import { useState, useCallback } from 'react';
import { useQuery } from '@tanstack/react-query';
import { apiClient } from '../../services/api.service';
import { API_ENDPOINTS } from '../../config/api';
import {
  ArrowRight, User, Calendar, MessageSquare, ChevronDown,
  GitBranch, Loader2, AlertTriangle, CheckCircle2, Clock
} from 'lucide-react';
import type { ApiResponse, PaginatedResponse, TransicionHistorialDTO } from '../../types/api.types';

// Colores por tipo de estado
const ESTADO_COLORS: Record<string, string> = {
  Abierto: 'bg-blue-100 text-blue-700',
  'En Proceso': 'bg-amber-100 text-amber-700',
  Cerrado: 'bg-slate-200 text-slate-700',
  'En Espera': 'bg-orange-100 text-orange-700',
  'Pendiente Aprobaci\u00f3n': 'bg-purple-100 text-purple-700',
  Resuelto: 'bg-emerald-100 text-emerald-700',
  Reabierto: 'bg-red-100 text-red-700',
};

function getEstadoColor(estado: string | null): string {
  if (!estado) return 'bg-gray-100 text-gray-600';
  return ESTADO_COLORS[estado] ?? 'bg-gray-100 text-gray-600';
}

function formatDate(dateStr: string): string {
  const d = new Date(dateStr);
  return d.toLocaleString('es-HN', {
    day: '2-digit', month: 'short', year: 'numeric',
    hour: '2-digit', minute: '2-digit',
  });
}

function relativeTime(dateStr: string): string {
  const diff = Date.now() - new Date(dateStr).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 1) return 'Hace un momento';
  if (mins < 60) return `Hace ${mins}m`;
  const hours = Math.floor(mins / 60);
  if (hours < 24) return `Hace ${hours}h`;
  const days = Math.floor(hours / 24);
  if (days < 30) return `Hace ${days}d`;
  return formatDate(dateStr);
}

// Props
interface TicketHistoryProps {
  ticketId: number;
  className?: string;
}

// Componente principal (Named Export)
export function TicketHistory({ ticketId, className = '' }: TicketHistoryProps) {
  const PAGE_SIZE = 10;
  const [allItems, setAllItems] = useState<TransicionHistorialDTO[]>([]);
  const [page, setPage] = useState(1);
  const [hasMore, setHasMore] = useState(true);
  const [totalCount, setTotalCount] = useState(0);

  const { isLoading, isFetching, isError, refetch } = useQuery({
    queryKey: ['ticket-history', ticketId, page],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<PaginatedResponse<TransicionHistorialDTO>>>(
        `${API_ENDPOINTS.TICKETS_TRANSITIONS_HISTORY(ticketId)}?pagina=${page}&porPagina=${PAGE_SIZE}`
      );
      const result = data.datos!;
      setTotalCount(result.totalRegistros);
      setHasMore(result.tienePaginaSiguiente);

      // Append new items (avoid duplicates)
      setAllItems((prev) => {
        const existingIds = new Set(prev.map((i) => i.idTransicion));
        const newItems = result.datos.filter((i) => !existingIds.has(i.idTransicion));
        return [...prev, ...newItems];
      });

      return result;
    },
    enabled: !!ticketId,
  });

  const loadMore = useCallback(() => {
    if (!isFetching && hasMore) {
      setPage((p) => p + 1);
    }
  }, [isFetching, hasMore]);

  if (isError) {
    return (
      <div className={`bg-red-50 border border-red-200 rounded-xl p-4 flex items-center gap-3 text-red-700 ${className}`}>
        <AlertTriangle className="w-5 h-5 flex-shrink-0" />
        <p className="text-sm">
          Error al cargar historial.{' '}
          <button onClick={() => refetch()} className="underline font-medium">Reintentar</button>
        </p>
      </div>
    );
  }

  return (
    <div className={`space-y-1 ${className}`}>
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <GitBranch className="w-5 h-5 text-indigo-600" />
          <h3 className="text-sm font-bold text-gray-900">Historial de Transiciones</h3>
          {totalCount > 0 && (
            <span className="text-xs text-gray-400">({totalCount})</span>
          )}
        </div>
      </div>

      {/* Loading inicial */}
      {isLoading && allItems.length === 0 && (
        <div className="text-center py-8 text-gray-400">
          <Loader2 className="w-6 h-6 mx-auto mb-2 animate-spin" />
          <p className="text-xs">Cargando historial...</p>
        </div>
      )}

      {/* Sin transiciones */}
      {!isLoading && allItems.length === 0 && (
        <div className="text-center py-8 text-gray-400">
          <Clock className="w-8 h-8 mx-auto mb-2" />
          <p className="text-sm">Sin transiciones registradas</p>
        </div>
      )}

      {/* Timeline */}
      {allItems.length > 0 && (
        <div className="relative">
          {/* L\u00ednea vertical de timeline */}
          <div className="absolute left-4 top-0 bottom-0 w-0.5 bg-gray-200" />

          <div className="space-y-0">
            {allItems.map((t, idx) => (
              <TransicionItem key={t.idTransicion} transicion={t} isFirst={idx === 0} />
            ))}
          </div>
        </div>
      )}

      {/* Bot\u00f3n Cargar m\u00e1s */}
      {hasMore && allItems.length > 0 && (
        <div className="flex justify-center pt-3">
          <button
            onClick={loadMore}
            disabled={isFetching}
            className="flex items-center gap-2 px-4 py-2 text-sm font-medium text-indigo-600 bg-indigo-50 hover:bg-indigo-100 rounded-lg transition-colors disabled:opacity-50"
          >
            {isFetching ? (
              <>
                <Loader2 className="w-4 h-4 animate-spin" />
                Cargando...
              </>
            ) : (
              <>
                <ChevronDown className="w-4 h-4" />
                Cargar m\u00e1s ({allItems.length} de {totalCount})
              </>
            )}
          </button>
        </div>
      )}

      {/* Fin del historial */}
      {!hasMore && allItems.length > 0 && (
        <div className="flex items-center justify-center gap-2 pt-3 text-xs text-gray-400">
          <CheckCircle2 className="w-3 h-3" />
          Fin del historial
        </div>
      )}
    </div>
  );
}

// TransicionItem sub-componente
function TransicionItem({ transicion: t, isFirst }: {
  transicion: TransicionHistorialDTO;
  isFirst: boolean;
}) {
  return (
    <div className="relative pl-10 pb-4">
      {/* Dot en la l\u00ednea del timeline */}
      <div className={`absolute left-2.5 w-3 h-3 rounded-full border-2 border-white z-10 ${
        isFirst ? 'bg-indigo-500' : 'bg-gray-300'
      }`} />

      <div className={`bg-white border rounded-lg p-3 shadow-sm hover:shadow transition-shadow ${
        isFirst ? 'border-indigo-200' : 'border-gray-200'
      }`}>
        {/* Row 1: Cambio de estado */}
        <div className="flex items-center gap-2 flex-wrap">
          {t.estadoFromNombre ? (
            <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-semibold ${getEstadoColor(t.estadoFromNombre)}`}>
              {t.estadoFromNombre}
            </span>
          ) : (
            <span className="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-semibold bg-gray-100 text-gray-500">
              Inicio
            </span>
          )}
          <ArrowRight className="w-3 h-3 text-gray-400 flex-shrink-0" />
          <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-semibold ${getEstadoColor(t.estadoToNombre)}`}>
            {t.estadoToNombre}
          </span>
        </div>

        {/* Row 2: Qui\u00e9n y cu\u00e1ndo */}
        <div className="flex items-center gap-3 mt-1.5 text-xs text-gray-500">
          <span className="flex items-center gap-1">
            <User className="w-3 h-3" />
            {t.usuarioActorNombre ?? 'Sistema'}
          </span>
          <span className="flex items-center gap-1" title={formatDate(t.fecha)}>
            <Calendar className="w-3 h-3" />
            {relativeTime(t.fecha)}
          </span>
        </div>

        {/* Row 3: Comentario / Motivo */}
        {(t.comentario || t.motivo) && (
          <div className="mt-2 p-2 bg-gray-50 rounded text-xs text-gray-600 border-l-2 border-indigo-300">
            <div className="flex items-start gap-1.5">
              <MessageSquare className="w-3 h-3 mt-0.5 flex-shrink-0 text-gray-400" />
              <p>{t.comentario ?? t.motivo}</p>
            </div>
            {t.comentario && t.motivo && (
              <p className="text-[10px] text-gray-400 mt-1">Motivo: {t.motivo}</p>
            )}
          </div>
        )}
      </div>
    </div>
  );
}