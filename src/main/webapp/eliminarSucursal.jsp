<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Eliminar Sucursal</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu { max-width: 520px; margin: 40px auto; }
            #zonaEliminar { display: none; margin-top: 16px; }
        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo">Administrador</span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Eliminar Sucursal</h1>

            <form class="buscador" onsubmit="buscar(event)">
                <input type="number" id="idBuscado" min="1" required autofocus placeholder="Id de la sucursal">
                <button type="submit">Buscar</button>
            </form>

            <div id="resultado" class="ficha"></div>
            <div id="zonaEliminar">
                <button type="button" id="btnEliminar" class="btn-accion btn-peligro" onclick="eliminar()">Eliminar esta sucursal</button>
            </div>
            <div id="mensaje" class="mensaje error"></div>
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

            function buscar(event) {
                event.preventDefault();
                Vistas.ocultarError();
                Sucursales.ocultarAviso();
                document.getElementById("resultado").innerHTML = "";
                document.getElementById("zonaEliminar").style.display = "none";
                idActual = null;

                var id = document.getElementById("idBuscado").value;
                Vistas.pedir(Sucursales.rutas.buscar(id))
                    .then(function (s) {
                        idActual = s.id;
                        Vistas.ficha(document.getElementById("resultado"), Sucursales.legible ? Sucursales.legible(s) : s);
                        document.getElementById("zonaEliminar").style.display = "block";
                    })
                    .catch(function (err) {
                        console.error(err);
                        Vistas.mostrarError(Vistas.textoError(err, "No existe una sucursal con ese Id."));
                    });
            }

            function eliminar() {
                if (idActual === null) return;
                if (!window.confirm("¿Seguro que querés eliminar la sucursal N° " + idActual + "? Esta acción no se puede deshacer.")) return;

                var boton = document.getElementById("btnEliminar");
                boton.disabled = true;
                Sucursales.ocultarAviso();
                Sucursales.enviar("DELETE", Sucursales.rutas.eliminar(idActual))
                    .then(function () {
                        Sucursales.aviso("ok", "Sucursal N° " + idActual + " eliminada.");
                        document.getElementById("resultado").innerHTML = "";
                        document.getElementById("zonaEliminar").style.display = "none";
                        document.getElementById("idBuscado").value = "";
                        idActual = null;
                    })
                    .catch(function (err) {
                        console.error(err);
                        Sucursales.aviso("err", Sucursales.textoError(err, "eliminar la sucursal"));
                    })
                    .then(function () { boton.disabled = false; });
            }
        </script>
    </body>
</html>