import json
import os
import time
from urllib.error import HTTPError
from urllib.request import Request, urlopen

import pytest


TEST_EVENT = {
    "service": "integration-test",
    "environment": "dev",
    "event_type": "test.created",
    "message": "EventFlow integration test",
}


def request_json(method: str, url: str, payload: dict | None = None) -> tuple[int, dict]:
    body = None
    headers = {"Accept": "application/json"}

    if payload is not None:
        body = json.dumps(payload).encode("utf-8")
        headers["Content-Type"] = "application/json"

    request = Request(url, data=body, headers=headers, method=method)

    try:
        with urlopen(request, timeout=10) as response:
            return response.status, json.load(response)
    except HTTPError as error:
        return error.code, json.loads(error.read())


def response_body(response: dict) -> dict:
    body = response.get("body", response)
    return json.loads(body) if isinstance(body, str) else body


@pytest.mark.integration
def test_event_can_be_created_and_queried():
    api_url = os.getenv("EVENTFLOW_API_URL", "").rstrip("/")

    if not api_url:
        pytest.skip("Set EVENTFLOW_API_URL to run integration tests")

    status, response = request_json("POST", api_url, TEST_EVENT)

    assert status == 202
    event_id = response_body(response)["event_id"]

    query_url = f"{api_url}/{event_id}"
    deadline = time.monotonic() + 30

    while time.monotonic() < deadline:
        query_status, query_response = request_json("GET", query_url)

        if query_status == 200:
            query_result = response_body(query_response)
            assert query_result["event_id"] == event_id
            assert query_result["service"] == TEST_EVENT["service"]
            return

        assert query_status == 404
        time.sleep(1)

    pytest.fail(f"Event {event_id} was not available from the query endpoint")