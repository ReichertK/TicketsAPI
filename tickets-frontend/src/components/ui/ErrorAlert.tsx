import { AlertCircle, RefreshCw } from 'lucide-react';

interface ErrorAlertProps {
  title?: string;
  message?: string;
  onRetry?: () => void;
  retryLabel?: string;
}

export default function ErrorAlert({
  title = 'Error al cargar datos',
  message = 'Ocurrió un error al comunicarse con el servidor. Verifica tu conexión e intenta nuevamente.',
  onRetry,
  retryLabel = 'Reintentar',
}: ErrorAlertProps) {
  return (
    <div className="flex items-center justify-center h-96">
      <div className="max-w-md w-full bg-red-50 border border-red-200 rounded-lg p-6 text-center">
        <AlertCircle className="w-12 h-12 text-red-500 mx-auto mb-4" />
        <h3 className="text-lg font-semibold text-red-800 mb-2">{title}</h3>
        <p className="text-sm text-red-600 mb-4">{message}</p>
        {onRetry && (
          <button
            onClick={onRetry}
            className="inline-flex items-center gap-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition"
          >
            <RefreshCw className="w-4 h-4" />
            {retryLabel}
          </button>
        )}
      </div>
    </div>
  );
}
