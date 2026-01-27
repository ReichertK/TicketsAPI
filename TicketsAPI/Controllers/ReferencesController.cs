using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TicketsAPI.Services.Interfaces;
using TicketsAPI.Services.Implementations;

namespace TicketsAPI.Controllers
{
    /// <summary>
    /// Controlador para obtener datos de referencia (Estados, Prioridades, Departamentos)
    /// Utiliza cache para mejorar performance
    /// </summary>
    [Authorize]
    public class ReferencesController : BaseApiController
    {
        private readonly IEstadoService _estadoService;
        private readonly IPrioridadService _prioridadService;
        private readonly IDepartamentoService _departamentoService;
        private readonly CacheService _cacheService;

        public ReferencesController(
            ILogger<BaseApiController> logger,
            IEstadoService estadoService,
            IPrioridadService prioridadService,
            IDepartamentoService departamentoService,
            CacheService cacheService) : base(logger)
        {
            _estadoService = estadoService;
            _prioridadService = prioridadService;
            _departamentoService = departamentoService;
            _cacheService = cacheService;
        }

        /// <summary>
        /// Obtener todos los estados (cached - 15 min)
        /// </summary>
        [AllowAnonymous]
        [HttpGet("estados")]
        [ResponseCache(Duration = 900)] // 15 minutos en el cliente
        public async Task<IActionResult> GetEstados()
        {
            try
            {
                var estados = await _cacheService.GetEstadosAsync();
                return Success(estados, "Estados obtenidos exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener estados");
                return Error<object>("Error interno del servidor", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Obtener todas las prioridades (cached - 15 min)
        /// </summary>
        [AllowAnonymous]
        [ResponseCache(Duration = 900)] // 15 minutos en el cliente
        [HttpGet("prioridades")]
        public async Task<IActionResult> GetPrioridades()
        {
            try
            {
                var prioridades = await _cacheService.GetPrioridadesAsync();
                return Success(prioridades, "Prioridades obtenidas exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener prioridades");
                return Error<object>("Error interno del servidor", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Obtener todos los departamentos (cached - 15 min)
        /// </summary>
        [AllowAnonymous]
        [HttpGet("departamentos")]
        [ResponseCache(Duration = 900)] // 15 minutos en el cliente
        public async Task<IActionResult> GetDepartamentos()
        {
            try
            {
                var departamentos = await _cacheService.GetDepartamentosAsync();
                return Success(departamentos, "Departamentos obtenidos exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener departamentos");
                return Error<object>("Error interno del servidor", new List<string> { ex.Message }, 500);
            }
        }
    }
}

// NOTA: Crear interfaces IPrioridadService y IDepartamentoService cuando sea necesario
