import { useState, useEffect } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { apiClient } from '../services/api.service';
import { API_ENDPOINTS } from '../config/api';
import type {
  ApiResponse,
  RolListDTO,
  PermisoListDTO,
  UsuarioDTO,
} from '../types/api.types';
import { sileo } from 'sileo';
import ErrorAlert from '../components/ui/ErrorAlert';
import EmptyState from '../components/ui/EmptyState';
import ConfirmActionModal from '../components/ui/ConfirmActionModal';
import {
  Shield,
  ShieldCheck,
  Key,
  Users,
  Pencil,
  Trash2,
  Plus,
  X,
  Search,
  AlertTriangle,
  Check,
  ChevronDown,
} from 'lucide-react';

// Sub-sección: Gestión de Roles
function RolesSection() {
  const queryClient = useQueryClient();
  const [searchInput, setSearchInput] = useState('');
  const [deleteTarget, setDeleteTarget] = useState<RolListDTO | null>(null);
  const [editRol, setEditRol] = useState<RolListDTO | null>(null);
  const [rolName, setRolName] = useState('');
  const [showCreateForm, setShowCreateForm] = useState(false);
  const [newRolName, setNewRolName] = useState('');

  // Modal de permisos
  const [permisosRol, setPermisosRol] = useState<RolListDTO | null>(null);
  const [selectedPermisos, setSelectedPermisos] = useState<Set<number>>(new Set());

  useEffect(() => {
    if (editRol) setRolName(editRol.nombre);
  }, [editRol]);

  const { data: roles, isLoading, isError, error, refetch } = useQuery({
    queryKey: ['rbac-roles'],
    queryFn: async () => {
      const res = await apiClient.get<ApiResponse<RolListDTO[]>>(API_ENDPOINTS.ROLES);
      return res.data.datos ?? [];
    },
  });

  const { data: allPermisos, isLoading: loadingAllPermisos } = useQuery({
    queryKey: ['rbac-permisos-all'],
    queryFn: async () => {
      const res = await apiClient.get<ApiResponse<PermisoListDTO[]>>(API_ENDPOINTS.PERMISOS);
      return res.data.datos ?? [];
    },
  });

  // Fetch permisos del rol seleccionado
  const { data: rolPermisos, isLoading: loadingRolPermisos, isError: errorRolPermisos } = useQuery({
    queryKey: ['rbac-rol-permisos', permisosRol?.idRol],
    queryFn: async () => {
      if (!permisosRol) return [];
      const res = await apiClient.get<ApiResponse<PermisoListDTO[]>>(API_ENDPOINTS.ROLES_PERMISOS(permisosRol.idRol));
      return res.data.datos ?? [];
    },
    enabled: !!permisosRol,
  });

  // Condición combinada: el modal muestra spinner si CUALQUIER query aún carga
  const modalLoading = loadingRolPermisos || loadingAllPermisos;

  useEffect(() => {
    if (rolPermisos) {
      setSelectedPermisos(new Set(rolPermisos.map(p => p.idPermiso)));
    }
  }, [rolPermisos]);

  const createMutation = useMutation({
    mutationFn: (nombre: string) => apiClient.post(API_ENDPOINTS.ROLES, { nombre }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['rbac-roles'] });
      sileo.success({ description: 'Rol creado exitosamente' });
      setShowCreateForm(false);
      setNewRolName('');
    },
    onError: (err: any) => sileo.error({ description: err?.response?.data?.mensaje || 'Error al crear rol' }),
  });

  const updateMutation = useMutation({
    mutationFn: (data: { id: number; nombre: string }) =>
      apiClient.put(API_ENDPOINTS.ROLES_BY_ID(data.id), { nombre: data.nombre }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['rbac-roles'] });
      sileo.success({ description: 'Rol actualizado' });
      setEditRol(null);
    },
    onError: (err: any) => sileo.error({ description: err?.response?.data?.mensaje || 'Error al actualizar' }),
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => apiClient.delete(API_ENDPOINTS.ROLES_BY_ID(id)),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['rbac-roles'] });
      sileo.success({ description: 'Rol eliminado' });
      setDeleteTarget(null);
    },
    onError: (err: any) => {
      sileo.error({ description: err?.response?.data?.mensaje || 'Error al eliminar rol' });
      setDeleteTarget(null);
    },
  });

  const syncPermisosMutation = useMutation({
    mutationFn: (data: { idRol: number; permisoIds: number[] }) =>
      apiClient.post(API_ENDPOINTS.ROLES_PERMISOS(data.idRol), { permisoIds: data.permisoIds }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['rbac-roles'] });
      queryClient.invalidateQueries({ queryKey: ['rbac-rol-permisos'] });
      sileo.success({ description: 'Permisos actualizados' });
      setPermisosRol(null);
    },
    onError: (err: any) => sileo.error({ description: err?.response?.data?.mensaje || 'Error al sincronizar permisos' }),
  });

  const isProtected = (rol: RolListDTO) => rol.idRol === 10; // Administrador

  if (isError) return <ErrorAlert title="Error" message={(error as any)?.response?.data?.mensaje || 'Error al cargar roles.'} onRetry={() => refetch()} />;

  const filtered = roles?.filter(r => !searchInput || r.nombre.toLowerCase().includes(searchInput.toLowerCase())) ?? [];

  const togglePermiso = (idPermiso: number) => {
    setSelectedPermisos(prev => {
      const next = new Set(prev);
      if (next.has(idPermiso)) next.delete(idPermiso);
      else next.add(idPermiso);
      return next;
    });
  };

  return (
    <div className="space-y-4">
      {/* Header con búsqueda y botón crear */}
      <div className="flex items-center justify-between gap-4">
        <div className="relative max-w-sm flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 w-4 h-4" />
          <input type="text" placeholder="Buscar roles…" value={searchInput} onChange={(e) => setSearchInput(e.target.value)}
            className="w-full pl-9 pr-4 py-2 border border-slate-200 rounded-lg bg-white text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm transition" />
        </div>
        <button
          onClick={() => setShowCreateForm(true)}
          className="flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-indigo-600 rounded-lg hover:bg-indigo-700 transition shadow-sm"
        >
          <Plus className="w-4 h-4" /> Nuevo Rol
        </button>
      </div>

      {/* Formulario crear (inline) */}
      {showCreateForm && (
        <div className="bg-indigo-50 border border-indigo-200 rounded-xl p-4">
          <form onSubmit={(e) => { e.preventDefault(); if (newRolName.trim()) createMutation.mutate(newRolName.trim()); }} className="flex items-end gap-3">
            <div className="flex-1">
              <label className="block text-sm font-medium text-slate-700 mb-1">Nombre del rol</label>
              <input
                autoFocus
                value={newRolName}
                onChange={(e) => setNewRolName(e.target.value)}
                className="w-full px-3 py-2 border border-slate-200 rounded-lg bg-white text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm"
                placeholder="Ej: Auditor"
                required
              />
            </div>
            <button type="submit" disabled={createMutation.isPending} className="px-4 py-2 text-sm font-medium text-white bg-indigo-600 rounded-lg hover:bg-indigo-700 disabled:opacity-50 transition">
              {createMutation.isPending ? 'Creando…' : 'Crear'}
            </button>
            <button type="button" onClick={() => { setShowCreateForm(false); setNewRolName(''); }} className="px-4 py-2 text-sm font-medium text-slate-600 border border-slate-200 rounded-lg hover:bg-slate-50 transition">
              Cancelar
            </button>
          </form>
        </div>
      )}

      {isLoading && <div className="flex items-center justify-center h-40"><div className="animate-spin rounded-full h-8 w-8 border-2 border-indigo-200 border-t-indigo-600" /></div>}

      {!isLoading && filtered.length === 0 ? (
        <EmptyState variant={searchInput ? 'no-results' : 'empty'} title="Sin roles" />
      ) : !isLoading && (
        <div className="bg-white rounded-xl border border-slate-200 overflow-hidden">
          <table className="min-w-full divide-y divide-slate-200">
            <thead className="bg-slate-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">ID</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Nombre</th>
                <th className="px-6 py-3 text-center text-xs font-medium text-slate-500 uppercase tracking-wider">Permisos</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-slate-500 uppercase tracking-wider">Acciones</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200">
              {filtered.map((r) => (
                <tr key={r.idRol} className="hover:bg-slate-50 transition">
                  <td className="px-6 py-3 text-sm font-medium text-slate-900">#{r.idRol}</td>
                  <td className="px-6 py-3 text-sm text-slate-900 font-medium">
                    {r.nombre}
                    {isProtected(r) && (
                      <span className="ml-2 text-xs bg-amber-100 text-amber-700 px-1.5 py-0.5 rounded-full font-normal">Protegido</span>
                    )}
                  </td>
                  <td className="px-6 py-3 text-center">
                    <span className="inline-flex items-center gap-1 px-2.5 py-1 text-xs font-medium rounded-full bg-indigo-100 text-indigo-700">
                      <Key className="w-3 h-3" /> {r.totalPermisos}
                    </span>
                  </td>
                  <td className="px-6 py-3 text-right">
                    <div className="flex items-center justify-end gap-1">
                      <button
                        onClick={() => setPermisosRol(r)}
                        className="p-2 text-slate-400 hover:text-indigo-600 hover:bg-indigo-50 rounded-lg transition"
                        title="Editar Permisos"
                      >
                        <ShieldCheck className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => setEditRol(r)}
                        className="p-2 text-slate-400 hover:text-indigo-600 hover:bg-indigo-50 rounded-lg transition"
                        title="Editar Nombre"
                      >
                        <Pencil className="w-4 h-4" />
                      </button>
                      {!isProtected(r) && (
                        <button
                          onClick={() => setDeleteTarget(r)}
                          className="p-2 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition"
                          title="Eliminar"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Modal editar nombre de rol */}
      {editRol && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md mx-4 overflow-hidden">
            <div className="flex items-center justify-between px-6 py-4 border-b border-slate-200">
              <h3 className="text-lg font-semibold text-slate-900">Editar Rol</h3>
              <button onClick={() => setEditRol(null)} className="p-1 text-slate-400 hover:text-slate-600 rounded-lg hover:bg-slate-100 transition">
                <X className="w-5 h-5" />
              </button>
            </div>
            <form onSubmit={(e) => { e.preventDefault(); if (rolName.trim()) updateMutation.mutate({ id: editRol.idRol, nombre: rolName.trim() }); }} className="p-6 space-y-4">
              <div>
                <label className="block text-sm font-medium text-slate-700 mb-1">Nombre del Rol *</label>
                <input
                  autoFocus
                  required
                  value={rolName}
                  onChange={(e) => setRolName(e.target.value)}
                  className="w-full px-3 py-2.5 border border-slate-200 rounded-lg bg-white text-slate-900 focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm transition"
                />
              </div>
              <div className="flex items-center justify-end gap-3 pt-4 border-t border-slate-100">
                <button type="button" onClick={() => setEditRol(null)} className="px-4 py-2.5 text-sm font-medium text-slate-700 border border-slate-200 rounded-lg hover:bg-slate-50 transition">
                  Cancelar
                </button>
                <button type="submit" disabled={updateMutation.isPending} className="px-5 py-2.5 text-sm font-medium text-white bg-indigo-600 rounded-lg hover:bg-indigo-700 disabled:opacity-50 transition shadow-sm">
                  {updateMutation.isPending ? 'Guardando…' : 'Guardar'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal asignar permisos al rol */}
      {permisosRol && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-lg mx-4 overflow-hidden max-h-[85vh] flex flex-col">
            <div className="flex items-center justify-between px-6 py-4 border-b border-slate-200 shrink-0">
              <div>
                <h3 className="text-lg font-semibold text-slate-900">Permisos del Rol</h3>
                <p className="text-sm text-slate-500 mt-0.5">
                  {permisosRol.nombre} — {selectedPermisos.size} seleccionados
                </p>
              </div>
              <button onClick={() => setPermisosRol(null)} className="p-1 text-slate-400 hover:text-slate-600 rounded-lg hover:bg-slate-100 transition">
                <X className="w-5 h-5" />
              </button>
            </div>
            <div className="flex-1 overflow-y-auto p-6">
              {modalLoading ? (
                <div className="flex items-center justify-center h-32">
                  <div className="animate-spin rounded-full h-8 w-8 border-2 border-indigo-200 border-t-indigo-600" />
                </div>
              ) : errorRolPermisos ? (
                <div className="flex flex-col items-center justify-center h-32 text-center">
                  <AlertTriangle className="w-8 h-8 text-red-400 mb-2" />
                  <p className="text-sm text-red-600 font-medium">Error al cargar permisos del rol</p>
                  <button onClick={() => setPermisosRol(null)} className="mt-2 text-sm text-indigo-600 hover:underline">Cerrar e intentar de nuevo</button>
                </div>
              ) : (
                <div className="space-y-2">
                  {allPermisos?.map((p) => (
                    <label
                      key={p.idPermiso}
                      className={`flex items-center gap-3 p-3 rounded-lg border cursor-pointer transition ${
                        selectedPermisos.has(p.idPermiso)
                          ? 'bg-indigo-50 border-indigo-200'
                          : 'bg-white border-slate-200 hover:bg-slate-50'
                      }`}
                    >
                      <div className={`w-5 h-5 rounded border-2 flex items-center justify-center transition shrink-0 ${
                        selectedPermisos.has(p.idPermiso) ? 'bg-indigo-600 border-indigo-600' : 'border-slate-300'
                      }`}>
                        {selectedPermisos.has(p.idPermiso) && <Check className="w-3 h-3 text-white" />}
                      </div>
                      <input
                        type="checkbox"
                        checked={selectedPermisos.has(p.idPermiso)}
                        onChange={() => togglePermiso(p.idPermiso)}
                        className="sr-only"
                      />
                      <div className="min-w-0">
                        <span className="text-sm font-medium text-slate-900 block">{p.codigo}</span>
                        {p.descripcion && <span className="text-xs text-slate-500 block">{p.descripcion}</span>}
                      </div>
                    </label>
                  )) ?? <p className="text-sm text-slate-500">No hay permisos en el catálogo.</p>}
                </div>
              )}
            </div>
            <div className="flex items-center justify-between gap-3 px-6 py-4 border-t border-slate-200 bg-slate-50 shrink-0">
              <button
                type="button"
                onClick={() => {
                  if (allPermisos) {
                    if (selectedPermisos.size === allPermisos.length) {
                      setSelectedPermisos(new Set());
                    } else {
                      setSelectedPermisos(new Set(allPermisos.map(p => p.idPermiso)));
                    }
                  }
                }}
                className="text-sm text-indigo-600 hover:text-indigo-700 font-medium transition"
              >
                {selectedPermisos.size === (allPermisos?.length ?? 0) ? 'Deseleccionar todos' : 'Seleccionar todos'}
              </button>
              <div className="flex gap-3">
                <button type="button" onClick={() => setPermisosRol(null)} className="px-4 py-2.5 text-sm font-medium text-slate-700 border border-slate-200 rounded-lg hover:bg-slate-50 transition">
                  Cancelar
                </button>
                <button
                  onClick={() => syncPermisosMutation.mutate({ idRol: permisosRol.idRol, permisoIds: Array.from(selectedPermisos) })}
                  disabled={syncPermisosMutation.isPending}
                  className="px-5 py-2.5 text-sm font-medium text-white bg-indigo-600 rounded-lg hover:bg-indigo-700 disabled:opacity-50 transition shadow-sm"
                >
                  {syncPermisosMutation.isPending ? 'Guardando…' : 'Guardar Permisos'}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Confirm delete */}
      <ConfirmActionModal
        open={!!deleteTarget}
        variant="danger"
        Icon={AlertTriangle}
        title="¿Eliminar este rol?"
        description={`Se eliminará "${deleteTarget?.nombre}" y todos sus permisos asociados. Los usuarios asignados a este rol quedarán sin rol.`}
        confirmText="Sí, eliminar"
        isPending={deleteMutation.isPending}
        onConfirm={() => deleteTarget && deleteMutation.mutate(deleteTarget.idRol)}
        onClose={() => setDeleteTarget(null)}
      />
    </div>
  );
}

// Sub-sección: Catálogo de Permisos
function PermisosSection() {
  const queryClient = useQueryClient();
  const [searchInput, setSearchInput] = useState('');
  const [editPermiso, setEditPermiso] = useState<PermisoListDTO | null>(null);
  const [editForm, setEditForm] = useState({ codigo: '', descripcion: '' });
  const [showCreateForm, setShowCreateForm] = useState(false);
  const [newForm, setNewForm] = useState({ codigo: '', descripcion: '' });

  useEffect(() => {
    if (editPermiso) setEditForm({ codigo: editPermiso.codigo, descripcion: editPermiso.descripcion ?? '' });
  }, [editPermiso]);

  const { data: permisos, isLoading, isError, error, refetch } = useQuery({
    queryKey: ['rbac-permisos-all'],
    queryFn: async () => {
      const res = await apiClient.get<ApiResponse<PermisoListDTO[]>>(API_ENDPOINTS.PERMISOS);
      return res.data.datos ?? [];
    },
  });

  const createMutation = useMutation({
    mutationFn: (dto: { codigo: string; descripcion: string }) => apiClient.post(API_ENDPOINTS.PERMISOS, dto),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['rbac-permisos-all'] });
      sileo.success({ description: 'Permiso creado exitosamente' });
      setShowCreateForm(false);
      setNewForm({ codigo: '', descripcion: '' });
    },
    onError: (err: any) => sileo.error({ description: err?.response?.data?.mensaje || 'Error al crear permiso' }),
  });

  const updateMutation = useMutation({
    mutationFn: (data: { id: number; dto: { codigo: string; descripcion: string } }) =>
      apiClient.put(API_ENDPOINTS.PERMISOS_BY_ID(data.id), data.dto),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['rbac-permisos-all'] });
      sileo.success({ description: 'Permiso actualizado' });
      setEditPermiso(null);
    },
    onError: (err: any) => sileo.error({ description: err?.response?.data?.mensaje || 'Error al actualizar' }),
  });

  if (isError) return <ErrorAlert title="Error" message={(error as any)?.response?.data?.mensaje || 'Error al cargar permisos.'} onRetry={() => refetch()} />;

  const filtered = permisos?.filter(p => {
    if (!searchInput) return true;
    const q = searchInput.toLowerCase();
    return p.codigo.toLowerCase().includes(q) || p.descripcion?.toLowerCase().includes(q);
  }) ?? [];

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between gap-4">
        <div className="relative max-w-sm flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 w-4 h-4" />
          <input type="text" placeholder="Buscar permisos…" value={searchInput} onChange={(e) => setSearchInput(e.target.value)}
            className="w-full pl-9 pr-4 py-2 border border-slate-200 rounded-lg bg-white text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm transition" />
        </div>
        <button
          onClick={() => setShowCreateForm(true)}
          className="flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-indigo-600 rounded-lg hover:bg-indigo-700 transition shadow-sm"
        >
          <Plus className="w-4 h-4" /> Nuevo Permiso
        </button>
      </div>

      {showCreateForm && (
        <div className="bg-indigo-50 border border-indigo-200 rounded-xl p-4">
          <form onSubmit={(e) => { e.preventDefault(); if (newForm.codigo.trim()) createMutation.mutate({ codigo: newForm.codigo.trim(), descripcion: newForm.descripcion.trim() }); }} className="flex items-end gap-3 flex-wrap">
            <div className="flex-1 min-w-[200px]">
              <label className="block text-sm font-medium text-slate-700 mb-1">Código</label>
              <input autoFocus value={newForm.codigo} onChange={(e) => setNewForm(f => ({ ...f, codigo: e.target.value.toUpperCase() }))}
                className="w-full px-3 py-2 border border-slate-200 rounded-lg bg-white text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm"
                placeholder="Ej: TKT_ARCHIVE" required />
            </div>
            <div className="flex-1 min-w-[200px]">
              <label className="block text-sm font-medium text-slate-700 mb-1">Descripción</label>
              <input value={newForm.descripcion} onChange={(e) => setNewForm(f => ({ ...f, descripcion: e.target.value }))}
                className="w-full px-3 py-2 border border-slate-200 rounded-lg bg-white text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm"
                placeholder="Descripción del permiso" />
            </div>
            <button type="submit" disabled={createMutation.isPending} className="px-4 py-2 text-sm font-medium text-white bg-indigo-600 rounded-lg hover:bg-indigo-700 disabled:opacity-50 transition">
              {createMutation.isPending ? 'Creando…' : 'Crear'}
            </button>
            <button type="button" onClick={() => { setShowCreateForm(false); setNewForm({ codigo: '', descripcion: '' }); }} className="px-4 py-2 text-sm font-medium text-slate-600 border border-slate-200 rounded-lg hover:bg-slate-50 transition">
              Cancelar
            </button>
          </form>
        </div>
      )}

      {isLoading && <div className="flex items-center justify-center h-40"><div className="animate-spin rounded-full h-8 w-8 border-2 border-indigo-200 border-t-indigo-600" /></div>}

      {!isLoading && filtered.length === 0 ? (
        <EmptyState variant={searchInput ? 'no-results' : 'empty'} title="Sin permisos" />
      ) : !isLoading && (
        <div className="bg-white rounded-xl border border-slate-200 overflow-hidden">
          <table className="min-w-full divide-y divide-slate-200">
            <thead className="bg-slate-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">ID</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Código</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Descripción</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-slate-500 uppercase tracking-wider">Acciones</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200">
              {filtered.map((p) => (
                <tr key={p.idPermiso} className="hover:bg-slate-50 transition">
                  <td className="px-6 py-3 text-sm font-medium text-slate-900">#{p.idPermiso}</td>
                  <td className="px-6 py-3 text-sm">
                    <code className="px-2 py-0.5 bg-slate-100 text-slate-800 rounded text-xs font-mono">{p.codigo}</code>
                  </td>
                  <td className="px-6 py-3 text-sm text-slate-600">{p.descripcion || '—'}</td>
                  <td className="px-6 py-3 text-right">
                    <button onClick={() => setEditPermiso(p)} className="p-2 text-slate-400 hover:text-indigo-600 hover:bg-indigo-50 rounded-lg transition" title="Editar">
                      <Pencil className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Modal editar permiso */}
      {editPermiso && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md mx-4 overflow-hidden">
            <div className="flex items-center justify-between px-6 py-4 border-b border-slate-200">
              <h3 className="text-lg font-semibold text-slate-900">Editar Permiso</h3>
              <button onClick={() => setEditPermiso(null)} className="p-1 text-slate-400 hover:text-slate-600 rounded-lg hover:bg-slate-100 transition">
                <X className="w-5 h-5" />
              </button>
            </div>
            <form onSubmit={(e) => { e.preventDefault(); updateMutation.mutate({ id: editPermiso.idPermiso, dto: editForm }); }} className="p-6 space-y-4">
              <div>
                <label className="block text-sm font-medium text-slate-700 mb-1">Código *</label>
                <input required value={editForm.codigo} onChange={(e) => setEditForm(f => ({ ...f, codigo: e.target.value.toUpperCase() }))}
                  className="w-full px-3 py-2.5 border border-slate-200 rounded-lg bg-white text-slate-900 focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm transition" />
              </div>
              <div>
                <label className="block text-sm font-medium text-slate-700 mb-1">Descripción</label>
                <input value={editForm.descripcion} onChange={(e) => setEditForm(f => ({ ...f, descripcion: e.target.value }))}
                  className="w-full px-3 py-2.5 border border-slate-200 rounded-lg bg-white text-slate-900 focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm transition"
                  placeholder="Descripción opcional" />
              </div>
              <div className="flex items-center justify-end gap-3 pt-4 border-t border-slate-100">
                <button type="button" onClick={() => setEditPermiso(null)} className="px-4 py-2.5 text-sm font-medium text-slate-700 border border-slate-200 rounded-lg hover:bg-slate-50 transition">
                  Cancelar
                </button>
                <button type="submit" disabled={updateMutation.isPending} className="px-5 py-2.5 text-sm font-medium text-white bg-indigo-600 rounded-lg hover:bg-indigo-700 disabled:opacity-50 transition shadow-sm">
                  {updateMutation.isPending ? 'Guardando…' : 'Guardar'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}

// Sub-sección: Asignación de Roles a Usuarios
function UsuarioRolesSection() {
  const queryClient = useQueryClient();
  const [searchInput, setSearchInput] = useState('');

  const { data: usuarios, isLoading: loadingUsuarios, isError, error, refetch } = useQuery({
    queryKey: ['rbac-usuarios'],
    queryFn: async () => {
      const res = await apiClient.get<ApiResponse<UsuarioDTO[]>>(API_ENDPOINTS.USUARIOS);
      return res.data.datos ?? [];
    },
  });

  const { data: roles } = useQuery({
    queryKey: ['rbac-roles'],
    queryFn: async () => {
      const res = await apiClient.get<ApiResponse<RolListDTO[]>>(API_ENDPOINTS.ROLES);
      return res.data.datos ?? [];
    },
  });

  const assignMutation = useMutation({
    mutationFn: (data: { idUsuario: number; idRol: number }) =>
      apiClient.post(API_ENDPOINTS.ROLES_ASIGNAR_USUARIO(data.idUsuario), { idRol: data.idRol }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['rbac-usuarios'] });
      sileo.success({ description: 'Rol asignado exitosamente' });
    },
    onError: (err: any) => sileo.error({ description: err?.response?.data?.mensaje || 'Error al asignar rol' }),
  });

  if (isError) return <ErrorAlert title="Error" message={(error as any)?.response?.data?.mensaje || 'Error al cargar usuarios.'} onRetry={() => refetch()} />;

  const filtered = usuarios?.filter(u => {
    if (!searchInput) return true;
    const q = searchInput.toLowerCase();
    return u.nombre?.toLowerCase().includes(q) || u.email?.toLowerCase().includes(q) || u.apellido?.toLowerCase().includes(q);
  }) ?? [];

  return (
    <div className="space-y-4">
      <div className="relative max-w-sm">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 w-4 h-4" />
        <input type="text" placeholder="Buscar usuarios…" value={searchInput} onChange={(e) => setSearchInput(e.target.value)}
          className="w-full pl-9 pr-4 py-2 border border-slate-200 rounded-lg bg-white text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm transition" />
      </div>

      {loadingUsuarios && <div className="flex items-center justify-center h-40"><div className="animate-spin rounded-full h-8 w-8 border-2 border-indigo-200 border-t-indigo-600" /></div>}

      {!loadingUsuarios && filtered.length === 0 ? (
        <EmptyState variant={searchInput ? 'no-results' : 'empty'} title="Sin usuarios" />
      ) : !loadingUsuarios && (
        <div className="bg-white rounded-xl border border-slate-200 overflow-hidden">
          <table className="min-w-full divide-y divide-slate-200">
            <thead className="bg-slate-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Usuario</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Email</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Rol Actual</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Cambiar Rol</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200">
              {filtered.map((u) => (
                <tr key={u.id_Usuario} className={`hover:bg-slate-50 transition ${!u.activo ? 'opacity-50' : ''}`}>
                  <td className="px-6 py-3 text-sm font-medium text-slate-900">
                    {u.nombre} {u.apellido}
                    {!u.activo && <span className="ml-2 text-xs bg-slate-100 text-slate-500 px-1.5 py-0.5 rounded-full">Inactivo</span>}
                  </td>
                  <td className="px-6 py-3 text-sm text-slate-600">{u.email}</td>
                  <td className="px-6 py-3 text-sm">
                    {u.rol ? (
                      <span className="inline-flex items-center gap-1 px-2.5 py-1 text-xs font-medium rounded-full bg-indigo-100 text-indigo-700">
                        <Shield className="w-3 h-3" /> {u.rol.nombre_Rol}
                      </span>
                    ) : (
                      <span className="text-slate-400 text-xs">Sin rol</span>
                    )}
                  </td>
                  <td className="px-6 py-3">
                    <div className="relative max-w-[180px]">
                      <select
                        value={u.id_Rol || ''}
                        onChange={(e) => {
                          const newRolId = Number(e.target.value);
                          if (newRolId && newRolId !== u.id_Rol) {
                            assignMutation.mutate({ idUsuario: u.id_Usuario, idRol: newRolId });
                          }
                        }}
                        disabled={assignMutation.isPending}
                        className="w-full appearance-none pl-3 pr-8 py-1.5 border border-slate-200 rounded-lg bg-white text-slate-900 text-sm focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition cursor-pointer disabled:opacity-50"
                      >
                        <option value="">Seleccionar…</option>
                        {roles?.map((r) => (
                          <option key={r.idRol} value={r.idRol}>{r.nombre}</option>
                        ))}
                      </select>
                      <ChevronDown className="absolute right-2 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400 pointer-events-none" />
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

// Componente Principal: SeguridadTab
type SecuritySection = 'roles' | 'permisos' | 'usuarios';

const SECURITY_SECTIONS: { id: SecuritySection; label: string; icon: typeof Shield; description: string }[] = [
  { id: 'roles', label: 'Roles', icon: Shield, description: 'Gestionar roles y sus permisos asociados' },
  { id: 'permisos', label: 'Permisos', icon: Key, description: 'Catálogo de permisos del sistema' },
  { id: 'usuarios', label: 'Usuarios', icon: Users, description: 'Asignar roles a usuarios' },
];

export default function SeguridadTab() {
  const [activeSection, setActiveSection] = useState<SecuritySection>('roles');

  return (
    <div className="space-y-5">
      {/* Sub-navigation cards */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
        {SECURITY_SECTIONS.map((section) => {
          const isActive = activeSection === section.id;
          const Icon = section.icon;
          return (
            <button
              key={section.id}
              onClick={() => setActiveSection(section.id)}
              className={`flex items-start gap-3 p-4 rounded-xl border-2 text-left transition ${
                isActive
                  ? 'border-indigo-500 bg-indigo-50 shadow-sm'
                  : 'border-slate-200 bg-white hover:border-slate-300 hover:bg-slate-50'
              }`}
            >
              <div className={`p-2 rounded-lg shrink-0 ${isActive ? 'bg-indigo-100' : 'bg-slate-100'}`}>
                <Icon className={`w-5 h-5 ${isActive ? 'text-indigo-600' : 'text-slate-500'}`} />
              </div>
              <div className="min-w-0">
                <span className={`text-sm font-semibold block ${isActive ? 'text-indigo-700' : 'text-slate-900'}`}>
                  {section.label}
                </span>
                <span className="text-xs text-slate-500 block mt-0.5">{section.description}</span>
              </div>
            </button>
          );
        })}
      </div>

      {/* Section content */}
      <div>
        {activeSection === 'roles' && <RolesSection />}
        {activeSection === 'permisos' && <PermisosSection />}
        {activeSection === 'usuarios' && <UsuarioRolesSection />}
      </div>
    </div>
  );
}
