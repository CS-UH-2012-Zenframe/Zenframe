"""
Extra tests focused on news/routes.py and comments/routes.py to lift coverage.
"""

import os
from unittest.mock import patch
import mongomock
import pytest


# ── Test app fixture ---------------------------------------------------------
@pytest.fixture(scope="session")
def app():
    os.environ["JWT_SECRET_KEY"] = "cov_secret"
    os.environ["SCHEDULER_API_ENABLED"] = "False"

    with patch("flask_pymongo.pymongo.MongoClient", mongomock.MongoClient):
        with patch("flask_apscheduler.APScheduler.start", lambda self: None):
            from app import create_app
            a = create_app()
            a.config["TESTING"] = True
            yield a


@pytest.fixture
def client(app):
    return app.test_client()


# ── Helpers ------------------------------------------------------------------
def token(client, email="u@test.com"):
    client.post("/signup", json={
        "first_name": "U", "last_name": "T",
        "email": email, "password": "p"
    })
    res = client.post("/login", json={"email": email, "password": "p"})
    return res.get_json()["access_token"]


def seed_one_news(app, score=70, cat="tech"):
    from app.models import create_news
    with app.app_context():
        return create_news(
            headline="H", excerpt="E", positivity=score,
            category=cat, full_body="B", source_url="u"
        )


# ── News route branch coverage ----------------------------------------------
def test_news_list_all_branches(client, app):
    # three docs: tech 80, science 40, tech 20
    seed_one_news(app, 80, "tech")
    seed_one_news(app, 40, "science")
    seed_one_news(app, 20, "tech")

    # default list
    assert client.get("/api/news").status_code == 200

    # positivity filter 50+
    hi = client.get("/api/news?positivity=50").get_json()
    assert len(hi) == 1 and hi[0]["positivity"] >= 50

    # category filter 'science'
    sci = client.get("/api/news?category=science").get_json()
    assert len(sci) == 1 and sci[0]["category"] == "science"

    # bad query values → fall back to defaults (limit non‑int)
    res = client.get("/api/news?limit=abc").status_code
    assert res == 200


def test_news_detail_valid_and_404(client, app):
    nid = seed_one_news(app, 75)
    ok = client.get(f"/api/news/{nid}")
    assert ok.status_code == 200 and ok.get_json()["news_id"] == nid

    # 24‑digit but nonexistent ObjectId → 404
    bad = client.get("/api/news/000000000000000000000000")
    assert bad.status_code == 404


# ── Comments route branch coverage ------------------------------------------
def test_add_comment_happy_400_401_404(client, app):
    nid = seed_one_news(app)
    jwt = token(client)

    # happy path
    good = client.post(f"/api/news/{nid}/add_comment",
                       headers={"Authorization": f"Bearer {jwt}"},
                       json={"comment_content": "Hi"})
    assert good.status_code == 201

    # missing field → 400
    miss = client.post(f"/api/news/{nid}/add_comment",
                       headers={"Authorization": f"Bearer {jwt}"},
                       json={})
    assert miss.status_code == 400

    # no token → 401
    unauth = client.post(f"/api/news/{nid}/add_comment",
                         json={"comment_content": "x"})
    assert unauth.status_code == 401

    # bad news id → 404
    notfound = client.post("/api/news/000000000000000000000000/add_comment",
                           headers={"Authorization": f"Bearer {jwt}"},
                           json={"comment_content": "x"})
    assert notfound.status_code == 404
