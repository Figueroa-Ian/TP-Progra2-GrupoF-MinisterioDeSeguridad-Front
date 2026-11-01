<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Menú Investigadores</title>
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
            <span id="saludo"></span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Menú Investigadores</h1>

            <!-- ID btnCrear para ocultar si es Investigador -->
            <a id="btnCrear" class="btn deshabilitado" href="#" title="Próximamente">+ Registrar Investigador</a>

            <!-- Enlace habilitado al nuevo listado -->
            <a class="btn" href="listadoInvestigadores.jsp">Ver Listado Investigadores</a>

            <a class="btn deshabilitado" href="#" title="Próximamente">Buscar por Id</a>

            <!-- ID btnVolver para redirigir según el rol -->
            <a id="btnVolver" class="volver" href="admin.jsp">← Volver al menú principal</a>
        </div>

        <script src="js/sesion.js"></script>
        <script>
            // 1. Permitimos acceso a Admin e Investigador
            var u = Sesion.exigir(["ADMIN", "ADMINISTRADOR", "INVESTIGADOR"]);
            
            if (u) {
                var rol = (u.rol || "").toUpperCase();
                document.getElementById("saludo").innerText = rol + " · " + u.mail;

                // 2. Si entra un Investigador, ocultamos el botón de crear y ajustamos el retorno
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