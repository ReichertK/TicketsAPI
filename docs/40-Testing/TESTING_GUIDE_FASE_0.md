# 🧪 GUÍA DE TESTING - FASE 0

**Status:** Listo para testing manual en Swagger

---

## 🚀 PASO 1: Levantar la API

```bash
cd c:\Users\Admin\Documents\GitHub\TicketsAPI\TicketsAPI
dotnet run
```

**Esperado:**
```
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://localhost:5000
      Now listening on: https://localhost:5001
```

Swagger en: **http://localhost:5000/swagger**

---

## 📝 PASO 2: Crear Usuario Admin (Si no existe)

Conectarse a MySQL y ejecutar:

```sql
-- Verificar si existe rol "Administrador"
SELECT * FROM rol WHERE nombre = 'Administrador';

-- Si no existe, crear:
INSERT INTO rol (nombre, descripcion) VALUES ('Administrador', 'Rol de administrador del sistema');

-- Obtener el ID del rol
SELECT idRol FROM rol WHERE nombre = 'Administrador';  -- Ej: 1

-- Crear usuario admin (contraseña en texto plano: admin123)
INSERT INTO usuario (nombre, email, passwordUsuario, idRol) 
VALUES ('admin', 'admin@system.com', 'admin123', 1);

-- Obtener el ID del usuario creado
SELECT idUsuario FROM usuario WHERE nombre = 'admin';  -- Ej: 1
```

---

## 🔓 PASO 3: Test - Login y Obtener JWT

### 3.1 Test en Swagger
1. Ir a **http://localhost:5000/swagger**
2. Buscar **POST /api/v1/auth/login**
3. Click en "Try it out"
4. Ingresar:
```json
{
  "nombreUsuario": "admin",
  "contrasena": "admin123"
}
```
5. Click en "Execute"

### 3.2 Test con cURL
```bash
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "nombreUsuario": "admin",
    "contrasena": "admin123"
  }'
```

### ✅ Esperado (Response 200)
```json
{
  "accessToken": "eyJhbGc...",
  "refreshToken": "AbCdEf...",
  "expiresIn": 3600
}
```

**Guardar estos tokens para los próximos tests.**

---

## 🔄 PASO 4: Test - Refresh Token

### 4.1 Test en Swagger
1. Ir a **POST /api/v1/auth/refresh-token**
2. Click en "Try it out"
3. Ingresar:
```json
{
  "refreshToken": "<el refreshToken del paso anterior>"
}
```
4. Click en "Execute"

### 4.2 Test con cURL
```bash
curl -X POST http://localhost:5000/api/v1/auth/refresh-token \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "AbCdEf..."
  }'
```

### ✅ Esperado (Response 200)
```json
{
  "accessToken": "eyJhbGc... (nuevo token)",
  "refreshToken": "XyZaBc... (token rotado)",
  "expiresIn": 3600
}
```

**Nota:** El refreshToken será diferente (rotación de token)

---

## 👥 PASO 5: Test - GET Usuarios (Protegido)

### 5.1 Test en Swagger
1. Ir a **GET /api/v1/usuarios**
2. Click en el botón "Authorize" (arriba a la derecha)
3. Ingresar token JWT: `Bearer <accessToken>`
4. Click en "Try it out"
5. Click en "Execute"

### 5.2 Test con cURL
```bash
curl -X GET http://localhost:5000/api/v1/usuarios \
  -H "Authorization: Bearer eyJhbGc..."
```

### ✅ Esperado (Response 200)
```json
[
  {
    "idUsuario": 1,
    "nombre": "admin",
    "email": "admin@system.com",
    "telefo no": null,
    "nota": null,
    "rol": {
      "idRol": 1,
      "nombre": "Administrador"
    },
    "departamento": null,
    "refreshTokenHash": "sD8F...",
    "refreshTokenExpires": "2026-01-31T11:41:51"
  }
]
```

### ❌ Sin Token (Response 401)
```json
{
  "error": "Unauthorized"
}
```

---

## 👤 PASO 6: Test - GET Usuario por ID

### 6.1 Test en Swagger
1. Ir a **GET /api/v1/usuarios/{id}**
2. Autorizar con token
3. Ingresar `id: 1`
4. Click en "Execute"

### 6.2 Test con cURL
```bash
curl -X GET http://localhost:5000/api/v1/usuarios/1 \
  -H "Authorization: Bearer eyJhbGc..."
```

### ✅ Esperado (Response 200)
```json
{
  "idUsuario": 1,
  "nombre": "admin",
  "email": "admin@system.com",
  ...
}
```

---

## ➕ PASO 7: Test - POST Crear Usuario

### 7.1 Test en Swagger
1. Ir a **POST /api/v1/usuarios**
2. Autorizar con token admin
3. Body:
```json
{
  "nombre": "tecnico",
  "email": "tecnico@example.com",
  "telefo no": "123456789",
  "nota": "Usuario técnico",
  "idRol": 2,
  "idDepartamento": 1,
  "passwordUsuario": "Tech@12345"
}
```
4. Click en "Execute"

### ✅ Esperado (Response 201)
```json
{
  "idUsuario": 2,
  "nombre": "tecnico",
  "email": "tecnico@example.com",
  ...
}
```

### ❌ Sin [Authorize] Admin (Response 403)
```json
{
  "error": "Forbidden"
}
```

---

## 🔐 PASO 8: Test - Cambiar Contraseña

### 8.1 Test en Swagger
1. Ir a **POST /api/v1/usuarios/{id}/change-password**
2. Autorizar con token
3. Body:
```json
{
  "passwordActual": "admin123",
  "passwordNueva": "NewPass@123"
}
```
4. Click en "Execute"

### ✅ Esperado (Response 200)
```json
{
  "mensaje": "Contraseña actualizada exitosamente"
}
```

---

## 📊 PASO 9: Test de Validación (Error Handling)

### 9.1 Email inválido
```json
{
  "nombre": "user",
  "email": "invalid-email",
  "idRol": 1,
  "passwordUsuario": "Pass123"
}
```
**Esperado Response 400:**
```json
{
  "errors": [
    {
      "field": "email",
      "message": "Email must be valid"
    }
  ]
}
```

### 9.2 Contraseña débil
```json
{
  "nombre": "user",
  "email": "user@example.com",
  "idRol": 1,
  "passwordUsuario": "123"
}
```
**Esperado Response 400:**
```json
{
  "errors": [
    {
      "field": "passwordUsuario",
      "message": "Password must be at least 8 characters"
    }
  ]
}
```

### 9.3 SQL Injection attempt
```json
{
  "nombre": "admin' OR '1'='1",
  "email": "user@example.com",
  "idRol": 1,
  "passwordUsuario": "Pass123"
}
```
**Esperado Response 400:**
```json
{
  "errors": [
    {
      "field": "nombre",
      "message": "Invalid characters in field"
    }
  ]
}
```

---

## 🔗 PASO 10: Test de Correlación de Request

Ejecutar:
```bash
curl -X GET http://localhost:5000/api/v1/usuarios \
  -H "Authorization: Bearer eyJhbGc..." \
  -H "X-Request-Id: test-123"
```

**En los logs (tickets-api-{date}.txt) deberías ver:**
```
[12:45:30] [INF] Request started: GET /api/v1/usuarios [CorrelationId: test-123]
[12:45:30] [INF] Request completed: 200 OK (45ms) [CorrelationId: test-123]
```

---

## ✅ CHECKLIST DE VALIDACIÓN

- [ ] Login retorna JWT + RefreshToken
- [ ] RefreshToken genera nuevo JWT
- [ ] GET /usuarios requiere autorización
- [ ] POST /usuarios requiere rol Admin
- [ ] Crear usuario válido funciona
- [ ] Validaciones rechazan datos inválidos
- [ ] SQL injection es prevenido
- [ ] X-Request-Id aparece en logs
- [ ] Cambiar contraseña funciona
- [ ] Todos los endpoints en Swagger son accesibles

---

## 🐛 Troubleshooting

### API no arranca
```
Error: Unable to connect to database
```
**Solución:**
```bash
# Verificar MySQL está corriendo
mysql -h localhost -u root -p1346 -e "SELECT 1"

# Verificar base de datos existe
mysql -h localhost -u root -p1346 -e "SHOW DATABASES LIKE 'cdk_tkt_dev'"
```

### Token expirado
```
Error: Token has expired
```
**Solución:** Usar endpoint `/refresh-token` para obtener nuevo accessToken

### Usuario no existe
```
Error: User not found
```
**Solución:** Crear usuario primero con INSERT en base de datos

### Sin autorización
```
Error 403: Forbidden
```
**Solución:** Verificar que el usuario tiene rol "Administrador" para endpoints protegidos

---

## 📝 Notas de Testing

- **AccessToken:** Válido por 60 minutos (configurable en Program.cs)
- **RefreshToken:** Válido por 24 horas (configurable en AuthService.cs)
- **Token Rotation:** Cada refresh genera nuevo refreshToken
- **Password Hash:** SHA256 (considerar BCrypt para producción)
- **Database:** MySQL 5.5.27 (compatible con script de migración)

---

## 📞 Contacto

Si encuentras problemas:
1. Revisa los logs en `TicketsAPI/logs/tickets-api-{date}.txt`
2. Verifica conexión a base de datos
3. Asegúrate que usuario admin existe
4. Verifica X-Request-Id en logs para tracing

