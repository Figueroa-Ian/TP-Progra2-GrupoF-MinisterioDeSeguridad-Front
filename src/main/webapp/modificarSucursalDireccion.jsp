<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Modificar Dirección de Sucursal</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu { max-width: 480px; margin: 40px auto; }
            #zonaForm { display: none; margin-top: 20px; }
            .campo { margin-bottom: 15px; }
            .campo label { display: block; margin-bottom: 5px; font-weight: bold; }
            .campo input { width: 100%; padding: 8px; box-sizing: border-box; }
        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo">Administrador</span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Modificar Dirección</h1>

            <form class="buscador" onsubmit="cargar(event)">
                <input type="number" id="idBuscado" min="1" required autofocus placeholder="Id de la sucursal">
                <button type="submit">Buscar</button>
            </form>

            <div id="zonaForm">
                <p id="titulo" style="font-weight:bold"></p>
                <p style="font-size:12px;color:#6c757d;margin-top:0">Actualice únicamente la dirección de esta sucursal.</p>
                
                <!-- Formulario estático solo para la dirección -->
                <form id="formDireccion" onsubmit="guardar(event)">
                    <div class="campo">
                        <label for="direccionInput">Dirección:</label>
                        <input type="text" id="direccionInput" required placeholder="Ej: Av. Corrientes 1234">
                    </div>
                    <button type="submit" id="btnGuardar">Guardar dirección</button>
                </form>
            </div>

            <div id="aviso" class="aviso"></div>

            <a class="volver" href="menuSucursales.jsp">← Volver al menú</a>
        </div>

        <script src="js/sesion.js"></script>
        <script src="js/vistas.js"></script>
        <script src="js/sucursales.js"></script>
        <script>
            var u = Sesion.exigir(["ADMIN", "ADMINISTRADOR", "CHUSMA"]);
            if (u) document.getElementById("saludo").innerText = "Administrador · " + u.mail;

            var idActual = null;
            var sucursalOriginal = null; // Guardamos el objeto completo para el PUT

            function cargar(event) {
                event.preventDefault();
                Sucursales.ocultarAviso();
                document.getElementById("zonaForm").style.display = "none";
                idActual = null;
                sucursalOriginal = null;

                var id = document.getElementById("idBuscado").value;
                Vistas.pedir(Sucursales.rutas.buscar(id))
                    .then(function (s) {
                        idActual = s.id;
                        sucursalOriginal = s; // Almacenamos los datos originales (nombre, telefono, etc.)
                        
                        // Cargamos solo la dirección en el input
                        document.getElementById("direccionInput").value = s.direccion || "";
                        
                        document.getElementById("titulo").textContent = "Editando la sucursal N° " + idActual + (s.nombre ? " — " + s.nombre : "");
                        document.getElementById("zonaForm").style.display = "block";
                    })
                    .catch(function (err) {
                        console.error(err);
                        Sucursales.aviso("err", Vistas.textoError(err, "No existe una sucursal con ese Id."));
                    });
            }

            function guardar(event) {
                event.preventDefault();
                if (idActual === null || sucursalOriginal === null) return;
                
                var boton = document.getElementById("btnGuardar");
                if (boton) boton.disabled = true;
                Sucursales.ocultarAviso();

                // Actualizamos únicamente la propiedad dirección del objeto original
                sucursalOriginal.direccion = document.getElementById("direccionInput").value;

                // Enviamos el objeto completo actualizado por PUT
                Sucursales.enviar("PUT", Sucursales.rutas.modificar(idActual), sucursalOriginal)
                    .then(function () {
                        Sucursales.aviso("ok", "Dirección de la sucursal N° " + idActual + " modificada correctamente.");
                    })
                    .catch(function (err) {
                        console.error(err);
                        Sucursales.aviso("err", Sucursales.textoError(err, "modificar la dirección"));
                    })
                    .then(function () { 
                        if (boton) boton.disabled = false; 
                    });
            }
        </script>
    </body>
</html>