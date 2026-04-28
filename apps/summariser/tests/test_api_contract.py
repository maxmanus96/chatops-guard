import pytest

fastapi = pytest.importorskip("fastapi")

from fastapi.testclient import TestClient

from chatops_guard_summariser.main import app


def test_healthz_returns_ok() -> None:
    client = TestClient(app)

    response = client.get("/healthz")

    assert response.status_code == 200
    assert response.json() == {"status": "ok", "service": "summariser"}


def test_summarise_returns_operator_friendly_shape() -> None:
    client = TestClient(app)

    response = client.post(
        "/summarise",
        json={
            "source": "aks",
            "severity": "warning",
            "title": "Readiness probe failures",
            "message": "Pod api failed readiness probe 12 times",
            "resource": "pod/api",
        },
    )

    assert response.status_code == 200
    body = response.json()
    assert body["summary"] == "aks reported warning: Readiness probe failures (pod/api)"
    assert body["mode"] == "rule_based_stub"
    assert "next_action" in body

