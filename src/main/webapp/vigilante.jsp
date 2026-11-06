<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Vigilante</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu { max-width: 460px; margin: 40px auto; }
            .ficha { margin: 0; padding: 0; }
            .ficha .fila {
                display: flex;
                justify-content: space-between;
                gap: 16px;
                padding: 10px 0;
                border-bottom: 1px solid #e3e7ec;
                font-size: 14px;
            }
            .ficha .fila:last-child { border-bottom: none; }
            .ficha .etiqueta { font-weight: bold; color: #1a252f; }
            .ficha .valor { text-align: right; word-break: break-word; }
            #mensaje { display: none; }
        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo">Vigilante</span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Mis datos</h1>

            <div id="ficha" class="ficha"></div>
            <div id="mensaje" class="mensaje error"></div>
        </div>

        <script src="js/sesion.js"></script>
        <script>
            // Campos que nunca se muestran
            var OCULTOS = ["contrasenia", "password", "clave_hash"];

            // Etiquetas amigables (los campos que no estén acá se muestran con su nombre "humanizado")
            var ETIQUETAS = {
                id: "ID",
                dni: "DNI",
                nombre: "Nombre",
                apellido: "Apellido",
                direccion: "Dirección",
                fechaNacimiento: "Fecha de nacimiento",
                rol: "Rol",
                mail: "Mail"
            };

            function humanizar(clave) {
                if (ETIQUETAS[clave]) return ETIQUETAS[clave];
                var t = clave.replace(/([A-Z])/g, " $1").replace(/[_\-]+/g, " ").trim().toLowerCase();
                return t.charAt(0).toUpperCase() + t.slice(1);
            }

            // Aplana objetos anidados: { banda: { numero: 1 } } -> "Banda › Numero": 1
            function aplanar(obj, prefijo, salida) {
                Object.keys(obj).forEach(function (k) {
                    if (OCULTOS.indexOf(k) !== -1) return;
                    var v = obj[k];
                    var etiqueta = (prefijo ? prefijo + " › " : "") + humanizar(k);
                    if (v !== null && typeof v === "object" && !Array.isArray(v)) {
                        aplanar(v, etiqueta, salida);
                    } else if (Array.isArray(v)) {
                        salida.push([etiqueta, v.length ? v.map(function (x) {
                            return (x !== null && typeof x === "object") ? JSON.stringify(x) : x;
                        }).join(", ") : "—"]);
                    } else {
                        salida.push([etiqueta, (v === null || v === "") ? "—" : v]);
                    }
                });
                return salida;
            }

            function mostrarFicha(datos) {
                var ficha = document.getElementById("ficha");
                ficha.innerHTML = "";
                aplanar(datos, "", []).forEach(function (par) {
                    var fila = document.createElement("div");
                    fila.className = "fila";
                    var e = document.createElement("span");
                    e.className = "etiqueta";
                    e.innerText = par[0];
                    var v = document.createElement("span");
                    v.className = "valor";
                    v.innerText = par[1];
                    fila.appendChild(e);
                    fila.appendChild(v);
                    ficha.appendChild(fila);
                });
            }

            function mostrarError(texto) {
                var m = document.getElementById("mensaje");
                m.innerText = texto;
                m.style.display = "block";
            }

            var u = Sesion.exigir(["VIGILANTE"]);
            if (u) {
                document.getElementById("saludo").innerText = "Vigilante · " + u.mail;

                // Se muestra primero lo que ya vino en el login...
                mostrarFicha(u);

                // ...y se completa con los datos completos del vigilante desde el backend
                if (u.personaId !== undefined && u.personaId !== null) {
                    fetch(API_URL + "/vigilantes/" + u.personaId)
                        .then(function (res) {
                            if (!res.ok) throw new Error("HTTP " + res.status);
                            return res.json();
                        }, function () {
                            // Solo acá se considera error de conexión (fetch no pudo completarse)
                            throw new Error("RED");
                        })
                        .then(function (vigilante) {
                            if (!vigilante || typeof vigilante !== "object") {
                                throw new Error("respuesta vacía o inválida");
                            }
                            mostrarFicha(vigilante);
                        })
                        .catch(function (err) {
                            console.error("Error en vista de vigilante:", err);
                            if (err.message === "RED") {
                                mostrarError("No se pudo conectar con el servidor.");
                            } else {
                                mostrarError("No se pudieron mostrar todos los datos (" + err.message + ").");
                            }
                        });
                }
            }
        </script>
    </body>
</html>
