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
                <div id="contenedorForm"></div>
            </div>

            <div id="aviso" class="aviso"></div>

            <a class="volver" href="menuSucursales.jsp">← Volver al menú</a>
        </div>

        <script src="js/sesion.js"></script>
        <script src="js/vistas.js"></script>
        <script src="js/sucursales.js"></script>
        <script>
            var u = Sesion.exigir(["ADMIN", "ADMINISTRADOR"]);
            if (u) document.getElementById("saludo").innerText = "Administrador · " + u.mail;

            var idActual = null;
            Sucursales.montar("contenedorForm", false, "Guardar cambios", guardar);

            function cargar(event) {
                event.preventDefault();
                Sucursales.ocultarAviso();
                document.getElementById("zonaForm").style.display = "none";
                idActual = null;

                var id = document.getElementById("idBuscado").value;
                Vistas.pedir(Sucursales.rutas.buscar(id))
                    .then(function (s) {
                        idActual = s.id;
                        Sucursales.llenar(s);
                        var nombre = s.nombre || ("Sucursal N° " + idActual);
                        document.getElementById("titulo").textContent = "Editando la sucursal N° " + idActual + (s.nombre ? " — " + s.nombre : "");
                        document.getElementById("zonaForm").style.display = "block";
                    })
                    .catch(function (err) {
                        console.error(err);
                        Sucursales.aviso("err", Vistas.textoError(err, "No existe una sucursal con ese Id."));
                    });
            }

            function guardar(sucursal) {
                if (idActual === null) return;
                var boton = document.getElementById("btnGuardar");
                if (boton) boton.disabled = true;
                Sucursales.ocultarAviso();
                Sucursales.enviar("PUT", Sucursales.rutas.modificar(idActual), sucursal)
                    .then(function () {
                        Sucursales.aviso("ok", "Sucursal N° " + idActual + " modificada correctamente.");
                    })
                    .catch(function (err) {
                        console.error(err);
                        Sucursales.aviso("err", Sucursales.textoError(err, "modificar la sucursal"));
                    })
                    .then(function () { 
                        if (boton) boton.disabled = false; 
                    });
            }
        </script>
    </body>
</html>