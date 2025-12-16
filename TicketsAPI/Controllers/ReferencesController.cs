using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TicketsAPI.Services.Interfaces;

namespace TicketsAPI.Controllers
{
    /// <summary>
    /// Controlador para obtener datos de referencia (Estados, Prioridades, Departamentos)
    /// </summary>
    [Authorize]
    public class ReferencesController : BaseApiController
    {
        private readonly IEstadoService _estadoService;
        private readonly IPrioridadService _prioridadService;
        private readonly IDepartamentoService _departamentoService;

        public ReferencesController(
            ILogger<ReferencesController> logger,
            IEstadoService estadoService,
            IPrioridadService prioridadService,
            IDepartamentoService departamentoService) : base(logger)
        {
            _estadoService = estadoService;
            _prioridadService = prioridadService;
            _departamentoService = departamentoService;
        }

        /// <summary>
        /// Obtener todos los estados
        /// </summary>
        [AllowAnonymous]
        [HttpGet("estados")]
        public async Task<IActionResult> GetEstados()
        {
            try
            {
                var estados = await _estadoService.GetAllAsync();
                return Success(estados, "Estados obtenidos exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener estados");
                return Error<object>("Error interno del servidor", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Obtener todas las prioridades
        /// </summary>
        [AllowAnonymous]
        [HttpGet("prioridades")]
        public async Task<IActionResult> GetPrioridades()
        {
            try
            {
                var prioridades = await _prioridadService.GetAllAsync();
                return Success(prioridades, "Prioridades obtenidas exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener prioridades");
                return Error<object>("Error interno del servidor", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Obtener todos los departamentos
        /// </summary>
        [AllowAnonymous]
        [HttpGet("departamentos")]
        public async Task<IActionResult> GetDepartamentos()
        {
            try
            {
                var departamentos = await _departamentoService.GetAllAsync();
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
