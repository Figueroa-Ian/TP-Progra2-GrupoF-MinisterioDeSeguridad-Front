<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Registrar Vigilante</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu { max-width: 520px; margin: 40px auto; }
        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo">Administrador</span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Registrar Vigilante</h1>

            <div id="contenedorForm"></div>
            <div id="aviso" class="aviso"></div>

            <a class="volver" href="menuVigilantes.jsp">← Volver al menú</a>
        </div>

        <script src="js/sesion.js"></script>
        <script src="js/vistas.js"></script>
        <script src="js/vigilantes.js"></script>
        <script>
            var u = Sesion.exigir(["ADMIN", "ADMINISTRADOR"]);
            if (u) document.getElementById("saludo").innerText = "Administrador · " + u.mail;

            Vigilantes.montar("contenedorForm", true, "Guardar Vigilante", guardar);

            function guardar(vigilante) {
                var boton = document.getElementById("btnGuardar");
                boton.disabled = true;
                Vigilantes.ocultarAviso();
                Vigilantes.enviar("POST", Vigilantes.rutas.crear, vigilante)
                    .then(function (creado) {
                        Vigilantes.aviso("ok", "¡Vigilante registrado! ID asignado: " + creado.id);
                        Vigilantes.limpiar();
                    })
                    .catch(function (err) {
                        console.error(err);
                        Vigilantes.aviso("err", Vigilantes.textoError(err, "registrar el vigilante"));
                    })
                    .then(function () { boton.disabled = false; });
            }
        </script>
    </body>
</html>
