"""
Tests for utils.py
"""
import pytest
from flask import Flask
from bson import ObjectId
from werkzeug.exceptions import BadRequest

from app.utils import obj_id, required


def test_obj_id_valid():
    """Test obj_id with valid ObjectId string."""
    test_id = "507f1f77bcf86cd799439011"
    result = obj_id(test_id)
    assert isinstance(result, ObjectId)
    assert str(result) == test_id


def test_obj_id_invalid():
    """Test obj_id with invalid ObjectId string."""
    with pytest.raises(BadRequest) as excinfo:
        obj_id("invalid_id")
    assert "Invalid ID format" in str(excinfo.value.description)


def test_required_all_fields_present():
    """Test required with all fields present."""
    data = {
        "field1": "value1",
        "field2": "value2",
        "field3": "value3"
    }
    # Should not raise any exception
    required(data, ["field1", "field2"])


def test_required_missing_fields():
    """Test required with missing fields."""
    data = {
        "field1": "value1"
    }
    with pytest.raises(BadRequest) as excinfo:
        required(data, ["field1", "field2", "field3"])
    assert "Missing fields: field2, field3" in str(excinfo.value.description)


def test_required_empty_fields_list():
    """Test required with empty fields list."""
    data = {
        "field1": "value1"
    }
    # Should not raise any exception
    required(data, [])


def test_required_empty_data():
    """Test required with empty data dict."""
    with pytest.raises(BadRequest) as excinfo:
        required({}, ["field1", "field2"])
    assert "Missing fields: field1, field2" in str(excinfo.value.description) 