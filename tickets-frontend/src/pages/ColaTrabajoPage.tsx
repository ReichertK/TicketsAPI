import { useQuery } from '@tanstack/react-query';
import { useNavigate } from 'react-router-dom';
import { apiClient } from '../services/api.service';
import { API_ENDPOINTS } from '../config/api';
import { ApiResponse, PaginatedResponse, TicketDTO } from '../types/api.types';
import { useTicketFilters } from '../hooks/useTicketFilters';
import ErrorAlert from '../components/ui/ErrorAlert';
import TicketFilters from '../components/tickets/TicketFilters';
import StatusBadge from '../components/tickets/StatusBadge';
import PriorityBadge from '../components/tickets/PriorityBadge';
import Pagination from '../components/ui/Pagination';
import EmptyState from '../components/ui/EmptyState';
import SortableHeader from '../components/tickets/SortableHeader';
import { getTicketRowBorderClass } from '../utils/ticketRowBorder';
import { Inbox } from 'lucide-react';

/**
 * Cola de Trabajo: tickets sin asignar para técnicos/admins.
 * forceSinAsignar inyecta SinAsignar=true en todos los requests.
 */
export default function ColaTrabajoPage() {
  const navigate = useNavigate();

  const {
    inputValue, isDebouncing, hasActiveFilters, filters,
    setSearch, toggleEstado, togglePrioridad, setMotivo, setFechaDesde, setFechaHasta, setPage, setPageSize, clearAll, setSorting,
    apiParams, queryKey,
  } = useTicketFilters({ pageSize: 20, forceVista: 'cola', queryKeyBase: 'tickets-cola' });

  const { data, isLoading, isError, error, refetch } = useQuery({
    queryKey,
    queryFn: async () => {
      const res = await apiClient.get<ApiResponse<PaginatedResponse<TicketDTO>>>(
        API_ENDPOINTS.TICKETS,
        { params: apiParams }
      );
      return res.data.datos;
    },
    placeholderData: (prev) => prev,
    retry: 2,
  });

  if (isError) {
    const errMsg = (error as any)?.response?.data?.mensaje || 'No se pudo cargar la cola.';
    return <ErrorAlert title="Error" message={errMsg} onRetry={() => refetch()} />;
  }

  const tickets = data?.datos ?? [];

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex items-center gap-3">
        <div className="p-2 bg-amber-100 rounded-lg">
          <Inbox className="w-6 h-6 text-amber-600" />
        </div>
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Cola de Trabajo</h1>
          <p className="text-sm text-slate-500">
            {data
              ? `${data.totalRegistros} ticket${data.totalRegistros !== 1 ? 's' : ''} pendiente${data.totalRegistros !== 1 ? 's' : ''} de asignación`
              : 'Cargando…'}
          </p>
        </div>
      </div>

      {/* Filtros (sin toggle "Mis Tickets", no aplica aquí) */}
      <TicketFilters
        inputValue={inputValue}
        isDebouncing={isDebouncing}
        hasActiveFilters={hasActiveFilters}
        selectedEstados={filters.estados}
        selectedPrioridades={filters.prioridades}
        selectedMotivo={filters.motivo}
        fechaDesde={filters.fechaDesde}
        fechaHasta={filters.fechaHasta}
        soloMios={false}
        showSoloMios={false}
        onSearchChange={setSearch}
        onToggleEstado={toggleEstado}
        onTogglePrioridad={togglePrioridad}
        onMotivoChange={setMotivo}
        onFechaDesdeChange={setFechaDesde}
        onFechaHastaChange={setFechaHasta}
        onToggleSoloMios={() => {}}
        onClearAll={clearAll}
      />

      {/* Loading */}
      {isLoading && (
        <div className="flex items-center justify-center h-64">
          <div className="animate-spin rounded-full h-10 w-10 border-2 border-amber-200 border-t-amber-600"></div>
        </div>
      )}

      {/* Tabla o Empty State */}
      {!isLoading && tickets.length === 0 ? (
        <EmptyState
          variant={hasActiveFilters ? 'no-results' : 'empty'}
          title={hasActiveFilters ? undefined : 'Cola vacía'}
          message={hasActiveFilters ? undefined : 'No hay tickets pendientes de asignación. ¡Buen trabajo!'}
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
                <SortableHeader label="Departamento" column="departamento" activeColumn={filters.ordenarPor} isDescending={filters.ordenDescendente} onSort={setSorting} className="hidden md:table-cell" />
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
                  <td className="px-6 py-4 text-sm text-slate-500 whitespace-nowrap hidden md:table-cell">
                    {ticket.departamento?.nombre || '-'}
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
