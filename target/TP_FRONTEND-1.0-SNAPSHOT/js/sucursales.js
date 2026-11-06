// js/sucursales.js
// Formulario y utilidades compartidas de las pantallas de Sucursal.
// Requiere js/sesion.js (API_URL) y js/vistas.js cargados antes.
var Sucursales = (function () {
    var css = ""
            + ".suc-form .campo{margin-bottom:14px}"
            + ".suc-form label{font-weight:bold;font-size:14px;display:block;margin-bottom:5px}"
            + ".suc-form input[type=text],.suc-form input[type=number]{width:100%;padding:9px;border:1px solid #ced4da;border-radius:4px;box-sizing:border-box;font-size:14px}"
            + ".suc-form input:focus{border-color:#007bff;outline:none}"
            + ".suc-form .check{display:flex;align-items:center;gap:8px;margin-bottom:10px;font-size:14px}"
            + ".suc-form .check label{margin:0;font-weight:normal}"
            + ".suc-form .seccion{font-size:15px;font-weight:bold;color:#007bff;margin:20px 0 10px;text-transform:uppercase;letter-spacing:.5px}"
            + ".suc-form button[type=submit],.btn-accion{background:#007bff;color:#fff;padding:11px;border:none;border-radius:4px;font-size:15px;font-weight:bold;cursor:pointer;width:100%;margin-top:10px}"
            + ".suc-form button[type=submit]:hover,.btn-accion:hover{background:#0056b3}"
            + ".suc-form button:disabled,.btn-accion:disabled{background:#9bbbe0;cursor:not-allowed}"
            + ".btn-peligro{background:#dc3545}.btn-peligro:hover{background:#b02a37}"
            + ".aviso{display:none;margin-top:15px;padding:12px;border-radius:4px;font-size:14px;text-align:center}"
            + ".aviso.ok{background:#d4edda;color:#155724;border:1px solid #c3e6cb}"
            + ".aviso.err{background:#f8d7da;color:#721c24;border:1px solid #f5c6cb}";
    var estilo = document.createElement("style");
    estilo.textContent = css;
    document.head.appendChild(estilo);

    var RUTAS = {
        listar: "/sucursales",
        buscar: function (id) {
            return "/sucursales/" + encodeURIComponent(id);
        },
        crear: "/sucursales",
        modificar: function (id) {
            return "/sucursales/" + encodeURIComponent(id);
        },
        eliminar: function (id) {
            return "/sucursales/eliminar/" + encodeURIComponent(id);
        } // <-- Agregamos "/eliminar/"
    };

    function $(id) {
        return document.getElementById(id);
    }

    var CAMPOS = ""
            + '<div class="seccion" style="margin-top:0">Datos de la sucursal</div>'
            + '<div class="campo"><label for="codigo_entidad">Código de Entidad:</label><input type="text" id="codigo_entidad" required placeholder="Ej: ENT-01"></div>'
            + '<div class="campo"><label for="numero_empleados">Número de Empleados:</label><input type="number" id="numero_empleados" min="0" required placeholder="Ej: 15"></div>'
            + '<div class="campo"><label for="direccion">Dirección:</label><input type="text" id="direccion" required placeholder="Ej: Av. Corrientes 1234"></div>'
            + '<div class="check"><input type="checkbox" id="es_central"><label for="es_central">¿Es sucursal central?</label></div>';

    function montar(idContenedor, conExtras, textoBoton, onGuardar) {
        $(idContenedor).innerHTML = '<form id="formSucursal" class="suc-form">'
                + CAMPOS
                + '<button type="submit" id="btnGuardar">' + textoBoton + '</button></form>';
        $("formSucursal").addEventListener("submit", function (ev) {
            ev.preventDefault();
            onGuardar(leer());
        });
    }

    function leer() {
        return {
            codigo_entidad: $("codigo_entidad").value.trim(),
            numero_empleados: parseInt($("numero_empleados").value, 10) || 0,
            direccion: $("direccion").value.trim(),
            es_central: $("es_central").checked
        };
    }

    function llenar(s) {
        $("codigo_entidad").value = s.codigo_entidad || "";
        $("numero_empleados").value = s.numero_empleados === null || s.numero_empleados === undefined ? "" : s.numero_empleados;
        $("direccion").value = s.direccion || "";
        $("es_central").checked = !!s.es_central;
    }

    function limpiar() {
        $("formSucursal").reset();
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
            return "No existe una sucursal con ese Id.";
        if (err.detalle)
            return err.detalle;
        if (err.estado === 409)
            return "Ya existe una sucursal con esos datos o tiene registros asociados.";
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