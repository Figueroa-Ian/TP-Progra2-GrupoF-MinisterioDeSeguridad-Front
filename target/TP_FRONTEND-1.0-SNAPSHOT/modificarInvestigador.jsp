<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Modificar Investigador</title>
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
            <h1>Modificar Investigador</h1>

            <form class="buscador" onsubmit="cargar(event)">
                <input type="number" id="idBuscado" min="1" required autofocus placeholder="Id del investigador">
                <button type="submit">Cargar</button>
            </form>

            <div id="zonaForm">
                <p id="titulo" style="font-weight:bold"></p>
                <div id="contenedorForm"></div>
            </div>

            <div id="aviso" class="aviso"></div>

            <a class="volver" href="menuInvestigadores.jsp">← Volver al menú</a>
        </div>

        <script src="js/sesion.js"></script>
        <script src="js/vistas.js"></script>
        <script src="js/investigadores.js"></script>
        <script>
            var u = Sesion.exigir(["ADMIN", "ADMINISTRADOR"]);
            if (u) document.getElementById("saludo").innerText = "Administrador · " + u.mail;

            var idActual = null;
            Investigadores.montar("contenedorForm", "Guardar cambios", guardar);

            function cargar(event) {
                event.preventDefault();
                Investigadores.ocultarAviso();
                document.getElementById("zonaForm").style.display = "none";
                idActual = null;

                var id = document.getElementById("idBuscado").value;
                Vistas.pedir(Investigadores.rutas.buscar(id))
                    .then(function (p) {
                        idActual = p.id;
                        Investigadores.llenar(p);
                        var nombre = ((p.nombre || "") + " " + (p.apellido || "")).trim();
                        document.getElementById("titulo").textContent =
                            "Editando al investigador N° " + idActual + (nombre ? " — " + nombre : "");
                        document.getElementById("zonaForm").style.display = "block";
                    })
                    .catch(function (err) {
                        console.error(err);
                        Investigadores.aviso("err", Vistas.textoError(err, "No existe un investigador con ese Id."));
                    });
            }

            function guardar(investigador) {
                if (idActual === null) return;
                var boton = document.getElementById("btnGuardar");
                boton.disabled = true;
                Investigadores.ocultarAviso();
                Investigadores.enviar("PUT", Investigadores.rutas.modificar(idActual), investigador)
                    .then(function () {
                        Investigadores.aviso("ok", "Investigador N° " + idActual + " modificado correctamente.");
                    })
                    .catch(function (err) {
                        console.error(err);
                        Investigadores.aviso("err", Investigadores.textoError(err, "modificar el investigador"));
                    })
                    .then(function () { boton.disabled = false; });
            }
        </script>
    </body>
</html>
