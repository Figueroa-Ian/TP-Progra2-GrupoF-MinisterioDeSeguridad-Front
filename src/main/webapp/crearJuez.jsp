<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <title>Registrar Juez - Ministerio del Interior</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 40px auto;
                max-width: 500px;
                background-color: #f4f6f9;
                color: #333;
            }
            .contenedor {
                background: #ffffff;
                padding: 30px;
                border-radius: 8px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            }
            h2 {
                margin-top: 0;
                color: #1a252f;
                border-bottom: 2px solid #007bff;
                padding-bottom: 10px;
            }
            .campo {
                margin-bottom: 14px;
            }
            label {
                font-weight: bold;
                font-size: 14px;
                display: block;
                margin-bottom: 5px;
            }
            input[type="text"], 
            input[type="number"], 
            input[type="date"] {
                width: 100%;
                padding: 9px;
                border: 1px solid #ced4da;
                border-radius: 4px;
                box-sizing: border-box;
                font-size: 14px;
            }
            input:focus {
                border-color: #007bff;
                outline: none;
            }
            .seccion-titulo {
                font-size: 15px;
                font-weight: bold;
                color: #007bff;
                margin-top: 20px;
                margin-bottom: 10px;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }
            button {
                background-color: #007bff;
                color: white;
                padding: 11px;
                border: none;
                border-radius: 4px;
                font-size: 15px;
                font-weight: bold;
                cursor: pointer;
                width: 100%;
                margin-top: 15px;
            }
            button:hover {
                background-color: #0056b3;
            }
            .btn-volver {
                display: block;
                text-align: center;
                margin-top: 12px;
                color: #6c757d;
                text-decoration: none;
                font-size: 14px;
            }
            .btn-volver:hover {
                text-decoration: underline;
            }
            #mensaje {
                margin-top: 15px;
                padding: 12px;
                display: none;
                border-radius: 4px;
                font-size: 14px;
                text-align: center;
            }
            .exito {
                background-color: #d4edda;
                color: #155724;
                border: 1px solid #c3e6cb;
            }
            .error {
                background-color: #f8d7da;
                color: #721c24;
                border: 1px solid #f5c6cb;
            }
        </style>
    </head>
    <body>
        <div class="contenedor">
            <h2>Registrar Nuevo Juez</h2>

            <form id="formJuez" onsubmit="guardarJuez(event)">
                <!-- Datos de Persona -->
                <div class="campo">
                    <label for="dni">DNI:</label>
                    <input type="text" id="dni" required placeholder="Ej: 35894123">
                </div>

                <div class="campo">
                    <label for="nombre">Nombre:</label>
                    <input type="text" id="nombre" required placeholder="Ej: Carlos">
                </div>

                <div class="campo">
                    <label for="apellido">Apellido:</label>
                    <input type="text" id="apellido" required placeholder="Ej: Pérez">
                </div>

                <div class="campo">
                    <label for="direccion">Dirección:</label>
                    <input type="text" id="direccion" placeholder="Ej: Av. Rivadavia 4500">
                </div>

                <div class="campo">
                    <label for="fechaNacimiento">Fecha de Nacimiento:</label>
                    <input type="date" id="fechaNacimiento" required>
                </div>

                <!-- Datos propios de Juez -->
                <div class="seccion-titulo">Datos del Juzgado</div>

                <div class="campo">
                    <label for="claveJuzgado">Clave del Juzgado:</label>
                    <input type="text" id="claveJuzgado" required placeholder="Ej: JUZ-CIV-04">
                </div>

                <div class="campo">
                    <label for="antiguedadServicio">Años de Antigüedad:</label>
                    <input type="number" id="antiguedadServicio" min="0" required placeholder="Ej: 12">
                </div>

                <button type="submit">Guardar Juez</button>
                <a href="menuJueces.jsp" class="btn-volver">← Volver al menú</a>
            </form>

            <div id="mensaje"></div>
        </div>

        <script src="js/sesion.js"></script>
        <script>
            Sesion.exigir(["ADMIN", "ADMINISTRADOR"]);
            function guardarJuez(event) {
                event.preventDefault();

                var nuevoJuez = {
                    dni: document.getElementById("dni").value,
                    nombre: document.getElementById("nombre").value,
                    apellido: document.getElementById("apellido").value,
                    direccion: document.getElementById("direccion").value,
                    fechaNacimiento: document.getElementById("fechaNacimiento").value,
                    rol: "JUEZ",
                    claveJuzgado: document.getElementById("claveJuzgado").value,
                    antiguedadServicio: parseInt(document.getElementById("antiguedadServicio").value, 10) || 0
                };

                fetch(API_URL + "/jueces", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify(nuevoJuez)
                })
                .then(function(res) {
                    if (res.ok) {
                        return res.json();
                    }
                    // Se lee el mensaje que manda el servidor (edad, DNI repetido, etc.)
                    return res.text().then(function(texto) {
                        var detalle = "";
                        try { detalle = JSON.parse(texto).message || ""; } catch (e) { /* sin cuerpo JSON */ }
                        var err = new Error("HTTP " + res.status);
                        err.estado = res.status;
                        err.detalle = detalle;
                        throw err;
                    });
                }, function() {
                    throw new Error("RED");   // solo acá es un problema de conexión
                })
                .then(function(data) {
                    var mensajeDiv = document.getElementById("mensaje");
                    mensajeDiv.className = "exito";
                    mensajeDiv.innerText = "¡Juez registrado correctamente! ID asignado: " + data.id;
                    mensajeDiv.style.display = "block";

                    document.getElementById("formJuez").reset();
                })
                .catch(function(err) {
                    var mensajeDiv = document.getElementById("mensaje");
                    var texto;
                    if (err.message === "RED") texto = "No se pudo conectar con el servidor.";
                    else if (err.detalle) texto = err.detalle;
                    else if (err.estado === 409) texto = "Esa clave o DNI ya está registrada.";
                    else texto = "Error al registrar el juez (" + err.message + ")";
                    mensajeDiv.className = "error";
                    mensajeDiv.innerText = texto;
                    mensajeDiv.style.display = "block";
                });
            }
        </script>
    </body>
</html>