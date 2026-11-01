// js/vigilantes.js
// Formulario y utilidades compartidas de las pantallas de Vigilante.
// Requiere js/sesion.js (API_URL) y js/vistas.js cargados antes.
var Vigilantes = (function () {
    var css = ""
        + ".vig-form .campo{margin-bottom:14px}"
        + ".vig-form label{font-weight:bold;font-size:14px;display:block;margin-bottom:5px}"
        + ".vig-form input[type=text],.vig-form input[type=number],.vig-form input[type=date]{width:100%;padding:9px;border:1px solid #ced4da;border-radius:4px;box-sizing:border-box;font-size:14px}"
        + ".vig-form input:focus{border-color:#007bff;outline:none}"
        + ".vig-form .check{display:flex;align-items:center;gap:8px;margin-bottom:10px;font-size:14px}"
        + ".vig-form .check label{margin:0;font-weight:normal}"
        + ".vig-form .seccion{font-size:15px;font-weight:bold;color:#007bff;margin:20px 0 10px;text-transform:uppercase;letter-spacing:.5px}"
        + ".vig-form button[type=submit],.btn-accion{background:#007bff;color:#fff;padding:11px;border:none;border-radius:4px;font-size:15px;font-weight:bold;cursor:pointer;width:100%;margin-top:10px}"
        + ".vig-form button[type=submit]:hover,.btn-accion:hover{background:#0056b3}"
        + ".vig-form button:disabled,.btn-accion:disabled{background:#9bbbe0;cursor:not-allowed}"
        + ".btn-peligro{background:#dc3545}.btn-peligro:hover{background:#b02a37}"
        + ".aviso{display:none;margin-top:15px;padding:12px;border-radius:4px;font-size:14px;text-align:center}"
        + ".aviso.ok{background:#d4edda;color:#155724;border:1px solid #c3e6cb}"
        + ".aviso.err{background:#f8d7da;color:#721c24;border:1px solid #f5c6cb}";
    var estilo = document.createElement("style");
    estilo.textContent = css;
    document.head.appendChild(estilo);

    // Rutas del back (VigilanteController). Si las cambiás allá, cambialas solo acá.
    var RUTAS = {
        listar: "/vigilantes",
        buscar: function (id) { return "/vigilantes/" + encodeURIComponent(id); },
        crear: "/vigilantes",
        modificar: function (id) { return "/vigilantes/modificar/" + encodeURIComponent(id); },
        eliminar: function (id) { return "/vigilantes/eliminar/" + encodeURIComponent(id); }
    };

    function $(id) { return document.getElementById(id); }

    var PERSONA = ""
        + '<div class="seccion" style="margin-top:0">Datos personales</div>'
        + '<div class="campo"><label for="dni">DNI:</label><input type="text" id="dni" required placeholder="Ej: 35111222"></div>'
        + '<div class="campo"><label for="nombre">Nombre:</label><input type="text" id="nombre" required placeholder="Ej: Ramón"></div>'
        + '<div class="campo"><label for="apellido">Apellido:</label><input type="text" id="apellido" required placeholder="Ej: Valdez"></div>'
        + '<div class="campo"><label for="direccion">Dirección:</label><input type="text" id="direccion" placeholder="Ej: Calle 1 #123, CABA"></div>'
        + '<div class="campo"><label for="fechaNacimiento">Fecha de nacimiento:</label><input type="date" id="fechaNacimiento" required></div>';

    var DATOS = ""
        + '<div class="seccion"@@MARGEN@@>Datos del vigilante</div>'
        + '<div class="campo"><label for="legajo">Legajo:</label><input type="text" id="legajo" required maxlength="20" placeholder="Ej: VIG-06"></div>'
        + '<div class="campo"><label for="edad">Edad:</label><input type="number" id="edad" min="1" required placeholder="Ej: 30"></div>'
        + '<div class="check"><input type="checkbox" id="disponibleTrabajar"><label for="disponibleTrabajar">Disponible para trabajar</label></div>';

    // Dibuja el formulario en #idContenedor.
    //   conPersona = true  -> también pide DNI, nombre, etc. (alta)
    //   conPersona = false -> solo legajo, edad y disponibilidad (modificación)
    function montar(idContenedor, conPersona, textoBoton, onGuardar) {
        $(idContenedor).innerHTML = '<form id="formVigilante" class="vig-form">'
            + (conPersona ? PERSONA : "")
            + DATOS.replace("@@MARGEN@@", conPersona ? "" : ' style="margin-top:0"')
            + '<button type="submit" id="btnGuardar">' + textoBoton + '</button></form>';
        $("formVigilante").addEventListener("submit", function (ev) {
            ev.preventDefault();
            onGuardar(leer(conPersona));
        });
    }

    function leer(conPersona) {
        var v = {
            legajo: $("legajo").value.trim(),
            edad: parseInt($("edad").value, 10) || 0,
            disponibleTrabajar: $("disponibleTrabajar").checked
        };
        if (conPersona) {
            v.dni = $("dni").value.trim();
            v.nombre = $("nombre").value.trim();
            v.apellido = $("apellido").value.trim();
            v.direccion = $("direccion").value.trim();
            v.fechaNacimiento = $("fechaNacimiento").value;
            v.rol = "VIGILANTE";
        }
        return v;
    }

    function llenar(v) {
        $("legajo").value = v.legajo || "";
        $("edad").value = v.edad === null || v.edad === undefined ? "" : v.edad;
        $("disponibleTrabajar").checked = !!v.disponibleTrabajar;
    }

    function limpiar() { $("formVigilante").reset(); }

    // Rechaza con Error("RED") o un Error con .estado y .detalle (mensaje del back, si lo manda)
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
        if (err.estado === 404) return "No existe un vigilante con ese Id.";
        if (err.detalle) return err.detalle;
        if (err.estado === 409) return "El legajo o el DNI ya existen, o el vigilante tiene registros asociados.";
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
