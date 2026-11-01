<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Modificar Expediente</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu { max-width: 560px; margin: 40px auto; }
            #zonaForm { display: none; }
        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo">Administrador</span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Modificar Expediente</h1>

            <form class="buscador" onsubmit="cargar(event)">
                <input type="number" id="idBuscado" min="1" required autofocus placeholder="N° de expediente">
                <button type="submit">Cargar</button>
            </form>

            <div id="zonaForm">
                <p id="titulo" style="font-weight:bold"></p>
                <p style="font-size:12px;color:#6c757d;margin-top:0">Los cambios al ilícito se aplican al ilícito vinculado a este expediente (si lo comparten otros expedientes, también los verán).</p>
                <div id="contenedorForm"></div>
            </div>

            <div id="aviso" class="aviso"></div>

            <a class="volver" href="menuExpedientes.jsp">← Volver al menú</a>
        </div>

        <script src="js/sesion.js"></script>
        <script src="js/vistas.js"></script>
        <script src="js/selectores.js"></script>
        <script src="js/expedientes.js"></script>
        <script>
            var u = Sesion.exigir(["ADMIN", "ADMINISTRADOR"]);
            if (u) document.getElementById("saludo").innerText = "Administrador · " + u.mail;

            var nroActual = null;
            var formListo = Expedientes.montar("contenedorForm", "Guardar cambios", guardar);

            function cargar(event) {
                event.preventDefault();
                Expedientes.ocultarAviso();
                document.getElementById("zonaForm").style.display = "none";
                nroActual = null;

                var id = document.getElementById("idBuscado").value;
                Promise.all([formListo, Vistas.pedir(Expedientes.rutas.buscar(id))])
                    .then(function (r) {
                        nroActual = r[1].nroExpediente;
                        Expedientes.llenar(r[1]);
                        document.getElementById("titulo").textContent = "Editando el expediente N° " + nroActual;
                        document.getElementById("zonaForm").style.display = "block";
                    })
                    .catch(function (err) {
                        console.error(err);
                        Expedientes.aviso("err", Vistas.textoError(err, "No existe un expediente con ese Id."));
                    });
            }

            function guardar(expediente) {
                if (nroActual === null) return;
                var boton = document.getElementById("btnGuardar");
                boton.disabled = true;
                Expedientes.ocultarAviso();
                Expedientes.enviar("PUT", Expedientes.rutas.modificar(nroActual), expediente)
                    .then(function (actualizado) {
                        Expedientes.aviso("ok", "Expediente N° " + actualizado.nroExpediente + " modificado correctamente.");
                    })
                    .catch(function (err) {
                        console.error(err);
                        Expedientes.aviso("err", Expedientes.textoError(err, "modificar el expediente"));
                    })
                    .then(function () { boton.disabled = false; });
            }
        </script>
    </body>
</html>
