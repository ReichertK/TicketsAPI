#!/usr/bin/env python3
import requests, json
from datetime import datetime
import urllib3
urllib3.disable_warnings()

BASE_URL = "https://localhost:5001/api/v1"
TEST_RESULTS = []
JWT_TOKEN = ""

def log_result(test_name, passed, msg):
    status = "[PASS]" if passed else "[FAIL]"
    color = '\033[92m' if passed else '\033[91m'
    print(f"{color}{status}\033[0m {test_name}\n  -> {msg}")
    TEST_RESULTS.append({"test": test_name, "passed": passed, "msg": msg})

print(f"\n\033[96m=== FASE 1: AUTENTICACION ===\033[0m\n")

print(f"\033[93m[1.1] POST /Auth/login\033[0m")
try:
    r = requests.post(f"{BASE_URL}/Auth/login", json={"Usuario": "admin", "Contraseña": "changeme"}, timeout=5, verify=False)
    if r.status_code == 200:
        data = r.json()
        JWT_TOKEN = data.get("datos", {}).get("token", "")
        if JWT_TOKEN:
            log_result("Login", True, f"Status {r.status_code}, token obtenido")
        else:
            log_result("Login", False, "Sin token en respuesta")
    else:
        log_result("Login", False, f"Status {r.status_code}: {r.text[:50]}")
except Exception as e:
    log_result("Login", False, str(e)[:50])

if not JWT_TOKEN:
    print(f"\n\033[91mERROR: Sin JWT token\033[0m\n")
    exit(1)

headers = {"Authorization": f"Bearer {JWT_TOKEN}"}

print(f"\n\033[96m=== FASE 2: REFERENCIAS ===\033[0m\n")

print(f"\033[93m[2.1] GET /References/estados\033[0m")
try:
    r = requests.get(f"{BASE_URL}/References/estados", verify=False)
    if r.status_code == 200:
        count = len(r.json().get("datos", []))
        log_result("GET /estados", True, f"Status 200, {count} items")
    else:
        log_result("GET /estados", False, f"Status {r.status_code}")
except Exception as e:
    log_result("GET /estados", False, str(e)[:50])

print(f"\n\033[93m[2.2] GET /References/prioridades\033[0m")
try:
    r = requests.get(f"{BASE_URL}/References/prioridades", verify=False)
    if r.status_code == 200:
        count = len(r.json().get("datos", []))
        log_result("GET /prioridades", True, f"Status 200, {count} items")
    else:
        log_result("GET /prioridades", False, f"Status {r.status_code}")
except Exception as e:
    log_result("GET /prioridades", False, str(e)[:50])

print(f"\n\033[93m[2.3] GET /References/departamentos\033[0m")
try:
    r = requests.get(f"{BASE_URL}/References/departamentos", verify=False)
    if r.status_code == 200:
        count = len(r.json().get("datos", []))
        log_result("GET /departamentos", True, f"Status 200, {count} items")
    else:
        log_result("GET /departamentos", False, f"Status {r.status_code}")
except Exception as e:
    log_result("GET /departamentos", False, str(e)[:50])

print(f"\n\033[96m=== FASE 3: TICKETS ===\033[0m\n")

ticket_id = 0

print(f"\033[93m[3.1] GET /Tickets\033[0m")
try:
    r = requests.get(f"{BASE_URL}/Tickets", headers=headers, verify=False)
    if r.status_code == 200:
        count = len(r.json().get("datos", []))
        log_result("GET /Tickets", True, f"Status 200, {count} items")
    else:
        log_result("GET /Tickets", False, f"Status {r.status_code}")
except Exception as e:
    log_result("GET /Tickets", False, str(e)[:50])

print(f"\n\033[93m[3.2] POST /Tickets\033[0m")
try:
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    ticket = {"Titulo": f"TEST {ts}", "Descripcion": "Test", "Id_Prioridad": 2, "Id_Departamento": 1, "Id_Usuario_Reportador": 1}
    r = requests.post(f"{BASE_URL}/Tickets", json=ticket, headers=headers, verify=False)
    if r.status_code == 201:
        ticket_id = r.json().get("datos", {}).get("id", 0)
        log_result("POST /Tickets", True, f"Status 201, ID: {ticket_id}")
    else:
        log_result("POST /Tickets", False, f"Status {r.status_code}")
except Exception as e:
    log_result("POST /Tickets", False, str(e)[:50])

if ticket_id > 0:
    print(f"\n\033[93m[3.3] GET /Tickets/{ticket_id}\033[0m")
    try:
        r = requests.get(f"{BASE_URL}/Tickets/{ticket_id}", headers=headers, verify=False)
        log_result(f"GET /Tickets/{ticket_id}", r.status_code == 200, f"Status {r.status_code}")
    except Exception as e:
        log_result(f"GET /Tickets/{ticket_id}", False, str(e)[:50])

    print(f"\n\033[93m[3.4] PUT /Tickets/{ticket_id}\033[0m")
    try:
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        ticket = {"Titulo": f"UPD {ts}", "Descripcion": "Updated", "Id_Prioridad": 3, "Id_Departamento": 1}
        r = requests.put(f"{BASE_URL}/Tickets/{ticket_id}", json=ticket, headers=headers, verify=False)
        log_result(f"PUT /Tickets/{ticket_id}", r.status_code == 200, f"Status {r.status_code}")
    except Exception as e:
        log_result(f"PUT /Tickets/{ticket_id}", False, str(e)[:50])

print(f"\n\033[96m=== FASE 4: TRANSICIONES ===\033[0m\n")

if ticket_id > 0:
    print(f"\033[93m[4.1] GET /transiciones-permitidas\033[0m")
    try:
        r = requests.get(f"{BASE_URL}/Tickets/{ticket_id}/transiciones-permitidas", headers=headers, verify=False)
        if r.status_code == 200:
            count = len(r.json().get("datos", []))
            log_result("GET /transiciones", True, f"Status 200, {count} items")
        else:
            log_result("GET /transiciones", False, f"Status {r.status_code}")
    except Exception as e:
        log_result("GET /transiciones", False, str(e)[:50])

    print(f"\n\033[93m[4.2] PATCH /cambiar-estado\033[0m")
    try:
        r = requests.patch(f"{BASE_URL}/Tickets/{ticket_id}/cambiar-estado", json={"Id_Estado_Nuevo": 2, "Comentario": "Test"}, headers=headers, verify=False)
        log_result("PATCH /cambiar-estado", r.status_code == 200, f"Status {r.status_code}")
    except Exception as e:
        log_result("PATCH /cambiar-estado", False, str(e)[:50])

    print(f"\n\033[93m[4.3] GET /historial\033[0m")
    try:
        r = requests.get(f"{BASE_URL}/Tickets/{ticket_id}/historial", headers=headers, verify=False)
        if r.status_code == 200:
            count = len(r.json().get("datos", []))
            log_result("GET /historial", True, f"Status 200, {count} items")
        else:
            log_result("GET /historial", False, f"Status {r.status_code}")
    except Exception as e:
        log_result("GET /historial", False, str(e)[:50])

print(f"\n\033[96m=== FASE 5: COMENTARIOS ===\033[0m\n")

comment_id = 0

if ticket_id > 0:
    print(f"\033[93m[5.1] POST /Comments\033[0m")
    try:
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        r = requests.post(f"{BASE_URL}/Tickets/{ticket_id}/Comments", json={"Contenido": f"C {ts}", "Tipo_Comentario": "O"}, headers=headers, verify=False)
        if r.status_code == 201:
            comment_id = r.json().get("datos", {}).get("id", 0)
            log_result("POST /Comments", True, f"Status 201, ID: {comment_id}")
        else:
            log_result("POST /Comments", False, f"Status {r.status_code}")
    except Exception as e:
        log_result("POST /Comments", False, str(e)[:50])

    print(f"\n\033[93m[5.2] GET /Comments\033[0m")
    try:
        r = requests.get(f"{BASE_URL}/Tickets/{ticket_id}/Comments", headers=headers, verify=False)
        if r.status_code == 200:
            count = len(r.json().get("datos", []))
            log_result("GET /Comments", True, f"Status 200, {count} items")
        else:
            log_result("GET /Comments", False, f"Status {r.status_code}")
    except Exception as e:
        log_result("GET /Comments", False, str(e)[:50])

    if comment_id > 0:
        print(f"\n\033[93m[5.3] PUT /Comments\033[0m")
        try:
            ts = datetime.now().strftime("%Y%m%d_%H%M%S")
            r = requests.put(f"{BASE_URL}/Comments/{comment_id}", json={"Contenido": f"U {ts}", "Tipo_Comentario": "O"}, headers=headers, verify=False)
            log_result(f"PUT /Comments", r.status_code == 200, f"Status {r.status_code}")
        except Exception as e:
            log_result(f"PUT /Comments", False, str(e)[:50])

        print(f"\n\033[93m[5.4] DELETE /Comments\033[0m")
        try:
            r = requests.delete(f"{BASE_URL}/Comments/{comment_id}", headers=headers, verify=False)
            log_result(f"DELETE /Comments", r.status_code == 204, f"Status {r.status_code}")
        except Exception as e:
            log_result(f"DELETE /Comments", False, str(e)[:50])

print(f"\n\033[96m=== FASE 6: CRUD ===\033[0m\n")

print(f"\033[93m[6.1] GET /Departamentos\033[0m")
try:
    r = requests.get(f"{BASE_URL}/Departamentos", headers=headers, verify=False)
    if r.status_code == 200:
        count = len(r.json().get("datos", []))
        log_result("GET /Departamentos", True, f"Status 200, {count} items")
    else:
        log_result("GET /Departamentos", False, f"Status {r.status_code}")
except Exception as e:
    log_result("GET /Departamentos", False, str(e)[:50])

print(f"\n\033[93m[6.2] GET /Motivos\033[0m")
try:
    r = requests.get(f"{BASE_URL}/Motivos", headers=headers, verify=False)
    if r.status_code == 200:
        count = len(r.json().get("datos", []))
        log_result("GET /Motivos", True, f"Status 200, {count} items")
    else:
        log_result("GET /Motivos", False, f"Status {r.status_code}")
except Exception as e:
    log_result("GET /Motivos", False, str(e)[:50])

print(f"\n\033[93m[6.3] GET /Grupos\033[0m")
try:
    r = requests.get(f"{BASE_URL}/Grupos", headers=headers, verify=False)
    if r.status_code == 200:
        count = len(r.json().get("datos", []))
        log_result("GET /Grupos", True, f"Status 200, {count} items")
    else:
        log_result("GET /Grupos", False, f"Status {r.status_code}")
except Exception as e:
    log_result("GET /Grupos", False, str(e)[:50])

passed = sum(1 for r in TEST_RESULTS if r["passed"])
failed = sum(1 for r in TEST_RESULTS if not r["passed"])
total = len(TEST_RESULTS)

print(f"\n\033[96m=== REPORTE ===\033[0m\n")
print(f"Total: {total}")
print(f"\033[92mPASS: {passed}\033[0m")
print(f"\033[91mFAIL: {failed}\033[0m")
if total > 0:
    pct = (passed / total) * 100
    print(f"\033[96mExito: {pct:.1f}%\033[0m")

if failed > 0:
    print(f"\n\033[91mFALLIDOS:\033[0m")
    for r in TEST_RESULTS:
        if not r["passed"]:
            print(f"  [FAIL] {r['test']}")

with open("QA_TEST_REPORT.json", "w") as f:
    json.dump({"total": total, "passed": passed, "failed": failed, "success_rate": (passed/total*100) if total > 0 else 0, "timestamp": datetime.now().isoformat(), "tests": TEST_RESULTS}, f, indent=2)

print(f"\nReporte: QA_TEST_REPORT.json\n")
