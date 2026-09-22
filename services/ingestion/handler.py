import os
import json
from uuid import uuid7
from datetime import datetime, timezone

import boto3

from pydantic import ValidationError

from models.ingestion_request import IngestionRequest
from models.ingestion_response import (
    IngestionResponse,
    IngestionResult
)
from common.event_message import EventMessage


sqs = boto3.client("sqs")
QUEUE_URL = os.environ["QUEUE_URL"]

def lambda_handler(event, context):

    try:
        body = event.get("body")

        if body is None:
            raise ValueError("Missing request body")

        if not body:
            raise ValueError("Missing request body")

        payload = json.loads(body)

        ingestion_request = IngestionRequest(**payload)

        event_id = str(uuid7())
        event_message = EventMessage(
            event_id=event_id,
            service=ingestion_request.service,
            environment=ingestion_request.environment,
            event_type=ingestion_request.event_type,
            message=ingestion_request.message,
            received_at=datetime.now(timezone.utc),
        )

        sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=event_message.model_dump_json(),
        )

        result = IngestionResult(
            status="accepted",
            message="Event queued successfully",
            event_id=event_id,
        )
        status_code = 202

    except (ValidationError, json.JSONDecodeError, ValueError) as error:
        result = IngestionResult(
            status="failure",
            message=str(error),
        )
        status_code = 400

    except Exception:
        result = IngestionResult(
            status="failure",
            message="Unable to queue event",
        )
        status_code = 500

    response = IngestionResponse(
        statusCode=status_code,
        headers={"Content-Type": "application/json"},
        body=result.model_dump_json(),
    )

    return response.model_dump()