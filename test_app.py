import pytest
from app import app

@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client

def test_index_route(client):
    res = client.get("/")
    assert res.status_code == 200
    data = res.get_json()
    assert data["status"] == "success"
    assert "Flask DevOps API" in data["message"]

def test_health_route(client):
    res = client.get("/health")
    assert res.status_code == 200
    data = res.get_json()
    assert data["status"] == "healthy"
    assert "uptime_seconds" in data
    assert data["uptime_seconds"] >= 0

def test_404_route(client):
    res = client.get("/invalid-route-test")
    assert res.status_code == 404
    data = res.get_json()
    assert data["status"] == "error"
