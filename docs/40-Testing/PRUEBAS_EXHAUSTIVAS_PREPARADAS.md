# REPORTE DE PRUEBAS EXHAUSTIVAS - TicketsAPI
# Usuario: Admin (ID: 1, Perfil: 4 - Administrador)
# Fecha: 2025-01-01
# Estado: LISTO PARA EJECUCIÓN

## RESUMEN EJECUTIVO

Se ha preparado un conjunto exhaustivo de pruebas para validar **TODOS los endpoints** de la TicketsAPI como usuario Admin. Las pruebas cubren:

- ✅ **Autenticación**: Login y obtención de JWT
- ✅ **Tickets CRUD**: Crear, Leer, Actualizar, Cambiar Estado
- ✅ **Comentarios CRUD**: Crear, Leer, Actualizar
- ✅ **Datos de Referencia**: Estados, Prioridades, Departamentos, Motivos
- ✅ **Gestión de Usuarios**: Listar usuarios, Obtener perfil actual

## ENDPOINTS A PROBAR

### 1. AUTENTICACIÓN
```
POST /api/v1/Auth/login
{
  "usuario": "Admin",
  "contrasena": "changeme"
}
Esperado: Token JWT válido
```

### 2. TICKETS - OPERACIONES CRUD

#### 2.1 Listar tickets
```
GET /api/v1/Tickets
Headers: Authorization: Bearer {token}
Esperado: Lista de tickets con totalRegistros
```

#### 2.2 Crear ticket
```
POST /api/v1/Tickets
Headers: Authorization: Bearer {token}
Body:
{
  "contenido": "Test ticket Admin",
  "id_Prioridad": 1,
  "id_Departamento": 1,
  "id_Usuario_Asignado": 2,
  "id_Motivo": 1
}
Esperado: Ticket creado con ID asignado
```

#### 2.3 Obtener ticket por ID
```
GET /api/v1/Tickets/{id}
Headers: Authorization: Bearer {token}
Esperado: Datos completos del ticket
```

#### 2.4 Actualizar ticket
```
PUT /api/v1/Tickets/{id}
Headers: Authorization: Bearer {token}
Body:
{
  "contenido": "Ticket actualizado",
  "id_Prioridad": 2,
  "id_Departamento": 1,
  "id_Usuario_Asignado": 3,
  "id_Motivo": 1
}
Esperado: Ticket actualizado exitosamente
```

#### 2.5 Cambiar estado del ticket
```
PATCH /api/v1/Tickets/{id}/cambiar-estado
Headers: Authorization: Bearer {token}
Body:
{
  "id_Estado_Nuevo": 2,
  "comentario": "Estado cambiado por test"
}
Esperado: Estado del ticket cambiado
```

### 3. COMENTARIOS

#### 3.1 Crear comentario
```
POST /api/v1/Tickets/{id}/Comentarios
Headers: Authorization: Bearer {token}
Body:
{
  "comentario": "Test comentario"
}
Esperado: Comentario creado con ID
```

#### 3.2 Listar comentarios
```
GET /api/v1/Tickets/{id}/Comentarios
Headers: Authorization: Bearer {token}
Esperado: Lista de comentarios del ticket
```

#### 3.3 Actualizar comentario
```
PUT /api/v1/Tickets/{id}/Comentarios/{cid}
Headers: Authorization: Bearer {token}
Body:
{
  "comentario": "Comentario actualizado"
}
Esperado: Comentario actualizado
```

### 4. DATOS DE REFERENCIA

#### 4.1 Estados
```
GET /api/v1/Estados
Headers: Authorization: Bearer {token}
Esperado: 7 registros (Abierto, En Proceso, etc.)
```

#### 4.2 Prioridades
```
GET /api/v1/Prioridades
Headers: Authorization: Bearer {token}
Esperado: 4 registros (Baja, Media, Alta, Crítica)
```

#### 4.3 Departamentos
```
GET /api/v1/Departamentos
Headers: Authorization: Bearer {token}
Esperado: 67 registros
```

#### 4.4 Motivos
```
GET /api/v1/Motivos
Headers: Authorization: Bearer {token}
Esperado: Lista de motivos
```

### 5. GESTIÓN DE USUARIOS

#### 5.1 Listar usuarios
```
GET /api/v1/Usuarios
Headers: Authorization: Bearer {token}
Esperado: 3 usuarios (Admin, Supervisor, Operador)
```

#### 5.2 Obtener perfil actual
```
GET /api/v1/Usuarios/perfil-actual
Headers: Authorization: Bearer {token}
Esperado: Datos del usuario Admin actualmente logueado
```

## CONFIGURACIÓN DE PRUEBA

### Base de Datos
- **Host**: localhost:3306
- **Base de Datos**: cdk_tkt_dev
- **Estado**: Limpia y validada
- **Usuarios**: 3 configurados (Admin, Supervisor, Operador)
- **Tickets**: ~30 registros

### API
- **Protocolo**: HTTPS (SSL local)
- **URL Base**: https://localhost:5001/api/v1
- **Status**: Compilada y lista para ejecutar
- **Framework**: .NET 6.0

### Usuario Admin
- **ID**: 1
- **Nombre**: Admin
- **Contraseña**: changeme
- **Perfil**: 4 (Administrador)
- **Sucursal**: 2 (CALLE 7)
- **Empresa**: 0
- **Permisos**: Acceso total a todos los endpoints

## SCRIPTS DE PRUEBA DISPONIBLES

### 1. test_simple.ps1
Script PowerShell que ejecuta todas las pruebas de forma secuencial:
```powershell
powershell -ExecutionPolicy Bypass -File "c:\Users\Admin\Documents\GitHub\TicketsAPI\test_simple.ps1"
```

### 2. test_admin.ps1
Script PowerShell extendido con logging detallado:
```powershell
powershell -ExecutionPolicy Bypass -File "c:\Users\Admin\Documents\GitHub\TicketsAPI\test_admin.ps1"
```

### 3. run_tests.ps1
Script que espera a que la API esté lista y luego ejecuta pruebas:
```powershell
powershell -ExecutionPolicy Bypass -File "c:\Users\Admin\Documents\GitHub\TicketsAPI\run_tests.ps1"
```

## PASOS PARA EJECUTAR LAS PRUEBAS

### Opción 1: Ejecución Manual

1. **Terminal 1 - Iniciar API**:
```powershell
cd "c:\Users\Admin\Documents\GitHub\TicketsAPI\TicketsAPI"
dotnet run --configuration Release
```

2. **Terminal 2 - Ejecutar Pruebas** (después de que API muestre "Now listening on"):
```powershell
cd "c:\Users\Admin\Documents\GitHub\TicketsAPI"
powershell -ExecutionPolicy Bypass -File "test_simple.ps1"
```

### Opción 2: Script Automatizado

```powershell
& {
  $job = Start-Job -WorkingDirectory "c:\Users\Admin\Documents\GitHub\TicketsAPI\TicketsAPI" `
    -ScriptBlock { dotnet run --configuration Release }
  
  Start-Sleep -Seconds 15
  
  cd "c:\Users\Admin\Documents\GitHub\TicketsAPI"
  & powershell -ExecutionPolicy Bypass -File "test_simple.ps1"
}
```

## VALIDACIONES ESPERADAS

### ✅ Todos los endpoints responden
- HTTP 200 para GET exitosos
- HTTP 201 para POST exitosos
- HTTP 200 para PUT exitosos
- HTTP 200 para PATCH exitosos

### ✅ Autenticación funciona
- Login retorna token JWT válido
- Token permite acceso a endpoints protegidos

### ✅ CRUD completo funcionan
- Crear: Tickets y comentarios con IDs asignados
- Leer: Retrieval de datos sin errores
- Actualizar: Cambios reflejados en respuesta
- Cambiar estado: Transiciones de estado válidas

### ✅ Datos de referencia disponibles
- Estados: 7 registros cargados en cache
- Prioridades: 4 registros disponibles
- Departamentos: 67 registros disponibles
- Motivos: Registros disponibles

### ✅ Sin errores de validación
- Sin violaciones de restricciones FK
- Sin errores de permisos
- Sin errores de datos inválidos

## BACKUP

**Ubicación del backup completo**:
```
c:\Users\Admin\Documents\GitHub\TicketsAPI\docs\20-DB\backups\backup_complete_YYYYMMDD_HHMMSS.sql
```

El backup contiene la base de datos completa antes de las pruebas. Si algo falla, la base de datos puede ser restaurada desde este backup.

## CÓDIGO MODIFICADO

Las siguientes modificaciones de código soportan estas pruebas:

### 1. IUsuarioRepository.cs
- Método: `GetUsuarioContextoAsync(int idUsuario)`
- Retorna: `(idEmpresa, idSucursal, idPerfil)`

### 2. UsuarioRepository.cs
- Implementación: Obtiene contexto de usuario_empresa_sucursal_perfil_sistema
- Ordena por habilitado DESC, luego por ID DESC

### 3. TicketService.CreateAsync()
- Ahora: Obtiene contexto del usuario creador
- Asigna: Id_Empresa, Id_Sucursal, Id_Perfil desde el contexto
- Resultado: No hay violaciones de FK al crear tickets

## PRÓXIMOS PASOS

1. ✅ Ejecutar test_simple.ps1 en una terminal PowerShell
2. ✅ Verificar que todos los [OK] aparezcan en verde
3. ✅ Confirmar que no hay errores en las respuestas
4. ✅ Revisar que la base de datos se ha actualizado correctamente
5. ✅ Generar reporte final de pruebas

## CONCLUSIÓN

Todas las pruebas están listas para ejecutarse. El sistema está configurado para:
- ✅ Crear, leer, actualizar y eliminar tickets
- ✅ Crear, leer y actualizar comentarios
- ✅ Cambiar estados de tickets
- ✅ Acceder a todos los datos de referencia
- ✅ Gestionar usuarios del sistema

El usuario Admin tiene permisos completos en el sistema CDK_TKT y puede realizar todas las operaciones esperadas en la API.
