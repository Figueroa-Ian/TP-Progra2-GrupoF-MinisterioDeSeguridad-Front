<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Eliminar Expediente</title>
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
            <h1>Eliminar Expediente</h1>

            <form class="buscador" onsubmit="buscar(event)">
                <input type="number" id="idBuscado" min="1" required autofocus placeholder="N° de expediente">
                <button type="submit">Buscar</button>
            </form>

            <div id="resultado" class="ficha"></div>
            <div id="zonaEliminar">
                <button type="button" id="btnEliminar" class="btn-accion btn-peligro" onclick="eliminar()">Eliminar este expediente</button>
            </div>
            <div id="mensaje" class="mensaje error"></div>
            <div id="aviso" class="aviso"></div>

            <a class="volver" href="menuExpedientes.jsp">← Volver al menú</a>
        </div>

        <script src="js/sesion.js"></script>
        <script src="js/vistas.js"></script>
        <script src="js/expedientes.js"></script>
        <script>
            var u = Sesion.exigir(["ADMIN", "ADMINISTRADOR"]);
            if (u) document.getElementById("saludo").innerText = "Administrador · " + u.mail;

            var nroActual = null;

            function buscar(event) {
                event.preventDefault();
                Vistas.ocultarError();
                Expedientes.ocultarAviso();
                document.getElementById("resultado").innerHTML = "";
                document.getElementById("zonaEliminar").style.display = "none";
                nroActual = null;

                var id = document.getElementById("idBuscado").value;
                Promise.all([Expedientes.cargarCatalogos(), Vistas.pedir(Expedientes.rutas.buscar(id))])
                    .then(function (r) {
                        nroActual = r[1].nroExpediente;
                        Vistas.ficha(document.getElementById("resultado"), Expedientes.legible(r[1]));
                        document.getElementById("zonaEliminar").style.display = "block";
                    })
                    .catch(function (err) {
                        console.error(err);
                        Vistas.mostrarError(Vistas.textoError(err, "No existe un expediente con ese Id."));
                    });
            }

            function eliminar() {
                if (nroActual === null) return;
                if (!window.confirm("¿Seguro que querés eliminar el expediente N° " + nroActual + "? Esta acción no se puede deshacer.")) return;

                var boton = document.getElementById("btnEliminar");
                boton.disabled = true;
                Expedientes.ocultarAviso();
                Expedientes.enviar("DELETE", Expedientes.rutas.eliminar(nroActual))
                    .then(function () {
                        Expedientes.aviso("ok", "Expediente N° " + nroActual + " eliminado.");
                        document.getElementById("resultado").innerHTML = "";
                        document.getElementById("zonaEliminar").style.display = "none";
                        document.getElementById("idBuscado").value = "";
                        nroActual = null;
                    })
                    .catch(function (err) {
                        console.error(err);
                        Expedientes.aviso("err", Expedientes.textoError(err, "eliminar el expediente"));
                    })
                    .then(function () { boton.disabled = false; });
            }
        </script>
    </body>
</html>
