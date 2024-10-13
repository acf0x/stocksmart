using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using StockSmart.Models;
using Newtonsoft.Json;

namespace StockSmart.Controllers
{
    public class ProductosController : Controller
    {
        private readonly HttpClient _httpClient;

        public ProductosController()
        {
            var handler = new HttpClientHandler
            {
                ServerCertificateCustomValidationCallback = (sender, cert, chain, sslPolicyErrors) => true
            };
            _httpClient = new HttpClient(handler);
            _httpClient.BaseAddress = new Uri("https://miappbackend.azurewebsites.net");
        }

        // GET: Products
        [HttpGet]
        public async Task<IActionResult> Index()
        {
            try
            {
                var response = await _httpClient.GetAsync("productos");
                
                if (!response.IsSuccessStatusCode)
                {
                    // Log the error status code
                    Console.WriteLine($"Error: {response.StatusCode}");
                    return StatusCode((int)response.StatusCode, $"Error al obtener productos: {response.ReasonPhrase}");
                }

                var productos = await response.Content.ReadAsStringAsync();
                var product_list = JsonConvert.DeserializeObject<List<Producto>>(productos);
                
                if (product_list == null)
                {
                    return StatusCode(500, "Error al deserializar la lista de productos");
                }

                return View(product_list);
            }

            catch (Exception e)
            {
                // Log the exception
                Console.WriteLine($"Exception: {e.Message}");
                return StatusCode(500, $"Error interno del servidor: {e.Message}");
            }
        }

        // GET: Products/5
        [HttpGet]
        public async Task<IActionResult> Ficha(int id)
        {            
            var response = await _httpClient.GetAsync($"productos/{id}");
            
            if (!response.IsSuccessStatusCode)
            {
                // Manejar el error de la respuesta
                return StatusCode((int)response.StatusCode, $"Error al obtener el producto: {response.ReasonPhrase}");
            }

            var producto = await response.Content.ReadAsStringAsync();
            var producto_obj = JsonConvert.DeserializeObject<Producto>(producto);
            
            if (producto_obj == null)
            {
                return NotFound(); // O cualquier otro manejo que desees
            }

            return View(producto_obj);
              }


        // PUT: Products/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Ficha(int id, Producto producto)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var response = await _httpClient.PutAsJsonAsync($"productos/{id}", producto);
                    if (response.IsSuccessStatusCode)
                    {
                        return RedirectToAction(nameof(Index));
                    }
                }

                // Si llegamos aquí, hubo un error o el modelo no es válido
                return View(producto); // Esto maneja el caso donde el modelo no es válido o el PUT falló
            }
            catch
            {
                // Manejo de excepción
                return View(new Producto());
            }
        }



        // GET: ProductosController/Nuevo
        public ActionResult Nuevo()
        {
            return View("Ficha", new Producto());
        }

        // POST: Products/Nuevo
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Nuevo(Producto producto)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var response = await _httpClient.PostAsJsonAsync("productos", producto);
                    if (response.IsSuccessStatusCode)
                    {
                        return RedirectToAction(nameof(Index));
                    }
                    return View("Ficha", producto);
                }
                else
                {
                    return View("Ficha", producto);
                }
            }
            catch (Exception e)
            {
                // Log the exception
                Console.WriteLine($"Exception: {e.Message}");
                return View("Ficha", producto);
            }
        }
    }
}
