import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { apiClient } from '../services/api.service';
import { API_ENDPOINTS } from '../config/api';
import {
  ApiResponse,
  DepartamentoDTO,
  CreateUpdateDepartamentoDTO,
} from '../types/api.types';
import { sileo } from 'sileo';
import ErrorAlert from '../components/ui/ErrorAlert';
import EmptyState from '../components/ui/EmptyState';
import ConfirmActionModal from '../components/ui/ConfirmActionModal';
import {
  Building2,
  Plus,
  Pencil,
  X,
  Search,
  AlertTriangle,
  Power,
} from 'lucide-react';

// Modal de departamento
interface DeptModalProps {
  open: boolean;
  dept: DepartamentoDTO | null;
  onClose: () => void;
}

function DeptModal({ open, dept, onClose }: DeptModalProps) {
  const queryClient = useQueryClient();
  const isEditing = !!dept;

  const [form, setForm] = useState<CreateUpdateDepartamentoDTO>({
    nombre: dept?.nombre ?? '',
    descripcion: dept?.descripcion ?? '',
  });

  const mutation = useMutation({
    mutationFn: async (data: CreateUpdateDepartamentoDTO) => {
      if (isEditing) {
        return apiClient.put(API_ENDPOINTS.DEPARTAMENTOS_BY_ID(dept!.id_Departamento), data);
      }
      return apiClient.post(API_ENDPOINTS.DEPARTAMENTOS, data);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['departamentos'] });
      queryClient.invalidateQueries({ queryKey: ['catalogo', 'departamentos'] });
      sileo.success({ description: isEditing ? 'Departamento actualizado' : 'Departamento creado' });
      onClose();
    },
    onError: (err: any) => {
      sileo.error({ description: err?.response?.data?.mensaje || 'Error al guardar' });
    },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    mutation.mutate(form);
  };

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md mx-4 overflow-hidden">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-200">
          <h3 className="text-lg font-semibold text-slate-900">
            {isEditing ? 'Editar Departamento' : 'Nuevo Departamento'}
          </h3>
          <button onClick={onClose} className="p-1 text-slate-400 hover:text-slate-600 rounded-lg hover:bg-slate-100 transition">
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          <div>
            <label htmlFor="dept-nombre" className="block text-sm font-medium text-slate-700 mb-1">
              Nombre *
            </label>
            <input
              id="dept-nombre"
              required
              value={form.nombre}
              onChange={(e) => setForm((f) => ({ ...f, nombre: e.target.value }))}
              className="w-full px-3 py-2.5 border border-slate-200 rounded-lg bg-white text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm transition"
              placeholder="Nombre del departamento"
            />
          </div>

          <div>
            <label htmlFor="dept-desc" className="block text-sm font-medium text-slate-700 mb-1">
              Descripción
            </label>
            <textarea
              id="dept-desc"
              rows={3}
              value={form.descripcion ?? ''}
              onChange={(e) => setForm((f) => ({ ...f, descripcion: e.target.value }))}
              className="w-full px-3 py-2.5 border border-slate-200 rounded-lg bg-white text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm resize-none transition"
              placeholder="Descripción opcional"
            />
          </div>

          {/* Actions */}
          <div className="flex items-center justify-end gap-3 pt-4 border-t border-slate-100">
            <button type="button" onClick={onClose} className="px-4 py-2.5 text-sm font-medium text-slate-700 border border-slate-200 rounded-lg hover:bg-slate-50 transition">
              Cancelar
            </button>
            <button
              type="submit"
              disabled={mutation.isPending}
              className="px-5 py-2.5 text-sm font-medium text-white bg-indigo-600 rounded-lg hover:bg-indigo-700 disabled:opacity-50 transition shadow-sm"
            >
              {mutation.isPending ? 'Guardando…' : isEditing ? 'Guardar Cambios' : 'Crear'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

// Página principal
export default function DepartamentosPage() {
  const queryClient = useQueryClient();
  const [modalOpen, setModalOpen] = useState(false);
  const [editingDept, setEditingDept] = useState<DepartamentoDTO | null>(null);
  const [searchInput, setSearchInput] = useState('');
  const [deleteTarget, setDeleteTarget] = useState<DepartamentoDTO | null>(null);

  const { data: departamentos, isLoading, isError, error, refetch } = useQuery({
    queryKey: ['departamentos'],
    queryFn: async () => {
      const res = await apiClient.get<ApiResponse<DepartamentoDTO[]>>(API_ENDPOINTS.DEPARTAMENTOS);
      return res.data.datos ?? [];
    },
  });

  // Delete / toggle
  const toggleMutation = useMutation({
    mutationFn: async (dept: DepartamentoDTO) => {
      return apiClient.delete(API_ENDPOINTS.DEPARTAMENTOS_BY_ID(dept.id_Departamento));
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['departamentos'] });
      queryClient.invalidateQueries({ queryKey: ['catalogo', 'departamentos'] });
      sileo.success({ description: 'Estado del departamento actualizado' });
      setDeleteTarget(null);
    },
    onError: (err: any) => {
      sileo.error({ description: err?.response?.data?.mensaje || 'Error al cambiar estado' });
      setDeleteTarget(null);
    },
  });

  const confirmToggle = () => {
    if (deleteTarget) toggleMutation.mutate(deleteTarget);
  };

  const openCreate = () => { setEditingDept(null); setModalOpen(true); };
  const openEdit = (dept: DepartamentoDTO) => { setEditingDept(dept); setModalOpen(true); };
  const closeModal = () => { setModalOpen(false); setEditingDept(null); };

  if (isError) {
    const errMsg = (error as any)?.response?.data?.mensaje || 'Error al cargar departamentos.';
    return <ErrorAlert title="Error" message={errMsg} onRetry={() => refetch()} />;
  }

  // Filtro local
  const filtered = departamentos?.filter((d) => {
    if (!searchInput) return true;
    return d.nombre?.toLowerCase().includes(searchInput.toLowerCase());
  }) ?? [];

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-purple-100 rounded-lg">
            <Building2 className="w-6 h-6 text-purple-600" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-slate-900">Departamentos</h1>
            <p className="text-sm text-slate-500">
              {departamentos ? `${departamentos.length} departamento${departamentos.length !== 1 ? 's' : ''}` : 'Cargando…'}
            </p>
          </div>
        </div>
        <button
          onClick={openCreate}
          className="flex items-center gap-2 bg-indigo-600 text-white px-4 py-2.5 rounded-lg hover:bg-indigo-700 shadow-sm transition text-sm font-medium"
        >
          <Plus className="w-4 h-4" />
          Nuevo Departamento
        </button>
      </div>

      {/* Search */}
      <div className="bg-white rounded-xl border border-slate-200 p-4">
        <div className="relative max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 w-4.5 h-4.5" />
          <input
            type="text"
            placeholder="Buscar departamentos…"
            value={searchInput}
            onChange={(e) => setSearchInput(e.target.value)}
            className="w-full pl-10 pr-4 py-2.5 border border-slate-200 rounded-lg bg-white text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm transition"
          />
        </div>
      </div>

      {/* Loading */}
      {isLoading && (
        <div className="flex items-center justify-center h-64">
          <div className="animate-spin rounded-full h-10 w-10 border-2 border-purple-200 border-t-purple-600"></div>
        </div>
      )}

      {/* Table */}
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
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Estado</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-slate-500 uppercase tracking-wider">Acciones</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200">
              {filtered.map((dept) => (
                <tr key={dept.id_Departamento} className="hover:bg-slate-50 transition">
                  <td className="px-6 py-4 text-sm font-medium text-slate-900 whitespace-nowrap">#{dept.id_Departamento}</td>
                  <td className="px-6 py-4 text-sm text-slate-900 font-medium">{dept.nombre}</td>
                  <td className="px-6 py-4 text-sm text-slate-600 max-w-xs truncate">{dept.descripcion || '—'}</td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <button
                      onClick={() => setDeleteTarget(dept)}
                      className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2 ${
                        dept.activo
                          ? 'bg-emerald-500 focus:ring-emerald-400'
                          : 'bg-slate-300 focus:ring-slate-400'
                      }`}
                      title={dept.activo ? 'Desactivar' : 'Reactivar'}
                    >
                      <span
                        className={`inline-block h-4 w-4 transform rounded-full bg-white shadow-sm transition-transform ${
                          dept.activo ? 'translate-x-6' : 'translate-x-1'
                        }`}
                      />
                    </button>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right">
                    <div className="flex items-center justify-end gap-1">
                      <button
                        onClick={() => openEdit(dept)}
                        className="p-2 text-slate-400 hover:text-indigo-600 hover:bg-indigo-50 rounded-lg transition"
                        title="Editar"
                      >
                        <Pencil className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Modal confirmación desactivar/reactivar */}
      <ConfirmActionModal
        open={!!deleteTarget}
        variant={deleteTarget?.activo ? 'danger' : 'success'}
        Icon={deleteTarget?.activo ? AlertTriangle : Power}
        title={deleteTarget?.activo ? '¿Desactivar este departamento?' : '¿Reactivar este departamento?'}
        description={deleteTarget?.nombre}
        footnote={deleteTarget?.activo ? 'Los tickets y usuarios asociados conservarán su referencia al departamento.' : undefined}
        confirmText={deleteTarget?.activo ? 'Sí, desactivar' : 'Sí, reactivar'}
        isPending={toggleMutation.isPending}
        onConfirm={confirmToggle}
        onClose={() => setDeleteTarget(null)}
      />

      {/* Modal crear/editar */}
      <DeptModal open={modalOpen} dept={editingDept} onClose={closeModal} />
    </div>
  );
}
