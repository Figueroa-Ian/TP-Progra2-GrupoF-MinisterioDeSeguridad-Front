// js/contrataciones.js
// Formulario y utilidades compartidas de las pantallas de Contratación.
// Requiere js/sesion.js (API_URL) y js/vistas.js cargados antes.
var Contrataciones = (function () {
    var css = ""
            + ".con-form .campo{margin-bottom:14px}"
            + ".con-form label{font-weight:bold;font-size:14px;display:block;margin-bottom:5px}"
            + ".con-form input[type=text],.con-form input[type=number],.con-form input[type=date],.con-form textarea{width:100%;padding:9px;border:1px solid #ced4da;border-radius:4px;box-sizing:border-box;font-size:14px}"
            + ".con-form input:focus,.con-form textarea:focus{border-color:#007bff;outline:none}"
            + ".con-form textarea{resize:vertical;height:70px}"
            + ".con-form .check{display:flex;align-items:center;gap:8px;margin-bottom:10px;font-size:14px}"
            + ".con-form .check label{margin:0;font-weight:normal}"
            + ".con-form .seccion{font-size:15px;font-weight:bold;color:#007bff;margin:20px 0 10px;text-transform:uppercase;letter-spacing:.5px}"
            + ".con-form button[type=submit],.btn-accion{background:#007bff;color:#fff;padding:11px;border:none;border-radius:4px;font-size:15px;font-weight:bold;cursor:pointer;width:100%;margin-top:10px}"
            + ".con-form button[type=submit]:hover,.btn-accion:hover{background:#0056b3}"
            + ".con-form button:disabled,.btn-accion:disabled{background:#9bbbe0;cursor:not-allowed}"
            + ".btn-peligro{background:#dc3545}.btn-peligro:hover{background:#b02a37}"
            + ".aviso{display:none;margin-top:15px;padding:12px;border-radius:4px;font-size:14px;text-align:center}"
            + ".aviso.ok{background:#d4edda;color:#155724;border:1px solid #c3e6cb}"
            + ".aviso.err{background:#f8d7da;color:#721c24;border:1px solid #f5c6cb}";
    var estilo = document.createElement("style");
    estilo.textContent = css;
    document.head.appendChild(estilo);

    var RUTAS = {
        listar: "/contrataciones",
        buscar: function (id) {
            return "/contrataciones/" + encodeURIComponent(id);
        },
        crear: "/contrataciones",
        modificar: function (id) {
            return "/contrataciones/" + encodeURIComponent(id);
        },
        eliminar: function (id) {
            return "/contrataciones/eliminar/" + encodeURIComponent(id);
        } // <-- Agregamos "/eliminar/"
    };

    function $(id) {
        return document.getElementById(id);
    }

    var CAMPOS = ""
            + '<div class="seccion" style="margin-top:0">Datos de la contratación</div>'
            + '<div class="campo"><label for="codigoSucursal">ID / Código de Sucursal:</label><input type="number" id="codigoSucursal" min="1" required placeholder="Ej: 1"></div>'
            + '<div class="campo"><label for="codigoVigilante">Código de Vigilante:</label><input type="text" id="codigoVigilante" required placeholder="Ej: VIG-01"></div>'
            + '<div class="campo"><label for="fecha">Fecha:</label><input type="date" id="fecha" required></div>'
            + '<div class="check"><input type="checkbox" id="conArma"><label for="conArma">¿Porta arma?</label></div>'
            + '<div class="campo"><label for="observaciones">Observaciones (máx. 100 caracteres):</label><textarea id="observaciones" maxlength="100" placeholder="Detalles opcionales..."></textarea></div>';

    function montar(idContenedor, conExtras, textoBoton, onGuardar) {
        $(idContenedor).innerHTML = '<form id="formContratacion" class="con-form">'
                + CAMPOS
                + '<button type="submit" id="btnGuardar">' + textoBoton + '</button></form>';
        $("formContratacion").addEventListener("submit", function (ev) {
            ev.preventDefault();
            onGuardar(leer());
        });
    }

    function leer() {
        return {
            codigoSucursal: parseInt($("codigoSucursal").value, 10) || 0,
            codigoVigilante: $("codigoVigilante").value.trim(),
            fecha: $("fecha").value,
            conArma: $("conArma").checked,
            observaciones: $("observaciones").value.trim()
        };
    }

    function llenar(c) {
        $("codigoSucursal").value = c.codigoSucursal === null || c.codigoSucursal === undefined ? "" : c.codigoSucursal;
        $("codigoVigilante").value = c.codigoVigilante || "";
        $("fecha").value = c.fecha || "";
        $("conArma").checked = !!c.conArma;
        $("observaciones").value = c.observaciones || "";
    }

    function limpiar() {
        $("formContratacion").reset();
    }

    function enviar(metodo, ruta, cuerpo) {
        var opciones = {method: metodo};
        if (cuerpo !== undefined) {
            opciones.headers = {"Content-Type": "application/json"};
            opciones.body = JSON.stringify(cuerpo);
        }
        return fetch(API_URL + ruta, opciones).then(function (res) {
            return res.text().then(function (texto) {
                if (!res.ok) {
                    var detalle = "";
                    try {
                        detalle = (JSON.parse(texto).message || "");
                    } catch (e) {
                    }
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
        if (err.message === "RED")
            return "No se pudo conectar con el servidor.";
        if (err.estado === 404)
            return "No existe una contratación con ese Id.";
        if (err.detalle)
            return err.detalle;
        if (err.estado === 409)
            return "Ya existe una contratación idéntica para esa sucursal, vigilante y fecha (restricción única).";
        if (err.estado === 400)
            return "Hay datos inválidos o incompletos.";
        return "No se pudo " + accion + " (" + err.message + ").";
    }

    function aviso(tipo, texto) {
        var a = $("aviso");
        if (!a)
            return;
        a.className = "aviso " + tipo;
        a.textContent = texto;
        a.style.display = "block";
    }

    function ocultarAviso() {
        var a = $("aviso");
        if (a)
            a.style.display = "none";
    }

    return {rutas: RUTAS, montar: montar, leer: leer, llenar: llenar, limpiar: limpiar,
        enviar: enviar, textoError: textoError, aviso: aviso, ocultarAviso: ocultarAviso};
})();