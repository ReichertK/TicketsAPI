# 🛠️ Scripts de Testing y Utilidades

Este directorio contiene todos los scripts de testing, validación y utilidades del proyecto.

---

## 📁 Estructura

```
scripts/
├── Python Scripts (*.py)      - Testing y validación con Python
├── PowerShell Scripts (*.ps1) - Testing y operaciones con PowerShell
└── README.md                  - Este archivo
```

---

## 🐍 Scripts Python

### Testing de API
- `test_api.py` - Suite completa de testing de endpoints
- `comprehensive_endpoints_test.py` - Testing exhaustivo de todos los endpoints
- `integration_endpoints.py` - Tests de integración
- `integration_comprehensive.py` - Suite completa de integración
- `integration_complete_all_endpoints.py` - Validación total de endpoints
- `integration_tests.py` - Tests de integración específicos

### Testing Específico
- `test_login_quick.py` - Test rápido de login
- `check_login.py` - Validación de autenticación
- `test_urllib.py` - Tests con urllib
- `test_fixes_quick.py` - Validación de fixes rápidos
- `quick_test_fixes.py` - Tests rápidos de correcciones

### QA y Auditoría
- `qa_testing.py` - Suite de Quality Assurance
- `qa_test_suite.py` - Suite completa de QA
- `run_comprehensive_audit.py` - Auditoría completa del sistema

---

## 💻 Scripts PowerShell

### Testing de API
- `test_api.ps1` - Test básico de API
- `test_api_simple.ps1` - Test simplificado
- `IntegrationTests.ps1` - Tests de integración

### Testing Específico
- `test_login.ps1` - Test de autenticación
- `test_fixes.ps1` - Validación de correcciones
- `test_reportes.ps1` - Test de endpoints de reportes
- `test_busqueda_avanzada.ps1` - Test de búsqueda avanzada

### QA
- `QA_TESTING.ps1` - Suite de Quality Assurance

---

## 🚀 Uso Rápido

### Testing Completo de API
```bash
# Python
python scripts/test_api.py

# PowerShell
.\scripts\test_api.ps1
```

### Testing de Login
```bash
# Python
python scripts/test_login_quick.py

# PowerShell
.\scripts\test_login.ps1
```

### Auditoría Completa
```bash
python scripts/run_comprehensive_audit.py
```

### Suite QA
```bash
# Python
python scripts/qa_test_suite.py

# PowerShell
.\scripts\QA_TESTING.ps1
```

---

## 📋 Recomendaciones

### Para Testing Rápido
1. `test_api_simple.ps1` - Validación rápida de API
2. `test_login_quick.py` - Check de autenticación

### Para Testing Completo
1. `comprehensive_endpoints_test.py` - Todos los endpoints
2. `qa_test_suite.py` - Suite completa de QA
3. `run_comprehensive_audit.py` - Auditoría total

### Para Integración
1. `integration_complete_all_endpoints.py` - Validación de integración completa
2. `IntegrationTests.ps1` - Tests de integración PowerShell

---

## ⚙️ Configuración

La mayoría de los scripts requieren:
- API corriendo en `http://localhost:5000`
- Credenciales válidas (configurables en cada script)
- Python 3.8+ o PowerShell 5.1+

---

## 📊 Reportes

Los resultados de los tests generalmente se guardan en:
- `docs/90-Reports/` - Reportes de auditoría
- `docs/40-Testing/Artifacts/` - Outputs de tests

---

**Última actualización:** 30 de Enero de 2026
