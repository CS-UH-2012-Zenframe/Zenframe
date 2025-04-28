"""
Small helpers reused across blueprints.
"""
from typing import Dict, List
from flask import abort
from bson import ObjectId


def obj_id(value: str) -> ObjectId:
    """Convert str→ObjectId, abort 400 on failure."""
    try:
        return ObjectId(value)
    except Exception:  # noqa: B902
        abort(400, description="Invalid ID format")


def required(data: Dict, fields: List[str]):
    """Abort 400 if any of `fields` missing from `data`."""
    miss = [f for f in fields if f not in data]
    if miss:
        abort(400, description=f"Missing fields: {', '.join(miss)}")
