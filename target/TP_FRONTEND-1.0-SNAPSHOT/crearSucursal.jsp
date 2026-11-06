<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <title>Registrar Sucursal - Ministerio del Interior</title>
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
            <h2>Registrar Nuevo Sucursal</h2>

            <form id="formSucursal" onsubmit="guardarSucursal(event)">
                <!-- Datos de Sucursal -->
                <div class="campo">
                    <label for="codigo_entidad">Codigo de la Suc:</label>
                    <input type="text" id="codigo_entidad" required placeholder="Ej: SUC-001">
                </div>

                <div class="campo">
                    <label for="numero_empleados">Cantidad de empleados:</label>
                    <input type="number" id="numero_empleados" min="0" required placeholder="Ej: 12">
                </div>

                <div class="campo">
                    <label for="direccion">Dirección:</label>
                    <input type="text" id="direccion" placeholder="Ej: Av. Rivadavia 4500">
                </div>

                <div class="campo" style="display: flex; align-items: center; gap: 10px;">
                    <label for="es_central" style="margin: 0; cursor: pointer;">Es sucursal central:</label>
                    <input type="checkbox" id="es_central" style="width: auto; margin: 0;">
                </div>

                <button type="submit">Guardar Sucursal</button>
                <a href="menuSucursales.jsp" class="btn-volver">← Volver al menú</a>
            </form>

            <div id="mensaje"></div>
        </div>

        <script src="js/sesion.js"></script>
        <script>
            Sesion.exigir(["ADMIN", "ADMINISTRADOR"]);
            function guardarSucursal(event) {
                event.preventDefault();

                var nuevoSucursal = {
                    codigo_entidad: document.getElementById("codigo_entidad").value,
                    direccion: document.getElementById("direccion").value,
                    numero_empleados: parseInt(document.getElementById("numero_empleados").value, 10) || 0, // <-- CORREGIDO AQUÍ
                    es_central: document.getElementById("es_central").checked
                };

                fetch(API_URL + "/sucursales", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify(nuevoSucursal)
                })
                    .then(function (res) {
                        if (res.status === 201 || res.ok) {
                            return res.json();
                        } else {
                            throw new Error("HTTP " + res.status);
                        }
                    })
                    .then(function (data) {
                        var mensajeDiv = document.getElementById("mensaje");
                        mensajeDiv.className = "exito";
                        mensajeDiv.innerText = "¡Sucursal registrada correctamente! ID asignado: " + data.id;
                        mensajeDiv.style.display = "block";

                        document.getElementById("formSucursal").reset();
                    })
                    .catch(function (err) {
                        var mensajeDiv = document.getElementById("mensaje");
                        mensajeDiv.className = "error";
                        mensajeDiv.innerText = "Error al registrar la sucursal (" + err.message + ")";
                        mensajeDiv.style.display = "block";
                    });
            }
        </script>
    </body>
</html>