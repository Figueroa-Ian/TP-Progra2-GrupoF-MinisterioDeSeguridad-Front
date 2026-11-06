<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Eliminar Contratación</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu { max-width: 520px; margin: 40px auto; }
            #zonaEliminar { display: none; margin-top: 16px; }
        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo">Administrador</span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Eliminar Contratación</h1>

            <form class="buscador" onsubmit="buscar(event)">
                <input type="number" id="idBuscado" min="1" required autofocus placeholder="Id de la contratación">
                <button type="submit">Buscar</button>
            </form>

            <div id="resultado" class="ficha"></div>
            <div id="zonaEliminar">
                <button type="button" id="btnEliminar" class="btn-accion btn-peligro" onclick="eliminar()">Eliminar esta contratación</button>
            </div>
            <div id="mensaje" class="mensaje error"></div>
            <div id="aviso" class="aviso"></div>

            <a class="volver" href="menuContrataciones.jsp">← Volver al menú</a>
        </div>

        <script src="js/sesion.js"></script>
        <script src="js/vistas.js"></script>
        <script src="js/contrataciones.js"></script>
        <script>
            var u = Sesion.exigir(["ADMIN", "ADMINISTRADOR"]);
            if (u) document.getElementById("saludo").innerText = "Administrador · " + u.mail;

            var idActual = null;

            function buscar(event) {
                event.preventDefault();
                Vistas.ocultarError();
                Contrataciones.ocultarAviso();
                document.getElementById("resultado").innerHTML = "";
                document.getElementById("zonaEliminar").style.display = "none";
                idActual = null;

                var id = document.getElementById("idBuscado").value;
                Vistas.pedir(Contrataciones.rutas.buscar(id))
                    .then(function (c) {
                        idActual = c.idContrato || c.id;
                        Vistas.ficha(document.getElementById("resultado"), Contrataciones.legible ? Contrataciones.legible(c) : c);
                        document.getElementById("zonaEliminar").style.display = "block";
                    })
                    .catch(function (err) {
                        console.error(err);
                        Vistas.mostrarError(Vistas.textoError(err, "No existe una contratación con ese Id."));
                    });
            }

            function eliminar() {
                if (idActual === null) return;
                if (!window.confirm("¿Seguro que querés eliminar la contratación N° " + idActual + "? Esta acción no se puede deshacer.")) return;

                var boton = document.getElementById("btnEliminar");
                boton.disabled = true;
                Contrataciones.ocultarAviso();
                Contrataciones.enviar("DELETE", Contrataciones.rutas.eliminar(idActual))
                    .then(function () {
                        Contrataciones.aviso("ok", "Contratación N° " + idActual + " eliminada.");
                        document.getElementById("resultado").innerHTML = "";
                        document.getElementById("zonaEliminar").style.display = "none";
                        document.getElementById("idBuscado").value = "";
                        idActual = null;
                    })
                    .catch(function (err) {
                        console.error(err);
                        Contrataciones.aviso("err", Contrataciones.textoError(err, "eliminar la contratación"));
                    })
                    .then(function () { boton.disabled = false; });
            }
        </script>
    </body>
</html>