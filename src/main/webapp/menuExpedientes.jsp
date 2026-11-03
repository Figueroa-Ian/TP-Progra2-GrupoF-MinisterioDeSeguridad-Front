<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Menú Expedientes</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu { max-width: 460px; margin: 40px auto; }
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
            <h1>Menú Expedientes</h1>

            <a class="btn" href="crearExpediente.jsp">+ Registrar Expediente</a>
            <a class="btn" href="listadoExpedientes.jsp">Ver Listado de Expedientes</a>
            <a class="btn" href="buscarExpediente.jsp">Buscar por Id</a>
            <a class="btn" href="modificarExpediente.jsp">Modificar Expediente</a>
            <a class="btn" href="eliminarExpediente.jsp">Eliminar Expediente</a>

            <a class="volver" href="admin.jsp">← Volver al menú principal</a>
        </div>

        <script src="js/sesion.js"></script>
        <script>
            var u = Sesion.exigir(["ADMIN", "ADMINISTRADOR", "CHUSMA"]);
            if (u) document.getElementById("saludo").innerText = "Administrador · " + u.mail;
        </script>
    </body>
</html>
