import { memo } from 'react';
import {
  AlertTriangle,
  ArrowUp,
  ArrowDown,
  Minus,
  Flame,
  type LucideIcon,
} from 'lucide-react';

interface PriorityBadgeProps {
  /** Nombre de la prioridad (nombre_Prioridad del DTO) */
  prioridad: string;
  /** ID de la prioridad — fallback cuando nombre viene vacío */
  id?: number;
  /** Color hex de la prioridad (del DTO — fallback) */
  color?: string;
  /** Tamaño: sm | md | lg */
  size?: 'sm' | 'md' | 'lg';
  /** Mostrar ícono */
  showIcon?: boolean;
  /** Clases CSS adicionales */
  className?: string;
}

interface PriorityStyle {
  bg: string;
  text: string;
  Icon: LucideIcon;
}

/**
 * Mapa semántico de prioridades
 * Crítica=Rose, Alta=Red/Orange, Media=Amber, Baja=Slate/Gray
 */
const PRIORITY_STYLES: Record<string, PriorityStyle> = {
  critica: {
    bg: 'bg-rose-100 border-rose-300',
    text: 'text-rose-800',
    Icon: Flame,
  },
  crítica: {
    bg: 'bg-rose-100 border-rose-300',
    text: 'text-rose-800',
    Icon: Flame,
  },
  alta: {
    bg: 'bg-orange-100 border-orange-300',
    text: 'text-orange-800',
    Icon: ArrowUp,
  },
  urgente: {
    bg: 'bg-red-100 border-red-300',
    text: 'text-red-800',
    Icon: AlertTriangle,
  },
  media: {
    bg: 'bg-amber-100 border-amber-300',
    text: 'text-amber-800',
    Icon: Minus,
  },
  normal: {
    bg: 'bg-amber-100 border-amber-300',
    text: 'text-amber-800',
    Icon: Minus,
  },
  baja: {
    bg: 'bg-slate-100 border-slate-300',
    text: 'text-slate-600',
    Icon: ArrowDown,
  },
};

const DEFAULT_STYLE: PriorityStyle = {
  bg: 'bg-slate-100 border-slate-300',
  text: 'text-slate-700',
  Icon: Minus,
};

/**
 * Mapa ID → nombre para fallback cuando el backend devuelve nombre vacío.
 * Se basa en la tabla `prioridad` de la BD.
 */
const PRIORIDAD_ID_MAP: Record<number, string> = {
  1: 'Alta',
  2: 'Media',
  3: 'Baja',
  7: 'Crítica',
};

const SIZES = {
  sm: { badge: 'px-2 py-0.5 text-xs gap-1', icon: 'w-3 h-3' },
  md: { badge: 'px-2.5 py-1 text-xs gap-1.5', icon: 'w-3.5 h-3.5' },
  lg: { badge: 'px-3 py-1.5 text-sm gap-2', icon: 'w-4 h-4' },
};

function getPriorityStyle(prioridad: string): PriorityStyle {
  const key = prioridad
    .toLowerCase()
    .trim()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '');
  return PRIORITY_STYLES[key] || DEFAULT_STYLE;
}

export default memo(function PriorityBadge({
  prioridad,
  id,
  size = 'md',
  showIcon = true,
  className = '',
}: PriorityBadgeProps) {
  // Resolución: nombre directo → fallback por ID → "Sin prioridad"
  let resolvedName = prioridad && prioridad !== '-' ? prioridad : '';
  if (!resolvedName && id && PRIORIDAD_ID_MAP[id]) {
    resolvedName = PRIORIDAD_ID_MAP[id];
  }
  const displayText = resolvedName || 'Sin prioridad';
  const style = getPriorityStyle(displayText);
  const sizeConfig = SIZES[size];

  return (
    <span
      className={`
        inline-flex items-center font-medium rounded-full border
        ${style.bg} ${style.text} ${sizeConfig.badge}
        ${className}
      `}
    >
      {showIcon && <style.Icon className={`${sizeConfig.icon} shrink-0`} />}
      {displayText}
    </span>
  );
});
