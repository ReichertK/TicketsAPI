import { Outlet, Link, useNavigate, useLocation } from 'react-router-dom';
import { useAuthStore } from '../../store/authStore';
import { usePermission } from '../../hooks/usePermission';
import {
  LayoutDashboard,
  Ticket,
  Users,
  Building2,
  LogOut,
  Menu,
  X,
  Inbox,
  Layers,
  Settings,
  ScrollText,
  ShieldAlert,
  PanelLeftClose,
  PanelLeftOpen,
  Search,
  HelpCircle,
  type LucideIcon,
} from 'lucide-react';
import { useState, useEffect } from 'react';
import { useSignalR } from '../../hooks/useSignalR';
import { Toaster } from 'sileo';
import 'sileo/styles.css';
import UserAvatar from '../ui/UserAvatar';
import NotificationBadge from './NotificationBadge';
import CommandPalette from './CommandPalette';

interface NavItem {
  name: string;
  href: string;
  icon: LucideIcon;
}

const SIDEBAR_KEY = 'sidebar-collapsed';

function getSavedCollapsed(): boolean {
  try {
    return localStorage.getItem(SIDEBAR_KEY) === 'true';
  } catch {
    return false;
  }
}

export default function Layout() {
  const { user, logout, isAdmin } = useAuthStore();
  const navigate = useNavigate();
  const location = useLocation();

  // Mobile drawer state
  const [drawerOpen, setDrawerOpen] = useState(false);
  // Desktop sidebar collapse state (persisted)
  const [collapsed, setCollapsed] = useState(getSavedCollapsed);
  // Command Palette (Ctrl+K)
  const [paletteOpen, setPaletteOpen] = useState(false);

  // Ctrl+K global shortcut
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
        e.preventDefault();
        setPaletteOpen(prev => !prev);
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, []);

  // Activar SignalR en tiempo real
  useSignalR();

  // Close drawer on route change
  useEffect(() => {
    setDrawerOpen(false);
  }, [location.pathname]);

  const toggleCollapsed = () => {
    setCollapsed((prev) => {
      const next = !prev;
      try { localStorage.setItem(SIDEBAR_KEY, String(next)); } catch { /* noop */ }
      return next;
    });
  };

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  // Menú RBAC
  const admin = isAdmin();
  const canListAll = usePermission('TKT_LIST_ALL');
  const canAccessConfig = usePermission('TKT_RBAC_ADMIN');

  const navigation: NavItem[] = [
    { name: 'Mis Tickets', href: '/tickets', icon: Ticket },
    ...(canListAll
      ? [
          { name: 'Cola de Trabajo', href: '/cola', icon: Inbox },
          { name: 'Todos los Tickets', href: '/todos-tickets', icon: Layers },
        ]
      : []),
    ...(admin
      ? [
          { name: 'Dashboard', href: '/dashboard', icon: LayoutDashboard },
          { name: 'Usuarios', href: '/usuarios', icon: Users },
          { name: 'Departamentos', href: '/departamentos', icon: Building2 },
        ]
      : []),
    ...(canAccessConfig
      ? [{ name: 'Configuración', href: '/configuracion', icon: Settings }]
      : []),
    ...(admin
      ? [
          { name: 'Auditoría', href: '/admin/logs', icon: ScrollText },
          { name: 'Seguimiento', href: '/admin/seguimiento-tickets', icon: ShieldAlert },
        ]
      : []),
  ];

  function isActive(href: string): boolean {
    if (href === '/') return location.pathname === '/';
    return location.pathname.startsWith(href);
  }

  // Sidebar nav items (full / collapsed)
  function renderNavItems(mode: 'full' | 'collapsed', onItemClick?: () => void) {
    return navigation.map((item) => {
      const active = isActive(item.href);
      if (mode === 'collapsed') {
        return (
          <Link
            key={item.name}
            to={item.href}
            onClick={onItemClick}
            title={item.name}
            className={`
              flex items-center justify-center w-10 h-10 mx-auto rounded-lg transition-all duration-200
              ${active
                ? 'bg-indigo-600 text-white shadow-lg shadow-indigo-500/30'
                : 'text-slate-400 hover:bg-slate-800 hover:text-white'}
            `}
          >
            <item.icon className="w-5 h-5" />
          </Link>
        );
      }
      return (
        <Link
          key={item.name}
          to={item.href}
          onClick={onItemClick}
          className={`
            flex items-center gap-3 px-4 py-3 rounded-lg transition-all duration-200 text-sm font-medium
            ${active
              ? 'bg-indigo-600 text-white shadow-lg shadow-indigo-500/30'
              : 'text-slate-300 hover:bg-slate-800 hover:text-white'}
          `}
        >
          <item.icon className={`w-5 h-5 flex-shrink-0 ${active ? 'text-white' : 'text-slate-400'}`} />
          <span className="truncate">{item.name}</span>
        </Link>
      );
    });
  }

  return (
    <div className="min-h-screen bg-slate-50">
      {/* Overlay + Drawer móvil */}
      {drawerOpen && (
        <div
          className="fixed inset-0 z-40 lg:hidden bg-black/50 backdrop-blur-sm"
          onClick={() => setDrawerOpen(false)}
        />
      )}
      <aside
        className={`
          fixed inset-y-0 left-0 z-50 w-64 bg-slate-900 transform transition-transform duration-300 ease-in-out lg:hidden
          ${drawerOpen ? 'translate-x-0' : '-translate-x-full'}
        `}
      >
        <div className="flex items-center justify-between p-4 border-b border-slate-700/50">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-indigo-600 flex items-center justify-center shadow-lg shadow-indigo-500/30">
              <span className="text-white font-bold text-sm">C</span>
            </div>
            <span className="text-xl font-extrabold text-white tracking-tight">Cediac</span>
          </div>
          <button
            onClick={() => setDrawerOpen(false)}
            className="p-1 text-slate-400 hover:text-white rounded-lg hover:bg-slate-800 transition"
          >
            <X className="w-5 h-5" />
          </button>
        </div>
        <nav className="p-3 space-y-1 overflow-y-auto max-h-[calc(100vh-8rem)]">
          {renderNavItems('full', () => setDrawerOpen(false))}
        </nav>
        <div className="absolute bottom-0 left-0 right-0 p-4 border-t border-slate-700/50">
          <div className="flex items-center gap-3">
            <UserAvatar nombre={user?.nombre || ''} rol={user?.rol?.nombre_Rol} size="sm" />
            <div className="flex-1 min-w-0">
              <p className="text-sm font-medium text-white truncate">{user?.nombre}</p>
              <p className="text-xs text-slate-400 truncate">{user?.rol?.nombre_Rol}</p>
            </div>
            <button
              onClick={handleLogout}
              className="p-1.5 text-slate-400 hover:text-rose-400 rounded-lg hover:bg-slate-800 transition"
              title="Cerrar sesión"
            >
              <LogOut className="w-4 h-4" />
            </button>
          </div>
        </div>
      </aside>

      {/* Sidebar desktop (collapsible) */}
      <aside
        className={`hidden lg:fixed lg:inset-y-0 lg:z-30 lg:flex lg:flex-col bg-slate-900 transition-all duration-300 ease-in-out ${collapsed ? 'lg:w-[68px]' : 'lg:w-64'}`}
      >
        {/* Logo + collapse toggle */}
        <div className="flex items-center h-16 px-3 border-b border-slate-700/50">
          {collapsed ? (
            <button
              onClick={toggleCollapsed}
              className="mx-auto p-2 text-slate-400 hover:text-white rounded-lg hover:bg-slate-800 transition"
              title="Expandir sidebar"
            >
              <PanelLeftOpen className="w-5 h-5" />
            </button>
          ) : (
            <>
              <div className="flex items-center gap-2 flex-1 pl-2">
                <div className="w-8 h-8 rounded-lg bg-indigo-600 flex items-center justify-center shadow-lg shadow-indigo-500/30">
                  <span className="text-white font-bold text-sm">C</span>
                </div>
                <span className="text-xl font-extrabold text-white tracking-tight">Cediac</span>
              </div>
              <button
                onClick={toggleCollapsed}
                className="p-2 text-slate-400 hover:text-white rounded-lg hover:bg-slate-800 transition"
                title="Plegar sidebar"
              >
                <PanelLeftClose className="w-5 h-5" />
              </button>
            </>
          )}
        </div>

        <nav className={`flex-1 overflow-y-auto ${collapsed ? 'p-2 space-y-2' : 'p-3 space-y-1'}`}>
          {renderNavItems(collapsed ? 'collapsed' : 'full')}
        </nav>

        <div className="border-t border-slate-700/50 p-3">
          {collapsed ? (
            <div className="flex flex-col items-center gap-2">
              <UserAvatar nombre={user?.nombre || ''} rol={user?.rol?.nombre_Rol} size="sm" />
              <button
                onClick={handleLogout}
                className="p-1.5 text-slate-400 hover:text-rose-400 rounded-lg hover:bg-slate-800 transition"
                title="Cerrar sesión"
              >
                <LogOut className="w-4 h-4" />
              </button>
            </div>
          ) : (
            <div className="flex items-center gap-3">
              <UserAvatar nombre={user?.nombre || ''} rol={user?.rol?.nombre_Rol} size="sm" />
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-white truncate">{user?.nombre}</p>
                <p className="text-xs text-slate-400 truncate">{user?.rol?.nombre_Rol}</p>
              </div>
              <button
                onClick={handleLogout}
                className="p-1.5 text-slate-400 hover:text-rose-400 rounded-lg hover:bg-slate-800 transition"
                title="Cerrar sesión"
              >
                <LogOut className="w-4 h-4" />
              </button>
            </div>
          )}
        </div>
      </aside>

      {/* Main content */}
      <div
        className={`flex flex-col flex-1 min-h-screen transition-all duration-300 ease-in-out ${collapsed ? 'lg:pl-[68px]' : 'lg:pl-64'}`}
      >
        <header className="sticky top-0 z-20 flex items-center h-16 bg-white border-b border-slate-200 px-4 sm:px-6 lg:px-8">
          <button
            onClick={() => setDrawerOpen(true)}
            className="p-2 -ml-2 text-slate-500 hover:text-slate-700 rounded-lg hover:bg-slate-100 lg:hidden transition"
          >
            <Menu className="w-5 h-5" />
          </button>

          <div className="flex-1 flex items-center justify-between ml-2 lg:ml-0">
            <h2 className="text-lg font-semibold text-slate-800">
              Bienvenido, {user?.nombre}
            </h2>

            <div className="flex items-center gap-3">
              {/* Búsqueda global Ctrl+K */}
              <button
                onClick={() => setPaletteOpen(true)}
                className="hidden sm:flex items-center gap-2 px-3 py-1.5 text-sm text-slate-400 bg-slate-100 hover:bg-slate-200 rounded-lg transition border border-slate-200"
                title="Búsqueda global (Ctrl+K)"
              >
                <Search className="w-4 h-4" />
                <span className="hidden md:inline">Buscar…</span>
                <kbd className="hidden md:inline text-[10px] font-mono bg-white border border-slate-300 rounded px-1.5 py-0.5 text-slate-400">Ctrl+K</kbd>
              </button>
              <NotificationBadge />
              <Link
                to="/ayuda"
                className="p-2 text-slate-400 hover:text-indigo-600 hover:bg-slate-100 rounded-lg transition"
                title="Centro de Ayuda"
              >
                <HelpCircle className="w-5 h-5" />
              </Link>
              <div className="hidden sm:flex items-center gap-2">
                <UserAvatar nombre={user?.nombre || ''} rol={user?.rol?.nombre_Rol} size="sm" />
                <span className="text-sm text-slate-500 hidden md:inline">{user?.rol?.nombre_Rol}</span>
              </div>
              <button
                onClick={handleLogout}
                className="flex items-center gap-2 px-3 py-1.5 text-sm text-slate-600 hover:text-rose-600 hover:bg-slate-100 rounded-lg transition"
              >
                <LogOut className="w-4 h-4" />
                <span className="hidden sm:inline">Salir</span>
              </button>
            </div>
          </div>
        </header>

        <main className="flex-1 p-4 sm:p-6 lg:p-8">
          <Outlet />
        </main>
      </div>

      {/* Toast notifications — Sileo */}
      <Toaster position="top-right" theme="system" />

      {/* Command Palette (Ctrl+K) */}
      <CommandPalette isOpen={paletteOpen} onClose={() => setPaletteOpen(false)} />
    </div>
  );
}
