<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Buscar Juez por Id</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu { max-width: 460px; margin: 40px auto; }
        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo">Administrador</span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Buscar Juez por Id</h1>

            <form class="buscador" onsubmit="buscar(event)">
                <input type="number" id="idBuscado" min="0" required autofocus placeholder="Id del juez">
                <button type="submit">Buscar</button>
            </form>

            <div id="resultado" class="ficha"></div>
            <div id="mensaje" class="mensaje error"></div>

            <a id="btnVolver" class="volver" href="menuJueces.jsp">← Volver al menú</a>
        </div>

        <script src="js/sesion.js"></script>
        <script src="js/vistas.js"></script>
        <script>
            var u = Sesion.exigir(["ADMIN", "ADMINISTRADOR", "INVESTIGADOR", "CHUSMA"]);

            if (u) {
                var rol = (u.rol || "ADMINISTRADOR").toUpperCase();
                document.getElementById("saludo").innerText =
                    rol + " · " + (u.mail || "");

                if (rol === "INVESTIGADOR") {
                    document.getElementById("btnVolver").href = "investigador.jsp";
                }
            }

            function buscar(event) {
                event.preventDefault();
                Vistas.ocultarError();

                var resultado = document.getElementById("resultado");
                resultado.innerHTML = "";

                var id = document.getElementById("idBuscado").value;

                Vistas.pedir("/jueces/" + encodeURIComponent(id))
                    .then(function (dato) {
                        Vistas.ficha(resultado, dato);
                    })
                    .catch(function (err) {
                        console.error(err);
                        Vistas.mostrarError(
                            Vistas.textoError(err, "No existe un juez con ese Id.")
                        );
                    });
            }
        </script>
    </body>
</html>