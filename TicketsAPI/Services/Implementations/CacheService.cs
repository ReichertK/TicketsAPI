using TicketsAPI.Models.DTOs;
using TicketsAPI.Models.Entities;
using TicketsAPI.Repositories.Interfaces;
using Microsoft.Extensions.Caching.Memory;

namespace TicketsAPI.Services.Implementations
{
    /// <summary>
    /// Servicio de cache para entidades de referencia (Estados, Prioridades, Departamentos)
    /// </summary>
    public class CacheService
    {
        private readonly IMemoryCache _cache;
        private readonly IEstadoRepository _estadoRepository;
        private readonly IPrioridadRepository _prioridadRepository;
        private readonly IDepartamentoRepository _departamentoRepository;
        private readonly ILogger<CacheService> _logger;

        // Cache keys
        private const string CACHE_KEY_ESTADOS = "cache_estados_all";
        private const string CACHE_KEY_PRIORIDADES = "cache_prioridades_all";
        private const string CACHE_KEY_DEPARTAMENTOS = "cache_departamentos_all";

        // TTL por defecto: 15 minutos
        private static readonly TimeSpan DefaultCacheDuration = TimeSpan.FromMinutes(15);

        public CacheService(
            IMemoryCache cache,
            IEstadoRepository estadoRepository,
            IPrioridadRepository prioridadRepository,
            IDepartamentoRepository departamentoRepository,
            ILogger<CacheService> logger)
        {
            _cache = cache;
            _estadoRepository = estadoRepository;
            _prioridadRepository = prioridadRepository;
            _departamentoRepository = departamentoRepository;
            _logger = logger;
        }

        /// <summary>
        /// Obtener todos los estados (con cache)
        /// </summary>
        public async Task<List<Estado>> GetEstadosAsync()
        {
            return await _cache.GetOrCreateAsync(CACHE_KEY_ESTADOS, async entry =>
            {
                entry.AbsoluteExpirationRelativeToNow = DefaultCacheDuration;
                entry.SetPriority(CacheItemPriority.High);
                
                _logger.LogInformation("Cache MISS: Cargando estados desde BD");
                var estados = await _estadoRepository.GetAllAsync();
                _logger.LogInformation("Estados cargados en cache: {Count} registros", estados.Count);
                
                return estados;
            }) ?? new List<Estado>();
        }

        /// <summary>
        /// Obtener todas las prioridades (con cache)
        /// </summary>
        public async Task<List<Prioridad>> GetPrioridadesAsync()
        {
            return await _cache.GetOrCreateAsync(CACHE_KEY_PRIORIDADES, async entry =>
            {
                entry.AbsoluteExpirationRelativeToNow = DefaultCacheDuration;
                entry.SetPriority(CacheItemPriority.High);
                
                _logger.LogInformation("Cache MISS: Cargando prioridades desde BD");
                var prioridades = await _prioridadRepository.GetAllAsync();
                _logger.LogInformation("Prioridades cargadas en cache: {Count} registros", prioridades.Count);
                
                return prioridades;
            }) ?? new List<Prioridad>();
        }

        /// <summary>
        /// Obtener todos los departamentos (con cache)
        /// </summary>
        public async Task<List<Departamento>> GetDepartamentosAsync()
        {
            return await _cache.GetOrCreateAsync(CACHE_KEY_DEPARTAMENTOS, async entry =>
            {
                entry.AbsoluteExpirationRelativeToNow = DefaultCacheDuration;
                entry.SetPriority(CacheItemPriority.High);
                
                _logger.LogInformation("Cache MISS: Cargando departamentos desde BD");
                var departamentos = await _departamentoRepository.GetAllAsync();
                _logger.LogInformation("Departamentos cargados en cache: {Count} registros", departamentos.Count);
                
                return departamentos;
            }) ?? new List<Departamento>();
        }

        /// <summary>
        /// Obtener un estado por ID (con cache)
        /// </summary>
        public async Task<Estado?> GetEstadoByIdAsync(int id)
        {
            var estados = await GetEstadosAsync();
            return estados.FirstOrDefault(e => e.Id_Estado == id);
        }

        /// <summary>
        /// Obtener una prioridad por ID (con cache)
        /// </summary>
        public async Task<Prioridad?> GetPrioridadByIdAsync(int id)
        {
            var prioridades = await GetPrioridadesAsync();
            return prioridades.FirstOrDefault(p => p.Id_Prioridad == id);
        }

        /// <summary>
        /// Obtener un departamento por ID (con cache)
        /// </summary>
        public async Task<Departamento?> GetDepartamentoByIdAsync(int id)
        {
            var departamentos = await GetDepartamentosAsync();
            return departamentos.FirstOrDefault(d => d.Id_Departamento == id);
        }

        /// <summary>
        /// Invalida cache de estados
        /// </summary>
        public void InvalidateEstadosCache()
        {
            _cache.Remove(CACHE_KEY_ESTADOS);
            _logger.LogInformation("Cache de estados invalidado");
        }

        /// <summary>
        /// Invalida cache de prioridades
        /// </summary>
        public void InvalidatePrioridadesCache()
        {
            _cache.Remove(CACHE_KEY_PRIORIDADES);
            _logger.LogInformation("Cache de prioridades invalidado");
        }

        /// <summary>
        /// Invalida cache de departamentos
        /// </summary>
        public void InvalidateDepartamentosCache()
        {
            _cache.Remove(CACHE_KEY_DEPARTAMENTOS);
            _logger.LogInformation("Cache de departamentos invalidado");
        }

        /// <summary>
        /// Invalida todo el cache de referencias
        /// </summary>
        public void InvalidateAllCache()
        {
            InvalidateEstadosCache();
            InvalidatePrioridadesCache();
            InvalidateDepartamentosCache();
            _logger.LogInformation("Todo el cache de referencias invalidado");
        }

        /// <summary>
        /// Pre-carga todos los datos en cache (warmup)
        /// </summary>
        public async Task WarmupCacheAsync()
        {
            _logger.LogInformation("Iniciando warmup de cache...");
            
            await Task.WhenAll(
                GetEstadosAsync(),
                GetPrioridadesAsync(),
                GetDepartamentosAsync()
            );
            
            _logger.LogInformation("Warmup de cache completado");
        }
    }
}
