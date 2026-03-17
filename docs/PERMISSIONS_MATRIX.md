# Matriz de Permisos

Sistema RBAC del módulo de tickets. Tablas: `tkt_rol`, `tkt_permiso`, `tkt_rol_permiso`, `tkt_usuario_rol`.

## Roles

| ID | Rol           | Descripción                        |
|----|---------------|------------------------------------|
| 1  | Administrador | Acceso total                       |
| 2  | Supervisor    | Supervisa y edita, sin eliminar    |
| 3  | Operador      | Opera tickets asignados            |
| 4  | Consulta      | Solo lectura y exportar            |
| 6  | Aprobador     | Puede aprobar/rechazar tickets     |

## Permisos

| Código                  | Descripción                        |
|-------------------------|------------------------------------|
| `TKT_LIST_ALL`          | Ver todos los tickets              |
| `TKT_LIST_ASSIGNED`     | Ver solo tickets asignados         |
| `TKT_VIEW_DETAIL`       | Ver detalle de ticket              |
| `TKT_CREATE`            | Crear ticket                       |
| `TKT_EDIT_ASSIGNED`     | Editar ticket si es asignado       |
| `TKT_EDIT_ANY`          | Editar cualquier ticket            |
| `TKT_ASSIGN`            | Asignar tickets                    |
| `TKT_CLOSE`             | Cerrar tickets                     |
| `TKT_DELETE`            | Eliminar tickets                   |
| `TKT_EXPORT`            | Exportar CSV                       |
| `TKT_COMMENT`           | Comentar en tickets                |
| `TKT_RBAC_ADMIN`        | Administrar roles y permisos       |
| `TKT_START`             | Iniciar trabajo en ticket          |
| `TKT_WAIT`              | Poner / sacar de espera            |
| `TKT_REQUEST_APPROVAL`  | Solicitar aprobación               |
| `TKT_APPROVE`           | Aprobar / rechazar                 |
| `TKT_RESOLVE`           | Marcar como resuelto               |
| `TKT_REOPEN`            | Reabrir ticket                     |
| `VER_SOLO_DEPARTAMENTO` | Restringir vista al propio depto   |

## Asignación rol → permiso

| Permiso                 | Admin | Supervisor | Operador | Consulta | Aprobador |
|-------------------------|:-----:|:----------:|:--------:|:--------:|:---------:|
| `TKT_LIST_ALL`          |   x   |     x      |          |    x     |     x     |
| `TKT_LIST_ASSIGNED`     |   x   |            |    x     |          |           |
| `TKT_VIEW_DETAIL`       |   x   |     x      |    x     |    x     |           |
| `TKT_CREATE`            |   x   |     x      |    x     |          |           |
| `TKT_EDIT_ASSIGNED`     |   x   |            |    x     |          |           |
| `TKT_EDIT_ANY`          |   x   |     x      |          |          |           |
| `TKT_ASSIGN`            |   x   |     x      |          |          |           |
| `TKT_CLOSE`             |   x   |     x      |    x     |          |           |
| `TKT_DELETE`            |   x   |            |          |          |           |
| `TKT_EXPORT`            |   x   |     x      |          |    x     |           |
| `TKT_COMMENT`           |   x   |     x      |    x     |          |           |
| `TKT_RBAC_ADMIN`        |   x   |            |          |          |           |
| `TKT_START`             |   x   |     x      |    x     |          |           |
| `TKT_WAIT`              |   x   |     x      |    x     |          |           |
| `TKT_REQUEST_APPROVAL`  |   x   |     x      |    x     |          |           |
| `TKT_APPROVE`           |   x   |     x      |          |          |     x     |
| `TKT_RESOLVE`           |   x   |     x      |    x     |          |           |
| `TKT_REOPEN`            |   x   |     x      |          |          |           |
| `VER_SOLO_DEPARTAMENTO` |       |            |    x     |          |           |

## Estados del ticket

| ID | Estado               |
|----|----------------------|
| 1  | Abierto              |
| 2  | En Proceso           |
| 3  | Cerrado              |
| 4  | En Espera            |
| 5  | Pendiente Aprobación |
| 6  | Resuelto             |
| 7  | Reabierto            |

## Transiciones permitidas

| Origen               | Destino              | Permiso requerido       | Aprobación |
|----------------------|----------------------|-------------------------|:----------:|
| Abierto              | En Proceso           | `TKT_ASSIGN`            |            |
| En Proceso           | Cerrado              | `TKT_START`             |            |
| En Proceso           | En Espera            | `TKT_WAIT`              |            |
| En Proceso           | Pend. Aprobación     | `TKT_REQUEST_APPROVAL`  |     x      |
| En Espera            | En Proceso           | `TKT_WAIT`              |            |
| En Espera            | Cerrado              | `TKT_WAIT`              |            |
| Pend. Aprobación     | Cerrado              | `TKT_APPROVE`           |            |
| Pend. Aprobación     | Resuelto             | `TKT_APPROVE`           |            |
| Pend. Aprobación     | En Proceso           | `TKT_APPROVE`           |            |
| Cerrado              | En Espera            | `TKT_WAIT`              |            |
| Cerrado              | Pend. Aprobación     | `TKT_REQUEST_APPROVAL`  |     x      |
| Cerrado              | Resuelto             | `TKT_RESOLVE`           |            |
| Cerrado              | Reabierto            | `TKT_REOPEN`            |            |
| Resuelto             | Reabierto            | `TKT_CLOSE`             |            |
| Resuelto             | Cerrado              | `TKT_CLOSE`             |            |
| Reabierto            | En Proceso           | `TKT_START`             |            |
