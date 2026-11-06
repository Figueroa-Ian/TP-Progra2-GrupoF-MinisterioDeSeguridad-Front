<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Registrar Expediente</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu { max-width: 560px; margin: 40px auto; }
            .volver { display: block; text-align: center; margin-top: 16px; color: #6c757d; text-decoration: none; font-size: 14px; }
            .volver:hover { text-decoration: underline; }
        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo">Administrador</span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Registrar Expediente</h1>
            <p style="font-size:13px;color:#6c757d;margin-top:0">El ilícito se crea junto con el expediente: si algo falla, no se guarda ninguno de los dos.</p>

            <div id="contenedorForm"></div>
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

            Expedientes.montar("contenedorForm", "Guardar Expediente", guardar)
                .catch(function (err) {
                    console.error(err);
                    Expedientes.aviso("err", "No se pudieron cargar los tipos de ilícito (" + Vistas.textoError(err, "catálogo inexistente") + ")");
                    document.getElementById("btnGuardar").disabled = true;
                });

            function guardar(expediente) {
                var boton = document.getElementById("btnGuardar");
                boton.disabled = true;
                Expedientes.ocultarAviso();
                Expedientes.enviar("POST", Expedientes.rutas.crear, expediente)
                    .then(function (creado) {
                        Expedientes.aviso("ok", "¡Expediente registrado! N° " + creado.nroExpediente + " (ilícito N° " + creado.ilicito.id + ")");
                        Expedientes.limpiar();
                    })
                    .catch(function (err) {
                        console.error(err);
                        Expedientes.aviso("err", Expedientes.textoError(err, "registrar el expediente"));
                    })
                    .then(function () { boton.disabled = false; });
            }
        </script>
    </body>
</html>
