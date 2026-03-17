import { useState, useEffect } from 'react';
import { useAuthStore } from '../store/authStore';
import {
  BookOpen,
  ShieldCheck,
  BookA,
  AlertTriangle,
  ChevronRight,
  ArrowUp,
} from 'lucide-react';

/* tipos */

interface TocItem {
  id: string;
  label: string;
  level: 2 | 3;
}

/* componentes de bloque */

function SectionTitle({ id, children }: { id: string; children: React.ReactNode }) {
  return (
    <h2 id={id} className="text-2xl font-bold text-slate-800 mt-12 mb-4 scroll-mt-24 border-b border-slate-200 pb-2">
      {children}
    </h2>
  );
}

function SubSection({ id, children }: { id: string; children: React.ReactNode }) {
  return (
    <h3 id={id} className="text-lg font-semibold text-slate-700 mt-8 mb-3 scroll-mt-24">
      {children}
    </h3>
  );
}

function P({ children }: { children: React.ReactNode }) {
  return <p className="text-slate-600 leading-relaxed mb-3">{children}</p>;
}

function Ol({ children }: { children: React.ReactNode }) {
  return <ol className="list-decimal list-inside space-y-1 text-slate-600 mb-4 pl-2">{children}</ol>;
}

function Ul({ children }: { children: React.ReactNode }) {
  return <ul className="list-disc list-inside space-y-1 text-slate-600 mb-4 pl-2">{children}</ul>;
}

function Tip({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex gap-3 bg-indigo-50 border border-indigo-200 rounded-lg p-4 mb-4 text-sm text-indigo-800">
      <BookOpen className="w-5 h-5 mt-0.5 flex-shrink-0" />
      <div>{children}</div>
    </div>
  );
}

function Warning({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex gap-3 bg-amber-50 border border-amber-200 rounded-lg p-4 mb-4 text-sm text-amber-800">
      <AlertTriangle className="w-5 h-5 mt-0.5 flex-shrink-0" />
      <div>{children}</div>
    </div>
  );
}

function Table({ headers, rows }: { headers: string[]; rows: string[][] }) {
  return (
    <div className="overflow-x-auto mb-6">
      <table className="w-full text-sm border border-slate-200 rounded-lg overflow-hidden">
        <thead>
          <tr className="bg-slate-100">
            {headers.map((h) => (
              <th key={h} className="text-left px-4 py-2.5 font-semibold text-slate-700 border-b border-slate-200">
                {h}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((row, i) => (
            <tr key={i} className="border-b border-slate-100 last:border-0 hover:bg-slate-50 transition-colors">
              {row.map((cell, j) => (
                <td key={j} className="px-4 py-2.5 text-slate-600">
                  {cell}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

/* secciones */

function SeccionUsuario() {
  return (
    <>
      <SectionTitle id="manual-usuario">Manual de Usuario</SectionTitle>

      <SubSection id="crear-ticket">Crear un Ticket</SubSection>
      <P>Para crear un nuevo ticket de soporte, sigue estos pasos:</P>
      <Ol>
        <li>Haz clic en <strong>"Mis Tickets"</strong> en el menú lateral.</li>
        <li>Presiona el botón <strong>"Nuevo Ticket"</strong>.</li>
        <li>Completa el formulario con la siguiente información:</li>
      </Ol>
      <Table
        headers={['Campo', 'Descripción', 'Obligatorio']}
        rows={[
          ['Descripción del problema', 'Explica de forma clara y detallada tu solicitud (mín. 10, máx. 10.000 caracteres).', 'Sí'],
          ['Prioridad', 'Selecciona el nivel de urgencia del ticket.', 'Sí'],
          ['Departamento', 'Indica a qué departamento va dirigido el ticket.', 'Sí'],
          ['Motivo', 'Clasifica la razón del ticket (si aparece disponible).', 'No'],
        ]}
      />
      <Ol>
        <li>Haz clic en <strong>"Crear Ticket"</strong> para enviarlo.</li>
      </Ol>
      <Tip>Mientras más detallada sea la descripción, más rápido podrá ser atendido tu ticket.</Tip>

      <SubSection id="estados">Estados de un Ticket</SubSection>
      <P>Cada ticket pasa por diferentes estados durante su ciclo de vida:</P>
      <Table
        headers={['Estado', 'Significado']}
        rows={[
          ['Abierto', 'El ticket fue creado y está pendiente de ser atendido.'],
          ['En Proceso', 'Un agente ya está trabajando en tu solicitud.'],
          ['En Espera', 'Se necesita información adicional o una acción de tu parte para continuar.'],
          ['Pendiente Aprobación', 'El ticket requiere la aprobación de un supervisor antes de avanzar.'],
          ['Resuelto', 'La solicitud fue atendida satisfactoriamente.'],
          ['Cerrado', 'El ticket finalizó y no requiere más acciones.'],
        ]}
      />

      <SubSection id="comentarios">Agregar Comentarios</SubSection>
      <P>Puedes comunicarte con el equipo de soporte directamente desde la vista detalle de un ticket:</P>
      <Ol>
        <li>Abre el ticket desde <strong>"Mis Tickets"</strong>.</li>
        <li>Desplázate hasta la sección <strong>"Actividad"</strong> en la parte inferior.</li>
        <li>Escribe tu comentario en el campo de texto (máximo 1.000 caracteres).</li>
        <li>Presiona <strong>"Comentar"</strong> o usa el atajo <strong>Ctrl+Enter</strong> para enviar.</li>
      </Ol>
      <Ul>
        <li><strong>Comentarios privados:</strong> Si está habilitado, puedes marcar un comentario como privado (solo visible para ti y los administradores).</li>
        <li><strong>@Menciones:</strong> Escribe <code className="bg-slate-100 px-1.5 py-0.5 rounded text-sm font-mono">@</code> seguido del nombre de un usuario para mencionarlo directamente.</li>
      </Ul>

      <SubSection id="notificaciones">Notificaciones</SubSection>
      <P>El sistema utiliza notificaciones en tiempo real para mantenerte informado:</P>
      <Ul>
        <li><strong>Nuevo comentario:</strong> Recibirás una notificación instantánea cuando alguien comente en un ticket donde participas.</li>
        <li><strong>Cambio de estado:</strong> Se te notificará cuando tu ticket cambie de estado.</li>
        <li><strong>Asignación:</strong> Si un ticket te es asignado, recibirás un aviso inmediato.</li>
      </Ul>
      <P>
        Las notificaciones aparecen como avisos emergentes en la esquina superior derecha.
        Además, el ícono de campana en la barra superior muestra un contador con tus notificaciones no leídas.
      </P>
    </>
  );
}

function SeccionAdmin() {
  return (
    <>
      <SectionTitle id="manual-admin">Manual de Administrador</SectionTitle>

      <SubSection id="gestion-usuarios">Gestión de Usuarios</SubSection>
      <P>Desde la sección <strong>"Usuarios"</strong> del menú lateral, puedes administrar las cuentas del sistema:</P>
      <Ul>
        <li><strong>Crear usuario:</strong> Completa el formulario con nombre, correo electrónico, rol y departamento.</li>
        <li><strong>Editar usuario:</strong> Modifica la información o el rol de un usuario existente.</li>
        <li><strong>Activar/Desactivar:</strong> Cambia el estado activo de una cuenta sin eliminarla.</li>
      </Ul>
      <Table
        headers={['Rol', 'Permisos principales']}
        rows={[
          ['Administrador', 'Acceso total: gestión de usuarios, departamentos, configuración, auditoría y dashboard.'],
          ['Técnico / Soporte', 'Puede ver la cola de trabajo, todos los tickets y atender solicitudes asignadas.'],
          ['Usuario común', 'Puede crear tickets, agregar comentarios y ver únicamente sus propios tickets.'],
        ]}
      />

      <SubSection id="asignacion">Asignación y Reasignación de Tickets</SubSection>
      <P>Como administrador o supervisor, puedes asignar y reasignar tickets a otros usuarios:</P>
      <Ol>
        <li>Abre el detalle de un ticket.</li>
        <li>En el panel lateral, selecciona un usuario en el desplegable <strong>"Asignar a usuario…"</strong>.</li>
        <li>Se abrirá un modal de confirmación con un campo de texto obligatorio.</li>
        <li>Escribe el <strong>motivo de la asignación</strong> (es obligatorio para reasignaciones).</li>
        <li>Confirma la acción.</li>
      </Ol>
      <Warning>
        La reasignación a otro usuario <strong>siempre</strong> requiere un comentario explicativo.
        Este comentario queda registrado en el historial del ticket para fines de trazabilidad.
      </Warning>

      <SubSection id="auditoria">Logs de Auditoría</SubSection>
      <P>La sección <strong>"Auditoría"</strong> muestra un registro completo de todas las acciones realizadas en el sistema:</P>
      <Table
        headers={['Dato', 'Descripción']}
        rows={[
          ['Tipo de acción', 'INSERT, UPDATE, DELETE, LOGIN, LOGOUT, TOGGLE.'],
          ['Tabla afectada', 'La entidad del sistema que fue modificada (ticket, usuario, comentario, etc.).'],
          ['Usuario', 'Quién realizó la acción.'],
          ['Fecha y hora', 'Momento exacto del evento.'],
          ['Dirección IP', 'IP desde la cual se realizó la operación.'],
        ]}
      />
      <P>Al expandir un registro, puedes ver una <strong>tabla comparativa</strong> (antes/después) de los valores modificados.</P>

      <SubSection id="dashboard">Dashboard</SubSection>
      <P>El Dashboard presenta un resumen visual del estado general del sistema:</P>
      <Table
        headers={['KPI', 'Descripción']}
        rows={[
          ['Tickets Abiertos', 'Cantidad de tickets que requieren atención.'],
          ['Tickets Cerrados', 'Total de tickets resueltos y cerrados.'],
          ['Tiempo Prom. Resolución', 'Promedio de horas que toma resolver un ticket.'],
          ['No Leídos', 'Notificaciones pendientes y tickets asignados sin revisar.'],
        ]}
      />
      <P><strong>Gráficos analíticos:</strong></P>
      <Ul>
        <li><strong>Tickets por Estado</strong> (gráfico circular): Distribución visual del total de tickets agrupados por estado.</li>
        <li><strong>Tickets por Prioridad</strong> (gráfico de barras): Cantidad de tickets según su nivel de prioridad.</li>
        <li><strong>Tickets por Departamento</strong> (gráfico de barras): Volumen de tickets por cada departamento.</li>
      </Ul>
    </>
  );
}

function SeccionDiccionario() {
  return (
    <>
      <SectionTitle id="diccionario">Diccionario de Términos</SectionTitle>
      <Table
        headers={['Término', 'Definición']}
        rows={[
          ['ID de Ticket', 'Número único e irrepetible que identifica a cada ticket. Se asigna automáticamente al crearlo.'],
          ['Prioridad', 'Nivel de urgencia asignado al ticket (Baja, Media, Alta, Crítica). Determina el orden de atención.'],
          ['Departamento', 'Área organizacional a la que se dirige el ticket (ej: Sistemas, Administración).'],
          ['Motivo', 'Clasificación que describe la razón del ticket (ej: Falla de equipo, Solicitud de acceso). Opcional al crear.'],
          ['Estado', 'Fase actual del ticket dentro de su ciclo de vida (Abierto, En Proceso, Resuelto, Cerrado, etc.).'],
          ['Asignado', 'Usuario responsable de atender y resolver el ticket.'],
          ['Cola de Trabajo', 'Vista donde los técnicos y supervisores encuentran todos los tickets pendientes de atención.'],
          ['Transición', 'Cambio de estado de un ticket (ej: de "Abierto" a "En Proceso"). Se registra automáticamente.'],
          ['Auditoría', 'Registro histórico de todas las acciones realizadas en el sistema, incluyendo quién las hizo y cuándo.'],
          ['SignalR', 'Tecnología de comunicación en tiempo real que permite recibir notificaciones sin recargar la página.'],
        ]}
      />
    </>
  );
}

function SeccionProblemas() {
  return (
    <>
      <SectionTitle id="problemas">Resolución de Problemas</SectionTitle>

      <SubSection id="errores-comunes">Errores comunes y soluciones</SubSection>
      <Table
        headers={['Error', 'Causa', 'Solución']}
        rows={[
          [
            '"La descripción debe tener al menos 10 caracteres"',
            'La descripción del ticket es demasiado corta.',
            'Escribe una descripción más detallada con al menos 10 caracteres.',
          ],
          [
            '"Selecciona una prioridad"',
            'No se eligió una prioridad al crear el ticket.',
            'Selecciona un nivel de prioridad del desplegable antes de enviar.',
          ],
          [
            '"Selecciona un departamento"',
            'No se eligió un departamento al crear el ticket.',
            'Selecciona un departamento del desplegable antes de enviar.',
          ],
          [
            'Sesión expirada',
            'Tu sesión ha caducado por inactividad o el token venció.',
            'Cierra sesión e ingresa nuevamente con tus credenciales.',
          ],
          [
            '"No autorizado" (Error 401)',
            'Intentas acceder a una sección sin permisos suficientes.',
            'Verifica que tu usuario tenga el rol adecuado. Contacta al administrador.',
          ],
          [
            '"Recurso no encontrado" (Error 404)',
            'El recurso que buscas no existe o fue eliminado.',
            'Verifica el ID o URL. El recurso puede haber sido eliminado.',
          ],
          [
            '"Servicio temporalmente no disponible" (Error 503)',
            'El servidor está experimentando alta carga.',
            'Espera unos segundos y vuelve a intentar. Si persiste, contacta al administrador.',
          ],
          [
            'No se reciben notificaciones',
            'La conexión en tiempo real se desconectó.',
            'Recarga la página con F5. Si persiste, cierra sesión y vuelve a ingresar.',
          ],
          [
            'El botón "Comentar" está deshabilitado',
            'El campo de comentario está vacío.',
            'Escribe al menos un carácter en el campo de texto antes de enviar.',
          ],
        ]}
      />

      <SubSection id="mas-ayuda">¿Necesitas más ayuda?</SubSection>
      <P>Si tu problema no se encuentra en esta lista, contacta al <strong>Administrador del Sistema</strong> proporcionando:</P>
      <Ul>
        <li>Tu nombre de usuario.</li>
        <li>Una captura de pantalla del error (si es posible).</li>
        <li>Los pasos para reproducir el problema.</li>
      </Ul>
    </>
  );
}

/* tabla de contenidos */

const tocUser: TocItem[] = [
  { id: 'manual-usuario', label: 'Manual de Usuario', level: 2 },
  { id: 'crear-ticket', label: 'Crear un Ticket', level: 3 },
  { id: 'estados', label: 'Estados de un Ticket', level: 3 },
  { id: 'comentarios', label: 'Agregar Comentarios', level: 3 },
  { id: 'notificaciones', label: 'Notificaciones', level: 3 },
];

const tocAdmin: TocItem[] = [
  { id: 'manual-admin', label: 'Manual de Administrador', level: 2 },
  { id: 'gestion-usuarios', label: 'Gestión de Usuarios', level: 3 },
  { id: 'asignacion', label: 'Asignación y Reasignación', level: 3 },
  { id: 'auditoria', label: 'Logs de Auditoría', level: 3 },
  { id: 'dashboard', label: 'Dashboard', level: 3 },
];

const tocDiccionario: TocItem[] = [
  { id: 'diccionario', label: 'Diccionario de Términos', level: 2 },
];

const tocProblemas: TocItem[] = [
  { id: 'problemas', label: 'Resolución de Problemas', level: 2 },
  { id: 'errores-comunes', label: 'Errores comunes', level: 3 },
  { id: 'mas-ayuda', label: '¿Necesitas más ayuda?', level: 3 },
];

/* HelpPage */

export default function HelpPage() {
  const { isAdmin } = useAuthStore();
  const admin = isAdmin();
  const [activeId, setActiveId] = useState('');

  const toc: TocItem[] = [
    ...tocUser,
    ...(admin ? tocAdmin : []),
    ...tocDiccionario,
    ...tocProblemas,
  ];

  // Track active section on scroll
  useEffect(() => {
    const ids = toc.map((t) => t.id);
    const observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.isIntersecting) {
            setActiveId(entry.target.id);
          }
        }
      },
      { rootMargin: '-80px 0px -60% 0px', threshold: 0.1 },
    );
    ids.forEach((id) => {
      const el = document.getElementById(id);
      if (el) observer.observe(el);
    });
    return () => observer.disconnect();
  }, [admin]);

  const scrollToTop = () => window.scrollTo({ top: 0, behavior: 'smooth' });

  const iconForSection = (id: string) => {
    if (id.startsWith('manual-usuario') || id === 'crear-ticket' || id === 'estados' || id === 'comentarios' || id === 'notificaciones')
      return <BookOpen className="w-4 h-4" />;
    if (id.startsWith('manual-admin') || id === 'gestion-usuarios' || id === 'asignacion' || id === 'auditoria' || id === 'dashboard')
      return <ShieldCheck className="w-4 h-4" />;
    if (id === 'diccionario') return <BookA className="w-4 h-4" />;
    return <AlertTriangle className="w-4 h-4" />;
  };

  return (
    <div className="flex gap-8 max-w-7xl mx-auto">
      {/* Sidebar TOC (desktop) */}
      <aside className="hidden xl:block w-64 flex-shrink-0">
        <div className="sticky top-24">
          <h4 className="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-4">Contenido</h4>
          <nav className="space-y-0.5">
            {toc.map((item) => {
              const active = activeId === item.id;
              return (
                <a
                  key={item.id}
                  href={`#${item.id}`}
                  className={`
                    flex items-center gap-2 px-3 py-1.5 rounded-lg text-sm transition-all duration-150
                    ${item.level === 3 ? 'pl-8' : 'font-semibold'}
                    ${active
                      ? 'bg-indigo-50 text-indigo-700 border-l-2 border-indigo-600'
                      : 'text-slate-500 hover:text-slate-800 hover:bg-slate-100'
                    }
                  `}
                >
                  {item.level === 2 && iconForSection(item.id)}
                  {item.level === 3 && <ChevronRight className="w-3 h-3 text-slate-400" />}
                  {item.label}
                </a>
              );
            })}
          </nav>
        </div>
      </aside>

      {/* Contenido principal */}
      <article className="flex-1 min-w-0">
        {/* Header */}
        <div className="mb-8">
          <div className="flex items-center gap-3 mb-2">
            <div className="w-10 h-10 rounded-xl bg-indigo-600 flex items-center justify-center shadow-lg shadow-indigo-500/20">
              <span className="text-white font-bold">C</span>
            </div>
            <div>
              <h1 className="text-3xl font-bold text-slate-900">Centro de Ayuda</h1>
              <p className="text-sm text-slate-500">Sistema de Tickets Cediac</p>
            </div>
          </div>
        </div>

        {/* Mobile TOC */}
        <details className="xl:hidden mb-8 bg-white border border-slate-200 rounded-xl p-4">
          <summary className="text-sm font-semibold text-slate-700 cursor-pointer select-none">
            Tabla de Contenidos
          </summary>
          <nav className="mt-3 space-y-1">
            {toc.map((item) => (
              <a
                key={item.id}
                href={`#${item.id}`}
                className={`block text-sm py-1 transition-colors ${item.level === 3 ? 'pl-6 text-slate-500' : 'font-medium text-slate-700'} hover:text-indigo-600`}
              >
                {item.label}
              </a>
            ))}
          </nav>
        </details>

        {/* Secciones */}
        <div className="bg-white rounded-xl border border-slate-200 p-6 sm:p-8 lg:p-10 shadow-sm">
          <SeccionUsuario />
          {admin && <SeccionAdmin />}
          <SeccionDiccionario />
          <SeccionProblemas />
        </div>

        {/* Scroll to top */}
        <div className="flex justify-center mt-8 mb-4">
          <button
            onClick={scrollToTop}
            className="flex items-center gap-2 px-4 py-2 text-sm text-slate-500 hover:text-indigo-600 bg-white border border-slate-200 rounded-lg hover:border-indigo-300 transition-all"
          >
            <ArrowUp className="w-4 h-4" />
            Volver arriba
          </button>
        </div>
      </article>
    </div>
  );
}
