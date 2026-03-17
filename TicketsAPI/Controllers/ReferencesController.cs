using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Services.Interfaces;
using TicketsAPI.Services.Implementations;

namespace TicketsAPI.Controllers
{
    /// Controlador para obtener datos de referencia (Estados, Prioridades, Departamentos, Roles)
    /// Utiliza cache para mejorar performance
    [Authorize]
    public class ReferencesController : BaseApiController
    {
        private readonly IEstadoService _estadoService;
        private readonly IPrioridadService _prioridadService;
        private readonly IDepartamentoService _departamentoService;
        private readonly IRolRepository _rolRepository;
        private readonly CacheService _cacheService;

        public ReferencesController(
            ILogger<BaseApiController> logger,
            IEstadoService estadoService,
            IPrioridadService prioridadService,
            IDepartamentoService departamentoService,
            IRolRepository rolRepository,
            CacheService cacheService) : base(logger)
        {
            _estadoService = estadoService;
            _prioridadService = prioridadService;
            _departamentoService = departamentoService;
            _rolRepository = rolRepository;
            _cacheService = cacheService;
        }

        /// Obtener todos los estados activos (cached - 15 min)
        /// Para selectores de tickets — solo estados habilitados
        [AllowAnonymous]
        [HttpGet("estados")]
        [ResponseCache(Duration = 900)] // 15 minutos en el cliente
        public async Task<IActionResult> GetEstados()
        {
            try
            {
                var estados = await _cacheService.GetEstadosAsync();
                var activos = estados.Where(e => e.Activo).ToList();
                return Success(activos, "Estados obtenidos exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener estados");
                return Error<object>("Error interno del servidor", statusCode: 500);
            }
        }

        /// Obtener todas las prioridades activas (cached - 15 min)
        /// Para selectores de tickets — solo prioridades habilitadas
        [AllowAnonymous]
        [ResponseCache(Duration = 900)] // 15 minutos en el cliente
        [HttpGet("prioridades")]
        public async Task<IActionResult> GetPrioridades()
        {
            try
            {
                var prioridades = await _cacheService.GetPrioridadesAsync();
                var activos = prioridades.Where(p => p.Activo).ToList();
                return Success(activos, "Prioridades obtenidas exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener prioridades");
                return Error<object>("Error interno del servidor", statusCode: 500);
            }
        }

        /// Obtener todos los departamentos activos (cached - 15 min)
        /// Para selectores de tickets y asignaciones — solo departamentos habilitados
        [AllowAnonymous]
        [HttpGet("departamentos")]
        [ResponseCache(Duration = 900)] // 15 minutos en el cliente
        public async Task<IActionResult> GetDepartamentos()
        {
            try
            {
                var departamentos = await _cacheService.GetDepartamentosAsync();
                // Filtrar solo activos para selectores
                var activos = departamentos.Where(d => d.Activo).ToList();
                return Success(activos, "Departamentos obtenidos exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener departamentos");
                return Error<object>("Error interno del servidor", statusCode: 500);
            }
        }

        /// Obtener todos los roles
        [HttpGet("roles")]
        [ResponseCache(Duration = 900)]
        public async Task<IActionResult> GetRoles()
        {
            try
            {
                var roles = await _rolRepository.GetAllAsync();
                return Success(roles, "Roles obtenidos exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener roles");
                return Error<object>("Error interno del servidor", statusCode: 500);
            }
        }
    }
}
