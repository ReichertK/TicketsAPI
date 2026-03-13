import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useMutation, useQuery } from '@tanstack/react-query';
import { apiClient } from '../services/api.service';
import { API_ENDPOINTS } from '../config/api';
import { 
  CreateUpdateTicketDTO, 
  ApiResponse, 
  PrioridadDTO, 
  DepartamentoDTO,
  MotivoDTO 
} from '../types/api.types';
import { Save, X, AlertTriangle, Building2, FileText, TicketPlus, Tag } from 'lucide-react';

export default function CreateTicketPage() {
  const navigate = useNavigate();
  const [ticket, setTicket] = useState<CreateUpdateTicketDTO>({
    contenido: '',
    id_Prioridad: 0,
    id_Departamento: 0,
    id_Motivo: undefined,
  });
  const [submitError, setSubmitError] = useState<string | null>(null);

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
      return (response.data.datos || []).filter((m) => m.activo);
    },
  });

  const createMutation = useMutation({
    mutationFn: async (data: CreateUpdateTicketDTO) => {
      const response = await apiClient.post<ApiResponse<any>>(
        API_ENDPOINTS.TICKETS,
        data
      );
      return response.data;
    },
    onSuccess: () => {
      navigate('/tickets');
    },
    onError: (err: any) => {
      // Parsear ValidationProblemDetails de ASP.NET
      const respData = err?.response?.data;
      if (respData?.errors) {
        const messages = Object.values(respData.errors).flat().join('. ');
        setSubmitError(messages || 'Error de validación.');
      } else {
        setSubmitError(respData?.mensaje || 'Error al crear el ticket. Inténtalo de nuevo.');
      }
    },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitError(null);

    // Validación frontend: contenido mínimo 10 caracteres
    if (ticket.contenido.trim().length < 10) {
      setSubmitError('La descripción debe tener al menos 10 caracteres.');
      return;
    }
    if (ticket.id_Prioridad === 0) {
      setSubmitError('Selecciona una prioridad.');
      return;
    }
    if (ticket.id_Departamento === 0) {
      setSubmitError('Selecciona un departamento.');
      return;
    }

    createMutation.mutate(ticket);
  };

  return (
    <div className="max-w-3xl mx-auto">
      <div className="bg-white rounded-xl border border-slate-200 shadow-sm">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-5 border-b border-slate-200">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-indigo-100 rounded-lg">
              <TicketPlus className="w-5 h-5 text-indigo-600" />
            </div>
            <h1 className="text-xl font-bold text-slate-900">Crear Nuevo Ticket</h1>
          </div>
          <button
            onClick={() => navigate('/tickets')}
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
              minLength={10}
              maxLength={10000}
              rows={6}
              className="w-full px-4 py-3 border border-slate-300 rounded-lg bg-white text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition text-sm resize-none"
              value={ticket.contenido}
              onChange={(e) => setTicket({ ...ticket, contenido: e.target.value })}
              placeholder="Describe el problema con el mayor detalle posible (mínimo 10 caracteres)..."
            />
            <div className="mt-1 text-xs text-slate-400 text-right">
              {ticket.contenido.length}/10000
              {ticket.contenido.length > 0 && ticket.contenido.length < 10 && (
                <span className="text-amber-500 ml-2">Mínimo 10 caracteres</span>
              )}
            </div>
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
              Motivo <span className="text-rose-500">*</span>
            </label>
            <div className="relative">
              <select
                required
                className="w-full pl-4 pr-10 py-2.5 border border-slate-300 rounded-lg bg-white text-slate-900 focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition appearance-none text-sm"
                value={ticket.id_Motivo ?? 0}
                onChange={(e) =>
                  setTicket({ ...ticket, id_Motivo: parseInt(e.target.value) || undefined })
                }
              >
                <option value={0}>Selecciona un motivo</option>
                {motivos?.map((m) => (
                  <option key={m.id_Motivo} value={m.id_Motivo}>
                    {m.nombre}{m.categoria ? ` (${m.categoria})` : ''}
                  </option>
                ))}
              </select>
              <svg className="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" /></svg>
            </div>
          </div>

          {/* Error */}
          {(createMutation.isError || submitError) && (
            <div className="flex items-center gap-2 bg-rose-50 border border-rose-200 text-rose-700 px-4 py-3 rounded-lg text-sm">
              <AlertTriangle className="w-4 h-4 shrink-0" />
              {submitError || 'Error al crear el ticket. Inténtalo de nuevo.'}
            </div>
          )}

          {/* Actions */}
          <div className="flex items-center gap-3 pt-2">
            <button
              type="submit"
              disabled={createMutation.isPending}
              className="flex items-center gap-2 bg-indigo-600 text-white px-5 py-2.5 rounded-lg hover:bg-indigo-700 disabled:opacity-50 shadow-sm transition text-sm font-medium"
            >
              <Save className="w-4 h-4" />
              {createMutation.isPending ? 'Creando…' : 'Crear Ticket'}
            </button>
            <button
              type="button"
              onClick={() => navigate('/tickets')}
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
