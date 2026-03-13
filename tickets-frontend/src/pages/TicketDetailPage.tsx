import { useParams, useNavigate } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useState, useCallback, useEffect } from 'react';
import { apiClient } from '../services/api.service';
import { API_ENDPOINTS } from '../config/api';
import { ApiResponse, TicketDTO, ComentarioDTO, HistorialTicketDTO, TransicionPermitidaDTO, SuscripcionInfoDTO, UsuarioDTO } from '../types/api.types';
import { useAuthStore } from '../store/authStore';
import { sileo } from 'sileo';
import { usePermissions } from '../hooks/usePermission';
import { useSignalR } from '../hooks/useSignalR';
import ErrorAlert from '../components/ui/ErrorAlert';
import StatusBadge from '../components/tickets/StatusBadge';
import PriorityBadge from '../components/tickets/PriorityBadge';
import UserAvatar from '../components/ui/UserAvatar';
import ConfirmActionModal from '../components/ui/ConfirmActionModal';
import {
  ArrowLeft,
  Calendar,
  Building2,
  MessageSquare,
  Send,
  Clock,
  UserCheck,
  XCircle,
  Lock,
  ArrowRightLeft,
  CheckCircle2,
  AlertTriangle,
  History,
  Trash2,
  Edit3,
  Tag,
  Bell,
  BellOff,
  Users,
  type LucideIcon,
} from 'lucide-react';

// ── Timeline Item types ──────────────────────────────────────────
type TimelineEntry =
  | { type: 'comment'; data: ComentarioDTO }
  | { type: 'event'; data: HistorialTicketDTO };

function mergeTimeline(
  comentarios: ComentarioDTO[] = [],
  historial: HistorialTicketDTO[] = []
): TimelineEntry[] {
  const entries: TimelineEntry[] = [
    ...comentarios.map((c) => ({ type: 'comment' as const, data: c })),
    ...historial.map((h) => ({ type: 'event' as const, data: h })),
  ];

  return entries.sort((a, b) => {
    const dateA = a.type === 'comment' ? a.data.fecha_Creacion : a.data.fecha_Cambio;
    const dateB = b.type === 'comment' ? b.data.fecha_Creacion : b.data.fecha_Cambio;
    return new Date(dateA).getTime() - new Date(dateB).getTime();
  });
}

// ── Event icon mapping ───────────────────────────────────────────
function getEventIcon(accion: string): { Icon: LucideIcon; color: string } {
  const lower = accion.toLowerCase();
  if (lower.includes('cread') || lower.includes('abier'))
    return { Icon: CheckCircle2, color: 'text-emerald-500' };
  if (lower.includes('cerr') || lower.includes('resuel'))
    return { Icon: XCircle, color: 'text-slate-500' };
  if (lower.includes('asign'))
    return { Icon: UserCheck, color: 'text-indigo-500' };
  if (lower.includes('transici') || lower.includes('estado') || lower.includes('cambi'))
    return { Icon: ArrowRightLeft, color: 'text-amber-500' };
  if (lower.includes('aprob'))
    return { Icon: CheckCircle2, color: 'text-emerald-500' };
  if (lower.includes('rechaz'))
    return { Icon: AlertTriangle, color: 'text-rose-500' };
  return { Icon: History, color: 'text-slate-400' };
}

// ── Human-readable event labels ──────────────────────────────────
function humanizeAction(accion: string): string {
  const lower = accion.toLowerCase();
  if (lower.includes('creado') || lower.includes('creación')) return 'Ticket creado';
  if (lower.includes('abierto') || lower.includes('reabierto')) return 'Ticket reabierto';
  if (lower.includes('cerrado')) return 'Ticket cerrado';
  if (lower.includes('resuelto')) return 'Ticket resuelto';
  if (lower.includes('asigna')) return 'Asignación actualizada';
  if (lower.includes('transición') || lower.includes('transicion')) return 'Cambio de estado';
  if (lower.includes('cambio de estado')) return 'Cambio de estado';
  if (lower.includes('aprob')) return 'Aprobación procesada';
  if (lower.includes('rechaz')) return 'Rechazado';
  if (lower.includes('comentario')) return 'Comentario del sistema';
  if (lower.includes('edita') || lower.includes('modific')) return 'Ticket editado';
  return accion; // Fallback al texto original
}

// ── Transition button styling ────────────────────────────────────
function getTransitionStyle(nombre: string): { bg: string; text: string; border: string; Icon: LucideIcon } {
  const lower = nombre.toLowerCase();
  if (lower.includes('cerr'))
    return { bg: 'bg-slate-50', text: 'text-slate-700', border: 'border-slate-200', Icon: XCircle };
  if (lower.includes('resuel'))
    return { bg: 'bg-emerald-50', text: 'text-emerald-700', border: 'border-emerald-200', Icon: CheckCircle2 };
  if (lower.includes('proceso'))
    return { bg: 'bg-indigo-50', text: 'text-indigo-700', border: 'border-indigo-200', Icon: ArrowRightLeft };
  if (lower.includes('espera'))
    return { bg: 'bg-amber-50', text: 'text-amber-700', border: 'border-amber-200', Icon: Clock };
  if (lower.includes('aprob'))
    return { bg: 'bg-violet-50', text: 'text-violet-700', border: 'border-violet-200', Icon: CheckCircle2 };
  if (lower.includes('reabier'))
    return { bg: 'bg-sky-50', text: 'text-sky-700', border: 'border-sky-200', Icon: History };
  return { bg: 'bg-slate-50', text: 'text-slate-700', border: 'border-slate-200', Icon: ArrowRightLeft };
}

export default function TicketDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  /** Invalidar todas las listas de tickets (mis-tickets, todos, cola) */
  const invalidateTicketLists = () => {
    queryClient.invalidateQueries({ queryKey: ['mis-tickets'] });
    queryClient.invalidateQueries({ queryKey: ['tickets-todos'] });
    queryClient.invalidateQueries({ queryKey: ['tickets-cola'] });
  };

  const [comentario, setComentario] = useState('');
  const [transitionComment, setTransitionComment] = useState('');
  const [confirmAction, setConfirmAction] = useState<{ type: 'transition' | 'delete' | 'reassign' | 'self-assign'; estadoId?: number; nombre?: string } | null>(null);
  const [assignToUserId, setAssignToUserId] = useState<number | ''>('');
  const [reassignComment, setReassignComment] = useState('');
  const [selfAssignComment, setSelfAssignComment] = useState('');
  const { user, isAdmin } = useAuthStore();
  const { hasPermission } = usePermissions();
  const { subscribeToTicket, unsubscribeFromTicket } = useSignalR();

  const ticketId = Number(id);

  // Suscribirse al grupo SignalR del ticket
  useEffect(() => {
    if (ticketId) {
      subscribeToTicket(ticketId);
      return () => {
        unsubscribeFromTicket(ticketId);
      };
    }
  }, [ticketId, subscribeToTicket, unsubscribeFromTicket]);

  // ── Queries ────────────────────────────────────────────────────
  const { data: ticket, isLoading, isError, error, refetch } = useQuery({
    queryKey: ['ticket', ticketId],
    queryFn: async () => {
      const response = await apiClient.get<ApiResponse<TicketDTO>>(
        API_ENDPOINTS.TICKETS_BY_ID(ticketId)
      );
      return response.data.datos;
    },
    enabled: !!ticketId,
  });

  // Obtener transiciones permitidas dinámicamente
  const { data: transiciones } = useQuery({
    queryKey: ['ticket-transitions', ticketId, ticket?.id_Estado],
    queryFn: async () => {
      const response = await apiClient.get<ApiResponse<TransicionPermitidaDTO[]>>(
        API_ENDPOINTS.TICKETS_TRANSITIONS(ticketId)
      );
      return response.data.datos ?? [];
    },
    enabled: !!ticketId && !!ticket,
    staleTime: 1000 * 30, // 30s
  });

  // Obtener estado de suscripción
  const { data: suscripcionInfo } = useQuery({
    queryKey: ['ticket-subscription', ticketId],
    queryFn: async () => {
      const response = await apiClient.get<ApiResponse<SuscripcionInfoDTO>>(
        API_ENDPOINTS.TICKETS_SUBSCRIBERS(ticketId)
      );
      return response.data.datos;
    },
    enabled: !!ticketId,
    staleTime: 1000 * 60,
  });

  // ── Mutations ──────────────────────────────────────────────────

  const suscribirMutation = useMutation({
    mutationFn: () =>
      sileo.promise(apiClient.post(API_ENDPOINTS.TICKETS_SUBSCRIBE(ticketId)), {
        loading: { title: 'Suscribiendo…' },
        success: { title: 'Suscrito', description: 'Ahora sigues este ticket' },
        error: { title: 'Error', description: 'No se pudo suscribir al ticket' },
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ticket-subscription', ticketId] });
    },
  });

  const desuscribirMutation = useMutation({
    mutationFn: () =>
      sileo.promise(apiClient.delete(API_ENDPOINTS.TICKETS_SUBSCRIBE(ticketId)), {
        loading: { title: 'Desuscribiendo…' },
        success: { title: 'Desuscrito', description: 'Dejaste de seguir este ticket' },
        error: { title: 'Error', description: 'No se pudo desuscribir del ticket' },
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ticket-subscription', ticketId] });
    },
  });

  const comentarioMutation = useMutation({
    mutationFn: (contenido: string) =>
      sileo.promise(
        apiClient.post<ApiResponse<ComentarioDTO>>(
          API_ENDPOINTS.TICKETS_COMMENTS(ticketId),
          { contenido, privado: false }
        ).then((r) => r.data),
        {
          loading: { title: 'Enviando…', description: 'Publicando comentario' },
          success: { title: 'Comentario enviado', description: 'Tu comentario se agregó correctamente' },
          error: { title: 'Error', description: 'No se pudo enviar el comentario' },
        },
      ),
    onSuccess: () => {
      setComentario('');
      queryClient.invalidateQueries({ queryKey: ['ticket', ticketId] });
    },
  });

  const assignMutation = useMutation({
    mutationFn: (comment: string) =>
      sileo.promise(
        apiClient.patch(API_ENDPOINTS.TICKETS_ASSIGN(ticketId), {
          Id_Usuario_Asignado: user!.id_Usuario,
          Comentario: comment,
        }),
        {
          loading: { title: 'Asignando…' },
          success: { title: 'Ticket asignado', description: 'Te has asignado este ticket' },
          error: (err) => ({ title: 'Error', description: (err as any)?.response?.data?.mensaje || 'No se pudo asignar el ticket' }),
        },
      ),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ticket', ticketId] });
      queryClient.invalidateQueries({ queryKey: ['ticket-transitions', ticketId] });
      invalidateTicketLists();
      setSelfAssignComment('');
      setConfirmAction(null);
    },
  });

  // Mutation para asignar a otro usuario (Admin/Supervisor)
  const assignToOtherMutation = useMutation({
    mutationFn: ({ userId, comment }: { userId: number; comment?: string }) =>
      sileo.promise(
        apiClient.patch(API_ENDPOINTS.TICKETS_ASSIGN(ticketId), {
          Id_Usuario_Asignado: userId,
          Comentario: comment || undefined,
        }),
        {
          loading: { title: 'Asignando…' },
          success: { title: 'Ticket asignado', description: 'El ticket fue asignado exitosamente' },
          error: (err) => ({ title: 'Error de asignación', description: (err as any)?.response?.data?.mensaje || 'No se pudo asignar el ticket' }),
        },
      ),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ticket', ticketId] });
      queryClient.invalidateQueries({ queryKey: ['ticket-transitions', ticketId] });
      invalidateTicketLists();
      setAssignToUserId('');
      setReassignComment('');
      setConfirmAction(null);
    },
  });

  // Lista de usuarios para el dropdown de asignación
  const { data: usersList } = useQuery({
    queryKey: ['users-for-assign'],
    queryFn: async () => {
      const response = await apiClient.get<ApiResponse<UsuarioDTO[]>>(API_ENDPOINTS.USUARIOS_PARA_ASIGNAR);
      return response.data.datos ?? [];
    },
    enabled: hasPermission('TKT_ASSIGN'),
    staleTime: 1000 * 60 * 5, // 5 minutos
  });

  const changeStatusMutation = useMutation({
    mutationFn: ({ estadoNuevo, comentario: comment }: { estadoNuevo: number; comentario: string }) =>
      sileo.promise(
        apiClient.patch(API_ENDPOINTS.TICKETS_CHANGE_STATUS(ticketId), {
          id_Estado_Nuevo: estadoNuevo,
          comentario: comment,
        }),
        {
          loading: { title: 'Cambiando estado…' },
          success: { title: 'Estado actualizado', description: 'El estado del ticket fue cambiado' },
          error: (err) => ({ title: 'Error', description: (err as any)?.response?.data?.mensaje || 'No se pudo cambiar el estado' }),
        },
      ),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ticket', ticketId] });
      queryClient.invalidateQueries({ queryKey: ['ticket-transitions', ticketId] });
      invalidateTicketLists();
      queryClient.invalidateQueries({ queryKey: ['dashboard'] });
    },
  });

  const deleteMutation = useMutation({
    mutationFn: () =>
      sileo.promise(apiClient.delete(API_ENDPOINTS.TICKETS_BY_ID(ticketId)), {
        loading: { title: 'Eliminando…' },
        success: { title: 'Ticket eliminado', description: `Ticket #${ticketId} eliminado exitosamente` },
        error: { title: 'Error', description: 'No se pudo eliminar el ticket' },
      }),
    onSuccess: () => {
      invalidateTicketLists();
      queryClient.invalidateQueries({ queryKey: ['dashboard'] });
      navigate('/tickets');
    },
  });

  // Ctrl+Enter para enviar comentario
  const handleKeyDown = useCallback(
    (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
      if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) {
        e.preventDefault();
        if (comentario.trim() && !comentarioMutation.isPending) {
          comentarioMutation.mutate(comentario);
        }
      }
    },
    [comentario, comentarioMutation]
  );

  // ── Loading / Error states ─────────────────────────────────────
  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-96">
        <div className="flex flex-col items-center gap-3">
          <div className="animate-spin rounded-full h-10 w-10 border-b-2 border-indigo-600"></div>
          <p className="text-sm text-slate-500">Cargando ticket…</p>
        </div>
      </div>
    );
  }

  if (isError) {
    const errMsg = (error as any)?.response?.data?.mensaje || 'No se pudo cargar el ticket.';
    return <ErrorAlert title="Error al cargar Ticket" message={errMsg} onRetry={() => refetch()} />;
  }

  if (!ticket) {
    return (
      <div className="flex flex-col items-center justify-center h-96 gap-4">
        <AlertTriangle className="w-12 h-12 text-amber-400" />
        <p className="text-lg text-slate-600">Ticket no encontrado</p>
        <button
          onClick={() => navigate('/tickets')}
          className="text-indigo-600 hover:text-indigo-700 text-sm font-medium"
        >
          Volver a Tickets
        </button>
      </div>
    );
  }

  // ── Derived data ───────────────────────────────────────────────
  const timeline = mergeTimeline(ticket.comentarios, ticket.historial);
  const admin = isAdmin();
  const canAssign = hasPermission('TKT_ASSIGN');
  const canDelete = hasPermission('TKT_DELETE');
  const canEdit = hasPermission('TKT_EDIT_ANY');
  const estadoNombre = ticket.estado?.nombre_Estado?.toLowerCase() ?? '';
  const isClosed = estadoNombre.includes('cerrad');
  const isAssignedToMe = ticket.id_Usuario_Asignado != null && Number(ticket.id_Usuario_Asignado) === Number(user?.id_Usuario);
  const ticketHasOwner = ticket.id_Usuario_Asignado != null && Number(ticket.id_Usuario_Asignado) > 0;
  const hasTransitions = transiciones && transiciones.length > 0;
  // Regla de Oro: puede transicionar el asignado, Admin, o si el ticket no tiene dueño (Supervisor "Iniciar")
  const canTransition = admin || isAssignedToMe || !ticketHasOwner;

  return (
    <div className="space-y-6">
      {/* ── Header ────────────────────────────────────────────────── */}
      <div className="flex items-center gap-4 flex-wrap">
        <button
          onClick={() => navigate('/tickets')}
          className="p-2 hover:bg-slate-100 rounded-lg transition text-slate-500 hover:text-slate-700"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <h1 className="text-2xl font-bold text-slate-900">Ticket #{ticket.id_Tkt}</h1>
        <StatusBadge estado={ticket.estado?.nombre_Estado || 'Sin estado'} size="md" />
        <PriorityBadge prioridad={ticket.prioridad?.nombre_Prioridad || 'Sin prioridad'} size="md" />

        {/* Seguir / Dejar de seguir ticket */}
        <button
          onClick={() => {
            if (suscripcionInfo?.estaSuscrito) {
              desuscribirMutation.mutate();
            } else {
              suscribirMutation.mutate();
            }
          }}
          disabled={suscribirMutation.isPending || desuscribirMutation.isPending}
          className={`flex items-center gap-1.5 px-3 py-2 text-sm font-medium rounded-lg border transition-[color,background-color,transform,opacity] duration-200 disabled:opacity-50 focus-visible:ring-2 focus-visible:ring-indigo-500 focus-visible:ring-offset-2 active:scale-[0.97] ${
            suscripcionInfo?.estaSuscrito
              ? 'bg-indigo-50 text-indigo-700 border-indigo-200 hover:bg-indigo-100'
              : 'bg-slate-50 text-slate-600 border-slate-200 hover:bg-slate-100'
          }`}
          title={suscripcionInfo?.estaSuscrito ? 'Dejar de seguir' : 'Seguir ticket'}
        >
          {suscripcionInfo?.estaSuscrito ? (
            <BellOff className="w-4 h-4" />
          ) : (
            <Bell className="w-4 h-4" />
          )}
          {suscripcionInfo?.estaSuscrito ? 'Siguiendo' : 'Seguir'}
          {(suscripcionInfo?.total ?? 0) > 0 && (
            <span className="ml-1 text-xs bg-slate-200 text-slate-600 px-1.5 py-0.5 rounded-full">
              {suscripcionInfo?.total}
            </span>
          )}
        </button>

        {/* Admin actions en header */}
        {(canEdit || canDelete) && (
          <div className="ml-auto flex items-center gap-2">
            {canEdit && (
              <button
                onClick={() => navigate(`/tickets/${ticket.id_Tkt}/editar`)}
                className="flex items-center gap-1.5 px-3 py-2 text-sm font-medium text-slate-600 bg-slate-100 rounded-lg hover:bg-slate-200 transition-[color,background-color,transform,opacity] duration-200 focus-visible:ring-2 focus-visible:ring-indigo-500 focus-visible:ring-offset-2 active:scale-[0.97]"
              >
                <Edit3 className="w-4 h-4" />
                Editar
              </button>
            )}
            {canDelete && (
              <button
                onClick={() => setConfirmAction({ type: 'delete' })}
                className="flex items-center gap-1.5 px-3 py-2 text-sm font-medium text-rose-600 bg-rose-50 rounded-lg hover:bg-rose-100 transition-[color,background-color,transform,opacity] duration-200 focus-visible:ring-2 focus-visible:ring-rose-500 focus-visible:ring-offset-2 active:scale-[0.97]"
              >
                <Trash2 className="w-4 h-4" />
                Eliminar
              </button>
            )}
          </div>
        )}
      </div>

      {/* ── Two column layout ─────────────────────────────────────── */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* ══ Left column (2/3) ═══════════════════════════════════ */}
        <div className="lg:col-span-2 space-y-6">
          {/* Cabecera con avatar del solicitante */}
          <div className="bg-white rounded-xl border border-slate-200 p-6">
            <div className="flex items-start gap-4 mb-4">
              <UserAvatar
                nombre={ticket.usuarioCreador?.nombre || 'Usuario'}
                apellido={ticket.usuarioCreador?.apellido}
                rol={ticket.usuarioCreador?.rol?.nombre_Rol}
                size="lg"
              />
              <div className="flex-1 min-w-0">
                <p className="text-sm text-slate-500">Creado por</p>
                <p className="text-lg font-semibold text-slate-900">
                  {ticket.usuarioCreador?.nombre} {ticket.usuarioCreador?.apellido || ''}
                </p>
                <p className="text-sm text-slate-400">
                  {ticket.date_Creado ? new Date(ticket.date_Creado).toLocaleString() : ''}
                </p>
              </div>
            </div>

            {/* Descripción con estilo prose */}
            <div className="prose prose-slate prose-sm max-w-none">
              <h3 className="text-base font-semibold text-slate-800 mb-2">Descripción</h3>
              <p className="text-slate-700 whitespace-pre-wrap leading-relaxed">
                {ticket.contenido || 'Sin descripción'}
              </p>
            </div>
          </div>

          {/* ── Panel de Acciones Dinámicas ────────────────────────── */}
          {((hasTransitions && canTransition) || (canAssign && !isClosed) || (!ticketHasOwner && !isClosed) || (admin && !isClosed)) && (
            <div className="bg-white rounded-xl border border-slate-200 p-4">
              <h3 className="text-sm font-semibold text-slate-500 uppercase tracking-wider mb-3">
                Acciones
              </h3>
              <div className="flex flex-wrap gap-2">
                {/* Asignarme: solo si el ticket NO tiene dueño y NO soy yo */}
                {!ticketHasOwner && !isAssignedToMe && !isClosed && (
                  <button
                    onClick={() => setConfirmAction({ type: 'self-assign' })}
                    disabled={assignMutation.isPending}
                    className="flex items-center gap-2 px-4 py-2 text-sm font-medium bg-indigo-50 text-indigo-700 rounded-lg hover:bg-indigo-100 border border-indigo-200 transition-[color,background-color,transform,opacity] duration-200 disabled:opacity-50 focus-visible:ring-2 focus-visible:ring-indigo-500 focus-visible:ring-offset-2 active:scale-[0.97]"
                  >
                    <UserCheck className="w-4 h-4" />
                    {assignMutation.isPending ? 'Asignando…' : 'Asignarme'}
                  </button>
                )}

                {/* Asignar a otro usuario: visible solo para Admin/Supervisor con TKT_ASSIGN */}
                {canAssign && (
                  <div className="flex items-center gap-2">
                    <select
                      value={assignToUserId}
                      onChange={(e) => setAssignToUserId(e.target.value ? Number(e.target.value) : '')}
                      className="px-3 py-2 text-sm border border-slate-200 rounded-lg bg-white text-slate-700 focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                    >
                      <option value="">Asignar a usuario…</option>
                      {usersList?.filter((u) => u.activo && u.id_Usuario !== ticket.id_Usuario_Asignado).map((u) => (
                        <option key={u.id_Usuario} value={u.id_Usuario}>
                          {u.nombre} {u.apellido || ''} ({u.rol?.nombre_Rol || ''})
                        </option>
                      ))}
                    </select>
                    {assignToUserId !== '' && (
                      <button
                        onClick={() => {
                          // Siempre abrir modal con comentario obligatorio
                          setConfirmAction({ type: 'reassign' });
                        }}
                        disabled={assignToOtherMutation.isPending}
                        className="flex items-center gap-2 px-4 py-2 text-sm font-medium bg-sky-50 text-sky-700 rounded-lg hover:bg-sky-100 border border-sky-200 transition-[color,background-color,transform,opacity] duration-200 disabled:opacity-50 focus-visible:ring-2 focus-visible:ring-sky-500 focus-visible:ring-offset-2 active:scale-[0.97]"
                      >
                        <Users className="w-4 h-4" />
                        {assignToOtherMutation.isPending ? 'Asignando…' : 'Asignar'}
                      </button>
                    )}
                  </div>
                )}

                {/* Botones dinámicos de transición — Regla de Oro: solo si estoy asignado o soy Admin */}
                {canTransition && transiciones
                  ?.filter((trans) => !trans.permiso_Requerido || hasPermission(trans.permiso_Requerido))
                  .map((trans) => {
                    const style = getTransitionStyle(trans.nombre_Estado);
                    return (
                      <button
                        key={trans.id_Estado_Destino}
                        onClick={() => setConfirmAction({ type: 'transition', estadoId: trans.id_Estado_Destino, nombre: trans.nombre_Estado })}
                        disabled={changeStatusMutation.isPending}
                        className={`flex items-center gap-2 px-4 py-2 text-sm font-medium ${style.bg} ${style.text} rounded-lg hover:opacity-80 border ${style.border} transition-[color,background-color,transform,opacity] duration-200 disabled:opacity-50 focus-visible:ring-2 focus-visible:ring-indigo-500 focus-visible:ring-offset-2 active:scale-[0.97]`}
                      >
                        <style.Icon className="w-4 h-4" />
                        {changeStatusMutation.isPending ? 'Cambiando…' : `→ ${trans.nombre_Estado}`}
                      </button>
                    );
                  })}

                {/* Admin: Forzar Cierre (siempre visible) */}
                {admin && !isClosed && (
                  <button
                    onClick={() => setConfirmAction({ type: 'transition', estadoId: 3, nombre: 'Cerrado (Admin)' })}
                    disabled={changeStatusMutation.isPending}
                    className="flex items-center gap-2 px-4 py-2 text-sm font-medium bg-rose-50 text-rose-700 rounded-lg hover:bg-rose-100 border border-rose-200 transition disabled:opacity-50"
                  >
                    <Lock className="w-4 h-4" />
                    Forzar Cierre
                  </button>
                )}
              </div>
            </div>
          )}

          {/* ── Timeline & Comentarios ────────────────────────────── */}
          <div className="bg-white rounded-xl border border-slate-200 p-6">
            <h2 className="text-base font-semibold text-slate-900 mb-6 flex items-center gap-2">
              <MessageSquare className="w-5 h-5 text-slate-400" />
              Actividad ({timeline.length})
            </h2>

            {/* Timeline */}
            <div className="relative">
              {/* Línea vertical */}
              {timeline.length > 0 && (
                <div className="absolute left-5 top-0 bottom-0 w-px bg-slate-200" />
              )}

              <div className="space-y-6">
                {timeline.map((entry) => {
                  if (entry.type === 'comment') {
                    const c = entry.data;
                    return (
                      <div key={`c-${c.id_Comentario}`} className="relative flex gap-4 pl-1">
                        <div className="relative z-10 shrink-0">
                          <UserAvatar
                            nombre={c.usuario?.nombre || 'Usuario'}
                            apellido={c.usuario?.apellido}
                            rol={c.usuario?.rol?.nombre_Rol}
                            size="sm"
                          />
                        </div>
                        <div className="flex-1 min-w-0">
                          <div className="bg-slate-50 border border-slate-200 rounded-lg p-4">
                            <div className="flex items-center gap-2 mb-1.5">
                              <span className="text-sm font-semibold text-slate-900">
                                {c.usuario?.nombre || 'Usuario'}
                              </span>
                              <span className="text-xs text-slate-400">
                                {new Date(c.fecha_Creacion).toLocaleString()}
                              </span>
                              {c.privado && (
                                <span className="text-xs bg-amber-100 text-amber-700 px-1.5 py-0.5 rounded">
                                  Privado
                                </span>
                              )}
                            </div>
                            <p className="text-sm text-slate-700 whitespace-pre-wrap">{c.contenido}</p>
                          </div>
                        </div>
                      </div>
                    );
                  }

                  // System event
                  const h = entry.data;
                  const { Icon, color } = getEventIcon(h.accion);
                  const label = humanizeAction(h.accion);
                  return (
                    <div key={`h-${h.id_Historial}`} className="relative flex items-center gap-4 pl-1">
                      <div className={`relative z-10 w-8 h-8 rounded-full bg-white border-2 border-slate-200 flex items-center justify-center shrink-0`}>
                        <Icon className={`w-4 h-4 ${color}`} />
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="text-sm text-slate-600">
                          <span className="font-medium text-slate-800">{label}</span>
                          {h.campo_Modificado && (
                            <span className="ml-1 text-slate-400">
                              — <span className="font-mono text-xs">{h.campo_Modificado}</span>: <span className="line-through text-slate-400">{h.valor_Anterior || '(vacío)'}</span> → <span className="text-slate-700 font-medium">{h.valor_Nuevo || '(vacío)'}</span>
                            </span>
                          )}
                        </p>
                        <p className="text-xs text-slate-400 mt-0.5">
                          {new Date(h.fecha_Cambio).toLocaleString()}
                        </p>
                      </div>
                    </div>
                  );
                })}

                {timeline.length === 0 && (
                  <p className="text-sm text-slate-400 text-center py-6">
                    No hay actividad registrada
                  </p>
                )}
              </div>
            </div>

            {/* ── Caja de comentario ──────────────────────────────── */}
            <div className="mt-6 pt-6 border-t border-slate-200">
              <div className="flex gap-3">
                <UserAvatar
                  nombre={user?.nombre || ''}
                  rol={user?.rol?.nombre_Rol}
                  size="sm"
                  className="mt-1"
                />
                <div className="flex-1">
                  <textarea
                    rows={3}
                    className="w-full px-4 py-3 border border-slate-200 rounded-lg bg-white text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-transparent resize-none text-sm"
                    placeholder="Escribe un comentario… (Ctrl+Enter para enviar)"
                    value={comentario}
                    onChange={(e) => setComentario(e.target.value)}
                    onKeyDown={handleKeyDown}
                  />
                  <div className="flex items-center justify-between mt-2">
                    <p className="text-xs text-slate-400">
                      Ctrl+Enter para enviar
                    </p>
                    <button
                      onClick={() => comentarioMutation.mutate(comentario)}
                      disabled={!comentario.trim() || comentarioMutation.isPending}
                      className="flex items-center gap-2 bg-indigo-600 text-white px-4 py-2 text-sm font-medium rounded-lg hover:bg-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed transition-[color,background-color,transform,opacity] duration-200 focus-visible:ring-2 focus-visible:ring-indigo-500 focus-visible:ring-offset-2 active:scale-[0.97]"
                    >
                      <Send className="w-4 h-4" />
                      {comentarioMutation.isPending ? 'Enviando…' : 'Comentar'}
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* ══ Right column (1/3) — Info sidebar ═══════════════════ */}
        <div className="space-y-6">
          {/* Info del ticket — grid completo */}
          <div className="bg-white rounded-xl border border-slate-200 p-6">
            <h3 className="text-sm font-semibold text-slate-500 uppercase tracking-wider mb-4">
              Información
            </h3>
            <div className="space-y-5">
              {/* Estado */}
              <div>
                <p className="text-xs text-slate-400 mb-1">Estado</p>
                <StatusBadge estado={ticket.estado?.nombre_Estado || 'Sin estado'} size="md" />
              </div>

              {/* Prioridad */}
              <div>
                <p className="text-xs text-slate-400 mb-1">Prioridad</p>
                <PriorityBadge prioridad={ticket.prioridad?.nombre_Prioridad || 'Sin prioridad'} size="md" />
              </div>

              {/* Departamento */}
              <div className="flex items-start gap-3">
                <Building2 className="w-4 h-4 text-slate-400 mt-0.5" />
                <div>
                  <p className="text-xs text-slate-400">Departamento</p>
                  <p className="text-sm font-medium text-slate-900">
                    {ticket.departamento?.nombre || 'Sin departamento'}
                  </p>
                </div>
              </div>

              {/* Motivo */}
              {ticket.id_Motivo && (
                <div className="flex items-start gap-3">
                  <Tag className="w-4 h-4 text-slate-400 mt-0.5" />
                  <div>
                    <p className="text-xs text-slate-400">Motivo</p>
                    <p className="text-sm font-medium text-slate-900">
                      {ticket.motivoNombre || `#${ticket.id_Motivo}`}
                    </p>
                  </div>
                </div>
              )}

              {/* Creado por */}
              <div className="flex items-start gap-3">
                <div className="mt-0.5">
                  <UserAvatar
                    nombre={ticket.usuarioCreador?.nombre || 'U'}
                    rol={ticket.usuarioCreador?.rol?.nombre_Rol}
                    size="sm"
                  />
                </div>
                <div>
                  <p className="text-xs text-slate-400">Creado por</p>
                  <p className="text-sm font-medium text-slate-900">
                    {ticket.usuarioCreador?.nombre || 'Desconocido'}
                  </p>
                </div>
              </div>

              {/* Asignado a */}
              {ticket.usuarioAsignado && (
                <div className="flex items-start gap-3">
                  <div className="mt-0.5">
                    <UserAvatar
                      nombre={ticket.usuarioAsignado.nombre}
                      apellido={ticket.usuarioAsignado.apellido}
                      rol={ticket.usuarioAsignado.rol?.nombre_Rol}
                      size="sm"
                    />
                  </div>
                  <div>
                    <p className="text-xs text-slate-400">Asignado a</p>
                    <p className="text-sm font-medium text-slate-900">
                      {ticket.usuarioAsignado.nombre} {ticket.usuarioAsignado.apellido || ''}
                    </p>
                  </div>
                </div>
              )}

              {!ticket.usuarioAsignado && (
                <div className="flex items-start gap-3">
                  <UserCheck className="w-4 h-4 text-slate-300 mt-0.5" />
                  <div>
                    <p className="text-xs text-slate-400">Asignado a</p>
                    <p className="text-sm text-slate-400 italic">Sin asignar</p>
                  </div>
                </div>
              )}
            </div>
          </div>

          {/* Fechas */}
          <div className="bg-white rounded-xl border border-slate-200 p-6">
            <h3 className="text-sm font-semibold text-slate-500 uppercase tracking-wider mb-4">
              Fechas
            </h3>
            <div className="space-y-4">
              <div className="flex items-start gap-3">
                <Calendar className="w-4 h-4 text-slate-400 mt-0.5" />
                <div>
                  <p className="text-xs text-slate-400">Creado</p>
                  <p className="text-sm font-medium text-slate-900">
                    {ticket.date_Creado ? new Date(ticket.date_Creado).toLocaleString() : '-'}
                  </p>
                </div>
              </div>

              {ticket.date_Asignado && (
                <div className="flex items-start gap-3">
                  <Clock className="w-4 h-4 text-slate-400 mt-0.5" />
                  <div>
                    <p className="text-xs text-slate-400">Asignado</p>
                    <p className="text-sm font-medium text-slate-900">
                      {new Date(ticket.date_Asignado).toLocaleString()}
                    </p>
                  </div>
                </div>
              )}

              {ticket.date_Cierre && (
                <div className="flex items-start gap-3">
                  <Calendar className="w-4 h-4 text-slate-400 mt-0.5" />
                  <div>
                    <p className="text-xs text-slate-400">Cerrado</p>
                    <p className="text-sm font-medium text-slate-900">
                      {new Date(ticket.date_Cierre).toLocaleString()}
                    </p>
                  </div>
                </div>
              )}
            </div>
          </div>

          {/* Transiciones disponibles (info) */}
          {hasTransitions && (
            <div className="bg-white rounded-xl border border-slate-200 p-6">
              <h3 className="text-sm font-semibold text-slate-500 uppercase tracking-wider mb-4">
                Flujo de Trabajo
              </h3>
              <div className="space-y-2">
                {transiciones?.map((t) => (
                  <div key={t.id_Estado_Destino} className="flex items-center justify-between text-sm">
                    <span className="text-slate-600">→ {t.nombre_Estado}</span>
                    <div className="flex items-center gap-1.5">
                      {t.requiere_Propietario && (
                        <span className="text-xs bg-amber-100 text-amber-700 px-1.5 py-0.5 rounded">Asignado</span>
                      )}
                      {t.requiere_Aprobacion && (
                        <span className="text-xs bg-violet-100 text-violet-700 px-1.5 py-0.5 rounded">Aprobación</span>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

        </div>
      </div>

      {/* ── Modales de confirmación ─────────────────────────────── */}
      <ConfirmActionModal
        open={confirmAction?.type === 'transition'}
        variant={confirmAction?.nombre?.toLowerCase().includes('cerr') ? 'danger' : 'info'}
        Icon={ArrowRightLeft}
        title={`Cambiar a ${confirmAction?.nombre || ''}`}
        description={`¿Confirmar el cambio de estado del ticket #${ticket.id_Tkt} a "${confirmAction?.nombre}"?`}
        detail="Se requiere un comentario para registrar la transición."
        confirmText={`Sí, cambiar a ${confirmAction?.nombre || ''}`}
        confirmDisabled={transitionComment.trim().length === 0}
        isPending={changeStatusMutation.isPending}
        onConfirm={() => {
          if (confirmAction?.estadoId && transitionComment.trim()) {
            changeStatusMutation.mutate(
              { estadoNuevo: confirmAction.estadoId, comentario: transitionComment.trim() },
              { onSettled: () => { setConfirmAction(null); setTransitionComment(''); } },
            );
          }
        }}
        onClose={() => { setConfirmAction(null); setTransitionComment(''); }}
      >
        <div className="mt-4 text-left">
          <label htmlFor="transition-comment" className="block text-sm font-medium text-slate-700 mb-1">
            Comentario <span className="text-rose-500">*</span>
          </label>
          <textarea
            id="transition-comment"
            rows={3}
            value={transitionComment}
            onChange={(e) => setTransitionComment(e.target.value)}
            placeholder="Motivo del cambio de estado…"
            className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 resize-none transition"
          />
          {transitionComment.trim().length === 0 && (
            <p className="text-xs text-rose-500 mt-1">El comentario es obligatorio</p>
          )}
        </div>
      </ConfirmActionModal>

      <ConfirmActionModal
        open={confirmAction?.type === 'delete'}
        variant="danger"
        Icon={Trash2}
        title="Eliminar Ticket"
        description={`¿Estás seguro de eliminar el ticket #${ticket.id_Tkt}?`}
        detail="Esta acción es irreversible. El ticket será eliminado permanentemente."
        confirmText="Sí, eliminar"
        isPending={deleteMutation.isPending}
        onConfirm={() => {
          deleteMutation.mutate(undefined, {
            onSettled: () => setConfirmAction(null),
          });
        }}
        onClose={() => setConfirmAction(null)}
      />

      {/* Modal de asignación / reasignación (requiere comentario obligatorio) */}
      <ConfirmActionModal
        open={confirmAction?.type === 'reassign'}
        variant="info"
        Icon={Users}
        title={ticketHasOwner ? 'Reasignar Ticket' : 'Asignar Ticket'}
        description={ticketHasOwner
          ? `El ticket #${ticket.id_Tkt} ya está asignado a ${ticket.usuarioAsignado?.nombre || 'otro usuario'}. ¿Deseas reasignarlo?`
          : `¿Asignar el ticket #${ticket.id_Tkt} al usuario seleccionado?`
        }
        detail="Se requiere un comentario obligatorio que quedará registrado en el historial."
        confirmText={ticketHasOwner ? 'Reasignar' : 'Asignar'}
        confirmDisabled={reassignComment.trim().length === 0}
        isPending={assignToOtherMutation.isPending}
        onConfirm={() => {
          if (assignToUserId !== '' && reassignComment.trim()) {
            assignToOtherMutation.mutate({
              userId: assignToUserId as number,
              comment: reassignComment.trim(),
            });
          }
        }}
        onClose={() => { setConfirmAction(null); setReassignComment(''); }}
      >
        <div className="mt-4 text-left">
          <label htmlFor="reassign-comment" className="block text-sm font-medium text-slate-700 mb-1">
            Motivo de asignación <span className="text-rose-500">*</span>
          </label>
          <textarea
            id="reassign-comment"
            rows={3}
            value={reassignComment}
            onChange={(e) => setReassignComment(e.target.value)}
            placeholder="Explique el motivo de esta asignación…"
            className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 resize-none transition"
          />
          {reassignComment.trim().length === 0 && (
            <p className="text-xs text-rose-500 mt-1">El comentario es obligatorio</p>
          )}
        </div>
      </ConfirmActionModal>

      {/* Modal de auto-asignación (requiere comentario obligatorio) */}
      <ConfirmActionModal
        open={confirmAction?.type === 'self-assign'}
        variant="info"
        Icon={UserCheck}
        title="Asignarme Ticket"
        description={`¿Deseas asignarte el ticket #${ticket.id_Tkt}?`}
        detail="Se requiere un comentario obligatorio que quedará registrado en el historial."
        confirmText="Asignarme"
        confirmDisabled={selfAssignComment.trim().length === 0}
        isPending={assignMutation.isPending}
        onConfirm={() => {
          if (selfAssignComment.trim()) {
            assignMutation.mutate(selfAssignComment.trim());
          }
        }}
        onClose={() => { setConfirmAction(null); setSelfAssignComment(''); }}
      >
        <div className="mt-4 text-left">
          <label htmlFor="self-assign-comment" className="block text-sm font-medium text-slate-700 mb-1">
            Comentario <span className="text-rose-500">*</span>
          </label>
          <textarea
            id="self-assign-comment"
            rows={3}
            value={selfAssignComment}
            onChange={(e) => setSelfAssignComment(e.target.value)}
            placeholder="Motivo de la asignación…"
            className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 resize-none transition"
          />
          {selfAssignComment.trim().length === 0 && (
            <p className="text-xs text-rose-500 mt-1">El comentario es obligatorio</p>
          )}
        </div>
      </ConfirmActionModal>
    </div>
  );
}
