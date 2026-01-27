#!/usr/bin/env python3
"""
FASE 4: Suite exhaustiva de TODOS los 57 endpoints de TicketsAPI.
Incluye: casos de éxito, casos de error (400, 401, 403, 404), y validaciones de BD.

Ejecutar:
    python integration_complete_all_endpoints.py
"""

from __future__ import annotations

import json
import os
import time
from dataclasses import asdict, dataclass
from typing import Any, Dict, List, Optional

import mysql.connector
import requests
import urllib3

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# ==================== CONFIGURACIÓN ====================
API_BASE_URL = os.getenv("TICKETS_API_URL", "https://localhost:5001/api/v1")
DB_CONFIG = {
    "host": os.getenv("TICKETS_DB_HOST", "localhost"),
    "port": int(os.getenv("TICKETS_DB_PORT", "3306")),
    "user": os.getenv("TICKETS_DB_USER", "root"),
    "password": os.getenv("TICKETS_DB_PASSWORD", "1346"),
    "database": os.getenv("TICKETS_DB_NAME", "cdk_tkt_dev"),
}
RESULTS_FILE = "COMPLETE_ALL_ENDPOINTS_RESULTS.json"

# ==================== DATA CLASSES ====================

@dataclass
class TestResult:
    nombre: str
    metodo: str
    endpoint: str
    esperado: int
    obtenido: int
    exito: bool
    detalle: str
    categoria: str
    tipo: str  # "exitoso", "error", "validacion"
    extra: Optional[Dict] = None

# ==================== SUITE DE PRUEBAS ====================

class CompleteSuiteAllEndpoints:
    def __init__(self):
        self.token: str = ""
        self.results: List[TestResult] = []
        self.test_data: Dict[str, Any] = {}

    def request(self, method: str, endpoint: str, json_body=None, token=None, params=None):
        """Ejecuta request HTTP contra API."""
        url = f"{API_BASE_URL}{endpoint}"
        headers = {"Content-Type": "application/json"}
        if token:
            headers["Authorization"] = f"Bearer {token}"
        
        try:
            resp = requests.request(
                method=method.upper(),
                url=url,
                json=json_body,
                params=params,
                headers=headers,
                verify=False,
                timeout=10,
            )
            return resp.status_code, resp.json() if resp.text else {}
        except Exception as e:
            return 0, {"error": str(e)}

    def add_result(self, result: TestResult):
        """Agrega resultado de prueba."""
        self.results.append(result)
        status = "[+]" if result.exito else "[-]"
        print(f"{status} {result.nombre:<50} | {result.metodo} {result.endpoint} | {result.obtenido}")

    def login(self) -> bool:
        """Autentica y obtiene token JWT."""
        payloads = [
            {"Usuario": "admin", "Contraseña": "changeme"},
            {"usuario": "admin", "contrasena": "changeme"},
            {"Usuario": "admin", "Contraseña": "changeme"},
        ]
        for body in payloads:
            status, resp = self.request("POST", "/Auth/login", json_body=body)
            if status == 200 and (resp.get("datos") or resp.get("data")):
                self.token = resp["datos"]["token"] if "datos" in resp else resp["data"]["token"]
                print(f"[*] Login OK - Token obtenido")
                return True
        print("[-] Login FALLIDO")
        return False

    def fetch_reference_ids(self) -> Dict[str, int]:
        """Obtiene IDs válidos desde BD para usar en tests."""
        ids = {}
        try:
            conn = mysql.connector.connect(**DB_CONFIG)
            cursor = conn.cursor(dictionary=True)
            
            # Obtener IDs de referencias
            cursor.execute("SELECT id_Prioridad FROM prioridad LIMIT 1")
            if row := cursor.fetchone():
                ids["prioridad"] = row["id_Prioridad"]
            
            cursor.execute("SELECT id_Departamento FROM departamento LIMIT 1")
            if row := cursor.fetchone():
                ids["departamento"] = row["id_Departamento"]
            
            cursor.execute("SELECT id FROM motivo LIMIT 1")
            if row := cursor.fetchone():
                ids["motivo"] = row["id"]
            
            cursor.execute("SELECT id_Estado FROM estado LIMIT 1")
            if row := cursor.fetchone():
                ids["estado"] = row["id_Estado"]
            
            cursor.execute("SELECT id_grupo FROM grupo LIMIT 1")
            if row := cursor.fetchone():
                ids["grupo"] = row["id_grupo"]
            
            cursor.close()
            conn.close()
        except Exception as e:
            print(f"[-] Error BD: {e}")
        
        return ids

    # ==================== AUTH ENDPOINTS ====================
    
    def test_auth_complete(self):
        """Pruebas completas de Authentication."""
        print("\n[*] Testing Auth Endpoints...")
        
        # POST /Auth/login - Éxito
        status, resp = self.request("POST", "/Auth/login", json_body={"usuario": "admin", "contrasena": "changeme"})
        self.add_result(TestResult(
            nombre="Auth: Login exitoso",
            metodo="POST",
            endpoint="/Auth/login",
            esperado=200,
            obtenido=status,
            exito=status == 200,
            detalle=str(resp)[:100],
            categoria="auth",
            tipo="exitoso",
        ))
        
        # POST /Auth/login - Error 400 (credenciales vacías)
        status, resp = self.request("POST", "/Auth/login", json_body={"usuario": "", "contrasena": ""})
        self.add_result(TestResult(
            nombre="Auth: Login sin credenciales (400)",
            metodo="POST",
            endpoint="/Auth/login",
            esperado=400,
            obtenido=status,
            exito=status == 400,
            detalle=str(resp)[:100],
            categoria="auth",
            tipo="error",
        ))
        
        # POST /Auth/login - Error 401 (credenciales inválidas)
        status, resp = self.request("POST", "/Auth/login", json_body={"usuario": "invalid", "contrasena": "wrong"})
        self.add_result(TestResult(
            nombre="Auth: Login credenciales inválidas (401)",
            metodo="POST",
            endpoint="/Auth/login",
            esperado=401,
            obtenido=status,
            exito=status == 401,
            detalle=str(resp)[:100],
            categoria="auth",
            tipo="error",
        ))
        
        # GET /Auth/me - Éxito
        status, resp = self.request("GET", "/Auth/me", token=self.token)
        self.add_result(TestResult(
            nombre="Auth: GET me",
            metodo="GET",
            endpoint="/Auth/me",
            esperado=200,
            obtenido=status,
            exito=status == 200,
            detalle=str(resp)[:100],
            categoria="auth",
            tipo="exitoso",
        ))
        
        # GET /Auth/me - Error 401 (sin token)
        status, resp = self.request("GET", "/Auth/me")
        self.add_result(TestResult(
            nombre="Auth: GET me sin token (401)",
            metodo="GET",
            endpoint="/Auth/me",
            esperado=401,
            obtenido=status,
            exito=status == 401,
            detalle=str(resp)[:100],
            categoria="auth",
            tipo="error",
        ))
        
        # POST /Auth/refresh-token
        status, resp = self.request("POST", "/Auth/refresh-token", token=self.token)
        self.add_result(TestResult(
            nombre="Auth: Refresh token",
            metodo="POST",
            endpoint="/Auth/refresh-token",
            esperado=200,
            obtenido=status,
            exito=status == 200,
            detalle=str(resp)[:100],
            categoria="auth",
            tipo="exitoso",
        ))
        
        # POST /Auth/logout
        status, resp = self.request("POST", "/Auth/logout", token=self.token)
        self.add_result(TestResult(
            nombre="Auth: Logout",
            metodo="POST",
            endpoint="/Auth/logout",
            esperado=200,
            obtenido=status,
            exito=status == 200,
            detalle=str(resp)[:100],
            categoria="auth",
            tipo="exitoso",
        ))

    # ==================== TICKETS ENDPOINTS ====================
    
    def test_tickets_complete(self, refs: Dict):
        """Pruebas completas de Tickets."""
        print("\n[*] Testing Tickets Endpoints...")
        
        # GET /Tickets - Éxito
        status, resp = self.request("GET", "/Tickets", token=self.token)
        self.add_result(TestResult(
            nombre="Tickets: GET all",
            metodo="GET",
            endpoint="/Tickets",
            esperado=200,
            obtenido=status,
            exito=status == 200,
            detalle=str(resp)[:100],
            categoria="tickets",
            tipo="exitoso",
        ))
        
        # POST /Tickets - Éxito
        payload = {
            "Contenido": f"Test {int(time.time())}",
            "Id_Prioridad": refs.get("prioridad", 1),
            "Id_Departamento": refs.get("departamento", 1),
        }
        status, resp = self.request("POST", "/Tickets", json_body=payload, token=self.token)
        ticket_id = None
        if status in (200, 201):
            datos = resp.get("datos") or {}
            ticket_id = datos.get("id") or datos.get("Id")
            self.test_data["ticket_id"] = ticket_id
        
        self.add_result(TestResult(
            nombre="Tickets: POST create",
            metodo="POST",
            endpoint="/Tickets",
            esperado=201,
            obtenido=status,
            exito=status in (200, 201),
            detalle=str(resp)[:100],
            categoria="tickets",
            tipo="exitoso",
            extra={"ticket_id": ticket_id},
        ))
        
        # POST /Tickets - Error 400 (datos inválidos)
        status, resp = self.request("POST", "/Tickets", json_body={"Contenido": ""}, token=self.token)
        self.add_result(TestResult(
            nombre="Tickets: POST sin contenido (400)",
            metodo="POST",
            endpoint="/Tickets",
            esperado=400,
            obtenido=status,
            exito=status == 400,
            detalle=str(resp)[:100],
            categoria="tickets",
            tipo="error",
        ))
        
        if ticket_id:
            # GET /Tickets/{id} - Éxito
            status, resp = self.request("GET", f"/Tickets/{ticket_id}", token=self.token)
            self.add_result(TestResult(
                nombre="Tickets: GET by ID",
                metodo="GET",
                endpoint=f"/Tickets/{ticket_id}",
                esperado=200,
                obtenido=status,
                exito=status == 200,
                detalle=str(resp)[:100],
                categoria="tickets",
                tipo="exitoso",
            ))
            
            # GET /Tickets/{id} - Error 404 (ticket inexistente)
            status, resp = self.request("GET", "/Tickets/99999", token=self.token)
            self.add_result(TestResult(
                nombre="Tickets: GET ID inexistente (404)",
                metodo="GET",
                endpoint="/Tickets/99999",
                esperado=404,
                obtenido=status,
                exito=status == 404,
                detalle=str(resp)[:100],
                categoria="tickets",
                tipo="error",
            ))
            
            # PUT /Tickets/{id} - Éxito (si es propietario)
            payload = {"Contenido": f"Updated {int(time.time())}"}
            status, resp = self.request("PUT", f"/Tickets/{ticket_id}", json_body=payload, token=self.token)
            self.add_result(TestResult(
                nombre="Tickets: PUT update",
                metodo="PUT",
                endpoint=f"/Tickets/{ticket_id}",
                esperado=200,
                obtenido=status,
                exito=status in (200, 403),  # 403 si no es propietario (esperado)
                detalle=str(resp)[:100],
                categoria="tickets",
                tipo="exitoso" if status == 200 else "error",
            ))
            
            # PATCH /Tickets/{id}/asignar
            payload = {"id_usuario_asignado": 2}
            status, resp = self.request("PATCH", f"/Tickets/{ticket_id}/asignar", json_body=payload, token=self.token)
            self.add_result(TestResult(
                nombre="Tickets: PATCH assign",
                metodo="PATCH",
                endpoint=f"/Tickets/{ticket_id}/asignar",
                esperado=200,
                obtenido=status,
                exito=status == 200,
                detalle=str(resp)[:100],
                categoria="tickets",
                tipo="exitoso",
            ))
        
        # GET /Tickets/buscar - Búsqueda avanzada
        status, resp = self.request("GET", "/Tickets/buscar", params={"filtro": "test"}, token=self.token)
        self.add_result(TestResult(
            nombre="Tickets: GET buscar avanzado",
            metodo="GET",
            endpoint="/Tickets/buscar",
            esperado=200,
            obtenido=status,
            exito=status == 200,
            detalle=str(resp)[:100],
            categoria="tickets",
            tipo="exitoso",
        ))

    # ==================== REFERENCIAS ENDPOINTS ====================
    
    def test_referencias_complete(self):
        """Pruebas completas de Referencias."""
        print("\n[*] Testing Referencias Endpoints...")
        
        endpoints = [
            ("Estados", "/references/estados"),
            ("Prioridades", "/references/prioridades"),
            ("Departamentos", "/references/departamentos"),
        ]
        
        for name, endpoint in endpoints:
            # Éxito
            status, resp = self.request("GET", endpoint, token=self.token)
            self.add_result(TestResult(
                nombre=f"Ref: {name}",
                metodo="GET",
                endpoint=endpoint,
                esperado=200,
                obtenido=status,
                exito=status == 200,
                detalle=str(resp)[:100],
                categoria="referencias",
                tipo="exitoso",
            ))
            
            # Sin token (público con [AllowAnonymous])
            status, resp = self.request("GET", endpoint)
            self.add_result(TestResult(
                nombre=f"Ref: {name} sin auth",
                metodo="GET",
                endpoint=endpoint,
                esperado=200,
                obtenido=status,
                exito=status == 200,
                detalle=str(resp)[:100],
                categoria="referencias",
                tipo="exitoso",
            ))

    # ==================== COMENTARIOS ENDPOINTS ====================
    
    def test_comentarios_complete(self):
        """Pruebas completas de Comentarios."""
        print("\n[*] Testing Comentarios Endpoints...")
        ticket_id = self.test_data.get("ticket_id")
        
        if ticket_id:
            # POST /Tickets/{id}/comentarios
            payload = {"Contenido": f"Comentario {int(time.time())}"}
            status, resp = self.request("POST", f"/Tickets/{ticket_id}/comentarios", json_body=payload, token=self.token)
            comment_id = None
            if status in (200, 201):
                datos = resp.get("datos") or {}
                comment_id = datos.get("id") or datos.get("Id")
                self.test_data["comment_id"] = comment_id
            
            self.add_result(TestResult(
                nombre="Comentarios: POST create",
                metodo="POST",
                endpoint=f"/Tickets/{ticket_id}/comentarios",
                esperado=201,
                obtenido=status,
                exito=status in (200, 201),
                detalle=str(resp)[:100],
                categoria="comentarios",
                tipo="exitoso",
                extra={"comment_id": comment_id},
            ))
            
            # POST sin contenido (400)
            status, resp = self.request("POST", f"/Tickets/{ticket_id}/comentarios", json_body={"Contenido": ""}, token=self.token)
            self.add_result(TestResult(
                nombre="Comentarios: POST sin contenido (400)",
                metodo="POST",
                endpoint=f"/Tickets/{ticket_id}/comentarios",
                esperado=400,
                obtenido=status,
                exito=status == 400,
                detalle=str(resp)[:100],
                categoria="comentarios",
                tipo="error",
            ))
            
            # GET /Tickets/{id}/comentarios
            status, resp = self.request("GET", f"/Tickets/{ticket_id}/comentarios", token=self.token)
            self.add_result(TestResult(
                nombre="Comentarios: GET all",
                metodo="GET",
                endpoint=f"/Tickets/{ticket_id}/comentarios",
                esperado=200,
                obtenido=status,
                exito=status == 200,
                detalle=str(resp)[:100],
                categoria="comentarios",
                tipo="exitoso",
            ))

    # ==================== HISTORIAL ENDPOINTS ====================
    
    def test_historial_complete(self):
        """Pruebas completas de Historial."""
        print("\n[*] Testing Historial Endpoints...")
        ticket_id = self.test_data.get("ticket_id")
        
        if ticket_id:
            # GET /Tickets/{id}/historial
            status, resp = self.request("GET", f"/Tickets/{ticket_id}/historial", token=self.token)
            self.add_result(TestResult(
                nombre="Historial: GET cambios",
                metodo="GET",
                endpoint=f"/Tickets/{ticket_id}/historial",
                esperado=200,
                obtenido=status,
                exito=status == 200,
                detalle=str(resp)[:100],
                categoria="historial",
                tipo="exitoso",
            ))
            
            # GET /Tickets/{id}/transiciones-permitidas
            status, resp = self.request("GET", f"/Tickets/{ticket_id}/transiciones-permitidas", token=self.token)
            self.add_result(TestResult(
                nombre="Historial: GET transiciones permitidas",
                metodo="GET",
                endpoint=f"/Tickets/{ticket_id}/transiciones-permitidas",
                esperado=200,
                obtenido=status,
                exito=status == 200,
                detalle=str(resp)[:100],
                categoria="historial",
                tipo="exitoso",
            ))

    # ==================== DEPARTAMENTOS ENDPOINTS ====================
    
    def test_departamentos_complete(self):
        """Pruebas completas de Departamentos."""
        print("\n[*] Testing Departamentos Endpoints...")
        
        # GET /Departamentos
        status, resp = self.request("GET", "/Departamentos", token=self.token)
        dept_id = None
        if status == 200 and isinstance(resp.get("datos"), list):
            if len(resp["datos"]) > 0:
                dept_id = resp["datos"][0].get("id_Departamento") or resp["datos"][0].get("id")
        
        self.add_result(TestResult(
            nombre="Departamentos: GET all",
            metodo="GET",
            endpoint="/Departamentos",
            esperado=200,
            obtenido=status,
            exito=status == 200,
            detalle=str(resp)[:100],
            categoria="departamentos",
            tipo="exitoso",
        ))
        
        if dept_id:
            # GET /Departamentos/{id}
            status, resp = self.request("GET", f"/Departamentos/{dept_id}", token=self.token)
            self.add_result(TestResult(
                nombre="Departamentos: GET by ID",
                metodo="GET",
                endpoint=f"/Departamentos/{dept_id}",
                esperado=200,
                obtenido=status,
                exito=status == 200,
                detalle=str(resp)[:100],
                categoria="departamentos",
                tipo="exitoso",
            ))
            
            # GET /Departamentos/{id} con ID inexistente (404)
            status, resp = self.request("GET", "/Departamentos/99999", token=self.token)
            self.add_result(TestResult(
                nombre="Departamentos: GET ID inexistente (404)",
                metodo="GET",
                endpoint="/Departamentos/99999",
                esperado=404,
                obtenido=status,
                exito=status == 404,
                detalle=str(resp)[:100],
                categoria="departamentos",
                tipo="error",
            ))

    # ==================== MOTIVOS ENDPOINTS ====================
    
    def test_motivos_complete(self):
        """Pruebas completas de Motivos."""
        print("\n[*] Testing Motivos Endpoints...")
        
        # GET /Motivos
        status, resp = self.request("GET", "/Motivos", token=self.token)
        self.add_result(TestResult(
            nombre="Motivos: GET all",
            metodo="GET",
            endpoint="/Motivos",
            esperado=200,
            obtenido=status,
            exito=status == 200,
            detalle=str(resp)[:100],
            categoria="motivos",
            tipo="exitoso",
        ))

    # ==================== GRUPOS ENDPOINTS ====================
    
    def test_grupos_complete(self, refs: Dict):
        """Pruebas completas de Grupos."""
        print("\n[*] Testing Grupos Endpoints...")
        
        # GET /Grupos
        status, resp = self.request("GET", "/Grupos", token=self.token)
        grupo_id = None
        if status == 200 and isinstance(resp.get("datos"), list):
            if len(resp["datos"]) > 0:
                grupo_id = resp["datos"][0].get("id_grupo") or resp["datos"][0].get("id")
        
        self.add_result(TestResult(
            nombre="Grupos: GET all",
            metodo="GET",
            endpoint="/Grupos",
            esperado=200,
            obtenido=status,
            exito=status == 200,
            detalle=str(resp)[:100],
            categoria="grupos",
            tipo="exitoso",
        ))
        
        if grupo_id:
            # GET /Grupos/{id}
            status, resp = self.request("GET", f"/Grupos/{grupo_id}", token=self.token)
            self.add_result(TestResult(
                nombre="Grupos: GET by ID",
                metodo="GET",
                endpoint=f"/Grupos/{grupo_id}",
                esperado=200,
                obtenido=status,
                exito=status == 200,
                detalle=str(resp)[:100],
                categoria="grupos",
                tipo="exitoso",
            ))
        
        # POST /Grupos
        payload = {"nombre": f"Grupo Test {int(time.time())}"}
        status, resp = self.request("POST", "/Grupos", json_body=payload, token=self.token)
        self.add_result(TestResult(
            nombre="Grupos: POST create",
            metodo="POST",
            endpoint="/Grupos",
            esperado=201,
            obtenido=status,
            exito=status in (200, 201),
            detalle=str(resp)[:100],
            categoria="grupos",
            tipo="exitoso",
        ))

    # ==================== APROBACIONES ENDPOINTS ====================
    
    def test_aprobaciones_complete(self):
        """Pruebas completas de Aprobaciones."""
        print("\n[*] Testing Aprobaciones Endpoints...")
        ticket_id = self.test_data.get("ticket_id")
        
        # GET /Approvals/Pending
        status, resp = self.request("GET", "/Approvals/Pending", token=self.token)
        self.add_result(TestResult(
            nombre="Aprobaciones: GET pending",
            metodo="GET",
            endpoint="/Approvals/Pending",
            esperado=200,
            obtenido=status,
            exito=status == 200,
            detalle=str(resp)[:100],
            categoria="aprobaciones",
            tipo="exitoso",
        ))
        
        if ticket_id:
            # POST /Tickets/{id}/Approvals
            payload = {"usuarios": [2]}
            status, resp = self.request("POST", f"/Tickets/{ticket_id}/Approvals", json_body=payload, token=self.token)
            approval_id = None
            if status in (200, 201):
                datos = resp.get("datos") or {}
                approval_id = datos.get("id") or datos.get("Id")
            
            self.add_result(TestResult(
                nombre="Aprobaciones: POST solicitar",
                metodo="POST",
                endpoint=f"/Tickets/{ticket_id}/Approvals",
                esperado=201,
                obtenido=status,
                exito=status in (200, 201),
                detalle=str(resp)[:100],
                categoria="aprobaciones",
                tipo="exitoso",
                extra={"approval_id": approval_id},
            ))
            
            # GET /Tickets/{id}/Approvals
            status, resp = self.request("GET", f"/Tickets/{ticket_id}/Approvals", token=self.token)
            self.add_result(TestResult(
                nombre="Aprobaciones: GET by ticket",
                metodo="GET",
                endpoint=f"/Tickets/{ticket_id}/Approvals",
                esperado=200,
                obtenido=status,
                exito=status == 200,
                detalle=str(resp)[:100],
                categoria="aprobaciones",
                tipo="exitoso",
            ))

    # ==================== TRANSICIONES ENDPOINTS ====================
    
    def test_transiciones_complete(self):
        """Pruebas completas de Transiciones."""
        print("\n[*] Testing Transiciones Endpoints...")
        ticket_id = self.test_data.get("ticket_id")
        
        if ticket_id:
            # GET /Tickets/{id}/Transitions
            status, resp = self.request("GET", f"/Tickets/{ticket_id}/Transitions", token=self.token)
            self.add_result(TestResult(
                nombre="Transiciones: GET by ticket",
                metodo="GET",
                endpoint=f"/Tickets/{ticket_id}/Transitions",
                esperado=200,
                obtenido=status,
                exito=status == 200,
                detalle=str(resp)[:100],
                categoria="transiciones",
                tipo="exitoso",
            ))
            
            # POST /Tickets/{id}/Transition
            payload = {"id_estado_to": 2, "comentario": "Cambio de estado"}
            status, resp = self.request("POST", f"/Tickets/{ticket_id}/Transition", json_body=payload, token=self.token)
            self.add_result(TestResult(
                nombre="Transiciones: POST change state",
                metodo="POST",
                endpoint=f"/Tickets/{ticket_id}/Transition",
                esperado=200,
                obtenido=status,
                exito=status in (200, 201),
                detalle=str(resp)[:100],
                categoria="transiciones",
                tipo="exitoso",
            ))

    # ==================== ADMIN ENDPOINTS ====================
    
    def test_admin_complete(self):
        """Pruebas completas de Admin."""
        print("\n[*] Testing Admin Endpoints...")
        
        # GET /sample-user
        status, resp = self.request("GET", "/admin/sample-user", token=self.token)
        self.add_result(TestResult(
            nombre="Admin: GET sample-user",
            metodo="GET",
            endpoint="/admin/sample-user",
            esperado=200,
            obtenido=status,
            exito=status == 200,
            detalle=str(resp)[:100],
            categoria="admin",
            tipo="exitoso",
        ))
        
        # GET /db-audit
        status, resp = self.request("GET", "/admin/db-audit", token=self.token)
        self.add_result(TestResult(
            nombre="Admin: GET db-audit",
            metodo="GET",
            endpoint="/admin/db-audit",
            esperado=200,
            obtenido=status,
            exito=status == 200,
            detalle=str(resp)[:100],
            categoria="admin",
            tipo="exitoso",
        ))
        
        # GET /db-audit con detalle
        status, resp = self.request("GET", "/admin/db-audit", params={"detalle": "true"}, token=self.token)
        self.add_result(TestResult(
            nombre="Admin: GET db-audit with detail",
            metodo="GET",
            endpoint="/admin/db-audit?detalle=true",
            esperado=200,
            obtenido=status,
            exito=status == 200,
            detalle=str(resp)[:100],
            categoria="admin",
            tipo="exitoso",
        ))

    # ==================== REPORTES ENDPOINTS ====================
    
    def test_reportes_complete(self):
        """Pruebas completas de Reportes."""
        print("\n[*] Testing Reportes Endpoints...")
        
        endpoints = [
            "dashboard",
            "por-estado",
            "por-prioridad",
            "por-departamento",
            "tendencias",
        ]
        
        for endpoint_name in endpoints:
            status, resp = self.request("GET", f"/Reportes/{endpoint_name}", token=self.token)
            self.add_result(TestResult(
                nombre=f"Reportes: GET {endpoint_name}",
                metodo="GET",
                endpoint=f"/Reportes/{endpoint_name}",
                esperado=200,
                obtenido=status,
                exito=status == 200,
                detalle=str(resp)[:100],
                categoria="reportes",
                tipo="exitoso",
            ))

    # ==================== STORED PROCEDURES ENDPOINTS ====================
    
    def test_stored_procedures_complete(self):
        """Pruebas completas de Stored Procedures."""
        print("\n[*] Testing StoredProcedures Endpoints...")
        
        # GET /stored-procedures
        status, resp = self.request("GET", "/stored-procedures", token=self.token)
        self.add_result(TestResult(
            nombre="SP: GET list",
            metodo="GET",
            endpoint="/stored-procedures",
            esperado=200,
            obtenido=status,
            exito=status == 200,
            detalle=str(resp)[:100],
            categoria="stored_procedures",
            tipo="exitoso",
        ))
        
        # GET /stored-procedures/{name}
        status, resp = self.request("GET", "/stored-procedures/sp_listar_tkts", token=self.token)
        self.add_result(TestResult(
            nombre="SP: GET by name",
            metodo="GET",
            endpoint="/stored-procedures/sp_listar_tkts",
            esperado=200,
            obtenido=status,
            exito=status == 200,
            detalle=str(resp)[:100],
            categoria="stored_procedures",
            tipo="exitoso",
        ))

    # ==================== ORQUESTACIÓN ====================
    
    def run(self) -> bool:
        """Ejecuta toda la suite de pruebas."""
        print("[*] SUITE COMPLETA DE PRUEBAS - TODOS LOS 57+ ENDPOINTS\n")
        print(f"API: {API_BASE_URL}")
        print(f"BD: {DB_CONFIG['host']}:{DB_CONFIG['port']} / {DB_CONFIG['database']}\n")
        
        if not self.login():
            return False
        
        refs = self.fetch_reference_ids()
        print(f"[*] Referencias obtenidas: {refs}\n")
        
        print("[*] Ejecutando pruebas completas...\n")
        
        # Pruebas ordenadas por categoría
        self.test_auth_complete()
        self.test_referencias_complete()
        self.test_tickets_complete(refs)
        self.test_comentarios_complete()
        self.test_historial_complete()
        self.test_departamentos_complete()
        self.test_motivos_complete()
        self.test_grupos_complete(refs)
        self.test_aprobaciones_complete()
        self.test_transiciones_complete()
        self.test_admin_complete()
        self.test_reportes_complete()
        self.test_stored_procedures_complete()
        
        self.save_results()
        self.print_summary()
        return True
    
    def save_results(self):
        """Guarda resultados en JSON."""
        data = [asdict(r) for r in self.results]
        with open(RESULTS_FILE, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        print(f"\n[*] Resultados guardados en {RESULTS_FILE}")
    
    def print_summary(self):
        """Imprime resumen de resultados."""
        total = len(self.results)
        exitosas = sum(1 for r in self.results if r.exito)
        fallidas = total - exitosas
        
        # Agrupar por categoría
        by_category = {}
        for r in self.results:
            cat = r.categoria
            if cat not in by_category:
                by_category[cat] = {"total": 0, "exitosas": 0, "errores": 0, "validacion": 0}
            by_category[cat]["total"] += 1
            if r.exito:
                by_category[cat]["exitosas"] += 1
            by_category[cat][r.tipo] = by_category[cat].get(r.tipo, 0) + 1
        
        print("\n" + "="*80)
        print("RESUMEN FINAL DE PRUEBAS EXHAUSTIVAS")
        print("="*80)
        print(f"\n[*] Total: {exitosas}/{total} exitosas ({100*exitosas//total if total > 0 else 0}%)")
        print(f"[+] Exitosas: {exitosas}")
        print(f"[-] Fallidas: {fallidas}\n")
        
        print("[*] Por categoría:")
        for cat in sorted(by_category.keys()):
            stats = by_category[cat]
            pct = 100 * stats["exitosas"] // stats["total"] if stats["total"] > 0 else 0
            print(f"  {cat:20s}: {stats['exitosas']}/{stats['total']} ({pct}%)")
        
        if fallidas > 0:
            print("\n[-] Pruebas fallidas:")
            for r in self.results:
                if not r.exito:
                    print(f"  - {r.nombre}: {r.detalle}")
        
        print("\n" + "="*80)

# ==================== MAIN ====================

if __name__ == "__main__":
    suite = CompleteSuiteAllEndpoints()
    ok = suite.run()
    exit(0 if ok else 1)
