from datetime import datetime

from pydantic import BaseModel

from common.fields import Environment, EventId, EventText, EventType, ServiceName


class EventMessage(BaseModel):
    event_id: EventId
    service: ServiceName
    environment: Environment
    event_type: EventType
    message: EventText
    received_at: datetime
