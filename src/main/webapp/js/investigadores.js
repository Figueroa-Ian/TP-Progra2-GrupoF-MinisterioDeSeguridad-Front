// js/investigadores.js
// Formulario y utilidades compartidas de las pantallas de Investigador.
// Requiere js/sesion.js (API_URL) y js/vistas.js cargados antes.
var Investigadores = (function () {
    var css = ""
        + ".inv-form .campo{margin-bottom:14px}"
        + ".inv-form label{font-weight:bold;font-size:14px;display:block;margin-bottom:5px}"
        + ".inv-form input[type=text],.inv-form input[type=date]{width:100%;padding:9px;border:1px solid #ced4da;border-radius:4px;box-sizing:border-box;font-size:14px}"
        + ".inv-form input:focus{border-color:#007bff;outline:none}"
        + ".inv-form button[type=submit]{background:#007bff;color:#fff;padding:11px;border:none;border-radius:4px;font-size:15px;font-weight:bold;cursor:pointer;width:100%;margin-top:10px}"
        + ".inv-form button[type=submit]:hover{background:#0056b3}"
        + ".inv-form button:disabled{background:#9bbbe0;cursor:not-allowed}"
        + ".aviso{display:none;margin-top:15px;padding:12px;border-radius:4px;font-size:14px;text-align:center}"
        + ".aviso.ok{background:#d4edda;color:#155724;border:1px solid #c3e6cb}"
        + ".aviso.err{background:#f8d7da;color:#721c24;border:1px solid #f5c6cb}";
    var estilo = document.createElement("style");
    estilo.textContent = css;
    document.head.appendChild(estilo);

    // Rutas del back (InvestigadorController). Si las cambiás allá, cambialas solo acá.
    var RUTAS = {
        listar: "/investigadores",
        buscar: function (id) { return "/investigadores/" + encodeURIComponent(id); },
        crear: "/investigadores",
        modificar: function (id) { return "/investigadores/modificar/" + encodeURIComponent(id); },
        eliminar: function (id) { return "/investigadores/eliminar/" + encodeURIComponent(id); }
    };

    function $(id) { return document.getElementById(id); }

    // Fecha más reciente permitida: hoy menos 18 años (formato yyyy-MM-dd)
    function fechaMaxima() {
        var h = new Date();
        var y = h.getFullYear() - 18;
        var m = ("0" + (h.getMonth() + 1)).slice(-2);
        var d = ("0" + h.getDate()).slice(-2);
        return y + "-" + m + "-" + d;
    }

    var CAMPOS = ""
        + '<div class="campo"><label for="dni">DNI:</label><input type="text" id="dni" required placeholder="Ej: 35111222"></div>'
        + '<div class="campo"><label for="nombre">Nombre:</label><input type="text" id="nombre" required placeholder="Ej: Laura"></div>'
        + '<div class="campo"><label for="apellido">Apellido:</label><input type="text" id="apellido" required placeholder="Ej: Gómez"></div>'
        + '<div class="campo"><label for="direccion">Dirección:</label><input type="text" id="direccion" placeholder="Ej: Calle 1 #123, CABA"></div>'
        + '<div class="campo"><label for="fechaNacimiento">Fecha de nacimiento:</label><input type="date" id="fechaNacimiento" required>'
        + '<small style="color:#6c757d">Tiene que ser mayor de 18 años.</small></div>';

    // Dibuja el formulario en #idContenedor y llama a onGuardar(datos) al enviarlo.
    function montar(idContenedor, textoBoton, onGuardar) {
        $(idContenedor).innerHTML = '<form id="formInvestigador" class="inv-form">'
            + CAMPOS
            + '<button type="submit" id="btnGuardar">' + textoBoton + '</button></form>';
        $("fechaNacimiento").max = fechaMaxima();
        $("formInvestigador").addEventListener("submit", function (ev) {
            ev.preventDefault();
            onGuardar(leer());
        });
    }

    function leer() {
        return {
            dni: $("dni").value.trim(),
            nombre: $("nombre").value.trim(),
            apellido: $("apellido").value.trim(),
            direccion: $("direccion").value.trim(),
            fechaNacimiento: $("fechaNacimiento").value,
            rol: "INVESTIGADOR"
        };
    }

    function llenar(p) {
        $("dni").value = p.dni || "";
        $("nombre").value = p.nombre || "";
        $("apellido").value = p.apellido || "";
        $("direccion").value = p.direccion || "";
        $("fechaNacimiento").value = p.fechaNacimiento || "";
    }

    function limpiar() { $("formInvestigador").reset(); }

    // Rechaza con Error("RED") o un Error con .estado y .detalle (mensaje del back)
    function enviar(metodo, ruta, cuerpo) {
        var opciones = { method: metodo };
        if (cuerpo !== undefined) {
            opciones.headers = { "Content-Type": "application/json" };
            opciones.body = JSON.stringify(cuerpo);
        }
        return fetch(API_URL + ruta, opciones).then(function (res) {
            return res.text().then(function (texto) {
                if (!res.ok) {
                    var detalle = "";
                    try { detalle = (JSON.parse(texto).message || ""); } catch (e) { /* sin cuerpo JSON */ }
                    var err = new Error("HTTP " + res.status);
                    err.estado = res.status;
                    err.detalle = detalle;
                    throw err;
                }
                return texto ? JSON.parse(texto) : null;
            });
        }, function () {
            throw new Error("RED");
        });
    }

    function textoError(err, accion) {
        if (err.message === "RED") return "No se pudo conectar con el servidor.";
        if (err.detalle) return err.detalle;
        if (err.estado === 404) return "No existe un investigador con ese Id.";
        if (err.estado === 409) return "Ese DNI ya está registrado, o el investigador tiene registros asociados.";
        if (err.estado === 400) return "Hay datos inválidos o incompletos.";
        return "No se pudo " + accion + " (" + err.message + ").";
    }

    function aviso(tipo, texto) {
        var a = $("aviso");
        a.className = "aviso " + tipo;
        a.textContent = texto;
        a.style.display = "block";
    }

    function ocultarAviso() { $("aviso").style.display = "none"; }

    return { rutas: RUTAS, montar: montar, leer: leer, llenar: llenar, limpiar: limpiar,
             enviar: enviar, textoError: textoError, aviso: aviso, ocultarAviso: ocultarAviso };
})();
