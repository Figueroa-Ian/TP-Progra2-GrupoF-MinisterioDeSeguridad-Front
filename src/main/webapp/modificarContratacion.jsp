<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Modificar Contratación</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu { max-width: 480px; margin: 40px auto; }
            #zonaForm { display: none; }
            .campo { margin-bottom: 14px; }
            label { font-weight: bold; font-size: 14px; display: block; margin-bottom: 5px; }
            input[type="text"], input[type="number"], input[type="date"], textarea { width: 100%; padding: 9px; border: 1px solid #ced4da; border-radius: 4px; box-sizing: border-box; }
            textarea { resize: vertical; height: 70px; }
        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo">Administrador</span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Modificar Contratación</h1>

            <form class="buscador" onsubmit="cargar(event)">
                <input type="number" id="idBuscado" min="1" required autofocus placeholder="Id de la contratación">
                <button type="submit">Cargar</button>
            </form>

            <div id="zonaForm">
                <p id="titulo" style="font-weight:bold"></p>
                <p style="font-size:12px;color:#6c757d;margin-top:0">Actualice los datos de la contratación.</p>
                
                <form id="formModificar" onsubmit="guardar(event)">
                    <div class="campo">
                        <label for="codigoSucursal">ID / Código de Sucursal:</label>
                        <input type="number" id="codigoSucursal" required>
                    </div>
                    <div class="campo">
                        <label for="codigoVigilante">Código de Vigilante:</label>
                        <input type="text" id="codigoVigilante" required>
                    </div>
                    <div class="campo">
                        <label for="fecha">Fecha:</label>
                        <input type="date" id="fecha" required>
                    </div>
                    <div class="campo" style="display: flex; align-items: center; gap: 10px;">
                        <label for="conArma" style="margin: 0; cursor: pointer;">¿Porta arma?:</label>
                        <input type="checkbox" id="conArma" style="width: auto; margin: 0;">
                    </div>
                    <div class="campo">
                        <label for="observaciones">Observaciones (máx. 100 caracteres):</label>
                        <textarea id="observaciones" maxlength="100"></textarea>
                    </div>
                    <button type="submit" id="btnGuardar">Guardar cambios</button>
                </form>
            </div>

            <div id="aviso" class="aviso"></div>

            <a class="volver" href="menuContrataciones.jsp">← Volver al menú</a>
        </div>

        <script src="js/sesion.js"></script>
        <script src="js/vistas.js"></script>
        <script>
            var u = Sesion.exigir(["ADMIN", "ADMINISTRADOR"]);
            if (u) document.getElementById("saludo").innerText = "Administrador · " + u.mail;

            var idActual = null;

            function cargar(event) {
                event.preventDefault();
                document.getElementById("aviso").style.display = "none";
                document.getElementById("zonaForm").style.display = "none";
                idActual = null;

                var id = document.getElementById("idBuscado").value;
                Vistas.pedir("/contrataciones/" + encodeURIComponent(id))
                    .then(function (c) {
                        idActual = c.idContrato || c.id;
                        document.getElementById("codigoSucursal").value = c.codigoSucursal || "";
                        document.getElementById("codigoVigilante").value = c.codigoVigilante || "";
                        document.getElementById("fecha").value = c.fecha || "";
                        document.getElementById("conArma").checked = !!c.conArma;
                        document.getElementById("observaciones").value = c.observaciones || "";

                        document.getElementById("titulo").textContent = "Editando la contratación N° " + idActual;
                        document.getElementById("zonaForm").style.display = "block";
                    })
                    .catch(function (err) {
                        console.error(err);
                        var aviso = document.getElementById("aviso");
                        aviso.className = "aviso error";
                        aviso.textContent = Vistas.textoError(err, "No existe una contratación con ese Id.");
                        aviso.style.display = "block";
                    });
            }

            function guardar(event) {
                event.preventDefault();
                if (idActual === null) return;

                var boton = document.getElementById("btnGuardar");
                boton.disabled = true;

                var contratacionModificada = {
                    codigoSucursal: parseInt(document.getElementById("codigoSucursal").value, 10),
                    codigoVigilante: document.getElementById("codigoVigilante").value,
                    fecha: document.getElementById("fecha").value,
                    conArma: document.getElementById("conArma").checked,
                    observaciones: document.getElementById("observaciones").value
                };

                fetch("http://localhost:8080/api/contrataciones/" + idActual, {
                    method: "PUT",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify(contratacionModificada)
                })
                .then(function (res) {
                    if (res.ok) {
                        return res.json().catch(function() { return {}; });
                    } else {
                        throw new Error("Error en la respuesta del servidor");
                    }
                })
                .then(function () {
                    var aviso = document.getElementById("aviso");
                    aviso.className = "aviso ok";
                    aviso.textContent = "Contratación N° " + idActual + " modificada correctamente.";
                    aviso.style.display = "block";
                })
                .catch(function (err) {
                    console.error(err);
                    var aviso = document.getElementById("aviso");
                    aviso.className = "aviso error";
                    aviso.textContent = "Error al modificar la contratación.";
                    aviso.style.display = "block";
                })
                .then(function () { 
                    boton.disabled = false; 
                });
            }
        </script>
    </body>
</html>