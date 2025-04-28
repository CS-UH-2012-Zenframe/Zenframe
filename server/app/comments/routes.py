from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from marshmallow import ValidationError

from ..schemas import CommentSchema
from ..models import add_comment, get_news
from ..utils import required

comments_bp = Blueprint("comments", __name__)
_comment_schema = CommentSchema()


@comments_bp.post("/news/<news_id>/add_comment")
@jwt_required()
def add_comment_route(news_id):
    if not get_news(news_id):
        return jsonify({"error": "News not found"}), 404

    data = request.get_json(force=True, silent=True) or {}
    try:
        data = _comment_schema.load(data)
    except ValidationError as err:
        return jsonify(err.messages), 400

    uid = get_jwt_identity()
    cid = add_comment(uid, news_id, data["comment_content"])
    return jsonify({"comment_id": cid}), 201
