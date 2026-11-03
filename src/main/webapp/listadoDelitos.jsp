<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Listado de Delitos</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu { max-width: 960px; margin: 40px auto; }
            .volver { display: block; margin-top: 16px; color: #6c757d; text-decoration: none; font-size: 14px; }
        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo"></span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Listado de Delitos</h1>

            <div id="resultado"></div>
            <div id="mensaje" class="mensaje error" style="display:none;"></div>

            <a id="btnVolver" class="volver" href="admin.jsp">← Volver al menú</a>
        </div>

        <script src="js/sesion.js"></script>
        <script src="js/vistas.js"></script>
        <script>
            var u = Sesion.exigir(["ADMIN", "ADMINISTRADOR", "INVESTIGADOR", "CHUSMA"]);
            if (u) {
                var rol = (u.rol || "").toUpperCase();
                document.getElementById("saludo").innerText = rol + " · " + u.mail;

                var btnVolver = document.getElementById("btnVolver");
                if (btnVolver) {
                    btnVolver.href = (rol === "INVESTIGADOR") ? "investigador.jsp" : "menuDelitos.jsp";
                }

                Vistas.pedir("/delitos")
                    .then(function (lista) {
                        Vistas.tabla(document.getElementById("resultado"), lista);
                    })
                    .catch(function (err) {
                        console.error(err);
                        Vistas.mostrarError(Vistas.textoError(err, "No se pudo obtener el listado de delitos."));
                    });
            }
        </script>
    </body>
</html>