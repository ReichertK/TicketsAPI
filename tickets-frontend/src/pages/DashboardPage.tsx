import { useQuery } from '@tanstack/react-query';
import { apiClient } from '../services/api.service';
import { API_ENDPOINTS } from '../config/api';
import { ApiResponse, DashboardDTO, NotificacionResumenDTO } from '../types/api.types';
import ErrorAlert from '../components/ui/ErrorAlert';
import {
  LayoutDashboard,
  Ticket,
  CheckCircle,
  Clock,
  AlertTriangle,
  TrendingUp,
  ArrowUpRight,
  ArrowDownRight,
  Bell,
  Activity,
} from 'lucide-react';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  Legend,
} from 'recharts';

// ── Colores para los gráficos ────────────────────────────────────
const PIE_COLORS = ['#6366f1', '#10b981', '#f59e0b', '#64748b', '#ef4444', '#8b5cf6', '#06b6d4'];
const BAR_COLORS = ['#ef4444', '#f97316', '#eab308', '#64748b'];

export default function DashboardPage() {
  const { data: dashboard, isLoading, isError, error, refetch } = useQuery({
    queryKey: ['dashboard'],
    queryFn: async () => {
      const response = await apiClient.get<ApiResponse<DashboardDTO>>(API_ENDPOINTS.DASHBOARD);
      return response.data.datos;
    },
    retry: 2,
  });

  const { data: notifResumen } = useQuery({
    queryKey: ['notificaciones-resumen'],
    queryFn: async () => {
      const res = await apiClient.get<ApiResponse<NotificacionResumenDTO>>(
        API_ENDPOINTS.NOTIFICACIONES_RESUMEN,
      );
      return res.data.datos;
    },
    staleTime: 15_000,
  });

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-96">
        <div className="flex flex-col items-center gap-3">
          <div className="animate-spin rounded-full h-10 w-10 border-b-2 border-indigo-600"></div>
          <p className="text-sm text-slate-500">Cargando métricas…</p>
        </div>
      </div>
    );
  }

  if (isError) {
    const errMsg = (error as any)?.response?.data?.mensaje || 'No se pudo cargar el dashboard.';
    return (
      <ErrorAlert
        title="Error al cargar el Dashboard"
        message={errMsg}
        onRetry={() => refetch()}
      />
    );
  }

  if (!dashboard) {
    return (
      <div className="flex items-center justify-center h-96">
        <p className="text-slate-500">No hay datos disponibles</p>
      </div>
    );
  }

  // ── KPI Cards data ─────────────────────────────────────────────
  const totalNoLeidos = notifResumen?.totalNoLeidos ?? 0;
  const pendientesAsignados = notifResumen?.pendientesAsignados ?? 0;

  const kpis = [
    {
      name: 'Tickets Abiertos',
      value: dashboard.ticketsAbiertos ?? 0,
      icon: AlertTriangle,
      color: 'text-rose-600',
      bgIcon: 'bg-rose-100',
      subtitle: 'Requieren atención',
      trendUp: true,
    },
    {
      name: 'Cerrados',
      value: dashboard.ticketsCerrados ?? 0,
      icon: CheckCircle,
      color: 'text-emerald-600',
      bgIcon: 'bg-emerald-100',
      subtitle: 'Resueltos',
      trendUp: false,
    },
    {
      name: 'Tiempo Prom. Resolución',
      value: `${(dashboard.tiempoPromedioResolucion ?? 0).toFixed(1)}h`,
      icon: Clock,
      color: 'text-indigo-600',
      bgIcon: 'bg-indigo-100',
      subtitle: 'Promedio general',
      trendUp: false,
    },
    {
      name: 'No Leídos',
      value: totalNoLeidos,
      icon: Bell,
      color: 'text-amber-600',
      bgIcon: 'bg-amber-100',
      subtitle: pendientesAsignados > 0
        ? `${pendientesAsignados} asignado${pendientesAsignados !== 1 ? 's' : ''} a ti`
        : 'Todo al día',
      trendUp: totalNoLeidos > 0,
    },
  ];

  // ── Chart data transformations ─────────────────────────────────
  const estadoData = Object.entries(dashboard.ticketsPorEstado ?? {}).map(([name, value]) => ({
    name,
    value: value as number,
  }));

  const prioridadData = Object.entries(dashboard.ticketsPorPrioridad ?? {}).map(([name, value]) => ({
    name,
    cantidad: value as number,
  }));

  const departamentoData = Object.entries(dashboard.ticketsPorDepartamento ?? {}).map(([name, value]) => ({
    name: name.length > 15 ? name.substring(0, 15) + '…' : name,
    fullName: name,
    tickets: value as number,
  }));

  // ── Métricas derivadas ─────────────────────────────────────────
  const totalTickets = dashboard.ticketsTotal ?? 0;
  const tasaResolucion = totalTickets > 0
    ? Math.round(((dashboard.ticketsCerrados ?? 0) / totalTickets) * 100)
    : 0;
  const enProceso = dashboard.ticketsEnProceso ?? 0;
  const asignadosAMi = dashboard.ticketsAsignadosAMi ?? 0;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-indigo-100 rounded-lg">
            <LayoutDashboard className="w-6 h-6 text-indigo-600" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-slate-900">Dashboard</h1>
            <p className="text-sm text-slate-500">Métricas en tiempo real del sistema</p>
          </div>
        </div>
        <button
          onClick={() => refetch()}
          className="flex items-center gap-2 px-3 py-1.5 text-sm text-slate-600 hover:text-indigo-600 bg-white border border-slate-200 rounded-lg hover:border-indigo-300 transition"
        >
          <Activity className="w-4 h-4" />
          Actualizar
        </button>
      </div>

      {/* ── KPI Cards ─────────────────────────────────────────────── */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {kpis.map((kpi) => (
          <div
            key={kpi.name}
            className="bg-white rounded-xl border border-slate-200 p-5 hover:shadow-md transition-shadow"
          >
            <div className="flex items-center justify-between mb-3">
              <p className="text-sm font-medium text-slate-500">{kpi.name}</p>
              <div className={`p-2 rounded-lg ${kpi.bgIcon}`}>
                <kpi.icon className={`w-5 h-5 ${kpi.color}`} />
              </div>
            </div>
            <p className="text-3xl font-bold text-slate-900 mb-1">{kpi.value}</p>
            <div className={`flex items-center gap-1 text-xs font-medium ${kpi.trendUp ? 'text-rose-500' : 'text-emerald-500'}`}>
              {kpi.trendUp ? <ArrowUpRight className="w-3.5 h-3.5" /> : <ArrowDownRight className="w-3.5 h-3.5" />}
              {kpi.subtitle}
            </div>
          </div>
        ))}
      </div>

      {/* ── Resumen rápido ────────────────────────────────────────── */}
      <div className="grid grid-cols-1 sm:grid-cols-4 gap-4">
        <div className="bg-white rounded-xl border border-slate-200 p-5">
          <div className="flex items-center gap-2 mb-1">
            <Ticket className="w-4 h-4 text-slate-400" />
            <p className="text-sm text-slate-500">Total Tickets</p>
          </div>
          <p className="text-2xl font-bold text-slate-900">{totalTickets}</p>
        </div>
        <div className="bg-white rounded-xl border border-slate-200 p-5">
          <div className="flex items-center gap-2 mb-1">
            <Clock className="w-4 h-4 text-slate-400" />
            <p className="text-sm text-slate-500">En Proceso</p>
          </div>
          <p className="text-2xl font-bold text-slate-900">{enProceso}</p>
        </div>
        <div className="bg-white rounded-xl border border-slate-200 p-5">
          <div className="flex items-center gap-2 mb-1">
            <TrendingUp className="w-4 h-4 text-slate-400" />
            <p className="text-sm text-slate-500">Asignados a mí</p>
          </div>
          <p className="text-2xl font-bold text-slate-900">{asignadosAMi}</p>
        </div>
        <div className="bg-white rounded-xl border border-slate-200 p-5">
          <div className="flex items-center gap-2 mb-1">
            <CheckCircle className="w-4 h-4 text-emerald-500" />
            <p className="text-sm text-slate-500">Tasa de Resolución</p>
          </div>
          <p className="text-2xl font-bold text-slate-900">{tasaResolucion}%</p>
        </div>
      </div>

      {/* ── Charts Grid ───────────────────────────────────────────── */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* PieChart: Tickets por Estado */}
        <div className="bg-white rounded-xl border border-slate-200 p-6">
          <h3 className="text-base font-semibold text-slate-900 mb-4">Tickets por Estado</h3>
          {estadoData.length > 0 ? (
            <ResponsiveContainer width="100%" height={280}>
              <PieChart>
                <Pie
                  data={estadoData}
                  cx="50%"
                  cy="50%"
                  innerRadius={60}
                  outerRadius={100}
                  paddingAngle={3}
                  dataKey="value"
                  nameKey="name"
                  stroke="none"
                >
                  {estadoData.map((entry, index) => (
                    <Cell key={entry.name} fill={PIE_COLORS[index % PIE_COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip
                  contentStyle={{
                    backgroundColor: '#1e293b',
                    border: 'none',
                    borderRadius: '8px',
                    color: '#f8fafc',
                    fontSize: '13px',
                  }}
                />
                <Legend
                  verticalAlign="bottom"
                  iconType="circle"
                  iconSize={8}
                  wrapperStyle={{ fontSize: '12px', color: '#64748b' }}
                />
              </PieChart>
            </ResponsiveContainer>
          ) : (
            <p className="text-slate-400 text-center py-12">Sin datos</p>
          )}
        </div>

        {/* BarChart: Tickets por Prioridad */}
        <div className="bg-white rounded-xl border border-slate-200 p-6">
          <h3 className="text-base font-semibold text-slate-900 mb-4">Tickets por Prioridad</h3>
          {prioridadData.length > 0 ? (
            <ResponsiveContainer width="100%" height={280}>
              <BarChart data={prioridadData} barSize={40}>
                <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                <XAxis dataKey="name" tick={{ fontSize: 12, fill: '#64748b' }} axisLine={false} tickLine={false} />
                <YAxis tick={{ fontSize: 12, fill: '#64748b' }} axisLine={false} tickLine={false} />
                <Tooltip
                  contentStyle={{
                    backgroundColor: '#1e293b',
                    border: 'none',
                    borderRadius: '8px',
                    color: '#f8fafc',
                    fontSize: '13px',
                  }}
                />
                <Bar dataKey="cantidad" radius={[6, 6, 0, 0]}>
                  {prioridadData.map((entry, index) => (
                    <Cell key={entry.name} fill={BAR_COLORS[index % BAR_COLORS.length]} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          ) : (
            <p className="text-slate-400 text-center py-12">Sin datos</p>
          )}
        </div>
      </div>

      {/* ── Departamentos (ancho completo) ────────────────────────── */}
      <div className="bg-white rounded-xl border border-slate-200 p-6">
        <h3 className="text-base font-semibold text-slate-900 mb-4">Tickets por Departamento</h3>
        {departamentoData.length > 0 ? (
          <ResponsiveContainer width="100%" height={Math.max(200, departamentoData.length * 45)}>
            <BarChart data={departamentoData} layout="vertical" barSize={20}>
              <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" horizontal={false} />
              <XAxis type="number" tick={{ fontSize: 12, fill: '#64748b' }} axisLine={false} tickLine={false} />
              <YAxis
                type="category"
                dataKey="name"
                width={120}
                tick={{ fontSize: 11, fill: '#64748b' }}
                axisLine={false}
                tickLine={false}
              />
              <Tooltip
                contentStyle={{
                  backgroundColor: '#1e293b',
                  border: 'none',
                  borderRadius: '8px',
                  color: '#f8fafc',
                  fontSize: '13px',
                }}
                formatter={(value) => [value, 'Tickets']}
                labelFormatter={(label) => {
                  const item = departamentoData.find((d) => d.name === label);
                  return item?.fullName || label;
                }}
              />
              <Bar dataKey="tickets" fill="#6366f1" radius={[0, 6, 6, 0]} />
            </BarChart>
          </ResponsiveContainer>
        ) : (
          <p className="text-slate-400 text-center py-12">Sin datos</p>
        )}
      </div>
    </div>
  );
}
