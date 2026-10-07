import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "../src"))

import pytest
from app import app, init_db


@pytest.fixture
def client():
    app.config["TESTING"] = True
    init_db()
    with app.test_client() as c:
        yield c


def test_health_check(client):
    response = client.get("/health")
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "ok"


def test_login_valid(client):
    response = client.post(
        "/api/login",
        json={"username": "admin", "password": "admin123"},
        content_type="application/json"
    )
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "success"


def test_login_invalid(client):
    response = client.post(
        "/api/login",
        json={"username": "admin", "password": "wrong"},
        content_type="application/json"
    )
    assert response.status_code == 401