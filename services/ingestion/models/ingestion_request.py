from pydantic import BaseModel

from common.fields import Environment, EventText, EventType, ServiceName


class IngestionRequest(BaseModel):
    service: ServiceName
    environment: Environment
    event_type: EventType
    message: EventText