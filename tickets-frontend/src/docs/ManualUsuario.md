# Centro de Ayuda — Sistema de Tickets Cediac

---

## Manual de Usuario

### Crear un Ticket

Para crear un nuevo ticket de soporte, sigue estos pasos:

1. Haz clic en **"Mis Tickets"** en el menú lateral.
2. Presiona el botón **"Nuevo Ticket"**.
3. Completa el formulario con la siguiente información:

| Campo | Descripción | Obligatorio |
|-------|-------------|:-----------:|
| **Descripción del problema** | Explica de forma clara y detallada tu solicitud (mínimo 10 caracteres, máximo 10.000). | Sí |
| **Prioridad** | Selecciona el nivel de urgencia del ticket. | Sí |
| **Departamento** | Indica a qué departamento va dirigido el ticket. | Sí |
| **Motivo** | Clasifica la razón del ticket (si aparece disponible). | No |

4. Haz clic en **"Crear Ticket"** para enviarlo.

> **Consejo:** Mientras más detallada sea la descripción, más rápido podrá ser atendido tu ticket.

---

### Estados de un Ticket

Cada ticket pasa por diferentes estados durante su ciclo de vida. A continuación se explica qué significa cada uno:

| Estado | Significado |
|--------|-------------|
| **Abierto** | El ticket fue creado y está pendiente de ser atendido. |
| **En Proceso** | Un agente ya está trabajando en tu solicitud. |
| **En Espera** | Se necesita información adicional o una acción de tu parte para continuar. |
| **Pendiente Aprobación** | El ticket requiere la aprobación de un supervisor antes de avanzar. |
| **Resuelto** | La solicitud fue atendida satisfactoriamente. |
| **Cerrado** | El ticket finalizó y no requiere más acciones. |

---

### Agregar Comentarios

Puedes comunicarte con el equipo de soporte directamente desde la vista detalle de un ticket:

1. Abre el ticket desde **"Mis Tickets"**.
2. Desplázate hasta la sección **"Actividad"** en la parte inferior.
3. Escribe tu comentario en el campo de texto (máximo 1.000 caracteres).
4. Presiona **"Comentar"** o usa el atajo **Ctrl+Enter** para enviar.

**Funciones adicionales:**

- **Comentarios privados:** Si está habilitado, puedes marcar un comentario como privado (solo visible para ti y los administradores).
- **@Menciones:** Escribe `@` seguido del nombre de un usuario para mencionarlo directamente.

---

### Notificaciones

El sistema utiliza notificaciones en tiempo real para mantenerte informado:

- **Nuevo comentario:** Recibirás una notificación instantánea cuando alguien comente en un ticket donde participas.
- **Cambio de estado:** Se te notificará cuando tu ticket cambie de estado (por ejemplo, de "Abierto" a "En Proceso").
- **Asignación:** Si un ticket te es asignado, recibirás un aviso inmediato.

Las notificaciones aparecen como avisos emergentes en la esquina superior derecha de la pantalla. Además, el ícono de campana en la barra superior muestra un contador con tus notificaciones no leídas.

---

---

## Manual de Administrador

### Gestión de Usuarios

Desde la sección **"Usuarios"** del menú lateral, puedes administrar las cuentas del sistema:

- **Crear usuario:** Completa el formulario con nombre, correo electrónico, rol y departamento.
- **Editar usuario:** Modifica la información o el rol de un usuario existente.
- **Activar/Desactivar:** Cambia el estado activo de una cuenta sin eliminarla.

| Rol | Permisos principales |
|-----|---------------------|
| **Administrador** | Acceso total: gestión de usuarios, departamentos, configuración, auditoría y dashboard. |
| **Técnico / Soporte** | Puede ver la cola de trabajo, todos los tickets y atender solicitudes asignadas. |
| **Usuario común** | Puede crear tickets, agregar comentarios y ver únicamente sus propios tickets. |

---

### Asignación y Reasignación de Tickets

Como administrador o supervisor, puedes asignar y reasignar tickets a otros usuarios:

1. Abre el detalle de un ticket.
2. En el panel lateral, selecciona un usuario en el desplegable **"Asignar a usuario…"**.
3. Se abrirá un modal de confirmación con un campo de texto obligatorio.
4. Escribe el **motivo de la asignación** (es obligatorio para reasignaciones).
5. Confirma la acción.

> **Importante:** La reasignación a otro usuario siempre requiere un comentario explicativo. Este comentario queda registrado en el historial del ticket para fines de trazabilidad.

---

### Logs de Auditoría

La sección **"Auditoría"** muestra un registro completo de todas las acciones realizadas en el sistema:

Cada entrada del log incluye:

| Dato | Descripción |
|------|-------------|
| **Tipo de acción** | INSERT, UPDATE, DELETE, LOGIN, LOGOUT, TOGGLE. |
| **Tabla afectada** | La entidad del sistema que fue modificada (ticket, usuario, comentario, etc.). |
| **Usuario** | Quién realizó la acción. |
| **Fecha y hora** | Momento exacto del evento. |
| **Dirección IP** | IP desde la cual se realizó la operación. |

Al expandir un registro, puedes ver una **tabla comparativa** (antes/después) de los valores modificados.

**Filtros disponibles:**
- Filtrar por tipo de acción (INSERT, UPDATE, DELETE…).
- Filtrar por tabla afectada.

---

### Dashboard

El Dashboard presenta un resumen visual del estado general del sistema:

**Indicadores principales (KPIs):**

| KPI | Descripción |
|-----|-------------|
| **Tickets Abiertos** | Cantidad de tickets que requieren atención. |
| **Tickets Cerrados** | Total de tickets resueltos y cerrados. |
| **Tiempo Prom. Resolución** | Promedio de horas que toma resolver un ticket. |
| **No Leídos** | Notificaciones pendientes y tickets asignados sin revisar. |

**Gráficos analíticos:**

- **Tickets por Estado** (gráfico circular): Distribución visual del total de tickets agrupados por estado.
- **Tickets por Prioridad** (gráfico de barras): Cantidad de tickets según su nivel de prioridad.
- **Tickets por Departamento** (gráfico de barras): Volumen de tickets por cada departamento.

---

---

## Diccionario de Términos

| Término | Definición |
|---------|-----------|
| **ID de Ticket** | Número único e irrepetible que identifica a cada ticket en el sistema. Se asigna automáticamente al crear el ticket. |
| **Prioridad** | Nivel de urgencia asignado al ticket (por ejemplo: Baja, Media, Alta, Crítica). Determina el orden de atención. |
| **Departamento** | Área organizacional a la que se dirige el ticket (por ejemplo: Sistemas, Administración, Soporte Técnico). |
| **Motivo** | Clasificación que describe la razón del ticket (por ejemplo: Falla de equipo, Solicitud de acceso, Consulta general). Es opcional al crear un ticket. |
| **Estado** | Fase actual del ticket dentro de su ciclo de vida (Abierto, En Proceso, En Espera, Resuelto, Cerrado). |
| **Asignado** | Usuario responsable de atender y resolver el ticket. |
| **Cola de Trabajo** | Vista donde los técnicos y supervisores encuentran todos los tickets pendientes de atención. |
| **Transición** | Cambio de estado de un ticket (por ejemplo, de "Abierto" a "En Proceso"). Se registra automáticamente. |
| **Auditoría** | Registro histórico de todas las acciones realizadas en el sistema, incluyendo quién las hizo y cuándo. |
| **SignalR** | Tecnología de comunicación en tiempo real que permite recibir notificaciones instantáneas sin recargar la página. |

---

---

## Resolución de Problemas

### Errores comunes y soluciones

| Error | Causa | Solución |
|-------|-------|----------|
| **"La descripción debe tener al menos 10 caracteres"** | La descripción del ticket es demasiado corta. | Escribe una descripción más detallada con al menos 10 caracteres. |
| **"Selecciona una prioridad"** | No se eligió una prioridad al crear el ticket. | Selecciona un nivel de prioridad del desplegable antes de enviar. |
| **"Selecciona un departamento"** | No se eligió un departamento al crear el ticket. | Selecciona un departamento del desplegable antes de enviar. |
| **Sesión expirada** | Tu sesión ha caducado por inactividad o el token de autenticación ha vencido. | Cierra sesión e ingresa nuevamente con tus credenciales. |
| **"No autorizado" (Error 401)** | Intentas acceder a una sección sin permisos suficientes. | Verifica que tu usuario tenga el rol adecuado. Contacta al administrador si necesitas acceso. |
| **"Recurso no encontrado" (Error 404)** | El ticket, usuario o recurso que buscas no existe o fue eliminado. | Verifica el ID o URL. El recurso puede haber sido eliminado por un administrador. |
| **"Servicio temporalmente no disponible" (Error 503)** | El servidor está experimentando alta carga o un problema temporal. | Espera unos segundos y vuelve a intentar. Si persiste, contacta al administrador. |
| **No se reciben notificaciones** | La conexión en tiempo real se desconectó. | Recarga la página con **F5** o **Ctrl+R**. Si el problema persiste, cierra sesión y vuelve a ingresar. |
| **El botón "Comentar" está deshabilitado** | El campo de comentario está vacío. | Escribe al menos un carácter en el campo de texto antes de enviar. |

### ¿Necesitas más ayuda?

Si tu problema no se encuentra en esta lista, contacta al **Administrador del Sistema** proporcionando:

- **Tu nombre de usuario.**
- **Una captura de pantalla del error** (si es posible).
- **Los pasos para reproducir el problema.**
