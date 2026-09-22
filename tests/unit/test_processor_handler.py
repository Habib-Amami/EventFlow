import json
from unittest.mock import MagicMock

import pytest

from conftest import load_lambda_module


processor = load_lambda_module(
    "services/processor/handler.py",
    "processor_handler",
)


EVENT_BODY = json.dumps(
    {
        "event_id": "01a0c62e-016d-742d-a3e4-95b9a21b2390",
        "service": "billing",
        "environment": "dev",
        "event_type": "invoice.created",
        "message": "Invoice created",
        "received_at": "2026-09-22T12:00:00+00:00",
    }
)


def record(message_id="message-id", body=EVENT_BODY):
    return {"messageId": message_id, "body": body}


def configure_dependencies(monkeypatch):
    s3_mock = MagicMock()
    table_mock = MagicMock()
    monkeypatch.setattr(processor, "s3", s3_mock)
    monkeypatch.setattr(processor, "table", table_mock)
    return s3_mock, table_mock


def test_valid_record_writes_to_s3_and_dynamodb(monkeypatch):
    s3_mock, table_mock = configure_dependencies(monkeypatch)

    response = processor.lambda_handler({"Records": [record()]}, None)

    assert response == {"batchItemFailures": []}
    s3_mock.put_object.assert_called_once()
    table_mock.put_item.assert_called_once()


def test_multiple_records_are_processed(monkeypatch):
    s3_mock, table_mock = configure_dependencies(monkeypatch)

    response = processor.lambda_handler(
        {"Records": [record("first"), record("second")]},
        None,
    )

    assert response == {"batchItemFailures": []}
    assert s3_mock.put_object.call_count == 2
    assert table_mock.put_item.call_count == 2


@pytest.mark.parametrize(
    "body",
    ["not-json", json.dumps({"service": "billing"})],
)
def test_invalid_record_is_reported_as_batch_failure(monkeypatch, body):
    configure_dependencies(monkeypatch)

    response = processor.lambda_handler({"Records": [record(body=body)]}, None)

    assert response == {
        "batchItemFailures": [
            {"itemIdentifier": "message-id"}
        ]
    }


def test_s3_failure_is_reported_as_batch_failure(monkeypatch):
    s3_mock, _ = configure_dependencies(monkeypatch)
    s3_mock.put_object.side_effect = RuntimeError("S3 unavailable")

    response = processor.lambda_handler({"Records": [record()]}, None)

    assert response == {"batchItemFailures": [{"itemIdentifier": "message-id"}]}


def test_dynamodb_failure_is_reported_as_batch_failure(monkeypatch):
    _, table_mock = configure_dependencies(monkeypatch)
    table_mock.put_item.side_effect = RuntimeError("DynamoDB unavailable")

    response = processor.lambda_handler({"Records": [record()]}, None)

    assert response == {"batchItemFailures": [{"itemIdentifier": "message-id"}]}