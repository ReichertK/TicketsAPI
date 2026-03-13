import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { LoginResponse } from '../types/api.types';

interface AuthState {
  user: LoginResponse | null;
  token: string | null;
  isAuthenticated: boolean;
  login: (data: LoginResponse) => void;
  logout: () => void;
  hasPermission: (permission: string) => boolean;
  isAdmin: () => boolean;
  isTecnico: () => boolean;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      token: null,
      isAuthenticated: false,

      login: (data: LoginResponse) => {
        localStorage.setItem('token', data.token);
        set({
          user: data,
          token: data.token,
          isAuthenticated: true,
        });
      },

      logout: () => {
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        set({
          user: null,
          token: null,
          isAuthenticated: false,
        });
      },

      hasPermission: (permission: string) => {
        const { user } = get();
        return user?.permisos?.includes(permission) ?? false;
      },

      isAdmin: () => {
        const { user } = get();
        return user?.rol?.nombre_Rol?.toLowerCase().includes('admin') ?? false;
      },

      isTecnico: () => {
        const { user } = get();
        const rol = user?.rol?.nombre_Rol?.toLowerCase() ?? '';
        return rol.includes('tecnico') || rol.includes('técnico') || rol.includes('soporte');
      },
    }),
    {
      name: 'auth-storage',
    }
  )
);
