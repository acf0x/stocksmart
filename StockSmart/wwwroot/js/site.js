let App = {
    Core: {
        CreateTable: function (id) {
            $("#" + id).DataTable({
                "language": {
                    "url": "//cdn.datatables.net/plug-ins/1.10.19/i18n/Spanish.json"
                }
            });
        }
    },
    Data: {},
    Page: {
        Products: {
            List: {
                OnLoad: function () {
                    App.Core.CreateTable("productos");

                    $(".text-units").click(function (e) {
                        alert("Stock: " + $(this).data("stock") + "\nPedido: " + $(this).data("order"));
                    });

                    $('[data-bs-toggle="tooltip"]').tooltip();
                }
            }
        }
    }
}
