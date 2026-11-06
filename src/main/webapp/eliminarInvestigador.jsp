<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Eliminar Investigador</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu { max-width: 460px; margin: 40px auto; }
            #zonaEliminar { display: none; margin-top: 16px; }
            #btnEliminar {
                background: #dc3545;
                color: #fff;
                padding: 11px;
                border: none;
                border-radius: 4px;
                font-size: 15px;
                font-weight: bold;
                cursor: pointer;
                width: 100%;
            }
            #btnEliminar:hover { background: #b02a37; }
            #btnEliminar:disabled { background: #e8a0a8; cursor: not-allowed; }
            #aviso {
                display: none;
                margin-top: 15px;
                padding: 12px;
                border-radius: 4px;
                font-size: 14px;
                text-align: center;
            }
            #aviso.ok { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
            #aviso.err { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo">Administrador</span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Eliminar Investigador</h1>

            <form class="buscador" onsubmit="buscar(event)">
                <input type="number" id="idBuscado" min="0" required autofocus placeholder="Id del investigador">
                <button type="submit">Buscar</button>
            </form>

            <div id="resultado" class="ficha"></div>
            <div id="zonaEliminar">
                <button type="button" id="btnEliminar" onclick="eliminar()">Eliminar este investigador</button>
            </div>
            <div id="mensaje" class="mensaje error"></div>
            <div id="aviso"></div>

            <a class="volver" href="menuInvestigadores.jsp">← Volver al menú</a>
        </div>

        <script src="js/sesion.js"></script>
        <script src="js/vistas.js"></script>
        <script>
            // Solo el administrador puede eliminar
            var u = Sesion.exigir(["ADMIN", "ADMINISTRADOR"]);
            if (u) document.getElementById("saludo").innerText = "Administrador · " + u.mail;

            var idActual = null;

            function aviso(tipo, texto) {
                var a = document.getElementById("aviso");
                a.className = tipo;
                a.textContent = texto;
                a.style.display = "block";
            }

            function buscar(event) {
                event.preventDefault();
                Vistas.ocultarError();
                document.getElementById("aviso").style.display = "none";
                document.getElementById("resultado").innerHTML = "";
                document.getElementById("zonaEliminar").style.display = "none";
                idActual = null;

                var id = document.getElementById("idBuscado").value;
                Vistas.pedir("/investigadores/" + encodeURIComponent(id))
                    .then(function (dato) {
                        idActual = id;
                        Vistas.ficha(document.getElementById("resultado"), dato);
                        document.getElementById("zonaEliminar").style.display = "block";
                    })
                    .catch(function (err) {
                        console.error(err);
                        Vistas.mostrarError(Vistas.textoError(err, "No existe un investigador con ese Id."));
                    });
            }

            function eliminar() {
                if (idActual === null) return;
                if (!window.confirm("¿Seguro que querés eliminar al investigador N° " + idActual + "? Esta acción no se puede deshacer.")) return;

                var boton = document.getElementById("btnEliminar");
                boton.disabled = true;
                document.getElementById("aviso").style.display = "none";

                // DELETE /investigadores/eliminar/{id}
                fetch(API_URL + "/investigadores/eliminar/" + encodeURIComponent(idActual), { method: "DELETE" })
                    .then(function (res) {
                        if (res.ok) return null;
                        return res.text().then(function (texto) {
                            var detalle = "";
                            try { detalle = JSON.parse(texto).message || ""; } catch (e) { /* sin cuerpo JSON */ }
                            var err = new Error("HTTP " + res.status);
                            err.estado = res.status;
                            err.detalle = detalle;
                            throw err;
                        });
                    }, function () {
                        throw new Error("RED");   // solo acá es un problema de conexión
                    })
                    .then(function () {
                        aviso("ok", "Investigador N° " + idActual + " eliminado.");
                        document.getElementById("resultado").innerHTML = "";
                        document.getElementById("zonaEliminar").style.display = "none";
                        document.getElementById("idBuscado").value = "";
                        idActual = null;
                    })
                    .catch(function (err) {
                        console.error(err);
                        var texto;
                        if (err.message === "RED") texto = "No se pudo conectar con el servidor.";
                        else if (err.estado === 404) texto = "No existe un investigador con ese Id.";
                        else if (err.detalle) texto = err.detalle;
                        else if (err.estado === 409) texto = "No se puede eliminar: el investigador tiene un usuario u otros registros asociados.";
                        else texto = "No se pudo eliminar el investigador (" + err.message + ").";
                        aviso("err", texto);
                    })
                    .then(function () { boton.disabled = false; });
            }
        </script>
    </body>
</html>
