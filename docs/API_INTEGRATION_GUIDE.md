# Guía de Integración - TicketsAPI REST

## 📋 Índice

1. [Información General](#información-general)
2. [Autenticación](#autenticación)
3. [Endpoints Disponibles](#endpoints-disponibles)
4. [Ejemplos de Integración](#ejemplos-de-integración)
5. [Códigos de Respuesta HTTP](#códigos-de-respuesta-http)
6. [Pruebas con Herramientas](#pruebas-con-herramientas)
7. [Manejo de Errores](#manejo-de-errores)

---

## Información General

### Base URL
```
http://localhost:5000/api
https://localhost:5001/api
```

### Formato de Datos
- **Content-Type:** `application/json`
- **Accept:** `application/json`
- **Encoding:** UTF-8

### Autenticación
Sistema basado en **JWT (JSON Web Tokens)**. Todos los endpoints excepto `/auth/login` requieren token válido.

---

## Autenticación

### 1. Login (Obtener Token)

**Endpoint:** `POST /api/auth/login`

**Request:**
```json
{
  "usuario": "admin",
  "contraseña": "password123"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Login exitoso",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "usuario": {
      "id_Usuario": 1,
      "nombre": "admin",
      "email": "admin@example.com",
      "id_Rol": 1
    }
  },
  "errors": []
}
```

**Ejemplo cURL:**
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "usuario": "admin",
    "contraseña": "password123"
  }'
```

**Ejemplo PowerShell:**
```powershell
$body = @{
    usuario = "admin"
    contraseña = "password123"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:5000/api/auth/login" `
    -Method Post `
    -ContentType "application/json" `
    -Body $body

$token = $response.data.token
```

---

## Endpoints Disponibles

### 📋 Tickets

#### Listar Tickets (Filtrados)

**Endpoint:** `GET /api/tickets`

**Headers:**
```
Authorization: Bearer {token}
```

**Query Parameters:**
| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `Id_Estado` | int | No | Filtrar por estado (1=Abierto, 2=En Proceso, etc.) |
| `Id_Prioridad` | int | No | Filtrar por prioridad |
| `Id_Departamento` | int | No | Filtrar por departamento |
| `Id_Motivo` | int | No | Filtrar por motivo |
| `Fecha_Desde` | date | No | Filtrar desde fecha (YYYY-MM-DD) |
| `Fecha_Hasta` | date | No | Filtrar hasta fecha (YYYY-MM-DD) |
| `Busqueda` | string | No | Búsqueda en contenido |
| `Pagina` | int | No | Número de página (default: 1) |
| `TamañoPagina` | int | No | Registros por página (default: 10, max: 100) |

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Tickets obtenidos exitosamente",
  "data": {
    "datos": [
      {
        "id_Tkt": 1,
        "contenido": "Error en sistema de login",
        "id_Estado": 1,
        "nombre_Estado": "Abierto",
        "id_Prioridad": 3,
        "nombre_Prioridad": "Alta",
        "id_Departamento": 2,
        "nombre_Departamento": "Soporte TI",
        "date_Creado": "2025-12-15T10:30:00",
        "id_Usuario": 5,
        "nombre_Usuario": "Juan Pérez"
      }
    ],
    "totalRegistros": 45,
    "totalPaginas": 5,
    "paginaActual": 1,
    "tamañoPagina": 10,
    "tienePaginaAnterior": false,
    "tienePaginaSiguiente": true
  },
  "errors": []
}
```

**Ejemplo cURL:**
```bash
curl -X GET "http://localhost:5000/api/tickets?Id_Estado=1&Pagina=1&TamañoPagina=10" \
  -H "Authorization: Bearer {token}"
```

**Ejemplo PowerShell:**
```powershell
$headers = @{
    Authorization = "Bearer $token"
}

$params = @{
    Id_Estado = 1
    Pagina = 1
    TamañoPagina = 10
}

$queryString = ($params.GetEnumerator() | ForEach-Object { 
    "$($_.Key)=$($_.Value)" 
}) -join "&"

$response = Invoke-RestMethod -Uri "http://localhost:5000/api/tickets?$queryString" `
    -Method Get `
    -Headers $headers
```

---

#### Obtener Ticket por ID

**Endpoint:** `GET /api/tickets/{id}`

**Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Ticket obtenido exitosamente",
  "data": {
    "id_Tkt": 1,
    "contenido": "Error en sistema de login",
    "id_Estado": 1,
    "estado": {
      "id_Estado": 1,
      "nombre_Estado": "Abierto",
      "color": "#FF0000",
      "orden": 1
    },
    "id_Prioridad": 3,
    "prioridad": {
      "id_Prioridad": 3,
      "nombre_Prioridad": "Alta"
    },
    "id_Departamento": 2,
    "departamento": {
      "id_Departamento": 2,
      "nombre": "Soporte TI"
    },
    "date_Creado": "2025-12-15T10:30:00",
    "id_Usuario": 5,
    "id_Usuario_Asignado": 10
  },
  "errors": []
}
```

**Ejemplo cURL:**
```bash
curl -X GET http://localhost:5000/api/tickets/1 \
  -H "Authorization: Bearer {token}"
```

---

#### Crear Ticket

**Endpoint:** `POST /api/tickets`

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "contenido": "Descripción detallada del problema o solicitud",
  "id_Prioridad": 2,
  "id_Departamento": 3,
  "id_Motivo": 5,
  "id_Usuario_Asignado": 10
}
```

**Validaciones:**
- `contenido`: Requerido, mínimo 10 caracteres, máximo 10000
- `id_Prioridad`: Requerido, debe existir en BD
- `id_Departamento`: Requerido, debe existir en BD
- `id_Motivo`: Opcional, si se proporciona debe existir en BD
- `id_Usuario_Asignado`: Opcional, si se proporciona debe existir en BD

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Ticket creado exitosamente",
  "data": {
    "id": 123
  },
  "errors": []
}
```

**Ejemplo cURL:**
```bash
curl -X POST http://localhost:5000/api/tickets \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "contenido": "No puedo acceder al sistema de reportes",
    "id_Prioridad": 2,
    "id_Departamento": 1,
    "id_Motivo": 3
  }'
```

**Ejemplo JavaScript (fetch):**
```javascript
const token = localStorage.getItem('authToken');

const createTicket = async (ticketData) => {
  const response = await fetch('http://localhost:5000/api/tickets', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(ticketData)
  });
  
  return await response.json();
};

// Uso
const newTicket = {
  contenido: "Error al cargar dashboard",
  id_Prioridad: 2,
  id_Departamento: 1
};

createTicket(newTicket)
  .then(result => console.log('Ticket creado:', result.data.id))
  .catch(error => console.error('Error:', error));
```

---

#### Actualizar Ticket

**Endpoint:** `PUT /api/tickets/{id}`

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Permisos Requeridos:**
- Usuario con permiso `TKT_EDIT_ANY`: puede editar cualquier ticket
- Usuario con permiso `TKT_EDIT_ASSIGNED`: solo puede editar tickets creados por él o asignados a él

**Request Body:**
```json
{
  "contenido": "Contenido actualizado del ticket",
  "id_Prioridad": 3,
  "id_Departamento": 2,
  "id_Motivo": 4,
  "id_Usuario_Asignado": 15
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Ticket actualizado exitosamente",
  "data": {},
  "errors": []
}
```

**Response (403 Forbidden):**
```json
{
  "success": false,
  "message": "Solo puedes editar tickets creados por ti o asignados a ti",
  "data": null,
  "errors": []
}
```

**Response (404 Not Found):**
```json
{
  "success": false,
  "message": "El ticket con ID 999 no existe",
  "data": null,
  "errors": []
}
```

**Ejemplo cURL:**
```bash
curl -X PUT http://localhost:5000/api/tickets/123 \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "contenido": "Actualización: problema resuelto parcialmente",
    "id_Prioridad": 1,
    "id_Departamento": 2
  }'
```

---

#### Asignar Ticket

**Endpoint:** `POST /api/tickets/{id}/assign`

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "idUsuarioAsignado": 10
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Ticket asignado exitosamente",
  "data": {},
  "errors": []
}
```

**Response (404 Not Found):**
```json
{
  "success": false,
  "message": "El ticket con ID 999 no existe",
  "data": null,
  "errors": []
}
```

**Ejemplo cURL:**
```bash
curl -X POST http://localhost:5000/api/tickets/123/assign \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"idUsuarioAsignado": 10}'
```

---

#### Cerrar Ticket

**Endpoint:** `POST /api/tickets/{id}/close`

**Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Ticket cerrado exitosamente",
  "data": {},
  "errors": []
}
```

**Response (404 Not Found):**
```json
{
  "success": false,
  "message": "El ticket con ID 999 no existe",
  "data": null,
  "errors": []
}
```

**Ejemplo cURL:**
```bash
curl -X POST http://localhost:5000/api/tickets/123/close \
  -H "Authorization: Bearer {token}"
```

---

### 💬 Comentarios

#### Obtener Comentarios de un Ticket

**Endpoint:** `GET /api/comentarios/ticket/{idTicket}`

**Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Comentarios obtenidos exitosamente",
  "data": [
    {
      "id_Comentario": 1,
      "id_Tkt": 123,
      "id_Usuario": 5,
      "nombre_Usuario": "Juan Pérez",
      "comentario": "Se está investigando el problema",
      "fecha_Comentario": "2025-12-15T14:30:00"
    }
  ],
  "errors": []
}
```

**Ejemplo cURL:**
```bash
curl -X GET http://localhost:5000/api/comentarios/ticket/123 \
  -H "Authorization: Bearer {token}"
```

---

#### Crear Comentario

**Endpoint:** `POST /api/comentarios/ticket/{idTicket}`

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "comentario": "Texto del comentario"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Comentario creado exitosamente",
  "data": {
    "id": 45
  },
  "errors": []
}
```

**Ejemplo cURL:**
```bash
curl -X POST http://localhost:5000/api/comentarios/ticket/123 \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"comentario": "Actualización del estado del ticket"}'
```

---

### 📊 Referencias

#### Obtener Prioridades

**Endpoint:** `GET /api/references/prioridades`

**Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Prioridades obtenidas exitosamente",
  "data": [
    {
      "id_Prioridad": 1,
      "nombre_Prioridad": "Baja"
    },
    {
      "id_Prioridad": 2,
      "nombre_Prioridad": "Media"
    },
    {
      "id_Prioridad": 3,
      "nombre_Prioridad": "Alta"
    },
    {
      "id_Prioridad": 4,
      "nombre_Prioridad": "Crítica"
    }
  ],
  "errors": []
}
```

---

#### Obtener Departamentos

**Endpoint:** `GET /api/references/departamentos`

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Departamentos obtenidos exitosamente",
  "data": [
    {
      "id_Departamento": 1,
      "nombre": "Soporte Técnico"
    },
    {
      "id_Departamento": 2,
      "nombre": "Desarrollo"
    }
  ],
  "errors": []
}
```

---

#### Obtener Estados

**Endpoint:** `GET /api/references/estados`

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Estados obtenidos exitosamente",
  "data": [
    {
      "id_Estado": 1,
      "nombre_Estado": "Abierto",
      "color": "#FF5733",
      "orden": 1
    },
    {
      "id_Estado": 2,
      "nombre_Estado": "En Proceso",
      "color": "#FFC300",
      "orden": 2
    },
    {
      "id_Estado": 5,
      "nombre_Estado": "Cerrado",
      "color": "#28A745",
      "orden": 5
    }
  ],
  "errors": []
}
```

---

## Ejemplos de Integración

### Flujo Completo con C# (.NET)

```csharp
using System;
using System.Net.Http;
using System.Net.Http.Json;
using System.Threading.Tasks;

public class TicketsApiClient
{
    private readonly HttpClient _httpClient;
    private string _token;

    public TicketsApiClient(string baseUrl)
    {
        _httpClient = new HttpClient { BaseAddress = new Uri(baseUrl) };
    }

    public async Task<bool> LoginAsync(string usuario, string contraseña)
    {
        var loginData = new { usuario, contraseña };
        var response = await _httpClient.PostAsJsonAsync("/api/auth/login", loginData);
        
        if (response.IsSuccessStatusCode)
        {
            var result = await response.Content.ReadFromJsonAsync<ApiResponse<LoginData>>();
            _token = result.Data.Token;
            _httpClient.DefaultRequestHeaders.Authorization = 
                new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", _token);
            return true;
        }
        return false;
    }

    public async Task<int?> CreateTicketAsync(CreateTicketDto ticket)
    {
        var response = await _httpClient.PostAsJsonAsync("/api/tickets", ticket);
        
        if (response.IsSuccessStatusCode)
        {
            var result = await response.Content.ReadFromJsonAsync<ApiResponse<CreatedTicket>>();
            return result.Data.Id;
        }
        return null;
    }

    public async Task<List<TicketDto>> GetTicketsAsync(int? estado = null, int pagina = 1)
    {
        var queryString = $"?Pagina={pagina}&TamañoPagina=20";
        if (estado.HasValue)
            queryString += $"&Id_Estado={estado.Value}";
            
        var response = await _httpClient.GetAsync($"/api/tickets{queryString}");
        
        if (response.IsSuccessStatusCode)
        {
            var result = await response.Content.ReadFromJsonAsync<ApiResponse<PaginatedData<TicketDto>>>();
            return result.Data.Datos;
        }
        return new List<TicketDto>();
    }
}

// Uso
var client = new TicketsApiClient("http://localhost:5000");
await client.LoginAsync("admin", "password123");

var newTicketId = await client.CreateTicketAsync(new CreateTicketDto
{
    Contenido = "Error en el sistema",
    Id_Prioridad = 2,
    Id_Departamento = 1
});

var tickets = await client.GetTicketsAsync(estado: 1);
```

---

### Flujo Completo con Python

```python
import requests
from typing import Optional, List, Dict

class TicketsAPIClient:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.token = None
        self.session = requests.Session()
    
    def login(self, usuario: str, contraseña: str) -> bool:
        """Autenticar y obtener token JWT"""
        url = f"{self.base_url}/api/auth/login"
        data = {
            "usuario": usuario,
            "contraseña": contraseña
        }
        
        response = self.session.post(url, json=data)
        
        if response.status_code == 200:
            result = response.json()
            self.token = result['data']['token']
            self.session.headers.update({
                'Authorization': f'Bearer {self.token}'
            })
            return True
        return False
    
    def create_ticket(self, contenido: str, prioridad: int, 
                     departamento: int, motivo: Optional[int] = None) -> Optional[int]:
        """Crear un nuevo ticket"""
        url = f"{self.base_url}/api/tickets"
        data = {
            "contenido": contenido,
            "id_Prioridad": prioridad,
            "id_Departamento": departamento
        }
        
        if motivo:
            data["id_Motivo"] = motivo
        
        response = self.session.post(url, json=data)
        
        if response.status_code == 201:
            result = response.json()
            return result['data']['id']
        return None
    
    def get_tickets(self, estado: Optional[int] = None, 
                   pagina: int = 1, tamaño: int = 20) -> List[Dict]:
        """Obtener lista de tickets"""
        url = f"{self.base_url}/api/tickets"
        params = {
            "Pagina": pagina,
            "TamañoPagina": tamaño
        }
        
        if estado:
            params["Id_Estado"] = estado
        
        response = self.session.get(url, params=params)
        
        if response.status_code == 200:
            result = response.json()
            return result['data']['datos']
        return []
    
    def get_ticket(self, ticket_id: int) -> Optional[Dict]:
        """Obtener ticket por ID"""
        url = f"{self.base_url}/api/tickets/{ticket_id}"
        response = self.session.get(url)
        
        if response.status_code == 200:
            result = response.json()
            return result['data']
        return None
    
    def update_ticket(self, ticket_id: int, contenido: str, 
                     prioridad: int, departamento: int) -> bool:
        """Actualizar ticket existente"""
        url = f"{self.base_url}/api/tickets/{ticket_id}"
        data = {
            "contenido": contenido,
            "id_Prioridad": prioridad,
            "id_Departamento": departamento
        }
        
        response = self.session.put(url, json=data)
        return response.status_code == 200
    
    def add_comment(self, ticket_id: int, comentario: str) -> Optional[int]:
        """Agregar comentario a un ticket"""
        url = f"{self.base_url}/api/comentarios/ticket/{ticket_id}"
        data = {"comentario": comentario}
        
        response = self.session.post(url, json=data)
        
        if response.status_code == 201:
            result = response.json()
            return result['data']['id']
        return None
    
    def get_references(self, tipo: str) -> List[Dict]:
        """Obtener datos de referencia (prioridades, departamentos, estados)"""
        url = f"{self.base_url}/api/references/{tipo}"
        response = self.session.get(url)
        
        if response.status_code == 200:
            result = response.json()
            return result['data']
        return []

# Ejemplo de uso
if __name__ == "__main__":
    client = TicketsAPIClient("http://localhost:5000")
    
    # 1. Login
    if client.login("admin", "password123"):
        print("✅ Login exitoso")
        
        # 2. Obtener referencias
        prioridades = client.get_references("prioridades")
        departamentos = client.get_references("departamentos")
        print(f"📊 Prioridades: {len(prioridades)}")
        print(f"📊 Departamentos: {len(departamentos)}")
        
        # 3. Crear ticket
        ticket_id = client.create_ticket(
            contenido="Sistema lento en módulo de reportes",
            prioridad=2,
            departamento=1
        )
        print(f"🎫 Ticket creado: #{ticket_id}")
        
        # 4. Agregar comentario
        comment_id = client.add_comment(ticket_id, "Iniciando investigación")
        print(f"💬 Comentario agregado: #{comment_id}")
        
        # 5. Listar tickets abiertos
        tickets = client.get_tickets(estado=1)
        print(f"📋 Tickets abiertos: {len(tickets)}")
        
        for ticket in tickets[:3]:
            print(f"  - Ticket #{ticket['id_Tkt']}: {ticket['contenido'][:50]}...")
    else:
        print("❌ Error en login")
```

---

### Flujo Completo con JavaScript/Node.js

```javascript
const axios = require('axios');

class TicketsAPIClient {
  constructor(baseURL) {
    this.client = axios.create({
      baseURL,
      headers: {
        'Content-Type': 'application/json'
      }
    });
  }

  async login(usuario, contraseña) {
    try {
      const response = await this.client.post('/api/auth/login', {
        usuario,
        contraseña
      });
      
      this.token = response.data.data.token;
      this.client.defaults.headers.common['Authorization'] = `Bearer ${this.token}`;
      return true;
    } catch (error) {
      console.error('Login failed:', error.response?.data || error.message);
      return false;
    }
  }

  async createTicket(ticketData) {
    try {
      const response = await this.client.post('/api/tickets', ticketData);
      return response.data.data.id;
    } catch (error) {
      console.error('Create ticket failed:', error.response?.data || error.message);
      return null;
    }
  }

  async getTickets(filters = {}) {
    try {
      const response = await this.client.get('/api/tickets', { params: filters });
      return response.data.data;
    } catch (error) {
      console.error('Get tickets failed:', error.response?.data || error.message);
      return null;
    }
  }

  async getTicket(id) {
    try {
      const response = await this.client.get(`/api/tickets/${id}`);
      return response.data.data;
    } catch (error) {
      console.error('Get ticket failed:', error.response?.data || error.message);
      return null;
    }
  }

  async updateTicket(id, ticketData) {
    try {
      const response = await this.client.put(`/api/tickets/${id}`, ticketData);
      return response.data.success;
    } catch (error) {
      console.error('Update ticket failed:', error.response?.data || error.message);
      return false;
    }
  }

  async addComment(ticketId, comentario) {
    try {
      const response = await this.client.post(`/api/comentarios/ticket/${ticketId}`, {
        comentario
      });
      return response.data.data.id;
    } catch (error) {
      console.error('Add comment failed:', error.response?.data || error.message);
      return null;
    }
  }

  async getReferences(type) {
    try {
      const response = await this.client.get(`/api/references/${type}`);
      return response.data.data;
    } catch (error) {
      console.error('Get references failed:', error.response?.data || error.message);
      return [];
    }
  }
}

// Ejemplo de uso
(async () => {
  const client = new TicketsAPIClient('http://localhost:5000');
  
  // 1. Login
  const loginSuccess = await client.login('admin', 'password123');
  if (!loginSuccess) {
    console.log('❌ Login failed');
    return;
  }
  console.log('✅ Login successful');
  
  // 2. Obtener referencias
  const prioridades = await client.getReferences('prioridades');
  const departamentos = await client.getReferences('departamentos');
  console.log(`📊 Prioridades: ${prioridades.length}`);
  console.log(`📊 Departamentos: ${departamentos.length}`);
  
  // 3. Crear ticket
  const ticketId = await client.createTicket({
    contenido: 'Error al generar reportes mensuales',
    id_Prioridad: 2,
    id_Departamento: 1
  });
  console.log(`🎫 Ticket creado: #${ticketId}`);
  
  // 4. Agregar comentario
  const commentId = await client.addComment(ticketId, 'Asignado a equipo técnico');
  console.log(`💬 Comentario agregado: #${commentId}`);
  
  // 5. Listar tickets
  const result = await client.getTickets({ Id_Estado: 1, Pagina: 1, TamañoPagina: 10 });
  console.log(`📋 Tickets abiertos: ${result.totalRegistros}`);
  
  result.datos.forEach(ticket => {
    console.log(`  - #${ticket.id_Tkt}: ${ticket.contenido.substring(0, 50)}...`);
  });
})();
```

---

## Códigos de Respuesta HTTP

| Código | Significado | Cuándo se usa |
|--------|-------------|---------------|
| **200** | OK | Operación exitosa (GET, PUT, POST sin creación) |
| **201** | Created | Recurso creado exitosamente (POST) |
| **400** | Bad Request | Datos inválidos, validación fallida |
| **401** | Unauthorized | Token ausente, inválido o expirado |
| **403** | Forbidden | Usuario sin permisos para la operación |
| **404** | Not Found | Recurso no encontrado |
| **500** | Internal Server Error | Error del servidor |

---

## Pruebas con Herramientas

### Postman

1. **Importar colección:**

Crear archivo `TicketsAPI.postman_collection.json`:

```json
{
  "info": {
    "name": "TicketsAPI",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "auth": {
    "type": "bearer",
    "bearer": [
      {
        "key": "token",
        "value": "{{jwt_token}}",
        "type": "string"
      }
    ]
  },
  "item": [
    {
      "name": "Auth",
      "item": [
        {
          "name": "Login",
          "event": [
            {
              "listen": "test",
              "script": {
                "exec": [
                  "if (pm.response.code === 200) {",
                  "    var jsonData = pm.response.json();",
                  "    pm.environment.set('jwt_token', jsonData.data.token);",
                  "}"
                ]
              }
            }
          ],
          "request": {
            "method": "POST",
            "header": [],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"usuario\": \"admin\",\n  \"contraseña\": \"password123\"\n}",
              "options": {
                "raw": {
                  "language": "json"
                }
              }
            },
            "url": {
              "raw": "{{base_url}}/api/auth/login",
              "host": ["{{base_url}}"],
              "path": ["api", "auth", "login"]
            }
          }
        }
      ]
    },
    {
      "name": "Tickets",
      "item": [
        {
          "name": "Get Tickets",
          "request": {
            "method": "GET",
            "header": [],
            "url": {
              "raw": "{{base_url}}/api/tickets?Pagina=1&TamañoPagina=10",
              "host": ["{{base_url}}"],
              "path": ["api", "tickets"],
              "query": [
                {
                  "key": "Pagina",
                  "value": "1"
                },
                {
                  "key": "TamañoPagina",
                  "value": "10"
                }
              ]
            }
          }
        },
        {
          "name": "Create Ticket",
          "request": {
            "method": "POST",
            "header": [],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"contenido\": \"Error en sistema de facturación\",\n  \"id_Prioridad\": 3,\n  \"id_Departamento\": 1\n}",
              "options": {
                "raw": {
                  "language": "json"
                }
              }
            },
            "url": {
              "raw": "{{base_url}}/api/tickets",
              "host": ["{{base_url}}"],
              "path": ["api", "tickets"]
            }
          }
        }
      ]
    }
  ],
  "variable": [
    {
      "key": "base_url",
      "value": "http://localhost:5000",
      "type": "string"
    }
  ]
}
```

2. **Configurar entorno:**
   - Crear variable `base_url`: `http://localhost:5000`
   - Crear variable `jwt_token`: (se auto-completa al hacer login)

---

### Insomnia

**Crear Workspace:**

1. New Request → POST → `http://localhost:5000/api/auth/login`
2. Body (JSON):
```json
{
  "usuario": "admin",
  "contraseña": "password123"
}
```
3. Copiar token del response
4. Crear nueva Request → GET → `http://localhost:5000/api/tickets`
5. Header: `Authorization: Bearer {token}`

---

### cURL - Script de Prueba Completo

```bash
#!/bin/bash

BASE_URL="http://localhost:5000/api"

# 1. Login
echo "🔐 Iniciando login..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"usuario":"admin","contraseña":"password123"}')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.data.token')

if [ "$TOKEN" == "null" ]; then
  echo "❌ Login failed"
  exit 1
fi

echo "✅ Token obtenido: ${TOKEN:0:20}..."

# 2. Obtener prioridades
echo ""
echo "📊 Obteniendo prioridades..."
curl -s -X GET "$BASE_URL/references/prioridades" \
  -H "Authorization: Bearer $TOKEN" | jq '.data[] | {id: .id_Prioridad, nombre: .nombre_Prioridad}'

# 3. Crear ticket
echo ""
echo "🎫 Creando ticket..."
CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/tickets" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "contenido": "Test desde cURL - Error en módulo de reportes",
    "id_Prioridad": 2,
    "id_Departamento": 1
  }')

TICKET_ID=$(echo $CREATE_RESPONSE | jq -r '.data.id')
echo "✅ Ticket creado: #$TICKET_ID"

# 4. Obtener ticket
echo ""
echo "📋 Obteniendo ticket #$TICKET_ID..."
curl -s -X GET "$BASE_URL/tickets/$TICKET_ID" \
  -H "Authorization: Bearer $TOKEN" | jq '.data | {id: .id_Tkt, contenido, estado: .estado.nombre_Estado}'

# 5. Listar tickets
echo ""
echo "📋 Listando tickets..."
curl -s -X GET "$BASE_URL/tickets?Pagina=1&TamañoPagina=5" \
  -H "Authorization: Bearer $TOKEN" | jq '.data | {total: .totalRegistros, paginas: .totalPaginas, tickets: .datos[] | {id: .id_Tkt, contenido}}'

echo ""
echo "✅ Pruebas completadas"
```

---

## Manejo de Errores

### Estructura de Respuestas de Error

**Formato estándar:**
```json
{
  "success": false,
  "message": "Descripción del error",
  "data": null,
  "errors": ["Detalle 1", "Detalle 2"]
}
```

### Ejemplos de Errores Comunes

#### 1. Token Ausente o Inválido (401)
```json
{
  "success": false,
  "message": "Usuario no autenticado",
  "data": null,
  "errors": []
}
```

**Solución:** Verificar que el header `Authorization: Bearer {token}` esté presente y sea válido.

---

#### 2. Token Expirado (401)
```json
{
  "success": false,
  "message": "Token expirado",
  "data": null,
  "errors": []
}
```

**Solución:** Realizar login nuevamente para obtener un nuevo token.

---

#### 3. Permisos Insuficientes (403)
```json
{
  "success": false,
  "message": "No tienes permisos para editar tickets",
  "data": null,
  "errors": []
}
```

**Solución:** Verificar que el usuario tenga los permisos necesarios (`TKT_EDIT_ANY` o `TKT_EDIT_ASSIGNED`).

---

#### 4. Validación de Datos (400)
```json
{
  "success": false,
  "message": "Datos inválidos",
  "data": null,
  "errors": [
    "El campo Contenido es requerido",
    "El campo Contenido debe tener al menos 10 caracteres"
  ]
}
```

**Solución:** Corregir los datos del request según los mensajes de error.

---

#### 5. Recurso No Encontrado (404)
```json
{
  "success": false,
  "message": "El ticket con ID 999 no existe",
  "data": null,
  "errors": []
}
```

**Solución:** Verificar que el ID del recurso sea correcto.

---

#### 6. Error de FK (400)
```json
{
  "success": false,
  "message": "La prioridad con ID 99 no existe",
  "data": null,
  "errors": []
}
```

**Solución:** Usar IDs válidos obtenidos de los endpoints de referencias.

---

## Límites y Restricciones

| Límite | Valor | Descripción |
|--------|-------|-------------|
| **Tamaño máximo request** | 10 MB | Límite general de payload |
| **Longitud contenido ticket** | 10-10000 chars | Validación en CreateUpdateTicketDTO |
| **Registros por página** | 1-100 | TamañoPagina en filtros |
| **Timeout de token JWT** | 24 horas | Después se requiere re-login |
| **Rate limiting** | No implementado | Sin límite actual |

---

## Notas de Seguridad

1. **HTTPS en Producción:** Usar siempre HTTPS en ambientes productivos
2. **Almacenamiento de Tokens:** NO almacenar tokens en localStorage si es posible XSS
3. **Renovación de Tokens:** Implementar refresh token en cliente
4. **Logs:** Evitar loguear tokens o contraseñas
5. **CORS:** Configurar correctamente dominios permitidos

---

## Troubleshooting

### Problema: "Connection refused"
**Causa:** API no está corriendo  
**Solución:** Ejecutar `dotnet run --project TicketsAPI`

### Problema: "401 Unauthorized" después de login exitoso
**Causa:** Token no se está enviando correctamente  
**Solución:** Verificar header `Authorization: Bearer {token}` con espacio correcto

### Problema: "403 Forbidden" al editar ticket
**Causa:** Usuario sin permisos  
**Solución:** 
- Verificar que sea creador o asignado del ticket
- O tener permiso `TKT_EDIT_ANY`

### Problema: "400 Bad Request" con mensaje genérico
**Causa:** Validación de modelo fallida  
**Solución:** Revisar `errors[]` en response para detalles específicos

---

## Soporte y Contacto

**Repositorio:** [GitHub - TicketsAPI](https://github.com/tu-repo/TicketsAPI)  
**Documentación Técnica:** Ver `TICKETS_API_ANALYSIS.md`  
**Base de Datos:** MySQL 5.5+  
**Framework:** ASP.NET Core 6.0

---

**Última actualización:** 2 de enero de 2026
