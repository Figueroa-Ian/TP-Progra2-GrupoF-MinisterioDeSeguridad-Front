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
            .error { color: #721c24; background-color: #f8d7da; padding: 10px; border-radius: 4px; }
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
                    <!-- Filas cargadas dinámicamente -->
                </tbody>
            </table>

            <div id="mensaje" class="mensaje error" style="display:none; margin-top:15px;"></div>

            <br>
            <a class="volver" href="index.jsp">← Volver al menú</a>
        </div>

        <script src="js/sesion.js"></script>
        <script>
            var u = Sesion.exigir(["ADMIN", "ADMINISTRADOR", "INVESTIGADOR"]);
            if (u) {
                document.getElementById("saludo").innerText = (u.rol || "Administrador") + " · " + (u.mail || "");

                // Petición al endpoint de Jueces en Spring Boot
                fetch("http://localhost:8080/api/jueces")
                    .then(function (res) {
                        if (!res.ok) throw new Error("HTTP " + res.status);
                        return res.json();
                    })
                    .then(function (lista) {
                        var tbody = document.getElementById("cuerpoTabla");
                        tbody.innerHTML = "";

                        if (lista.length === 0) {
                            tbody.innerHTML = "<tr><td colspan='6'>No hay jueces registrados.</td></tr>";
                            return;
                        }

                        lista.forEach(function (juez) {
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
                    .catch(function (err) {
                        console.error("Error al cargar jueces:", err);
                        var msgDiv = document.getElementById("mensaje");
                        msgDiv.innerText = "Error al obtener el listado de jueces (" + err.message + ")";
                        msgDiv.style.display = "block";
                    });
            }
        </script>
    </body>
</html>