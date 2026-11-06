<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Delincuentes de una banda</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu { max-width: 960px; margin: 40px auto; }
            .autocompletar { position: relative; margin-bottom: 16px; }
            .autocompletar input {
                width: 100%;
                box-sizing: border-box;
                padding: 10px;
                border: 1px solid #ced4da;
                border-radius: 4px;
                font-size: 14px;
            }
            .autocompletar input:focus { border-color: #007bff; outline: none; }
            .sugerencias {
                display: none;
                position: absolute;
                left: 0;
                right: 0;
                top: 100%;
                z-index: 10;
                margin: 2px 0 0;
                padding: 0;
                list-style: none;
                background: #fff;
                border: 1px solid #ced4da;
                border-radius: 4px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.1);
                max-height: 260px;
                overflow-y: auto;
            }
            .sugerencias li {
                padding: 10px;
                font-size: 14px;
                cursor: pointer;
                border-bottom: 1px solid #f0f2f5;
            }
            .sugerencias li:last-child { border-bottom: none; }
            .sugerencias li:hover { background: #eaf3ff; }
            .sugerencias li.vacio { color: #6c757d; cursor: default; }
            .sugerencias li.vacio:hover { background: #fff; }
            #titulo-integrantes { display: none; margin: 24px 0 12px; font-size: 18px; color: #1a252f; }
        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo">Administrador</span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Delincuentes de una banda</h1>

            <div class="autocompletar">
                <input type="text" id="buscadorBanda" autocomplete="off" autofocus
                       placeholder="Escribí el nombre de la banda...">
                <ul id="sugerencias" class="sugerencias"></ul>
            </div>

            <h2 id="titulo-integrantes"></h2>
            <div id="resultado"></div>
            <div id="mensaje" class="mensaje error"></div>

            <a class="volver" href="menuBandas.jsp">← Volver al menú</a>
        </div>

        <script src="js/sesion.js"></script>
        <script src="js/vistas.js"></script>
        <script>
            var u = Sesion.exigir(["ADMIN", "ADMINISTRADOR", "INVESTIGADOR"]);
            if (u) document.getElementById("saludo").innerText = "Administrador · " + u.mail;

            var RETRASO_MS = 250;                                   // espera después de la última tecla
            var CAMPOS_NUMERO = ["numeroBanda", "id", "numero"];    // posibles nombres del Id de la banda en el JSON
            var CAMPOS_NOMBRE = ["nombreBanda", "nombre"];          // posibles nombres del nombre de la banda

            var entrada = document.getElementById("buscadorBanda");
            var lista = document.getElementById("sugerencias");
            var titulo = document.getElementById("titulo-integrantes");
            var resultado = document.getElementById("resultado");

            var temporizador = null;
            var consultaSugerencias = 0;   // sirve para descartar respuestas que llegan tarde
            var consultaIntegrantes = 0;

            function primerCampo(obj, candidatos) {
                for (var i = 0; i < candidatos.length; i++) {
                    var v = obj[candidatos[i]];
                    if (v !== undefined && v !== null) return v;
                }
                return null;
            }

            function ocultarSugerencias() {
                lista.style.display = "none";
                lista.innerHTML = "";
            }

            function limpiarIntegrantes() {
                consultaIntegrantes++;
                titulo.style.display = "none";
                titulo.textContent = "";
                resultado.innerHTML = "";
            }

            function mostrarSugerencias(bandas) {
                lista.innerHTML = "";
                var validas = 0;
                var hayDatos = Array.isArray(bandas) && bandas.length > 0;

                if (hayDatos) {
                    bandas.forEach(function (b) {
                        var numero = primerCampo(b, CAMPOS_NUMERO);
                        var nombre = primerCampo(b, CAMPOS_NOMBRE);
                        if (numero === null || nombre === null) return;
                        validas++;
                        var li = document.createElement("li");
                        li.textContent = nombre;
                        li.addEventListener("click", function () { elegirBanda(numero, nombre); });
                        lista.appendChild(li);
                    });
                }

                if (hayDatos && !validas) {
                    ocultarSugerencias();
                    Vistas.mostrarError("No se reconocieron los campos de la banda (se esperaba numeroBanda y nombreBanda).");
                    return;
                }
                if (!validas) {
                    var vacio = document.createElement("li");
                    vacio.className = "vacio";
                    vacio.textContent = "No hay bandas que coincidan";
                    lista.appendChild(vacio);
                }
                lista.style.display = "block";
            }

            function buscarSugerencias(texto) {
                var consulta = ++consultaSugerencias;
                Vistas.pedir("/bandas/buscar/bandas/nombreParcial/" + encodeURIComponent(texto))
                    .then(function (bandas) {
                        if (consulta !== consultaSugerencias) return;   // llegó tarde, ya se escribió otra cosa
                        mostrarSugerencias(bandas);
                    })
                    .catch(function (err) {
                        if (consulta !== consultaSugerencias) return;
                        console.error(err);
                        ocultarSugerencias();
                        Vistas.mostrarError(Vistas.textoError(err, "No se encontró el servicio de búsqueda de bandas."));
                    });
            }

            function elegirBanda(numero, nombre) {
                consultaSugerencias++;         // cancela cualquier sugerencia pendiente
                clearTimeout(temporizador);
                entrada.value = nombre;
                ocultarSugerencias();
                cargarIntegrantes(numero, nombre);
            }

            function cargarIntegrantes(numero, nombre) {
                limpiarIntegrantes();
                var consulta = consultaIntegrantes;
                titulo.textContent = "Integrantes de " + nombre;
                titulo.style.display = "block";

                Vistas.pedir("/delincuentes/buscar/delincuentes/numeroBanda/" + encodeURIComponent(numero))
                    .then(function (miembros) {
                        if (consulta !== consultaIntegrantes) return;
                        if (!Array.isArray(miembros) || !miembros.length) {
                            var p = document.createElement("p");
                            p.textContent = "Esta banda no tiene delincuentes registrados.";
                            resultado.appendChild(p);
                            return;
                        }
                        Vistas.tabla(resultado, miembros);
                    })
                    .catch(function (err) {
                        if (consulta !== consultaIntegrantes) return;
                        console.error(err);
                        Vistas.mostrarError(Vistas.textoError(err, "No se encontraron integrantes para esta banda."));
                    });
            }

            entrada.addEventListener("input", function () {
                clearTimeout(temporizador);
                Vistas.ocultarError();
                limpiarIntegrantes();                      // el texto cambió: los integrantes mostrados ya no corresponden
                var texto = entrada.value.trim();
                if (!texto) {
                    consultaSugerencias++;
                    ocultarSugerencias();
                    return;
                }
                temporizador = setTimeout(function () { buscarSugerencias(texto); }, RETRASO_MS);
            });

            entrada.addEventListener("keydown", function (e) {
                if (e.key === "Escape") ocultarSugerencias();
            });

            // Click fuera del buscador cierra el desplegable
            document.addEventListener("click", function (e) {
                if (!e.target.closest(".autocompletar")) ocultarSugerencias();
            });
        </script>
    </body>
</html>
