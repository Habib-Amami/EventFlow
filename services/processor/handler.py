import os
import json
from datetime import datetime, timezone

import boto3
from pydantic import ValidationError

from common.event_message import EventMessage



s3 = boto3.client("s3")
dynamodb = boto3.resource("dynamodb")

RAW_EVENTS_BUCKET = os.environ["RAW_EVENTS_BUCKET"]
DYNAMODB_TABLE_NAME = os.environ["DYNAMODB_TABLE_NAME"]
table = dynamodb.Table(DYNAMODB_TABLE_NAME)  # type: ignore


def process_record(record):
    body = json.loads(record["body"])
    event_message = EventMessage(**body)

    # Archive the raw event
    s3.put_object(
        Bucket=RAW_EVENTS_BUCKET,
        Key=f"{event_message.event_id}.json",
        Body=record["body"],
        ContentType="application/json",
    )

    # Write the processed result
    table.put_item(
        Item={
            "event_id": event_message.event_id,
            "service": event_message.service,
            "environment": event_message.environment,
            "event_type": event_message.event_type,
            "message": event_message.message,
            "processed_at": datetime.now(timezone.utc).isoformat(),
        }
    )


def lambda_handler(event, context):
    batch_item_failures = []

    for record in event["Records"]:
        try:
            process_record(record)
        except (ValidationError, json.JSONDecodeError, KeyError):
            batch_item_failures.append({"itemIdentifier": record["messageId"]})
        except Exception:
            batch_item_failures.append({"itemIdentifier": record["messageId"]})

    return {"batchItemFailures": batch_item_failures}