# scripts/

Scripts operacionales para TicketsAPI. Todos están diseñados para Windows (PowerShell 5.0+) salvo indicación contraria.

## Base de datos

| Script | Descripción | Requisitos |
|--------|-------------|------------|
| `db-migrate-refresh-token.ps1` | Agrega columnas de refresh-token a la tabla `usuario` | `mysql.exe` en PATH |
| `db-setup-admin.ps1` | Crea el rol Administrador y el usuario admin por defecto | `mysql.exe` en PATH |

```powershell
# Ejecutar migración contra MySQL local
.\scripts\db-migrate-refresh-token.ps1 -Password "yourpass"

# Crear usuario admin
.\scripts\db-setup-admin.ps1 -Password "yourpass" -AdminPassword "s3cret"
```

## Pruebas

| Script | Descripción | Requisitos |
|--------|-------------|------------|
| `smoke-test.py` | Valida que los endpoints principales de la API respondan (auth, CRUD, permisos) | Python 3.8+, `requests` |

```bash
# Configurar vía variables de entorno (o usar defaults: localhost:5001, admin/changeme)
export API_BASE_URL=https://localhost:5001/api/v1
export API_USER=admin
export API_PASSWORD=changeme
python scripts/smoke-test.py
```

## internal/

Scripts de uso poco frecuente y potencialmente destructivos. **No ejecutar sin entender las consecuencias.**

| Script | Descripción |
|--------|-------------|
| `hard_reset_produccion.sql` | Trunca todos los tickets, comentarios, historial y usuarios no-admin. **Destructivo.** |
