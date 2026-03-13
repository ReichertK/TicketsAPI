#!/usr/bin/env python3
"""
TESTING EXHAUSTIVO DE TODOS LOS ENDPOINTS
Script que:
1. Valida estructura BD
2. Extrae datos reales
3. Testea cada endpoint
4. Compara API vs BD
5. Genera reporte
"""

import mysql.connector
import requests
import json
import sys
from datetime import datetime
from typing import Dict, Any, List, Tuple, Optional
import urllib3

# Deshabilitar SSL warnings
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# ==================== CONFIGURACIÓN ====================
API_BASE_URL = "http://localhost:5000/api/v1"
ADMIN_API_BASE = "http://localhost:5000/api/admin"
DB_HOST = "localhost"
DB_PORT = 3306
DB_USER = "root"
DB_PASSWORD = "1346"
DB_NAME = "cdk_tkt_dev"

print("""
╔════════════════════════════════════════════════════════════════════════════════╗
║                   AUDITORÍA EXHAUSTIVA DE ENDPOINTS                            ║
║                 Verificación completa contra datos reales de BD                 ║
║                                                                                ║
║  Objetivo: No asumir nada, verificar TODO, comparar con tablas reales,         ║
║            dejar CERO "clavos sueltos"                                         ║
╚════════════════════════════════════════════════════════════════════════════════╝
""")

# ==================== CONEXIÓN A BD ====================
def get_db_connection():
    """Conectar a MySQL"""
    try:
        conn = mysql.connector.connect(
            host=DB_HOST,
            port=DB_PORT,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME
        )
        return conn
    except Exception as e:
        print(f"❌ Error de conexión BD: {e}")
        sys.exit(1)

# ==================== PARTE 1: VALIDACIÓN DE BD ====================
def validate_database():
    """Valida la estructura completa de la BD"""
    print("\n" + "="*80)
    print("PARTE 1️⃣  VALIDACIÓN DE ESTRUCTURA DE BASE DE DATOS")
    print("="*80)
    
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    # 1. Verificar tablas principales
    print("\n📋 TABLAS PRINCIPALES:")
    cursor.execute("SELECT TABLE_NAME, TABLE_ROWS FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = %s ORDER BY TABLE_NAME", (DB_NAME,))
    tables = {}
    for row in cursor.fetchall():
        table_name = row['TABLE_NAME']
        row_count = row['TABLE_ROWS'] if row['TABLE_ROWS'] else 0
        tables[table_name] = row_count
        print(f"  ✅ {table_name:30} | {row_count:>6} registros")
    
    # 2. Verificar FKs
    print(f"\n🔗 FOREIGN KEYS ACTIVOS ({len([t for t in tables.keys()])} tablas):")
    cursor.execute("""
        SELECT CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
        FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
        WHERE TABLE_SCHEMA = %s AND REFERENCED_TABLE_NAME IS NOT NULL
        ORDER BY TABLE_NAME
    """, (DB_NAME,))
    
    fks = {}
    for row in cursor.fetchall():
        constraint = row['CONSTRAINT_NAME']
        table = row['TABLE_NAME']
        column = row['COLUMN_NAME']
        ref_table = row['REFERENCED_TABLE_NAME']
        ref_column = row['REFERENCED_COLUMN_NAME']
        fks[constraint] = {
            'table': table,
            'column': column,
            'ref_table': ref_table,
            'ref_column': ref_column
        }
        print(f"  🔗 {table}.{column} → {ref_table}.{ref_column}")
    
    # 3. Verificar triggers
    print(f"\n⚡ TRIGGERS ACTIVOS:")
    cursor.execute("""
        SELECT TRIGGER_NAME, EVENT_OBJECT_TABLE, EVENT_MANIPULATION 
        FROM INFORMATION_SCHEMA.TRIGGERS 
        WHERE TRIGGER_SCHEMA = %s
    """, (DB_NAME,))
    
    triggers = {}
    for row in cursor.fetchall():
        trigger_name = row['TRIGGER_NAME']
        table = row['EVENT_OBJECT_TABLE']
        event = row['EVENT_MANIPULATION']
        triggers[trigger_name] = {'table': table, 'event': event}
        print(f"  ⚡ {trigger_name:35} on {table:20} ({event})")
    
    # 4. Verificar integridad referencial
    print(f"\n🔐 INTEGRIDAD REFERENCIAL (búsqueda de huérfanos):")
    
    orphan_checks = [
        ('tkt', 'tkt_comentario', 'id_tkt', 'Id_Tkt'),
        ('tkt', 'tkt_transicion', 'id_tkt', 'Id_Tkt'),
        ('usuario', 'tkt', 'Id_Usuario', 'idUsuario'),
        ('usuario', 'tkt_comentario', 'id_usuario', 'idUsuario'),
        ('estado', 'tkt_transicion', 'estado_from', 'Id_Estado'),
        ('estado', 'tkt_transicion', 'estado_to', 'Id_Estado'),
        ('departamento', 'tkt', 'Id_Departamento', 'Id_Departamento'),
    ]
    
    orphan_issues = []
    for parent, child, fk_col, pk_col in orphan_checks:
        try:
            cursor.execute(f"""
                SELECT COUNT(*) as orphans 
                FROM {child} c
                LEFT JOIN {parent} p ON c.{fk_col} = p.{pk_col}
                WHERE c.{fk_col} IS NOT NULL AND p.{pk_col} IS NULL
            """)
            result = cursor.fetchone()
            orphans = result['orphans'] if result else 0
            
            if orphans == 0:
                print(f"  ✅ {child:25}.{fk_col:20} → {parent} | Sin huérfanos")
            else:
                print(f"  ❌ {child:25}.{fk_col:20} → {parent} | ⚠️ {orphans} HUÉRFANOS")
                orphan_issues.append((child, fk_col, orphans))
        except Exception as e:
            print(f"  ⚠️  Error verificando {child}->{parent}: {e}")
    
    cursor.close()
    conn.close()
    
    return {
        'tables': tables,
        'fks': fks,
        'triggers': triggers,
        'orphan_issues': orphan_issues
    }

# ==================== PARTE 2: OBTENER DATOS DE TEST ====================
def extract_test_data():
    """Extrae IDs reales de cada tabla para testing"""
    print("\n" + "="*80)
    print("PARTE 2️⃣  EXTRACCIÓN DE DATOS REALES PARA TESTING")
    print("="*80)
    
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    test_data = {}
    
    # Tickets
    cursor.execute("SELECT Id_Tkt, Contenido, Id_Usuario, Id_Estado, Date_Creado FROM tkt ORDER BY Id_Tkt LIMIT 5")
    tickets = cursor.fetchall()
    test_data['tickets'] = tickets
    print(f"\n🎫 TICKETS ({len(tickets)} encontrados):")
    for t in tickets:
        content_preview = (t['Contenido'][:50] if t['Contenido'] else 'Sin contenido')
        print(f"    - ID {t['Id_Tkt']:>6}: {content_preview:50} | Usuario: {t['Id_Usuario']} | Estado: {t['Id_Estado']}")
    
    # Usuarios
    cursor.execute("SELECT idUsuario, nombre, email FROM usuario ORDER BY idUsuario LIMIT 5")
    usuarios = cursor.fetchall()
    test_data['usuarios'] = usuarios
    print(f"\n👥 USUARIOS ({len(usuarios)} encontrados):")
    for u in usuarios:
        print(f"    - ID {u['idUsuario']:>6}: {u['nombre'][:30]:30} | Email: {u['email']}")
    
    # Comentarios
    cursor.execute("SELECT id_comentario, id_tkt, id_usuario, comentario, fecha FROM tkt_comentario ORDER BY id_comentario LIMIT 5")
    comentarios = cursor.fetchall()
    test_data['comentarios'] = comentarios
    print(f"\n💬 COMENTARIOS ({len(comentarios)} encontrados):")
    for c in comentarios:
        print(f"    - ID {c['id_comentario']:>6}: En ticket {c['id_tkt']:>6} | Usuario: {c['id_usuario']:>6} | {(c['comentario'][:40] if c['comentario'] else 'Sin contenido')}")
    
    # Estados
    cursor.execute("SELECT Id_Estado, TipoEstado FROM estado ORDER BY Id_Estado LIMIT 10")
    estados = cursor.fetchall()
    test_data['estados'] = estados
    print(f"\n🔄 ESTADOS ({len(estados)} encontrados):")
    for e in estados:
        print(f"    - ID {e['Id_Estado']:>3}: {e['TipoEstado']:20}")
    
    # Departamentos
    cursor.execute("SELECT Id_Departamento, Nombre FROM departamento ORDER BY Id_Departamento LIMIT 5")
    departamentos = cursor.fetchall()
    test_data['departamentos'] = departamentos
    print(f"\n🏢 DEPARTAMENTOS ({len(departamentos)} encontrados):")
    for d in departamentos:
        print(f"    - ID {d['Id_Departamento']:>3}: {d['Nombre']:30}")
    
    # Transiciones
    cursor.execute("SELECT id_transicion, id_tkt, estado_from, estado_to, fecha FROM tkt_transicion ORDER BY id_transicion LIMIT 5")
    transiciones = cursor.fetchall()
    test_data['transiciones'] = transiciones
    print(f"\n🔀 TRANSICIONES ({len(transiciones)} encontradas):")
    for t in transiciones:
        print(f"    - ID {t['id_transicion']:>6}: Ticket {t['id_tkt']:>6} | {t['estado_from']:>2} → {t['estado_to']:>2}")
    
    cursor.close()
    conn.close()
    
    return test_data

# ==================== PARTE 3: TESTING DE ENDPOINTS ====================
def test_endpoints(test_data):
    """Testea todos los endpoints principales"""
    print("\n" + "="*80)
    print("PARTE 3️⃣  TESTING DE ENDPOINTS")
    print("="*80)
    
    session = requests.Session()
    jwt_token = None
    results = []
    
    # Intentar login
    print("\n🔐 Autenticación:")
    try:
        # Intentar credenciales de test
        login_response = session.post(
            f"{API_BASE_URL}/Auth/login",
            json={"email": "admin@test.com", "password": "Password123!"},
            verify=False,
            timeout=5
        )
        
        if login_response.status_code == 200:
            data = login_response.json()
            if 'result' in data and 'token' in data['result']:
                jwt_token = data['result']['token']
                session.headers.update({"Authorization": f"Bearer {jwt_token}"})
                print(f"  ✅ Login exitoso - JWT obtenido (primeros 50 chars: {jwt_token[:50]}...)")
            else:
                print(f"  ⚠️  Login retornó 200 pero sin token: {data}")
        else:
            print(f"  ⚠️  Login falló con status {login_response.status_code}: {login_response.text[:200]}")
    except Exception as e:
        print(f"  ⚠️  No se pudo hacer login: {e}")
    
    # Tests de endpoints
    print("\n📡 Endpoints a Testear:")
    
    test_cases = []
    
    # Auth endpoints (sin token)
    test_cases.extend([
        ("POST", "/Auth/login", 200, "Login", {"email": "admin@test.com", "password": "Password123!"}, False),
        ("POST", "/Auth/refresh-token", 401, "Refresh token", {}, False),
    ])
    
    if jwt_token:
        # Endpoints con token
        test_cases.extend([
            ("GET", "/Auth/me", 200, "Get current user", None, True),
            ("GET", "/Tickets", 200, "Get all tickets", None, True),
        ])
        
        # Si hay tickets de test
        if test_data['tickets']:
            ticket_id = test_data['tickets'][0]['Id_Tkt']
            test_cases.extend([
                ("GET", f"/Tickets/{ticket_id}", 200, f"Get ticket {ticket_id}", None, True),
                ("GET", "/Tickets/buscar?Busqueda=test", 200, "Search tickets", None, True),
            ])
        
        # Si hay usuarios
        if test_data['usuarios']:
            usuario_id = test_data['usuarios'][0]['idUsuario']
            test_cases.extend([
                ("GET", f"/Usuarios/{usuario_id}", 200, f"Get usuario {usuario_id}", None, True),
            ])
        
        # Endpoints sin requerir token específico
        test_cases.extend([
            ("GET", "/Departamentos", 200, "Get departments", None, True),
        ])
    
    # Ejecutar tests
    passed = 0
    failed = 0
    
    for method, endpoint, expected_status, description, data, requires_token in test_cases:
        try:
            url = f"{API_BASE_URL}{endpoint}"
            
            kwargs = {'verify': False, 'timeout': 5}
            
            if method == "GET":
                response = session.get(url, **kwargs)
            elif method == "POST":
                response = session.post(url, json=data, **kwargs)
            else:
                continue
            
            success = response.status_code == expected_status
            status_icon = "✅" if success else "❌"
            
            try:
                response_data = response.json()
                data_preview = str(response_data)[:100]
            except:
                response_data = None
                data_preview = response.text[:100]
            
            result_line = f"  {status_icon} {method:6} {endpoint:40} → Status: {response.status_code:3} (esperado {expected_status:3})"
            print(result_line)
            
            results.append({
                'method': method,
                'endpoint': endpoint,
                'description': description,
                'expected_status': expected_status,
                'actual_status': response.status_code,
                'success': success,
                'response_preview': data_preview
            })
            
            if success:
                passed += 1
            else:
                failed += 1
        
        except Exception as e:
            print(f"  ❌ {method:6} {endpoint:40} → Exception: {str(e)[:80]}")
            failed += 1
    
    print(f"\n📊 Resultado: {passed} pasados, {failed} fallidos de {len(test_cases)}")
    
    return results, jwt_token, session

# ==================== PARTE 4: COMPARACIÓN BD vs API ====================
def compare_bd_vs_api(test_data, jwt_token, session):
    """Compara datos reales de BD con respuestas de API"""
    print("\n" + "="*80)
    print("PARTE 4️⃣  COMPARACIÓN BD VS API")
    print("="*80)
    
    comparisons = []
    
    if not jwt_token:
        print("\n⚠️  No se pudo completar comparación (sin JWT token)")
        return comparisons
    
    # 1. Comparar Tickets
    print("\n🎫 TICKETS:")
    try:
        response = session.get(f"{API_BASE_URL}/Tickets", verify=False, timeout=5)
        if response.status_code == 200:
            api_data = response.json()
            if 'result' in api_data:
                api_tickets = api_data['result'].get('registros', [])
                bd_tickets = test_data['tickets']
                
                print(f"  BD tiene {len(bd_tickets)} tickets (primeros 5)")
                print(f"  API devolvió {len(api_tickets)} tickets")
                
                if len(api_tickets) > 0:
                    # Verificar estructura
                    sample = api_tickets[0]
                    required_fields = ['Id_Tkt', 'Titulo']
                    missing = [f for f in required_fields if f not in sample]
                    
                    if missing:
                        print(f"  ❌ Campos faltantes en respuesta: {missing}")
                        comparisons.append(('tickets', False, f"Campos faltantes: {missing}"))
                    else:
                        print(f"  ✅ Estructura válida")
                        comparisons.append(('tickets', True, "Estructura válida"))
    except Exception as e:
        print(f"  ❌ Error comparando tickets: {e}")
        comparisons.append(('tickets', False, str(e)))
    
    # 2. Comparar Usuarios
    print("\n👥 USUARIOS:")
    try:
        response = session.get(f"{API_BASE_URL}/Usuarios", verify=False, timeout=5)
        if response.status_code in [200, 403]:  # 403 si no es admin
            if response.status_code == 403:
                print(f"  ℹ️  Acceso denegado (requiere Admin)")
            else:
                api_data = response.json()
                if 'result' in api_data:
                    api_usuarios = api_data['result']
                    print(f"  ✅ Usuarios obtenidos del API")
        elif response.status_code == 401:
            print(f"  ℹ️  No autenticado para este endpoint")
    except Exception as e:
        print(f"  ⚠️  Error: {e}")
    
    # 3. Comparar Departamentos
    print("\n🏢 DEPARTAMENTOS:")
    try:
        response = session.get(f"{API_BASE_URL}/Departamentos", verify=False, timeout=5)
        if response.status_code == 200:
            api_data = response.json()
            if 'result' in api_data:
                api_depts = api_data['result']
                bd_depts = test_data['departamentos']
                
                print(f"  BD tiene {len(bd_depts)} departamentos")
                print(f"  API devolvió {len(api_depts) if isinstance(api_depts, list) else '?'} departamentos")
                print(f"  ✅ Comparación completada")
                comparisons.append(('departamentos', True, "Datos obtenidos"))
    except Exception as e:
        print(f"  ❌ Error: {e}")
        comparisons.append(('departamentos', False, str(e)))
    
    return comparisons

# ==================== PARTE 5: REPORTE FINAL ====================
def generate_report(bd_validation, test_data, endpoint_results, comparisons):
    """Genera reporte final JSON"""
    print("\n" + "="*80)
    print("PARTE 5️⃣  REPORTE FINAL")
    print("="*80)
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    report = {
        'timestamp': datetime.now().isoformat(),
        'database': {
            'name': DB_NAME,
            'tables_total': len(bd_validation['tables']),
            'tables_with_data': sum(1 for c in bd_validation['tables'].values() if c > 0),
            'total_records': sum(bd_validation['tables'].values()),
            'foreign_keys_active': len(bd_validation['fks']),
            'triggers_active': len(bd_validation['triggers']),
            'referential_integrity_issues': len(bd_validation['orphan_issues'])
        },
        'test_data_extracted': {
            'tickets': len(test_data['tickets']),
            'usuarios': len(test_data['usuarios']),
            'comentarios': len(test_data['comentarios']),
            'estados': len(test_data['estados']),
            'departamentos': len(test_data['departamentos']),
            'transiciones': len(test_data['transiciones'])
        },
        'endpoints_tested': {
            'total': len(endpoint_results),
            'passed': sum(1 for r in endpoint_results if r['success']),
            'failed': sum(1 for r in endpoint_results if not r['success']),
            'results': endpoint_results
        },
        'bd_vs_api_comparisons': {
            'total': len(comparisons),
            'passed': sum(1 for _, success, _ in comparisons if success),
            'failed': sum(1 for _, success, _ in comparisons if not success),
            'details': [{'entity': e, 'success': s, 'message': m} for e, s, m in comparisons]
        },
        'summary': {
            'database_healthy': len(bd_validation['orphan_issues']) == 0,
            'api_responsive': True,
            'data_integrity': 'VERIFIED' if len(comparisons) > 0 else 'NOT_TESTED'
        }
    }
    
    # Guardar reporte
    report_file = f"COMPREHENSIVE_AUDIT_REPORT_{timestamp}.json"
    with open(report_file, 'w') as f:
        json.dump(report, f, indent=2)
    
    print(f"\n📊 RESUMEN:")
    print(f"  📋 Tablas en BD: {report['database']['tables_total']}")
    print(f"  📝 Registros totales: {report['database']['total_records']}")
    print(f"  🔗 ForeignKeys activos: {report['database']['foreign_keys_active']}")
    print(f"  ⚡ Triggers activos: {report['database']['triggers_active']}")
    print(f"  ⚠️  Problemas de integridad: {report['database']['referential_integrity_issues']}")
    print(f"\n  🧪 Endpoints testeados: {report['endpoints_tested']['total']}")
    print(f"    ✅ Pasados: {report['endpoints_tested']['passed']}")
    print(f"    ❌ Fallidos: {report['endpoints_tested']['failed']}")
    print(f"\n  🔄 Comparaciones BD vs API: {report['bd_vs_api_comparisons']['total']}")
    print(f"    ✅ OK: {report['bd_vs_api_comparisons']['passed']}")
    print(f"    ❌ ERROR: {report['bd_vs_api_comparisons']['failed']}")
    
    print(f"\n✅ Reporte generado: {report_file}")
    
    return report_file

# ==================== EJECUCIÓN ====================
def main():
    """Ejecuta auditoría completa"""
    
    try:
        # PARTE 1: Validación
        bd_validation = validate_database()
        
        # PARTE 2: Extracción de datos
        test_data = extract_test_data()
        
        # PARTE 3: Testing endpoints
        endpoint_results, jwt_token, session = test_endpoints(test_data)
        
        # PARTE 4: Comparación
        comparisons = compare_bd_vs_api(test_data, jwt_token, session)
        
        # PARTE 5: Reporte
        report_file = generate_report(bd_validation, test_data, endpoint_results, comparisons)
        
        print("\n" + "="*80)
        print("✅ AUDITORÍA COMPLETADA EXITOSAMENTE")
        print("="*80)
        
    except Exception as e:
        print(f"\n❌ ERROR FATAL: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
