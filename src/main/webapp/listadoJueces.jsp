<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Listado de Jueces</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu { max-width: 960px; margin: 40px auto; }
            table { width: 100%; border-collapse: collapse; margin-top: 15px; }
            th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
            th { background-color: #f2f2f2; }
        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo">Administrador</span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Listado de Jueces</h1>

            <table id="tablaJueces">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>DNI</th>
                        <th>Nombre</th>
                        <th>Apellido</th>
                        <th>Juzgado</th>
                        <th>Antigüedad</th>
                    </tr>
                </thead>
                <tbody id="cuerpoTabla">
                    <!-- JS loop render mapping data target insertion point -->
                </tbody>
            </table>

            <div id="mensaje" class="mensaje error" style="display:none; margin-top:15px;"></div>

            <br>
            <a class="volver" href="index.jsp">← Volver al menú</a>
        </div>

        <script src="js/sesion.js"></script>
        <script src="js/vistas.js"></script>
        <script>
            var u = Sesion.exigir(["ADMIN", "ADMINISTRADOR", "INVESTIGADOR"]);
            if (u) {
                document.getElementById("saludo").innerText = u.rol + " · " + u.mail;

                fetch("http://localhost:8080/api/jueces")
                    .then(function(res) {
                        if (!res.ok) {
                            throw new Error("HTTP Error " + res.status);
                        }
                        return res.json();
                    })
                    .then(function(lista) {
                        var tbody = document.getElementById("cuerpoTabla");
                        tbody.innerHTML = "";

                        lista.forEach(function(juez) {
                            var tr = document.createElement("tr");
                            tr.innerHTML = 
                                "<td>" + (juez.id || "") + "</td>" +
                                "<td>" + (juez.dni || "") + "</td>" +
                                "<td>" + (juez.nombre || "") + "</td>" +
                                "<td>" + (juez.apellido || "") + "</td>" +
                                "<td>" + (juez.claveJuzgado || "") + "</td>" +
                                "<td>" + (juez.antiguedadServicio || 0) + " años</td>";
                            tbody.appendChild(tr);
                        });
                    })
                    .catch(function(err) {
                        console.error(err);
                        var msgDiv = document.getElementById("mensaje");
                        msgDiv.innerText = "Error al cargar la lista de jueces (" + err.message + ")";
                        msgDiv.style.display = "block";
                    });
            }
        </script>
    </body>
</html>