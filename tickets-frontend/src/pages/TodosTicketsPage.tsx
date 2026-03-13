import { useQuery } from '@tanstack/react-query';
import { useNavigate } from 'react-router-dom';
import { apiClient } from '../services/api.service';
import { API_ENDPOINTS } from '../config/api';
import { ApiResponse, PaginatedResponse, TicketDTO, TicketStatsDTO } from '../types/api.types';
import { useTicketFilters } from '../hooks/useTicketFilters';
import { useAuthStore } from '../store/authStore';
import ErrorAlert from '../components/ui/ErrorAlert';
import TicketFilters from '../components/tickets/TicketFilters';
import StatusBadge from '../components/tickets/StatusBadge';
import PriorityBadge from '../components/tickets/PriorityBadge';
import UserAvatar from '../components/ui/UserAvatar';
import Pagination from '../components/ui/Pagination';
import EmptyState from '../components/ui/EmptyState';
import SortableHeader from '../components/tickets/SortableHeader';
import { getTicketRowBorderClass } from '../utils/ticketRowBorder';
import { Layers, CircleDot, UserX, Clock, Hash } from 'lucide-react';

/**
 * Todos los Tickets: vista completa para técnicos/admins.
 * Muestra columna de usuario asignado y búsqueda completa.
 */
export default function TodosTicketsPage() {
  const navigate = useNavigate();
  const user = useAuthStore((s) => s.user);

  const {
    inputValue, isDebouncing, hasActiveFilters, filters,
    setSearch, toggleEstado, togglePrioridad, toggleSoloMios, setPage, clearAll, setSorting,
    setMotivo, setFechaDesde, setFechaHasta, setPageSize,
    apiParams, queryKey,
  } = useTicketFilters({ pageSize: 20, forceVista: 'todos', queryKeyBase: 'tickets-todos' });

  const finalParams = {
    ...apiParams,
    ...(filters.soloMios && user ? { Id_Usuario_Asignado: user.id_Usuario } : {}),
  };

  const { data, isLoading, isError, error, refetch } = useQuery({
    queryKey,
    queryFn: async () => {
      const res = await apiClient.get<ApiResponse<PaginatedResponse<TicketDTO>>>(
        API_ENDPOINTS.TICKETS,
        { params: finalParams }
      );
      return res.data.datos;
    },
    placeholderData: (prev) => prev,
    retry: 2,
  });

  // Mini-dashboard: estadísticas rápidas
  const { data: stats } = useQuery({
    queryKey: ['ticket-stats'],
    queryFn: async () => {
      const res = await apiClient.get<ApiResponse<TicketStatsDTO>>(API_ENDPOINTS.TICKET_STATS);
      return res.data?.datos;
    },
    staleTime: 30_000,
    refetchInterval: 60_000,
  });

  if (isError) {
    const errMsg = (error as any)?.response?.data?.mensaje || 'No se pudieron cargar los tickets.';
    return <ErrorAlert title="Error" message={errMsg} onRetry={() => refetch()} />;
  }

  const tickets = data?.datos ?? [];

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex items-center gap-3">
        <div className="p-2 bg-indigo-100 rounded-lg">
          <Layers className="w-6 h-6 text-indigo-600" />
        </div>
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Todos los Tickets</h1>
          <p className="text-sm text-slate-500">
            {data ? `${data.totalRegistros} ticket${data.totalRegistros !== 1 ? 's' : ''} en el sistema` : 'Cargando…'}
          </p>
        </div>
      </div>

      {/* Mini-Dashboard: Stat Cards */}
      {stats && (
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
          <div className="bg-white rounded-xl border border-slate-200 p-4 flex items-center gap-3">
            <div className="p-2 rounded-lg bg-emerald-100">
              <CircleDot className="w-5 h-5 text-emerald-600" />
            </div>
            <div>
              <p className="text-xs text-slate-500">Abiertos</p>
              <p className="text-xl font-bold text-slate-900">{stats.abiertos}</p>
            </div>
          </div>
          <div className="bg-white rounded-xl border border-slate-200 p-4 flex items-center gap-3">
            <div className="p-2 rounded-lg bg-amber-100">
              <UserX className="w-5 h-5 text-amber-600" />
            </div>
            <div>
              <p className="text-xs text-slate-500">Sin Asignar</p>
              <p className="text-xl font-bold text-slate-900">{stats.sinAsignar}</p>
            </div>
          </div>
          <div className="bg-white rounded-xl border border-slate-200 p-4 flex items-center gap-3">
            <div className="p-2 rounded-lg bg-red-100">
              <Clock className="w-5 h-5 text-red-600" />
            </div>
            <div>
              <p className="text-xs text-slate-500">Vencidos</p>
              <p className="text-xl font-bold text-slate-900">{stats.vencidos}</p>
            </div>
          </div>
          <div className="bg-white rounded-xl border border-slate-200 p-4 flex items-center gap-3">
            <div className="p-2 rounded-lg bg-indigo-100">
              <Hash className="w-5 h-5 text-indigo-600" />
            </div>
            <div>
              <p className="text-xs text-slate-500">Total</p>
              <p className="text-xl font-bold text-slate-900">{stats.totalFiltro}</p>
            </div>
          </div>
        </div>
      )}

      {/* Filtros */}
      <TicketFilters
        inputValue={inputValue}
        isDebouncing={isDebouncing}
        hasActiveFilters={hasActiveFilters}
        selectedEstados={filters.estados}
        selectedPrioridades={filters.prioridades}
        soloMios={filters.soloMios}
        selectedMotivo={filters.motivo}
        fechaDesde={filters.fechaDesde}
        fechaHasta={filters.fechaHasta}
        onMotivoChange={setMotivo}
        onFechaDesdeChange={setFechaDesde}
        onFechaHastaChange={setFechaHasta}
        showSoloMios={true}
        onSearchChange={setSearch}
        onToggleEstado={toggleEstado}
        onTogglePrioridad={togglePrioridad}
        onToggleSoloMios={toggleSoloMios}
        onClearAll={clearAll}
      />

      {/* Loading */}
      {isLoading && (
        <div className="flex items-center justify-center h-64">
          <div className="animate-spin rounded-full h-10 w-10 border-2 border-indigo-200 border-t-indigo-600"></div>
        </div>
      )}

      {/* Tabla o Empty State */}
      {!isLoading && tickets.length === 0 ? (
        <EmptyState
          variant={hasActiveFilters ? 'no-results' : 'empty'}
          action={
            hasActiveFilters ? (
              <button onClick={clearAll} className="text-sm text-indigo-600 hover:text-indigo-700 font-medium">
                Limpiar filtros
              </button>
            ) : undefined
          }
        />
      ) : !isLoading && (
        <div className="bg-white rounded-xl border border-slate-200 overflow-hidden">
          <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-slate-200">
            <thead className="bg-slate-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">ID</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Contenido</th>
                <SortableHeader label="Estado" column="estado" activeColumn={filters.ordenarPor} isDescending={filters.ordenDescendente} onSort={setSorting} />
                <SortableHeader label="Prioridad" column="prioridad" activeColumn={filters.ordenarPor} isDescending={filters.ordenDescendente} onSort={setSorting} />
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider hidden md:table-cell">Asignado</th>
                <SortableHeader label="Fecha" column="fecha" activeColumn={filters.ordenarPor} isDescending={filters.ordenDescendente} onSort={setSorting} className="hidden md:table-cell" />
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200">
              {tickets.map((ticket) => (
                <tr
                  key={ticket.id_Tkt}
                  onClick={() => navigate(`/tickets/${ticket.id_Tkt}`)}
                  className={`hover:bg-slate-50 cursor-pointer transition-colors duration-150 ${getTicketRowBorderClass(ticket.id_Prioridad, ticket.prioridad?.nombre_Prioridad)}`}
                >
                  <td className="px-6 py-4 text-sm font-medium text-slate-900 whitespace-nowrap">#{ticket.id_Tkt}</td>
                  <td className="px-6 py-4 text-sm text-slate-700 max-w-md truncate">{ticket.contenido}</td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <StatusBadge estado={ticket.estado?.nombre_Estado || ''} id={ticket.id_Estado} size="sm" />
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <PriorityBadge prioridad={ticket.prioridad?.nombre_Prioridad || ''} id={ticket.id_Prioridad} size="sm" />
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap hidden md:table-cell">
                    {ticket.usuarioAsignado ? (
                      <div className="flex items-center gap-2">
                        <UserAvatar nombre={ticket.usuarioAsignado.nombre} rol={ticket.usuarioAsignado.rol?.nombre_Rol} size="sm" />
                        <span className="text-sm text-slate-700">{ticket.usuarioAsignado.nombre}</span>
                      </div>
                    ) : (
                      <span className="text-sm text-slate-400 italic">Sin asignar</span>
                    )}
                  </td>
                  <td className="px-6 py-4 text-sm text-slate-500 whitespace-nowrap hidden md:table-cell">
                    {ticket.date_Creado ? new Date(ticket.date_Creado).toLocaleDateString() : '-'}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          </div>
        </div>
      )}

      {/* Paginación */}
      {data && (
        <Pagination
          paginaActual={data.paginaActual}
          totalPaginas={data.totalPaginas}
          totalRegistros={data.totalRegistros}
          tamañoPagina={data.tamañoPagina}
          tienePaginaAnterior={data.tienePaginaAnterior}
          tienePaginaSiguiente={data.tienePaginaSiguiente}
          onPageChange={setPage}
          onPageSizeChange={setPageSize}
        />
      )}
    </div>
  );
}
