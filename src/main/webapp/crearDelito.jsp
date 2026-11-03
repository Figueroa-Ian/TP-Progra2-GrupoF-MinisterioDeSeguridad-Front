<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Menú Delitos</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu { max-width: 460px; margin: 40px auto; }
            .volver { display: block; text-align: center; margin-top: 16px; color: #6c757d; text-decoration: none; font-size: 14px; }
            .volver:hover { text-decoration: underline; }
        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo"></span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Menú Delitos</h1>

            <a id="btnCrear" class="btn" href="crearDelito.jsp">+ Registrar Delito</a>
            <a class="btn" href="listadoDelitos.jsp">Ver Listado Delitos</a>
            <a class="btn" href="buscarDelito.jsp">Buscar por Id</a>

            <a id="btnVolver" class="volver" href="admin.jsp">← Volver al menú principal</a>
        </div>

        <script src="js/sesion.js"></script>
        <script>
            var u = Sesion.exigir(["ADMIN", "ADMINISTRADOR", "INVESTIGADOR"]);
            if (u) {
                var rol = (u.rol || "").toUpperCase();
                document.getElementById("saludo").innerText = rol + " · " + u.mail;

                if (rol === "INVESTIGADOR") {
                    document.getElementById("btnCrear").style.display = "none";
                    document.getElementById("btnVolver").href = "investigador.jsp";
                } else {
                    document.getElementById("btnVolver").href = "admin.jsp";
                }
            }
        </script>
    </body>
</html>