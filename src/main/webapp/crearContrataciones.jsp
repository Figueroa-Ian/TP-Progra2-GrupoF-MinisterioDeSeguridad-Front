<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <title>Registrar Contratación - Ministerio de Seguridad</title>
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
            input[type="date"],
            textarea {
                width: 100%;
                padding: 9px;
                border: 1px solid #ced4da;
                border-radius: 4px;
                box-sizing: border-box;
                font-size: 14px;
            }
            textarea {
                resize: vertical;
                height: 70px;
            }
            input:focus, textarea:focus {
                border-color: #007bff;
                outline: none;
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
            <h2>Registrar Contratación</h2>

            <form id="formContratacion" onsubmit="guardarContratacion(event)">

                <div class="campo">
                    <label for="codigoSucursal">ID / Código de Sucursal:</label>
                    <input type="number" id="codigoSucursal" required placeholder="Ej: 1">
                </div>

                <div class="campo">
                    <label for="codigoVigilante">Código de Vigilante:</label>
                    <input type="text" id="codigoVigilante" required placeholder="Ej: VIG-001">
                </div>

                <div class="campo">
                    <label for="fecha">Fecha de Contratación:</label>
                    <input type="date" id="fecha" required>
                </div>

                <div class="campo" style="display: flex; align-items: center; gap: 10px;">
                    <label for="conArma" style="margin: 0; cursor: pointer;">¿Porta arma?:</label>
                    <input type="checkbox" id="conArma" style="width: auto; margin: 0;">
                </div>

                <div class="campo">
                    <label for="observaciones">Observaciones (máx. 100 caracteres):</label>
                    <textarea id="observaciones" maxlength="100" placeholder="Detalles o ubicación de cobertura..."></textarea>
                </div>

                <button type="submit">Guardar Contratación</button>
                <a href="admin.jsp" class="btn-volver">← Volver al menú principal</a>
            </form>

            <div id="mensaje"></div>
        </div>

        <script>
            function guardarContratacion(event) {
                event.preventDefault();

                // Construimos el objeto respetando los nombres exactos de la entidad Java
                var nuevaContratacion = {
                    codigoSucursal: parseInt(document.getElementById("codigoSucursal").value, 10),
                    codigoVigilante: document.getElementById("codigoVigilante").value,
                    fecha: document.getElementById("fecha").value, // Formato YYYY-MM-DD que maneja LocalDate
                    conArma: document.getElementById("conArma").checked,
                    observaciones: document.getElementById("observaciones").value
                };

                fetch("http://localhost:8080/api/contrataciones", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify(nuevaContratacion)
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
                            mensajeDiv.innerText = "¡Contratación registrada correctamente! ID de contrato: " + data.idContrato;
                            mensajeDiv.style.display = "block";

                            document.getElementById("formContratacion").reset();
                        })
                        .catch(function (err) {
                            var mensajeDiv = document.getElementById("mensaje");
                            mensajeDiv.className = "error";
                            mensajeDiv.innerText = "Error al registrar la contratación (" + err.message + ")";
                            mensajeDiv.style.display = "block";
                        });
            }
        </script>
    </body>
</html>