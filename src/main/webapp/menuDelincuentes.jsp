<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Menú Delincuentes</title>
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
            <h1>Menú Delincuentes</h1>

            <!-- Le agregamos un id para poder ocultarlo si es Investigador -->
            <a id="btnCrear" class="btn" href="crearDelincuente.jsp">+ Registrar Delincuente</a>

            <a class="btn" href="listadoDelincuentes.jsp">Ver Listado Delincuentes</a>
            <a class="btn" href="buscarDelincuente.jsp">Buscar por Id</a>
            <a id="btnEliminar" class="btn" href="eliminarDelincuente.jsp">Eliminar Delincuente</a>

            <a id="btnVolver" class="volver" href="admin.jsp">← Volver al menú principal</a>
        </div>

        <script src="js/sesion.js"></script>
        <script>
                // 1. Permitimos el acceso tanto al Admin como al Investigador
                var u = Sesion.exigir(["ADMIN", "ADMINISTRADOR", "INVESTIGADOR", "CHUSMA"]);

                if (u) {
                    var rol = (u.rol || "").toUpperCase();
                    document.getElementById("saludo").innerText = rol + " · " + u.mail;

                    // 2. Si el rol es INVESTIGADOR, ocultamos la opción de registro
                    if (rol === "INVESTIGADOR" || rol === "CHUSMA") {
                        document.getElementById("btnCrear").style.display = "none";
                        document.getElementById("btnEliminar").style.display = "none";
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