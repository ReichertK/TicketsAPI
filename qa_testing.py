#!/usr/bin/env python3
import requests
import json
from datetime import datetime
import urllib3

urllib3.disable_warnings()
requests.packages.urllib3.disable_warnings()

BASE_URL = "http://localhost:5000/api/v1"
TEST_RESULTS = []
JWT_TOKEN = ""
REFRESH_TOKEN = ""

class C:
    G = '\033[92m'
    R = '\033[91m'
    Y = '\033[93m'
    C = '\033[96m'
    B = '\033[1m'
    E = '\033[0m'

def log_result(test_name, passed, msg):
    status = "[PASS]" if passed else "[FAIL]"
    color = C.G if passed else C.R
    print(f"{color}{status}{C.E} {test_name}\n  -> {msg}")
    TEST_RESULTS.append({"test": test_name, "passed": passed, "msg": msg})

print(f"\n{C.C}=== FASE 1: AUTENTICACION ==={C.E}\n")

print(f"{C.Y}[1.1] POST /Auth/login - Validas{C.E}")
try:
    r = requests.post(f"{BASE_URL}/Auth/login", json={"Usuario": "admin", "Contrasena": "changeme"}, timeout=5, verify=False)
    if r.status_code == 200:
        JWT_TOKEN = r.json().get("data", {}).get("token", "")
        REFRESH_TOKEN = r.json().get("data", {}).get("refreshToken", "")
        if JWT_TOKEN:
            log_result("Login valido", True, f"Status {r.status_code}")
        else:
            log_result("Login valido", False, "Sin token")
    else:
        log_result("Login valido", False, f"Status {r.status_code}")
except Exception as e:
    log_result("Login valido", False, str(e))

print(f"\n{C.Y}[1.2] POST /Auth/login - Invalidas{C.E}")
try:
    r = requests.post(f"{BASE_URL}/Auth/login", json={"Usuario": "invalid", "Contrasena": "wrong"}, timeout=5, verify=False)
    log_result("Login invalido", r.status_code == 401, f"Status {r.status_code}")
except Exception as e:
    log_result("Login invalido", False, str(e))

if not JWT_TOKEN:
    print(f"\n{C.R}ERROR: Sin JWT token{C.E}\n")
    exit(1)

headers = {"Authorization": f"Bearer {JWT_TOKEN}"}

print(f"\n{C.Y}[1.3] POST /Auth/refresh-token{C.E}")
try:
    r = requests.post(f"{BASE_URL}/Auth/refresh-token", json={"refreshToken": REFRESH_TOKEN}, timeout=5, verify=False)
    if r.status_code == 200:
        JWT_TOKEN = r.json().get("data", {}).get("token", JWT_TOKEN)
        headers["Authorization"] = f"Bearer {JWT_TOKEN}"
        log_result("Refresh token", True, f"Status {r.status_code}")
    else:
        log_result("Refresh token", False, f"Status {r.status_code}")
except Exception as e:
    log_result("Refresh token", False, str(e))

print(f"\n{C.Y}[1.4] GET /Auth/me{C.E}")
try:
    r = requests.get(f"{BASE_URL}/Auth/me", headers=headers, timeout=5, verify=False)
    log_result("GET /Auth/me", r.status_code == 200, f"Status {r.status_code}")
except Exception as e:
    log_result("GET /Auth/me", False, str(e))

print(f"\n{C.Y}[1.5] POST /Auth/logout{C.E}")
try:
    r = requests.post(f"{BASE_URL}/Auth/logout", headers=headers, timeout=5, verify=False)
    log_result("POST /Auth/logout", r.status_code == 200, f"Status {r.status_code}")
except Exception as e:
    log_result("POST /Auth/logout", False, str(e))

print(f"\n{C.Y}[1.6] Re-login{C.E}")
try:
    r = requests.post(f"{BASE_URL}/Auth/login", json={"Usuario": "admin", "Contrasena": "changeme"}, timeout=5, verify=False)
    if r.status_code == 200:
        JWT_TOKEN = r.json().get("data", {}).get("token", "")
        headers["Authorization"] = f"Bearer {JWT_TOKEN}"
        log_result("Re-login", True, f"Status {r.status_code}")
    else:
        log_result("Re-login", False, f"Status {r.status_code}")
except Exception as e:
    log_result("Re-login", False, str(e))

print(f"\n{C.C}=== FASE 2: REFERENCIAS ==={C.E}\n")

print(f"{C.Y}[2.1] GET /References/estados{C.E}")
try:
    r = requests.get(f"{BASE_URL}/References/estados", verify=False)
    if r.status_code == 200:
        count = len(r.json().get("data", []))
        log_result("GET /References/estados", True, f"Status 200, {count} items")
    else:
        log_result("GET /References/estados", False, f"Status {r.status_code}")
except Exception as e:
    log_result("GET /References/estados", False, str(e))

print(f"\n{C.Y}[2.2] GET /References/prioridades{C.E}")
try:
    r = requests.get(f"{BASE_URL}/References/prioridades", verify=False)
    if r.status_code == 200:
        count = len(r.json().get("data", []))
        log_result("GET /References/prioridades", True, f"Status 200, {count} items")
    else:
        log_result("GET /References/prioridades", False, f"Status {r.status_code}")
except Exception as e:
    log_result("GET /References/prioridades", False, str(e))

print(f"\n{C.Y}[2.3] GET /References/departamentos{C.E}")
try:
    r = requests.get(f"{BASE_URL}/References/departamentos", verify=False)
    if r.status_code == 200:
        count = len(r.json().get("data", []))
        log_result("GET /References/departamentos", True, f"Status 200, {count} items")
    else:
        log_result("GET /References/departamentos", False, f"Status {r.status_code}")
except Exception as e:
    log_result("GET /References/departamentos", False, str(e))

print(f"\n{C.C}=== FASE 3: TICKETS CRUD ==={C.E}\n")

ticket_id = 0

print(f"{C.Y}[3.1] GET /Tickets{C.E}")
try:
    r = requests.get(f"{BASE_URL}/Tickets", headers=headers, verify=False)
    if r.status_code == 200:
        count = len(r.json().get("data", []))
        log_result("GET /Tickets", True, f"Status 200, {count} items")
    else:
        log_result("GET /Tickets", False, f"Status {r.status_code}")
except Exception as e:
    log_result("GET /Tickets", False, str(e))

print(f"\n{C.Y}[3.2] POST /Tickets{C.E}")
try:
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    ticket = {"Titulo": f"TEST {ts}", "Descripcion": "Test ticket", "Id_Prioridad": 2, "Id_Departamento": 1, "Id_Usuario_Reportador": 1}
    r = requests.post(f"{BASE_URL}/Tickets", json=ticket, headers=headers, verify=False)
    if r.status_code == 201:
        ticket_id = r.json().get("data", {}).get("id", 0)
        log_result("POST /Tickets", True, f"Status 201, ID: {ticket_id}")
    else:
        log_result("POST /Tickets", False, f"Status {r.status_code}")
except Exception as e:
    log_result("POST /Tickets", False, str(e))

if ticket_id > 0:
    print(f"\n{C.Y}[3.3] GET /Tickets/{ticket_id}{C.E}")
    try:
        r = requests.get(f"{BASE_URL}/Tickets/{ticket_id}", headers=headers, verify=False)
        log_result(f"GET /Tickets/{ticket_id}", r.status_code == 200, f"Status {r.status_code}")
    except Exception as e:
        log_result(f"GET /Tickets/{ticket_id}", False, str(e))

    print(f"\n{C.Y}[3.4] PUT /Tickets/{ticket_id}{C.E}")
    try:
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        ticket = {"Titulo": f"UPDATED {ts}", "Descripcion": "Updated", "Id_Prioridad": 3, "Id_Departamento": 1}
        r = requests.put(f"{BASE_URL}/Tickets/{ticket_id}", json=ticket, headers=headers, verify=False)
        log_result(f"PUT /Tickets/{ticket_id}", r.status_code == 200, f"Status {r.status_code}")
    except Exception as e:
        log_result(f"PUT /Tickets/{ticket_id}", False, str(e))

print(f"\n{C.C}=== FASE 4: TRANSICIONES ==={C.E}\n")

if ticket_id > 0:
    print(f"{C.Y}[4.1] GET /Tickets/{ticket_id}/transiciones-permitidas{C.E}")
    try:
        r = requests.get(f"{BASE_URL}/Tickets/{ticket_id}/transiciones-permitidas", headers=headers, verify=False)
        if r.status_code == 200:
            count = len(r.json().get("data", []))
            log_result("GET /transiciones-permitidas", True, f"Status 200, {count} items")
        else:
            log_result("GET /transiciones-permitidas", False, f"Status {r.status_code}")
    except Exception as e:
        log_result("GET /transiciones-permitidas", False, str(e))

    print(f"\n{C.Y}[4.2] PATCH /Tickets/{ticket_id}/cambiar-estado{C.E}")
    try:
        r = requests.patch(f"{BASE_URL}/Tickets/{ticket_id}/cambiar-estado", json={"Id_Estado_Nuevo": 2, "Comentario": "Test"}, headers=headers, verify=False)
        log_result("PATCH /cambiar-estado", r.status_code == 200, f"Status {r.status_code}")
    except Exception as e:
        log_result("PATCH /cambiar-estado", False, str(e))

    print(f"\n{C.Y}[4.3] GET /Tickets/{ticket_id}/historial{C.E}")
    try:
        r = requests.get(f"{BASE_URL}/Tickets/{ticket_id}/historial", headers=headers, verify=False)
        if r.status_code == 200:
            count = len(r.json().get("data", []))
            log_result("GET /historial", True, f"Status 200, {count} items")
        else:
            log_result("GET /historial", False, f"Status {r.status_code}")
    except Exception as e:
        log_result("GET /historial", False, str(e))

print(f"\n{C.C}=== FASE 5: COMENTARIOS ==={C.E}\n")

comment_id = 0

if ticket_id > 0:
    print(f"{C.Y}[5.1] POST /Tickets/{ticket_id}/Comments{C.E}")
    try:
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        r = requests.post(f"{BASE_URL}/Tickets/{ticket_id}/Comments", json={"Contenido": f"Comment {ts}", "Tipo_Comentario": "Observacion"}, headers=headers, verify=False)
        if r.status_code == 201:
            comment_id = r.json().get("data", {}).get("id", 0)
            log_result("POST /Comments", True, f"Status 201, ID: {comment_id}")
        else:
            log_result("POST /Comments", False, f"Status {r.status_code}")
    except Exception as e:
        log_result("POST /Comments", False, str(e))

    print(f"\n{C.Y}[5.2] GET /Tickets/{ticket_id}/Comments{C.E}")
    try:
        r = requests.get(f"{BASE_URL}/Tickets/{ticket_id}/Comments", headers=headers, verify=False)
        if r.status_code == 200:
            count = len(r.json().get("data", []))
            log_result("GET /Comments", True, f"Status 200, {count} items")
        else:
            log_result("GET /Comments", False, f"Status {r.status_code}")
    except Exception as e:
        log_result("GET /Comments", False, str(e))

    if comment_id > 0:
        print(f"\n{C.Y}[5.3] PUT /Comments/{comment_id}{C.E}")
        try:
            ts = datetime.now().strftime("%Y%m%d_%H%M%S")
            r = requests.put(f"{BASE_URL}/Comments/{comment_id}", json={"Contenido": f"Updated {ts}", "Tipo_Comentario": "Observacion"}, headers=headers, verify=False)
            log_result(f"PUT /Comments/{comment_id}", r.status_code == 200, f"Status {r.status_code}")
        except Exception as e:
            log_result(f"PUT /Comments/{comment_id}", False, str(e))

        print(f"\n{C.Y}[5.4] DELETE /Comments/{comment_id}{C.E}")
        try:
            r = requests.delete(f"{BASE_URL}/Comments/{comment_id}", headers=headers, verify=False)
            log_result(f"DELETE /Comments/{comment_id}", r.status_code == 204, f"Status {r.status_code}")
        except Exception as e:
            log_result(f"DELETE /Comments/{comment_id}", False, str(e))

print(f"\n{C.C}=== FASE 6: CRUD GENERALES ==={C.E}\n")

print(f"{C.Y}[6.1] GET /Departamentos{C.E}")
try:
    r = requests.get(f"{BASE_URL}/Departamentos", headers=headers, verify=False)
    if r.status_code == 200:
        count = len(r.json().get("data", []))
        log_result("GET /Departamentos", True, f"Status 200, {count} items")
    else:
        log_result("GET /Departamentos", False, f"Status {r.status_code}")
except Exception as e:
    log_result("GET /Departamentos", False, str(e))

print(f"\n{C.Y}[6.2] GET /Motivos{C.E}")
try:
    r = requests.get(f"{BASE_URL}/Motivos", headers=headers, verify=False)
    if r.status_code == 200:
        count = len(r.json().get("data", []))
        log_result("GET /Motivos", True, f"Status 200, {count} items")
    else:
        log_result("GET /Motivos", False, f"Status {r.status_code}")
except Exception as e:
    log_result("GET /Motivos", False, str(e))

print(f"\n{C.Y}[6.3] GET /Grupos{C.E}")
try:
    r = requests.get(f"{BASE_URL}/Grupos", headers=headers, verify=False)
    if r.status_code == 200:
        count = len(r.json().get("data", []))
        log_result("GET /Grupos", True, f"Status 200, {count} items")
    else:
        log_result("GET /Grupos", False, f"Status {r.status_code}")
except Exception as e:
    log_result("GET /Grupos", False, str(e))

print(f"\n{C.C}=== REPORTE ==={C.E}\n")

passed = sum(1 for r in TEST_RESULTS if r["passed"])
failed = sum(1 for r in TEST_RESULTS if not r["passed"])
total = len(TEST_RESULTS)

print(f"  Total: {total}")
print(f"  {C.G}PASS: {passed}{C.E}")
print(f"  {C.R}FAIL: {failed}{C.E}")
if total > 0:
    pct = (passed / total) * 100
    print(f"  {C.C}Exito: {pct:.1f}%{C.E}")

if failed > 0:
    print(f"\n{C.R}FALLIDOS:{C.E}")
    for r in TEST_RESULTS:
        if not r["passed"]:
            print(f"  [FAIL] {r['test']}")

with open("QA_TEST_REPORT.json", "w") as f:
    json.dump({"total": total, "passed": passed, "failed": failed, "success_rate": (passed/total*100) if total > 0 else 0, "timestamp": datetime.now().isoformat(), "tests": TEST_RESULTS}, f, indent=2)

print(f"\n{C.C}Reporte guardado en: QA_TEST_REPORT.json{C.E}\n")
