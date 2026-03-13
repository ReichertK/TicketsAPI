import { useState, useEffect, useRef, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { apiClient } from '../../services/api.service';
import { API_ENDPOINTS } from '../../config/api';
import { Search, Ticket, User, Building2, X, Loader2 } from 'lucide-react';
import type { ApiResponse, GlobalSearchResult, GlobalSearchItem } from '../../types/api.types';

interface CommandPaletteProps {
  isOpen: boolean;
  onClose: () => void;
}

interface FlatItem extends GlobalSearchItem {
  section: string;
}

export default function CommandPalette({ isOpen, onClose }: CommandPaletteProps) {
  const [query, setQuery] = useState('');
  const [selectedIndex, setSelectedIndex] = useState(0);
  const inputRef = useRef<HTMLInputElement>(null);
  const listRef = useRef<HTMLDivElement>(null);
  const navigate = useNavigate();

  // Búsqueda con debounce
  const [debouncedQuery, setDebouncedQuery] = useState('');
  useEffect(() => {
    const timer = setTimeout(() => setDebouncedQuery(query), 300);
    return () => clearTimeout(timer);
  }, [query]);

  const { data, isLoading } = useQuery({
    queryKey: ['global-search', debouncedQuery],
    queryFn: async () => {
      const { data } = await apiClient.get<ApiResponse<GlobalSearchResult>>(
        API_ENDPOINTS.GLOBAL_SEARCH,
        { params: { q: debouncedQuery, limite: 10 } }
      );
      return data.datos!;
    },
    enabled: isOpen && debouncedQuery.length >= 2,
    staleTime: 30_000,
  });

  // Aplanar resultados en una lista navegable
  const flatItems: FlatItem[] = [];
  if (data) {
    if (data.tickets.length > 0) {
      data.tickets.forEach(t => flatItems.push({ ...t, section: 'Tickets' }));
    }
    if (data.usuarios.length > 0) {
      data.usuarios.forEach(u => flatItems.push({ ...u, section: 'Usuarios' }));
    }
    if (data.departamentos.length > 0) {
      data.departamentos.forEach(d => flatItems.push({ ...d, section: 'Departamentos' }));
    }
  }

  // Reset al abrir/cerrar
  useEffect(() => {
    if (isOpen) {
      setQuery('');
      setDebouncedQuery('');
      setSelectedIndex(0);
      setTimeout(() => inputRef.current?.focus(), 50);
    }
  }, [isOpen]);

  // Reset selectedIndex cuando cambian los resultados
  useEffect(() => {
    setSelectedIndex(0);
  }, [flatItems.length]);

  // Scroll into view
  useEffect(() => {
    const el = listRef.current?.querySelector(`[data-idx="${selectedIndex}"]`);
    el?.scrollIntoView({ block: 'nearest' });
  }, [selectedIndex]);

  // Navegar al seleccionar un item
  const handleSelect = useCallback((item: FlatItem) => {
    onClose();
    if (item.section === 'Tickets') {
      navigate(`/tickets/${item.id}`);
    } else if (item.section === 'Usuarios') {
      navigate(`/usuarios`);
    } else if (item.section === 'Departamentos') {
      navigate(`/departamentos`);
    }
  }, [navigate, onClose]);

  // Keyboard navigation
  const handleKeyDown = useCallback((e: React.KeyboardEvent) => {
    if (e.key === 'ArrowDown') {
      e.preventDefault();
      setSelectedIndex(i => (i + 1) % Math.max(flatItems.length, 1));
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      setSelectedIndex(i => (i - 1 + flatItems.length) % Math.max(flatItems.length, 1));
    } else if (e.key === 'Enter' && flatItems[selectedIndex]) {
      e.preventDefault();
      handleSelect(flatItems[selectedIndex]);
    } else if (e.key === 'Escape') {
      e.preventDefault();
      onClose();
    }
  }, [flatItems, selectedIndex, handleSelect, onClose]);

  if (!isOpen) return null;

  const sectionIcon = (section: string) => {
    switch (section) {
      case 'Tickets': return <Ticket className="w-4 h-4 text-indigo-500" />;
      case 'Usuarios': return <User className="w-4 h-4 text-emerald-500" />;
      case 'Departamentos': return <Building2 className="w-4 h-4 text-amber-500" />;
      default: return <Search className="w-4 h-4 text-slate-400" />;
    }
  };

  // Agrupar para mostrar headers de sección
  let lastSection = '';

  return (
    <>
      {/* Backdrop */}
      <div
        className="fixed inset-0 z-50 bg-black/50 backdrop-blur-sm"
        onClick={onClose}
      />

      {/* Modal */}
      <div className="fixed inset-x-0 top-[15%] z-50 mx-auto max-w-xl px-4">
        <div className="bg-white rounded-2xl shadow-2xl border border-slate-200 overflow-hidden">
          {/* Input */}
          <div className="flex items-center gap-3 px-4 py-3 border-b border-slate-200">
            <Search className="w-5 h-5 text-slate-400 flex-shrink-0" />
            <input
              ref={inputRef}
              type="text"
              placeholder="Buscar tickets, usuarios, departamentos…"
              value={query}
              onChange={e => setQuery(e.target.value)}
              onKeyDown={handleKeyDown}
              className="flex-1 text-sm text-slate-900 placeholder:text-slate-400 outline-none bg-transparent"
              autoComplete="off"
            />
            {isLoading && <Loader2 className="w-4 h-4 text-indigo-500 animate-spin" />}
            <button
              onClick={onClose}
              className="p-1 text-slate-400 hover:text-slate-600 rounded-lg hover:bg-slate-100 transition"
            >
              <X className="w-4 h-4" />
            </button>
          </div>

          {/* Resultados */}
          <div ref={listRef} className="max-h-80 overflow-y-auto">
            {query.length < 2 ? (
              <div className="px-4 py-8 text-center text-sm text-slate-400">
                Escribe al menos 2 caracteres para buscar
              </div>
            ) : flatItems.length === 0 && !isLoading ? (
              <div className="px-4 py-8 text-center text-sm text-slate-400">
                No se encontraron resultados para "{query}"
              </div>
            ) : (
              flatItems.map((item, idx) => {
                const showHeader = item.section !== lastSection;
                lastSection = item.section;
                return (
                  <div key={`${item.section}-${item.id}`}>
                    {showHeader && (
                      <div className="px-4 py-2 text-xs font-semibold text-slate-500 uppercase tracking-wider bg-slate-50">
                        {item.section}
                      </div>
                    )}
                    <div
                      data-idx={idx}
                      onClick={() => handleSelect(item)}
                      className={`
                        flex items-center gap-3 px-4 py-2.5 cursor-pointer transition-colors
                        ${idx === selectedIndex ? 'bg-indigo-50 text-indigo-900' : 'hover:bg-slate-50 text-slate-700'}
                      `}
                    >
                      {sectionIcon(item.section)}
                      <div className="flex-1 min-w-0">
                        <span className="text-sm font-medium truncate block">{item.titulo}</span>
                        {item.extra && (
                          <span className="text-xs text-slate-400 truncate block">{item.extra}</span>
                        )}
                      </div>
                      <span className="text-xs text-slate-400 flex-shrink-0">#{item.id}</span>
                    </div>
                  </div>
                );
              })
            )}
          </div>

          {/* Footer con atajos */}
          <div className="flex items-center justify-between px-4 py-2 border-t border-slate-200 bg-slate-50 text-xs text-slate-400">
            <div className="flex items-center gap-3">
              <span><kbd className="px-1.5 py-0.5 bg-white border border-slate-300 rounded text-[10px] font-mono">↑↓</kbd> navegar</span>
              <span><kbd className="px-1.5 py-0.5 bg-white border border-slate-300 rounded text-[10px] font-mono">Enter</kbd> abrir</span>
              <span><kbd className="px-1.5 py-0.5 bg-white border border-slate-300 rounded text-[10px] font-mono">Esc</kbd> cerrar</span>
            </div>
            <span>Ctrl+K</span>
          </div>
        </div>
      </div>
    </>
  );
}
