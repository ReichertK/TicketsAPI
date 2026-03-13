import { useAuthStore } from '../store/authStore';

/**
 * Hook para verificar permisos del usuario autenticado.
 *
 * Regla Especial: Si el rol es 'Administrador', siempre devuelve true.
 *
 * @example
 * const canDelete = usePermission('TKT_DELETE');
 * const canApprove = usePermission('TKT_APPROVE');
 * const { hasPermission } = usePermissions();
 */

/** Verificar un solo permiso — devuelve boolean */
export function usePermission(permission: string): boolean {
  const user = useAuthStore((s) => s.user);
  if (!user) return false;

  // Admin bypass: siempre tiene todos los permisos
  if (user.rol?.nombre_Rol?.toLowerCase().includes('admin')) return true;

  return user.permisos?.includes(permission) ?? false;
}

/** Verificar múltiples permisos a la vez */
export function usePermissions(): {
  hasPermission: (permission: string) => boolean;
  hasAnyPermission: (...permissions: string[]) => boolean;
  hasAllPermissions: (...permissions: string[]) => boolean;
  isAdmin: boolean;
  permisos: string[];
} {
  const user = useAuthStore((s) => s.user);
  const isAdmin = user?.rol?.nombre_Rol?.toLowerCase().includes('admin') ?? false;
  const permisos = user?.permisos ?? [];

  const hasPermission = (permission: string): boolean => {
    if (isAdmin) return true;
    return permisos.includes(permission);
  };

  const hasAnyPermission = (...permissions: string[]): boolean => {
    if (isAdmin) return true;
    return permissions.some((p) => permisos.includes(p));
  };

  const hasAllPermissions = (...permissions: string[]): boolean => {
    if (isAdmin) return true;
    return permissions.every((p) => permisos.includes(p));
  };

  return { hasPermission, hasAnyPermission, hasAllPermissions, isAdmin, permisos };
}
