from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token
from marshmallow import ValidationError
from ..schemas import SignUpSchema, LoginSchema
from ..models import create_user, get_user_by_email, verify_password
from ..utils import required

auth_bp = Blueprint("auth", __name__)
_signup_schema = SignUpSchema()
_login_schema = LoginSchema()


@auth_bp.post("/signup")
def signup():
    data = request.get_json(force=True, silent=True) or {}
    try:
        data = _signup_schema.load(data)
    except ValidationError as err:
        return jsonify(err.messages), 400

    if get_user_by_email(data["email"]):
        return jsonify({"error": "Email already registered"}), 400

    uid = create_user(
        data["first_name"],
        data["last_name"],
        data["email"],
        data["password"],
    )
    token = create_access_token(identity=uid)
    return jsonify({"user_id": uid, "access_token": token}), 201


@auth_bp.post("/login")
def login():
    data = request.get_json(force=True, silent=True) or {}
    try:
        data = _login_schema.load(data)
    except ValidationError as err:
        return jsonify(err.messages), 400

    user = get_user_by_email(data["email"])
    if not user or not verify_password(data["password"], user["password"]):
        return jsonify({"error": "Invalid credentials"}), 401

    token = create_access_token(identity=str(user["_id"]))
    return jsonify({"access_token": token}), 200
