"""
All direct DB access lives here (pure functions, no Flask).  
Each function returns plain dicts with ObjectIds converted to str.
"""
from datetime import datetime
from typing import List, Optional, Dict, Any

from bson import ObjectId
from passlib.hash import bcrypt

from .extensions import mongo

# ─────────────────────────── USERS ────────────────────────────
def create_user(first: str, last: str, email: str, password: str) -> str:
    user = {
        "first_name": first,
        "last_name": last,
        "email": email.lower(),
        "password": bcrypt.hash(password),
        "created_date": datetime.utcnow(),
    }
    _id = mongo.db.Users.insert_one(user).inserted_id
    return str(_id)


def get_user_by_email(email: str) -> Optional[Dict]:
    return mongo.db.Users.find_one({"email": email.lower()})


def get_user_by_id(uid: str) -> Optional[Dict]:
    return mongo.db.Users.find_one({"_id": ObjectId(uid)})


def verify_password(raw: str, hashed: str) -> bool:
    return bcrypt.verify(raw, hashed)


# ─────────────────────────── NEWS ─────────────────────────────
def create_news(**kwargs) -> str:
    """
    kwargs: headline, excerpt, positivity(int), category, full_body
    """
    kwargs["created_date"] = datetime.utcnow()
    _id = mongo.db.News_reserve.insert_one(kwargs).inserted_id
    return str(_id)


def list_news(
    positivity: Optional[int] = None,
    category: Optional[str] = None,
    limit: int = 20,
    offset: int = 0,
) -> List[Dict]:
    query: Dict[str, Any] = {}
    if positivity is not None:
        query["positivity"] = {"$gte": positivity}
    if category:
        query["category"] = category

    cursor = (
        mongo.db.News_reserve.find(query)
        .skip(offset)
        .limit(limit)
        .sort("created_date", -1)
    )
    res = []
    for doc in cursor:
        doc["news_id"] = str(doc.pop("_id"))
        doc.pop("full_body", None)  # keep response light
        res.append(doc)
    return res


def get_news(news_id: str) -> Optional[Dict]:
    doc = mongo.db.News_reserve.find_one({"_id": ObjectId(news_id)})
    if not doc:
        return None
    doc["news_id"] = str(doc.pop("_id"))
    return doc


# ───────────────────────── COMMENTS ───────────────────────────
def add_comment(user_id: str, news_id: str, content: str) -> str:
    comment = {
        "user_id": user_id,
        "news_id": news_id,
        "comment_content": content,
        "created_date": datetime.utcnow(),
    }
    _id = mongo.db.Comments.insert_one(comment).inserted_id
    return str(_id)


def list_comments(news_id: str) -> List[Dict]:
    cursor = mongo.db.Comments.find({"news_id": news_id}).sort("created_date", -1)
    res = []
    for doc in cursor:
        doc["comment_id"] = str(doc.pop("_id"))
        res.append(doc)
    return res
