import { useState, useCallback } from 'react';
import { useQuery } from '@tanstack/react-query';
import { apiClient } from '../services/api.service';
import { API_ENDPOINTS } from '../config/api';
import {
  Search, Filter, Activity,
  Database, User, Calendar, RefreshCw, BarChart3, X,
  Plus, Pencil, Trash2, ToggleLeft, LogIn, LogOut, AlertTriangle,
  ChevronDown, Loader2, Download
} from 'lucide-react';
import type {
  ApiResponse, PaginatedResponse, AuditLogDTO,
  AuditLogFiltro, AuditLogStats, AuditLogFiltersOptions
} from '../types/api.types';
import { DiffTable } from '../components/tickets/DiffTable';

// ── Mapas de colores e iconos por acción ──

const ACTION_COLORS: Record<string, { bg: string; text: string; border: string; badge: string }> = {
  INSERT: { bg: 'bg-emerald-50', text: 'text-emerald-700', border: 'border-emerald-200', badge: 'bg-emerald-100' },
  UPDATE: { bg: 'bg-blue-50', text: 'text-blue-700', border: 'border-blue-200', badge: 'bg-blue-100' },
  DELETE: { bg: 'bg-red-50', text: 'text-red-700', border: 'border-red-200', badge: 'bg-red-100' },
  TOGGLE: { bg: 'bg-amber-50', text: 'text-amber-700', border: 'border-amber-200', badge: 'bg-amber-100' },
  LOGIN: { bg: 'bg-violet-50', text: 'text-violet-700', border: 'border-violet-200', badge: 'bg-violet-100' },
  LOGOUT: { bg: 'bg-slate-50', text: 'text-slate-700', border: 'border-slate-200', badge: 'bg-slate-100' },
};

const ACTION_ICONS: Record<string, React.ComponentType<{ className?: string }>> = {
  INSERT: Plus,
  UPDATE: Pencil,
  DELETE: Trash2,
  TOGGLE: ToggleLeft,
  LOGIN: LogIn,
  LOGOUT: LogOut,
};

function getActionColor(action: string) {
  return ACTION_COLORS[action?.toUpperCase()] ?? {
    bg: 'bg-gray-50', text: 'text-gray-700', border: 'border-gray-200', badge: 'bg-gray-100',
  };
}

// ── Utilidades ──

function formatDate(dateStr: string) {
  const d = new Date(dateStr);
  return d.toLocaleString('es-HN', {
    day: '2-digit', month: 'short', year: 'numeric',
    hour: '2-digit', minute: '2-digit', second: '2-digit',
  });
}

// ── Sub-componentes ──

function StatCard({ icon: Icon, label, value, color }: {
  icon: React.ComponentType<{ className?: string }>;
  label: string;
  value: number | string;
  color: string;
}) {
  return (
    <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-4 flex items-center gap-3">
      <div className={`p-2 rounded-lg ${color}`}>
        <Icon className="w-5 h-5" />
      </div>
      <div>
        <p className="text-sm text-gray-500">{label}</p>
        <p className="text-xl font-bold text-gray-900">{value}</p>
      </div>
    </div>
  );
}

function TimelineEntry({ log, isExpanded, onToggle }: {
  log: AuditLogDTO;
  isExpanded: boolean;
  onToggle: () => void;
}) {
  const colors = getActionColor(log.accion);
  const ActionIcon = ACTION_ICONS[log.accion?.toUpperCase()] ?? Activity;

  return (
    <div
      className={`relative border rounded-xl transition-all cursor-pointer ${colors.border} ${isExpanded ? colors.bg : 'bg-white hover:bg-gray-50'}`}
      onClick={onToggle}
    >
      <div className="p-4 flex items-start gap-4">
        <div className={`flex-shrink-0 p-2 rounded-lg ${colors.badge}`}>
          <ActionIcon className={`w-4 h-4 ${colors.text}`} />
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 flex-wrap">
            <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-xs font-semibold ${colors.badge} ${colors.text}`}>
              {log.accion}
            </span>
            <span className="text-sm font-medium text-gray-900 truncate">{log.tabla}</span>
            {log.idRegistro != null && (
              <span className="text-xs text-gray-400">#{log.idRegistro}</span>
            )}
          </div>
          <div className="flex items-center gap-3 mt-1 text-xs text-gray-500">
            <span className="flex items-center gap-1">
              <User className="w-3 h-3" />
              {log.usuarioNombre ?? 'Sistema'}
            </span>
            <span className="flex items-center gap-1">
              <Calendar className="w-3 h-3" />
              {formatDate(log.fecha)}
            </span>
            {log.ipAddress && <span className="text-gray-400">{log.ipAddress}</span>}
          </div>
        </div>
      </div>
      {isExpanded && (
        <div className="px-4 pb-4 pt-0" onClick={(e) => e.stopPropagation()}>
          <DiffTable
            valoresAntiguos={log.valoresAntiguos}
            valoresNuevos={log.valoresNuevos}
            accion={log.accion}
          />
        </div>
      )}
    </div>
  );
}

// ── Componente principal ──

export default function AuditLogsPage() {
  const PAGE_SIZE = 20;
  const [page, setPage] = useState(1);
  const [allLogs, setAllLogs] = useState<AuditLogDTO[]>([]);
  const [hasMore, setHasMore] = useState(true);
  const [totalRecords, setTotalRecords] = useState(0);
  const [expandedId, setExpandedId] = useState<number | null>(null);
  const [filters, setFilters] = useState<AuditLogFiltro>({});
  const [showFilters, setShowFilters] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');

  // ── Clave de filtros para detectar cambios y resetear ──
  const filterKey = JSON.stringify({ ...filters, searchTerm });

  // ── Query: Página actual (append) ──
  const logsQuery = useQuery({
    queryKey: ['audit-logs', page, filterKey],
    queryFn: async () => {
      const params = new URLSearchParams();
      params.set('pagina', String(page));
      params.set('porPagina', String(PAGE_SIZE));
      if (filters.accion) params.set('accion', filters.accion);
      if (filters.tabla) params.set('tabla', filters.tabla);
      if (filters.usuarioId) params.set('usuarioId', String(filters.usuarioId));
      if (filters.fechaDesde) params.set('fechaDesde', filters.fechaDesde);
      if (filters.fechaHasta) params.set('fechaHasta', filters.fechaHasta);
      if (searchTerm) params.set('busqueda', searchTerm);
      const { data } = await apiClient.get<ApiResponse<PaginatedResponse<AuditLogDTO>>>(
        `${API_ENDPOINTS.AUDIT_LOGS}?${params}`
      );
      const result = data.datos!;
      setTotalRecords(result.totalRegistros);
      setHasMore(result.tienePaginaSiguiente);

      // Append — si es página 1 (reset por filtros), reemplazar; sino, anexar
      setAllLogs((prev) => {
        if (page === 1) return result.datos;
        const existingIds = new Set(prev.map((l) => l.idAuditoria));
        const newItems = result.datos.filter((l) => !existingIds.has(l.idAuditoria));
        return [...prev, ...newItems];
      });

      return result;
    },
  });

  // ── Query: Estadísticas ──
  const statsQuery = useQuery({
    queryKey: ['audit-stats'],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<AuditLogStats>>(
        API_ENDPOINTS.AUDIT_LOGS_STATS
      );
      return data.datos!;
    },
  });

  // ── Query: Opciones de filtro ──
  const filterOptionsQuery = useQuery({
    queryKey: ['audit-filter-options'],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<AuditLogFiltersOptions>>(
        API_ENDPOINTS.AUDIT_LOGS_FILTERS
      );
      return data.datos!;
    },
  });

  const stats = statsQuery.data;
  const filterOptions = filterOptionsQuery.data;

  const resetAndSearch = useCallback(() => {
    setAllLogs([]);
    setPage(1);
    setHasMore(true);
  }, []);

  const handleSearch = () => resetAndSearch();

  const clearFilters = () => {
    setFilters({});
    setSearchTerm('');
    resetAndSearch();
  };

  const loadMore = useCallback(() => {
    if (!logsQuery.isFetching && hasMore) {
      setPage((p) => p + 1);
    }
  }, [logsQuery.isFetching, hasMore]);

  const handleFilterChange = useCallback((updater: (f: AuditLogFiltro) => AuditLogFiltro) => {
    setFilters((f) => updater(f));
    setAllLogs([]);
    setPage(1);
    setHasMore(true);
  }, []);

  const activeFilterCount =
    Object.values(filters).filter(Boolean).length + (searchTerm ? 1 : 0);

  // ── Exportar a Excel ──
  const [exporting, setExporting] = useState(false);
  const handleExport = useCallback(async () => {
    try {
      setExporting(true);
      const params = new URLSearchParams();
      if (filters.accion) params.set('accion', filters.accion);
      if (filters.tabla) params.set('tabla', filters.tabla);
      if (filters.usuarioId) params.set('usuarioId', String(filters.usuarioId));
      if (filters.fechaDesde) params.set('fechaDesde', filters.fechaDesde);
      if (filters.fechaHasta) params.set('fechaHasta', filters.fechaHasta);
      if (searchTerm) params.set('busqueda', searchTerm);

      const response = await apiClient.get(`${API_ENDPOINTS.AUDIT_LOGS_EXPORT}?${params}`, {
        responseType: 'blob',
      });
      const blob = new Blob([response.data], {
        type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `auditoria_${new Date().toISOString().slice(0, 10)}.xlsx`;
      a.click();
      URL.revokeObjectURL(url);
    } catch {
      // silenciar
    } finally {
      setExporting(false);
    }
  }, [filters, searchTerm]);

  // ── Render ──
  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 flex items-center gap-2">
            <Activity className="w-7 h-7 text-indigo-600" />
            Auditoría del Sistema
          </h1>
          <p className="text-sm text-gray-500 mt-1">
            Registro de todas las acciones realizadas
          </p>
        </div>
        <div className="flex items-center gap-2">
          <button
            onClick={handleExport}
            disabled={exporting}
            className="flex items-center gap-2 px-4 py-2 bg-emerald-600 text-white border border-emerald-700 rounded-lg text-sm font-medium hover:bg-emerald-700 disabled:opacity-50 transition"
          >
            {exporting ? <Loader2 className="w-4 h-4 animate-spin" /> : <Download className="w-4 h-4" />}
            Exportar Excel
          </button>
          <button
            onClick={() => { logsQuery.refetch(); statsQuery.refetch(); }}
            className="flex items-center gap-2 px-4 py-2 bg-white border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50"
          >
            <RefreshCw className={`w-4 h-4 ${logsQuery.isFetching ? 'animate-spin' : ''}`} />
            Actualizar
          </button>
        </div>
      </div>

      {/* Stats cards (usa los campos reales de AuditLogStats) */}
      {stats && (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <StatCard
            icon={Database}
            label="Total Estimado"
            value={stats.totalEstimado.toLocaleString()}
            color="bg-indigo-100 text-indigo-600"
          />
          <StatCard
            icon={BarChart3}
            label="Tipos de Acción"
            value={Object.keys(stats.porAccion ?? {}).length}
            color="bg-emerald-100 text-emerald-600"
          />
          <StatCard
            icon={User}
            label="Tablas Afectadas"
            value={Object.keys(stats.porTabla ?? {}).length}
            color="bg-blue-100 text-blue-600"
          />
          <StatCard
            icon={Activity}
            label="Rango"
            value={
              stats.primeraFecha
                ? `${new Date(stats.primeraFecha).toLocaleDateString('es-HN')} – ${new Date(stats.ultimaFecha!).toLocaleDateString('es-HN')}`
                : 'N/A'
            }
            color="bg-amber-100 text-amber-600"
          />
        </div>
      )}

      {/* Barra de búsqueda + filtros */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-4">
        <div className="flex items-center gap-3 flex-wrap">
          <div className="relative flex-1 min-w-[200px]">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input
              type="text"
              placeholder="Buscar en registros..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && handleSearch()}
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
            />
          </div>
          <button
            onClick={() => setShowFilters(!showFilters)}
            className={`flex items-center gap-2 px-4 py-2 border rounded-lg text-sm font-medium transition-colors ${
              activeFilterCount > 0
                ? 'bg-indigo-50 border-indigo-300 text-indigo-700'
                : 'bg-white border-gray-300 text-gray-700 hover:bg-gray-50'
            }`}
          >
            <Filter className="w-4 h-4" />
            Filtros{activeFilterCount > 0 && ` (${activeFilterCount})`}
          </button>
          {activeFilterCount > 0 && (
            <button
              onClick={clearFilters}
              className="flex items-center gap-1 px-3 py-2 text-sm text-red-600 hover:bg-red-50 rounded-lg"
            >
              <X className="w-4 h-4" /> Limpiar
            </button>
          )}
        </div>

        {/* Panel de filtros expandible */}
        {showFilters && filterOptions && (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3 mt-4 pt-4 border-t">
            <select
              value={filters.accion ?? ''}
              onChange={(e) => handleFilterChange((f) => ({ ...f, accion: e.target.value || undefined }))}
              className="border border-slate-300 rounded-lg px-3 py-2 text-sm text-slate-900 bg-white focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
            >
              <option value="" className="text-slate-500">Todas las acciones</option>
              {(filterOptions.acciones ?? []).map((a: string) => (
                <option key={a} value={a} className="text-slate-900">{a}</option>
              ))}
            </select>
            <select
              value={filters.tabla ?? ''}
              onChange={(e) => handleFilterChange((f) => ({ ...f, tabla: e.target.value || undefined }))}
              className="border border-slate-300 rounded-lg px-3 py-2 text-sm text-slate-900 bg-white focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
            >
              <option value="" className="text-slate-500">Todas las tablas</option>
              {(filterOptions.tablas ?? []).map((t: string) => (
                <option key={t} value={t} className="text-slate-900">{t}</option>
              ))}
            </select>
            <div className="relative">
              <label className="absolute -top-2 left-2 px-1 bg-white text-xs text-slate-500 z-10">Desde</label>
              <input
                type="date"
                value={filters.fechaDesde ?? ''}
                onChange={(e) => handleFilterChange((f) => ({ ...f, fechaDesde: e.target.value || undefined }))}
                max={filters.fechaHasta || undefined}
                className="border border-slate-300 rounded-lg px-3 py-2 text-sm text-slate-900 bg-white focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 w-full cursor-pointer"
              />
            </div>
            <div className="relative">
              <label className="absolute -top-2 left-2 px-1 bg-white text-xs text-slate-500 z-10">Hasta</label>
              <input
                type="date"
                value={filters.fechaHasta ?? ''}
                onChange={(e) => handleFilterChange((f) => ({ ...f, fechaHasta: e.target.value || undefined }))}
                min={filters.fechaDesde || undefined}
                className="border border-slate-300 rounded-lg px-3 py-2 text-sm text-slate-900 bg-white focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 w-full cursor-pointer"
              />
            </div>
          </div>
        )}
      </div>

      {/* Estado de error */}
      {logsQuery.isError && (
        <div className="bg-red-50 border border-red-200 rounded-xl p-4 flex items-center gap-3 text-red-700">
          <AlertTriangle className="w-5 h-5 flex-shrink-0" />
          <p className="text-sm">
            Error al cargar registros de auditoría.{' '}
            <button onClick={() => logsQuery.refetch()} className="underline font-medium">
              Reintentar
            </button>
          </p>
        </div>
      )}

      {/* Timeline de registros */}
      <div className="space-y-3">
        {logsQuery.isLoading && allLogs.length === 0 ? (
          <div className="text-center py-12 text-gray-500">
            <RefreshCw className="w-8 h-8 mx-auto mb-3 animate-spin text-indigo-400" />
            Cargando registros...
          </div>
        ) : allLogs.length === 0 ? (
          <div className="text-center py-12 text-gray-400">
            <Database className="w-10 h-10 mx-auto mb-3" />
            No se encontraron registros
          </div>
        ) : (
          allLogs.map((log) => (
            <TimelineEntry
              key={log.idAuditoria}
              log={log}
              isExpanded={expandedId === log.idAuditoria}
              onToggle={() =>
                setExpandedId(expandedId === log.idAuditoria ? null : log.idAuditoria)
              }
            />
          ))
        )}
      </div>

      {/* Botón "Cargar registros antiguos" */}
      {allLogs.length > 0 && (
        <div className="flex flex-col items-center gap-2 pt-2">
          <span className="text-xs text-slate-400">
            Mostrando {allLogs.length.toLocaleString()} de {totalRecords > 10000 ? '10,000+' : totalRecords.toLocaleString()} registros
          </span>
          {hasMore ? (
            <button
              onClick={loadMore}
              disabled={logsQuery.isFetching}
              className="flex items-center gap-2 px-6 py-2.5 bg-white border border-slate-300 rounded-xl text-sm font-medium text-slate-700 hover:bg-slate-50 hover:border-slate-400 disabled:opacity-50 transition-all shadow-sm"
            >
              {logsQuery.isFetching ? (
                <Loader2 className="w-4 h-4 animate-spin" />
              ) : (
                <ChevronDown className="w-4 h-4" />
              )}
              {logsQuery.isFetching ? 'Cargando...' : 'Cargar registros antiguos'}
            </button>
          ) : (
            <span className="text-xs text-slate-400 flex items-center gap-1">
              <Database className="w-3 h-3" /> Fin del historial
            </span>
          )}
        </div>
      )}
    </div>
  );
}