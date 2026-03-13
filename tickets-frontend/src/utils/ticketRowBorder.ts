/**
 * Devuelve la clase CSS de border-left para una fila de ticket,
 * basada en la prioridad (ID o nombre).
 *
 * Paleta:
 *   Crítica (id=7)  → rose-500
 *   Alta    (id=1)  → orange-500
 *   Media   (id=2)  → amber-400
 *   Baja    (id=3)  → slate-300
 *   Default         → slate-200
 */
export function getTicketRowBorderClass(
  prioridadId?: number,
  prioridadNombre?: string,
): string {
  // Resolución por ID (más confiable)
  if (prioridadId) {
    switch (prioridadId) {
      case 7: return 'border-l-4 border-l-rose-500';
      case 1: return 'border-l-4 border-l-orange-500';
      case 2: return 'border-l-4 border-l-amber-400';
      case 3: return 'border-l-4 border-l-slate-300';
    }
  }

  // Fallback por nombre
  const key = prioridadNombre?.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '') ?? '';
  if (key.includes('critica') || key.includes('urgente')) return 'border-l-4 border-l-rose-500';
  if (key.includes('alta')) return 'border-l-4 border-l-orange-500';
  if (key.includes('media') || key.includes('normal')) return 'border-l-4 border-l-amber-400';
  if (key.includes('baja')) return 'border-l-4 border-l-slate-300';

  return 'border-l-4 border-l-slate-200';
}
