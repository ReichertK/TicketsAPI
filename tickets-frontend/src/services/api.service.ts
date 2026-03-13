import axios, { AxiosError, InternalAxiosRequestConfig, AxiosResponse } from 'axios';
import { API_BASE_URL, API_ENDPOINTS } from '../config/api';

export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// --- Auto-refresh de token ---
let isRefreshing = false;
let failedQueue: Array<{
  resolve: (token: string) => void;
  reject: (error: unknown) => void;
}> = [];

function processQueue(error: unknown, token: string | null) {
  failedQueue.forEach((prom) => {
    if (token) {
      prom.resolve(token);
    } else {
      prom.reject(error);
    }
  });
  failedQueue = [];
}

// Request interceptor para agregar token
apiClient.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const token = localStorage.getItem('token');
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error: AxiosError) => {
    return Promise.reject(error);
  }
);

// Response interceptor con auto-refresh de token
apiClient.interceptors.response.use(
  (response: AxiosResponse) => response,
  async (error: AxiosError) => {
    const originalRequest = error.config as InternalAxiosRequestConfig & { _retry?: boolean };

    // Log detallado de errores 400 para diagnóstico
    if (error.response?.status === 400) {
      console.error('[API 400 Debug]', {
        url: originalRequest?.url,
        method: originalRequest?.method,
        params: originalRequest?.params,
        data: originalRequest?.data,
        fullURL: error.request?.responseURL || `${originalRequest?.baseURL}${originalRequest?.url}`,
        responseBody: error.response?.data,
      });
    }

    // Solo intentar refresh si es 401, no es login/refresh, y no es reintento
    if (
      error.response?.status === 401 &&
      originalRequest &&
      !originalRequest._retry &&
      !originalRequest.url?.includes('/Auth/login') &&
      !originalRequest.url?.includes('/Auth/refresh-token')
    ) {
      // Si ya estamos refrescando, encolar esta petición
      if (isRefreshing) {
        return new Promise((resolve, reject) => {
          failedQueue.push({
            resolve: (token: string) => {
              if (originalRequest.headers) {
                originalRequest.headers.Authorization = `Bearer ${token}`;
              }
              resolve(apiClient(originalRequest));
            },
            reject,
          });
        });
      }

      originalRequest._retry = true;
      isRefreshing = true;

      try {
        // Obtener refreshToken del store Zustand persistido
        const authStorage = localStorage.getItem('auth-storage');
        const refreshToken = authStorage
          ? JSON.parse(authStorage)?.state?.user?.refreshToken
          : null;

        if (!refreshToken) {
          throw new Error('No refresh token available');
        }

        const response = await axios.post(
          `${API_BASE_URL}${API_ENDPOINTS.REFRESH_TOKEN}`,
          { refreshToken },
          { headers: { 'Content-Type': 'application/json' } }
        );

        const newData = response.data?.datos;
        if (!newData?.token) {
          throw new Error('Invalid refresh response');
        }

        // Actualizar token en localStorage
        localStorage.setItem('token', newData.token);

        // Actualizar Zustand store persistido
        if (authStorage) {
          const parsed = JSON.parse(authStorage);
          parsed.state.user = { ...parsed.state.user, ...newData };
          parsed.state.token = newData.token;
          localStorage.setItem('auth-storage', JSON.stringify(parsed));
        }

        // Procesar cola de peticiones pendientes
        processQueue(null, newData.token);

        // Reintentar la petición original con el nuevo token
        if (originalRequest.headers) {
          originalRequest.headers.Authorization = `Bearer ${newData.token}`;
        }
        return apiClient(originalRequest);
      } catch (refreshError) {
        // Refresh falló — limpiar y redirigir a login
        processQueue(refreshError, null);
        localStorage.removeItem('token');
        localStorage.removeItem('auth-storage');
        window.location.href = '/login';
        return Promise.reject(refreshError);
      } finally {
        isRefreshing = false;
      }
    }

    return Promise.reject(error);
  }
);
