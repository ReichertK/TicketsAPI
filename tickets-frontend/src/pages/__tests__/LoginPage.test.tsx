import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { describe, it, expect, vi } from 'vitest';
import LoginPage from '../LoginPage';

// Mock API client
vi.mock('../../services/api.service', () => ({
  apiClient: {
    post: vi.fn(() => new Promise(() => {})), // never resolves — keeps loading
  },
}));
const mockNavigate = vi.fn();
vi.mock('react-router-dom', async () => {
  const actual = await vi.importActual('react-router-dom');
  return { ...actual, useNavigate: () => mockNavigate };
});

function renderLoginPage() {
  return render(
    <MemoryRouter>
      <LoginPage />
    </MemoryRouter>
  );
}

describe('LoginPage — Smoke Tests', () => {
  it('renders branding elements', () => {
    renderLoginPage();
    expect(screen.getByText('Sistema de Tickets')).toBeInTheDocument();
    expect(screen.getByText('Cediac')).toBeInTheDocument();
  });

  it('renders usuario and contraseña inputs', () => {
    renderLoginPage();
    expect(screen.getByLabelText('Usuario / Email')).toBeInTheDocument();
    expect(screen.getByLabelText('Contraseña')).toBeInTheDocument();
  });

  it('renders submit button with "Iniciar sesión"', () => {
    renderLoginPage();
    expect(screen.getByRole('button', { name: /iniciar sesión/i })).toBeInTheDocument();
  });

  it('renders "Recordar usuario" checkbox', () => {
    renderLoginPage();
    expect(screen.getByLabelText(/recordar usuario/i)).toBeInTheDocument();
  });

  it('toggles password visibility', async () => {
    renderLoginPage();
    const user = userEvent.setup();
    const passwordInput = screen.getByLabelText(/contraseña/i);

    expect(passwordInput).toHaveAttribute('type', 'password');

    // Click the toggle button (the eye icon button)
    const toggleBtn = passwordInput.parentElement!.querySelector('button')!;
    await user.click(toggleBtn);
    expect(passwordInput).toHaveAttribute('type', 'text');

    await user.click(toggleBtn);
    expect(passwordInput).toHaveAttribute('type', 'password');
  });

  it('submit button shows loading state when form is submitted', async () => {
    renderLoginPage();
    const user = userEvent.setup();

    await user.type(screen.getByLabelText('Usuario / Email'), 'test@test.com');
    await user.type(screen.getByLabelText('Contraseña'), 'password123');

    const button = screen.getByRole('button', { name: /iniciar sesión/i });
    await user.click(button);

    // After click the button should show loading text
    expect(await screen.findByText(/iniciando sesión/i)).toBeInTheDocument();
  });
});
