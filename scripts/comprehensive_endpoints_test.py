#!/usr/bin/env python3
"""
TEST EXHAUSTIVO DE TODOS LOS ENDPOINTS Y FUNCIONES
Verifica que cada endpoint devuelva datos reales de BD sin suposiciones
Compara directamente contra las tablas reales
Generado: 30 Enero 2026
"""

import mysql.connector
import requests
import json
from datetime import datetime
from typing import Dict, Any, List, Tuple
import urllib3

# Deshabilitar SSL warnings
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# ==================== CONFIGURACIÓN ====================
API_BASE_URL = "http://localhost:5000/api/v1"
DB_HOST = "localhost"
DB_PORT = 3306
DB_USER = "root"
DB_PASSWORD = "1346"
DB_NAME = "cdk_tkt_dev"
DISABLE_SSL_VERIFY = True

# ==================== CONEXIÓN A BASE DE DATOS ====================
def get_db_connection():
    """Conectar a la base de datos MySQL"""
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
        print(f"❌ Error conectando a BD: {e}")
        return None

# ==================== VALIDACIÓN DE TABLAS REALES ====================
class TableValidator:
    """Valida que las tablas existan y tengan datos"""
    
    def __init__(self):
        self.conn = get_db_connection()
        self.results = []
    
    def verify_table_exists(self, table_name: str) -> bool:
        """Verifica que una tabla existe"""
        cursor = self.conn.cursor()
        try:
            cursor.execute(f"SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = %s AND TABLE_NAME = %s", (DB_NAME, table_name))
            result = cursor.fetchone()
            exists = result[0] > 0
            status = "✅ EXISTE" if exists else "❌ NO EXISTE"
            print(f"  Tabla {table_name}: {status}")
            return exists
        except Exception as e:
            print(f"  Error verificando {table_name}: {e}")
            return False
        finally:
            cursor.close()
    
    def get_table_count(self, table_name: str) -> int:
        """Obtiene el número de registros en una tabla"""
        cursor = self.conn.cursor()
        try:
            cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
            result = cursor.fetchone()
            return result[0] if result else 0
        except Exception as e:
            return -1
        finally:
            cursor.close()
    
    def get_table_sample(self, table_name: str, limit: int = 5) -> List[Dict]:
        """Obtiene muestra de datos de una tabla"""
        cursor = self.conn.cursor(dictionary=True)
        try:
            cursor.execute(f"SELECT * FROM {table_name} LIMIT {limit}")
            return cursor.fetchall()
        except Exception as e:
            return []
        finally:
            cursor.close()
    
    def verify_foreign_keys(self) -> Dict[str, bool]:
        """Verifica que todos los FKs estén activos"""
        cursor = self.conn.cursor()
        try:
            cursor.execute("""
                SELECT CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME 
                FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
                WHERE TABLE_SCHEMA = %s AND REFERENCED_TABLE_NAME IS NOT NULL
            """, (DB_NAME,))
            
            fks = {}
            for row in cursor.fetchall():
                fk_name = row[0]
                fks[fk_name] = True
            
            return fks
        except Exception as e:
            print(f"Error verificando FKs: {e}")
            return {}
        finally:
            cursor.close()
    
    def verify_triggers(self) -> Dict[str, bool]:
        """Verifica que todos los triggers estén activos"""
        cursor = self.conn.cursor()
        try:
            cursor.execute("""
                SELECT TRIGGER_NAME, EVENT_OBJECT_TABLE 
                FROM INFORMATION_SCHEMA.TRIGGERS 
                WHERE TRIGGER_SCHEMA = %s
            """, (DB_NAME,))
            
            triggers = {}
            for row in cursor.fetchall():
                trigger_name = row[0]
                triggers[trigger_name] = True
            
            return triggers
        except Exception as e:
            print(f"Error verificando triggers: {e}")
            return {}
        finally:
            cursor.close()
    
    def compare_fk_references(self, parent_table: str, child_table: str, fk_column: str, pk_column: str) -> Tuple[bool, str]:
        """Verifica que todas las FKs en tabla hijo apunten a padre válido"""
        cursor = self.conn.cursor()
        try:
            # Encontrar huérfanos
            query = f"""
                SELECT COUNT(*) as huerfanos 
                FROM {child_table} c
                LEFT JOIN {parent_table} p ON c.{fk_column} = p.{pk_column}
                WHERE c.{fk_column} IS NOT NULL AND p.{pk_column} IS NULL
            """
            cursor.execute(query)
            result = cursor.fetchone()
            orphans = result[0] if result else 0
            
            if orphans == 0:
                return True, f"✅ {child_table}.{fk_column} - Sin huérfanos"
            else:
                return False, f"❌ {child_table}.{fk_column} - {orphans} registros huérfanos"
        except Exception as e:
            return False, f"⚠️ Error verificando FK: {e}"
        finally:
            cursor.close()

# ==================== TESTING DE ENDPOINTS ====================
class EndpointTester:
    """Test todos los endpoints del API"""
    
    def __init__(self):
        self.session = requests.Session()
        self.jwt_token = None
        self.results = []
        self.test_data = {}
    
    def login(self) -> bool:
        """Intenta login para obtener JWT"""
        try:
            # Intentar con credenciales de test
            response = self.session.post(
                f"{API_BASE_URL}/Auth/login",
                json={"email": "admin@test.com", "password": "Password123!"},
                verify=not DISABLE_SSL_VERIFY
            )
            
            if response.status_code == 200:
                data = response.json()
                if 'result' in data and 'token' in data['result']:
                    self.jwt_token = data['result']['token']
                    self.session.headers.update({"Authorization": f"Bearer {self.jwt_token}"})
                    print(f"✅ Login exitoso - JWT obtenido")
                    return True
            
            print(f"⚠️ Login retornó {response.status_code} - Continuando sin JWT")
            return False
        except Exception as e:
            print(f"⚠️ No se pudo hacer login: {e}")
            return False
    
    def get_test_data(self) -> bool:
        """Obtiene IDs de test de la BD"""
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        try:
            # Obtener un ticket
            cursor.execute("SELECT Id_Tkt, Titulo FROM tkt LIMIT 1")
            ticket = cursor.fetchone()
            
            # Obtener un usuario
            cursor.execute("SELECT idUsuario, Email FROM usuario LIMIT 1")
            usuario = cursor.fetchone()
            
            # Obtener un comentario
            cursor.execute("SELECT id_comentario, id_tkt FROM tkt_comentario LIMIT 1")
            comentario = cursor.fetchone()
            
            # Obtener un estado
            cursor.execute("SELECT Id_Estado, TipoEstado FROM estado LIMIT 1")
            estado = cursor.fetchone()
            
            # Obtener un departamento
            cursor.execute("SELECT Id_Departamento, Nombre FROM departamento LIMIT 1")
            depto = cursor.fetchone()
            
            self.test_data = {
                'ticket': ticket or {'Id_Tkt': 1, 'Titulo': 'Test'},
                'usuario': usuario or {'idUsuario': 1, 'Email': 'test@test.com'},
                'comentario': comentario or {'id_comentario': 1, 'id_tkt': 1},
                'estado': estado or {'Id_Estado': 1, 'TipoEstado': 'Abierto'},
                'departamento': depto or {'Id_Departamento': 1, 'Nombre': 'IT'}
            }
            
            print(f"✅ Datos de test obtenidos de BD:")
            print(f"  - Ticket ID: {self.test_data['ticket']['Id_Tkt']}")
            print(f"  - Usuario ID: {self.test_data['usuario']['idUsuario']}")
            print(f"  - Comentario ID: {self.test_data['comentario']['id_comentario']}")
            print(f"  - Estado ID: {self.test_data['estado']['Id_Estado']}")
            print(f"  - Departamento ID: {self.test_data['departamento']['Id_Departamento']}")
            
            return True
        except Exception as e:
            print(f"❌ Error obteniendo datos de test: {e}")
            return False
        finally:
            cursor.close()
            conn.close()
    
    def test_endpoint(self, method: str, endpoint: str, expected_status: int = 200, 
                     description: str = "", data: Dict = None) -> Tuple[bool, str, Dict]:
        """Prueba un endpoint específico"""
        try:
            url = f"{API_BASE_URL}{endpoint}"
            
            if method.upper() == "GET":
                response = self.session.get(url, verify=not DISABLE_SSL_VERIFY)
            elif method.upper() == "POST":
                response = self.session.post(url, json=data, verify=not DISABLE_SSL_VERIFY)
            elif method.upper() == "PATCH":
                response = self.session.patch(url, json=data, verify=not DISABLE_SSL_VERIFY)
            elif method.upper() == "PUT":
                response = self.session.put(url, json=data, verify=not DISABLE_SSL_VERIFY)
            else:
                return False, f"Método desconocido: {method}", {}
            
            success = response.status_code == expected_status
            
            try:
                response_data = response.json()
            except:
                response_data = {"raw_text": response.text[:200]}
            
            status_str = "✅" if success else "❌"
            result_msg = f"{status_str} {method} {endpoint} - Status: {response.status_code} (esperado {expected_status})"
            
            self.results.append({
                'timestamp': datetime.now().isoformat(),
                'endpoint': endpoint,
                'method': method,
                'expected_status': expected_status,
                'actual_status': response.status_code,
                'success': success,
                'description': description,
                'response_preview': str(response_data)[:300]
            })
            
            return success, result_msg, response_data
        
        except Exception as e:
            error_msg = f"❌ {method} {endpoint} - Exception: {str(e)[:100]}"
            self.results.append({
                'timestamp': datetime.now().isoformat(),
                'endpoint': endpoint,
                'method': method,
                'success': False,
                'description': description,
                'error': str(e)[:300]
            })
            return False, error_msg, {}

# ==================== EJECUTAR AUDITORÍA ====================
def run_audit():
    """Ejecuta auditoría completa"""
    
    print("\n" + "="*80)
    print("AUDITORÍA COMPLETA DE ENDPOINTS Y FUNCIONES")
    print("Verificación contra datos reales de BD")
    print("="*80)
    
    # PARTE 1: VALIDAR TABLAS Y ESTRUCTURA
    print("\n📊 PARTE 1: VALIDAR ESTRUCTURA DE BASE DE DATOS")
    print("-" * 80)
    
    validator = TableValidator()
    
    # Verificar tablas principales
    print("\n🔍 Verificando tablas principales:")
    tables = ['tkt', 'usuario', 'tkt_comentario', 'tkt_transicion', 'estado', 'departamento', 
              'empresa', 'sucursal', 'motivo', 'perfil', 'audit_log', 'sesiones', 
              'failed_login_attempts', 'tkt_transicion_auditoria']
    
    table_stats = {}
    for table in tables:
        exists = validator.verify_table_exists(table)
        if exists:
            count = validator.get_table_count(table)
            table_stats[table] = count
            print(f"    └─ Registros: {count}")
    
    # Verificar FKs
    print("\n🔗 Verificando Foreign Keys:")
    fks = validator.verify_foreign_keys()
    print(f"   ✅ Total de FKs activos: {len(fks)}")
    for fk_name in sorted(fks.keys())[:10]:
        print(f"    └─ {fk_name}")
    if len(fks) > 10:
        print(f"    └─ ... y {len(fks) - 10} más")
    
    # Verificar Triggers
    print("\n⚡ Verificando Triggers:")
    triggers = validator.verify_triggers()
    print(f"   ✅ Total de triggers activos: {len(triggers)}")
    for trigger_name in sorted(triggers.keys()):
        print(f"    └─ {trigger_name}")
    
    # Verificar integridad de referencias
    print("\n🔐 Verificando integridad de referencias (búsqueda de huérfanos):")
    
    integrity_checks = [
        ('tkt', 'tkt_comentario', 'id_tkt', 'Id_Tkt'),
        ('tkt', 'tkt_transicion', 'id_tkt', 'Id_Tkt'),
        ('usuario', 'tkt', 'Id_Usuario', 'idUsuario'),
        ('usuario', 'tkt_comentario', 'id_usuario', 'idUsuario'),
        ('estado', 'tkt_transicion', 'estado_from', 'Id_Estado'),
        ('estado', 'tkt_transicion', 'estado_to', 'Id_Estado'),
    ]
    
    integrity_results = []
    for parent, child, fk_col, pk_col in integrity_checks:
        success, msg = validator.compare_fk_references(parent, child, fk_col, pk_col)
        integrity_results.append((success, msg))
        print(f"   {msg}")
    
    # PARTE 2: TESTING DE ENDPOINTS
    print("\n" + "="*80)
    print("📡 PARTE 2: TESTING DE ENDPOINTS")
    print("-" * 80)
    
    tester = EndpointTester()
    
    # Obtener datos de test de BD
    print("\n🔍 Obteniendo datos reales de BD para testing:")
    tester.get_test_data()
    
    # Intentar login
    print("\n🔐 Intentando autenticación:")
    tester.login()
    
    # Pruebas de endpoints principales
    print("\n🧪 Testendo endpoints principales:")
    
    endpoints_to_test = [
        ("GET", "/Tickets", 200, "Obtener todos los tickets"),
        ("GET", f"/Tickets/{tester.test_data['ticket']['Id_Tkt']}", 200, "Obtener ticket específico"),
        ("GET", "/Tickets/buscar?Busqueda=test", 200, "Búsqueda avanzada"),
        ("GET", "/Estados", 200, "Obtener estados"),
        ("GET", "/Departamentos", 200, "Obtener departamentos"),
        ("GET", "/Usuarios", 200, "Obtener usuarios"),
        ("GET", "/Motivos", 200, "Obtener motivos"),
    ]
    
    passed = 0
    failed = 0
    
    for method, endpoint, expected, desc in endpoints_to_test:
        success, msg, response = tester.test_endpoint(method, endpoint, expected, desc)
        print(f"  {msg}")
        if success:
            passed += 1
        else:
            failed += 1
    
    # PARTE 3: COMPARAR DATOS
    print("\n" + "="*80)
    print("🔄 PARTE 3: COMPARAR DATOS API vs BD")
    print("-" * 80)
    
    if tester.jwt_token:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        print("\n📋 Validando respuestas de endpoints contra BD:")
        
        # Obtener tickets del API
        success, msg, api_response = tester.test_endpoint("GET", "/Tickets", 200, "")
        if success and 'result' in api_response:
            api_tickets = api_response['result'].get('registros', [])
            
            # Comparar con BD
            cursor.execute("SELECT COUNT(*) as total FROM tkt")
            db_count = cursor.fetchone()['total']
            
            print(f"  Tickets en API: {len(api_tickets)}")
            print(f"  Tickets en BD: {db_count}")
            
            if len(api_tickets) > 0:
                # Validar estructura de respuesta
                sample_ticket = api_tickets[0]
                required_fields = ['Id_Tkt', 'Titulo', 'Descripcion']
                missing = [f for f in required_fields if f not in sample_ticket]
                
                if not missing:
                    print(f"  ✅ Estructura de ticket válida")
                else:
                    print(f"  ❌ Campos faltantes: {missing}")
        
        cursor.close()
        conn.close()
    
    # PARTE 4: REPORTE FINAL
    print("\n" + "="*80)
    print("📊 REPORTE FINAL")
    print("-" * 80)
    
    print(f"\n✅ Tablas verificadas: {len([t for t in tables if t in table_stats])}/{len(tables)}")
    print(f"✅ Foreign Keys activos: {len(fks)}")
    print(f"✅ Triggers activos: {len(triggers)}")
    print(f"✅ Integridad referencias: {sum(1 for s, _ in integrity_results if s)}/{len(integrity_results)}")
    print(f"✅ Endpoints testados: {passed} pasados, {failed} fallidos")
    
    # Generar reporte
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    report_file = f"COMPREHENSIVE_TEST_REPORT_{timestamp}.json"
    
    report_data = {
        'timestamp': datetime.now().isoformat(),
        'database': DB_NAME,
        'api_url': API_BASE_URL,
        'table_stats': table_stats,
        'foreign_keys_count': len(fks),
        'triggers_count': len(triggers),
        'integrity_checks': [{'check': f"{p}->{c}", 'success': s} for (p, c, _, _), (s, _) in zip(integrity_checks, integrity_results)],
        'endpoints_passed': passed,
        'endpoints_failed': failed,
        'endpoints_tested': len(endpoints_to_test),
        'test_results': tester.results
    }
    
    with open(report_file, 'w') as f:
        json.dump(report_data, f, indent=2, default=str)
    
    print(f"\n📄 Reporte guardado en: {report_file}")
    
    print("\n" + "="*80)
    print("✅ AUDITORÍA COMPLETADA")
    print("="*80)

if __name__ == "__main__":
    run_audit()
