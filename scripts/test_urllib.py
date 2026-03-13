#!/usr/bin/env python3
import json
import sys
import urllib.request
import ssl

ssl._create_default_https_context = ssl._create_unverified_context

def test():
    # Try both HTTP and HTTPS
    for api_base in ["https://localhost:5001/api/v1", "http://localhost:5000/api/v1"]:
        print(f"[1] Testing login at {api_base}...")
        payload = json.dumps({"Usuario": "admin", "Contraseña": "changeme"}).encode()
        req = urllib.request.Request(
            f"{api_base}/Auth/login",
            data=payload,
            headers={"Content-Type": "application/json"},
            method="POST"
        )
        try:
            with urllib.request.urlopen(req, timeout=20) as resp:
                data = json.loads(resp.read().decode())
                token = data.get("datos", {}).get("token", "")
                if token:
                    print(f"  OK: Got token ({len(token)} chars)")
                    return token
        except urllib.error.HTTPError as e:
            print(f"  HTTP {e.code}: {e.reason}")
        except Exception as e:
            print(f"  Error: {e}")
    return None

if __name__ == "__main__":
    token = test()
    if not token:
        sys.exit(1)
    print("\nSUCCESS")
