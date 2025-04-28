"""
Marshmallow schemas for easy validation / serialisation.
"""
from marshmallow import Schema, fields, validate


class SignUpSchema(Schema):
    first_name = fields.Str(required=True, validate=validate.Length(min=1))
    last_name = fields.Str(required=True, validate=validate.Length(min=1))
    email = fields.Email(required=True)
    password = fields.Str(required=True, validate=validate.Length(min=6))


class LoginSchema(Schema):
    email = fields.Email(required=True)
    password = fields.Str(required=True)


class CommentSchema(Schema):
    # shown in API responses, ignored on input
    user_id = fields.Str(dump_only=True)
    comment_content = fields.Str(required=True, validate=validate.Length(min=1))
