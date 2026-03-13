#!/usr/bin/env python3
"""
Script de Testing Exhaustivo - TicketsAPI
Realiza pruebas de todos los endpoints como usuario Admin
"""

import requests
import json
from datetime import datetime
from typing import Dict, Any, Optional
import time

# Configuración
API_BASE_URL = "https://localhost:5001/api/v1"
ADMIN_USER = "Admin"
ADMIN_PASSWORD = "changeme"

# Variables globales para almacenar datos de prueba
test_results = []
auth_token = None
current_usuario_id = None

class TestRunner:
    def __init__(self):
        self.session = requests.Session()
        self.session.verify = False  # Para SSL sin verificar (local)
        self.results = []
        
    def log_test(self, endpoint: str, method: str, status: int, success: bool, message: str, response_data: Optional[Dict] = None):
        """Registra resultado de una prueba"""
        result = {
            "timestamp": datetime.now().isoformat(),
            "endpoint": endpoint,
            "method": method,
            "status": status,
            "success": success,
            "message": message,
            "response_data": response_data
        }
        self.results.append(result)
        status_icon = "✅" if success else "❌"
        print(f"{status_icon} [{method}] {endpoint} - {status} - {message}")
        
    def save_results(self):
        """Guarda resultados en archivo JSON"""
        filename = f"TEST_RESULTS_ADMIN_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(self.results, f, indent=2, ensure_ascii=False)
        print(f"\n📊 Resultados guardados en: {filename}")
        return filename

def login() -> Optional[str]:
    """Realiza login como Admin y obtiene token"""
    global auth_token, current_usuario_id
    
    print("\n" + "="*60)
    print("🔐 AUTENTICACIÓN")
    print("="*60)
    
    runner = TestRunner()
    url = f"{API_BASE_URL}/Auth/login"
    payload = {
        "usuario": ADMIN_USER,
        "contraseña": ADMIN_PASSWORD
    }
    
    try:
        response = runner.session.post(url, json=payload, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            if data.get("exitoso"):
                token = data["datos"]["token"]
                current_usuario_id = data["datos"]["id_Usuario"]
                auth_token = token
                runner.log_test("/Auth/login", "POST", 200, True, 
                               f"Login exitoso - Usuario ID: {current_usuario_id}")
                print(f"   Token: {token[:50]}...\n")
                return token
            else:
                runner.log_test("/Auth/login", "POST", 200, False, 
                               data.get("mensaje", "Error desconocido"))
        else:
            runner.log_test("/Auth/login", "POST", response.status_code, False, 
                           f"Error HTTP {response.status_code}")
    except Exception as e:
        runner.log_test("/Auth/login", "POST", 0, False, f"Error: {str(e)}")
    
    return None

def test_tickets(runner: TestRunner, token: str):
    """Prueba endpoints de tickets"""
    print("\n" + "="*60)
    print("🎫 TESTING TICKETS")
    print("="*60)
    
    headers = {"Authorization": f"Bearer {token}"}
    created_ticket_id = None
    
    # 1. GET - Listar tickets
    print("\n[1] GET /Tickets - Listar todos los tickets")
    try:
        response = runner.session.get(f"{API_BASE_URL}/Tickets", headers=headers, timeout=10)
        success = response.status_code == 200
        runner.log_test("/Tickets", "GET", response.status_code, success, 
                       "Listado de tickets obtenido" if success else response.text[:100])
        if success:
            data = response.json()
            total = data["datos"]["totalRegistros"]
            print(f"   Total de tickets: {total}")
    except Exception as e:
        runner.log_test("/Tickets", "GET", 0, False, f"Error: {str(e)}")
    
    # 2. POST - Crear ticket
    print("\n[2] POST /Tickets - Crear nuevo ticket")
    ticket_payload = {
        "contenido": f"Test ticket Admin - {datetime.now().isoformat()}",
        "id_Prioridad": 1,
        "id_Departamento": 1,
        "id_Usuario_Asignado": 2,
        "id_Motivo": 1
    }
    try:
        response = runner.session.post(f"{API_BASE_URL}/Tickets", 
                                       headers=headers, json=ticket_payload, timeout=10)
        success = response.status_code == 201
        if success:
            data = response.json()
            created_ticket_id = data["datos"]["id"]
            runner.log_test("/Tickets", "POST", 201, True, 
                           f"Ticket creado - ID: {created_ticket_id}")
            print(f"   ID del ticket creado: {created_ticket_id}")
        else:
            runner.log_test("/Tickets", "POST", response.status_code, False, response.text[:200])
    except Exception as e:
        runner.log_test("/Tickets", "POST", 0, False, f"Error: {str(e)}")
    
    # 3. GET - Obtener un ticket por ID
    if created_ticket_id:
        print(f"\n[3] GET /Tickets/{{id}} - Obtener ticket ID {created_ticket_id}")
        try:
            response = runner.session.get(f"{API_BASE_URL}/Tickets/{created_ticket_id}", 
                                         headers=headers, timeout=10)
            success = response.status_code == 200
            runner.log_test(f"/Tickets/{created_ticket_id}", "GET", response.status_code, success,
                           "Ticket obtenido" if success else response.text[:100])
        except Exception as e:
            runner.log_test(f"/Tickets/{created_ticket_id}", "GET", 0, False, f"Error: {str(e)}")
    
    # 4. PUT - Actualizar ticket
    if created_ticket_id:
        print(f"\n[4] PUT /Tickets/{{id}} - Actualizar ticket ID {created_ticket_id}")
        update_payload = {
            "contenido": f"Test ticket ACTUALIZADO - {datetime.now().isoformat()}",
            "id_Prioridad": 2,
            "id_Departamento": 1,
            "id_Usuario_Asignado": 3,
            "id_Motivo": 1
        }
        try:
            response = runner.session.put(f"{API_BASE_URL}/Tickets/{created_ticket_id}", 
                                         headers=headers, json=update_payload, timeout=10)
            success = response.status_code == 200
            runner.log_test(f"/Tickets/{created_ticket_id}", "PUT", response.status_code, success,
                           "Ticket actualizado" if success else response.text[:200])
        except Exception as e:
            runner.log_test(f"/Tickets/{created_ticket_id}", "PUT", 0, False, f"Error: {str(e)}")
    
    # 5. PATCH - Cambiar estado
    if created_ticket_id:
        print(f"\n[5] PATCH /Tickets/{{id}}/cambiar-estado - Cambiar estado")
        state_payload = {
            "id_Estado_Nuevo": 2,
            "comentario": f"Test cambio de estado - {datetime.now().isoformat()}"
        }
        try:
            response = runner.session.patch(f"{API_BASE_URL}/Tickets/{created_ticket_id}/cambiar-estado", 
                                           headers=headers, json=state_payload, timeout=10)
            success = response.status_code == 200
            runner.log_test(f"/Tickets/{created_ticket_id}/cambiar-estado", "PATCH", response.status_code, success,
                           "Estado cambiado" if success else response.text[:200])
        except Exception as e:
            runner.log_test(f"/Tickets/{created_ticket_id}/cambiar-estado", "PATCH", 0, False, f"Error: {str(e)}")
    
    # 6. Búsqueda avanzada
    print("\n[6] GET /Tickets/buscar - Búsqueda avanzada")
    try:
        response = runner.session.get(f"{API_BASE_URL}/Tickets/buscar?Busqueda=Test&TipoBusqueda=contiene", 
                                     headers=headers, timeout=10)
        success = response.status_code == 200
        runner.log_test("/Tickets/buscar", "GET", response.status_code, success,
                       "Búsqueda realizada" if success else response.text[:100])
    except Exception as e:
        runner.log_test("/Tickets/buscar", "GET", 0, False, f"Error: {str(e)}")
    
    return created_ticket_id

def test_comentarios(runner: TestRunner, token: str, ticket_id: Optional[int]):
    """Prueba endpoints de comentarios"""
    print("\n" + "="*60)
    print("💬 TESTING COMENTARIOS")
    print("="*60)
    
    if not ticket_id:
        print("⚠️  No hay ticket_id para pruebas de comentarios")
        return None
    
    headers = {"Authorization": f"Bearer {token}"}
    created_comment_id = None
    
    # 1. POST - Crear comentario
    print(f"\n[1] POST /Tickets/{{id}}/Comentarios - Crear comentario en ticket {ticket_id}")
    comment_payload = {
        "comentario": f"Test comentario desde Admin - {datetime.now().isoformat()}"
    }
    try:
        response = runner.session.post(f"{API_BASE_URL}/Tickets/{ticket_id}/Comentarios", 
                                       headers=headers, json=comment_payload, timeout=10)
        success = response.status_code == 201
        if success:
            data = response.json()
            created_comment_id = data["datos"]["id"]
            runner.log_test(f"/Tickets/{ticket_id}/Comentarios", "POST", 201, True,
                           f"Comentario creado - ID: {created_comment_id}")
        else:
            runner.log_test(f"/Tickets/{ticket_id}/Comentarios", "POST", response.status_code, False,
                           response.text[:200])
    except Exception as e:
        runner.log_test(f"/Tickets/{ticket_id}/Comentarios", "POST", 0, False, f"Error: {str(e)}")
    
    # 2. GET - Listar comentarios del ticket
    print(f"\n[2] GET /Tickets/{{id}}/Comentarios - Listar comentarios")
    try:
        response = runner.session.get(f"{API_BASE_URL}/Tickets/{ticket_id}/Comentarios", 
                                     headers=headers, timeout=10)
        success = response.status_code == 200
        runner.log_test(f"/Tickets/{ticket_id}/Comentarios", "GET", response.status_code, success,
                       "Comentarios listados" if success else response.text[:100])
    except Exception as e:
        runner.log_test(f"/Tickets/{ticket_id}/Comentarios", "GET", 0, False, f"Error: {str(e)}")
    
    # 3. PUT - Actualizar comentario
    if created_comment_id:
        print(f"\n[3] PUT /Tickets/{{id}}/Comentarios/{{cid}} - Actualizar comentario")
        update_payload = {
            "comentario": f"Test comentario ACTUALIZADO - {datetime.now().isoformat()}"
        }
        try:
            response = runner.session.put(f"{API_BASE_URL}/Tickets/{ticket_id}/Comentarios/{created_comment_id}", 
                                         headers=headers, json=update_payload, timeout=10)
            success = response.status_code == 200
            runner.log_test(f"/Tickets/{ticket_id}/Comentarios/{created_comment_id}", "PUT", 
                           response.status_code, success,
                           "Comentario actualizado" if success else response.text[:200])
        except Exception as e:
            runner.log_test(f"/Tickets/{ticket_id}/Comentarios/{created_comment_id}", "PUT", 0, False, f"Error: {str(e)}")

def test_datos_referencia(runner: TestRunner, token: str):
    """Prueba endpoints de datos de referencia"""
    print("\n" + "="*60)
    print("📚 TESTING DATOS DE REFERENCIA")
    print("="*60)
    
    headers = {"Authorization": f"Bearer {token}"}
    endpoints = [
        ("/Estados", "Estados"),
        ("/Prioridades", "Prioridades"),
        ("/Departamentos", "Departamentos"),
        ("/Motivos", "Motivos"),
        ("/Grupos", "Grupos"),
        ("/Sucursales", "Sucursales"),
    ]
    
    for endpoint, name in endpoints:
        print(f"\n[GET] {endpoint} - Obtener {name}")
        try:
            response = runner.session.get(f"{API_BASE_URL}{endpoint}", headers=headers, timeout=10)
            success = response.status_code == 200
            if success:
                data = response.json()
                total = len(data.get("datos", []))
                runner.log_test(endpoint, "GET", 200, True, f"{name} obtenidos ({total} registros)")
            else:
                runner.log_test(endpoint, "GET", response.status_code, False, response.text[:100])
        except Exception as e:
            runner.log_test(endpoint, "GET", 0, False, f"Error: {str(e)}")

def test_usuarios(runner: TestRunner, token: str):
    """Prueba endpoints de usuarios"""
    print("\n" + "="*60)
    print("👥 TESTING USUARIOS")
    print("="*60)
    
    headers = {"Authorization": f"Bearer {token}"}
    
    # 1. GET - Listar usuarios
    print("\n[1] GET /Usuarios - Listar usuarios")
    try:
        response = runner.session.get(f"{API_BASE_URL}/Usuarios", headers=headers, timeout=10)
        success = response.status_code == 200
        runner.log_test("/Usuarios", "GET", response.status_code, success,
                       "Usuarios listados" if success else response.text[:100])
    except Exception as e:
        runner.log_test("/Usuarios", "GET", 0, False, f"Error: {str(e)}")
    
    # 2. GET - Obtener usuario actual
    print("\n[2] GET /Usuarios/perfil-actual - Obtener perfil actual")
    try:
        response = runner.session.get(f"{API_BASE_URL}/Usuarios/perfil-actual", headers=headers, timeout=10)
        success = response.status_code == 200
        runner.log_test("/Usuarios/perfil-actual", "GET", response.status_code, success,
                       "Perfil actual obtenido" if success else response.text[:100])
    except Exception as e:
        runner.log_test("/Usuarios/perfil-actual", "GET", 0, False, f"Error: {str(e)}")

def main():
    print("\n" + "="*60)
    print("🧪 TESTING EXHAUSTIVO TICKETSAPI - USUARIO ADMIN")
    print("="*60)
    print(f"Inicio: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    runner = TestRunner()
    
    # 1. Login
    token = login()
    if not token:
        print("❌ No se pudo obtener token de autenticación")
        return
    
    # 2. Pruebas de referencia
    test_datos_referencia(runner, token)
    
    # 3. Pruebas de usuarios
    test_usuarios(runner, token)
    
    # 4. Pruebas de tickets
    created_ticket_id = test_tickets(runner, token)
    
    # 5. Pruebas de comentarios
    test_comentarios(runner, token, created_ticket_id)
    
    # Guardar resultados
    runner.save_results()
    
    # Resumen
    print("\n" + "="*60)
    print("📊 RESUMEN DE PRUEBAS")
    print("="*60)
    total = len(runner.results)
    passed = len([r for r in runner.results if r["success"]])
    failed = total - passed
    
    print(f"Total de pruebas: {total}")
    print(f"✅ Exitosas: {passed}")
    print(f"❌ Fallidas: {failed}")
    print(f"Tasa de éxito: {(passed/total*100):.1f}%")
    print(f"\nFin: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

if __name__ == "__main__":
    main()
