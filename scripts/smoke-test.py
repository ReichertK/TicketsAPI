#!/usr/bin/env python3
"""
Smoke test for TicketsAPI — validates core endpoints are responding.

Requires the API to be running. Configure via environment variables:
    API_BASE_URL  (default: https://localhost:5001/api/v1)
    API_USER      (default: admin)
    API_PASSWORD  (default: changeme)

Usage:
    python smoke-test.py
"""

import os
import sys
import json
import urllib3
from datetime import datetime
from typing import Tuple, Any, Dict

try:
    import requests
except ImportError:
    print("ERROR: 'requests' package required. Install with: pip install requests")
    sys.exit(1)

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# --- Configuration (from environment) ---
BASE_URL   = os.environ.get("API_BASE_URL", "https://localhost:5001/api/v1")
API_USER   = os.environ.get("API_USER", "admin")
API_PASS   = os.environ.get("API_PASSWORD", "changeme")
VERIFY_SSL = False
HEADERS    = {"Content-Type": "application/json"}


def request(method: str, path: str, headers: Dict = None, body: Dict = None,
            expect: int = None) -> Tuple[int, Any, bool]:
    """Execute HTTP request, return (status, data, matched_expected)."""
    url = f"{BASE_URL}{path}"
    h = headers or HEADERS.copy()
    try:
        resp = getattr(requests, method.lower())(url, headers=h, json=body,
                                                  verify=VERIFY_SSL, timeout=10)
        try:
            data = resp.json()
        except ValueError:
            data = resp.text
        ok = expect is None or resp.status_code == expect
        return resp.status_code, data, ok
    except Exception as e:
        return -1, str(e), False


def auth_header(token: str) -> Dict:
    h = HEADERS.copy()
    h["Authorization"] = f"Bearer {token}"
    return h


# --- Test suites ---

def test_auth() -> str | None:
    """Authenticate and return JWT token, or None on failure."""
    print("\n--- Auth ---")

    status, data, ok = request("POST", "/Auth/Login",
                               body={"Usuario": API_USER, "Contraseña": API_PASS},
                               expect=200)
    if ok and isinstance(data, dict) and data.get("datos", {}).get("token"):
        print(f"  Login .............. OK ({status})")
        return data["datos"]["token"]

    print(f"  Login .............. FAIL ({status})")
    return None


def test_read_endpoints(token: str) -> Tuple[int, int]:
    """Hit read-only endpoints. Returns (passed, failed)."""
    print("\n--- Read endpoints ---")
    passed = failed = 0
    endpoints = [
        ("/References/Estados",    "Estados"),
        ("/References/Prioridades","Prioridades"),
        ("/Tickets",               "Tickets"),
        ("/Departamentos",         "Departamentos"),
        ("/Motivos",               "Motivos"),
        ("/Grupos",                "Grupos"),
    ]
    h = auth_header(token)
    for path, label in endpoints:
        status, data, ok = request("GET", path, headers=h, expect=200)
        tag = "OK" if ok else "FAIL"
        count = f" ({len(data)} items)" if isinstance(data, list) else ""
        print(f"  {label:20s} {tag} ({status}){count}")
        if ok:
            passed += 1
        else:
            failed += 1
    return passed, failed


def test_permissions(token: str) -> Tuple[int, int]:
    """Verify auth enforcement."""
    print("\n--- Permissions ---")
    passed = failed = 0

    # No token → 401
    status, _, _ = request("GET", "/Tickets", expect=401)
    if status == 401:
        print(f"  No token ........... 401 OK")
        passed += 1
    else:
        print(f"  No token ........... FAIL ({status})")
        failed += 1

    # Bad token → 401
    bad = auth_header("invalid.token.here")
    status, _, _ = request("GET", "/Tickets", headers=bad, expect=401)
    if status == 401:
        print(f"  Bad token .......... 401 OK")
        passed += 1
    else:
        print(f"  Bad token .......... FAIL ({status})")
        failed += 1

    # Valid token → 200
    status, _, _ = request("GET", "/Tickets", headers=auth_header(token), expect=200)
    if status == 200:
        print(f"  Valid token ........ 200 OK")
        passed += 1
    else:
        print(f"  Valid token ........ FAIL ({status})")
        failed += 1

    return passed, failed


# --- Main ---

def main():
    print(f"TicketsAPI Smoke Test — {datetime.now():%Y-%m-%d %H:%M:%S}")
    print(f"Target: {BASE_URL}")

    token = test_auth()
    if not token:
        print("\nABORTED: Could not authenticate.")
        sys.exit(1)

    p1, f1 = test_read_endpoints(token)
    p2, f2 = test_permissions(token)

    total_pass = p1 + p2 + 1  # +1 for login
    total_fail = f1 + f2
    total = total_pass + total_fail

    print(f"\n{'='*40}")
    print(f"Results: {total_pass}/{total} passed", end="")
    if total_fail:
        print(f", {total_fail} FAILED")
        sys.exit(1)
    else:
        print(" — ALL OK")
        sys.exit(0)


if __name__ == "__main__":
    main()
