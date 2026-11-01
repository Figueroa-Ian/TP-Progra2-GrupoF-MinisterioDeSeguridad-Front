<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Modificar Sucursal</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu { max-width: 480px; margin: 40px auto; }
            #zonaForm { display: none; }
            .campo { margin-bottom: 14px; }
            label { font-weight: bold; font-size: 14px; display: block; margin-bottom: 5px; }
            input[type="text"], input[type="number"] { width: 100%; padding: 9px; border: 1px solid #ced4da; border-radius: 4px; box-sizing: border-box; }
        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo">Administrador</span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Modificar Sucursal</h1>

            <form class="buscador" onsubmit="cargar(event)">
                <input type="number" id="idBuscado" min="1" required autofocus placeholder="Id de la sucursal">
                <button type="submit">Cargar</button>
            </form>

            <div id="zonaForm">
                <p id="titulo" style="font-weight:bold"></p>
                <p style="font-size:12px;color:#6c757d;margin-top:0">Acá se modifican los datos de la sucursal.</p>
                
                <!-- Formulario de modificación de sucursal -->
                <form id="formModificar" onsubmit="guardar(event)">
                    <div class="campo">
                        <label for="nombreSucursal">Nombre:</label>
                        <input type="text" id="nombreSucursal" required>
                    </div>
                    <div class="campo">
                        <label for="direccionSucursal">Dirección:</label>
                        <input type="text" id="direccionSucursal" required>
                    </div>
                    <button type="submit" id="btnGuardar">Guardar cambios</button>
                </form>
            </div>

            <div id="aviso" class="aviso"></div>

            <a class="volver" href="menuSucursales.jsp">← Volver al menú</a>
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
                Vistas.pedir("/sucursales/" + id)
                    .then(function (s) {
                        idActual = s.id;
                        // Rellenamos los inputs con los datos actuales de la sucursal
                        document.getElementById("nombreSucursal").value = s.nombre || "";
                        document.getElementById("direccionSucursal").value = s.direccion || "";

                        document.getElementById("titulo").textContent = "Editando la sucursal N° " + idActual + (s.nombre ? " — " + s.nombre : "");
                        document.getElementById("zonaForm").style.display = "block";
                    })
                    .catch(function (err) {
                        console.error(err);
                        var aviso = document.getElementById("aviso");
                        aviso.className = "aviso error";
                        aviso.textContent = Vistas.textoError(err, "No existe una sucursal con ese Id.");
                        aviso.style.display = "block";
                    });
            }

            function guardar(event) {
                event.preventDefault();
                if (idActual === null) return;

                var boton = document.getElementById("btnGuardar");
                boton.disabled = true;

                var sucursalModificada = {
                    nombre: document.getElementById("nombreSucursal").value,
                    direccion: document.getElementById("direccionSucursal").value
                };

                fetch("http://localhost:8080/api/sucursales/" + idActual, {
                    method: "PUT",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify(sucursalModificada)
                })
                .then(function (res) {
                    if (res.ok) {
                        return res.json();
                    } else {
                        throw new Error("Error en la respuesta del servidor");
                    }
                })
                .then(function () {
                    var aviso = document.getElementById("aviso");
                    aviso.className = "aviso ok";
                    aviso.textContent = "Sucursal N° " + idActual + " modificada correctamente.";
                    aviso.style.display = "block";
                })
                .catch(function (err) {
                    console.error(err);
                    var aviso = document.getElementById("aviso");
                    aviso.className = "aviso error";
                    aviso.textContent = "Error al modificar la sucursal.";
                    aviso.style.display = "block";
                })
                .then(function () { 
                    boton.disabled = false; 
                });
            }
        </script>
    </body>
</html>