import { useState, useEffect, useCallback, useMemo } from 'react';

export type SortColumn = 'fecha' | 'estado' | 'prioridad' | 'departamento';

interface TicketFilterState {
  busqueda: string;
  estados: number[];
  prioridades: number[];
  motivo: number | null;
  fechaDesde: string;   // ISO date string 'YYYY-MM-DD' or ''
  fechaHasta: string;   // ISO date string 'YYYY-MM-DD' or ''
  soloMios: boolean;
  sinAsignar: boolean;
  pagina: number;
  tamañoPagina: number;
  ordenarPor: SortColumn;
  ordenDescendente: boolean;
}

interface UseTicketFiltersOptions {
  /** Tamaño de página por defecto */
  pageSize?: number;
  /** Forzar filtro sinAsignar (para Cola de Trabajo) */
  forceSinAsignar?: boolean;
  /** Vista del SP a utilizar: 'mis-tickets' | 'cola' | 'todos' */
  forceVista?: string;
  /** Query key base para React Query */
  queryKeyBase?: string;
}

const INITIAL_STATE: TicketFilterState = {
  busqueda: '',
  estados: [],
  prioridades: [],
  motivo: null,
  fechaDesde: '',
  fechaHasta: '',
  soloMios: false,
  sinAsignar: false,
  pagina: 1,
  tamañoPagina: 20,
  ordenarPor: 'fecha',
  ordenDescendente: true,
};

/**
 * Hook centralizado para gestionar filtros de tickets.
 * Incluye debounce de búsqueda y parámetros listos para React Query.
 */
export function useTicketFilters(options: UseTicketFiltersOptions = {}) {
  const { pageSize = 20, forceSinAsignar = false, forceVista, queryKeyBase = 'tickets' } = options;

  const [filters, setFilters] = useState<TicketFilterState>({
    ...INITIAL_STATE,
    tamañoPagina: pageSize,
    sinAsignar: forceSinAsignar,
  });

  // Debounce: el input de texto se actualiza inmediatamente en el UI,
  // pero el término real de búsqueda se retrasa 500ms.
  const [inputValue, setInputValue] = useState('');
  const [debouncedSearch, setDebouncedSearch] = useState('');

  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedSearch(inputValue);
      // Reset a página 1 cuando cambia la búsqueda
      setFilters((prev) => ({ ...prev, busqueda: inputValue, pagina: 1 }));
    }, 500);
    return () => clearTimeout(timer);
  }, [inputValue]);

  const isDebouncing = inputValue !== debouncedSearch;

  // --- Acciones ---

  const setSearch = useCallback((value: string) => {
    setInputValue(value);
  }, []);

  const toggleEstado = useCallback((id: number) => {
    setFilters((prev) => ({
      ...prev,
      estados: prev.estados.includes(id)
        ? prev.estados.filter((e) => e !== id)
        : [...prev.estados, id],
      pagina: 1,
    }));
  }, []);

  const togglePrioridad = useCallback((id: number) => {
    setFilters((prev) => ({
      ...prev,
      prioridades: prev.prioridades.includes(id)
        ? prev.prioridades.filter((p) => p !== id)
        : [...prev.prioridades, id],
      pagina: 1,
    }));
  }, []);

  const setMotivo = useCallback((id: number | null) => {
    setFilters((prev) => ({ ...prev, motivo: id, pagina: 1 }));
  }, []);

  const setFechaDesde = useCallback((value: string) => {
    setFilters((prev) => ({ ...prev, fechaDesde: value, pagina: 1 }));
  }, []);

  const setFechaHasta = useCallback((value: string) => {
    setFilters((prev) => ({ ...prev, fechaHasta: value, pagina: 1 }));
  }, []);

  const toggleSoloMios = useCallback(() => {
    setFilters((prev) => ({ ...prev, soloMios: !prev.soloMios, pagina: 1 }));
  }, []);

  const setPage = useCallback((page: number) => {
    setFilters((prev) => ({ ...prev, pagina: page }));
  }, []);

  const setPageSize = useCallback((size: number) => {
    setFilters((prev) => ({ ...prev, tamañoPagina: size, pagina: 1 }));
  }, []);

  const clearAll = useCallback(() => {
    setInputValue('');
    setDebouncedSearch('');
    setFilters({
      ...INITIAL_STATE,
      tamañoPagina: pageSize,
      sinAsignar: forceSinAsignar,
    });
  }, [pageSize, forceSinAsignar]);

  /** Alterna ordenamiento: si ya ordena por esa columna, invierte la dirección; si no, la activa DESC */
  const setSorting = useCallback((column: SortColumn) => {
    setFilters((prev) => ({
      ...prev,
      ordenarPor: column,
      ordenDescendente: prev.ordenarPor === column ? !prev.ordenDescendente : true,
      pagina: 1,
    }));
  }, []);

  const hasActiveFilters = useMemo(() => {
    return (
      filters.busqueda.length > 0 ||
      filters.estados.length > 0 ||
      filters.prioridades.length > 0 ||
      filters.motivo !== null ||
      filters.fechaDesde.length > 0 ||
      filters.fechaHasta.length > 0 ||
      filters.soloMios
    );
  }, [filters]);

  // --- Parámetros para la API ---
  const apiParams = useMemo(() => {
    const params: Record<string, unknown> = {
      Pagina: filters.pagina,
      TamañoPagina: filters.tamañoPagina,
      Ordenar_Por: filters.ordenarPor,
      Orden_Descendente: filters.ordenDescendente,
    };
    if (debouncedSearch) params.Busqueda = debouncedSearch;
    if (filters.estados.length === 1) params.Id_Estado = filters.estados[0];
    if (filters.prioridades.length === 1) params.Id_Prioridad = filters.prioridades[0];
    if (filters.motivo !== null) params.Id_Motivo = filters.motivo;
    if (filters.fechaDesde) params.Fecha_Desde = filters.fechaDesde;
    if (filters.fechaHasta) params.Fecha_Hasta = filters.fechaHasta;
    if (filters.sinAsignar) params.SinAsignar = true;
    if (forceVista) params.Vista = forceVista;
    return params;
  }, [filters, debouncedSearch, forceVista]);

  // --- Query Key para React Query (cambia cuando cambian los filtros) ---
  const queryKey = useMemo(
    () => [queryKeyBase, filters.pagina, filters.tamañoPagina, debouncedSearch, filters.estados, filters.prioridades, filters.motivo, filters.fechaDesde, filters.fechaHasta, filters.soloMios, filters.sinAsignar, filters.ordenarPor, filters.ordenDescendente],
    [queryKeyBase, filters, debouncedSearch]
  );

  return {
    // State
    filters,
    inputValue,
    isDebouncing,
    hasActiveFilters,

    // Actions
    setSearch,
    toggleEstado,
    togglePrioridad,
    setMotivo,
    setFechaDesde,
    setFechaHasta,
    toggleSoloMios,
    setPage,
    setPageSize,
    clearAll,
    setSorting,

    // Para React Query
    apiParams,
    queryKey,
  };
}
