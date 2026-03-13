import { ArrowUp, ArrowDown, ArrowUpDown } from 'lucide-react';
import type { SortColumn } from '../../hooks/useTicketFilters';

interface SortableHeaderProps {
  /** Texto visible en el encabezado */
  label: string;
  /** Clave de ordenamiento que envía al backend */
  column: SortColumn;
  /** Columna actualmente activa */
  activeColumn: SortColumn;
  /** Dirección actual de ordenamiento */
  isDescending: boolean;
  /** Callback al hacer clic */
  onSort: (column: SortColumn) => void;
  /** Clases CSS adicionales para el <th> */
  className?: string;
}

/**
 * Header de tabla clicable con indicador de dirección de ordenamiento.
 * Muestra ↑/↓ si es la columna activa, o ↕ si es inactiva.
 */
export default function SortableHeader({
  label,
  column,
  activeColumn,
  isDescending,
  onSort,
  className = '',
}: SortableHeaderProps) {
  const isActive = activeColumn === column;

  return (
    <th
      onClick={() => onSort(column)}
      className={`px-6 py-3 text-left text-xs font-medium uppercase tracking-wider cursor-pointer select-none group transition-colors hover:bg-slate-100 ${className}`}
    >
      <span className={`inline-flex items-center gap-1.5 ${isActive ? 'text-indigo-600' : 'text-slate-500'}`}>
        {label}
        {isActive ? (
          isDescending ? (
            <ArrowDown className="w-3.5 h-3.5" />
          ) : (
            <ArrowUp className="w-3.5 h-3.5" />
          )
        ) : (
          <ArrowUpDown className="w-3 h-3 opacity-30 group-hover:opacity-60 transition-opacity" />
        )}
      </span>
    </th>
  );
}
