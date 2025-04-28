"""
Seed script: creates 1 demo user + 3 dummy news docs.
Usage:  python seed.py
"""
import random
from pprint import pprint
from app import create_app
from app.models import create_user, create_news

app = create_app()

with app.app_context():  # Flask-PyMongo needs application context
    user_id = create_user("Demo", "User", "demo@example.com", "demo1234")
    categories = ["world", "tech", "sports", "business"]
    ids = []
    for i in range(3):
        nid = create_news(
            headline=f"Sample Headline {i+1}",
            excerpt="Short excerpt for testing.",
            positivity=random.randint(0, 100),
            category=random.choice(categories),
            full_body="Full article body lorem ipsum... " * 5,
        )
        ids.append(nid)
    pprint({"demo_user_id": user_id, "seed_news_ids": ids})
