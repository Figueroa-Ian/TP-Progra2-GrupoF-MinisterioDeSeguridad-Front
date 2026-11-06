<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Eliminar Vigilante</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu { max-width: 460px; margin: 40px auto; }
            #zonaEliminar { display: none; margin-top: 16px; }
        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo">Administrador</span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Eliminar Vigilante</h1>

            <form class="buscador" onsubmit="buscar(event)">
                <input type="number" id="idBuscado" min="1" required autofocus placeholder="Id del vigilante">
                <button type="submit">Buscar</button>
            </form>

            <div id="resultado" class="ficha"></div>
            <div id="zonaEliminar">
                <button type="button" id="btnEliminar" class="btn-accion btn-peligro" onclick="eliminar()">Eliminar este vigilante</button>
            </div>
            <div id="mensaje" class="mensaje error"></div>
            <div id="aviso" class="aviso"></div>

            <a class="volver" href="menuVigilantes.jsp">← Volver al menú</a>
        </div>

        <script src="js/sesion.js"></script>
        <script src="js/vistas.js"></script>
        <script src="js/vigilantes.js"></script>
        <script>
            var u = Sesion.exigir(["ADMIN", "ADMINISTRADOR"]);
            if (u) document.getElementById("saludo").innerText = "Administrador · " + u.mail;

            var idActual = null;

            function buscar(event) {
                event.preventDefault();
                Vistas.ocultarError();
                Vigilantes.ocultarAviso();
                document.getElementById("resultado").innerHTML = "";
                document.getElementById("zonaEliminar").style.display = "none";
                idActual = null;

                var id = document.getElementById("idBuscado").value;
                Vistas.pedir(Vigilantes.rutas.buscar(id))
                    .then(function (v) {
                        idActual = v.id;
                        Vistas.ficha(document.getElementById("resultado"), v);
                        document.getElementById("zonaEliminar").style.display = "block";
                    })
                    .catch(function (err) {
                        console.error(err);
                        Vistas.mostrarError(Vistas.textoError(err, "No existe un vigilante con ese Id."));
                    });
            }

            function eliminar() {
                if (idActual === null) return;
                if (!window.confirm("¿Seguro que querés eliminar al vigilante N° " + idActual + "? Esta acción no se puede deshacer.")) return;

                var boton = document.getElementById("btnEliminar");
                boton.disabled = true;
                Vigilantes.ocultarAviso();
                Vigilantes.enviar("DELETE", Vigilantes.rutas.eliminar(idActual))
                    .then(function () {
                        Vigilantes.aviso("ok", "Vigilante N° " + idActual + " eliminado.");
                        document.getElementById("resultado").innerHTML = "";
                        document.getElementById("zonaEliminar").style.display = "none";
                        document.getElementById("idBuscado").value = "";
                        idActual = null;
                    })
                    .catch(function (err) {
                        console.error(err);
                        Vigilantes.aviso("err", Vigilantes.textoError(err, "eliminar el vigilante"));
                    })
                    .then(function () { boton.disabled = false; });
            }
        </script>
    </body>
</html>
