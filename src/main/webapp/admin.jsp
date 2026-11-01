<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Administrador</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu { max-width: 460px; margin: 40px auto; }
        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo">Administrador</span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Menús</h1>

            <a class="btn" href="menuJueces.jsp">Menú Jueces</a>
            <a class="btn" href="menuDelincuentes.jsp">Menú Delincuentes</a>
            <a class="btn" href="menuBandas.jsp">Menú Bandas</a>
            <a class="btn" href="menuSucursales.jsp">Menú Sucursales</a>
            <a class="btn" href="menuInvestigadores.jsp">Menú Investigadores</a>
            <a class="btn" href="menuExpedientes.jsp">Menú Expedientes</a>
<<<<<<< HEAD

            <a class="btn" href="menuVigilantes.jsp">Menú Vigilantes</a>
=======
            <a class="btn" href="menuContrataciones.jsp">Menú Contrataciones</a>
            
            <!-- Pendientes: todavía no hay pantalla en el Front -->
            <a class="btn deshabilitado" href="#" title="Próximamente">Menú Vigilantes</a>
>>>>>>> 835d36d26e20fa41763a644236c78504123dc0f3
        </div>

        <script src="js/sesion.js"></script>
        <script>
            var u = Sesion.exigir(["ADMIN", "ADMINISTRADOR"]);
            if (u) document.getElementById("saludo").innerText = "Administrador · " + u.mail;
        </script>
    </body>
</html>
