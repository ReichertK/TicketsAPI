import { type LucideIcon, AlertTriangle } from 'lucide-react';
import type { ReactNode } from 'react';

type ConfirmActionVariant = 'danger' | 'warning' | 'success' | 'info';

interface ConfirmActionModalProps {
  /** Controla la visibilidad */
  open: boolean;
  /** Variante visual: danger=rose, warning=amber, success=emerald, info=indigo */
  variant?: ConfirmActionVariant;
  /** Ícono central (default: AlertTriangle) */
  Icon?: LucideIcon;
  /** Título principal */
  title: string;
  /** Línea principal de descripción */
  description?: string;
  /** Línea secundaria (nombre del recurso, email, etc.) */
  detail?: string;
  /** Texto aclaratorio extra */
  footnote?: string;
  /** Contenido extra entre la descripción y los botones */
  children?: ReactNode;
  /** Texto del botón de confirmar */
  confirmText?: string;
  /** Texto del botón de cancelar */
  cancelText?: string;
  /** Deshabilitar el botón de confirmar (además de isPending) */
  confirmDisabled?: boolean;
  /** Si la acción está en curso */
  isPending?: boolean;
  /** Callback al confirmar */
  onConfirm: () => void;
  /** Callback al cancelar / cerrar */
  onClose: () => void;
}

const VARIANT_STYLES: Record<ConfirmActionVariant, { bg: string; iconText: string; btn: string }> = {
  danger:  { bg: 'bg-rose-100',    iconText: 'text-rose-600',    btn: 'bg-rose-600 hover:bg-rose-700' },
  warning: { bg: 'bg-amber-100',   iconText: 'text-amber-600',   btn: 'bg-amber-600 hover:bg-amber-700' },
  success: { bg: 'bg-emerald-100', iconText: 'text-emerald-600', btn: 'bg-emerald-600 hover:bg-emerald-700' },
  info:    { bg: 'bg-indigo-100',  iconText: 'text-indigo-600',  btn: 'bg-indigo-600 hover:bg-indigo-700' },
};

/**
 * Modal genérico de confirmación de acción.
 * Reemplaza los modales inline de confirmación embebidos en páginas.
 */
export default function ConfirmActionModal({
  open,
  variant = 'danger',
  Icon = AlertTriangle,
  title,
  description,
  detail,
  footnote,
  children,
  confirmText = 'Confirmar',
  cancelText = 'Cancelar',
  confirmDisabled = false,
  isPending = false,
  onConfirm,
  onClose,
}: ConfirmActionModalProps) {
  if (!open) return null;

  const vs = VARIANT_STYLES[variant];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md mx-4 overflow-hidden">
        {/* Contenido */}
        <div className="p-6 text-center">
          <div className={`mx-auto w-14 h-14 rounded-full flex items-center justify-center mb-4 ${vs.bg}`}>
            <Icon className={`w-7 h-7 ${vs.iconText}`} />
          </div>
          <h3 className="text-lg font-semibold text-slate-900 mb-2">{title}</h3>
          {description && (
            <p className="text-sm text-slate-700 font-medium mb-1">{description}</p>
          )}
          {detail && (
            <p className="text-sm text-slate-400">{detail}</p>
          )}
          {footnote && (
            <p className="text-xs text-slate-400 mt-3">{footnote}</p>
          )}
          {children}
        </div>

        {/* Botones */}
        <div className="flex items-center gap-3 px-6 pb-6">
          <button
            onClick={onClose}
            disabled={isPending}
            className="flex-1 px-4 py-2.5 text-sm font-medium text-slate-700 border border-slate-200 rounded-lg hover:bg-slate-50 transition disabled:opacity-50"
          >
            {cancelText}
          </button>
          <button
            onClick={onConfirm}
            disabled={isPending || confirmDisabled}
            className={`flex-1 px-4 py-2.5 text-sm font-medium text-white rounded-lg transition shadow-sm disabled:opacity-50 ${vs.btn}`}
          >
            {isPending ? 'Procesando…' : confirmText}
          </button>
        </div>
      </div>
    </div>
  );
}
