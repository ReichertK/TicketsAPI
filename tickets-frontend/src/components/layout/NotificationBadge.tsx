import { useState, useRef, useEffect } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useNavigate } from 'react-router-dom';
import { Bell, CheckCheck, ExternalLink, User, Clock } from 'lucide-react';
import { apiClient } from '../../services/api.service';
import { API_ENDPOINTS } from '../../config/api';
import type { ApiResponse, NotificacionResumenDTO } from '../../types/api.types';

export default function NotificationBadge() {
  const [open, setOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  // ── Polling cada 60s ───────────────────────────────────────────
  const { data: resumen } = useQuery({
    queryKey: ['notificaciones-resumen'],
    queryFn: async () => {
      const res = await apiClient.get<ApiResponse<NotificacionResumenDTO>>(
        API_ENDPOINTS.NOTIFICACIONES_RESUMEN,
      );
      return res.data.datos;
    },
    refetchInterval: 60_000,
    staleTime: 30_000,
  });

  // ── Marcar todas como leídas ───────────────────────────────────
  const markAll = useMutation({
    mutationFn: async () => {
      await apiClient.patch(API_ENDPOINTS.NOTIFICACIONES_MARCAR_TODOS);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notificaciones-resumen'] });
    },
  });

  // ── Click fuera cierra dropdown ────────────────────────────────
  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target as Node)) {
        setOpen(false);
      }
    }
    if (open) document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [open]);

  const total = resumen?.totalNoLeidos ?? 0;
  const pendientes = resumen?.pendientesAsignados ?? 0;
  const ultimos = resumen?.ultimosNoLeidos ?? [];

  return (
    <div className="relative" ref={dropdownRef}>
      {/* ── Bell button ─────────────────────────────────────────── */}
      <button
        onClick={() => setOpen((prev) => !prev)}
        className="relative p-2 text-slate-500 hover:text-indigo-600 hover:bg-slate-100 rounded-lg transition"
        title="Notificaciones"
      >
        <Bell className="w-5 h-5" />
        {total > 0 && (
          <span className="absolute -top-0.5 -right-0.5 flex items-center justify-center min-w-[18px] h-[18px] px-1 text-[10px] font-bold text-white bg-rose-500 rounded-full ring-2 ring-white">
            {total > 99 ? '99+' : total}
          </span>
        )}
      </button>

      {/* ── Dropdown ────────────────────────────────────────────── */}
      {open && (
        <div className="absolute right-0 mt-2 w-80 bg-white rounded-xl border border-slate-200 shadow-xl z-50 overflow-hidden">
          {/* Header */}
          <div className="flex items-center justify-between px-4 py-3 border-b border-slate-100 bg-slate-50">
            <div>
              <p className="text-sm font-semibold text-slate-800">Notificaciones</p>
              {pendientes > 0 && (
                <p className="text-xs text-indigo-600 font-medium">
                  {pendientes} pendiente{pendientes !== 1 ? 's' : ''} asignado{pendientes !== 1 ? 's' : ''}
                </p>
              )}
            </div>
            {total > 0 && (
              <button
                onClick={() => markAll.mutate()}
                disabled={markAll.isPending}
                className="flex items-center gap-1 text-xs text-indigo-600 hover:text-indigo-800 font-medium transition disabled:opacity-50"
              >
                <CheckCheck className="w-3.5 h-3.5" />
                Marcar todas
              </button>
            )}
          </div>

          {/* List */}
          <div className="max-h-72 overflow-y-auto divide-y divide-slate-100">
            {ultimos.length === 0 ? (
              <div className="flex flex-col items-center py-8 text-slate-400">
                <Bell className="w-8 h-8 mb-2 opacity-40" />
                <p className="text-sm">Sin notificaciones nuevas</p>
              </div>
            ) : (
              ultimos.map((n) => (
                <button
                  key={n.id_Ticket}
                  onClick={() => {
                    setOpen(false);
                    navigate(`/tickets/${n.id_Ticket}`);
                  }}
                  className="w-full flex items-start gap-3 px-4 py-3 text-left hover:bg-indigo-50/60 transition group"
                >
                  <div className="mt-0.5 p-1.5 rounded-lg bg-indigo-100 text-indigo-600 group-hover:bg-indigo-200 transition shrink-0">
                    {n.es_Asignado_A_Mi ? <User className="w-3.5 h-3.5" /> : <ExternalLink className="w-3.5 h-3.5" />}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-slate-800 truncate">
                      #{n.id_Ticket} — {n.contenido || 'Sin contenido'}
                    </p>
                    <div className="flex items-center gap-2 mt-0.5">
                      <span className="text-xs text-slate-500">{n.estado_Nombre}</span>
                      {n.prioridad_Nombre && (
                        <>
                          <span className="text-slate-300">·</span>
                          <span className="text-xs text-slate-500">{n.prioridad_Nombre}</span>
                        </>
                      )}
                    </div>
                    {n.fecha_Cambio && (
                      <div className="flex items-center gap-1 mt-1 text-xs text-slate-400">
                        <Clock className="w-3 h-3" />
                        {new Date(n.fecha_Cambio).toLocaleString('es', {
                          day: '2-digit',
                          month: 'short',
                          hour: '2-digit',
                          minute: '2-digit',
                        })}
                      </div>
                    )}
                  </div>
                  {n.es_Asignado_A_Mi && (
                    <span className="shrink-0 mt-1 px-1.5 py-0.5 text-[10px] font-semibold bg-amber-100 text-amber-700 rounded">
                      Asignado
                    </span>
                  )}
                </button>
              ))
            )}
          </div>

          {/* Footer */}
          {total > ultimos.length && (
            <div className="px-4 py-2.5 border-t border-slate-100 bg-slate-50 text-center">
              <button
                onClick={() => {
                  setOpen(false);
                  navigate('/tickets');
                }}
                className="text-xs font-medium text-indigo-600 hover:text-indigo-800 transition"
              >
                Ver todos los tickets ({total} no leídos)
              </button>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
