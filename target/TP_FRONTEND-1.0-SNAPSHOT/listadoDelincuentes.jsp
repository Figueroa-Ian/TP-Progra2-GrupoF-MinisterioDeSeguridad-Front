<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Listado de Delincuentes</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu {
                max-width: 960px;
                margin: 40px auto;
            }
        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo">Administrador</span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Listado de Delincuentes</h1>

            <div id="resultado"></div>
            <div id="mensaje" class="mensaje error"></div>

            <a class="volver" href="menuDelincuentes.jsp">← Volver al menú</a>
        </div>

        <script src="js/sesion.js"></script>
        <script src="js/vistas.js"></script>
        <script>
                // 1. Incluimos INVESTIGADOR en los roles autorizados
                var u = Sesion.exigir(["ADMIN", "ADMINISTRADOR", "INVESTIGADOR", "CHUSMA"]);

                if (u) {
                    // 2. Saludo dinámico según el rol y mail del usuario
                    var rolNombre = u.rol ? u.rol.toUpperCase() : "USUARIO";
                    document.getElementById("saludo").innerText = rolNombre + " · " + u.mail;

                    // 3. Redirección dinámica del botón "Volver" según el rol
                    var btnVolver = document.querySelector(".volver");
                    if (btnVolver) {
                        btnVolver.href = (rolNombre === "INVESTIGADOR") ? "investigador.jsp" : "menuDelincuentes.jsp";
                    }

                    // Petición de datos al backend
                    Vistas.pedir("/delincuentes")
                            .then(function (lista) {
                                Vistas.tabla(document.getElementById("resultado"), lista);
                            })
                            .catch(function (err) {
                                console.error(err);
                                Vistas.mostrarError(Vistas.textoError(err, "No se encontró el listado."));
                            });
                }
        </script>

    </body>
</html>
