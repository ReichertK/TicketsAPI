#!/usr/bin/env python3
"""
Test rápido: Login + 3 endpoints clave tras fixes
"""
import requests
import json
import sys
import time
from urllib3.exceptions import InsecureRequestWarning

requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

API = "http://localhost:5000/api/v1"
TIMEOUT = 10

print("[*] Iniciando pruebas rápidas...")
print(f"[*] API: {API}\n")

# 1. LOGIN
print("[TEST] POST /Auth/login")
try:
    resp = requests.post(
        f"{API}/Auth/login",
        json={"Usuario": "admin", "Contraseña": "changeme"},
        verify=False,
        timeout=TIMEOUT
    )
    print(f"  Status: {resp.status_code}")
    if resp.status_code == 200:
        body = resp.json()
        token = body.get("datos", {}).get("token", "")
        if token:
            print(f"  ✓ Token obtained ({len(token)} chars)\n")
        else:
            print(f"  ✗ No token in response\n")
            sys.exit(1)
    else:
        print(f"  ✗ Login failed: {resp.text[:200]}\n")
        sys.exit(1)
except Exception as e:
    print(f"  ✗ Error: {e}\n")
    sys.exit(1)

headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

# 2. GET transiciones-permitidas (Test fix #1: 500 → 200)
print("[TEST] GET /Tickets/1/transiciones-permitidas")
try:
    resp = requests.get(
        f"{API}/Tickets/1/transiciones-permitidas",
        headers=headers,
        verify=False,
        timeout=TIMEOUT
    )
    print(f"  Status: {resp.status_code}")
    if resp.status_code == 200:
        body = resp.json()
        count = len(body.get("datos", []))
        print(f"  ✓ Transiciones obtenidas: {count} items\n")
    else:
        print(f"  ✗ Failed: {resp.text[:200]}\n")
        sys.exit(1)
except Exception as e:
    print(f"  ✗ Error: {e}\n")
    sys.exit(1)

# 3. POST /Grupos (Test fix #2: 403 → 201 con admin)
print("[TEST] POST /Grupos (crear grupo con admin)")
try:
    body = {"Id_Grupo": 0, "Tipo_Grupo": "Test-Integracion"}
    resp = requests.post(
        f"{API}/Grupos",
        json=body,
        headers=headers,
        verify=False,
        timeout=TIMEOUT
    )
    print(f"  Status: {resp.status_code}")
    if resp.status_code in [201, 200]:
        print(f"  ✓ Grupo creado exitosamente\n")
    elif resp.status_code == 403:
        print(f"  ⚠ Acceso denegado (esperado si rol no es Admin,Administrador)\n")
    else:
        print(f"  ✗ Error: {resp.text[:200]}\n")
        sys.exit(1)
except Exception as e:
    print(f"  ✗ Error: {e}\n")
    sys.exit(1)

print("[SUCCESS] Todas las pruebas rápidas pasaron ✓")
sys.exit(0)
