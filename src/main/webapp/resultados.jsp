<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Resultados - Jueces</title>
</head>
<body>
    <h1>Listado de Jueces</h1>

    <table border="1" cellpadding="8" style="border-collapse: collapse;">
        <thead>
            <tr>
                <th>ID</th>
                <th>DNI</th>
                <th>Nombre</th>
                <th>Apellido</th>
                <th>Juzgado</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="linea" items="${listaParaMostrar}">
                <!-- fn:split divide la cadena por el caracter '|' en un arreglo de columnas -->
                <c:set var="datos" value="${fn:split(linea, '|')}" />
                <tr>
                    <td>${datos[0]}</td>
                    <td>${datos[1]}</td>
                    <td>${datos[2]}</td>
                    <td>${datos[3]}</td>
                    <td>${datos[4]}</td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</body>
</html>