import { memo } from 'react';
import {
  Circle,
  Clock,
  CheckCircle2,
  XCircle,
  Pause,
  RotateCcw,
  ShieldCheck,
  type LucideIcon,
} from 'lucide-react';

interface StatusBadgeProps {
  /** Nombre del estado (nombre_Estado del DTO) */
  estado: string;
  /** ID del estado — fallback cuando nombre viene vacío */
  id?: number;
  /** Color hex del estado (viene del DTO — se usa como fallback) */
  color?: string;
  /** Tamaño: sm | md | lg */
  size?: 'sm' | 'md' | 'lg';
  /** Mostrar ícono */
  showIcon?: boolean;
  /** Clases CSS adicionales */
  className?: string;
}

interface StatusStyle {
  bg: string;
  text: string;
  dot: string;
  Icon: LucideIcon;
}

/**
 * Mapa semántico de estados con la paleta del spec:
 * Abierto=Azul, En Proceso=Indigo, En Espera=Naranja, Cerrado=Gris, Vencido=Rojo
 */
const STATUS_STYLES: Record<string, StatusStyle> = {
  abierto: {
    bg: 'bg-blue-50 border-blue-200',
    text: 'text-blue-700',
    dot: 'bg-blue-500',
    Icon: Circle,
  },
  'en proceso': {
    bg: 'bg-indigo-50 border-indigo-200',
    text: 'text-indigo-700',
    dot: 'bg-indigo-500',
    Icon: Clock,
  },
  'en progreso': {
    bg: 'bg-indigo-50 border-indigo-200',
    text: 'text-indigo-700',
    dot: 'bg-indigo-500',
    Icon: Clock,
  },
  pendiente: {
    bg: 'bg-orange-50 border-orange-200',
    text: 'text-orange-700',
    dot: 'bg-orange-500',
    Icon: Pause,
  },
  'en espera': {
    bg: 'bg-orange-50 border-orange-200',
    text: 'text-orange-700',
    dot: 'bg-orange-500',
    Icon: Pause,
  },
  cerrado: {
    bg: 'bg-slate-100 border-slate-300',
    text: 'text-slate-600',
    dot: 'bg-slate-500',
    Icon: XCircle,
  },
  resuelto: {
    bg: 'bg-emerald-50 border-emerald-200',
    text: 'text-emerald-700',
    dot: 'bg-emerald-500',
    Icon: CheckCircle2,
  },
  reabierto: {
    bg: 'bg-rose-50 border-rose-200',
    text: 'text-rose-700',
    dot: 'bg-rose-500',
    Icon: RotateCcw,
  },
  vencido: {
    bg: 'bg-red-50 border-red-200',
    text: 'text-red-700',
    dot: 'bg-red-500',
    Icon: XCircle,
  },
  aprobado: {
    bg: 'bg-indigo-50 border-indigo-200',
    text: 'text-indigo-700',
    dot: 'bg-indigo-500',
    Icon: ShieldCheck,
  },
};

const DEFAULT_STYLE: StatusStyle = {
  bg: 'bg-slate-50 border-slate-200',
  text: 'text-slate-600',
  dot: 'bg-slate-400',
  Icon: Circle,
};

/**
 * Mapa ID → nombre para fallback cuando el backend devuelve nombre vacío.
 * Se basa en la tabla `estado` de la BD: INSERT INTO estado(Id_Estado, TipoEstado) VALUES ...
 */
const ESTADO_ID_MAP: Record<number, string> = {
  1: 'Abierto',
  2: 'En Proceso',
  3: 'Cerrado',
  4: 'En Espera',
  5: 'Pendiente Aprobación',
  6: 'Resuelto',
  7: 'Reabierto',
};

const SIZES = {
  sm: { badge: 'px-2 py-0.5 text-xs gap-1', icon: 'w-3 h-3', dot: 'w-1.5 h-1.5' },
  md: { badge: 'px-2.5 py-1 text-xs gap-1.5', icon: 'w-3.5 h-3.5', dot: 'w-2 h-2' },
  lg: { badge: 'px-3 py-1.5 text-sm gap-2', icon: 'w-4 h-4', dot: 'w-2.5 h-2.5' },
};

function getStatusStyle(estado: string): StatusStyle {
  const key = estado.toLowerCase().trim();
  return STATUS_STYLES[key] || DEFAULT_STYLE;
}

export default memo(function StatusBadge({
  estado,
  id,
  size = 'md',
  showIcon = true,
  className = '',
}: StatusBadgeProps) {
  // Resolución: nombre directo → fallback por ID → "Sin estado"
  let resolvedName = estado && estado !== '-' ? estado : '';
  if (!resolvedName && id && ESTADO_ID_MAP[id]) {
    resolvedName = ESTADO_ID_MAP[id];
  }
  const displayText = resolvedName || 'Sin estado';
  const style = getStatusStyle(displayText);
  const sizeConfig = SIZES[size];

  return (
    <span
      className={`
        inline-flex items-center font-medium rounded-full border
        ${style.bg} ${style.text} ${sizeConfig.badge}
        ${className}
      `}
    >
      {showIcon ? (
        <style.Icon className={`${sizeConfig.icon} shrink-0`} />
      ) : (
        <span className={`${sizeConfig.dot} rounded-full shrink-0 ${style.dot}`} />
      )}
      {displayText}
    </span>
  );
});
