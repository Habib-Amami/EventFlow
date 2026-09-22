from typing import Annotated, Literal

from pydantic import Field, StringConstraints

ServiceName = Annotated[
    str,
    StringConstraints(
        strip_whitespace=True,
        min_length=1,
        max_length=100
    ),
]

EventType = Annotated[
    str,
    StringConstraints(
        strip_whitespace=True,
        min_length=1,
        max_length=100
    ),
]

EventText = Annotated[
    str,
    StringConstraints(
        strip_whitespace=True,
        min_length=1,
        max_length=1000
    ),
]

Environment = Literal["dev", "production"]

EventId = Annotated[
    str,
    StringConstraints(
        strip_whitespace=True,
        min_length=1,
        max_length=100
    ),
]

StatusCode = Annotated[
    int,
    Field(ge=100, le=599),
]