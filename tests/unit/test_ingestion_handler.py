import json
from unittest.mock import MagicMock

import pytest

from conftest import load_lambda_module


ingestion = load_lambda_module(
    "services/ingestion/handler.py",
    "ingestion_handler",
)


VALID_PAYLOAD = {
    "service": "billing",
    "environment": "dev",
    "event_type": "invoice.created",
    "message": "Invoice created",
}


def invoke(body):
    return ingestion.lambda_handler({"body": body}, None)


def test_valid_request_returns_202_and_sends_to_sqs(monkeypatch):
    sqs_mock = MagicMock()
    monkeypatch.setattr(ingestion, "sqs", sqs_mock)

    response = invoke(json.dumps(VALID_PAYLOAD))

    assert response["statusCode"] == 202
    sqs_mock.send_message.assert_called_once()
    assert sqs_mock.send_message.call_args.kwargs["QueueUrl"] == ingestion.QUEUE_URL


@pytest.mark.parametrize("body", [None, ""])
def test_missing_body_returns_400(body):
    response = invoke(body)

    assert response["statusCode"] == 400


def test_invalid_json_returns_400():
    response = invoke("not-json")

    assert response["statusCode"] == 400


def test_invalid_fields_returns_400():
    response = invoke(json.dumps({"service": "", "environment": "dev"}))

    assert response["statusCode"] == 400


def test_sqs_failure_returns_500(monkeypatch):
    sqs_mock = MagicMock()
    sqs_mock.send_message.side_effect = RuntimeError("SQS unavailable")
    monkeypatch.setattr(ingestion, "sqs", sqs_mock)

    response = invoke(json.dumps(VALID_PAYLOAD))

    assert response["statusCode"] == 500