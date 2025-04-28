"""
Application factory & global error handling.
"""
from flask import Flask, jsonify
from .config import Config
from .extensions import mongo, jwt, cors, scheduler as apscheduler
from .auth.routes import auth_bp
from .news.routes import news_bp
from .comments.routes import comments_bp
from .scheduler import register_jobs


def create_app() -> Flask:
    app = Flask(__name__)
    app.config.from_object(Config())

    # ── Extensions ─────────────────────────────
    mongo.init_app(app)
    jwt.init_app(app)
    cors.init_app(app, resources={r"/*": {"origins": "*"}})
    apscheduler.init_app(app)
    register_jobs(apscheduler)
    apscheduler.start()

    # ── Blueprints ─────────────────────────────
    app.register_blueprint(auth_bp, url_prefix="")
    app.register_blueprint(news_bp, url_prefix="/api")
    app.register_blueprint(comments_bp, url_prefix="/api")

    # ── Error handlers ─────────────────────────
    @app.errorhandler(400)
    def bad_request(err):
        return jsonify({"error": err.description}), 400

    @app.errorhandler(401)
    def unauthorized(err):
        return jsonify({"error": err.description}), 401

    @app.errorhandler(404)
    def not_found(err):
        return jsonify({"error": "Resource not found"}), 404

    @app.errorhandler(500)
    def server_error(err):
        return jsonify({"error": "Internal server error"}), 500

    return app
