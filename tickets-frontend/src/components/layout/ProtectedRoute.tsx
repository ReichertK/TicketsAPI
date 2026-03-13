import { Navigate } from 'react-router-dom';
import { useAuthStore } from '../../store/authStore';
import { usePermissions } from '../../hooks/usePermission';

interface ProtectedRouteProps {
  children: React.ReactNode;
  /** Si se especifican roles, el usuario debe tener uno de ellos */
  roles?: string[];
  /** Si se especifican permisos, el usuario debe tener al menos uno (Admin bypasses) */
  permissions?: string[];
}

export default function ProtectedRoute({ children, roles, permissions }: ProtectedRouteProps) {
  const { isAuthenticated, user } = useAuthStore();
  const { hasAnyPermission, isAdmin } = usePermissions();

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  // Validar rol si se requiere
  if (roles && roles.length > 0) {
    const userRole = user?.rol?.nombre_Rol?.toLowerCase() ?? '';
    const hasRole = roles.some((r) => userRole.includes(r.toLowerCase()));
    if (!hasRole) {
      return <Navigate to="/tickets" replace />;
    }
  }

  // Validar permisos granulares si se requieren (Admin bypasses)
  if (permissions && permissions.length > 0 && !isAdmin) {
    if (!hasAnyPermission(...permissions)) {
      return <Navigate to="/tickets" replace />;
    }
  }

  return <>{children}</>;
}
