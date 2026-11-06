<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Menú Sucursales</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu {
                max-width: 460px;
                margin: 40px auto;
            }
            .volver {
                display: block;
                text-align: center;
                margin-top: 16px;
                color: #6c757d;
                text-decoration: none;
                font-size: 14px;
            }
            .volver:hover {
                text-decoration: underline;
            }
        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo"></span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Menú Sucursales</h1>

            <!-- ID btnCrear asignado para ocultar si es INVESTIGADOR -->
            <a id="btnCrear" class="btn" href="crearSucursal.jsp">+ Registrar Sucursal</a>
            <a class="btn" href="listadoSucursales.jsp">Ver Listado Sucursales</a>
            <a class="btn" href="buscarSucursal.jsp">Buscar por Id</a>
            <a id="btnModificar" class="btn" href="modificarSucursal.jsp">Modificar Sucursal</a>
            <a id="btnEliminar" class="btn" href="eliminarSucursal.jsp">Eliminar Sucursal</a>

            <!-- ID btnVolver asignado para redirigir dinámicamente -->
            <a id="btnVolver" class="volver" href="admin.jsp">← Volver al menú principal</a>
        </div>

        <script src="js/sesion.js"></script>
        <script>
                var u = Sesion.exigir(["ADMIN", "ADMINISTRADOR", "INVESTIGADOR", "CHUSMA"]);
                if (u) {
                    var rol = (u.rol || "").toUpperCase();
                    document.getElementById("saludo").innerText = rol + " · " + u.mail;

                    // El investigador solo consulta: se ocultan alta, modificación y baja
                    if (rol === "INVESTIGADOR" || rol === "CHUSMA") {
                        ["btnCrear", "btnModificar", "btnEliminar"].forEach(function (id) {
                            var el = document.getElementById(id);
                            if (el)
                                el.style.display = "none";
                        });
                        if (rol === "CHUSMA") {
                            document.getElementById("btnVolver").href = "chusma.jsp";
                        } else if (rol === "INVESTIGADOR") {
                            document.getElementById("btnVolver").href = "investigador.jsp";
                        }
                    }
                }
        </script>
    </body>
</html>
