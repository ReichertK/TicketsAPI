import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useMutation, useQuery } from '@tanstack/react-query';
import { apiClient } from '../services/api.service';
import { API_ENDPOINTS } from '../config/api';
import {
  CreateUpdateTicketDTO,
  ApiResponse,
  TicketDTO,
  PrioridadDTO,
  DepartamentoDTO,
  MotivoDTO,
} from '../types/api.types';
import { Save, X, AlertTriangle, Building2, FileText, Edit3, Tag } from 'lucide-react';

export default function EditTicketPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const ticketId = Number(id);

  const [ticket, setTicket] = useState<CreateUpdateTicketDTO>({
    contenido: '',
    id_Prioridad: 0,
    id_Departamento: 0,
  });

  // ── Cargar datos del ticket existente ──────────────────────────
  const { data: ticketData, isLoading: isLoadingTicket } = useQuery({
    queryKey: ['ticket', ticketId],
    queryFn: async () => {
      const response = await apiClient.get<ApiResponse<TicketDTO>>(
        API_ENDPOINTS.TICKETS_BY_ID(ticketId)
      );
      return response.data.datos;
    },
    enabled: !!ticketId,
  });

  // Rellenar formulario cuando llegan los datos
  useEffect(() => {
    if (ticketData) {
      setTicket({
        contenido: ticketData.contenido || '',
        id_Prioridad: ticketData.id_Prioridad || 0,
        id_Departamento: ticketData.id_Departamento || 0,
        id_Motivo: ticketData.id_Motivo,
      });
    }
  }, [ticketData]);

  // ── Catálogos ──────────────────────────────────────────────────
  const { data: prioridades } = useQuery({
    queryKey: ['prioridades'],
    queryFn: async () => {
      const response = await apiClient.get<ApiResponse<PrioridadDTO[]>>(
        API_ENDPOINTS.PRIORIDADES
      );
      return response.data.datos || [];
    },
  });

  const { data: departamentos } = useQuery({
    queryKey: ['departamentos'],
    queryFn: async () => {
      const response = await apiClient.get<ApiResponse<DepartamentoDTO[]>>(
        API_ENDPOINTS.DEPARTAMENTOS
      );
      return response.data.datos || [];
    },
  });

  const { data: motivos } = useQuery({
    queryKey: ['motivos'],
    queryFn: async () => {
      const response = await apiClient.get<ApiResponse<MotivoDTO[]>>(
        API_ENDPOINTS.MOTIVOS
      );
      return response.data.datos || [];
    },
  });

  // ── Mutation ───────────────────────────────────────────────────
  const updateMutation = useMutation({
    mutationFn: async (data: CreateUpdateTicketDTO) => {
      const response = await apiClient.put<ApiResponse<any>>(
        API_ENDPOINTS.TICKETS_BY_ID(ticketId),
        data
      );
      return response.data;
    },
    onSuccess: () => {
      navigate(`/tickets/${ticketId}`);
    },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    updateMutation.mutate(ticket);
  };

  const isLoadingCatalogs = !prioridades || !departamentos || !motivos;

  if (isLoadingTicket || isLoadingCatalogs) {
    return (
      <div className="flex items-center justify-center h-96">
        <div className="flex flex-col items-center gap-3">
          <div className="animate-spin rounded-full h-10 w-10 border-b-2 border-indigo-600"></div>
          <p className="text-sm text-slate-500">Cargando ticket…</p>
        </div>
      </div>
    );
  }

  if (!ticketData) {
    return (
      <div className="flex flex-col items-center justify-center h-96 gap-4">
        <AlertTriangle className="w-12 h-12 text-amber-400" />
        <p className="text-lg text-slate-600">Ticket no encontrado</p>
        <button
          onClick={() => navigate('/tickets')}
          className="text-indigo-600 hover:text-indigo-700 text-sm font-medium"
        >
          Volver a Tickets
        </button>
      </div>
    );
  }

  return (
    <div className="max-w-3xl mx-auto">
      <div className="bg-white rounded-xl border border-slate-200 shadow-sm">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-5 border-b border-slate-200">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-amber-100 rounded-lg">
              <Edit3 className="w-5 h-5 text-amber-600" />
            </div>
            <h1 className="text-xl font-bold text-slate-900">
              Editar Ticket #{ticketId}
            </h1>
          </div>
          <button
            onClick={() => navigate(`/tickets/${ticketId}`)}
            className="p-1.5 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-lg transition"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-6 space-y-6">
          {/* Contenido */}
          <div>
            <label className="flex items-center gap-2 text-sm font-medium text-slate-700 mb-2">
              <FileText className="w-4 h-4 text-slate-400" />
              Descripción del problema <span className="text-rose-500">*</span>
            </label>
            <textarea
              required
              rows={6}
              className="w-full px-4 py-3 border border-slate-300 rounded-lg bg-white text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition text-sm resize-none"
              value={ticket.contenido}
              onChange={(e) => setTicket({ ...ticket, contenido: e.target.value })}
              placeholder="Describe el problema con el mayor detalle posible..."
            />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Prioridad */}
            <div>
              <label className="flex items-center gap-2 text-sm font-medium text-slate-700 mb-2">
                <AlertTriangle className="w-4 h-4 text-slate-400" />
                Prioridad <span className="text-rose-500">*</span>
              </label>
              <div className="relative">
                <select
                  required
                  className="w-full pl-4 pr-10 py-2.5 border border-slate-300 rounded-lg bg-white text-slate-900 focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition appearance-none text-sm"
                  value={ticket.id_Prioridad}
                  onChange={(e) =>
                    setTicket({ ...ticket, id_Prioridad: parseInt(e.target.value) })
                  }
                >
                  <option value={0}>Selecciona una prioridad</option>
                  {prioridades?.map((p) => (
                    <option key={p.id_Prioridad} value={p.id_Prioridad}>
                      {p.nombre_Prioridad}
                    </option>
                  ))}
                </select>
                <svg className="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" /></svg>
              </div>
            </div>

            {/* Departamento */}
            <div>
              <label className="flex items-center gap-2 text-sm font-medium text-slate-700 mb-2">
                <Building2 className="w-4 h-4 text-slate-400" />
                Departamento <span className="text-rose-500">*</span>
              </label>
              <div className="relative">
                <select
                  required
                  className="w-full pl-4 pr-10 py-2.5 border border-slate-300 rounded-lg bg-white text-slate-900 focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition appearance-none text-sm"
                  value={ticket.id_Departamento}
                  onChange={(e) =>
                    setTicket({ ...ticket, id_Departamento: parseInt(e.target.value) })
                  }
                >
                  <option value={0}>Selecciona un departamento</option>
                  {departamentos?.map((d) => (
                    <option key={d.id_Departamento} value={d.id_Departamento}>
                      {d.nombre}
                    </option>
                  ))}
                </select>
                <svg className="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" /></svg>
              </div>
            </div>
          </div>

          {/* Motivo */}
          <div>
            <label className="flex items-center gap-2 text-sm font-medium text-slate-700 mb-2">
              <Tag className="w-4 h-4 text-slate-400" />
              Motivo
            </label>
            <div className="relative">
              <select
                className="w-full pl-4 pr-10 py-2.5 border border-slate-300 rounded-lg bg-white text-slate-900 focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition appearance-none text-sm"
                value={ticket.id_Motivo || 0}
                onChange={(e) => {
                  const val = parseInt(e.target.value);
                  setTicket({ ...ticket, id_Motivo: val || undefined });
                }}
              >
                <option value={0}>Sin motivo</option>
                {motivos?.map((m) => (
                  <option key={m.id_Motivo} value={m.id_Motivo}>
                    {m.nombre}
                  </option>
                ))}
              </select>
              <svg className="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" /></svg>
            </div>
          </div>

          {/* Error */}
          {updateMutation.isError && (
            <div className="flex items-center gap-2 bg-rose-50 border border-rose-200 text-rose-700 px-4 py-3 rounded-lg text-sm">
              <AlertTriangle className="w-4 h-4 shrink-0" />
              {(updateMutation.error as any)?.response?.data?.mensaje || 'Error al actualizar el ticket. Inténtalo de nuevo.'}
            </div>
          )}

          {/* Actions */}
          <div className="flex items-center gap-3 pt-2">
            <button
              type="submit"
              disabled={updateMutation.isPending}
              className="flex items-center gap-2 bg-indigo-600 text-white px-5 py-2.5 rounded-lg hover:bg-indigo-700 disabled:opacity-50 shadow-sm transition text-sm font-medium"
            >
              <Save className="w-4 h-4" />
              {updateMutation.isPending ? 'Guardando…' : 'Guardar Cambios'}
            </button>
            <button
              type="button"
              onClick={() => navigate(`/tickets/${ticketId}`)}
              className="px-5 py-2.5 border border-slate-300 text-slate-700 rounded-lg hover:bg-slate-50 transition text-sm font-medium"
            >
              Cancelar
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
