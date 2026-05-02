"""
Posts a synthetic market event to the Data Cloud Streaming Ingestion API.

Usage:
    export DC_INGEST_URL='https://<tenant>.c360a.salesforce.com/api/v1/ingest/sources/MarketEventStream/<connector>'
    export DC_TOKEN='<bearer>'
    python3 scripts/simulator/post_event.py scripts/simulator/events/rbi_mpc_25bps_cut.json

The Streaming Ingestion endpoint expects a JSON object (or a {"data": [...]}
batch). We POST the raw event body; if your connector requires the batch
wrapper, set DC_BATCH=1 and the script will wrap it for you.
"""

import json
import os
import ssl
import sys
import urllib.error
import urllib.request

_SSL_CTX = ssl.create_default_context()
_SSL_CTX.check_hostname = False
_SSL_CTX.verify_mode = ssl.CERT_NONE


def _load_event(path: str) -> bytes:
    with open(path, "rb") as f:
        body = f.read()
    if os.environ.get("DC_BATCH") == "1":
        event = json.loads(body)
        body = json.dumps({"data": [event]}).encode()
    return body


def main(path: str) -> int:
    try:
        url = os.environ["DC_INGEST_URL"]
        token = os.environ["DC_TOKEN"]
    except KeyError as missing:
        print(f"error: env var {missing} is required", file=sys.stderr)
        return 2

    body = _load_event(path)
    req = urllib.request.Request(
        url,
        data=body,
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(req, timeout=15, context=_SSL_CTX) as resp:
            print(f"HTTP {resp.status} {resp.reason}")
            print(resp.read().decode())
    except urllib.error.HTTPError as e:
        print(f"HTTP {e.code} {e.reason}", file=sys.stderr)
        print(e.read().decode(), file=sys.stderr)
        return 1
    except urllib.error.URLError as e:
        print(f"network error: {e.reason}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"usage: {sys.argv[0]} <event.json>", file=sys.stderr)
        sys.exit(2)
    sys.exit(main(sys.argv[1]))
