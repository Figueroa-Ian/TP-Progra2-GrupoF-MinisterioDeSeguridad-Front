<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Registrar Banda</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu { max-width: 460px; margin: 40px auto; }
            .campo { margin-bottom: 14px; }
            .campo label { font-weight: bold; font-size: 14px; display: block; margin-bottom: 5px; }
            .campo input {
                width: 100%;
                padding: 9px;
                border: 1px solid #ced4da;
                border-radius: 4px;
                box-sizing: border-box;
                font-size: 14px;
            }
            .campo input:focus { border-color: #007bff; outline: none; }
            .ayuda { font-size: 12px; color: #6c757d; margin-top: 4px; }
            #btnGuardar {
                background: #007bff;
                color: #fff;
                padding: 11px;
                border: none;
                border-radius: 4px;
                font-size: 15px;
                font-weight: bold;
                cursor: pointer;
                width: 100%;
                margin-top: 10px;
            }
            #btnGuardar:hover { background: #0056b3; }
            #btnGuardar:disabled { background: #9bbbe0; cursor: not-allowed; }
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
            .volver {
                display: block;
                text-align: center;
                margin-top: 16px;
                color: #6c757d;
                text-decoration: none;
                font-size: 14px;
            }
            .volver:hover { text-decoration: underline; }
        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo">Administrador</span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Registrar Banda</h1>

            <form id="formBanda" onsubmit="guardarBanda(event)">
                <div class="campo">
                    <label for="nombreBanda">Nombre de la banda:</label>
                    <input type="text" id="nombreBanda" required maxlength="100" autofocus placeholder="Ej: Los Halcones">
                    <div class="ayuda">El número de banda lo asigna el sistema. Los integrantes se suman después, al registrar delincuentes en esta banda.</div>
                </div>

                <button type="submit" id="btnGuardar">Guardar Banda</button>
            </form>

            <div id="aviso"></div>

            <a class="volver" href="menuBandas.jsp">← Volver al menú</a>
        </div>

        <script src="js/sesion.js"></script>
        <script>
            var u = Sesion.exigir(["ADMIN", "ADMINISTRADOR"]);
            if (u) document.getElementById("saludo").innerText = "Administrador · " + u.mail;

            function aviso(tipo, texto) {
                var a = document.getElementById("aviso");
                a.className = tipo;
                a.textContent = texto;
                a.style.display = "block";
            }

            function guardarBanda(event) {
                event.preventDefault();

                var nombre = document.getElementById("nombreBanda").value.trim();
                if (!nombre) {
                    aviso("err", "El nombre de la banda es obligatorio.");
                    return;
                }

                var nuevaBanda = {
                    nombreBanda: nombre,
                    numeroMiembros: 0   // una banda nueva arranca sin integrantes
                };

                var boton = document.getElementById("btnGuardar");
                boton.disabled = true;
                document.getElementById("aviso").style.display = "none";

                // POST /api/bandas/crear/banda  (BandaController.crearBanda)
                fetch(API_URL + "/bandas/crear/banda", {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify(nuevaBanda)
                }).then(function (res) {
                    if (!res.ok) throw new Error("HTTP " + res.status);
                    return res.json();
                }, function () {
                    throw new Error("RED");   // solo acá es un problema de conexión
                }).then(function (creada) {
                    aviso("ok", "¡Banda registrada! N° de banda asignado: " + creada.numeroBanda);
                    document.getElementById("formBanda").reset();
                }).catch(function (err) {
                    console.error(err);
                    aviso("err", err.message === "RED"
                        ? "No se pudo conectar con el servidor."
                        : "No se pudo registrar la banda (" + err.message + ").");
                }).then(function () {
                    boton.disabled = false;
                    document.getElementById("nombreBanda").focus();
                });
            }
        </script>
    </body>
</html>
