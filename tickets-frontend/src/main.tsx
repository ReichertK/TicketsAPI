import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { QueryClientProvider, QueryClient } from '@tanstack/react-query';
import './index.css';

import Layout from './components/layout/Layout';
import ProtectedRoute from './components/layout/ProtectedRoute';
import LoginPage from './pages/LoginPage';
import DashboardPage from './pages/DashboardPage';
import TicketsPage from './pages/TicketsPage';
import CreateTicketPage from './pages/CreateTicketPage';
import TicketDetailPage from './pages/TicketDetailPage';
import EditTicketPage from './pages/EditTicketPage';
import UsuariosPage from './pages/UsuariosPage';
import DepartamentosPage from './pages/DepartamentosPage';
import ColaTrabajoPage from './pages/ColaTrabajoPage';
import TodosTicketsPage from './pages/TodosTicketsPage';
import ConfiguracionPage from './pages/ConfiguracionPage';
import AuditLogsPage from './pages/AuditLogsPage';
import SeguimientoTicketsPage from './pages/SeguimientoTicketsPage';
import HelpPage from './pages/HelpPage';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5, // 5 minutos
      gcTime: 1000 * 60 * 10, // 10 minutos (antes cacheTime)
    },
  },
});

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<LoginPage />} />

          <Route
            element={
              <ProtectedRoute>
                <Layout />
              </ProtectedRoute>
            }
          >
            <Route path="/" element={<Navigate to="/tickets" replace />} />
            <Route path="/dashboard" element={<ProtectedRoute roles={['Administrador']}><DashboardPage /></ProtectedRoute>} />
            <Route path="/tickets" element={<TicketsPage />} />
            <Route path="/tickets/nuevo" element={<CreateTicketPage />} />
            <Route path="/tickets/:id" element={<TicketDetailPage />} />
            <Route path="/tickets/:id/editar" element={<ProtectedRoute roles={['Administrador']}><EditTicketPage /></ProtectedRoute>} />
            <Route path="/cola" element={<ProtectedRoute permissions={['TKT_LIST_ALL']}><ColaTrabajoPage /></ProtectedRoute>} />
            <Route path="/todos-tickets" element={<ProtectedRoute permissions={['TKT_LIST_ALL']}><TodosTicketsPage /></ProtectedRoute>} />
            <Route path="/usuarios" element={<ProtectedRoute roles={['Administrador']}><UsuariosPage /></ProtectedRoute>} />
            <Route path="/departamentos" element={<ProtectedRoute roles={['Administrador']}><DepartamentosPage /></ProtectedRoute>} />
            <Route path="/configuracion" element={<ProtectedRoute roles={['Administrador']}><ConfiguracionPage /></ProtectedRoute>} />
            <Route path="/admin/logs" element={<ProtectedRoute roles={['Administrador']}><AuditLogsPage /></ProtectedRoute>} />
            <Route path="/admin/seguimiento-tickets" element={<ProtectedRoute roles={['Administrador']}><SeguimientoTicketsPage /></ProtectedRoute>} />
            <Route path="/ayuda" element={<HelpPage />} />
          </Route>

          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </BrowserRouter>
    </QueryClientProvider>
  </React.StrictMode>
);
