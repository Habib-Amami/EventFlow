from unittest.mock import MagicMock

from conftest import load_lambda_module


query = load_lambda_module(
    "services/query/handler.py",
    "query_handler",
)


def test_existing_event_returns_200(monkeypatch):
    table_mock = MagicMock()
    table_mock.get_item.return_value = {"Item": {"event_id": "event-1"}}
    monkeypatch.setattr(query, "table", table_mock)

    response = query.lambda_handler(
        {"pathParameters": {"event_id": "event-1"}},
        None,
    )

    assert response["statusCode"] == 200
    assert '"event_id": "event-1"' in response["body"]


def test_missing_event_returns_404(monkeypatch):
    table_mock = MagicMock()
    table_mock.get_item.return_value = {}
    monkeypatch.setattr(query, "table", table_mock)

    response = query.lambda_handler(
        {"pathParameters": {"event_id": "missing"}},
        None,
    )

    assert response["statusCode"] == 404


def test_missing_event_id_returns_400():
    response = query.lambda_handler({}, None)

    assert response["statusCode"] == 400


def test_dynamodb_failure_returns_500(monkeypatch):
    table_mock = MagicMock()
    table_mock.get_item.side_effect = RuntimeError("DynamoDB unavailable")
    monkeypatch.setattr(query, "table", table_mock)

    response = query.lambda_handler(
        {"pathParameters": {"event_id": "event-1"}},
        None,
    )

    assert response["statusCode"] == 500