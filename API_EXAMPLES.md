# Ejemplos de Consumo de API

## 📋 Ejemplos en Diferentes Lenguajes

### 1. JavaScript/Axios (para React)

```javascript
// api.config.js
import axios from 'axios';

export const apiClient = axios.create({
  baseURL: process.env.REACT_APP_API_URL || 'https://localhost:5001/api/v1',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json'
  }
});

// Interceptor para agregar token JWT
apiClient.interceptors.request.use(
  config => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  error => Promise.reject(error)
);

// Interceptor para manejar errores 401
apiClient.interceptors.response.use(
  response => response,
  async error => {
    if (error.response?.status === 401) {
      // Intentar refresh token
      const refreshToken = localStorage.getItem('refreshToken');
      if (refreshToken) {
        try {
          const { data } = await apiClient.post('/auth/refresh-token', { refreshToken });
          localStorage.setItem('token', data.datos.token);
          // Reintentar request original
          return apiClient(error.config);
        } catch (refreshError) {
          // Redirigir a login
          localStorage.clear();
          window.location.href = '/login';
        }
      }
    }
    return Promise.reject(error);
  }
);

export default apiClient;
```

#### Login
```javascript
// authService.js
import apiClient from './api.config';

export const authService = {
  login: async (usuario, contraseña) => {
    const { data } = await apiClient.post('/auth/login', { usuario, contraseña });
    if (data.exitoso) {
      localStorage.setItem('token', data.datos.token);
      localStorage.setItem('refreshToken', data.datos.refreshToken);
      return data.datos;
    }
    throw new Error(data.mensaje);
  },

  logout: async () => {
    await apiClient.post('/auth/logout');
    localStorage.clear();
  },

  getCurrentUser: async () => {
    const { data } = await apiClient.get('/auth/me');
    return data.datos;
  }
};
```

#### Tickets
```javascript
// ticketService.js
import apiClient from './api.config';

export const ticketService = {
  // Listar tickets con filtros
  getTickets: async (filters = {}) => {
    const { data } = await apiClient.get('/tickets', { params: filters });
    return data.datos; // PaginatedResponse<TicketDTO>
  },

  // Obtener detalle
  getTicketById: async (id) => {
    const { data } = await apiClient.get(`/tickets/${id}`);
    return data.datos;
  },

  // Crear
  createTicket: async (ticket) => {
    const { data } = await apiClient.post('/tickets', ticket);
    return data.datos;
  },

  // Actualizar
  updateTicket: async (id, ticket) => {
    const { data } = await apiClient.put(`/tickets/${id}`, ticket);
    return data;
  },

  // Cambiar estado
  changeStatus: async (id, idEstadoNuevo, motivo) => {
    const { data } = await apiClient.patch(`/tickets/${id}/cambiar-estado`, {
      id_estado_nuevo: idEstadoNuevo,
      motivo
    });
    return data;
  },

  // Asignar
  assignTicket: async (id, usuarioId) => {
    const { data } = await apiClient.patch(`/tickets/${id}/asignar/${usuarioId}`);
    return data;
  },

  // Cerrar
  closeTicket: async (id) => {
    const { data } = await apiClient.patch(`/tickets/${id}/cerrar`);
    return data;
  }
};
```

#### References (Estados, Prioridades, etc)
```javascript
// referenceService.js
import apiClient from './api.config';

export const referenceService = {
  getEstados: async () => {
    const { data } = await apiClient.get('/references/estados');
    return data.datos;
  },

  getPrioridades: async () => {
    const { data } = await apiClient.get('/references/prioridades');
    return data.datos;
  },

  getDepartamentos: async () => {
    const { data } = await apiClient.get('/references/departamentos');
    return data.datos;
  }
};
```

#### SignalR (Notificaciones)
```javascript
// signalrService.js
import * as signalR from '@microsoft/signalr';

export class SignalRService {
  constructor() {
    this.connection = null;
  }

  connect = async (token) => {
    this.connection = new signalR.HubConnectionBuilder()
      .withUrl('https://localhost:5001/hubs/tickets', {
        accessTokenFactory: () => token
      })
      .withAutomaticReconnect()
      .withHubProtocol(new signalR.JsonHubProtocol())
      .build();

    this.connection.on('NuevoTicket', (ticket) => {
      console.log('Nuevo ticket:', ticket);
      // Emitir evento o actualizar store
    });

    this.connection.on('TicketActualizado', (ticket) => {
      console.log('Ticket actualizado:', ticket);
    });

    this.connection.on('EstadoTransicionado', (ticketId, nuevoEstado) => {
      console.log(`Ticket ${ticketId} -> ${nuevoEstado}`);
    });

    await this.connection.start();
  };

  subscribeToTicket = (ticketId) => {
    this.connection?.invoke('SubscribeToTicket', ticketId);
  };

  unsubscribeFromTicket = (ticketId) => {
    this.connection?.invoke('UnsubscribeFromTicket', ticketId);
  };

  subscribeToApprovals = () => {
    this.connection?.invoke('SubscribeToApprovals');
  };

  disconnect = async () => {
    await this.connection?.stop();
  };
}
```

### 2. C# / HttpClient

```csharp
// TicketsApiClient.cs
using System.Net.Http.Json;
using TicketsAPI.Models.DTOs;

public class TicketsApiClient
{
    private readonly HttpClient _httpClient;
    private string? _token;

    public TicketsApiClient(string baseUrl)
    {
        _httpClient = new HttpClient { BaseAddress = new Uri(baseUrl) };
    }

    // Login
    public async Task<LoginResponse?> LoginAsync(string usuario, string contraseña)
    {
        var request = new LoginRequest { Usuario = usuario, Contraseña = contraseña };
        var response = await _httpClient.PostAsJsonAsync("/api/v1/auth/login", request);
        
        if (!response.IsSuccessStatusCode)
            return null;

        var result = await response.Content.ReadAsAsync<ApiResponse<LoginResponse>>();
        _token = result?.Datos?.Token;
        
        _httpClient.DefaultRequestHeaders.Authorization = 
            new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", _token);
        
        return result?.Datos;
    }

    // Obtener tickets
    public async Task<PaginatedResponse<TicketDTO>?> GetTicketsAsync(int pagina = 1, int tamañoPagina = 20)
    {
        var response = await _httpClient.GetAsync($"/api/v1/tickets?pagina={pagina}&tamañoPagina={tamañoPagina}");
        
        if (!response.IsSuccessStatusCode)
            return null;

        var result = await response.Content.ReadAsAsync<ApiResponse<PaginatedResponse<TicketDTO>>>();
        return result?.Datos;
    }

    // Crear ticket
    public async Task<ApiResponse<object>?> CreateTicketAsync(CreateUpdateTicketDTO dto)
    {
        var response = await _httpClient.PostAsJsonAsync("/api/v1/tickets", dto);
        return await response.Content.ReadAsAsync<ApiResponse<object>>();
    }
}

// Uso
var client = new TicketsApiClient("https://localhost:5001");
var loginResult = await client.LoginAsync("usuario@empresa.com", "password");
var tickets = await client.GetTicketsAsync();
```

### 3. PowerShell

```powershell
# PowerShell Script para consumir API

$apiUrl = "https://localhost:5001/api/v1"
$usuario = "usuario@empresa.com"
$contraseña = "password123"

# Login
$loginBody = @{
    usuario = $usuario
    contraseña = $contraseña
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "$apiUrl/auth/login" `
    -Method Post `
    -ContentType "application/json" `
    -Body $loginBody

$token = $loginResponse.datos.token

# Obtener tickets
$headers = @{
    Authorization = "Bearer $token"
    "Content-Type" = "application/json"
}

$tickets = Invoke-RestMethod -Uri "$apiUrl/tickets?pagina=1" `
    -Method Get `
    -Headers $headers

$tickets.datos.datos | Format-Table Id_Ticket, Titulo, Fecha_Creacion
```

### 4. cURL

```bash
# Login
curl -X POST https://localhost:5001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"usuario":"user@empresa.com","contraseña":"password123"}' \
  -k

# Guardar token
TOKEN="eyJhbGciOiJIUzI1NiIs..."

# Obtener tickets
curl -X GET "https://localhost:5001/api/v1/tickets?pagina=1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -k

# Crear ticket
curl -X POST https://localhost:5001/api/v1/tickets \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "titulo":"Nuevo ticket",
    "descripcion":"Descripción del problema",
    "id_prioridad":2,
    "id_departamento":1
  }' \
  -k
```

### 5. Python

```python
# Python con requests
import requests
import json

class TicketsAPI:
    def __init__(self, base_url):
        self.base_url = base_url
        self.token = None
        self.session = requests.Session()

    def login(self, usuario, contraseña):
        payload = {"usuario": usuario, "contraseña": contraseña}
        response = self.session.post(
            f"{self.base_url}/api/v1/auth/login",
            json=payload,
            verify=False
        )
        data = response.json()
        self.token = data['datos']['token']
        self.session.headers.update({'Authorization': f'Bearer {self.token}'})
        return data['datos']

    def get_tickets(self, pagina=1, tamaño_pagina=20):
        response = self.session.get(
            f"{self.base_url}/api/v1/tickets",
            params={'pagina': pagina, 'tamañoPagina': tamaño_pagina},
            verify=False
        )
        return response.json()['datos']

    def create_ticket(self, titulo, descripcion, id_prioridad, id_departamento):
        payload = {
            "titulo": titulo,
            "descripcion": descripcion,
            "id_prioridad": id_prioridad,
            "id_departamento": id_departamento
        }
        response = self.session.post(
            f"{self.base_url}/api/v1/tickets",
            json=payload,
            verify=False
        )
        return response.json()

# Uso
api = TicketsAPI('https://localhost:5001')
api.login('user@empresa.com', 'password123')
tickets = api.get_tickets()
print(tickets)
```

## 🔐 Notas de Seguridad

1. **Nunca** guardar credenciales en código
2. **Siempre** usar HTTPS en producción
3. **Validar** certificados SSL (no usar `verify=False` en prod)
4. **Guardar tokens** en localStorage o sessionStorage (no cookies si es posible)
5. **Limpiar tokens** al logout
6. **Usar refresh tokens** para renovación automática

## 📊 Casos de Uso Comunes

### Filtrar tickets
```javascript
const filters = {
  id_estado: 2,           // En Proceso
  id_prioridad: 3,        // Alta
  id_departamento: 1,
  fecha_desde: '2025-12-01',
  fecha_hasta: '2025-12-31',
  pagina: 1,
  tamañoPagina: 50
};

const response = await ticketService.getTickets(filters);
```

### Cambiar estado
```javascript
try {
  await ticketService.changeStatus(
    ticketId,
    3,  // ID del nuevo estado
    'Completado exitosamente'  // Motivo
  );
  console.log('Estado actualizado');
} catch (error) {
  console.error('No tiene permiso para esta transición');
}
```

### Notificaciones en tiempo real
```javascript
const signalR = new SignalRService();
await signalR.connect(token);
signalR.subscribeToTicket(ticketId);
```

---

**Versión**: 1.0.0  
**Última Actualización**: 9 de Diciembre de 2025
