from datetime import datetime

import pytest
from pydantic import ValidationError

from common.event_message import EventMessage
from models.ingestion_request import IngestionRequest


VALID_REQUEST = {
    "service": "billing",
    "environment": "dev",
    "event_type": "invoice.created",
    "message": "Invoice created",
}


def test_required_fields_are_enforced():
    with pytest.raises(ValidationError):
        IngestionRequest.model_validate({"service": "billing"})


@pytest.mark.parametrize("field", ["service", "event_type", "message"])
def test_empty_strings_are_rejected(field):
    payload = {**VALID_REQUEST, field: ""}

    with pytest.raises(ValidationError):
        IngestionRequest.model_validate(payload)


@pytest.mark.parametrize(
    ("field", "length"),
    [("service", 101), ("event_type", 101), ("message", 1001)],
)
def test_values_longer_than_limits_are_rejected(field, length):
    payload = {**VALID_REQUEST, field: "x" * length}

    with pytest.raises(ValidationError):
        IngestionRequest.model_validate(payload)


@pytest.mark.parametrize("environment", ["test", "staging", "prod"])
def test_environment_accepts_only_dev_or_production(environment):
    with pytest.raises(ValidationError):
        IngestionRequest.model_validate(
            {**VALID_REQUEST, "environment": environment}
        )


def test_event_message_rejects_invalid_event_id():
    with pytest.raises(ValidationError):
        EventMessage(
            event_id="",
            service="billing",
            environment="dev",
            event_type="invoice.created",
            message="Invoice created",
            received_at=datetime.fromisoformat("2026-09-22T12:00:00+00:00"),
        )