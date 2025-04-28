from flask import Blueprint, request, jsonify, abort
from ..models import list_news, get_news, list_comments
from ..utils import obj_id


news_bp = Blueprint("news", __name__)


def _as_int(arg, default=None):
    try:
        return int(arg) if arg is not None else default
    except ValueError:
        return default


@news_bp.get("/news")
def news_list():
    qp = request.args
    docs = list_news(
        positivity=_as_int(qp.get("positivity")),
        category=qp.get("category"),
        limit=max(1, min(100, _as_int(qp.get("limit"), 20))),
        offset=max(0, _as_int(qp.get("offset"), 0)),
    )
    return jsonify(docs), 200


@news_bp.get("/news/<news_id>")
def news_detail(news_id):
    doc = get_news(news_id)
    if not doc:
        abort(404)
    doc["comments"] = list_comments(news_id)
    return jsonify(doc), 200
