#!/usr/bin/env python3
"""
Suite de Pruebas QA Profesional para TicketsAPI
Pruebas completas: Auth, Tickets, Grupos, Comentarios, Transiciones, Admin
Fecha: Diciembre 2025
"""

import requests
import json
import urllib3
from datetime import datetime
from typing import Dict, Any, List, Tuple
import time
import concurrent.futures

# Deshabilitar warnings de SSL para certificados autofirmados
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# ==================== CONFIGURACIÓN ====================
BASE_URL = "https://localhost:5001/api/v1"
VERIFY_SSL = False
HEADERS = {"Content-Type": "application/json"}

# Test Users
TEST_USERS = {
    "admin": {"Usuario": "admin", "Contraseña": "changeme"},
}

# Colores para output
class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    RESET = '\033[0m'
    BOLD = '\033[1m'

# ==================== UTILIDADES ====================
def log_test(name: str, status: str, message: str = ""):
    """Registrar resultado de prueba"""
    if status == "PASS":
        print(f"{Colors.GREEN}[PASS]{Colors.RESET}: {name}")
    elif status == "FAIL":
        print(f"{Colors.RED}[FAIL]{Colors.RESET}: {name} - {message}")
    elif status == "INFO":
        print(f"{Colors.BLUE}[INFO]{Colors.RESET}: {name}")
    else:
        print(f"{Colors.YELLOW}[SKIP]{Colors.RESET}: {name} - {message}")

def make_request(method: str, endpoint: str, headers: Dict = None, json_data: Dict = None, 
                 expected_status: int = None) -> Tuple[int, Any, bool]:
    """Hacer request HTTP y retornar (status, data, success)"""
    try:
        url = f"{BASE_URL}{endpoint}"
        if headers is None:
            headers = HEADERS.copy()
        
        if method == "GET":
            resp = requests.get(url, headers=headers, verify=VERIFY_SSL)
        elif method == "POST":
            resp = requests.post(url, headers=headers, json=json_data, verify=VERIFY_SSL)
        elif method == "PUT":
            resp = requests.put(url, headers=headers, json=json_data, verify=VERIFY_SSL)
        elif method == "DELETE":
            resp = requests.delete(url, headers=headers, verify=VERIFY_SSL)
        
        try:
            data = resp.json()
        except:
            data = resp.text
        
        success = expected_status is None or resp.status_code == expected_status
        return resp.status_code, data, success
    except Exception as e:
        return -1, str(e), False

# ==================== FASE 1: AUTENTICACIÓN ====================
def test_authentication() -> Tuple[bool, Dict]:
    """Pruebas de autenticación JWT"""
    print(f"\n{Colors.BOLD}{'='*60}{Colors.RESET}")
    print(f"{Colors.BOLD}FASE 1: AUTENTICACIÓN Y TOKENS{Colors.RESET}")
    print(f"{Colors.BOLD}{'='*60}{Colors.RESET}\n")
    
    results = {"passed": 0, "failed": 0, "token": None}
    
    # Test 1.1: Login exitoso
    status, data, success = make_request(
        "POST", "/Auth/Login",
        json_data=TEST_USERS["admin"],
        expected_status=200
    )
    
    if success and isinstance(data, dict) and "datos" in data and "token" in data["datos"]:
        log_test("Login con credenciales válidas", "PASS")
        results["passed"] += 1
        results["token"] = data["datos"]["token"]
    else:
        log_test("Login con credenciales válidas", "FAIL", f"Status: {status}")
        results["failed"] += 1
    
    # Test 1.2: Login fallido
    status, data, success = make_request(
        "POST", "/Auth/Login",
        json_data={"Usuario": "admin", "Contraseña": "wrongpass"},
        expected_status=401
    )
    
    if status == 401:
        log_test("Login rechazado con credenciales inválidas", "PASS")
        results["passed"] += 1
    else:
        log_test("Login rechazado con credenciales inválidas", "FAIL", f"Status: {status}")
        results["failed"] += 1
    
    # Test 1.3: Refresh token
    if results["token"]:
        auth_header = HEADERS.copy()
        auth_header["Authorization"] = f"Bearer {results['token']}"
        status, data, success = make_request(
            "POST", "/Auth/RefreshToken",
            headers=auth_header,
            expected_status=200
        )
        
        if success and isinstance(data, dict) and "datos" in data and "token" in data["datos"]:
            log_test("Refresh token válido", "PASS")
            results["passed"] += 1
            results["token"] = data["datos"]["token"]  # Actualizar token
        else:
            log_test("Refresh token válido", "FAIL", f"Status: {status}")
            results["failed"] += 1
    
    return results["failed"] == 0, results

# ==================== FASE 2: REFERENCIAS ====================
def test_references(token: str) -> Tuple[bool, Dict]:
    """Pruebas de endpoints de referencias (estados, prioridades, etc)"""
    print(f"\n{Colors.BOLD}{'='*60}{Colors.RESET}")
    print(f"{Colors.BOLD}FASE 2: REFERENCIAS (ESTADOS, PRIORIDADES, TIPOS){Colors.RESET}")
    print(f"{Colors.BOLD}{'='*60}{Colors.RESET}\n")
    
    results = {"passed": 0, "failed": 0}
    auth_header = HEADERS.copy()
    auth_header["Authorization"] = f"Bearer {token}"
    
    reference_endpoints = [
        ("/References/Estados", "Estados"),
        ("/References/Prioridades", "Prioridades"),
        ("/References/Tipos", "Tipos de Tickets"),
    ]
    
    for endpoint, name in reference_endpoints:
        status, data, success = make_request(
            "GET", endpoint,
            headers=auth_header,
            expected_status=200
        )
        
        if success and isinstance(data, list) and len(data) > 0:
            log_test(f"GET {name}", "PASS", f"({len(data)} items)")
            results["passed"] += 1
        else:
            log_test(f"GET {name}", "FAIL", f"Status: {status}, Data: {str(data)[:50]}")
            results["failed"] += 1
    
    return results["failed"] == 0, results

# ==================== FASE 3: TICKETS CRUD ====================
def test_tickets_crud(token: str) -> Tuple[bool, Dict]:
    """Pruebas CRUD de tickets"""
    print(f"\n{Colors.BOLD}{'='*60}{Colors.RESET}")
    print(f"{Colors.BOLD}FASE 3: TICKETS - CRUD OPERATIONS{Colors.RESET}")
    print(f"{Colors.BOLD}{'='*60}{Colors.RESET}\n")
    
    results = {"passed": 0, "failed": 0, "ticket_id": None}
    auth_header = HEADERS.copy()
    auth_header["Authorization"] = f"Bearer {token}"
    
    # Test 3.1: GET todos los tickets
    status, data, success = make_request(
        "GET", "/Tickets",
        headers=auth_header,
        expected_status=200
    )
    
    if success and isinstance(data, list):
        log_test("GET /Tickets (listar)", "PASS", f"({len(data)} tickets)")
        results["passed"] += 1
        if len(data) > 0:
            results["ticket_id"] = data[0].get("Id_Ticket")
    else:
        log_test("GET /Tickets (listar)", "FAIL", f"Status: {status}")
        results["failed"] += 1
    
    # Test 3.2: POST crear ticket
    new_ticket = {
        "Contenido": "Ticket de prueba QA - " + datetime.now().isoformat(),
        "Id_Tipo_Ticket": 1,
        "Id_Prioridad": 1,
        "Id_Departamento": 1
    }
    
    status, data, success = make_request(
        "POST", "/Tickets",
        headers=auth_header,
        json_data=new_ticket,
        expected_status=201
    )
    
    if success and isinstance(data, dict) and "id_ticket" in data:
        log_test("POST /Tickets (crear)", "PASS")
        results["passed"] += 1
        results["ticket_id"] = data.get("id_ticket")
    else:
        log_test("POST /Tickets (crear)", "FAIL", f"Status: {status}")
        results["failed"] += 1
    
    # Test 3.3: GET ticket específico
    if results["ticket_id"]:
        status, data, success = make_request(
            "GET", f"/Tickets/{results['ticket_id']}",
            headers=auth_header,
            expected_status=200
        )
        
        if success and isinstance(data, dict):
            log_test(f"GET /Tickets/{results['ticket_id']} (obtener)", "PASS")
            results["passed"] += 1
        else:
            log_test(f"GET /Tickets/{results['ticket_id']} (obtener)", "FAIL", f"Status: {status}")
            results["failed"] += 1
    
    return results["failed"] == 0, results

# ==================== FASE 4: GRUPOS ====================
def test_grupos(token: str) -> Tuple[bool, Dict]:
    """Pruebas de endpoints de Grupos"""
    print(f"\n{Colors.BOLD}{'='*60}{Colors.RESET}")
    print(f"{Colors.BOLD}FASE 4: GRUPOS (EQUIPOS){Colors.RESET}")
    print(f"{Colors.BOLD}{'='*60}{Colors.RESET}\n")
    
    results = {"passed": 0, "failed": 0}
    auth_header = HEADERS.copy()
    auth_header["Authorization"] = f"Bearer {token}"
    
    # Test 4.1: GET todos los grupos
    status, data, success = make_request(
        "GET", "/Grupos",
        headers=auth_header,
        expected_status=200
    )
    
    if success and isinstance(data, list):
        log_test("GET /Grupos (listar)", "PASS", f"({len(data)} grupos)")
        results["passed"] += 1
    else:
        log_test("GET /Grupos (listar)", "FAIL", f"Status: {status}")
        results["failed"] += 1
    
    return results["failed"] == 0, results

# ==================== FASE 5: DEPARTAMENTOS ====================
def test_departamentos(token: str) -> Tuple[bool, Dict]:
    """Pruebas de endpoints de Departamentos"""
    print(f"\n{Colors.BOLD}{'='*60}{Colors.RESET}")
    print(f"{Colors.BOLD}FASE 5: DEPARTAMENTOS{Colors.RESET}")
    print(f"{Colors.BOLD}{'='*60}{Colors.RESET}\n")
    
    results = {"passed": 0, "failed": 0}
    auth_header = HEADERS.copy()
    auth_header["Authorization"] = f"Bearer {token}"
    
    status, data, success = make_request(
        "GET", "/Departamentos",
        headers=auth_header,
        expected_status=200
    )
    
    if success and isinstance(data, list):
        log_test("GET /Departamentos (listar)", "PASS", f"({len(data)} depts)")
        results["passed"] += 1
    else:
        log_test("GET /Departamentos (listar)", "FAIL", f"Status: {status}")
        results["failed"] += 1
    
    return results["failed"] == 0, results

# ==================== FASE 6: MOTIVOS ====================
def test_motivos(token: str) -> Tuple[bool, Dict]:
    """Pruebas de endpoints de Motivos"""
    print(f"\n{Colors.BOLD}{'='*60}{Colors.RESET}")
    print(f"{Colors.BOLD}FASE 6: MOTIVOS{Colors.RESET}")
    print(f"{Colors.BOLD}{'='*60}{Colors.RESET}\n")
    
    results = {"passed": 0, "failed": 0}
    auth_header = HEADERS.copy()
    auth_header["Authorization"] = f"Bearer {token}"
    
    status, data, success = make_request(
        "GET", "/Motivos",
        headers=auth_header,
        expected_status=200
    )
    
    if success and isinstance(data, list):
        log_test("GET /Motivos (listar)", "PASS", f"({len(data)} motivos)")
        results["passed"] += 1
    else:
        log_test("GET /Motivos (listar)", "FAIL", f"Status: {status}")
        results["failed"] += 1
    
    return results["failed"] == 0, results

# ==================== PRUEBAS DE CARGA ====================
def performance_test(token: str, endpoint: str, num_requests: int = 10):
    """Prueba de carga - múltiples requests concurrentes"""
    auth_header = HEADERS.copy()
    auth_header["Authorization"] = f"Bearer {token}"
    
    print(f"\n{Colors.BOLD}{'='*60}{Colors.RESET}")
    print(f"{Colors.BOLD}PRUEBA DE CARGA: {endpoint}{Colors.RESET}")
    print(f"{Colors.BOLD}Requests: {num_requests}{Colors.RESET}")
    print(f"{Colors.BOLD}{'='*60}{Colors.RESET}\n")
    
    times = []
    errors = 0
    
    def single_request():
        start = time.time()
        try:
            resp = requests.get(
                f"{BASE_URL}{endpoint}",
                headers=auth_header,
                verify=VERIFY_SSL,
                timeout=10
            )
            elapsed = time.time() - start
            return elapsed, resp.status_code == 200
        except:
            return -1, False
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
        futures = [executor.submit(single_request) for _ in range(num_requests)]
        for future in concurrent.futures.as_completed(futures):
            elapsed, success = future.result()
            if elapsed > 0:
                times.append(elapsed)
                if not success:
                    errors += 1
    
    if times:
        avg_time = sum(times) / len(times)
        min_time = min(times)
        max_time = max(times)
        throughput = len(times) / sum(times)
        
        print(f"  {Colors.GREEN}Total requests:{Colors.RESET} {len(times)}/{num_requests}")
        print(f"  {Colors.GREEN}Successful:{Colors.RESET} {len(times) - errors}")
        print(f"  {Colors.GREEN}Failed:{Colors.RESET} {errors}")
        print(f"  {Colors.GREEN}Avg latency:{Colors.RESET} {avg_time*1000:.2f}ms")
        print(f"  {Colors.GREEN}Min latency:{Colors.RESET} {min_time*1000:.2f}ms")
        print(f"  {Colors.GREEN}Max latency:{Colors.RESET} {max_time*1000:.2f}ms")
        print(f"  {Colors.GREEN}Throughput:{Colors.RESET} {throughput:.2f} req/s")

# ==================== PRUEBAS DE PERMISOS ====================
def test_permissions(token: str) -> Tuple[bool, Dict]:
    """Pruebas de permisos y autorización"""
    print(f"\n{Colors.BOLD}{'='*60}{Colors.RESET}")
    print(f"{Colors.BOLD}PRUEBAS DE PERMISOS Y AUTORIZACIÓN{Colors.RESET}")
    print(f"{Colors.BOLD}{'='*60}{Colors.RESET}\n")
    
    results = {"passed": 0, "failed": 0}
    auth_header = HEADERS.copy()
    
    # Test sin token
    status, _, _ = make_request(
        "GET", "/Tickets",
        headers=HEADERS,
        expected_status=401
    )
    
    if status == 401:
        log_test("Request sin token retorna 401", "PASS")
        results["passed"] += 1
    else:
        log_test("Request sin token retorna 401", "FAIL", f"Status: {status}")
        results["failed"] += 1
    
    # Test con token válido
    auth_header["Authorization"] = f"Bearer {token}"
    status, _, _ = make_request(
        "GET", "/Tickets",
        headers=auth_header,
        expected_status=200
    )
    
    if status == 200:
        log_test("Request con token válido retorna 200", "PASS")
        results["passed"] += 1
    else:
        log_test("Request con token válido retorna 200", "FAIL", f"Status: {status}")
        results["failed"] += 1
    
    # Test con token inválido
    bad_header = HEADERS.copy()
    bad_header["Authorization"] = "Bearer invalid_token_here"
    status, _, _ = make_request(
        "GET", "/Tickets",
        headers=bad_header,
        expected_status=401
    )
    
    if status == 401:
        log_test("Token inválido retorna 401", "PASS")
        results["passed"] += 1
    else:
        log_test("Token inválido retorna 401", "FAIL", f"Status: {status}")
        results["failed"] += 1
    
    return results["failed"] == 0, results

# ==================== RESUMEN ====================
def generate_summary(all_results: List[Dict]):
    """Generar resumen de pruebas"""
    total_passed = sum(r.get("passed", 0) for r in all_results)
    total_failed = sum(r.get("failed", 0) for r in all_results)
    total = total_passed + total_failed
    percentage = (total_passed / total * 100) if total > 0 else 0
    
    print(f"\n{Colors.BOLD}{'='*60}{Colors.RESET}")
    print(f"{Colors.BOLD}RESUMEN FINAL DE PRUEBAS{Colors.RESET}")
    print(f"{Colors.BOLD}{'='*60}{Colors.RESET}\n")
    
    print(f"  Total de pruebas: {total}")
    if percentage >= 80:
        print(f"  {Colors.GREEN}Exitosas: {total_passed} ({percentage:.1f}%){Colors.RESET}")
    else:
        print(f"  {Colors.RED}Exitosas: {total_passed} ({percentage:.1f}%){Colors.RESET}")
    print(f"  Fallidas: {total_failed}")
    
    if total_failed == 0:
        print(f"\n{Colors.GREEN}{Colors.BOLD}[SUCCESS] TODAS LAS PRUEBAS PASARON!{Colors.RESET}")
    else:
        print(f"\n{Colors.RED}{Colors.BOLD}[ERROR] ALGUNAS PRUEBAS FALLARON{Colors.RESET}")
    
    return {
        "total": total,
        "passed": total_passed,
        "failed": total_failed,
        "percentage": percentage,
        "timestamp": datetime.now().isoformat()
    }

# ==================== MAIN ====================
def main():
    """Ejecutar todas las pruebas"""
    print(f"\n{Colors.BOLD}{'='*60}{Colors.RESET}")
    print(f"{Colors.BOLD}SUITE DE PRUEBAS QA - TicketsAPI{Colors.RESET}")
    print(f"{Colors.BOLD}Inicio: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}{Colors.RESET}")
    print(f"{Colors.BOLD}Base URL: {BASE_URL}{Colors.RESET}")
    print(f"{Colors.BOLD}{'='*60}{Colors.RESET}")
    
    all_results = []
    
    # Fase 1: Autenticación
    success, auth_results = test_authentication()
    all_results.append(auth_results)
    
    if not auth_results.get("token"):
        print(f"\n{Colors.RED}❌ No se pudo obtener token. Abortando.{Colors.RESET}")
        return
    
    token = auth_results["token"]
    
    # Fases 2-6: Pruebas funcionales
    success, ref_results = test_references(token)
    all_results.append(ref_results)
    
    success, tickets_results = test_tickets_crud(token)
    all_results.append(tickets_results)
    
    success, grupos_results = test_grupos(token)
    all_results.append(grupos_results)
    
    success, depts_results = test_departamentos(token)
    all_results.append(depts_results)
    
    success, motivos_results = test_motivos(token)
    all_results.append(motivos_results)
    
    # Pruebas adicionales
    success, perms_results = test_permissions(token)
    all_results.append(perms_results)
    
    # Pruebas de carga
    performance_test(token, "/Tickets", num_requests=20)
    performance_test(token, "/References/Estados", num_requests=20)
    
    # Resumen
    summary = generate_summary(all_results)
    
    # Guardar reporte en JSON
    with open("qa_test_report.json", "w", encoding="utf-8") as f:
        json.dump({
            "summary": summary,
            "details": all_results
        }, f, indent=2, ensure_ascii=False)
    
    print(f"\n{Colors.BLUE}Reporte guardado en: qa_test_report.json{Colors.RESET}\n")

if __name__ == "__main__":
    main()
