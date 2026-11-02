<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Listado de Vigilantes</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu { max-width: 1000px; margin: 40px auto; }
        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo">Administrador</span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Listado de Vigilantes</h1>

            <div id="resultado"></div>
            <div id="mensaje" class="mensaje error"></div>

            <a class="volver" href="menuVigilantes.jsp">← Volver al menú</a>
        </div>

        <script src="js/sesion.js"></script>
        <script src="js/vistas.js"></script>
        <script src="js/vigilantes.js"></script>
        <script>
            var u = Sesion.exigir(["ADMIN", "ADMINISTRADOR", "INVESTIGADOR"]);
            if (u) document.getElementById("saludo").innerText = "Administrador · " + u.mail;

            Vistas.pedir(Vigilantes.rutas.listar)
                .then(function (lista) {
                    Vistas.tabla(document.getElementById("resultado"), lista);
                })
                .catch(function (err) {
                    console.error(err);
                    Vistas.mostrarError(Vistas.textoError(err, "No se encontraron vigilantes."));
                });
        </script>
    </body>
</html>
