using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace TicketsAPI.Config
{
    /// Filter para agregar descripciones a los tags de Swagger
    public class SwaggerTagDescriptionsDocumentFilter : IDocumentFilter
    {
        public void Apply(OpenApiDocument swaggerDoc, DocumentFilterContext context)
        {
            swaggerDoc.Tags = new List<OpenApiTag>
            {
                new OpenApiTag
                {
                    Name = "Admin",
                    Description = "Endpoints administrativos para gestión de usuarios, roles y permisos"
                },
                new OpenApiTag
                {
                    Name = "Aprobaciones",
                    Description = "Gestión de aprobaciones de tickets (solicitud, respuesta, historial)"
                },
                new OpenApiTag
                {
                    Name = "Auth",
                    Description = "Autenticación y autorización (login, logout, refresh token)"
                },
                new OpenApiTag
                {
                    Name = "Comentarios",
                    Description = "Gestión de comentarios en tickets (crear, editar, eliminar, listar)"
                },
                new OpenApiTag
                {
                    Name = "Departamentos",
                    Description = "CRUD de departamentos de la organización"
                },
                new OpenApiTag
                {
                    Name = "Grupos",
                    Description = "Gestión de grupos de usuarios y permisos"
                },
                new OpenApiTag
                {
                    Name = "Motivos",
                    Description = "Catálogo de motivos/categorías de tickets"
                },
                new OpenApiTag
                {
                    Name = "References",
                    Description = "Datos de referencia cacheados (Estados, Prioridades, Departamentos)"
                },
                new OpenApiTag
                {
                    Name = "Reportes",
                    Description = "Analytics y reportes (Dashboard, por Estado, Prioridad, Departamento, Tendencias)"
                },
                new OpenApiTag
                {
                    Name = "StoredProcedures",
                    Description = "Acceso directo a stored procedures de la base de datos"
                },
                new OpenApiTag
                {
                    Name = "Tickets",
                    Description = "Gestión completa de tickets (CRUD, búsqueda avanzada, exportación CSV, transiciones)"
                },
                new OpenApiTag
                {
                    Name = "Transiciones",
                    Description = "Gestión de transiciones de estado de tickets"
                }
            };
        }
    }
}
