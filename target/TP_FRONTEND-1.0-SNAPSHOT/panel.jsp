<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Panel</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu { max-width: 460px; margin: 40px auto; }
        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo"></span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1 id="titulo">Panel</h1>
            <p id="detalle"></p>
            <div id="opciones"></div>
        </div>

        <script src="js/sesion.js"></script>
        <script>
            // Opciones por rol. Agregá/quitá según lo que le corresponda ver a cada uno.
            var OPCIONES = {
                JUEZ:       [{ texto: "Ver nómina de Jueces", href: "buscar" }],
                VIGILANTE:  [{ texto: "Ver mis datos", href: "vigilante.jsp" }],
                INVESTIGADOR: []
            };

            var u = Sesion.exigir(null);
            if (u) {
                var rol = (u.rol || "").toUpperCase();
                document.getElementById("saludo").innerText = rol + " · " + u.mail;
                document.getElementById("titulo").innerText = "Panel de " + rol.charAt(0) + rol.slice(1).toLowerCase();
                var ops = OPCIONES[rol] || [];
                document.getElementById("detalle").innerText = ops.length ? "" : "Todavía no hay opciones disponibles para este rol.";
                ops.forEach(function (o) {
                    var a = document.createElement("a");
                    a.className = "btn";
                    a.href = o.href;
                    a.innerText = o.texto;
                    document.getElementById("opciones").appendChild(a);
                });
            }
        </script>
    </body>
</html>
