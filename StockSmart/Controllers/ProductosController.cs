using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using StockSmart.Models;

namespace StockSmart.Controllers
{
    public class ProductosController : Controller
    {
        // GET: ProductosController
        public ActionResult Index()
        {
            return View(new List<Producto>());
        }

        // GET: ProductosController/Ficha/5
        public ActionResult Ficha(int id)
        {
            return View(new Producto());
        }

        // POST: ProductosController/Ficha/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Ficha(int id, IFormCollection collection)
        {
            try
            {
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                return View(new Producto());
            }
        }


        // GET: ProductosController/Nuevo
        public ActionResult Nuevo()
        {
            return View("Ficha", new Producto());
        }

        // POST: ProductosController/Nuevo
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Nuevo(IFormCollection collection)
        {
            try
            {
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                return View("Ficha", new Producto());
            }
        }
    }
}
