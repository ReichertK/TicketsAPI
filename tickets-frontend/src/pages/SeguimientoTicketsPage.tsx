import { useState } from 'react';
import { TicketHistory } from '../components/tickets/TicketHistory';
import { Search, ShieldAlert, FileSearch } from 'lucide-react';

export default function SeguimientoTicketsPage() {
  const [inputValue, setInputValue] = useState('');
  const [ticketId, setTicketId] = useState<number | null>(null);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    const parsed = parseInt(inputValue.replace('#', '').trim(), 10);
    if (!isNaN(parsed) && parsed > 0) {
      setTicketId(parsed);
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') handleSearch(e);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center gap-3">
        <div className="p-2 bg-amber-100 rounded-lg">
          <ShieldAlert className="w-6 h-6 text-amber-600" />
        </div>
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Seguimiento Forense de Tickets</h1>
          <p className="text-sm text-slate-500">
            Herramienta administrativa para inspeccionar el historial completo de transiciones de cualquier ticket.
          </p>
        </div>
      </div>

      {/* Search bar */}
      <div className="bg-white rounded-xl border border-slate-200 p-6">
        <form onSubmit={handleSearch} className="flex items-end gap-3">
          <div className="flex-1 max-w-sm">
            <label htmlFor="ticket-search" className="block text-sm font-medium text-slate-700 mb-1.5">
              ID del Ticket
            </label>
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 w-4 h-4" />
              <input
                id="ticket-search"
                type="text"
                inputMode="numeric"
                placeholder="Ej: 1042 o #1042"
                value={inputValue}
                onChange={(e) => setInputValue(e.target.value)}
                onKeyDown={handleKeyDown}
                className="w-full pl-10 pr-4 py-2.5 border border-slate-200 rounded-lg bg-white text-slate-900 placeholder-slate-400 focus:ring-2 focus:ring-amber-500 focus:border-transparent text-sm transition"
                autoFocus
              />
            </div>
          </div>
          <button
            type="submit"
            disabled={!inputValue.trim()}
            className="flex items-center gap-2 px-5 py-2.5 bg-amber-600 text-white rounded-lg hover:bg-amber-700 disabled:opacity-40 disabled:cursor-not-allowed shadow-sm text-sm font-medium transition"
          >
            <FileSearch className="w-4 h-4" />
            Inspeccionar
          </button>
        </form>
      </div>

      {/* Results */}
      {ticketId ? (
        <div className="bg-white rounded-xl border border-slate-200 p-6">
          <div className="mb-4 pb-4 border-b border-slate-100">
            <h2 className="text-lg font-semibold text-slate-800">
              Ticket <span className="text-amber-600">#{ticketId}</span> — Historial Completo
            </h2>
            <p className="text-xs text-slate-400 mt-1">
              Se muestran todas las transiciones de estado en orden cronológico. Utilice "Cargar más" para ver transiciones anteriores.
            </p>
          </div>
          <TicketHistory ticketId={ticketId} />
        </div>
      ) : (
        <div className="bg-white rounded-xl border border-dashed border-slate-300 p-12 text-center">
          <FileSearch className="w-12 h-12 text-slate-300 mx-auto mb-3" />
          <p className="text-slate-500 text-sm">
            Ingrese un ID de ticket para ver su historial forense completo.
          </p>
        </div>
      )}
    </div>
  );
}
