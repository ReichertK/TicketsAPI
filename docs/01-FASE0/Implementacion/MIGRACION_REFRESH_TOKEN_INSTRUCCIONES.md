# Instrucciones de Migración - FASE 0 Refresh Token

**Problema:** MySQL 5.5.27 no soporta `IF NOT EXISTS` en `ALTER TABLE`

**Solución:** Ejecutar las sentencias directamente

---

## ✅ PASOS PARA EJECUTAR LA MIGRACIÓN

### Opción 1: Línea por línea (Recomendado)

Conéctate a tu base de datos MySQL:
```bash
mysql -h localhost -u root -p cdk_tkt_dev
```

Luego ejecuta estas 3 líneas:

```sql
ALTER TABLE usuario ADD COLUMN refresh_token_hash VARCHAR(512) DEFAULT NULL;
ALTER TABLE usuario ADD COLUMN refresh_token_expires DATETIME DEFAULT NULL;
ALTER TABLE usuario ADD COLUMN last_login DATETIME DEFAULT NULL;
```

**Esperado:** 
```
Query OK, 0 rows affected
```

---

### Opción 2: Desde archivo SQL compatible

Si quieres usar el script desde archivo, ejecuta:

```bash
mysql -h localhost -u root -p cdk_tkt_dev < Database/001_add_refresh_token.sql
```

**Nota:** El script verificará si las columnas ya existen y ejecutará las sentencias directas sin `IF NOT EXISTS`.

---

### Opción 3: Desde GUI (MySQL Workbench, DBeaver, etc.)

1. Abre tu cliente MySQL GUI
2. Conéctate a `cdk_tkt_dev`
3. Copia y ejecuta estas 3 líneas en una nueva pestaña SQL:

```sql
ALTER TABLE usuario ADD COLUMN refresh_token_hash VARCHAR(512) DEFAULT NULL;
ALTER TABLE usuario ADD COLUMN refresh_token_expires DATETIME DEFAULT NULL;
ALTER TABLE usuario ADD COLUMN last_login DATETIME DEFAULT NULL;
```

---

## ✔️ VERIFICACIÓN

Después de ejecutar, verifica que las columnas fueron creadas:

```sql
DESC usuario;
```

Deberías ver al final:
```
refresh_token_hash      | varchar(512)  | YES  |     | NULL
refresh_token_expires   | datetime      | YES  |     | NULL
last_login              | datetime      | YES  |     | NULL
```

O usa esta query:
```sql
SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'usuario' 
AND COLUMN_NAME IN ('refresh_token_hash', 'refresh_token_expires', 'last_login');
```

---

## 📊 RESULTADO ESPERADO

```
+-----------------------+----------+
| COLUMN_NAME           | COLUMN_TYPE |
+-----------------------+----------+
| refresh_token_hash    | varchar(512) |
| refresh_token_expires | datetime     |
| last_login            | datetime     |
+-----------------------+----------+
```

---

## ⚠️ TROUBLESHOOTING

**Si obtienes error 1064:**
```
Error Code: 1064
You have an error in your SQL syntax
```

✅ **Solución:** Es porque MySQL 5.5 no soporta `IF NOT EXISTS` en ALTER TABLE. Usa la opción 1 o 2 sin el `IF NOT EXISTS`.

**Si obtienes error 1060:**
```
Error Code: 1060
Duplicate column name 'refresh_token_hash'
```

✅ **Solución:** La columna ya existe. Continúa sin hacer nada. Es seguro para la migración.

---

## 🔄 ROLLBACK (si necesitas deshacer)

Si las cosas salen mal, puedes revertir:

```sql
ALTER TABLE usuario DROP COLUMN refresh_token_hash;
ALTER TABLE usuario DROP COLUMN refresh_token_expires;
ALTER TABLE usuario DROP COLUMN last_login;
```

---

## 📋 CHECKLIST POST-MIGRACIÓN

- [ ] 3 columnas agregadas sin errores
- [ ] `DESC usuario` muestra las nuevas columnas
- [ ] API compila sin errores: `dotnet build`
- [ ] Tests pasan: `dotnet test`
- [ ] Swagger funciona: `dotnet run` → http://localhost:5000/swagger

---

## 🎯 NEXT STEPS

Una vez migración exitosa:

```bash
# 1. Compilar
dotnet build

# 2. Ejecutar tests (si existen)
dotnet test

# 3. Correr API
dotnet run

# 4. Probar endpoints en Swagger
curl http://localhost:5000/swagger
```

---

**Fecha:** 30 de enero de 2026  
**Compatible:** MySQL 5.5+ (cualquier versión)  
**Tiempo estimado:** 1 minuto
