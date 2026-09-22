import importlib.util
import os
import sys
from pathlib import Path


ROOT = Path(__file__).parents[1]
sys.path.insert(0, str(ROOT / "layers/common-layer/python"))
sys.path.insert(0, str(ROOT / "services/ingestion"))

os.environ.setdefault("AWS_ACCESS_KEY_ID", "testing")
os.environ.setdefault("AWS_SECRET_ACCESS_KEY", "testing")
os.environ.setdefault("AWS_DEFAULT_REGION", "us-east-1")
os.environ.setdefault("AWS_EC2_METADATA_DISABLED", "true")
os.environ.setdefault("QUEUE_URL", "https://sqs.us-east-1.amazonaws.com/123/events")
os.environ.setdefault("RAW_EVENTS_BUCKET", "eventflow-raw-events")
os.environ.setdefault("DYNAMODB_TABLE_NAME", "eventflow-results")


def load_lambda_module(relative_path: str, module_name: str):
    module_path = ROOT / relative_path
    spec = importlib.util.spec_from_file_location(module_name, module_path)
    if spec is None or spec.loader is None:
        raise ImportError(f"Unable to load {module_path}")

    module = importlib.util.module_from_spec(spec)
    sys.modules[module_name] = module
    spec.loader.exec_module(module)
    return module