<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Menú Bandas</title>
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
            <h1>Menú Bandas</h1>
            <a id="btnCrear" class="btn" href="crearBanda.jsp">+ Registrar Banda</a>
            <a class="btn" href="listadoBandas.jsp">Ver Listado Bandas</a>
            <a class="btn" href="buscarBanda.jsp">Buscar por Id</a>
            <a class="btn" href="delincuentesDeBanda.jsp">Ver delincuentes de banda</a>

            <a id="btnVolver" class="volver" href="admin.jsp">← Volver al menú principal</a>
        </div>

        <script src="js/sesion.js"></script>
        <script>
            var u = Sesion.exigir(["ADMIN", "ADMINISTRADOR", "INVESTIGADOR", "CHUSMA"]);
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
