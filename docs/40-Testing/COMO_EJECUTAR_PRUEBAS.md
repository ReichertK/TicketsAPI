# CÓMO EJECUTAR LAS PRUEBAS EXHAUSTIVAS

## Instrucciones Rápidas

### Paso 1: Abra DOS terminales PowerShell

#### Terminal 1 - Iniciar la API:
```powershell
cd "c:\Users\Admin\Documents\GitHub\TicketsAPI\TicketsAPI"
dotnet run --configuration Release
```

Espere hasta ver:
```
[INF] Now listening on: https://localhost:5001
[INF] Application started. Press Ctrl+C to shut down.
```

#### Terminal 2 - Ejecutar las Pruebas:
```powershell
cd "c:\Users\Admin\Documents\GitHub\TicketsAPI"
powershell -ExecutionPolicy Bypass -File "run_all_tests.ps1"
```

---

## Métodos Alternativos

### Método A: Script Automatizado
```powershell
cd "c:\Users\Admin\Documents\GitHub\TicketsAPI"
powershell -ExecutionPolicy Bypass -File "run_tests.ps1"
```

### Método B: Scripts Individuales
```powershell
# Script simple
powershell -ExecutionPolicy Bypass -File "test_simple.ps1"

# Script completo con más detalles
powershell -ExecutionPolicy Bypass -File "test_admin.ps1"
```

---

## Archivos de Pruebas Disponibles

| Archivo | Descripción |
|---------|------------|
| **run_all_tests.ps1** | Script principal - RECOMENDADO |
| **test_simple.ps1** | Script simple y directo |
| **test_admin.ps1** | Script con logging detallado |
| **run_tests.ps1** | Script que espera a API y ejecuta |
| **PRUEBAS_EXHAUSTIVAS_PREPARADAS.md** | Documentación completa |

---

## Qué Prueban los Scripts

✅ **Autenticación**
- Login como usuario Admin
- Obtención de JWT token

✅ **Tickets (CRUD)**
- Listar todos los tickets (GET /Tickets)
- Crear nuevo ticket (POST /Tickets)
- Obtener ticket por ID (GET /Tickets/{id})
- Actualizar ticket (PUT /Tickets/{id})
- Cambiar estado (PATCH /Tickets/{id}/cambiar-estado)

✅ **Comentarios (CRUD)**
- Crear comentario (POST /Tickets/{id}/Comentarios)
- Listar comentarios (GET /Tickets/{id}/Comentarios)
- Actualizar comentario (PUT /Tickets/{id}/Comentarios/{cid})

✅ **Datos de Referencia**
- GET /Estados
- GET /Prioridades
- GET /Departamentos
- GET /Motivos

✅ **Gestión de Usuarios**
- GET /Usuarios
- GET /Usuarios/perfil-actual

---

## Resultado Esperado

### Si TODO funciona correctamente:
```
========================================
PRUEBAS EXHAUSTIVAS - TicketsAPI Admin
========================================

[Test 1] Login ✓ OK
[Test 2] GET /Tickets ✓ OK
[Test 3] POST /Tickets (crear) ✓ OK
[Test 4] GET /Tickets/{id} ✓ OK
... (más pruebas)

========================================
RESUMEN DE PRUEBAS
========================================

Total de pruebas: 12
Exitosas: 12
Fallidas: 0
Tasa de éxito: 100%

✓ TODAS LAS PRUEBAS PASARON EXITOSAMENTE
```

---

## Si Hay Errores

### Error 1: "No es posible conectar con el servidor remoto"
- **Causa**: API no está corriendo
- **Solución**: Asegúrese de que la Terminal 1 muestra "Now listening on: https://localhost:5001"

### Error 2: "Unexpected token 'cd' in expression"
- **Causa**: Ejecutó en cmd.exe en lugar de PowerShell
- **Solución**: Abra PowerShell y ejecute el comando

### Error 3: "The term 'dotnet' is not recognized"
- **Causa**: dotnet no está en el PATH
- **Solución**: Verifique que .NET 6 está instalado (`dotnet --version`)

---

## Backup de Base de Datos

Si desea restaurar la BD a su estado anterior:
```
Ubicación del backup: docs/20-DB/backups/backup_complete_[timestamp].sql

Restaurar con:
mysql -h localhost -u root -p1346 cdk_tkt_dev < docs/20-DB/backups/backup_complete_[timestamp].sql
```

---

## Información de Usuario Admin

- **Usuario**: Admin
- **Contraseña**: changeme
- **ID de Usuario**: 1
- **Perfil**: 4 (Administrador)
- **Sucursal**: 2 (CALLE 7)
- **Empresa**: 0
- **Sistema**: CDK_TKT (TICKETS)
- **Estado**: Activo (habilitado)

---

## Información de la API

- **URL**: https://localhost:5001/api/v1
- **Protocolo**: HTTPS con SSL local
- **Framework**: .NET 6.0
- **Base de Datos**: MySQL cdk_tkt_dev
- **Status**: Compilada y lista

---

## Próximos Pasos

1. Abra dos terminales PowerShell
2. En Terminal 1: Inicie la API
3. En Terminal 2: Ejecute `powershell -ExecutionPolicy Bypass -File "run_all_tests.ps1"`
4. Verifique que TODO muestre ✓ OK en verde
5. Si hay errores, revise la sección "Si Hay Errores" arriba

---

**¡Listo para empezar las pruebas exhaustivas!**
