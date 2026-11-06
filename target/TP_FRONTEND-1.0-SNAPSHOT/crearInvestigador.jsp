<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Registrar Investigador</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu { max-width: 480px; margin: 40px auto; }

        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo">Administrador</span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Registrar Investigador</h1>

            <div id="contenedorForm"></div>
            <div id="aviso" class="aviso"></div>

            <a class="volver" href="menuInvestigadores.jsp">← Volver al menú</a>
        </div>

        <script src="js/sesion.js"></script>
        <script src="js/vistas.js"></script>
        <script src="js/investigadores.js"></script>
        <script>
            var u = Sesion.exigir(["ADMIN", "ADMINISTRADOR"]);
            if (u) document.getElementById("saludo").innerText = "Administrador · " + u.mail;

            Investigadores.montar("contenedorForm", "Registrar Investigador", guardar);

            function guardar(investigador) {
                var boton = document.getElementById("btnGuardar");
                boton.disabled = true;
                Investigadores.ocultarAviso();
                Investigadores.enviar("POST", Investigadores.rutas.crear, investigador)
                    .then(function (creado) {
                        Investigadores.aviso("ok", "Investigador registrado correctamente (Id " + creado.id + ").");
                        Investigadores.limpiar();
                    })
                    .catch(function (err) {
                        console.error(err);
                        Investigadores.aviso("err", Investigadores.textoError(err, "registrar el investigador"));
                    })
                    .then(function () { boton.disabled = false; });
            }
        </script>
    </body>
</html>
