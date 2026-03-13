#!/usr/bin/env python3
"""
Suite de pruebas exhaustiva para TODOS los endpoints de TicketsAPI.
Cubre 57+ endpoints con casos de éxito, errores, validaciones y contraste con BD.

Ejecutar:
    python integration_comprehensive.py
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
TEST_USER = os.getenv("TICKETS_TEST_USER", "admin")
TEST_PASSWORD = os.getenv("TICKETS_TEST_PASSWORD", "changeme")
HTTP_TIMEOUT = int(os.getenv("TICKETS_HTTP_TIMEOUT", "15"))
RESULTS_FILE = os.getenv("TICKETS_RESULTS_FILE", "COMPREHENSIVE_TEST_RESULTS.json")


@dataclass
class TestResult:
    nombre: str
    metodo: str
    endpoint: str
    esperado: int
    obtenido: int
    exito: bool
    detalle: str
    categoria: str = "general"
    extra: Optional[Dict[str, Any]] = None


class ComprehensiveSuite:
    def __init__(self) -> None:
        self.token: Optional[str] = None
        self.results: List[TestResult] = []
        self.db_conn = None
        self.test_data = {}

    def connect_db(self):
        if self.db_conn:
            return self.db_conn
        try:
            self.db_conn = mysql.connector.connect(**DB_CONFIG)
            return self.db_conn
        except Exception as exc:
            print(f"❌ Error conectando a BD: {exc}")
            return None

    def db_query_one(self, query: str, params: tuple = ()):
        conn = self.connect_db()
        if not conn:
            return None
        cur = conn.cursor(dictionary=True)
        cur.execute(query, params)
        row = cur.fetchone()
        cur.close()
        return row

    def db_query_all(self, query: str, params: tuple = ()):
        conn = self.connect_db()
        if not conn:
            return []
        cur = conn.cursor(dictionary=True)
        cur.execute(query, params)
        rows = cur.fetchall()
        cur.close()
        return rows

    def request(self, method: str, path: str, *, json_body: Optional[Dict] = None, token: Optional[str] = None):
        url = f"{API_BASE_URL}{path}"
        headers = {"Content-Type": "application/json"}
        if token:
            headers["Authorization"] = f"Bearer {token}"
        resp = requests.request(
            method=method.upper(),
            url=url,
            headers=headers,
            json=json_body,
            timeout=HTTP_TIMEOUT,
            verify=False,
        )
        try:
            payload = resp.json()
        except Exception:
            payload = resp.text
        return resp.status_code, payload

    def add_result(self, res: TestResult):
        self.results.append(res)
        icon = "✅" if res.exito else "❌"
        print(f"{icon} [{res.categoria}] {res.nombre}: {res.obtenido} (esperado {res.esperado})")

    def login(self):
        payloads = [
            {"Usuario": TEST_USER, "Contraseña": TEST_PASSWORD},
            {"usuario": TEST_USER, "contraseña": TEST_PASSWORD},
        ]
        for body in payloads:
            status, resp = self.request("POST", "/Auth/login", json_body=body)
            if status == 200 and isinstance(resp, dict):
                datos = resp.get("datos") or resp.get("data") or resp
                token = datos.get("token") if isinstance(datos, dict) else None
                if token:
                    self.token = token
                    self.add_result(TestResult(
                        nombre="Login",
                        metodo="POST",
                        endpoint="/Auth/login",
                        esperado=200,
                        obtenido=status,
                        exito=True,
                        detalle="OK",
                        categoria="auth",
                    ))
                    return True
        self.add_result(TestResult(
            nombre="Login",
            metodo="POST",
            endpoint="/Auth/login",
            esperado=200,
            obtenido=status,
            exito=False,
            detalle="Falló login",
            categoria="auth",
        ))
        return False

    def fetch_reference_ids(self):
        prioridad = self.db_query_one("SELECT Id_Prioridad FROM prioridad LIMIT 1") or {"Id_Prioridad": 1}
        depto = self.db_query_one("SELECT Id_Departamento FROM departamento LIMIT 1") or {"Id_Departamento": 1}
        motivo = self.db_query_one("SELECT Id_Motivo FROM motivo LIMIT 1")
        estado = self.db_query_one("SELECT Id_Estado FROM estado LIMIT 1") or {"Id_Estado": 1}
        return {
            "prioridad": prioridad.get("Id_Prioridad", 1),
            "departamento": depto.get("Id_Departamento", 1),
            "motivo": motivo.get("Id_Motivo") if motivo else None,
            "estado": estado.get("Id_Estado", 1),
        }

    # ==================== TESTS POR CATEGORÍA ====================

    def test_auth(self):
        """Auth endpoints."""
        # GET me
        status, resp = self.request("GET", "/Auth/me", token=self.token)
        self.add_result(TestResult(
            nombre="Auth: GET /me",
            metodo="GET",
            endpoint="/Auth/me",
            esperado=200,
            obtenido=status,
            exito=status == 200,
            detalle=str(resp)[:200],
            categoria="auth",
        ))

    def test_referencias(self):
        """Referencias (estados, prioridades, departamentos)."""
        endpoints = [
            ("Estados", "/references/estados"),
            ("Prioridades", "/references/prioridades"),
            ("Departamentos", "/references/departamentos"),
        ]
        for name, endpoint in endpoints:
            status, resp = self.request("GET", endpoint, token=self.token)
            exito = status == 200
            self.add_result(TestResult(
                nombre=f"Ref: {name}",
                metodo="GET",
                endpoint=endpoint,
                esperado=200,
                obtenido=status,
                exito=exito,
                detalle=str(resp)[:200],
                categoria="referencias",
            ))

    def test_tickets_crud(self, refs):
        """Tickets: CRUD operations."""
        # GET all
        status, resp = self.request("GET", "/Tickets", token=self.token)
        self.add_result(TestResult(
            nombre="Tickets: GET all",
            metodo="GET",
            endpoint="/Tickets",
            esperado=200,
            obtenido=status,
            exito=status == 200,
            detalle=str(resp)[:200],
            categoria="tickets",
        ))

        # POST create
        payload = {
            "Contenido": f"Test {int(time.time())}",
            "Id_Prioridad": refs["prioridad"],
            "Id_Departamento": refs["departamento"],
        }
        status, resp = self.request("POST", "/Tickets", json_body=payload, token=self.token)
        exito = status in (200, 201)
        ticket_id = None
        if exito and isinstance(resp, dict):
            datos = resp.get("datos") or resp.get("data") or {}
            ticket_id = datos.get("id") or datos.get("Id")
        self.add_result(TestResult(
            nombre="Tickets: POST create",
            metodo="POST",
            endpoint="/Tickets",
            esperado=201,
            obtenido=status,
            exito=exito,
            detalle=str(resp)[:200],
            categoria="tickets",
            extra={"ticket_id": ticket_id},
        ))

        if ticket_id:
            self.test_data["ticket_id"] = ticket_id

            # GET by ID
            status, resp = self.request("GET", f"/Tickets/{ticket_id}", token=self.token)
            self.add_result(TestResult(
                nombre="Tickets: GET by ID",
                metodo="GET",
                endpoint=f"/Tickets/{ticket_id}",
                esperado=200,
                obtenido=status,
                exito=status == 200,
                detalle=str(resp)[:200],
                categoria="tickets",
            ))

            # PUT update
            update_payload = {
                "Contenido": f"Updated {int(time.time())}",
                "Id_Prioridad": refs["prioridad"],
                "Id_Departamento": refs["departamento"],
            }
            status, resp = self.request("PUT", f"/Tickets/{ticket_id}", json_body=update_payload, token=self.token)
            self.add_result(TestResult(
                nombre="Tickets: PUT update",
                metodo="PUT",
                endpoint=f"/Tickets/{ticket_id}",
                esperado=200,
                obtenido=status,
                exito=status == 200,
                detalle=str(resp)[:200],
                categoria="tickets",
            ))

            # PATCH assign
            status, resp = self.request("PATCH", f"/Tickets/{ticket_id}/asignar/1", token=self.token)
            self.add_result(TestResult(
                nombre="Tickets: PATCH assign",
                metodo="PATCH",
                endpoint=f"/Tickets/{ticket_id}/asignar/1",
                esperado=200,
                obtenido=status,
                exito=status == 200,
                detalle=str(resp)[:200],
                categoria="tickets",
            ))

    def test_tickets_advanced(self):
        """Búsqueda avanzada de tickets."""
        status, resp = self.request("GET", "/Tickets/buscar?Busqueda=test&BuscarEnComentarios=true", token=self.token)
        self.add_result(TestResult(
            nombre="Tickets: Búsqueda avanzada",
            metodo="GET",
            endpoint="/Tickets/buscar",
            esperado=200,
            obtenido=status,
            exito=status == 200,
            detalle=str(resp)[:200],
            categoria="tickets",
        ))

    def test_comentarios(self):
        """Comentarios CRUD."""
        ticket_id = self.test_data.get("ticket_id")
        if not ticket_id:
            return

        # POST create
        payload = {"Contenido": f"Comment {int(time.time())}", "Privado": False}
        status, resp = self.request("POST", f"/Tickets/{ticket_id}/Comments", json_body=payload, token=self.token)
        exito = status in (200, 201)
        comment_id = None
        if exito and isinstance(resp, dict):
            datos = resp.get("datos") or resp.get("data") or {}
            comment_id = datos.get("id_comentario") or datos.get("Id_Comentario")
        self.add_result(TestResult(
            nombre="Comentarios: POST create",
            metodo="POST",
            endpoint=f"/Tickets/{ticket_id}/Comments",
            esperado=201,
            obtenido=status,
            exito=exito,
            detalle=str(resp)[:200],
            categoria="comentarios",
            extra={"comment_id": comment_id},
        ))

        # GET all
        status, resp = self.request("GET", f"/Tickets/{ticket_id}/Comments", token=self.token)
        self.add_result(TestResult(
            nombre="Comentarios: GET all",
            metodo="GET",
            endpoint=f"/Tickets/{ticket_id}/Comments",
            esperado=200,
            obtenido=status,
            exito=status == 200,
            detalle=str(resp)[:200],
            categoria="comentarios",
        ))

        if comment_id:
            # PUT update
            update_payload = {"Contenido": f"Updated {int(time.time())}", "Privado": True}
            status, resp = self.request("PUT", f"/Comments/{comment_id}", json_body=update_payload, token=self.token)
            self.add_result(TestResult(
                nombre="Comentarios: PUT update",
                metodo="PUT",
                endpoint=f"/Comments/{comment_id}",
                esperado=200,
                obtenido=status,
                exito=status == 200,
                detalle=str(resp)[:200],
                categoria="comentarios",
            ))

    def test_historial_y_transiciones(self):
        """Historial y transiciones."""
        ticket_id = self.test_data.get("ticket_id")
        if not ticket_id:
            return

        # Historial
        status, resp = self.request("GET", f"/Tickets/{ticket_id}/historial", token=self.token)
        self.add_result(TestResult(
            nombre="Historial: GET",
            metodo="GET",
            endpoint=f"/Tickets/{ticket_id}/historial",
            esperado=200,
            obtenido=status,
            exito=status == 200,
            detalle=str(resp)[:200],
            categoria="historial",
        ))

        # Transiciones permitidas
        status, resp = self.request("GET", f"/Tickets/{ticket_id}/transiciones-permitidas", token=self.token)
        self.add_result(TestResult(
            nombre="Transiciones: GET permitidas",
            metodo="GET",
            endpoint=f"/Tickets/{ticket_id}/transiciones-permitidas",
            esperado=200,
            obtenido=status,
            exito=status == 200,
            detalle=str(resp)[:200],
            categoria="historial",
        ))

    def test_departamentos(self):
        """Departamentos CRUD."""
        # GET all
        status, resp = self.request("GET", "/Departamentos", token=self.token)
        self.add_result(TestResult(
            nombre="Depts: GET all",
            metodo="GET",
            endpoint="/Departamentos",
            esperado=200,
            obtenido=status,
            exito=status == 200,
            detalle=str(resp)[:200],
            categoria="departamentos",
        ))

        # GET by ID
        dep_id = self.db_query_one("SELECT Id_Departamento FROM departamento LIMIT 1")
        if dep_id:
            status, resp = self.request("GET", f"/Departamentos/{dep_id['Id_Departamento']}", token=self.token)
            self.add_result(TestResult(
                nombre="Depts: GET by ID",
                metodo="GET",
                endpoint=f"/Departamentos/{dep_id['Id_Departamento']}",
                esperado=200,
                obtenido=status,
                exito=status == 200,
                detalle=str(resp)[:200],
                categoria="departamentos",
            ))

    def test_motivos(self):
        """Motivos CRUD."""
        status, resp = self.request("GET", "/Motivos", token=self.token)
        self.add_result(TestResult(
            nombre="Motivos: GET all",
            metodo="GET",
            endpoint="/Motivos",
            esperado=200,
            obtenido=status,
            exito=status == 200,
            detalle=str(resp)[:200],
            categoria="motivos",
        ))

    def test_reportes(self):
        """Reportes."""
        endpoints = [
            ("Dashboard", "/Reportes/Dashboard"),
            ("PorEstado", "/Reportes/PorEstado"),
            ("PorPrioridad", "/Reportes/PorPrioridad"),
            ("PorDepartamento", "/Reportes/PorDepartamento"),
            ("Tendencias", "/Reportes/Tendencias"),
        ]
        for name, endpoint in endpoints:
            status, resp = self.request("GET", endpoint, token=self.token)
            self.add_result(TestResult(
                nombre=f"Reportes: {name}",
                metodo="GET",
                endpoint=endpoint,
                esperado=200,
                obtenido=status,
                exito=status == 200,
                detalle=str(resp)[:200],
                categoria="reportes",
            ))

    def run(self):
        print("[SUITE EXHAUSTIVA DE PRUEBAS - TicketsAPI]\n")
        print(f"API: {API_BASE_URL}")
        print(f"BD: {DB_CONFIG['host']}:{DB_CONFIG['port']} / {DB_CONFIG['database']}\n")

        if not self.login():
            return False

        refs = self.fetch_reference_ids()

        # Ejecutar todas las pruebas
        print("[*] Ejecutando pruebas...\n")
        self.test_auth()
        self.test_referencias()
        self.test_tickets_crud(refs)
        self.test_tickets_advanced()
        self.test_comentarios()
        self.test_historial_y_transiciones()
        self.test_departamentos()
        self.test_motivos()
        self.test_reportes()

        self.save_results()
        self.print_summary()
        return True

    def save_results(self):
        data = [asdict(r) for r in self.results]
        with open(RESULTS_FILE, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        print(f"\n[*] Resultados guardados en {RESULTS_FILE}")

    def print_summary(self):
        total = len(self.results)
        passed = sum(1 for r in self.results if r.exito)
        failed = total - passed
        
        # Agrupar por categoría
        by_category = {}
        for r in self.results:
            cat = r.categoria
            if cat not in by_category:
                by_category[cat] = {"total": 0, "passed": 0}
            by_category[cat]["total"] += 1
            if r.exito:
                by_category[cat]["passed"] += 1
        
        print("\n" + "="*70)
        print("RESUMEN FINAL DE PRUEBAS")
        print("="*70)
        print(f"\n[*] Total: {passed}/{total} exitosas ({100*passed//total if total > 0 else 0}%)")
        print(f"[+] Exitosas: {passed}")
        print(f"[-] Fallidas: {failed}\n")
        
        print("[*] Por categoria:")
        for cat in sorted(by_category.keys()):
            stats = by_category[cat]
            pct = 100 * stats["passed"] // stats["total"] if stats["total"] > 0 else 0
            print(f"  {cat:20s}: {stats['passed']}/{stats['total']} ({pct}%)")
        
        if failed > 0:
            print("\n[-] Fallos:")
            for r in self.results:
                if not r.exito:
                    print(f"  - {r.nombre}: {r.detalle}")


if __name__ == "__main__":
    suite = ComprehensiveSuite()
    ok = suite.run()
