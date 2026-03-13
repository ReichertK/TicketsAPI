import { SearchX, Inbox, FileQuestion } from 'lucide-react';

type EmptyVariant = 'no-results' | 'empty' | 'error';

interface EmptyStateProps {
  variant?: EmptyVariant;
  title?: string;
  message?: string;
  action?: React.ReactNode;
}

const CONFIG: Record<EmptyVariant, { icon: typeof SearchX; defaultTitle: string; defaultMessage: string }> = {
  'no-results': {
    icon: SearchX,
    defaultTitle: 'Sin resultados',
    defaultMessage: 'No se encontraron tickets con los filtros aplicados. Intenta ajustar tu búsqueda.',
  },
  empty: {
    icon: Inbox,
    defaultTitle: 'Sin tickets',
    defaultMessage: 'Aún no hay tickets en esta vista.',
  },
  error: {
    icon: FileQuestion,
    defaultTitle: 'Error',
    defaultMessage: 'Ocurrió un error al cargar los datos.',
  },
};

/**
 * Estado vacío visual para listados de tickets.
 * Variantes: no-results (búsqueda), empty (sin datos), error.
 */
export default function EmptyState({
  variant = 'empty',
  title,
  message,
  action,
}: EmptyStateProps) {
  const cfg = CONFIG[variant];
  const Icon = cfg.icon;

  return (
    <div className="bg-white rounded-xl border border-slate-200 py-16 px-8 text-center">
      {/* Icono decorativo con anillos */}
      <div className="relative inline-flex items-center justify-center mb-6">
        <div className="absolute w-24 h-24 rounded-full bg-slate-50"></div>
        <div className="absolute w-16 h-16 rounded-full bg-slate-100"></div>
        <Icon className="relative w-8 h-8 text-slate-400" strokeWidth={1.5} />
      </div>

      <h3 className="text-lg font-semibold text-slate-700 mb-1">
        {title ?? cfg.defaultTitle}
      </h3>
      <p className="text-sm text-slate-500 max-w-md mx-auto mb-6">
        {message ?? cfg.defaultMessage}
      </p>

      {action && <div>{action}</div>}
    </div>
  );
}
