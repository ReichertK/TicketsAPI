import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { apiClient } from '../services/api.service';
import { API_ENDPOINTS } from '../config/api';
import { useAuthStore } from '../store/authStore';
import { LoginRequest, ApiResponse, LoginResponse } from '../types/api.types';
import { LogIn, Eye, EyeOff } from 'lucide-react';

const REMEMBERED_USER_KEY = 'cediac_remembered_user';

export default function LoginPage() {
  const [credentials, setCredentials] = useState<LoginRequest>({
    usuario: '',
    contraseña: '',
  });
  const [rememberUser, setRememberUser] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  
  const navigate = useNavigate();
  const login = useAuthStore((state) => state.login);

  useEffect(() => {
    const saved = localStorage.getItem(REMEMBERED_USER_KEY);
    if (saved) {
      setCredentials((prev) => ({ ...prev, usuario: saved }));
      setRememberUser(true);
    }
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    if (rememberUser) {
      localStorage.setItem(REMEMBERED_USER_KEY, credentials.usuario);
    } else {
      localStorage.removeItem(REMEMBERED_USER_KEY);
    }

    try {
      const response = await apiClient.post<ApiResponse<LoginResponse>>(
        API_ENDPOINTS.LOGIN,
        credentials
      );

      if (response.data.exitoso && response.data.datos) {
        login(response.data.datos);
        navigate('/');
      } else {
        setError(response.data.mensaje || 'Error al iniciar sesión');
      }
    } catch (err: any) {
      setError(err.response?.data?.mensaje || err.message || 'Error de conexión con el servidor');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-slate-800 via-slate-900 to-slate-950 px-4">
      <div className="max-w-md w-full bg-white rounded-2xl shadow-2xl p-8">
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-indigo-600 rounded-2xl mb-4 shadow-lg shadow-indigo-500/30">
            <LogIn className="w-8 h-8 text-white" />
          </div>
          <h1 className="text-2xl font-bold text-slate-900">Sistema de Tickets</h1>
          <p className="text-indigo-600 font-semibold text-lg mt-1">Cediac</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-5">
          {error && (
            <div className="bg-rose-50 border border-rose-200 text-rose-700 px-4 py-3 rounded-lg text-sm">
              {error}
            </div>
          )}

          <div>
            <label htmlFor="usuario" className="block text-sm font-medium text-slate-700 mb-1.5">
              Usuario / Email
            </label>
            <input
              id="usuario"
              type="text"
              required
              className="w-full px-4 py-2.5 border border-slate-300 rounded-lg bg-white text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition text-sm"
              value={credentials.usuario}
              onChange={(e) => setCredentials({ ...credentials, usuario: e.target.value })}
              placeholder="usuario@ejemplo.com"
              autoComplete="username"
            />
          </div>

          <div>
            <label htmlFor="password" className="block text-sm font-medium text-slate-700 mb-1.5">
              Contraseña
            </label>
            <div className="relative">
              <input
                id="password"
                type={showPassword ? 'text' : 'password'}
                required
                className="w-full px-4 py-2.5 border border-slate-300 rounded-lg bg-white text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition text-sm pr-10"
                value={credentials.contraseña}
                onChange={(e) => setCredentials({ ...credentials, contraseña: e.target.value })}
                placeholder="••••••••"
                autoComplete="current-password"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 transition"
                tabIndex={-1}
              >
                {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
              </button>
            </div>
          </div>

          <div className="flex items-center justify-between">
            <label className="flex items-center gap-2 cursor-pointer select-none">
              <input
                type="checkbox"
                checked={rememberUser}
                onChange={(e) => setRememberUser(e.target.checked)}
                className="w-4 h-4 rounded border-slate-300 text-indigo-600 focus:ring-indigo-500"
              />
              <span className="text-sm text-slate-600">Recordar usuario</span>
            </label>
            <button
              type="button"
              className="text-sm text-indigo-600 hover:text-indigo-800 font-medium transition"
              onClick={() => alert('Contacta al administrador del sistema para restablecer tu contraseña.')}
            >
              ¿Olvidaste tu contraseña?
            </button>
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-indigo-600 text-white py-2.5 px-4 rounded-lg hover:bg-indigo-700 focus:ring-4 focus:ring-indigo-300 disabled:opacity-50 disabled:cursor-not-allowed shadow-sm transition font-medium text-sm flex items-center justify-center gap-2"
          >
            {loading ? (
              <>
                <svg className="animate-spin h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                  <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                </svg>
                Iniciando sesión…
              </>
            ) : (
              'Iniciar Sesión'
            )}
          </button>
        </form>

        <p className="mt-6 text-center text-xs text-slate-400">
          &copy; {new Date().getFullYear()} Cediac — Todos los derechos reservados
        </p>
      </div>
    </div>
  );
}
