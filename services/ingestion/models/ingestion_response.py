from pydantic import BaseModel, Field
from typing import Literal

from common.fields import EventId, EventText, StatusCode


class IngestionResult(BaseModel):
    status: Literal["accepted", "failure"]
    message: EventText
    event_id: EventId | None = None

class IngestionResponse(BaseModel):
    statusCode: StatusCode
    headers: dict[str, str] = Field(default_factory=dict)
    body: str = Field(min_length=1)