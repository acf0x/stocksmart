using System.ComponentModel.DataAnnotations;

namespace StockSmart.Models
{
    public class Producto
    {
        [Display(Name = "Referencia")]
        [Required(ErrorMessage = "La <b>Referencía</b> es un dato requerido.")]
        public int ProductID { get; set; }

        [Display(Name = "Descripción")]
        [Required(ErrorMessage = "La <b>Descripción</b> es un dato requerido.")]
        [MinLength(5, ErrorMessage = "Debe contener al menos 5 caracteres.")]
        public string ProductName { get; set; }

        [Display(Name = "Proveedor")]
        public int? SupplierID { get; set; }

        [Display(Name = "Categoría")]
        public int? CategoryID { get; set; }

        [Display(Name = "Cantidades por unidad")]
        public string QuantityPerUnit { get; set; }

        [Display(Name = "Precio")]
        public decimal? UnitPrice { get; set; }

        [Display(Name = "Stock")]
        public short? UnitsInStock { get; set; }

        [Display(Name = "Stock Pedido")]
        public short? UnitsOnOrder { get; set; }

        [Display(Name = "Nivel")]
        public short? ReorderLevel { get; set; }

        [Display(Name = "Descuentos")]
        public bool Discontinued { get; set; }
    }
}
