#!/usr/bin/env python3
"""
Suite de pruebas de integración end-to-end para TicketsAPI.
- Usa credenciales admin/changeme contra la API local.
- Valida efectos en BD MySQL (cdk_tkt_dev) para comparar resultados.
- Cubre endpoints principales: login, crear ticket, obtener ticket, búsqueda avanzada,
  comentarios y lectura de historial.

Ejecutar:
    python integration_endpoints.py

Requisitos:
    pip install requests mysql-connector-python urllib3
"""

from __future__ import annotations

import json
import os
import sys
import time
from dataclasses import dataclass, asdict
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
RESULTS_FILE = os.getenv("TICKETS_RESULTS_FILE", "INTEGRATION_ENDPOINT_RESULTS.json")


@dataclass
class TestResult:
    nombre: str
    metodo: str
    endpoint: str
    esperado: int
    obtenido: int
    exito: bool
    detalle: str
    verificacion_bd: Optional[str] = None
    extra: Optional[Dict[str, Any]] = None


class IntegrationSuite:
    def __init__(self) -> None:
        self.token: Optional[str] = None
        self.results: List[TestResult] = []
        self.db_conn = None

    # ---------- Infra ----------
    def connect_db(self):
        if self.db_conn:
            return self.db_conn
        try:
            self.db_conn = mysql.connector.connect(**DB_CONFIG)
            return self.db_conn
        except Exception as exc:  # pragma: no cover - solo logging
            print(f"❌ Error conectando a BD: {exc}")
            return None

    def db_query_one(self, query: str, params: tuple = ()):  # pragma: no cover - integración
        conn = self.connect_db()
        if not conn:
            return None
        cur = conn.cursor(dictionary=True)
        cur.execute(query, params)
        row = cur.fetchone()
        cur.close()
        return row

    def db_query_all(self, query: str, params: tuple = ()):  # pragma: no cover - integración
        conn = self.connect_db()
        if not conn:
            return []
        cur = conn.cursor(dictionary=True)
        cur.execute(query, params)
        rows = cur.fetchall()
        cur.close()
        return rows

    # ---------- HTTP helpers ----------
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
        print(f"{icon} {res.nombre}: {res.obtenido} (esperado {res.esperado})")
        if res.verificacion_bd:
            print(f"   BD: {res.verificacion_bd}")

    # ---------- Tests ----------
    def login(self):
        """Intenta login con varias formas de payload para robustez."""
        payloads = [
            {"Usuario": TEST_USER, "Contraseña": TEST_PASSWORD},
            {"usuario": TEST_USER, "contraseña": TEST_PASSWORD},
            {"usuario": TEST_USER, "contrasena": TEST_PASSWORD},
            {"email": TEST_USER, "password": TEST_PASSWORD},
        ]
        last_status, last_body = 0, None
        for body in payloads:
            status, resp = self.request("POST", "/Auth/login", json_body=body)
            last_status, last_body = status, resp
            if status == 200 and isinstance(resp, dict):
                datos = resp.get("datos") or resp.get("data") or resp
                token = datos.get("token") if isinstance(datos, dict) else None
                if token:
                    self.token = token
                    self.add_result(TestResult(
                        nombre="Login admin",
                        metodo="POST",
                        endpoint="/Auth/login",
                        esperado=200,
                        obtenido=status,
                        exito=True,
                        detalle="Login exitoso",
                    ))
                    return True
        self.add_result(TestResult(
            nombre="Login admin",
            metodo="POST",
            endpoint="/Auth/login",
            esperado=200,
            obtenido=last_status,
            exito=False,
            detalle=f"No se pudo iniciar sesión: {last_body}",
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

    def test_crear_ticket(self, refs):
        contenido = f"Ticket integración {int(time.time())}"
        payload = {
            "Contenido": contenido,
            "Id_Prioridad": refs["prioridad"],
            "Id_Departamento": refs["departamento"],
            "Id_Motivo": refs["motivo"],
        }
        status, resp = self.request("POST", "/Tickets", json_body=payload, token=self.token)
        exito = status in (200, 201)
        ticket_id = None
        if exito and isinstance(resp, dict):
            datos = resp.get("datos") or resp.get("data") or {}
            ticket_id = datos.get("id") or datos.get("Id") or datos.get("Id_Tkt")
        verificacion = ""
        if ticket_id:
            row = self.db_query_one("SELECT Id_Tkt, Contenido, Id_Prioridad, Id_Departamento FROM tkt WHERE Id_Tkt=%s", (ticket_id,))
            if row and row.get("Contenido") == contenido:
                verificacion = f"tkt.Id_Tkt={ticket_id} coincide"
            else:
                verificacion = "No se encontró el ticket en BD"
        self.add_result(TestResult(
            nombre="Crear ticket",
            metodo="POST",
            endpoint="/Tickets",
            esperado=201,
            obtenido=status,
            exito=exito,
            detalle=str(resp)[:300],
            verificacion_bd=verificacion or None,
            extra={"ticket_id": ticket_id, "contenido": contenido},
        ))
        return ticket_id, contenido

    def test_get_ticket(self, ticket_id):
        status, resp = self.request("GET", f"/Tickets/{ticket_id}", token=self.token)
        exito = status == 200 and isinstance(resp, dict) and (resp.get("datos") or resp.get("data"))
        datos = resp.get("datos") if isinstance(resp, dict) else None
        self.add_result(TestResult(
            nombre="Obtener ticket",
            metodo="GET",
            endpoint=f"/Tickets/{ticket_id}",
            esperado=200,
            obtenido=status,
            exito=exito,
            detalle=str(resp)[:300],
            extra={"datos": datos} if datos else None,
        ))

    def test_busqueda_avanzada(self, contenido_match):
        params = f"?Busqueda={requests.utils.quote(contenido_match)}&BuscarEnContenido=true&BuscarEnComentarios=true"
        status, resp = self.request("GET", f"/Tickets/buscar{params}", token=self.token)
        exito = status == 200 and isinstance(resp, dict)
        total = None
        if exito:
            datos = resp.get("datos") or resp.get("data")
            total = datos.get("totalRegistros") if isinstance(datos, dict) else None
            exito = total is not None and total >= 1
        self.add_result(TestResult(
            nombre="Búsqueda avanzada",
            metodo="GET",
            endpoint=f"/Tickets/buscar{params}",
            esperado=200,
            obtenido=status,
            exito=exito,
            detalle=str(resp)[:300],
            extra={"total": total},
        ))

    def test_crear_comentario(self, ticket_id):
        texto = f"Comentario integ {int(time.time())}"
        payload = {"Contenido": texto, "Privado": False}
        status, resp = self.request("POST", f"/Tickets/{ticket_id}/Comments", json_body=payload, token=self.token)
        exito = status in (200, 201)
        comentario_id = None
        if exito and isinstance(resp, dict):
            datos = resp.get("datos") or resp.get("data") or {}
            comentario_id = datos.get("id_comentario") or datos.get("Id_Comentario")
        verificacion = None
        if comentario_id:
            row = self.db_query_one("SELECT Id_Comentario, Contenido FROM tkt_comentario WHERE Id_Comentario=%s", (comentario_id,))
            if row and row.get("Contenido") == texto:
                verificacion = f"tkt_comentario.Id_Comentario={comentario_id} coincide"
        self.add_result(TestResult(
            nombre="Crear comentario",
            metodo="POST",
            endpoint=f"/Tickets/{ticket_id}/Comments",
            esperado=201,
            obtenido=status,
            exito=exito,
            detalle=str(resp)[:300],
            verificacion_bd=verificacion,
            extra={"comentario_id": comentario_id},
        ))
        return comentario_id

    def test_listar_comentarios(self, ticket_id):
        status, resp = self.request("GET", f"/Tickets/{ticket_id}/Comments", token=self.token)
        exito = status == 200 and isinstance(resp, dict)
        total = len(resp.get("datos") or resp.get("data") or []) if exito else None
        self.add_result(TestResult(
            nombre="Listar comentarios",
            metodo="GET",
            endpoint=f"/Tickets/{ticket_id}/Comments",
            esperado=200,
            obtenido=status,
            exito=exito,
            detalle=str(resp)[:300],
            extra={"total": total},
        ))

    def test_historial(self, ticket_id):
        status, resp = self.request("GET", f"/Tickets/{ticket_id}/historial", token=self.token)
        exito = status == 200
        total = None
        if exito and isinstance(resp, dict):
            datos = resp.get("datos") or resp.get("data")
            if isinstance(datos, list):
                total = len(datos)
        self.add_result(TestResult(
            nombre="Historial ticket",
            metodo="GET",
            endpoint=f"/Tickets/{ticket_id}/historial",
            esperado=200,
            obtenido=status,
            exito=exito,
            detalle=str(resp)[:300],
            extra={"total": total},
        ))

    # ---------- Orquestador ----------
    def run(self):
        print(f"API: {API_BASE_URL}")
        print(f"BD: {DB_CONFIG['host']}:{DB_CONFIG['port']} / {DB_CONFIG['database']}")
        print("Iniciando suite de integración...\n")

        if not self.login():
            return False

        refs = self.fetch_reference_ids()
        ticket_id, contenido = self.test_crear_ticket(refs)
        if ticket_id:
            self.test_get_ticket(ticket_id)
            self.test_busqueda_avanzada(contenido.split()[0])
            self.test_crear_comentario(ticket_id)
            self.test_listar_comentarios(ticket_id)
            self.test_historial(ticket_id)
        else:
            print("⚠️  No se pudo crear ticket; se omiten pruebas dependientes")

        self.save_results()
        self.print_summary()
        return True

    def save_results(self):
        data = [asdict(r) for r in self.results]
        with open(RESULTS_FILE, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        print(f"\n📄 Resultados guardados en {RESULTS_FILE}")

    def print_summary(self):
        total = len(self.results)
        passed = sum(1 for r in self.results if r.exito)
        failed = total - passed
        print("\n===== RESUMEN =====")
        print(f"Pruebas exitosas: {passed}/{total}")
        print(f"Pruebas fallidas: {failed}/{total}")
        if failed:
            print("Fallidas:")
            for r in self.results:
                if not r.exito:
                    print(f" - {r.nombre}: {r.detalle}")


if __name__ == "__main__":  # pragma: no cover - ejecución directa
    suite = IntegrationSuite()
    ok = suite.run()
    sys.exit(0 if ok else 1)
