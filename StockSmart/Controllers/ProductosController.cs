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
            _httpClient = new HttpClient();
            _httpClient.BaseAddress = new Uri("https://127.0.0.1:5000/");
        }

        // GET: Products
        [HttpGet]
        public async Task<IActionResult> Index()
        {
            var response = await _httpClient.GetAsync("products");
            var productos = await response.Content.ReadAsStringAsync();
            var product_list = JsonConvert.DeserializeObject<List<Producto>>(productos);
            return Ok(View(product_list));
        }

        // GET: Products/5
        [HttpGet]
        public async Task<IActionResult> Ficha(int id)
        {            
            var response = await _httpClient.GetAsync($"products/{id}");
            var producto = await response.Content.ReadAsStringAsync();
            var producto_obj = JsonConvert.DeserializeObject<Producto>(producto);
            return Ok(View(producto_obj));
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
                    var response = await _httpClient.PutAsJsonAsync<Producto>($"products/{id}", producto);
                    if (response.IsSuccessStatusCode)
                    {
                        return RedirectToAction(nameof(Index));
                    }
                    return View(producto);
                }
                else
                {
                    return View(producto);
                }
            }
            catch
            {
                return View(new Producto());
            }
        }


        // // GET: ProductosController/Nuevo
        // public ActionResult Nuevo()
        // {
        //     return View("Ficha", new Producto());
        // }

        // // POST: Products/Nuevo
        // [HttpPost]
        // [ValidateAntiForgeryToken]
        // public async Task<IActionResult> Nuevo(Producto producto)
        // {
        //     try
        //     {
        //         var producto = new Producto
        //         {
        //             // TODO: REVISAR
        //             ProductID = int.Parse(producto.ProductID),
        //             ProductName = producto.ProductName,
        //             SupplierID = int.Parse(producto.SupplierID),
        //             CategoryID = int.Parse(producto.CategoryID),
        //             QuantityPerUnit = producto.QuantityPerUnit,
        //             UnitPrice = decimal.Parse(producto.UnitPrice),
        //             UnitsInStock = short.Parse(producto.UnitsInStock),
        //             UnitsOnOrder = short.Parse(producto.UnitsOnOrder),
        //             ReorderLevel = short.Parse(producto.ReorderLevel),
        //             Discontinued = bool.Parse(producto.Discontinued),

        //         };

        //         var productojson = JsonContent.SerializeObject(producto);

        //         if (ModelState.IsValid)
        //         {
        //             var response = await _httpClient.PostAsJsonAsync<Producto>("products", producto);
        //             if (response.IsSuccessStatusCode)
        //             {
        //                 return RedirectToAction(nameof(Index));
        //             }
        //             return View("Ficha", producto);
        //         }
        //         else
        //         {
        //             return View("Ficha", producto);
        //         }
        //     }
        //     catch
        //     {
        //         return View("Ficha", new Producto());
        //     }
        // }
    }
}
