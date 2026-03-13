import { describe, it, expect, beforeEach } from 'vitest';
import { useAuthStore } from '../authStore';
import type { LoginResponse } from '../../types/api.types';

const mockLoginData: LoginResponse = {
  id_Usuario: 1,
  nombre: 'Admin User',
  email: 'admin@cediac.com',
  token: 'jwt-token-123',
  refreshToken: 'refresh-token-456',
  rol: { id_Rol: 10, nombre_Rol: 'Administrador', descripcion: 'Admin', activo: true },
  permisos: ['TKT_CREATE', 'TKT_EDIT_ANY', 'TKT_APPROVE'],
};

describe('authStore', () => {
  beforeEach(() => {
    useAuthStore.setState({ user: null, token: null, isAuthenticated: false });
    localStorage.clear();
  });

  it('starts with unauthenticated state', () => {
    const state = useAuthStore.getState();
    expect(state.user).toBeNull();
    expect(state.token).toBeNull();
    expect(state.isAuthenticated).toBe(false);
  });

  it('login sets user, token and isAuthenticated', () => {
    useAuthStore.getState().login(mockLoginData);
    const state = useAuthStore.getState();

    expect(state.user).toEqual(mockLoginData);
    expect(state.token).toBe('jwt-token-123');
    expect(state.isAuthenticated).toBe(true);
    expect(localStorage.getItem('token')).toBe('jwt-token-123');
  });

  it('logout clears state and localStorage', () => {
    useAuthStore.getState().login(mockLoginData);
    useAuthStore.getState().logout();
    const state = useAuthStore.getState();

    expect(state.user).toBeNull();
    expect(state.token).toBeNull();
    expect(state.isAuthenticated).toBe(false);
    expect(localStorage.getItem('token')).toBeNull();
  });

  it('hasPermission returns true for existing permission', () => {
    useAuthStore.getState().login(mockLoginData);
    expect(useAuthStore.getState().hasPermission('TKT_CREATE')).toBe(true);
    expect(useAuthStore.getState().hasPermission('TKT_APPROVE')).toBe(true);
  });

  it('hasPermission returns false for missing permission', () => {
    useAuthStore.getState().login(mockLoginData);
    expect(useAuthStore.getState().hasPermission('SUPER_DELETE')).toBe(false);
  });

  it('hasPermission returns false when not logged in', () => {
    expect(useAuthStore.getState().hasPermission('TKT_CREATE')).toBe(false);
  });

  it('isAdmin returns true for Administrador role', () => {
    useAuthStore.getState().login(mockLoginData);
    expect(useAuthStore.getState().isAdmin()).toBe(true);
  });

  it('isAdmin returns false for non-admin role', () => {
    useAuthStore.getState().login({
      ...mockLoginData,
      rol: { id_Rol: 3, nombre_Rol: 'Operador', descripcion: 'Op', activo: true },
    });
    expect(useAuthStore.getState().isAdmin()).toBe(false);
  });

  it('isTecnico returns true for tecnico/soporte role', () => {
    useAuthStore.getState().login({
      ...mockLoginData,
      rol: { id_Rol: 2, nombre_Rol: 'Soporte Técnico', descripcion: '', activo: true },
    });
    expect(useAuthStore.getState().isTecnico()).toBe(true);
  });
});
