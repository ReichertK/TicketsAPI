# Auditoría comparativa BD - TicketsAPI

**Fecha:** 30 de enero de 2026
**Generado:** 2026-01-30T13:50:11.571927+00:00
**BD:** cdk_tkt_dev @ localhost:3306

## Resumen
- MySQL (actual): 5.5.27
- Tablas (actual): 30
- Tablas (anterior): 30

## Diferencias detectadas

### Tablas agregadas
- (sin cambios)

### Tablas eliminadas
- (sin cambios)

### Cambios en columnas
- **accion**
  - Modificadas: codigo, idAccion, nombre
- **departamento**
  - Modificadas: Id_Departamento, Nombre
- **empresa**
  - Modificadas: codigo, cuit, idEmpresa, nombre
- **estado**
  - Modificadas: Id_Estado, TipoEstado
- **grupo**
  - Modificadas: Id_Grupo, Tipo_Grupo
- **motivo**
  - Modificadas: Categoria, Id_Motivo, Nombre
- **notificaciones**
  - Modificadas: Fecha_Creacion, Id_Notificacion, Id_Usuario, Mensaje
- **perfil**
  - Modificadas: idPerfil, nombre
- **perfil_accion_sistema**
  - Modificadas: ID, codigoAccion, idSistema
- **permiso**
  - Modificadas: codigo, descripcion, idPermiso
- **prioridad**
  - Modificadas: Id_Prioridad, NombrePrioridad
- **rol**
  - Modificadas: idRol, nombre
- **rol_permiso**
  - Modificadas: idPermiso, idRol
- **sistema**
  - Modificadas: idSistema, nombre
- **sucursal**
  - Modificadas: codigo, descripcion, domicilio, email, idSucursal, telefono
- **tkt**
  - Modificadas: Contenido, Date_Asignado, Date_Cambio_Estado, Date_Cierre, Date_Creado, Id_Departamento, Id_Empresa, Id_Motivo, Id_Perfil, Id_Prioridad, Id_Sucursal, Id_Tkt, Id_Usuario, Id_Usuario_Asignado
- **tkt_aprobacion**
  - Modificadas: aprobador_id, comentario, fecha_respuesta, id_aprob, id_tkt, solicitante_id
- **tkt_comentario**
  - Modificadas: comentario, id_comentario, id_tkt, id_usuario
- **tkt_permiso**
  - Modificadas: codigo, descripcion, id_permiso
- **tkt_rol**
  - Modificadas: descripcion, id_rol, nombre
- **tkt_rol_permiso**
  - Modificadas: id_permiso, id_rol
- **tkt_search**
  - Modificadas: Id_Tkt, Term
- **tkt_suscriptor**
  - Modificadas: id_tkt, id_usuario
- **tkt_transicion**
  - Modificadas: comentario, estado_from, estado_to, id_tkt, id_transicion, id_usuario_actor, id_usuario_asignado_new, id_usuario_asignado_old, meta_json, motivo
- **tkt_transicion_regla**
  - Modificadas: estado_from, estado_to, id, permiso_requerido
- **tkt_usuario_rol**
  - Modificadas: idUsuario, id_rol
- **usuario**
  - Modificadas: email, fechaAlta, fechaBaja, firma, firma_aclaracion, idUsuario, nombre, nota, passwordUsuario, passwordUsuarioEnc, telefono
- **usuario_empresa_sucursal_perfil_sistema**
  - Modificadas: ID, idSistema
- **usuario_rol**
  - Modificadas: idRol, idUsuario
- **usuario_tipo**
  - Modificadas: usuTipoDesc, usuTipoId

## Archivos generados
- docs/20-DB/DB_AUDIT_LATEST.json
- docs/20-DB/AUDIT_COMPARISON_REPORT_2026-01-30.md
