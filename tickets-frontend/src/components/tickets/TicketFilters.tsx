import { useState, useRef, useEffect } from 'react';
import { useQuery } from '@tanstack/react-query';
import { apiClient } from '../../services/api.service';
import { API_ENDPOINTS } from '../../config/api';
import { ApiResponse, EstadoDTO, PrioridadDTO, MotivoDTO } from '../../types/api.types';
import StatusBadge from './StatusBadge';
import PriorityBadge from './PriorityBadge';
import { Search, X, ChevronDown, ToggleLeft, ToggleRight, SlidersHorizontal, Calendar, Tag } from 'lucide-react';

interface TicketFiltersProps {
  inputValue: string;
  isDebouncing: boolean;
  hasActiveFilters: boolean;
  selectedEstados: number[];
  selectedPrioridades: number[];
  selectedMotivo: number | null;
  fechaDesde: string;
  fechaHasta: string;
  soloMios: boolean;
  showSoloMios?: boolean;
  onSearchChange: (value: string) => void;
  onToggleEstado: (id: number) => void;
  onTogglePrioridad: (id: number) => void;
  onMotivoChange: (id: number | null) => void;
  onFechaDesdeChange: (value: string) => void;
  onFechaHastaChange: (value: string) => void;
  onToggleSoloMios: () => void;
  onClearAll: () => void;
}

/**
 * Barra de filtros reutilizable para listados de tickets.
 * Incluye buscador con debounce, multiselect de Estado/Prioridad,
 * selector de Motivo, date-pickers, toggle "Mis Tickets" y botón Limpiar.
 */
export default function TicketFilters({
  inputValue,
  isDebouncing,
  hasActiveFilters,
  selectedEstados,
  selectedPrioridades,
  selectedMotivo,
  fechaDesde,
  fechaHasta,
  soloMios,
  showSoloMios = true,
  onSearchChange,
  onToggleEstado,
  onTogglePrioridad,
  onMotivoChange,
  onFechaDesdeChange,
  onFechaHastaChange,
  onToggleSoloMios,
  onClearAll,
}: TicketFiltersProps) {
  const [estadoOpen, setEstadoOpen] = useState(false);
  const [prioridadOpen, setPrioridadOpen] = useState(false);
  const [motivoOpen, setMotivoOpen] = useState(false);
  const [showDateFilters, setShowDateFilters] = useState(false);
  const estadoRef = useRef<HTMLDivElement>(null);
  const prioridadRef = useRef<HTMLDivElement>(null);
  const motivoRef = useRef<HTMLDivElement>(null);

  // Cargar catálogos
  const { data: estados } = useQuery({
    queryKey: ['catalogo', 'estados'],
    queryFn: async () => {
      const res = await apiClient.get<ApiResponse<EstadoDTO[]>>(API_ENDPOINTS.ESTADOS);
      return res.data.datos ?? [];
    },
    staleTime: 1000 * 60 * 30,
  });

  const { data: prioridades } = useQuery({
    queryKey: ['catalogo', 'prioridades'],
    queryFn: async () => {
      const res = await apiClient.get<ApiResponse<PrioridadDTO[]>>(API_ENDPOINTS.PRIORIDADES);
      return res.data.datos ?? [];
    },
    staleTime: 1000 * 60 * 30,
  });

  const { data: motivos } = useQuery({
    queryKey: ['catalogo', 'motivos'],
    queryFn: async () => {
      const res = await apiClient.get<ApiResponse<MotivoDTO[]>>(API_ENDPOINTS.MOTIVOS);
      return res.data.datos ?? [];
    },
    staleTime: 1000 * 60 * 30,
  });

  // Cerrar dropdowns al hacer clic fuera
  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (estadoRef.current && !estadoRef.current.contains(e.target as Node)) setEstadoOpen(false);
      if (prioridadRef.current && !prioridadRef.current.contains(e.target as Node)) setPrioridadOpen(false);
      if (motivoRef.current && !motivoRef.current.contains(e.target as Node)) setMotivoOpen(false);
    }
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const closeAllDropdowns = () => { setEstadoOpen(false); setPrioridadOpen(false); setMotivoOpen(false); };

  const activeCount =
    selectedEstados.length +
    selectedPrioridades.length +
    (selectedMotivo !== null ? 1 : 0) +
    (fechaDesde ? 1 : 0) +
    (fechaHasta ? 1 : 0) +
    (soloMios ? 1 : 0) +
    (inputValue ? 1 : 0);

  const motivoNombre = motivos?.find((m) => m.id_Motivo === selectedMotivo)?.nombre;

  // Mostrar date filters si hay alguna fecha activa
  useEffect(() => {
    if (fechaDesde || fechaHasta) setShowDateFilters(true);
  }, [fechaDesde, fechaHasta]);

  return (
    <div className="bg-white rounded-xl border border-slate-200 p-4 space-y-3">
      {/* Fila principal */}
      <div className="flex flex-wrap items-center gap-3">
        {/* Buscador */}
        <div className="flex-1 min-w-[220px] relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 w-4.5 h-4.5" />
          <input
            type="text"
            placeholder="Buscar en título y contenido…"
            className="w-full pl-10 pr-10 py-2.5 border border-slate-200 rounded-lg bg-white text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm transition"
            value={inputValue}
            onChange={(e) => onSearchChange(e.target.value)}
          />
          {isDebouncing && (
            <div className="absolute right-3 top-1/2 -translate-y-1/2">
              <div className="animate-spin rounded-full h-4 w-4 border-2 border-indigo-200 border-t-indigo-600"></div>
            </div>
          )}
          {!isDebouncing && inputValue && (
            <button
              onClick={() => onSearchChange('')}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 transition"
            >
              <X className="w-4 h-4" />
            </button>
          )}
        </div>

        {/* Dropdown Estado */}
        <div className="relative min-w-[130px]" ref={estadoRef}>
          <button
            onClick={() => { setEstadoOpen(!estadoOpen); setPrioridadOpen(false); setMotivoOpen(false); }}
            className={`flex items-center gap-2 px-3.5 py-2.5 border rounded-lg text-sm transition ${
              selectedEstados.length > 0
                ? 'border-indigo-300 bg-indigo-50 text-indigo-700'
                : 'border-slate-200 text-slate-700 hover:bg-slate-50'
            }`}
          >
            <SlidersHorizontal className="w-4 h-4" />
            Estado
            {selectedEstados.length > 0 && (
              <span className="bg-indigo-600 text-white text-xs font-medium rounded-full w-5 h-5 flex items-center justify-center">
                {selectedEstados.length}
              </span>
            )}
            <ChevronDown className={`w-3.5 h-3.5 transition-transform ${estadoOpen ? 'rotate-180' : ''}`} />
          </button>

          {estadoOpen && (
            <div className="absolute z-50 top-full mt-1.5 left-0 bg-white rounded-xl border border-slate-200 shadow-lg shadow-slate-200/50 py-2 min-w-[220px] animate-in fade-in slide-in-from-top-1 duration-150">
              {estados?.map((estado) => {
                const isSelected = selectedEstados.includes(estado.id_Estado);
                return (
                  <button
                    key={estado.id_Estado}
                    onClick={() => onToggleEstado(estado.id_Estado)}
                    className={`w-full flex items-center gap-3 px-4 py-2 text-sm hover:bg-slate-50 transition ${
                      isSelected ? 'bg-indigo-50' : ''
                    }`}
                  >
                    <div className={`w-4 h-4 rounded border-2 flex items-center justify-center transition ${
                      isSelected ? 'border-indigo-600 bg-indigo-600' : 'border-slate-300'
                    }`}>
                      {isSelected && (
                        <svg className="w-2.5 h-2.5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={3}>
                          <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                        </svg>
                      )}
                    </div>
                    <StatusBadge estado={estado.nombre_Estado} size="sm" />
                  </button>
                );
              })}
              {(!estados || estados.length === 0) && (
                <p className="px-4 py-2 text-sm text-slate-400">Cargando…</p>
              )}
            </div>
          )}
        </div>

        {/* Dropdown Prioridad */}
        <div className="relative min-w-[130px]" ref={prioridadRef}>
          <button
            onClick={() => { setPrioridadOpen(!prioridadOpen); setEstadoOpen(false); setMotivoOpen(false); }}
            className={`flex items-center gap-2 px-3.5 py-2.5 border rounded-lg text-sm transition ${
              selectedPrioridades.length > 0
                ? 'border-amber-300 bg-amber-50 text-amber-700'
                : 'border-slate-200 text-slate-700 hover:bg-slate-50'
            }`}
          >
            <SlidersHorizontal className="w-4 h-4" />
            Prioridad
            {selectedPrioridades.length > 0 && (
              <span className="bg-amber-600 text-white text-xs font-medium rounded-full w-5 h-5 flex items-center justify-center">
                {selectedPrioridades.length}
              </span>
            )}
            <ChevronDown className={`w-3.5 h-3.5 transition-transform ${prioridadOpen ? 'rotate-180' : ''}`} />
          </button>

          {prioridadOpen && (
            <div className="absolute z-50 top-full mt-1.5 left-0 bg-white rounded-xl border border-slate-200 shadow-lg shadow-slate-200/50 py-2 min-w-[220px] animate-in fade-in slide-in-from-top-1 duration-150">
              {prioridades?.map((prio) => {
                const isSelected = selectedPrioridades.includes(prio.id_Prioridad);
                return (
                  <button
                    key={prio.id_Prioridad}
                    onClick={() => onTogglePrioridad(prio.id_Prioridad)}
                    className={`w-full flex items-center gap-3 px-4 py-2 text-sm hover:bg-slate-50 transition ${
                      isSelected ? 'bg-amber-50' : ''
                    }`}
                  >
                    <div className={`w-4 h-4 rounded border-2 flex items-center justify-center transition ${
                      isSelected ? 'border-amber-600 bg-amber-600' : 'border-slate-300'
                    }`}>
                      {isSelected && (
                        <svg className="w-2.5 h-2.5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={3}>
                          <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                        </svg>
                      )}
                    </div>
                    <PriorityBadge prioridad={prio.nombre_Prioridad} size="sm" />
                  </button>
                );
              })}
              {(!prioridades || prioridades.length === 0) && (
                <p className="px-4 py-2 text-sm text-slate-400">Cargando…</p>
              )}
            </div>
          )}
        </div>

        {/* Dropdown Motivo */}
        <div className="relative min-w-[120px]" ref={motivoRef}>
          <button
            onClick={() => { setMotivoOpen(!motivoOpen); setEstadoOpen(false); setPrioridadOpen(false); }}
            className={`flex items-center gap-2 px-3.5 py-2.5 border rounded-lg text-sm transition ${
              selectedMotivo !== null
                ? 'border-violet-300 bg-violet-50 text-violet-700'
                : 'border-slate-200 text-slate-700 hover:bg-slate-50'
            }`}
          >
            <Tag className="w-4 h-4" />
            {selectedMotivo !== null ? (motivoNombre || 'Motivo') : 'Motivo'}
            <ChevronDown className={`w-3.5 h-3.5 transition-transform ${motivoOpen ? 'rotate-180' : ''}`} />
          </button>

          {motivoOpen && (
            <div className="absolute z-50 top-full mt-1.5 left-0 bg-white rounded-xl border border-slate-200 shadow-lg shadow-slate-200/50 py-2 min-w-[220px] max-h-[280px] overflow-y-auto animate-in fade-in slide-in-from-top-1 duration-150">
              {/* Opción "Todos" */}
              <button
                onClick={() => { onMotivoChange(null); setMotivoOpen(false); }}
                className={`w-full flex items-center gap-3 px-4 py-2 text-sm hover:bg-slate-50 transition ${
                  selectedMotivo === null ? 'bg-violet-50 font-medium' : ''
                }`}
              >
                <span className="text-slate-500">Todos los motivos</span>
              </button>
              <div className="border-t border-slate-100 my-1" />
              {motivos?.filter((m) => m.activo).map((motivo) => (
                <button
                  key={motivo.id_Motivo}
                  onClick={() => { onMotivoChange(motivo.id_Motivo); setMotivoOpen(false); }}
                  className={`w-full flex items-center gap-3 px-4 py-2 text-sm hover:bg-slate-50 transition ${
                    selectedMotivo === motivo.id_Motivo ? 'bg-violet-50' : ''
                  }`}
                >
                  <div className={`w-4 h-4 rounded-full border-2 flex items-center justify-center transition ${
                    selectedMotivo === motivo.id_Motivo ? 'border-violet-600 bg-violet-600' : 'border-slate-300'
                  }`}>
                    {selectedMotivo === motivo.id_Motivo && (
                      <div className="w-1.5 h-1.5 rounded-full bg-white" />
                    )}
                  </div>
                  <span className="text-slate-700">{motivo.nombre}</span>
                </button>
              ))}
              {(!motivos || motivos.length === 0) && (
                <p className="px-4 py-2 text-sm text-slate-400">Cargando…</p>
              )}
            </div>
          )}
        </div>

        {/* Toggle Fechas */}
        <button
          onClick={() => { setShowDateFilters(!showDateFilters); closeAllDropdowns(); }}
          className={`flex items-center gap-2 px-3.5 py-2.5 border rounded-lg text-sm transition ${
            fechaDesde || fechaHasta
              ? 'border-sky-300 bg-sky-50 text-sky-700'
              : 'border-slate-200 text-slate-700 hover:bg-slate-50'
          }`}
        >
          <Calendar className="w-4 h-4" />
          Fechas
          {(fechaDesde || fechaHasta) && (
            <span className="bg-sky-600 text-white text-xs font-medium rounded-full w-5 h-5 flex items-center justify-center">
              {(fechaDesde ? 1 : 0) + (fechaHasta ? 1 : 0)}
            </span>
          )}
        </button>

        {/* Toggle Mis Tickets */}
        {showSoloMios && (
          <button
            onClick={onToggleSoloMios}
            className={`flex items-center gap-2 px-3.5 py-2.5 border rounded-lg text-sm transition ${
              soloMios
                ? 'border-emerald-300 bg-emerald-50 text-emerald-700'
                : 'border-slate-200 text-slate-700 hover:bg-slate-50'
            }`}
          >
            {soloMios ? <ToggleRight className="w-5 h-5" /> : <ToggleLeft className="w-5 h-5" />}
            Mis Tickets
          </button>
        )}

        {/* Limpiar */}
        {hasActiveFilters && (
          <button
            onClick={onClearAll}
            className="flex items-center gap-1.5 px-3.5 py-2.5 text-sm text-rose-600 border border-rose-200 rounded-lg hover:bg-rose-50 transition"
          >
            <X className="w-4 h-4" />
            Limpiar
            {activeCount > 0 && (
              <span className="bg-rose-100 text-rose-700 text-xs font-medium rounded-full px-1.5 py-0.5">
                {activeCount}
              </span>
            )}
          </button>
        )}
      </div>

      {/* Fila de date-pickers (colapsable) */}
      {showDateFilters && (
        <div className="flex flex-wrap items-center gap-3 pt-1 border-t border-slate-100">
          <span className="text-xs font-medium text-slate-500 uppercase tracking-wider">Rango de fechas</span>
          <div className="flex items-center gap-2">
            <label className="text-xs text-slate-500">Desde</label>
            <input
              type="date"
              value={fechaDesde}
              onChange={(e) => onFechaDesdeChange(e.target.value)}
              max={fechaHasta || undefined}
              className="px-3 py-2 border border-slate-200 rounded-lg text-sm text-slate-700 focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
            />
          </div>
          <div className="flex items-center gap-2">
            <label className="text-xs text-slate-500">Hasta</label>
            <input
              type="date"
              value={fechaHasta}
              onChange={(e) => onFechaHastaChange(e.target.value)}
              min={fechaDesde || undefined}
              className="px-3 py-2 border border-slate-200 rounded-lg text-sm text-slate-700 focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
            />
          </div>
          {(fechaDesde || fechaHasta) && (
            <button
              onClick={() => { onFechaDesdeChange(''); onFechaHastaChange(''); }}
              className="text-xs text-slate-400 hover:text-slate-600 transition"
            >
              <X className="w-3.5 h-3.5" />
            </button>
          )}
        </div>
      )}

      {/* Chips de filtros activos */}
      {(selectedEstados.length > 0 || selectedPrioridades.length > 0 || selectedMotivo !== null) && (
        <div className="flex flex-wrap gap-2 pt-1">
          {selectedEstados.map((id) => {
            const estado = estados?.find((e) => e.id_Estado === id);
            return estado ? (
              <span
                key={`e-${id}`}
                className="inline-flex items-center gap-1.5 bg-slate-100 text-slate-700 text-xs font-medium pl-2 pr-1 py-1 rounded-full"
              >
                <StatusBadge estado={estado.nombre_Estado} size="sm" />
                <button
                  onClick={() => onToggleEstado(id)}
                  className="hover:bg-slate-200 rounded-full p-0.5 transition"
                >
                  <X className="w-3 h-3" />
                </button>
              </span>
            ) : null;
          })}
          {selectedPrioridades.map((id) => {
            const prio = prioridades?.find((p) => p.id_Prioridad === id);
            return prio ? (
              <span
                key={`p-${id}`}
                className="inline-flex items-center gap-1.5 bg-slate-100 text-slate-700 text-xs font-medium pl-2 pr-1 py-1 rounded-full"
              >
                <PriorityBadge prioridad={prio.nombre_Prioridad} size="sm" />
                <button
                  onClick={() => onTogglePrioridad(id)}
                  className="hover:bg-slate-200 rounded-full p-0.5 transition"
                >
                  <X className="w-3 h-3" />
                </button>
              </span>
            ) : null;
          })}
          {selectedMotivo !== null && motivoNombre && (
            <span className="inline-flex items-center gap-1.5 bg-violet-100 text-violet-700 text-xs font-medium pl-2 pr-1 py-1 rounded-full">
              <Tag className="w-3 h-3" />
              {motivoNombre}
              <button
                onClick={() => onMotivoChange(null)}
                className="hover:bg-violet-200 rounded-full p-0.5 transition"
              >
                <X className="w-3 h-3" />
              </button>
            </span>
          )}
        </div>
      )}
    </div>
  );
}
