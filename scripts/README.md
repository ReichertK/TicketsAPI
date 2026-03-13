# scripts/

Operational scripts for TicketsAPI. All scripts are designed for Windows (PowerShell 5.0+) unless noted otherwise.

## Database Setup

| Script | Purpose | Prerequisites |
|--------|---------|---------------|
| `db-migrate-refresh-token.ps1` | Adds refresh-token columns to `usuario` table | `mysql.exe` in PATH |
| `db-setup-admin.ps1` | Creates the Administrador role and default admin user | `mysql.exe` in PATH |

```powershell
# Example: run migration against local MySQL
.\scripts\db-migrate-refresh-token.ps1 -Password "yourpass"

# Example: create admin user
.\scripts\db-setup-admin.ps1 -Password "yourpass" -AdminPassword "s3cret"
```

## Testing

| Script | Purpose | Prerequisites |
|--------|---------|---------------|
| `smoke-test.py` | Validates core API endpoints are responding (auth, CRUD, permissions) | Python 3.8+, `requests` |

```bash
# Configure via environment variables (or use defaults: localhost:5001, admin/changeme)
export API_BASE_URL=https://localhost:5001/api/v1
export API_USER=admin
export API_PASSWORD=changeme
python scripts/smoke-test.py
```

## internal/

Scripts that are rarely needed and potentially destructive. **Do not run without understanding the consequences.**

| Script | Purpose |
|--------|---------|
| `hard_reset_produccion.sql` | Truncates all tickets, comments, history, and non-admin users. **Destructive.** |
