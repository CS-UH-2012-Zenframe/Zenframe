"""
Ingest news → rewrite & summarise via LLM → store in Mongo.
Called by the 2-hour APScheduler job.
"""
from __future__ import annotations
import os, logging, time, html, re, hashlib
from datetime import datetime

import requests
from together import Together
from textblob import TextBlob
from bson.objectid import ObjectId
from pymongo.errors import DuplicateKeyError

from ..extensions import mongo
from ..models import create_news

# ---------------------------------------------------------------------
ALLOWED_CATEGORIES = {
    "world", "politics", "business", "tech", "science",
    "health", "sports", "entertainment", "travel", "lifestyle"
}
DEFAULT_CATEGORY = "other"

# ---------------------------------------------------------------------
NEWS_API = "https://api.thenewsapi.com/v1/news/all"
TOGETHER_CLIENT = Together(api_key=os.getenv("TOGETHER_API_KEY"))
MODEL = os.getenv("TOGETHER_MODEL", "meta-llama/Llama-3-8b-chat-hf")

LANG = os.getenv("NEWS_LANGUAGE", "en")
PAGES = int(os.getenv("NEWS_MAX_PAGES", 3))
PAGE_SIZE = int(os.getenv("NEWS_PAGE_SIZE", 100))
REQUEST_TIMEOUT = 10


def _positivity(text: str) -> int:
    """-1..1 → 0..100"""
    return int((TextBlob(text).sentiment.polarity + 1) * 50)

def _norm_category(raw: str | None) -> str:
    if not raw:
        return DEFAULT_CATEGORY
    raw_l = raw.lower()
    if raw_l in ALLOWED_CATEGORIES:
        return raw_l
    # fuzzy map: ‘technology’ → ‘tech’, ‘sci-tech’ → ‘tech’, etc.
    for cat in ALLOWED_CATEGORIES:
        if cat in raw_l:
            return cat
    return DEFAULT_CATEGORY


def _clean(txt: str) -> str:
    txt = re.sub(r"<[^>]+>", "", html.unescape(txt or ""))
    return re.sub(r"\s+", " ", txt).strip()


def _summary(full: str, sentences: int = 2) -> str:
    parts = re.split(r"(?<=[.!?]) +", _clean(full))
    return " ".join(parts[:sentences]) or _clean(full)[:200]


def _rewrite_llm(title: str, body: str) -> tuple[str, str]:
    """
    Returns (headline, summary) with zero boilerplate and zero formatting only the string.
    Model must answer with exactly TWO lines:
      line-1 → rewritten headline (≤ 15 words)
      line-2 → two-sentence summary
    """
    prompt = (
        "Rewrite the following news headline and give a positive-tone 2-sentence summary.\n"
        "Answer with **exactly two lines**:\n"
        "1) Your rewritten headline (max 15 words, no prefix or quotes, no formatting, only plain string, no title or any extra information just the rewritten headline).\n"
        "2) The summary (exactly 2 sentences, no prefix, or quotes, no formatting, only plain string, no titles like summary or similar).\n\n"
        f"Original headline: {title}\n"
        f"Article text: {body[:1000]}\n"
    )

    for attempt in range(3):
        try:
            resp = TOGETHER_CLIENT.chat.completions.create(
                model=MODEL,
                messages=[{"role": "user", "content": prompt}],
                temperature=0.6,
            )
            raw = resp.choices[0].message.content.strip()
            lines = [l.strip(" *-:_") for l in raw.splitlines() if l.strip()]
            if len(lines) < 2:
                raise ValueError("wrong format")
            headline = re.sub(r"^Rewritten headline[:\- ]*", "", lines[0], flags=re.I)
            summary  = re.sub(r"^Summary[:\- ]*", "", lines[1], flags=re.I)
            return headline[:180], summary
        except Exception as exc:
            logging.warning("LLM attempt %d failed: %s", attempt + 1, exc)
            time.sleep(2 * (attempt + 1))
    # fallback – keep original title & heuristic summary
    return title, _summary(body)



def ingest_once() -> int:
    # ensure index exists (idempotent)
    mongo.db.News_reserve.create_index(
        "source_url", unique=True, sparse=True, background=True
    )

    params = {
        "api_token": os.getenv("NEWS_API_TOKEN"),
        "language": LANG,
        "page_size": PAGE_SIZE,
    }

    inserted = 0
    for page in range(1, PAGES + 1):
        params["page"] = page
        try:
            r = requests.get(NEWS_API, params=params, timeout=REQUEST_TIMEOUT)
            r.raise_for_status()
            data = r.json().get("data", [])
        except Exception as exc:
            logging.error("NewsAPI call failed (page %d): %s", page, exc)
            break    # network is down – try next cycle

        for art in data:
            url = art.get("url")
            if not url:
                continue
            src_raw = art.get("source")
            category = _norm_category(
                src_raw.get("name") if isinstance(src_raw, dict) else src_raw
            )

            orig_head = art.get("title") or ""
            body_pieces = [
                art.get("content"),
                art.get("description"),
                art.get("snippet")
            ]
            full_body  = _clean(" ".join(filter(None, body_pieces)))
            new_head, summary = _rewrite_llm(orig_head, full_body)
            positivity = _positivity(full_body or orig_head)

            try:
                res = mongo.db.News_reserve.replace_one(
                    {"source_url": url},
                    {
                        "headline":      new_head,
                        "excerpt":       summary,
                        "positivity":    positivity,
                        "category":      category,
                        "full_body":     full_body,
                        "created_date":  datetime.utcnow(),
                        "source_url":    url,
                        "orig_headline": orig_head,
                    },
                    upsert=True,
                )
                if res.upserted_id:
                    inserted += 1
            except DuplicateKeyError:
                continue

