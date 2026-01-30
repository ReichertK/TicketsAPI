#!/usr/bin/env python3
"""Test rápido de los 4 endpoints que fallaron"""
import json
import urllib.request
import ssl

ssl._create_default_https_context = ssl._create_unverified_context

def request(method, url, data=None, headers=None):
    if headers is None:
        headers = {}
    if data and not isinstance(data, bytes):
        data = json.dumps(data).encode()
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            content = resp.read().decode()
            return resp.status, json.loads(content) if content else {}
    except urllib.error.HTTPError as e:
        return e.code, {}
    except Exception as e:
        return 0, {"error": str(e)}

# Login
print("[1] Login...", end=" ")
status, resp = request("POST", "https://localhost:5001/api/v1/Auth/login",
                      {"Usuario": "admin", "Contraseña": "changeme"},
                      {"Content-Type": "application/json"})
if status != 200:
    print(f"FAIL ({status})")
    exit(1)
token = resp.get("datos", {}).get("token", "")
print(f"OK")

headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

# Test 1: GET transiciones-permitidas
print("[2] GET /Tickets/1/transiciones-permitidas...", end=" ")
status, resp = request("GET", "https://localhost:5001/api/v1/Tickets/1/transiciones-permitidas", headers=headers)
if status == 200:
    print(f"OK ({len(resp.get('datos', []))} transiciones)")
else:
    print(f"FAIL ({status}): {resp.get('mensaje', resp.get('error', ''))[:100]}")

# Test 2: POST Grupos
print("[3] POST /Grupos...", end=" ")
status, resp = request("POST", "https://localhost:5001/api/v1/Grupos",
                      {"Id_Grupo": 0, "Tipo_Grupo": "Test"},
                      headers)
if status == 201:
    print("OK")
elif status == 403:
    print(f"BLOCKED (403 - esperado si rol no es Admin)")
else:
    print(f"FAIL ({status})")

# Test 3: POST Transiciones (con fix)
print("[4] POST /Tickets/1/Transition...", end=" ")
body = {"Id_Estado_Nuevo": 2, "Comentario": "Test"}
status, resp = request("POST", "https://localhost:5001/api/v1/Tickets/1/Transition", body, headers)
if status in [200, 201]:
    print("OK")
elif status == 403:
    print(f"BLOCKED (403 - transición no permitida)")
else:
    print(f"FAIL ({status})")

print("\nDONE")
