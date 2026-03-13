import { render, screen } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { MemoryRouter } from 'react-router-dom';
import { describe, it, expect, vi } from 'vitest';
import TicketsPage from '../TicketsPage';

// Mock API client to prevent real network requests
vi.mock('../../services/api.service', () => ({
  apiClient: {
    get: vi.fn().mockResolvedValue({
      data: {
        exitoso: true,
        datos: { datos: [], totalRegistros: 0, totalPaginas: 0, paginaActual: 1 },
      },
    }),
    post: vi.fn(),
  },
}));

function renderTicketsPage() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });

  return render(
    <QueryClientProvider client={queryClient}>
      <MemoryRouter>
        <TicketsPage />
      </MemoryRouter>
    </QueryClientProvider>
  );
}

describe('TicketsPage — Smoke Tests', () => {
  it('renders the page heading "Mis Tickets"', async () => {
    renderTicketsPage();
    expect(screen.getByText('Mis Tickets')).toBeInTheDocument();
  });

  it('renders "Nuevo Ticket" button', () => {
    renderTicketsPage();
    expect(screen.getByText('Nuevo Ticket')).toBeInTheDocument();
  });

  it('shows loading or ticket count text', () => {
    renderTicketsPage();
    // When loading shows "Cargando…", when loaded shows count
    const indicator = screen.getAllByText(/cargando|ticket/i);
    expect(indicator.length).toBeGreaterThan(0);
  });
});
