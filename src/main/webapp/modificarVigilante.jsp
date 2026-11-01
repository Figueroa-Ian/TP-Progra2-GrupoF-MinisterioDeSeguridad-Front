<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Modificar Vigilante</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu { max-width: 480px; margin: 40px auto; }
            #zonaForm { display: none; }
        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo">Administrador</span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Modificar Vigilante</h1>

            <form class="buscador" onsubmit="cargar(event)">
                <input type="number" id="idBuscado" min="1" required autofocus placeholder="Id del vigilante">
                <button type="submit">Cargar</button>
            </form>

            <div id="zonaForm">
                <p id="titulo" style="font-weight:bold"></p>
                <p style="font-size:12px;color:#6c757d;margin-top:0">Acá se modifican el legajo, la edad y la disponibilidad.</p>
                <div id="contenedorForm"></div>
            </div>

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
            Vigilantes.montar("contenedorForm", false, "Guardar cambios", guardar);

            function cargar(event) {
                event.preventDefault();
                Vigilantes.ocultarAviso();
                document.getElementById("zonaForm").style.display = "none";
                idActual = null;

                var id = document.getElementById("idBuscado").value;
                Vistas.pedir(Vigilantes.rutas.buscar(id))
                    .then(function (v) {
                        idActual = v.id;
                        Vigilantes.llenar(v);
                        var nombre = ((v.nombre || "") + " " + (v.apellido || "")).trim();
                        document.getElementById("titulo").textContent = "Editando al vigilante N° " + idActual + (nombre ? " — " + nombre : "");
                        document.getElementById("zonaForm").style.display = "block";
                    })
                    .catch(function (err) {
                        console.error(err);
                        Vigilantes.aviso("err", Vistas.textoError(err, "No existe un vigilante con ese Id."));
                    });
            }

            function guardar(vigilante) {
                if (idActual === null) return;
                var boton = document.getElementById("btnGuardar");
                boton.disabled = true;
                Vigilantes.ocultarAviso();
                Vigilantes.enviar("PUT", Vigilantes.rutas.modificar(idActual), vigilante)
                    .then(function () {
                        Vigilantes.aviso("ok", "Vigilante N° " + idActual + " modificado correctamente.");
                    })
                    .catch(function (err) {
                        console.error(err);
                        Vigilantes.aviso("err", Vigilantes.textoError(err, "modificar el vigilante"));
                    })
                    .then(function () { boton.disabled = false; });
            }
        </script>
    </body>
</html>
