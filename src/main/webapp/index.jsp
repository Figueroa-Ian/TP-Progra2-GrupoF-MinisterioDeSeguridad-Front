<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Iniciar sesión</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .login { max-width: 420px; margin: 80px auto; }
            .login h1 { text-align: center; }
        </style>
    </head>
    <body>
        <div class="login contenedor">
            <h1>Sistema</h1>

            <form id="formLogin" onsubmit="iniciarSesion(event)">
                <div class="campo">
                    <label for="mail">Usuario (mail):</label>
                    <input type="email" id="mail" required autofocus placeholder="nombre.apellido@sistema.com">
                </div>
                <div class="campo">
                    <label for="contrasenia">Contraseña:</label>
                    <input type="password" id="contrasenia" required>
                </div>
                <button type="submit" id="btnIngresar">Ingresar</button>
            </form>

            <div id="mensaje" class="mensaje error"></div>
        </div>

        <script src="js/sesion.js"></script>
        <script>
            // Si ya hay sesión iniciada, saltar directo a la vista del rol
            (function () {
                var u = Sesion.obtener();
                if (u && u.rol) window.location.href = Sesion.destino(u.rol);
            })();

            function mostrarError(texto) {
                var m = document.getElementById("mensaje");
                m.innerText = texto;
                m.style.display = "block";
            }

            function iniciarSesion(event) {
                event.preventDefault();
                var btn = document.getElementById("btnIngresar");
                document.getElementById("mensaje").style.display = "none";
                btn.disabled = true;

                fetch(API_URL + "/auth/login", {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({
                        mail: document.getElementById("mail").value.trim(),
                        contrasenia: document.getElementById("contrasenia").value
                    })
                })
                .then(function (res) {
                    if (res.status === 401 || res.status === 404) throw new Error("CREDENCIALES");
                    if (!res.ok) throw new Error("HTTP " + res.status);
                    return res.json();
                })
                .then(function (usuario) {
                    Sesion.guardar(usuario);
                    window.location.href = Sesion.destino(usuario.rol);
                })
                .catch(function (err) {
                    btn.disabled = false;
                    if (err.message === "CREDENCIALES") {
                        mostrarError("Usuario o contraseña incorrectos.");
                    } else if (err instanceof TypeError) {
                        mostrarError("No se pudo conectar con el servidor.");
                    } else {
                        mostrarError("Error al iniciar sesión (" + err.message + ").");
                    }
                });
            }
        </script>
    </body>
</html>
