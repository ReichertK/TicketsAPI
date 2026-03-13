import { useEffect, useRef, useCallback } from 'react';
import {
  HubConnectionBuilder,
  HubConnection,
  LogLevel,
  HubConnectionState,
} from '@microsoft/signalr';
import { useQueryClient } from '@tanstack/react-query';
import { useAuthStore } from '../store/authStore';
import { sileo } from 'sileo';

// Hub URL: usa VITE_SIGNALR_HUB_URL si existe, sino deriva de VITE_API_URL
const HUB_URL = import.meta.env.VITE_SIGNALR_HUB_URL
  || (import.meta.env.VITE_API_URL || 'http://localhost:5000/api/v1')
      .replace('/api/v1', '')
      .concat('/hubs/tickets');

/**
 * SignalR event payloads del backend
 */
interface NuevoTicketPayload {
  idTicket: number;
  idUsuarioCreador?: number;
}

interface ActualizacionTicketPayload {
  idTicket: number;
  idUsuarioActualizador?: number;
}

interface TransicionEstadoPayload {
  idTicket: number;
  nuevoEstado?: string;
  idUsuario?: number;
  idEstadoNuevo?: number;
}

interface NuevoComentarioPayload {
  idTicket: number;
  idUsuario?: number;
  comentario?: string;
}

interface SolicitudAprobacionPayload {
  idTicket: number;
  idUsuarioSolicitante?: number;
  idUsuarioAprobador?: number;
}

/**
 * De-bounce helper: ignora llamadas duplicadas dentro de una ventana de tiempo
 * basándose en una clave string (e.g. "NuevoTicket-42").
 */
function createEventDeduper(windowMs = 1500) {
  const seen = new Map<string, number>();
  return (key: string): boolean => {
    const now = Date.now();
    const last = seen.get(key);
    if (last && now - last < windowMs) return true; // duplicado
    seen.set(key, now);
    // Limpiar entradas antiguas cada 50 eventos
    if (seen.size > 50) {
      for (const [k, ts] of seen) {
        if (now - ts > windowMs * 2) seen.delete(k);
      }
    }
    return false;
  };
}

/**
 * Hook global de SignalR.
 * Se conecta automáticamente cuando hay token y desconecta en logout.
 * Escucha todos los eventos del TicketHub e invalida las queries de React Query.
 *
 * Usa refs para queryClient/userId de modo que `connect` solo dependa
 * de `token`, evitando reconexiones innecesarias y handlers duplicados.
 */

// ── Module-level singleton to survive StrictMode double-mount ────
let _sharedConnection: HubConnection | null = null;
let _sharedConnecting = false;

export function useSignalR() {
  const connectionRef = useRef<HubConnection | null>(_sharedConnection);
  const connectingRef = useRef(_sharedConnecting);

  const token = useAuthStore((s) => s.token);
  const userId = useAuthStore((s) => s.user?.id_Usuario);
  const queryClient = useQueryClient();

  // Refs estables — siempre apuntan al valor más reciente
  const userIdRef = useRef(userId);
  userIdRef.current = userId;
  const queryClientRef = useRef(queryClient);
  queryClientRef.current = queryClient;

  const isDup = useRef(createEventDeduper(1500)).current;

  const connect = useCallback(async () => {
    if (!token) return;
    // Check module-level guard (survives StrictMode unmount/remount)
    if (_sharedConnecting) return;
    if (
      _sharedConnection &&
      (_sharedConnection.state === HubConnectionState.Connected ||
       _sharedConnection.state === HubConnectionState.Connecting ||
       _sharedConnection.state === HubConnectionState.Reconnecting)
    ) {
      connectionRef.current = _sharedConnection;
      return; // ya conectado o en proceso
    }

    _sharedConnecting = true;
    connectingRef.current = true;

    const connection = new HubConnectionBuilder()
      .withUrl(HUB_URL, {
        accessTokenFactory: () => token,
      })
      .withAutomaticReconnect([0, 2000, 5000, 10000, 30000])
      .configureLogging(LogLevel.Warning)
      .build();

    // Tolerancia amplia: el server envía ping cada 15s,
    // pero el main thread puede tardar en procesarlos.
    connection.serverTimeoutInMilliseconds = 120_000; // 2 min
    connection.keepAliveIntervalInMilliseconds = 15_000;

    // ── Handlers de eventos (usan refs para valores actuales) ────

    /** Invalidar todas las listas de tickets (mis-tickets, todos, cola) */
    const invalidateTicketLists = () => {
      queryClientRef.current.invalidateQueries({ queryKey: ['mis-tickets'] });
      queryClientRef.current.invalidateQueries({ queryKey: ['tickets-todos'] });
      queryClientRef.current.invalidateQueries({ queryKey: ['tickets-cola'] });
    };

    connection.on('NuevoTicket', (payload: NuevoTicketPayload | number) => {
      const data = typeof payload === 'number' ? { idTicket: payload } : payload;
      if (isDup(`NuevoTicket-${data.idTicket}`)) return;

      // No notificar al creador
      if (data.idUsuarioCreador && data.idUsuarioCreador === userIdRef.current) return;

      queryClientRef.current.invalidateQueries({ queryKey: ['mis-tickets'] });
      queryClientRef.current.invalidateQueries({ queryKey: ['tickets-todos'] });
      queryClientRef.current.invalidateQueries({ queryKey: ['tickets-cola'] });
      queryClientRef.current.invalidateQueries({ queryKey: ['dashboard'] });

      sileo.action({
        title: 'Nuevo Ticket',
        description: `Se ha creado el ticket #${data.idTicket}`,
        button: { title: 'Ver', onClick: () => window.location.assign(`/tickets/${data.idTicket}`) },
      });
    });

    connection.on(
      'ActualizacionTicket',
      (payload: ActualizacionTicketPayload | number) => {
        const data =
          typeof payload === 'number' ? { idTicket: payload } : payload;
        if (isDup(`ActualizacionTicket-${data.idTicket}`)) return;

        invalidateTicketLists();
        queryClientRef.current.invalidateQueries({ queryKey: ['ticket', data.idTicket] });
        queryClientRef.current.invalidateQueries({ queryKey: ['dashboard'] });

        sileo.action({
          title: 'Ticket Actualizado',
          description: `El ticket #${data.idTicket} ha sido actualizado`,
          button: { title: 'Ver', onClick: () => window.location.assign(`/tickets/${data.idTicket}`) },
        });
      }
    );

    connection.on(
      'TransicionEstado',
      (payload: TransicionEstadoPayload | number) => {
        const data =
          typeof payload === 'number' ? { idTicket: payload } : payload;
        if (isDup(`TransicionEstado-${data.idTicket}`)) return;

        invalidateTicketLists();
        queryClientRef.current.invalidateQueries({ queryKey: ['ticket', data.idTicket] });
        queryClientRef.current.invalidateQueries({ queryKey: ['dashboard'] });

        const estadoLabel = data.nuevoEstado ?? `Estado #${data.idEstadoNuevo}`;
        sileo.action({
          title: 'Cambio de Estado',
          description: `Ticket #${data.idTicket} → ${estadoLabel}`,
          button: { title: 'Ver', onClick: () => window.location.assign(`/tickets/${data.idTicket}`) },
        });
      }
    );

    connection.on(
      'NuevoComentario',
      (payload: NuevoComentarioPayload | number) => {
        const data =
          typeof payload === 'number' ? { idTicket: payload } : payload;
        if (isDup(`NuevoComentario-${data.idTicket}`)) return;

        queryClientRef.current.invalidateQueries({ queryKey: ['ticket', data.idTicket] });

        sileo.action({
          title: 'Nuevo Comentario',
          description: `Comentario añadido en ticket #${data.idTicket}`,
          button: { title: 'Ver', onClick: () => window.location.assign(`/tickets/${data.idTicket}`) },
        });
      }
    );

    connection.on(
      'SolicitudAprobacion',
      (payload: SolicitudAprobacionPayload | number) => {
        const data =
          typeof payload === 'number' ? { idTicket: payload } : payload;
        if (isDup(`SolicitudAprobacion-${data.idTicket}`)) return;

        invalidateTicketLists();
        queryClientRef.current.invalidateQueries({ queryKey: ['ticket', data.idTicket] });

        sileo.action({
          title: 'Solicitud de Aprobación',
          description: `El ticket #${data.idTicket} requiere aprobación`,
          button: { title: 'Revisar', onClick: () => window.location.assign(`/tickets/${data.idTicket}`) },
        });
      }
    );

    // ── Menciones (@usuario) ─────────────────────────────────────

    connection.on('MencionUsuario', (payload: { idTicket: number; idComentario: number; mensaje: string }) => {
      if (isDup(`MencionUsuario-${payload.idTicket}-${payload.idComentario}`)) return;

      // Invalidar alertas
      queryClientRef.current.invalidateQueries({ queryKey: ['alertas'] });
      queryClientRef.current.invalidateQueries({ queryKey: ['ticket', payload.idTicket] });

      sileo.action({
        title: 'Te mencionaron',
        description: payload.mensaje || `Te mencionaron en el ticket #${payload.idTicket}`,
        button: { title: 'Ver', onClick: () => window.location.assign(`/tickets/${payload.idTicket}`) },
      });
    });

    // ── Asignación de ticket (@usuario) ──────────────────────────

    connection.on('TicketAssigned', (payload: { idTicket: number; mensaje: string }) => {
      if (isDup(`TicketAssigned-${payload.idTicket}`)) return;

      // Invalidar alertas (campana), ticket detalle, lista de tickets y transiciones
      queryClientRef.current.invalidateQueries({ queryKey: ['alertas'] });
      queryClientRef.current.invalidateQueries({ queryKey: ['ticket', payload.idTicket] });
      invalidateTicketLists();
      queryClientRef.current.invalidateQueries({ queryKey: ['ticket-transitions', payload.idTicket] });

      sileo.action({
        title: 'Ticket asignado',
        description: payload.mensaje || `Te asignaron el ticket #${payload.idTicket}`,
        button: { title: 'Abrir', onClick: () => window.location.assign(`/tickets/${payload.idTicket}`) },
      });
    });

    // ── Reconexión ───────────────────────────────────────────────

    connection.onreconnecting(() => {
      sileo.warning({
        title: 'Reconectando…',
        description: 'Se perdió la conexión en tiempo real. Reintentando…',
      });
    });

    connection.onreconnected(() => {
      sileo.success({
        title: 'Reconectado',
        description: 'Conexión en tiempo real restaurada',
      });
      // Refrescar datos tras reconexión
      invalidateTicketLists();
      queryClientRef.current.invalidateQueries({ queryKey: ['dashboard'] });
      // Re-suscribirse al grupo personal tras reconexión
      connection.invoke('SubscribeToUser').catch(() => {});
    });

    connection.onclose(() => {
      connectionRef.current = null;
      connectingRef.current = false;
      _sharedConnection = null;
      _sharedConnecting = false;
    });

    // ── Iniciar conexión ─────────────────────────────────────────

    try {
      await connection.start();
      connectionRef.current = connection;
      connectingRef.current = false;
      _sharedConnection = connection;
      _sharedConnecting = false;
      console.log('[SignalR] Conectado a TicketHub');

      // Suscribirse al grupo personal para recibir @menciones dirigidas
      try {
        await connection.invoke('SubscribeToUser');
        console.log('[SignalR] Suscrito a grupo personal de usuario');
      } catch (subErr) {
        console.warn('[SignalR] No se pudo suscribir a grupo personal:', subErr);
      }
    } catch (err) {
      connectingRef.current = false;
      _sharedConnecting = false;
      console.error('[SignalR] Error al conectar:', err);
    }
  }, [token]); // ← SOLO depende de token (refs para el resto)

  const disconnect = useCallback(async () => {
    const conn = connectionRef.current || _sharedConnection;
    if (conn) {
      try {
        await conn.stop();
      } catch {
        // silenciar errores al desconectar
      }
      connectionRef.current = null;
      connectingRef.current = false;
      _sharedConnection = null;
      _sharedConnecting = false;
    }
  }, []);

  /**
   * Suscribirse a actualizaciones de un ticket específico (grupo SignalR)
   */
  const subscribeToTicket = useCallback(async (ticketId: number) => {
    if (
      connectionRef.current?.state === HubConnectionState.Connected
    ) {
      await connectionRef.current.invoke('SubscribeToTicket', ticketId);
    }
  }, []);

  /**
   * Desuscribirse de un ticket específico
   */
  const unsubscribeFromTicket = useCallback(async (ticketId: number) => {
    if (
      connectionRef.current?.state === HubConnectionState.Connected
    ) {
      await connectionRef.current.invoke('UnsubscribeFromTicket', ticketId);
    }
  }, []);

  /**
   * Suscribirse a notificaciones de aprobación (aprobadores)
   */
  const subscribeToApprovals = useCallback(async () => {
    if (
      connectionRef.current?.state === HubConnectionState.Connected
    ) {
      await connectionRef.current.invoke('SubscribeToApprovals');
    }
  }, []);

  // Auto-connect cuando hay token, disconnect solo en logout.
  // ⚠️ Sin cleanup — la conexión singleton sobrevive unmounts de StrictMode
  // y desmontajes de componentes. Solo se desconecta cuando token → null.
  useEffect(() => {
    if (token) {
      connect();
    } else {
      disconnect();
    }
  }, [token, connect, disconnect]);

  return {
    connection: connectionRef.current || _sharedConnection,
    subscribeToTicket,
    unsubscribeFromTicket,
    subscribeToApprovals,
  };
}
