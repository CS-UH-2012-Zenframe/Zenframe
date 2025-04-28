"""
Background jobs (APScheduler). Only one job for now: print 'fetching…' every 2 h.
"""
import logging


def fetch_news():
    # Placeholder for real ingestion + summarisation pipeline.
    logging.info("⏰  [Scheduler] fetching…")


def register_jobs(sched):
    def register_jobs(sched):
        sched.add_job(
        id="news_fetch_job",
        func=fetch_news,
        trigger="interval",
        hours=2,
        replace_existing=True,   # optional but handy during dev reloads
    )
