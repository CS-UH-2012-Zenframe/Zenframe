"""
Ingest news → send ONE prompt to Llama‑3 → get:
• rewritten_headline
• summary (≤ 2 sentences, positive tone)
• positivity (1‑100)
• category (one of 10 canonical labels)
Then upsert into Mongo.

Retries, JSON‑parsing guard, and duplicate‑key handling included.
"""

from __future__ import annotations
import os, logging, time, html, re, json
from datetime import datetime
from typing import Tuple, Dict, Any

import requests
from together import Together
from pymongo.errors import DuplicateKeyError
from bson import ObjectId

from ..extensions import mongo

# -----------------------------------------------------------------------------
NEWS_API   = "https://api.thenewsapi.com/v1/news/all"
TOGETHER   = Together(api_key=os.getenv("TOGETHER_API_KEY"))
LLM_MODEL  = os.getenv("TOGETHER_MODEL", "meta-llama/Llama-3-8b-chat-hf")
REQUEST_TIMEOUT = 12  # s

ALLOWED_CATEGORIES = [
    "world", "politics", "business", "tech", "science",
    "health", "sports", "entertainment", "travel", "lifestyle"
]

# unique index (idempotent)
# mongo.db.News_reserve.create_index("source_url", unique=True, sparse=True)

# -----------------------------------------------------------------------------
def _clean(text: str | None) -> str:
    """Strip HTML & collapse whitespace."""
    if not text:
        return ""
    text = re.sub(r"<[^>]+>", "", html.unescape(text))
    return re.sub(r"\s+", " ", text).strip()

# -----------------------------------------------------------------------------
def _llm_analyse(title: str, body: str) -> Tuple[str, str, int, str]:
    """
    Returns (rewritten_headline, summary, positivity, category).
    If anything goes wrong → raise.
    """
    prompt = (
        "You are a news rewriter and sentiment analyser. "
        "Given an original headline & article text, produce JSON **exactly** in "
        "this format (no markdown, no commentary):\n\n"
        "{\n"
        '  "rewritten_headline": "<headline ≤ 15 words, no quotes>",\n'
        '  "summary": "<2 sentences, positive tone>",\n'
        '  "positivity": <integer 1‑100, 100 happiest>,\n'
        f'  "category": "<one of {ALLOWED_CATEGORIES}>"\n'
        "}\n\n"
        f"Original headline: {title}\n"
        f"Article text: {body[:1500]}\n"
    )

    resp = TOGETHER.chat.completions.create(
        model=LLM_MODEL,
        messages=[{"role": "user", "content": prompt}],
        temperature=0.6,
    )
    raw = resp.choices[0].message.content.strip()

    try:
        data: Dict[str, Any] = json.loads(raw)
        head   = str(data["rewritten_headline"]).strip()
        summ   = str(data["summary"]).strip()
        pos    = int(data["positivity"])
        cat    = str(data["category"]).lower()
        if cat not in ALLOWED_CATEGORIES:
            cat = "other"
        pos = max(1, min(100, pos))
        return head, summ, pos, cat
    except Exception as exc:
        raise ValueError(f"Bad LLM JSON: {exc} | Raw: {raw[:120]}")

# -----------------------------------------------------------------------------
def _fallback(title: str, body: str) -> Tuple[str, str, int, str]:
    """Emergency fallback if LLM fails."""
    summary = body[:160] + "…" if len(body) > 160 else body
    return title, summary, 50, "other"

# -----------------------------------------------------------------------------
def ingest_once() -> int:
    params = {
        "api_token": os.getenv("NEWS_API_TOKEN"),
        "language": os.getenv("NEWS_LANGUAGE", "en"),
        "page_size": int(os.getenv("NEWS_PAGE_SIZE", 50)),
    }
    pages = int(os.getenv("NEWS_MAX_PAGES", 3))

    inserted = 0
    for page in range(1, pages + 1):
        params["page"] = page
        try:
            r = requests.get(NEWS_API, params=params, timeout=REQUEST_TIMEOUT)
            r.raise_for_status()
            articles = r.json().get("data", [])
        except Exception as exc:
            logging.error("NewsAPI page %d failed: %s", page, exc)
            break

        for art in articles:
            url = art.get("url")
            if not url:
                continue

            body = _clean(
                " ".join(
                    filter(
                        None,
                        [art.get("content"), art.get("description"), art.get("snippet")],
                    )
                )
            )
            title = art.get("title") or art.get("headline") or ""
            # ── LLM step with 2 retries ───────────────────────────────
            for attempt in range(3):
                try:
                    head, summ, pos, cat = _llm_analyse(title, body)
                    break
                except Exception as exc:
                    logging.warning("LLM attempt %d failed: %s", attempt + 1, exc)
                    if attempt == 2:
                        head, summ, pos, cat = _fallback(title, body)
                    else:
                        time.sleep(2 * (attempt + 1))

            # ── Upsert into Mongo (dedupe on source_url) ─────────────
            try:
                res = mongo.db.News_reserve.replace_one(
                    {"source_url": url},
                    {
                        "headline":      head,
                        "excerpt":       summ,
                        "positivity":    pos,
                        "category":      cat,
                        "full_body":     body,
                        "created_date":  datetime.utcnow(),
                        "source_url":    url,
                        "orig_headline": title,
                    },
                    upsert=True,
                )
                if res.upserted_id:
                    inserted += 1
            except DuplicateKeyError:
                continue  # race condition dup

        time.sleep(1)  # polite delay between pages

    logging.info("Ingest cycle done – %d new docs", inserted)
    return inserted
