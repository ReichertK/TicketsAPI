import { useMemo } from 'react';
import {
  ArrowRight, Minus, User, Building2, Shield, Tag, Ticket,
  FileText, Settings, Key, Globe, PlusCircle, Trash2, RefreshCw, Info
} from 'lucide-react';

// Helpers
function humanizeFieldName(field: string): string {
  return field
    .replace(/^id_/, '')
    .replace(/_id$/, '')
    .replace(/([A-Z])/g, ' $1')
    .replace(/[_-]+/g, ' ')
    .trim()
    .replace(/\b\w/g, (c) => c.toUpperCase());
}

function formatValue(val: unknown): string {
  if (val === null || val === undefined) return '(vac\u00edo)';
  if (typeof val === 'boolean') return val ? 'S\u00ed' : 'No';
  if (typeof val === 'object') return JSON.stringify(val);
  return String(val);
}

function valuesAreEqual(a: unknown, b: unknown): boolean {
  if (a === b) return true;
  if (a === null || a === undefined) return b === null || b === undefined;
  if (typeof a === 'object' || typeof b === 'object') {
    return JSON.stringify(a) === JSON.stringify(b);
  }
  return String(a) === String(b);
}

function tryParseJSON(val: string | null | undefined): Record<string, unknown> | null {
  if (!val) return null;
  try { return JSON.parse(val); } catch { return null; }
}

/** Detecta si un JSON es placeholder (ej: {"campo":"valor_viejo"}) */
function isPlaceholderJSON(obj: Record<string, unknown> | null): boolean {
  if (!obj) return true;
  const keys = Object.keys(obj);
  if (keys.length === 0) return true;
  if (keys.length === 1 && keys[0] === 'campo') return true;
  return false;
}

function extractEntityName(obj: Record<string, unknown> | null): string | null {
  if (!obj || isPlaceholderJSON(obj)) return null;
  const candidates = [
    'nombre', 'nombre_Rol', 'nombre_Estado', 'nombre_Prioridad',
    'login', 'email', 'descripcion', 'contenido', 'titulo', 'asunto',
    'usuario_Correo'
  ];
  for (const key of candidates) {
    const val = obj[key];
    if (val && typeof val === 'string' && val.trim().length > 0) {
      return val.trim().length > 60 ? val.trim().substring(0, 57) + '...' : val.trim();
    }
  }
  return null;
}

const TABLE_ICONS: Record<string, React.ComponentType<{ className?: string }>> = {
  usuarios: User, usuario: User,
  departamentos: Building2, departamento: Building2,
  roles: Shield, rol: Shield,
  permisos: Key, permiso: Key,
  estados: Tag, estado: Tag,
  prioridades: Tag, prioridad: Tag,
  tickets: Ticket, ticket: Ticket, tkt: Ticket,
  motivos: FileText, motivo: FileText,
  configuracion: Settings, audit_log: Globe,
};

function getTableIcon(tabla: string): React.ComponentType<{ className?: string }> {
  const normalized = tabla?.toLowerCase().replace(/^tbl_/, '');
  return TABLE_ICONS[normalized] ?? TABLE_ICONS[normalized.replace(/s$/, '')] ?? FileText;
}

const ACTION_HEADER: Record<string, { icon: React.ComponentType<{ className?: string }>; label: string; color: string }> = {
  INSERT: { icon: PlusCircle, label: 'Registro Creado', color: 'text-emerald-600' },
  DELETE: { icon: Trash2, label: 'Registro Eliminado', color: 'text-red-600' },
  UPDATE: { icon: RefreshCw, label: 'Registro Modificado', color: 'text-blue-600' },
  TOGGLE: { icon: Settings, label: 'Estado Cambiado', color: 'text-amber-600' },
  LOGIN: { icon: User, label: 'Inicio de Sesi\u00f3n', color: 'text-violet-600' },
  LOGOUT: { icon: User, label: 'Cierre de Sesi\u00f3n', color: 'text-slate-600' },
};

// Tipos
interface DiffTableProps {
  valoresAntiguos: string | null | undefined;
  valoresNuevos: string | null | undefined;
  accion: string;
  tabla?: string;
  /** Fallback: cuando el JSON es placeholder, muestra la descripci\u00f3n del log */
  descripcion?: string | null;
}

interface DiffRow {
  field: string;
  label: string;
  oldVal: unknown;
  newVal: unknown;
  changed: boolean;
}

// Componente principal (Named Export)
export function DiffTable({ valoresAntiguos, valoresNuevos, accion, tabla, descripcion }: DiffTableProps) {
  const accionUpper = accion?.toUpperCase() ?? '';
  const isInsert = accionUpper === 'INSERT';
  const isDelete = accionUpper === 'DELETE';
  const isUpdate = accionUpper === 'UPDATE';

  const oldObj = useMemo(() => tryParseJSON(valoresAntiguos), [valoresAntiguos]);
  const newObj = useMemo(() => tryParseJSON(valoresNuevos), [valoresNuevos]);

  const oldIsPlaceholder = isPlaceholderJSON(oldObj);
  const newIsPlaceholder = isPlaceholderJSON(newObj);
  const bothPlaceholder = oldIsPlaceholder && newIsPlaceholder;

  const rows = useMemo<DiffRow[]>(() => {
    if (bothPlaceholder) return [];

    const effectiveOld = oldIsPlaceholder ? null : oldObj;
    const effectiveNew = newIsPlaceholder ? null : newObj;
    if (!effectiveOld && !effectiveNew) return [];

    const allKeys = new Set<string>();
    if (effectiveOld) Object.keys(effectiveOld).forEach((k) => allKeys.add(k));
    if (effectiveNew) Object.keys(effectiveNew).forEach((k) => allKeys.add(k));

    const allRows = Array.from(allKeys).map((field) => {
      const oldVal = effectiveOld?.[field] ?? null;
      const newVal = effectiveNew?.[field] ?? null;
      return { field, label: humanizeFieldName(field), oldVal, newVal, changed: !valuesAreEqual(oldVal, newVal) };
    });

    if (isUpdate) return allRows.filter((r) => r.changed);
    return allRows;
  }, [oldObj, newObj, oldIsPlaceholder, newIsPlaceholder, bothPlaceholder, isUpdate]);

  const entityName = useMemo(
    () => extractEntityName(isDelete ? oldObj : newObj) ?? extractEntityName(oldObj),
    [oldObj, newObj, isDelete]
  );

  // Header din\u00e1mico
  const headerInfo = ACTION_HEADER[accionUpper] ?? ACTION_HEADER['UPDATE'];
  const TableIcon = tabla ? getTableIcon(tabla) : FileText;

  // Fallback: JSON placeholder, mostrar descripci\u00f3n
  if (bothPlaceholder) {
    return (
      <div className="mt-3 pt-3 border-t border-slate-200/60">
        <div className="flex items-center gap-2 mb-2">
          <TableIcon className={`w-4 h-4 ${headerInfo.color}`} />
          <span className={`text-xs font-semibold ${headerInfo.color}`}>{headerInfo.label}</span>
          {tabla && (
            <>
              <span className="text-xs text-slate-300">\u00b7</span>
              <span className="text-[10px] text-slate-400 font-mono">{tabla}</span>
            </>
          )}
        </div>
        {descripcion ? (
          <div className="flex items-start gap-2 p-3 bg-slate-50 rounded-lg border border-slate-200">
            <Info className="w-4 h-4 text-slate-400 mt-0.5 flex-shrink-0" />
            <div>
              <p className="text-xs font-medium text-slate-600">Descripci\u00f3n del registro</p>
              <p className="text-sm text-slate-800 mt-0.5">{descripcion}</p>
            </div>
          </div>
        ) : (
          <p className="text-xs text-slate-400 italic">Sin datos detallados de valores registrados</p>
        )}
        {isDelete && (
          <span className="inline-flex items-center gap-1 mt-2 px-2 py-0.5 rounded-full text-[10px] font-semibold bg-red-100 text-red-700">
            <Trash2 className="w-3 h-3" /> ELIMINADO
          </span>
        )}
        {isInsert && (
          <span className="inline-flex items-center gap-1 mt-2 px-2 py-0.5 rounded-full text-[10px] font-semibold bg-emerald-100 text-emerald-700">
            <PlusCircle className="w-3 h-3" /> NUEVO
          </span>
        )}
      </div>
    );
  }

  if (rows.length === 0 && isUpdate) {
    return <p className="text-xs text-slate-400 italic mt-2">Sin cambios detectados en los valores</p>;
  }

  return (
    <div className="mt-3 pt-3 border-t border-slate-200/60">
      <div className="flex items-center gap-2 mb-3">
        <TableIcon className={`w-4 h-4 ${headerInfo.color}`} />
        <span className={`text-xs font-semibold ${headerInfo.color}`}>{headerInfo.label}</span>
        {entityName && (
          <>
            <span className="text-xs text-slate-300">\u00b7</span>
            <span className="text-xs text-slate-500 font-medium truncate max-w-[250px]">{entityName}</span>
          </>
        )}
        {tabla && (
          <>
            <span className="text-xs text-slate-300">\u00b7</span>
            <span className="text-[10px] text-slate-400 font-mono">{tabla}</span>
          </>
        )}
      </div>

      <div className="overflow-x-auto rounded-lg border border-slate-200">
        <table className="w-full text-xs">
          <thead>
            <tr className="bg-slate-50 border-b border-slate-200">
              <th className="text-left px-3 py-2 font-semibold text-slate-600 w-[35%]">Campo</th>
              <th className="text-left px-3 py-2 font-semibold text-slate-600 w-[32.5%]">Antes</th>
              <th className="text-left px-3 py-2 font-semibold text-slate-600 w-[32.5%]">Despu\u00e9s</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {rows.map((row) => (
              <tr key={row.field} className={row.changed ? 'bg-green-50/60 hover:bg-green-50' : 'bg-white hover:bg-slate-50/50'}>
                <td className="px-3 py-1.5 font-medium text-slate-700">
                  <span className="flex items-center gap-1.5">
                    {row.changed && <ArrowRight className="w-3 h-3 text-green-600 flex-shrink-0" />}
                    {row.label}
                  </span>
                </td>
                <td className="px-3 py-1.5">
                  {isInsert ? (
                    <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-semibold bg-slate-200 text-slate-600">NUEVO</span>
                  ) : (
                    <CellValue value={row.oldVal} highlight={false} />
                  )}
                </td>
                <td className="px-3 py-1.5">
                  {isDelete ? (
                    <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-semibold bg-red-100 text-red-700">
                      <Trash2 className="w-3 h-3" /> ELIMINADO
                    </span>
                  ) : (
                    <CellValue value={row.newVal} highlight={row.changed} />
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <p className="mt-1.5 text-[10px] text-slate-400">
        {isUpdate
          ? `${rows.length} campo(s) modificado(s)`
          : `${rows.filter((r) => r.changed).length} campo(s) modificado(s) de ${rows.length} total`}
      </p>
    </div>
  );
}

function CellValue({ value, highlight }: { value: unknown; highlight: boolean }) {
  const isEmpty = value === null || value === undefined;
  const display = formatValue(value);
  if (isEmpty) {
    return (
      <span className="inline-flex items-center gap-1 text-slate-400 italic">
        <Minus className="w-3 h-3" /> (vac\u00edo)
      </span>
    );
  }
  return (
    <span className={highlight ? 'text-green-700 bg-green-50 font-medium px-1.5 py-0.5 rounded' : 'text-slate-600'}>
      {display}
    </span>
  );
}