using Microsoft.AspNetCore.Mvc;

namespace serve_config_net.Controllers
{
    [ApiController]
    [Route("")]
    public class ConfigController : ControllerBase
    {
        private readonly ILogger<ConfigController> _logger;
        private readonly IWebHostEnvironment _env;

        public ConfigController(ILogger<ConfigController> logger, IWebHostEnvironment env)
        {
            _logger = logger;
            _env = env;
        }

        private string GetConfigDir()
        {
            // Get path to the config_files directory at the project root
            return Path.Combine(_env.ContentRootPath, "config_files");
        }

        [HttpGet("cooker_config.json")]
        public IActionResult GetCookerConfig()
        {
            string configPath = Path.Combine(GetConfigDir(), "cooker_config.json");
            
            if (!System.IO.File.Exists(configPath))
            {
                _logger.LogError($"File not found: {configPath}");
                return NotFound("Config file not found");
            }
            
            return PhysicalFile(configPath, "application/json");
        }

        [HttpGet("eiot_config.json")]
        public IActionResult GetEiotConfig()
        {
            string configPath = Path.Combine(GetConfigDir(), "eiot_config.json");
            
            if (!System.IO.File.Exists(configPath))
            {
                _logger.LogError($"File not found: {configPath}");
                return NotFound("Config file not found");
            }
            
            return PhysicalFile(configPath, "application/json");
        }

        [HttpGet("pico_iot_config.json")]
        public IActionResult GetPicoIotConfig()
        {
            string configPath = Path.Combine(GetConfigDir(), "pico_iot_config.json");
            
            if (!System.IO.File.Exists(configPath))
            {
                _logger.LogError($"File not found: {configPath}");
                return NotFound("Config file not found");
            }
            
            return PhysicalFile(configPath, "application/json");
        }

        [HttpGet("ping")]
        public IActionResult Ping()
        {
            _logger.LogInformation($"Ping request from IP: {HttpContext.Connection.RemoteIpAddress}");
            return Ok("pong");
        }
    }
}