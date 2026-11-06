<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Listado de Investigadores</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu { max-width: 1100px; margin: 40px auto; }
            .tabla-scroll { overflow-x: auto; }
            .tabla-investigadores { width: 100%; border-collapse: collapse; margin-top: 16px; }
            .tabla-investigadores th,
            .tabla-investigadores td { border: 1px solid #e3e7ec; padding: 10px; text-align: left; }
            .tabla-investigadores th { background: #f4f6f9; }
            .estado { text-align: center !important; color: #6c757d; }
            #mensaje { display: none; margin-top: 16px; }
        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo">Investigador</span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Listado de Investigadores</h1>

            <div class="tabla-scroll">
                <table class="tabla-investigadores">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>DNI</th>
                            <th>Nombre</th>
                            <th>Apellido</th>
                            <th>Dirección</th>
                            <th>Fecha de nacimiento</th>
                            <th>Rol</th>
                        </tr>
                    </thead>
                    <tbody id="cuerpoTabla">
                        <tr><td class="estado" colspan="7">Cargando investigadores…</td></tr>
                    </tbody>
                </table>
            </div>

            <div id="mensaje" class="mensaje error" role="alert"></div>
            <a id="btnVolver" class="volver" href="menuInvestigadores.jsp">← Volver al menú</a>
        </div>

        <script src="js/sesion.js"></script>
        <script>
            var usuario = Sesion.exigir(["ADMIN", "ADMINISTRADOR", "INVESTIGADOR", "CHUSMA"]);

            if (usuario) {
                var rolUsuario = (usuario.rol || "").toUpperCase();
                document.getElementById("saludo").textContent = rolUsuario + " · " + (usuario.mail || "");

                if (rolUsuario === "INVESTIGADOR") {
                    document.getElementById("btnVolver").href = "investigador.jsp";
                }

                function textoCelda(valor) {
                    if (valor === null || valor === undefined || valor === "") return "—";
                    if (Array.isArray(valor)) return valor.join("-");
                    return String(valor);
                }

                function agregarCelda(fila, valor) {
                    var celda = document.createElement("td");
                    celda.textContent = textoCelda(valor);
                    fila.appendChild(celda);
                }

                var cuerpoTabla = document.getElementById("cuerpoTabla");
                var mensaje = document.getElementById("mensaje");

                fetch(API_URL + "/investigadores", { headers: { "Accept": "application/json" } })
                    .then(function (respuesta) {
                        if (!respuesta.ok) throw new Error("HTTP " + respuesta.status);
                        return respuesta.json();
                    })
                    .then(function (investigadores) {
                        if (!Array.isArray(investigadores)) {
                            throw new Error("La respuesta del servidor no es una lista.");
                        }

                        cuerpoTabla.innerHTML = "";
                        if (investigadores.length === 0) {
                            var filaVacia = document.createElement("tr");
                            var celdaVacia = document.createElement("td");
                            celdaVacia.className = "estado";
                            celdaVacia.colSpan = 7;
                            celdaVacia.textContent = "No hay investigadores registrados.";
                            filaVacia.appendChild(celdaVacia);
                            cuerpoTabla.appendChild(filaVacia);
                            return;
                        }

                        investigadores.forEach(function (investigador) {
                            var fila = document.createElement("tr");
                            agregarCelda(fila, investigador.id);
                            agregarCelda(fila, investigador.dni);
                            agregarCelda(fila, investigador.nombre);
                            agregarCelda(fila, investigador.apellido);
                            agregarCelda(fila, investigador.direccion);
                            agregarCelda(fila, investigador.fechaNacimiento);
                            agregarCelda(fila, investigador.rol);
                            cuerpoTabla.appendChild(fila);
                        });
                    })
                    .catch(function (error) {
                        console.error("No se pudo mostrar el listado de investigadores:", error);
                        cuerpoTabla.innerHTML = "";
                        var filaError = document.createElement("tr");
                        var celdaError = document.createElement("td");
                        celdaError.className = "estado";
                        celdaError.colSpan = 7;
                        celdaError.textContent = "No se pudo cargar el listado.";
                        filaError.appendChild(celdaError);
                        cuerpoTabla.appendChild(filaError);
                        mensaje.textContent = "Error al cargar investigadores: " + error.message;
                        mensaje.style.display = "block";
                    });
            }
        </script>
    </body>