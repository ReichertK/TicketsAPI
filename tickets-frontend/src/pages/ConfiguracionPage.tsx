import { useState, useEffect } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { apiClient } from '../services/api.service';
import { API_ENDPOINTS } from '../config/api';
import type {
  ApiResponse,
  MotivoDTO,
  CreateUpdateMotivoDTO,
  PrioridadDTO,
  CreateUpdatePrioridadDTO,
  EstadoDTO,
  CreateUpdateEstadoDTO,
  DepartamentoDTO,
  CreateUpdateDepartamentoDTO,
} from '../types/api.types';
import { sileo } from 'sileo';
import ErrorAlert from '../components/ui/ErrorAlert';
import EmptyState from '../components/ui/EmptyState';
import ConfirmActionModal from '../components/ui/ConfirmActionModal';
import {
  Settings,
  Tag,
  AlertTriangle as PriorityIcon,
  Layers,
  Building2,
  Pencil,
  X,
  Search,
  AlertTriangle,
  ShieldAlert,
} from 'lucide-react';
import SeguridadTab from './SeguridadTab';

type TabId = 'departamentos' | 'estados' | 'prioridades' | 'motivos' | 'seguridad';

const TABS: { id: TabId; label: string; icon: typeof Settings }[] = [
  { id: 'departamentos', label: 'Departamentos', icon: Building2 },
  { id: 'estados', label: 'Estados', icon: Layers },
  { id: 'prioridades', label: 'Prioridades', icon: PriorityIcon },
  { id: 'motivos', label: 'Motivos', icon: Tag },
  { id: 'seguridad', label: 'Seguridad', icon: ShieldAlert },
];

// Toggle Switch reutilizable
function ToggleSwitch({ activo, onClick, title }: { activo: boolean; onClick: () => void; title?: string }) {
  return (
    <button
      onClick={onClick}
      className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2 ${
        activo ? 'bg-emerald-500 focus:ring-emerald-400' : 'bg-slate-300 focus:ring-slate-400'
      }`}
      title={title ?? (activo ? 'Desactivar' : 'Reactivar')}
    >
      <span className={`inline-block h-4 w-4 transform rounded-full bg-white shadow-sm transition-transform ${activo ? 'translate-x-6' : 'translate-x-1'}`} />
    </button>
  );
}

// Modal genérico de edición
interface EditModalProps {
  open: boolean;
  title: string;
  fields: { id: string; label: string; value: string; required?: boolean; placeholder?: string }[];
  onChange: (id: string, value: string) => void;
  onSubmit: () => void;
  onClose: () => void;
  isPending: boolean;
}

function EditModal({ open, title, fields, onChange, onSubmit, onClose, isPending }: EditModalProps) {
  if (!open) return null;
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md mx-4 overflow-hidden">
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-200">
          <h3 className="text-lg font-semibold text-slate-900">{title}</h3>
          <button onClick={onClose} className="p-1 text-slate-400 hover:text-slate-600 rounded-lg hover:bg-slate-100 transition">
            <X className="w-5 h-5" />
          </button>
        </div>
        <form
          onSubmit={(e) => { e.preventDefault(); onSubmit(); }}
          className="p-6 space-y-4"
        >
          {fields.map((f) => (
            <div key={f.id}>
              <label htmlFor={`edit-${f.id}`} className="block text-sm font-medium text-slate-700 mb-1">
                {f.label}{f.required ? ' *' : ''}
              </label>
              <input
                id={`edit-${f.id}`}
                required={f.required}
                value={f.value}
                onChange={(e) => onChange(f.id, e.target.value)}
                className="w-full px-3 py-2.5 border border-slate-200 rounded-lg bg-white text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm transition"
                placeholder={f.placeholder ?? ''}
              />
            </div>
          ))}
          <div className="flex items-center justify-end gap-3 pt-4 border-t border-slate-100">
            <button type="button" onClick={onClose} className="px-4 py-2.5 text-sm font-medium text-slate-700 border border-slate-200 rounded-lg hover:bg-slate-50 transition">
              Cancelar
            </button>
            <button type="submit" disabled={isPending} className="px-5 py-2.5 text-sm font-medium text-white bg-indigo-600 rounded-lg hover:bg-indigo-700 disabled:opacity-50 transition shadow-sm">
              {isPending ? 'Guardando…' : 'Guardar Cambios'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

// Tab: Departamentos
function DepartamentosTab() {
  const queryClient = useQueryClient();
  const [searchInput, setSearchInput] = useState('');
  const [toggleTarget, setToggleTarget] = useState<DepartamentoDTO | null>(null);
  const [editTarget, setEditTarget] = useState<DepartamentoDTO | null>(null);
  const [editForm, setEditForm] = useState({ nombre: '', descripcion: '' });

  useEffect(() => {
    if (editTarget) setEditForm({ nombre: editTarget.nombre, descripcion: editTarget.descripcion ?? '' });
  }, [editTarget]);

  const { data: items, isLoading, isError, error, refetch } = useQuery({
    queryKey: ['config-departamentos'],
    queryFn: async () => {
      const res = await apiClient.get<ApiResponse<DepartamentoDTO[]>>(API_ENDPOINTS.DEPARTAMENTOS);
      return res.data.datos ?? [];
    },
  });

  const toggleMutation = useMutation({
    mutationFn: (item: DepartamentoDTO) => apiClient.delete(API_ENDPOINTS.DEPARTAMENTOS_BY_ID(item.id_Departamento)),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['config-departamentos'] });
      queryClient.invalidateQueries({ queryKey: ['departamentos'] });
      sileo.success({ description: 'Estado actualizado' });
      setToggleTarget(null);
    },
    onError: (err: any) => { sileo.error({ description: err?.response?.data?.mensaje || 'Error' }); setToggleTarget(null); },
  });

  const editMutation = useMutation({
    mutationFn: (data: { id: number; dto: CreateUpdateDepartamentoDTO }) =>
      apiClient.put(API_ENDPOINTS.DEPARTAMENTOS_BY_ID(data.id), data.dto),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['config-departamentos'] });
      queryClient.invalidateQueries({ queryKey: ['departamentos'] });
      sileo.success({ description: 'Departamento actualizado' });
      setEditTarget(null);
    },
    onError: (err: any) => { sileo.error({ description: err?.response?.data?.mensaje || 'Error al guardar' }); },
  });

  if (isError) return <ErrorAlert title="Error" message={(error as any)?.response?.data?.mensaje || 'Error al cargar.'} onRetry={() => refetch()} />;

  const filtered = items?.filter((d) => !searchInput || d.nombre.toLowerCase().includes(searchInput.toLowerCase())) ?? [];

  return (
    <div className="space-y-4">
      <div className="relative max-w-sm">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 w-4 h-4" />
        <input type="text" placeholder="Buscar departamentos…" value={searchInput} onChange={(e) => setSearchInput(e.target.value)}
          className="w-full pl-9 pr-4 py-2 border border-slate-200 rounded-lg bg-white text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm transition" />
      </div>

      {isLoading && <div className="flex items-center justify-center h-40"><div className="animate-spin rounded-full h-8 w-8 border-2 border-indigo-200 border-t-indigo-600" /></div>}

      {!isLoading && filtered.length === 0 ? (
        <EmptyState variant={searchInput ? 'no-results' : 'empty'} title="Sin departamentos" />
      ) : !isLoading && (
        <div className="bg-white rounded-xl border border-slate-200 overflow-hidden">
          <table className="min-w-full divide-y divide-slate-200">
            <thead className="bg-slate-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">ID</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Nombre</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Descripción</th>
                <th className="px-6 py-3 text-center text-xs font-medium text-slate-500 uppercase tracking-wider">Estado</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-slate-500 uppercase tracking-wider">Acciones</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200">
              {filtered.map((d) => (
                <tr key={d.id_Departamento} className={`hover:bg-slate-50 transition ${!d.activo ? 'opacity-50' : ''}`}>
                  <td className="px-6 py-3 text-sm font-medium text-slate-900">#{d.id_Departamento}</td>
                  <td className="px-6 py-3 text-sm text-slate-900 font-medium">{d.nombre}</td>
                  <td className="px-6 py-3 text-sm text-slate-600">{d.descripcion || '—'}</td>
                  <td className="px-6 py-3 text-center">
                    <ToggleSwitch activo={d.activo} onClick={() => setToggleTarget(d)} />
                  </td>
                  <td className="px-6 py-3 text-right">
                    <button onClick={() => setEditTarget(d)} className="p-2 text-slate-400 hover:text-indigo-600 hover:bg-indigo-50 rounded-lg transition" title="Editar">
                      <Pencil className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      <ConfirmActionModal
        open={!!toggleTarget}
        variant={toggleTarget?.activo ? 'danger' : 'info'}
        Icon={AlertTriangle}
        title={toggleTarget?.activo ? '¿Desactivar este departamento?' : '¿Reactivar este departamento?'}
        description={toggleTarget?.nombre}
        confirmText={toggleTarget?.activo ? 'Sí, desactivar' : 'Sí, reactivar'}
        isPending={toggleMutation.isPending}
        onConfirm={() => toggleTarget && toggleMutation.mutate(toggleTarget)}
        onClose={() => setToggleTarget(null)}
      />

      <EditModal
        open={!!editTarget}
        title="Editar Departamento"
        fields={[
          { id: 'nombre', label: 'Nombre', value: editForm.nombre, required: true, placeholder: 'Nombre del departamento' },
          { id: 'descripcion', label: 'Descripción', value: editForm.descripcion, placeholder: 'Descripción opcional' },
        ]}
        onChange={(id, val) => setEditForm((f) => ({ ...f, [id]: val }))}
        onSubmit={() => editTarget && editMutation.mutate({ id: editTarget.id_Departamento, dto: editForm })}
        onClose={() => setEditTarget(null)}
        isPending={editMutation.isPending}
      />
    </div>
  );
}

// Tab: Estados
function EstadosTab() {
  const queryClient = useQueryClient();
  const [searchInput, setSearchInput] = useState('');
  const [toggleTarget, setToggleTarget] = useState<EstadoDTO | null>(null);
  const [editTarget, setEditTarget] = useState<EstadoDTO | null>(null);
  const [editForm, setEditForm] = useState({ nombre: '', descripcion: '' });

  useEffect(() => {
    if (editTarget) setEditForm({ nombre: editTarget.nombre_Estado, descripcion: '' });
  }, [editTarget]);

  const { data: items, isLoading, isError, error, refetch } = useQuery({
    queryKey: ['config-estados'],
    queryFn: async () => {
      const res = await apiClient.get<ApiResponse<EstadoDTO[]>>(API_ENDPOINTS.ADMIN_ESTADOS);
      return res.data.datos ?? [];
    },
  });

  const toggleMutation = useMutation({
    mutationFn: (item: EstadoDTO) => apiClient.delete(API_ENDPOINTS.ADMIN_ESTADOS_BY_ID(item.id_Estado)),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['config-estados'] });
      queryClient.invalidateQueries({ queryKey: ['estados'] });
      sileo.success({ description: 'Estado actualizado' });
      setToggleTarget(null);
    },
    onError: (err: any) => { sileo.error({ description: err?.response?.data?.mensaje || 'Error' }); setToggleTarget(null); },
  });

  const editMutation = useMutation({
    mutationFn: (data: { id: number; dto: CreateUpdateEstadoDTO }) =>
      apiClient.put(API_ENDPOINTS.ADMIN_ESTADOS_BY_ID(data.id), data.dto),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['config-estados'] });
      queryClient.invalidateQueries({ queryKey: ['estados'] });
      sileo.success({ description: 'Estado actualizado' });
      setEditTarget(null);
    },
    onError: (err: any) => { sileo.error({ description: err?.response?.data?.mensaje || 'Error al guardar' }); },
  });

  const isCritical = (e: EstadoDTO) => e.nombre_Estado === 'Abierto' || e.nombre_Estado === 'Cerrado';

  if (isError) return <ErrorAlert title="Error" message={(error as any)?.response?.data?.mensaje || 'Error al cargar.'} onRetry={() => refetch()} />;

  const filtered = items?.filter((e) => !searchInput || e.nombre_Estado.toLowerCase().includes(searchInput.toLowerCase())) ?? [];

  return (
    <div className="space-y-4">
      <div className="relative max-w-sm">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 w-4 h-4" />
        <input type="text" placeholder="Buscar estados…" value={searchInput} onChange={(e) => setSearchInput(e.target.value)}
          className="w-full pl-9 pr-4 py-2 border border-slate-200 rounded-lg bg-white text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm transition" />
      </div>

      {isLoading && <div className="flex items-center justify-center h-40"><div className="animate-spin rounded-full h-8 w-8 border-2 border-indigo-200 border-t-indigo-600" /></div>}

      {!isLoading && filtered.length === 0 ? (
        <EmptyState variant={searchInput ? 'no-results' : 'empty'} title="Sin estados" />
      ) : !isLoading && (
        <div className="bg-white rounded-xl border border-slate-200 overflow-hidden">
          <table className="min-w-full divide-y divide-slate-200">
            <thead className="bg-slate-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">ID</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Nombre</th>
                <th className="px-6 py-3 text-center text-xs font-medium text-slate-500 uppercase tracking-wider">Estado</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-slate-500 uppercase tracking-wider">Acciones</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200">
              {filtered.map((e) => (
                <tr key={e.id_Estado} className={`hover:bg-slate-50 transition ${!e.activo ? 'opacity-50' : ''}`}>
                  <td className="px-6 py-3 text-sm font-medium text-slate-900">#{e.id_Estado}</td>
                  <td className="px-6 py-3 text-sm text-slate-900 font-medium">
                    {e.nombre_Estado}
                    {isCritical(e) && (
                      <span className="ml-2 text-xs bg-amber-100 text-amber-700 px-1.5 py-0.5 rounded-full font-normal">Crítico</span>
                    )}
                  </td>
                  <td className="px-6 py-3 text-center">
                    {isCritical(e) ? (
                      <span className="inline-flex items-center px-2.5 py-1 text-xs font-medium rounded-full bg-emerald-100 text-emerald-700">
                        Siempre activo
                      </span>
                    ) : (
                      <ToggleSwitch activo={e.activo} onClick={() => setToggleTarget(e)} />
                    )}
                  </td>
                  <td className="px-6 py-3 text-right">
                    <button onClick={() => setEditTarget(e)} className="p-2 text-slate-400 hover:text-indigo-600 hover:bg-indigo-50 rounded-lg transition" title="Editar">
                      <Pencil className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      <ConfirmActionModal
        open={!!toggleTarget}
        variant={toggleTarget?.activo ? 'danger' : 'info'}
        Icon={AlertTriangle}
        title={toggleTarget?.activo ? '¿Desactivar este estado?' : '¿Reactivar este estado?'}
        description={toggleTarget?.nombre_Estado}
        confirmText={toggleTarget?.activo ? 'Sí, desactivar' : 'Sí, reactivar'}
        isPending={toggleMutation.isPending}
        onConfirm={() => toggleTarget && toggleMutation.mutate(toggleTarget)}
        onClose={() => setToggleTarget(null)}
      />

      <EditModal
        open={!!editTarget}
        title="Editar Estado"
        fields={[
          { id: 'nombre', label: 'Nombre', value: editForm.nombre, required: true, placeholder: 'Nombre del estado' },
          { id: 'descripcion', label: 'Descripción', value: editForm.descripcion, placeholder: 'Descripción opcional' },
        ]}
        onChange={(id, val) => setEditForm((f) => ({ ...f, [id]: val }))}
        onSubmit={() => editTarget && editMutation.mutate({ id: editTarget.id_Estado, dto: editForm })}
        onClose={() => setEditTarget(null)}
        isPending={editMutation.isPending}
      />
    </div>
  );
}

// Tab: Prioridades
function PrioridadesTab() {
  const queryClient = useQueryClient();
  const [searchInput, setSearchInput] = useState('');
  const [toggleTarget, setToggleTarget] = useState<PrioridadDTO | null>(null);
  const [editTarget, setEditTarget] = useState<PrioridadDTO | null>(null);
  const [editForm, setEditForm] = useState({ nombre: '', descripcion: '' });

  useEffect(() => {
    if (editTarget) setEditForm({ nombre: editTarget.nombre_Prioridad, descripcion: '' });
  }, [editTarget]);

  const { data: items, isLoading, isError, error, refetch } = useQuery({
    queryKey: ['config-prioridades'],
    queryFn: async () => {
      const res = await apiClient.get<ApiResponse<PrioridadDTO[]>>(API_ENDPOINTS.ADMIN_PRIORIDADES);
      return res.data.datos ?? [];
    },
  });

  const toggleMutation = useMutation({
    mutationFn: (item: PrioridadDTO) => apiClient.delete(API_ENDPOINTS.ADMIN_PRIORIDADES_BY_ID(item.id_Prioridad)),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['config-prioridades'] });
      queryClient.invalidateQueries({ queryKey: ['prioridades'] });
      sileo.success({ description: 'Prioridad actualizada' });
      setToggleTarget(null);
    },
    onError: (err: any) => { sileo.error({ description: err?.response?.data?.mensaje || 'Error' }); setToggleTarget(null); },
  });

  const editMutation = useMutation({
    mutationFn: (data: { id: number; dto: CreateUpdatePrioridadDTO }) =>
      apiClient.put(API_ENDPOINTS.ADMIN_PRIORIDADES_BY_ID(data.id), data.dto),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['config-prioridades'] });
      queryClient.invalidateQueries({ queryKey: ['prioridades'] });
      sileo.success({ description: 'Prioridad actualizada' });
      setEditTarget(null);
    },
    onError: (err: any) => { sileo.error({ description: err?.response?.data?.mensaje || 'Error al guardar' }); },
  });

  if (isError) return <ErrorAlert title="Error" message={(error as any)?.response?.data?.mensaje || 'Error al cargar.'} onRetry={() => refetch()} />;

  const filtered = items?.filter((p) => !searchInput || p.nombre_Prioridad.toLowerCase().includes(searchInput.toLowerCase())) ?? [];

  return (
    <div className="space-y-4">
      <div className="relative max-w-sm">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 w-4 h-4" />
        <input type="text" placeholder="Buscar prioridades…" value={searchInput} onChange={(e) => setSearchInput(e.target.value)}
          className="w-full pl-9 pr-4 py-2 border border-slate-200 rounded-lg bg-white text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm transition" />
      </div>

      {isLoading && <div className="flex items-center justify-center h-40"><div className="animate-spin rounded-full h-8 w-8 border-2 border-indigo-200 border-t-indigo-600" /></div>}

      {!isLoading && filtered.length === 0 ? (
        <EmptyState variant={searchInput ? 'no-results' : 'empty'} title="Sin prioridades" />
      ) : !isLoading && (
        <div className="bg-white rounded-xl border border-slate-200 overflow-hidden">
          <table className="min-w-full divide-y divide-slate-200">
            <thead className="bg-slate-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">ID</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Nombre</th>
                <th className="px-6 py-3 text-center text-xs font-medium text-slate-500 uppercase tracking-wider">Estado</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-slate-500 uppercase tracking-wider">Acciones</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200">
              {filtered.map((p) => (
                <tr key={p.id_Prioridad} className={`hover:bg-slate-50 transition ${!p.activo ? 'opacity-50' : ''}`}>
                  <td className="px-6 py-3 text-sm font-medium text-slate-900">#{p.id_Prioridad}</td>
                  <td className="px-6 py-3 text-sm text-slate-900 font-medium">{p.nombre_Prioridad}</td>
                  <td className="px-6 py-3 text-center">
                    <ToggleSwitch activo={p.activo} onClick={() => setToggleTarget(p)} />
                  </td>
                  <td className="px-6 py-3 text-right">
                    <button onClick={() => setEditTarget(p)} className="p-2 text-slate-400 hover:text-indigo-600 hover:bg-indigo-50 rounded-lg transition" title="Editar">
                      <Pencil className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      <ConfirmActionModal
        open={!!toggleTarget}
        variant={toggleTarget?.activo ? 'danger' : 'info'}
        Icon={AlertTriangle}
        title={toggleTarget?.activo ? '¿Desactivar esta prioridad?' : '¿Reactivar esta prioridad?'}
        description={toggleTarget?.nombre_Prioridad}
        confirmText={toggleTarget?.activo ? 'Sí, desactivar' : 'Sí, reactivar'}
        isPending={toggleMutation.isPending}
        onConfirm={() => toggleTarget && toggleMutation.mutate(toggleTarget)}
        onClose={() => setToggleTarget(null)}
      />

      <EditModal
        open={!!editTarget}
        title="Editar Prioridad"
        fields={[
          { id: 'nombre', label: 'Nombre', value: editForm.nombre, required: true, placeholder: 'Nombre de la prioridad' },
          { id: 'descripcion', label: 'Descripción', value: editForm.descripcion, placeholder: 'Descripción opcional' },
        ]}
        onChange={(id, val) => setEditForm((f) => ({ ...f, [id]: val }))}
        onSubmit={() => editTarget && editMutation.mutate({ id: editTarget.id_Prioridad, dto: editForm })}
        onClose={() => setEditTarget(null)}
        isPending={editMutation.isPending}
      />
    </div>
  );
}

// Tab: Motivos
function MotivosTab() {
  const queryClient = useQueryClient();
  const [searchInput, setSearchInput] = useState('');
  const [toggleTarget, setToggleTarget] = useState<MotivoDTO | null>(null);
  const [editTarget, setEditTarget] = useState<MotivoDTO | null>(null);
  const [editForm, setEditForm] = useState({ nombre: '', descripcion: '', categoria: '' });

  useEffect(() => {
    if (editTarget) setEditForm({ nombre: editTarget.nombre, descripcion: editTarget.descripcion ?? '', categoria: editTarget.categoria ?? '' });
  }, [editTarget]);

  const { data: items, isLoading, isError, error, refetch } = useQuery({
    queryKey: ['config-motivos'],
    queryFn: async () => {
      const res = await apiClient.get<ApiResponse<MotivoDTO[]>>(API_ENDPOINTS.MOTIVOS);
      return res.data.datos ?? [];
    },
  });

  const toggleMutation = useMutation({
    mutationFn: (item: MotivoDTO) => apiClient.delete(`${API_ENDPOINTS.MOTIVOS}/${item.id_Motivo}`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['config-motivos'] });
      queryClient.invalidateQueries({ queryKey: ['motivos'] });
      sileo.success({ description: 'Motivo actualizado' });
      setToggleTarget(null);
    },
    onError: (err: any) => { sileo.error({ description: err?.response?.data?.mensaje || 'Error' }); setToggleTarget(null); },
  });

  const editMutation = useMutation({
    mutationFn: (data: { id: number; dto: CreateUpdateMotivoDTO }) =>
      apiClient.put(`${API_ENDPOINTS.MOTIVOS}/${data.id}`, data.dto),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['config-motivos'] });
      queryClient.invalidateQueries({ queryKey: ['motivos'] });
      sileo.success({ description: 'Motivo actualizado' });
      setEditTarget(null);
    },
    onError: (err: any) => { sileo.error({ description: err?.response?.data?.mensaje || 'Error al guardar' }); },
  });

  if (isError) return <ErrorAlert title="Error" message={(error as any)?.response?.data?.mensaje || 'Error al cargar.'} onRetry={() => refetch()} />;

  const filtered = items?.filter((m) => {
    if (!searchInput) return true;
    const q = searchInput.toLowerCase();
    return m.nombre?.toLowerCase().includes(q) || m.categoria?.toLowerCase().includes(q);
  }) ?? [];

  return (
    <div className="space-y-4">
      <div className="relative max-w-sm">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 w-4 h-4" />
        <input type="text" placeholder="Buscar motivos…" value={searchInput} onChange={(e) => setSearchInput(e.target.value)}
          className="w-full pl-9 pr-4 py-2 border border-slate-200 rounded-lg bg-white text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm transition" />
      </div>

      {isLoading && <div className="flex items-center justify-center h-40"><div className="animate-spin rounded-full h-8 w-8 border-2 border-indigo-200 border-t-indigo-600" /></div>}

      {!isLoading && filtered.length === 0 ? (
        <EmptyState variant={searchInput ? 'no-results' : 'empty'} title="Sin motivos" />
      ) : !isLoading && (
        <div className="bg-white rounded-xl border border-slate-200 overflow-hidden">
          <table className="min-w-full divide-y divide-slate-200">
            <thead className="bg-slate-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">ID</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Nombre</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Categoría</th>
                <th className="px-6 py-3 text-center text-xs font-medium text-slate-500 uppercase tracking-wider">Estado</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-slate-500 uppercase tracking-wider">Acciones</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200">
              {filtered.map((m) => (
                <tr key={m.id_Motivo} className={`hover:bg-slate-50 transition ${!m.activo ? 'opacity-50' : ''}`}>
                  <td className="px-6 py-3 text-sm font-medium text-slate-900">#{m.id_Motivo}</td>
                  <td className="px-6 py-3 text-sm text-slate-900 font-medium">{m.nombre}</td>
                  <td className="px-6 py-3 text-sm text-slate-600">{m.categoria || '—'}</td>
                  <td className="px-6 py-3 text-center">
                    <ToggleSwitch activo={m.activo} onClick={() => setToggleTarget(m)} />
                  </td>
                  <td className="px-6 py-3 text-right">
                    <button onClick={() => setEditTarget(m)} className="p-2 text-slate-400 hover:text-indigo-600 hover:bg-indigo-50 rounded-lg transition" title="Editar">
                      <Pencil className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      <ConfirmActionModal
        open={!!toggleTarget}
        variant={toggleTarget?.activo ? 'danger' : 'info'}
        Icon={AlertTriangle}
        title={toggleTarget?.activo ? '¿Desactivar este motivo?' : '¿Reactivar este motivo?'}
        description={toggleTarget?.nombre}
        confirmText={toggleTarget?.activo ? 'Sí, desactivar' : 'Sí, reactivar'}
        isPending={toggleMutation.isPending}
        onConfirm={() => toggleTarget && toggleMutation.mutate(toggleTarget)}
        onClose={() => setToggleTarget(null)}
      />

      <EditModal
        open={!!editTarget}
        title="Editar Motivo"
        fields={[
          { id: 'nombre', label: 'Nombre', value: editForm.nombre, required: true, placeholder: 'Nombre del motivo' },
          { id: 'descripcion', label: 'Descripción', value: editForm.descripcion, placeholder: 'Descripción opcional' },
          { id: 'categoria', label: 'Categoría', value: editForm.categoria, placeholder: 'Categoría opcional' },
        ]}
        onChange={(id, val) => setEditForm((f) => ({ ...f, [id]: val }))}
        onSubmit={() => editTarget && editMutation.mutate({ id: editTarget.id_Motivo, dto: editForm })}
        onClose={() => setEditTarget(null)}
        isPending={editMutation.isPending}
      />
    </div>
  );
}

// Página principal
export default function ConfiguracionPage() {
  const [activeTab, setActiveTab] = useState<TabId>('departamentos');

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex items-center gap-3">
        <div className="p-2 bg-slate-100 rounded-lg">
          <Settings className="w-6 h-6 text-slate-600" />
        </div>
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Configuración</h1>
          <p className="text-sm text-slate-500">Gestión de departamentos, estados, prioridades, motivos y seguridad</p>
        </div>
      </div>

      {/* Tabs */}
      <div className="border-b border-slate-200">
        <nav className="flex gap-1" aria-label="Tabs">
          {TABS.map((tab) => {
            const isActive = activeTab === tab.id;
            const Icon = tab.icon;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`flex items-center gap-2 px-4 py-2.5 text-sm font-medium border-b-2 transition ${
                  isActive
                    ? 'border-indigo-500 text-indigo-600'
                    : 'border-transparent text-slate-500 hover:text-slate-700 hover:border-slate-300'
                }`}
              >
                <Icon className="w-4 h-4" />
                {tab.label}
              </button>
            );
          })}
        </nav>
      </div>

      {/* Tab content */}
      <div>
        {activeTab === 'departamentos' && <DepartamentosTab />}
        {activeTab === 'estados' && <EstadosTab />}
        {activeTab === 'prioridades' && <PrioridadesTab />}
        {activeTab === 'motivos' && <MotivosTab />}
        {activeTab === 'seguridad' && <SeguridadTab />}
      </div>
    </div>
  );
}
