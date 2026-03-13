import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { apiClient } from '../services/api.service';
import { API_ENDPOINTS } from '../config/api';
import {
  ApiResponse,
  UsuarioDTO,
  RolDTO,
  DepartamentoDTO,
  CreateUpdateUsuarioDTO,
} from '../types/api.types';
import { sileo } from 'sileo';
import ErrorAlert from '../components/ui/ErrorAlert';
import UserAvatar from '../components/ui/UserAvatar';
import EmptyState from '../components/ui/EmptyState';
import ConfirmActionModal from '../components/ui/ConfirmActionModal';
import {
  Users,
  Plus,
  Pencil,
  UserX,
  UserCheck,
  X,
  Search,
  Shield,
  Mail,
  Building2,
  AlertTriangle,
} from 'lucide-react';

// ── Modal de usuario ─────────────────────────────────────────────

interface UserModalProps {
  open: boolean;
  usuario: UsuarioDTO | null;
  onClose: () => void;
}

function UserModal({ open, usuario, onClose }: UserModalProps) {
  const queryClient = useQueryClient();
  const isEditing = !!usuario;

  const [form, setForm] = useState<CreateUpdateUsuarioDTO>({
    nombre: usuario?.nombre ?? '',
    apellido: usuario?.apellido ?? '',
    email: usuario?.email ?? '',
    password: '',
    id_Rol: usuario?.id_Rol ?? 0,
    id_Departamento: usuario?.id_Departamento ?? undefined,
  });

  // Catálogos
  const { data: roles, isLoading: isLoadingRoles } = useQuery({
    queryKey: ['catalogo', 'roles'],
    queryFn: async () => {
      const res = await apiClient.get<ApiResponse<RolDTO[]>>('/References/Roles');
      return res.data.datos ?? [];
    },
    staleTime: 1000 * 60 * 30,
  });

  const { data: departamentos, isLoading: isLoadingDepts } = useQuery({
    queryKey: ['catalogo', 'departamentos'],
    queryFn: async () => {
      const res = await apiClient.get<ApiResponse<DepartamentoDTO[]>>(API_ENDPOINTS.DEPARTAMENTOS);
      return res.data.datos ?? [];
    },
    staleTime: 1000 * 60 * 30,
  });

  const catalogsLoading = isLoadingRoles || isLoadingDepts;

  const mutation = useMutation({
    mutationFn: async (data: CreateUpdateUsuarioDTO) => {
      if (isEditing) {
        return apiClient.put(API_ENDPOINTS.USUARIOS_BY_ID(usuario!.id_Usuario), data);
      }
      return apiClient.post(API_ENDPOINTS.USUARIOS, data);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['usuarios'] });
      sileo.success({ description: isEditing ? 'Usuario actualizado' : 'Usuario creado' });
      onClose();
    },
    onError: (err: any) => {
      sileo.error({ description: err?.response?.data?.mensaje || 'Error al guardar usuario' });
    },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const payload: CreateUpdateUsuarioDTO = {
      ...form,
      usuario_Correo: form.email,
    };
    // No enviar password vacío al editar
    if (isEditing && !payload.password) {
      delete (payload as any).password;
    }
    mutation.mutate(payload);
  };

  const set = (field: keyof CreateUpdateUsuarioDTO, value: unknown) =>
    setForm((prev) => ({ ...prev, [field]: value }));

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-lg mx-4 overflow-hidden">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-200">
          <h3 className="text-lg font-semibold text-slate-900">
            {isEditing ? 'Editar Usuario' : 'Nuevo Usuario'}
          </h3>
          <button onClick={onClose} className="p-1 text-slate-400 hover:text-slate-600 rounded-lg hover:bg-slate-100 transition">
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Form */}
        {catalogsLoading ? (
          <div className="flex items-center justify-center h-48">
            <div className="animate-spin rounded-full h-8 w-8 border-2 border-indigo-200 border-t-indigo-600" />
          </div>
        ) : (
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          <div className="grid grid-cols-2 gap-4">
            {/* Nombre */}
            <div>
              <label htmlFor="nombre" className="block text-sm font-medium text-slate-700 mb-1">Nombre *</label>
              <input
                id="nombre"
                required
                value={form.nombre}
                onChange={(e) => set('nombre', e.target.value)}
                className="w-full px-3 py-2.5 border border-slate-200 rounded-lg bg-white text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm transition"
                placeholder="Nombre"
              />
            </div>
            {/* Apellido */}
            <div>
              <label htmlFor="apellido" className="block text-sm font-medium text-slate-700 mb-1">Apellido</label>
              <input
                id="apellido"
                value={form.apellido}
                onChange={(e) => set('apellido', e.target.value)}
                className="w-full px-3 py-2.5 border border-slate-200 rounded-lg bg-white text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm transition"
                placeholder="Apellido"
              />
            </div>
          </div>

          {/* Email */}
          <div>
            <label htmlFor="email" className="block text-sm font-medium text-slate-700 mb-1">Email *</label>
            <div className="relative">
              <Mail className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 w-4 h-4" />
              <input
                id="email"
                type="email"
                required
                value={form.email}
                onChange={(e) => set('email', e.target.value)}
                className="w-full pl-10 pr-3 py-2.5 border border-slate-200 rounded-lg bg-white text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm transition"
                placeholder="correo@empresa.com"
              />
            </div>
          </div>

          {/* Password */}
          <div>
            <label htmlFor="password" className="block text-sm font-medium text-slate-700 mb-1">
              {isEditing ? 'Nueva Contraseña (dejar vacío para no cambiar)' : 'Contraseña *'}
            </label>
            <input
              id="password"
              type="password"
              required={!isEditing}
              value={form.password}
              onChange={(e) => set('password', e.target.value)}
              className="w-full px-3 py-2.5 border border-slate-200 rounded-lg bg-white text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm transition"
              placeholder="••••••••"
              autoComplete="new-password"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            {/* Rol */}
            <div>
              <label htmlFor="rol" className="block text-sm font-medium text-slate-700 mb-1">Rol *</label>
              <div className="relative">
                <Shield className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 w-4 h-4" />
                <select
                  id="rol"
                  required
                  value={form.id_Rol}
                  onChange={(e) => set('id_Rol', Number(e.target.value))}
                  className="w-full pl-10 pr-8 py-2.5 border border-slate-200 rounded-lg bg-white text-slate-900 focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm appearance-none cursor-pointer transition"
                >
                  <option value={0} disabled>Seleccionar rol</option>
                  {roles?.map((r) => (
                    <option key={r.id_Rol} value={r.id_Rol}>{r.nombre_Rol}</option>
                  ))}
                </select>
                <div className="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2">
                  <svg className="w-4 h-4 text-slate-400" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24"><path d="M6 9l6 6 6-6"/></svg>
                </div>
              </div>
            </div>

            {/* Departamento */}
            <div>
              <label htmlFor="depto" className="block text-sm font-medium text-slate-700 mb-1">Departamento</label>
              <div className="relative">
                <Building2 className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 w-4 h-4" />
                <select
                  id="depto"
                  value={form.id_Departamento ?? ''}
                  onChange={(e) => set('id_Departamento', e.target.value ? Number(e.target.value) : undefined)}
                  className="w-full pl-10 pr-8 py-2.5 border border-slate-200 rounded-lg bg-white text-slate-900 focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm appearance-none cursor-pointer transition"
                >
                  <option value="">Sin departamento</option>
                  {departamentos?.filter((d) => d.activo || d.id_Departamento === usuario?.id_Departamento).map((d) => (
                    <option key={d.id_Departamento} value={d.id_Departamento} disabled={!d.activo}>
                      {d.nombre}{!d.activo ? ' (inactivo)' : ''}
                    </option>
                  ))}
                </select>
                <div className="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2">
                  <svg className="w-4 h-4 text-slate-400" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24"><path d="M6 9l6 6 6-6"/></svg>
                </div>
              </div>
            </div>
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
              {mutation.isPending ? 'Guardando…' : isEditing ? 'Guardar Cambios' : 'Crear Usuario'}
            </button>
          </div>
        </form>
        )}
      </div>
    </div>
  );
}

// ── Página principal ─────────────────────────────────────────────

export default function UsuariosPage() {
  const queryClient = useQueryClient();
  const [modalOpen, setModalOpen] = useState(false);
  const [editingUser, setEditingUser] = useState<UsuarioDTO | null>(null);
  const [searchInput, setSearchInput] = useState('');
  const [deleteTarget, setDeleteTarget] = useState<UsuarioDTO | null>(null);

  const { data: usuarios, isLoading, isError, error, refetch } = useQuery({
    queryKey: ['usuarios'],
    queryFn: async () => {
      const res = await apiClient.get<ApiResponse<UsuarioDTO[]>>(API_ENDPOINTS.USUARIOS);
      return res.data.datos ?? [];
    },
  });

  // Toggle activo/inactivo (soft delete)
  const toggleMutation = useMutation({
    mutationFn: async (user: UsuarioDTO) => {
      // El backend DELETE hace soft delete (toggle activo)
      return apiClient.delete(API_ENDPOINTS.USUARIOS_BY_ID(user.id_Usuario));
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['usuarios'] });
      sileo.success({ description: 'Estado del usuario actualizado' });
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

  const openCreate = () => {
    setEditingUser(null);
    setModalOpen(true);
  };

  const openEdit = (user: UsuarioDTO) => {
    setEditingUser(user);
    setModalOpen(true);
  };

  const closeModal = () => {
    setModalOpen(false);
    setEditingUser(null);
  };

  if (isError) {
    const errMsg = (error as any)?.response?.data?.mensaje || 'Error al cargar usuarios.';
    return <ErrorAlert title="Error" message={errMsg} onRetry={() => refetch()} />;
  }

  // Filtro local por nombre/email
  const filtered = usuarios?.filter((u) => {
    if (!searchInput) return true;
    const q = searchInput.toLowerCase();
    return (
      u.nombre?.toLowerCase().includes(q) ||
      u.apellido?.toLowerCase().includes(q) ||
      u.email?.toLowerCase().includes(q)
    );
  }) ?? [];

  const getRolBadge = (rol?: string) => {
    const r = rol?.toLowerCase() ?? '';
    if (r.includes('admin')) return 'bg-rose-100 text-rose-700 border-rose-200';
    if (r.includes('tecnico') || r.includes('técnico') || r.includes('soporte')) return 'bg-indigo-100 text-indigo-700 border-indigo-200';
    return 'bg-emerald-100 text-emerald-700 border-emerald-200';
  };

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-indigo-100 rounded-lg">
            <Users className="w-6 h-6 text-indigo-600" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-slate-900">Usuarios</h1>
            <p className="text-sm text-slate-500">
              {usuarios ? `${usuarios.length} usuario${usuarios.length !== 1 ? 's' : ''} registrado${usuarios.length !== 1 ? 's' : ''}` : 'Cargando…'}
            </p>
          </div>
        </div>
        <button
          onClick={openCreate}
          className="flex items-center gap-2 bg-indigo-600 text-white px-4 py-2.5 rounded-lg hover:bg-indigo-700 shadow-sm transition text-sm font-medium"
        >
          <Plus className="w-4 h-4" />
          Nuevo Usuario
        </button>
      </div>

      {/* Search */}
      <div className="bg-white rounded-xl border border-slate-200 p-4">
        <div className="relative max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 w-4.5 h-4.5" />
          <input
            type="text"
            placeholder="Buscar por nombre o email…"
            value={searchInput}
            onChange={(e) => setSearchInput(e.target.value)}
            className="w-full pl-10 pr-4 py-2.5 border border-slate-200 rounded-lg bg-white text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm transition"
          />
        </div>
      </div>

      {/* Loading */}
      {isLoading && (
        <div className="flex items-center justify-center h-64">
          <div className="animate-spin rounded-full h-10 w-10 border-2 border-indigo-200 border-t-indigo-600"></div>
        </div>
      )}

      {/* Table */}
      {!isLoading && filtered.length === 0 ? (
        <EmptyState
          variant={searchInput ? 'no-results' : 'empty'}
          title={searchInput ? undefined : 'Sin usuarios'}
          message={searchInput ? undefined : 'No hay usuarios en el sistema.'}
        />
      ) : !isLoading && (
        <div className="bg-white rounded-xl border border-slate-200 overflow-hidden">
          <table className="min-w-full divide-y divide-slate-200">
            <thead className="bg-slate-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Usuario</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Email</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Rol</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Departamento</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wider">Estado</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-slate-500 uppercase tracking-wider">Acciones</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200">
              {filtered.map((user) => (
                <tr key={user.id_Usuario} className="hover:bg-slate-50 transition">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center gap-3">
                      <UserAvatar nombre={user.nombre} rol={user.rol?.nombre_Rol} size="sm" />
                      <div>
                        <p className="text-sm font-medium text-slate-900">{user.nombre} {user.apellido}</p>
                        {user.ultima_Sesion && (
                          <p className="text-xs text-slate-400">Último acceso: {new Date(user.ultima_Sesion).toLocaleDateString()}</p>
                        )}
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 text-sm text-slate-600">{user.email}</td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex items-center gap-1 px-2.5 py-1 text-xs font-medium rounded-full border ${getRolBadge(user.rol?.nombre_Rol)}`}>
                      <Shield className="w-3 h-3" />
                      {user.rol?.nombre_Rol || 'Sin rol'}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-sm text-slate-600">
                    {user.departamento?.nombre || <span className="text-slate-400 italic">Sin departamento</span>}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex items-center px-2.5 py-1 text-xs font-medium rounded-full ${
                      user.activo ? 'bg-emerald-100 text-emerald-700' : 'bg-slate-100 text-slate-500'
                    }`}>
                      {user.activo ? 'Activo' : 'Inactivo'}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right">
                    <div className="flex items-center justify-end gap-1">
                      {user.id_Usuario === 1 ? (
                        <span className="text-xs text-slate-400 italic px-2">Protegido</span>
                      ) : (
                        <>
                          <button
                            onClick={() => openEdit(user)}
                            className="p-2 text-slate-400 hover:text-indigo-600 hover:bg-indigo-50 rounded-lg transition"
                            title="Editar"
                          >
                            <Pencil className="w-4 h-4" />
                          </button>
                          <button
                            onClick={() => setDeleteTarget(user)}
                            className={`p-2 rounded-lg transition ${
                              user.activo
                                ? 'text-slate-400 hover:text-rose-600 hover:bg-rose-50'
                                : 'text-slate-400 hover:text-emerald-600 hover:bg-emerald-50'
                            }`}
                            title={user.activo ? 'Dar de baja' : 'Reactivar'}
                          >
                            {user.activo ? <UserX className="w-4 h-4" /> : <UserCheck className="w-4 h-4" />}
                          </button>
                        </>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Modal confirmación baja/reactivación */}
      <ConfirmActionModal
        open={!!deleteTarget}
        variant={deleteTarget?.activo ? 'danger' : 'success'}
        Icon={deleteTarget?.activo ? AlertTriangle : UserCheck}
        title={deleteTarget?.activo ? '¿Dar de baja a este usuario?' : '¿Reactivar a este usuario?'}
        description={deleteTarget ? `${deleteTarget.nombre} ${deleteTarget.apellido}` : undefined}
        detail={deleteTarget?.email}
        footnote={deleteTarget?.activo ? 'El usuario no podrá acceder al sistema pero sus datos se conservarán.' : undefined}
        confirmText={deleteTarget?.activo ? 'Sí, dar de baja' : 'Sí, reactivar'}
        isPending={toggleMutation.isPending}
        onConfirm={confirmToggle}
        onClose={() => setDeleteTarget(null)}
      />

      {/* Modal crear/editar */}
      <UserModal open={modalOpen} usuario={editingUser} onClose={closeModal} />
    </div>
  );
}
