import { ChevronLeft, ChevronRight } from 'lucide-react';

interface PaginationProps {
  paginaActual: number;
  totalPaginas: number;
  totalRegistros: number;
  tamañoPagina: number;
  tienePaginaAnterior: boolean;
  tienePaginaSiguiente: boolean;
  onPageChange: (page: number) => void;
  onPageSizeChange?: (size: number) => void;
}

const PAGE_SIZE_OPTIONS = [10, 15, 20, 25, 50];

/**
 * Paginación visual reutilizable para listados.
 * Muestra "Mostrando X-Y de Z" + selector de filas por página + botones de página.
 */
export default function Pagination({
  paginaActual,
  totalPaginas,
  totalRegistros,
  tamañoPagina,
  tienePaginaAnterior,
  tienePaginaSiguiente,
  onPageChange,
  onPageSizeChange,
}: PaginationProps) {
  if (totalPaginas <= 1 && !onPageSizeChange) return null;

  const desde = (paginaActual - 1) * tamañoPagina + 1;
  const hasta = Math.min(paginaActual * tamañoPagina, totalRegistros);

  // Generar números de página visibles (máx 5, centrados)
  const getPageNumbers = (): (number | 'ellipsis')[] => {
    if (totalPaginas <= 5) {
      return Array.from({ length: totalPaginas }, (_, i) => i + 1);
    }
    const pages: (number | 'ellipsis')[] = [];
    if (paginaActual <= 3) {
      pages.push(1, 2, 3, 4, 'ellipsis', totalPaginas);
    } else if (paginaActual >= totalPaginas - 2) {
      pages.push(1, 'ellipsis', totalPaginas - 3, totalPaginas - 2, totalPaginas - 1, totalPaginas);
    } else {
      pages.push(1, 'ellipsis', paginaActual - 1, paginaActual, paginaActual + 1, 'ellipsis', totalPaginas);
    }
    return pages;
  };

  return (
    <div className="flex flex-col sm:flex-row items-center justify-between gap-3 bg-white px-5 py-3 rounded-xl border border-slate-200">
      <div className="flex items-center gap-4">
        <p className="text-sm text-slate-600">
          Mostrando <span className="font-medium text-slate-900">{desde}</span>
          {' – '}
          <span className="font-medium text-slate-900">{hasta}</span>
          {' de '}
          <span className="font-medium text-slate-900">{totalRegistros}</span> resultados
        </p>

        {onPageSizeChange && (
          <div className="flex items-center gap-2">
            <label className="text-sm text-slate-500">Filas:</label>
            <select
              value={tamañoPagina}
              onChange={(e) => onPageSizeChange(Number(e.target.value))}
              className="border border-slate-200 rounded-lg px-2 py-1.5 text-sm text-slate-700 bg-white focus:ring-2 focus:ring-indigo-500 focus:border-transparent cursor-pointer"
            >
              {PAGE_SIZE_OPTIONS.map((size) => (
                <option key={size} value={size}>{size}</option>
              ))}
            </select>
          </div>
        )}
      </div>

      <div className="flex items-center gap-1">
        {/* Anterior */}
        <button
          onClick={() => onPageChange(paginaActual - 1)}
          disabled={!tienePaginaAnterior}
          className="p-2 border border-slate-200 rounded-lg hover:bg-slate-50 disabled:opacity-40 disabled:cursor-not-allowed transition"
          aria-label="Página anterior"
        >
          <ChevronLeft className="w-4 h-4" />
        </button>

        {/* Números de página */}
        {getPageNumbers().map((item, idx) =>
          item === 'ellipsis' ? (
            <span key={`e-${idx}`} className="px-2 text-slate-400 text-sm">…</span>
          ) : (
            <button
              key={item}
              onClick={() => onPageChange(item)}
              className={`min-w-[36px] h-9 text-sm font-medium rounded-lg transition ${
                item === paginaActual
                  ? 'bg-indigo-600 text-white shadow-sm'
                  : 'text-slate-700 hover:bg-slate-50 border border-slate-200'
              }`}
            >
              {item}
            </button>
          )
        )}

        {/* Siguiente */}
        <button
          onClick={() => onPageChange(paginaActual + 1)}
          disabled={!tienePaginaSiguiente}
          className="p-2 border border-slate-200 rounded-lg hover:bg-slate-50 disabled:opacity-40 disabled:cursor-not-allowed transition"
          aria-label="Página siguiente"
        >
          <ChevronRight className="w-4 h-4" />
        </button>
      </div>
    </div>
  );
}
