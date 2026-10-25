<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Ministerio de Seguridad - Inicio</title>
    </head>
    <body>
        <h1>Sistema de Seguridad</h1>
        <p>Seleccione una opción para consultar:</p>

        <!-- Enlace que dispara el método doGet del Servlet mapeado en /buscar -->
        <a href="buscar">Ver Nómina de Jueces</a>
        <a href="crearJuez.jsp" style="display: inline-block; margin-bottom: 15px; padding: 8px 12px; background: #28a745; color: white; text-decoration: none; border-radius: 4px;">
            + Registrar Nuevo Juez
        </a>
    </body>
</html>