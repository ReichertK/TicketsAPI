# Revisión de SPs vs código (estado actual)
Fecha: 3 de febrero de 2026
Última actualización: Completada migración de Usuarios a SPs (3 Feb 2026)

## 1) SPs existentes en BD (cdk_tkt_dev)
**Total: 64 SPs** (aumentó desde 53 iniciales)

Relevantes para la API actual:
- Tickets:
  - sp_agregar_tkt ✅ En uso
  - sp_actualizar_tkt ✅ En uso
  - sp_eliminar_ticket ✅ En uso
  - sp_listar_tkts ✅ En uso
  - sp_tkt_transicionar ✅ En uso
  - sp_tkt_historial ✅ En uso
  - sp_tkt_comentar ✅ En uso

- Departamentos:
  - sp_listar_departamento ✅ En uso
  - sp_departamento_crear ✅ **Nuevo** - En uso
  - sp_departamento_actualizar ✅ **Nuevo** - En uso
  - sp_departamento_eliminar ✅ **Nuevo** - En uso

- Motivos:
  - sp_obtener_motivos ✅ En uso
  - sp_motivo_crear ✅ **Nuevo** - En uso
  - sp_motivo_actualizar ✅ **Nuevo** - En uso
  - sp_motivo_eliminar ✅ **Nuevo** - En uso

- Usuarios:
  - sp_agregar_usuario ✅ **Modernizado** - En uso
  - sp_editar_usuario ✅ **Modernizado** - En uso
  - sp_eliminar_usuario ✅ **Nuevo** - En uso
  - sp_obtener_usuarios ✅ En uso
  - old_sp_agregar_usuario 📦 Respaldo legacy
  - old_sp_editar_usuario 📦 Respaldo legacy

- Otros (login, permisos, rol, etc.):
  - sp_login_hub (no usado por Auth actual)
  - sp_tkt_permisos_por_usuario, sp_tkt_permiso_crear, sp_tkt_rol_crear, etc.

### Estado real en BD (consultado)
- `sp_eliminar_ticket`: hace soft delete (Habilitado = 0) y valida existencia.
- `sp_listar_departamento`: corregida (devuelve Id_Departamento, Nombre). Respaldo: `old_sp_listar_departamento`.
- `sp_obtener_motivos`: devuelve Id_Motivo, Nombre, Categoria.
- `sp_obtener_usuarios`: actualizada para devolver columnas completas. Respaldo: `old_sp_obtener_usuarios`.
- `sp_tkt_transicionar`: lógica completa de transición con permisos/validaciones.
- `sp_tkt_comentar`: inserta comentario y devuelve SELECT success/mensaje.

**Nuevos SPs creados (Feb 2026):**
- `sp_departamento_crear/actualizar/eliminar`: CRUD completo con validación de duplicados y OUT parameters
- `sp_motivo_crear/actualizar/eliminar`: CRUD completo con validación de duplicados y OUT parameters
- `sp_agregar_usuario` (modernizado): Compatible con arquitectura actual (usuario_rol), validación de emails
- `sp_editar_usuario` (modernizado): Actualización opcional de password, gestión de roles, validación de duplicados
- `sp_eliminar_usuario`: Soft delete con fechaBaja

## 2) Uso actual en código (resumen)
**Ya usa SPs (completamente migrado)**
- ✅ Tickets (CRUD + transiciones) en [TicketRepository.cs](TicketsAPI/Repositories/Implementations/TicketRepository.cs)
- ✅ Comentarios (crear) en [ComentarioRepository.cs](TicketsAPI/Repositories/Implementations/ComentarioRepository.cs)
- ✅ Departamentos (CRUD completo) en [DepartamentoRepository.cs](TicketsAPI/Repositories/Implementations/DepartamentoRepository.cs)
- ✅ Motivos (CRUD completo) en [MotivoRepository.cs](TicketsAPI/Repositories/Implementations/MotivoRepository.cs)
- ✅ Usuarios (CRUD completo) en [UsuarioRepository.cs](TicketsAPI/Repositories/Implementations/UsuarioRepository.cs)

**Sin migrar aún**
- ⏳ Estados, Prioridades, Roles, Permisos, Grupos, Aprobaciones

## 3) Verificación de endpoints
**Estado: 14/14 endpoints verificados ✅**

Tests ejecutados exitosamente:
1. POST /Tickets/1/Comments ✅
2. PUT /Tickets/1/Comments/{id} ✅
3. DELETE /Comments/{id} ✅
4. POST /Usuarios ✅
5. PUT /Usuarios/{id} ✅
6. DELETE /Usuarios/{id} ✅
7. POST /Motivos ✅
8. PUT /Motivos/{id} ✅
9. POST /Departamentos ✅
10. PUT /Departamentos/{id} ✅
11. POST /Tickets/1/Transition ✅
12. GET /Approvals/Pending ✅
13. GET /api/sp ✅
14. DELETE /Tickets (crea y elimina) ✅

## 4) Próximos pasos
**Entidades pendientes de migración:**
- Estados (sp_obtener_estados existe, falta CRUD)
- Prioridades (sp_obtener_prioridades existe, falta CRUD)
- Roles y Permisos (sp_tkt_rol_crear, sp_tkt_permiso_crear existen)
- Grupos
- Aprobaciones

**Duplicidades por resolver:**
- Transiciones: existe flujo SP `sp_tkt_transicionar` (usado en PATCH /Tickets/{id}/cambiar-estado) y flujo alterno en `POST /Tickets/{id}/Transition` que valida con `IEstadoService` y actualiza directo.

---

## Historial de cambios
**3 Feb 2026:**
- ✅ Migrado UsuarioRepository full CRUD a SPs
- ✅ Creados sp_agregar_usuario, sp_editar_usuario, sp_eliminar_usuario (modernizados)
- ✅ Respaldados SPs legacy como old_sp_agregar_usuario y old_sp_editar_usuario
- ✅ Actualizado sp_editar_usuario para manejo opcional de password
- ✅ Verificados 14/14 endpoints funcionando
- ✅ Total SPs: 64 (aumentó desde 53)
