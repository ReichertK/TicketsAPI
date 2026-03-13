import { useMemo, memo } from 'react';

interface UserAvatarProps {
  /** Nombre completo del usuario */
  nombre: string;
  /** Apellido (opcional, para mejores iniciales) */
  apellido?: string;
  /** Nombre del rol para color dinámico */
  rol?: string;
  /** URL de imagen de avatar (opcional) */
  imageUrl?: string;
  /** Tamaño: sm (32px) | md (40px) | lg (48px) */
  size?: 'sm' | 'md' | 'lg';
  /** Clases CSS adicionales */
  className?: string;
}

/**
 * Paleta de colores por tipo de rol.
 * Admin=Rose/Purple, Técnico=Indigo/Cyan, Usuario=Emerald/Slate
 */
const ROLE_COLORS: Record<string, { bg: string; text: string; ring: string }> = {
  admin: {
    bg: 'bg-gradient-to-br from-rose-500 to-purple-600',
    text: 'text-white',
    ring: 'ring-rose-300',
  },
  administrador: {
    bg: 'bg-gradient-to-br from-rose-500 to-purple-600',
    text: 'text-white',
    ring: 'ring-rose-300',
  },
  tecnico: {
    bg: 'bg-gradient-to-br from-indigo-500 to-cyan-500',
    text: 'text-white',
    ring: 'ring-indigo-300',
  },
  técnico: {
    bg: 'bg-gradient-to-br from-indigo-500 to-cyan-500',
    text: 'text-white',
    ring: 'ring-indigo-300',
  },
  soporte: {
    bg: 'bg-gradient-to-br from-indigo-500 to-cyan-500',
    text: 'text-white',
    ring: 'ring-indigo-300',
  },
  usuario: {
    bg: 'bg-gradient-to-br from-emerald-500 to-teal-500',
    text: 'text-white',
    ring: 'ring-emerald-300',
  },
  default: {
    bg: 'bg-gradient-to-br from-slate-400 to-slate-500',
    text: 'text-white',
    ring: 'ring-slate-300',
  },
};

const SIZES = {
  sm: 'w-8 h-8 text-xs',
  md: 'w-10 h-10 text-sm',
  lg: 'w-12 h-12 text-base',
};

function getInitials(nombre: string, apellido?: string): string {
  const first = nombre?.trim().charAt(0).toUpperCase() || '';
  if (apellido) {
    return first + apellido.trim().charAt(0).toUpperCase();
  }
  // Si no hay apellido, tomar la segunda palabra del nombre
  const parts = nombre?.trim().split(/\s+/) || [];
  if (parts.length > 1) {
    return first + parts[1].charAt(0).toUpperCase();
  }
  return first;
}

function getRoleColor(rol?: string) {
  if (!rol) return ROLE_COLORS.default;
  const key = rol.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
  return ROLE_COLORS[key] || ROLE_COLORS.default;
}

export default memo(function UserAvatar({
  nombre,
  apellido,
  rol,
  imageUrl,
  size = 'md',
  className = '',
}: UserAvatarProps) {
  const initials = useMemo(() => getInitials(nombre, apellido), [nombre, apellido]);
  const colors = useMemo(() => getRoleColor(rol), [rol]);

  if (imageUrl) {
    return (
      <img
        src={imageUrl}
        alt={`Avatar de ${nombre}`}
        className={`
          ${SIZES[size]} rounded-full object-cover ring-2 ${colors.ring}
          ${className}
        `}
      />
    );
  }

  return (
    <div
      className={`
        ${SIZES[size]} rounded-full ${colors.bg} ${colors.text}
        inline-flex items-center justify-center font-semibold
        ring-2 ${colors.ring} select-none shrink-0
        ${className}
      `}
      title={`${nombre}${apellido ? ` ${apellido}` : ''} ${rol ? `(${rol})` : ''}`}
    >
      {initials}
    </div>
  );
});
