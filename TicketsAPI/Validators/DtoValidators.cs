using FluentValidation;
using TicketsAPI.Models.DTOs;

namespace TicketsAPI.Validators
{
    /// <summary>
    /// Validador para LoginRequest
    /// </summary>
    public class LoginRequestValidator : AbstractValidator<LoginRequest>
    {
        public LoginRequestValidator()
        {
            RuleFor(x => x.Usuario)
                .NotEmpty().WithMessage("El usuario es requerido")
                .Length(3, 100).WithMessage("El usuario debe tener entre 3 y 100 caracteres");

            RuleFor(x => x.Contraseña)
                .NotEmpty().WithMessage("La contraseña es requerida")
                .MinimumLength(6).WithMessage("La contraseña debe tener al menos 6 caracteres");
        }
    }

    /// <summary>
    /// Validador para RefreshTokenRequest
    /// </summary>
    public class RefreshTokenRequestValidator : AbstractValidator<RefreshTokenRequest>
    {
        public RefreshTokenRequestValidator()
        {
            RuleFor(x => x.RefreshToken)
                .NotEmpty().WithMessage("El refresh token es requerido")
                .MinimumLength(50).WithMessage("El refresh token es inválido");
        }
    }

    /// <summary>
    /// Validador para CreateUpdateUsuarioDTO
    /// </summary>
    public class CreateUpdateUsuarioDTOValidator : AbstractValidator<CreateUpdateUsuarioDTO>
    {
        public CreateUpdateUsuarioDTOValidator()
        {
            RuleFor(x => x.Nombre)
                .NotEmpty().WithMessage("El nombre es requerido")
                .Length(2, 100).WithMessage("El nombre debe tener entre 2 y 100 caracteres")
                .Matches(@"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$").WithMessage("El nombre contiene caracteres inválidos");

            RuleFor(x => x.Apellido)
                .NotEmpty().WithMessage("El apellido es requerido")
                .Length(2, 100).WithMessage("El apellido debe tener entre 2 y 100 caracteres")
                .Matches(@"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$").WithMessage("El apellido contiene caracteres inválidos");

            RuleFor(x => x.Email)
                .NotEmpty().WithMessage("El email es requerido")
                .EmailAddress().WithMessage("El email es inválido");

            RuleFor(x => x.Usuario_Correo)
                .NotEmpty().WithMessage("El usuario es requerido")
                .Length(3, 50).WithMessage("El usuario debe tener entre 3 y 50 caracteres")
                .Matches(@"^[a-zA-Z0-9._-]+$").WithMessage("El usuario contiene caracteres inválidos");

            RuleFor(x => x.Contraseña)
                .MinimumLength(6).WithMessage("La contraseña debe tener al menos 6 caracteres")
                .When(x => !string.IsNullOrEmpty(x.Contraseña));

            RuleFor(x => x.Id_Rol)
                .GreaterThan(0).WithMessage("El rol es inválido");

            RuleFor(x => x.Id_Departamento)
                .GreaterThan(0).WithMessage("El departamento es inválido")
                .When(x => x.Id_Departamento.HasValue);
        }
    }

    /// <summary>
    /// Validador para ChangePasswordDTO
    /// </summary>
    public class ChangePasswordDTOValidator : AbstractValidator<ChangePasswordDTO>
    {
        public ChangePasswordDTOValidator()
        {
            RuleFor(x => x.PasswordActual)
                .NotEmpty().WithMessage("La contraseña actual es requerida")
                .MinimumLength(6).WithMessage("La contraseña actual es inválida");

            RuleFor(x => x.PasswordNueva)
                .NotEmpty().WithMessage("La nueva contraseña es requerida")
                .MinimumLength(6).WithMessage("La nueva contraseña debe tener al menos 6 caracteres")
                .NotEqual(x => x.PasswordActual).WithMessage("La nueva contraseña no puede ser igual a la actual");
        }
    }

    /// <summary>
    /// Validador para CreateUpdateTicketDTO
    /// </summary>
    public class CreateUpdateTicketDTOValidator : AbstractValidator<CreateUpdateTicketDTO>
    {
        public CreateUpdateTicketDTOValidator()
        {
            RuleFor(x => x.Contenido)
                .NotEmpty().WithMessage("El contenido es requerido")
                .Length(10, 10000).WithMessage("El contenido debe tener entre 10 y 10000 caracteres")
                .Must(c => !ContainsSqlInjectionPatterns(c)).WithMessage("El contenido contiene caracteres no permitidos");

            RuleFor(x => x.Id_Prioridad)
                .GreaterThan(0).WithMessage("La prioridad es inválida");

            RuleFor(x => x.Id_Departamento)
                .GreaterThan(0).WithMessage("El departamento es inválido");

            RuleFor(x => x.Id_Usuario_Asignado)
                .GreaterThan(0).WithMessage("El usuario asignado es inválido")
                .When(x => x.Id_Usuario_Asignado.HasValue);

            RuleFor(x => x.Id_Motivo)
                .GreaterThan(0).WithMessage("El motivo es inválido")
                .When(x => x.Id_Motivo.HasValue);
        }

        private bool ContainsSqlInjectionPatterns(string content)
        {
            if (string.IsNullOrEmpty(content))
                return false;

            var sqlPatterns = new[] { "';", "--", "/*", "*/", "xp_", "sp_", "DROP", "DELETE", "UPDATE", "INSERT" };
            var upperContent = content.ToUpperInvariant();

            return !sqlPatterns.Any(pattern => upperContent.Contains(pattern));
        }
    }

    /// <summary>
    /// Validador para TicketFiltroDTO
    /// </summary>
    public class TicketFiltroDTOValidator : AbstractValidator<TicketFiltroDTO>
    {
        public TicketFiltroDTOValidator()
        {
            RuleFor(x => x.Busqueda)
                .MaximumLength(500).WithMessage("La búsqueda no puede exceder 500 caracteres")
                .Must(b => !ContainsSqlInjectionPatterns(b)).WithMessage("La búsqueda contiene caracteres no permitidos")
                .When(x => !string.IsNullOrEmpty(x.Busqueda));

            RuleFor(x => x.TipoBusqueda)
                .Must(t => new[] { "contiene", "exacta", "comienza", "termina" }.Contains(t?.ToLowerInvariant()))
                .WithMessage("El tipo de búsqueda es inválido")
                .When(x => !string.IsNullOrEmpty(x.TipoBusqueda));

            RuleFor(x => x.Pagina)
                .GreaterThan(0).WithMessage("La página debe ser mayor a 0");

            RuleFor(x => x.TamañoPagina)
                .GreaterThan(0).WithMessage("El tamaño de página debe ser mayor a 0")
                .LessThanOrEqualTo(100).WithMessage("El tamaño de página no puede exceder 100");

            RuleFor(x => x.Fecha_Desde)
                .LessThan(x => x.Fecha_Hasta).WithMessage("La fecha desde no puede ser mayor a la fecha hasta")
                .When(x => x.Fecha_Desde.HasValue && x.Fecha_Hasta.HasValue);
        }

        private bool ContainsSqlInjectionPatterns(string? text)
        {
            if (string.IsNullOrEmpty(text))
                return false;

            var sqlPatterns = new[] { "';", "--", "/*", "*/", "xp_", "sp_" };
            var upperText = text.ToUpperInvariant();

            return !sqlPatterns.Any(pattern => upperText.Contains(pattern));
        }
    }
}
