<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Registrar Delito</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu {
                max-width: 560px;
                margin: 40px auto;
            }
            .campo {
                margin-bottom: 14px;
            }
            .campo label {
                display: block;
                font-weight: bold;
                margin-bottom: 5px;
            }
            .campo input, .campo select, .campo textarea {
                box-sizing: border-box;
                width: 100%;
                padding: 9px;
                border: 1px solid #ced4da;
                border-radius: 4px;
                font: inherit;
            }
        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo">Administrador</span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Registrar Delito</h1>
            <form id="formDelito" onsubmit="guardar(event)">
                <div class="campo">
                    <label for="descripcion">Descripción del ilícito:</label>
                    <textarea id="descripcion" rows="3" required placeholder="Ej: Robo agravado"></textarea>
                </div>
                <div class="campo">
                    <label for="tipoJuridico">Tipo jurídico:</label>
                    <select id="tipoJuridico" required></select>
                </div>
                <div class="campo">
                    <label for="tipoAccion">Tipo de acción:</label>
                    <select id="tipoAccion" required></select>
                </div>
                <div class="campo">
                    <label for="tipoIntencion">Tipo de intención:</label>
                    <select id="tipoIntencion" required></select>
                </div>
                <button class="btn" id="btnGuardar" type="submit">Registrar delito</button>
            </form>
            <div id="mensaje" class="mensaje error" role="alert"></div>
            <a class="volver" href="menuDelitos.jsp">← Volver al menú de delitos</a>
        </div>

        <script src="js/sesion.js"></script>
        <script src="js/vistas.js"></script>
        <script>
                var u = Sesion.exigir(["ADMIN", "ADMINISTRADOR"]);
                if (u) {
                    document.getElementById("saludo").innerText =
                            (u.rol || "ADMINISTRADOR").toUpperCase() + " · " + (u.mail || "");
                }

                function cargarTipo(idSelect, ruta) {
                    return Vistas.pedir(ruta).then(function (lista) {
                        var select = document.getElementById(idSelect);
                        select.innerHTML = "";
                        var inicial = document.createElement("option");
                        inicial.value = "";
                        inicial.textContent = "— Elegí una opción —";
                        select.appendChild(inicial);
                        lista.forEach(function (tipo) {
                            var opcion = document.createElement("option");
                            opcion.value = tipo.id;
                            opcion.textContent = tipo.nombre + (tipo.descripcion ? " — " + tipo.descripcion : "");
                            select.appendChild(opcion);
                        });
                    });
                }

                Promise.all([
                    cargarTipo("tipoJuridico", "/catalogos/tipos-juridicos"),
                    cargarTipo("tipoAccion", "/catalogos/tipos-accion"),
                    cargarTipo("tipoIntencion", "/catalogos/tipos-intencion")
                ]).catch(function (error) {
                    console.error("No se pudieron cargar los tipos del delito:", error);
                    Vistas.mostrarError("No se pudieron cargar los tipos. Revisá que el backend esté disponible.");
                    document.getElementById("btnGuardar").disabled = true;
                });

                function guardar(event) {
                    event.preventDefault();
                    Vistas.ocultarError();
                    var descripcion = document.getElementById("descripcion").value.trim();
                    var datos = {
                        tipo: descripcion,
                        descripcion: descripcion,
                        idTipoJuridico: Number(document.getElementById("tipoJuridico").value),
                        idTipoAccion: Number(document.getElementById("tipoAccion").value),
                        idTipoIntencion: Number(document.getElementById("tipoIntencion").value)
                    };

                    fetch(API_URL + "/delitos", {
                        method: "POST",
                        headers: {"Content-Type": "application/json"},
                        body: JSON.stringify(datos)
                    }).then(function (respuesta) {
                        return respuesta.text().then(function (texto) {
                            var cuerpo = texto ? JSON.parse(texto) : {};
                            if (!respuesta.ok) {
                                throw new Error(cuerpo.message || "No se pudo registrar el delito.");
                            }
                            return cuerpo;
                        });
                    }).then(function (data) {
                        var mensajeDiv = document.getElementById("mensaje");
                        mensajeDiv.className = "exito";
                        mensajeDiv.innerText = "¡Delito registrado correctamente!" +
                                (data.id ? " ID asignado: " + data.id : "");
                        mensajeDiv.style.display = "block";
                    }).catch(function (error) {
                        console.error(error);
                        Vistas.mostrarError(error.message);
                    });
                }
        </script>
    </body>
</html>
