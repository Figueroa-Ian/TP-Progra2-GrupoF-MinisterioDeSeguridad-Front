// js/chusmas.js
// Formulario y utilidades para el rol CHUSMA (Solo puede modificar dirección).
// Requiere js/sesion.js (API_URL) y js/vistas.js cargados antes.
var Chusmas = (function () {
    var css = ""
        + ".inv-form .campo{margin-bottom:14px}"
        + ".inv-form label{font-weight:bold;font-size:14px;display:block;margin-bottom:5px}"
        + ".inv-form input[type=text],.inv-form input[type=date]{width:100%;padding:9px;border:1px solid #ced4da;border-radius:4px;box-sizing:border-box;font-size:14px}"
        + ".inv-form input:focus:not([readonly]){border-color:#007bff;outline:none}"
        /* Estilo para los campos bloqueados */
        + ".inv-form input[readonly]{background-color:#e9ecef;color:#6c757d;cursor:not-allowed;border-color:#ced4da}"
        + ".inv-form button[type=submit]{background:#007bff;color:#fff;padding:11px;border:none;border-radius:4px;font-size:15px;font-weight:bold;cursor:pointer;width:100%;margin-top:10px}"
        + ".inv-form button[type=submit]:hover{background:#0056b3}"
        + ".inv-form button:disabled{background:#9bbbe0;cursor:not-allowed}"
        + ".aviso{display:none;margin-top:15px;padding:12px;border-radius:4px;font-size:14px;text-align:center}"
        + ".aviso.ok{background:#d4edda;color:#155724;border:1px solid #c3e6cb}"
        + ".aviso.err{background:#f8d7da;color:#721c24;border:1px solid #f5c6cb}";
    var estilo = document.createElement("style");
    estilo.textContent = css;
    document.head.appendChild(estilo);

    // Rutas del back. Asegurate de que existan los endpoints equivalentes o ajustá la ruta.
    var RUTAS = {
        listar: "/chusmas",
        buscar: function (id) { return "/chusmas/" + encodeURIComponent(id); },
        crear: "/chusmas",
        modificar: function (id) { return "/chusmas/modificar/" + encodeURIComponent(id); },
        eliminar: function (id) { return "/chusmas/eliminar/" + encodeURIComponent(id); }
    };

    function $(id) { return document.getElementById(id); }

    // Variable interna para guardar el registro completo que viene del backend
    var objetoOriginal = null; 

    // Todos los campos excepto dirección tienen "readonly"
    var CAMPOS = ""
        + '<div class="campo"><label for="dni">DNI:</label><input type="text" id="dni" readonly></div>'
        + '<div class="campo"><label for="nombre">Nombre:</label><input type="text" id="nombre" readonly></div>'
        + '<div class="campo"><label for="apellido">Apellido:</label><input type="text" id="apellido" readonly></div>'
        + '<div class="campo"><label for="direccion">Dirección (Único campo editable):</label><input type="text" id="direccion" required placeholder="Ej: Calle 1 #123, CABA"></div>'
        + '<div class="campo"><label for="fechaNacimiento">Fecha de nacimiento:</label><input type="date" id="fechaNacimiento" readonly></div>';

    function montar(idContenedor, textoBoton, onGuardar) {
        $(idContenedor).innerHTML = '<form id="formChusma" class="inv-form">'
            + CAMPOS
            + '<button type="submit" id="btnGuardar">' + textoBoton + '</button></form>';
            
        $("formChusma").addEventListener("submit", function (ev) {
            ev.preventDefault();
            onGuardar(leer());
        });
    }

    function leer() {
        // Si estamos modificando, usamos el objeto original y solo actualizamos la dirección.
        if (objetoOriginal) {
            objetoOriginal.direccion = $("direccion").value.trim();
            return objetoOriginal;
        }
        
        // Fallback por si se usa este form para crear (aunque el rol CHUSMA no debería crear si todo es readonly)
        return {
            dni: $("dni").value.trim(),
            nombre: $("nombre").value.trim(),
            apellido: $("apellido").value.trim(),
            direccion: $("direccion").value.trim(),
            fechaNacimiento: $("fechaNacimiento").value,
            rol: "CHUSMA"
        };
    }

    function llenar(p) {
        objetoOriginal = p; // Clonamos/Guardamos la referencia del registro original
        $("dni").value = p.dni || "";
        $("nombre").value = p.nombre || "";
        $("apellido").value = p.apellido || "";
        $("direccion").value = p.direccion || "";
        $("fechaNacimiento").value = p.fechaNacimiento || "";
    }

    function limpiar() { 
        $("formChusma").reset(); 
        objetoOriginal = null;
    }

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
                    try { detalle = (JSON.parse(texto).message || ""); } catch (e) {}
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
        if (err.estado === 404) return "No existe el registro con ese Id.";
        if (err.estado === 409) return "Ese DNI ya está registrado o tiene datos asociados.";
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