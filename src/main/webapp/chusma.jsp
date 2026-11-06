<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Chusma</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu { max-width: 460px; margin: 40px auto; }
        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo">Chusma</span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Consultas</h1>

            <a class="btn" href="menuJueces.jsp">Consultar Jueces</a>
            <a class="btn" href="menuDelincuentes.jsp">Consultar Delincuentes</a>
            <a class="btn" href="menuBandas.jsp">Consultar Bandas</a>
            <a class="btn" href="menuSucursales.jsp">Consultar Sucursales</a>
            <a class="btn" href="menuContrataciones.jsp">Consultar Contrataciones</a>
            <a class="btn" href="menuInvestigadores.jsp">Consultar Investigadores</a>
            <a class="btn" href="menuVigilantes.jsp">Consultar Vigilantes</a>
            <a class="btn" href="menuDelitos.jsp">Consultar Delitos</a>
            
            
            <hr style="margin: 20px 0; border: 1px solid #ced4da;">
            <!-- Única acción de modificación permitida -->
            <a class="btn" style="background:#28a745" href="modificarSucursalDireccion.jsp">Modificar Dirección de Sucursal</a>
            
        </div>

        <script src="js/sesion.js"></script>
        <script>
            // Permitimos acceso a CHUSMA y Admin
            var u = Sesion.exigir(["CHUSMA", "ADMIN", "ADMINISTRADOR"]);
            if (u) {
                var rol = (u.rol || "CHUSMA").toUpperCase();
                document.getElementById("saludo").innerText = rol + " · " + u.mail;
            }
        </script>
    </body>
</html>