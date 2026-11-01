<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Menú Contrataciones</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu { max-width: 460px; margin: 40px auto; }
            .volver {
                display: block;
                text-align: center;
                margin-top: 16px;
                color: #6c757d;
                text-decoration: none;
                font-size: 14px;
            }
            .volver:hover { text-decoration: underline; }
        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo">Administrador</span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Menú Contrataciones</h1>

            <a class="btn" href="crearContratacion.jsp">+ Registrar Contratación</a>
            <a class="btn" href="listadoContrataciones.jsp">Ver Listado Contrataciones</a>
            <a class="btn" href="buscarContratacion.jsp">Buscar por Id</a>
            <a class="btn" href="modificarContratacion.jsp">Modificar Contratacion</a>
            <a class="btn" href="eliminarContratacion.jsp">Eliminar Contratacion</a>
            
            <a class="volver" href="admin.jsp">← Volver al menú principal</a>
        </div>

        <script src="js/sesion.js"></script>
        <script>
            var u = Sesion.exigir(["ADMIN", "ADMINISTRADOR", "INVESTIGADOR"]);
            if (u) document.getElementById("saludo").innerText = "Administrador · " + u.mail;
        </script>
    </body>
</html>