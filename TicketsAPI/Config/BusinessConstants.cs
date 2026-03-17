namespace TicketsAPI.Config
{
    /// Constantes de estados del ciclo de vida del ticket.
    /// Centralizan los IDs de estado para evitar magic numbers en servicios y controladores.
    public static class TicketStates
    {
        /// Estado inicial al crear un ticket (DB: 1 = Abierto).
        public const int Abierto = 1;

        /// Ticket en proceso de resolución (DB: 2 = En Proceso).
        public const int EnProceso = 2;

        /// <summary>Ticket cerrado (DB: 3 = Cerrado)</summary>
        public const int Cerrado = 3;

        /// <summary>Ticket en espera de información (DB: 4 = En Espera)</summary>
        public const int EnEspera = 4;

        /// <summary>Ticket pendiente de aprobación (DB: 5 = Pendiente Aprobación)</summary>
        public const int PendienteAprobacion = 5;

        /// <summary>Ticket resuelto (DB: 6 = Resuelto)</summary>
        public const int Resuelto = 6;

        /// <summary>Ticket reabierto (DB: 7 = Reabierto)</summary>
        public const int Reabierto = 7;
    }

    /// <summary>
    /// Constantes de roles del sistema.
    /// Centralizan los IDs y nombres de rol para evitar IDs/strings hardcoded.
    /// </summary>
    public static class UserRoles
    {
        // IDs numéricos (deben coincidir con tabla rol)
        public const int SupervisorId = 1;
        public const int AgenteId = 2;
        public const int OperadorId = 3;
        public const int AdminId = 10;

        // Nombres (deben coincidir con los claims JWT / tabla rol)
        public const string Admin = "Administrador";
        public const string Supervisor = "Supervisor";
        public const string Agente = "Agente";
        public const string Operador = "Operador";

        // Códigos DB (campo tipo en tabla usuario)
        public const string AdminCode = "ADM";
        public const string SupervisorCode = "SUP";
        public const string AgenteCode = "AGE";
        public const string OperadorCode = "OPE";
    }
}
