import logging
from .services.ingest import ingest_once

def fetch_news():
    try:
        n = ingest_once()
        logging.info("⏰ ingest_once() OK – %d new docs", n)
    except Exception:                    # catch-all so the job never dies
        logging.exception("⏰ ingest_once() crashed")

def register_jobs(sched):
    sched.add_job(
        id="news_ingest_job",
        func=fetch_news,
        trigger="interval",
        hours=2,
        replace_existing=True,
        max_instances=1,
        coalesce=True,
        misfire_grace_time=600,
    )
