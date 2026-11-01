// js/vistas.js
// Helpers compartidos para las pantallas de listado y búsqueda por Id.
// Requiere que js/sesion.js (que define API_URL) esté cargado antes.
var Vistas = (function () {
    var OCULTOS = ["contrasenia", "password"];

    // Etiquetas amigables; los campos que no estén acá se muestran "humanizados"
    var ETIQUETAS = {
        id: "ID",
        dni: "DNI",
        nombre: "Nombre",
        apellido: "Apellido",
        direccion: "Dirección",
        fechaNacimiento: "Fecha de nacimiento",
        rol: "Rol",
        mail: "Mail",
        numeroBanda: "N° de banda"
    };

    // Estilos de tabla, ficha, buscador y "volver" (se inyectan una sola vez)
    var css = ""
        + ".tabla-scroll{overflow-x:auto}"
        + ".tabla-datos{width:100%;border-collapse:collapse;font-size:14px}"
        + ".tabla-datos th,.tabla-datos td{border-bottom:1px solid #e3e7ec;padding:8px 10px;text-align:left;white-space:nowrap}"
        + ".tabla-datos th{background:#f4f6f9;color:#1a252f}"
        + ".ficha .fila{display:flex;justify-content:space-between;gap:16px;padding:10px 0;border-bottom:1px solid #e3e7ec;font-size:14px}"
        + ".ficha .fila:last-child{border-bottom:none}"
        + ".ficha .etiqueta{font-weight:bold;color:#1a252f}"
        + ".ficha .valor{text-align:right;word-break:break-word}"
        + ".buscador{display:flex;gap:8px;margin-bottom:16px}"
        + ".buscador input{flex:1;padding:9px;border:1px solid #ced4da;border-radius:4px;font-size:14px}"
        + ".buscador button{padding:9px 18px;background:#007bff;color:#fff;border:none;border-radius:4px;font-size:14px;font-weight:bold;cursor:pointer}"
        + ".buscador button:hover{background:#0056b3}"
        + ".volver{display:block;text-align:center;margin-top:16px;color:#6c757d;text-decoration:none;font-size:14px}"
        + ".volver:hover{text-decoration:underline}"
        + "#mensaje{display:none}";
    var estilo = document.createElement("style");
    estilo.textContent = css;
    document.head.appendChild(estilo);

    function humanizar(clave) {
        if (Object.prototype.hasOwnProperty.call(ETIQUETAS, clave)) return ETIQUETAS[clave];
        var t = clave.replace(/([A-Z])/g, " $1").replace(/[_\-]+/g, " ").trim().toLowerCase();
        return t.charAt(0).toUpperCase() + t.slice(1);
    }

    function formatear(v) {
        if (v === null || v === undefined || v === "") return "—";
        if (v === true) return "Sí";
        if (v === false) return "No";
        if (Array.isArray(v)) {
            if (!v.length) return "—";
            return v.map(function (x) {
                return (x !== null && typeof x === "object") ? JSON.stringify(x) : x;
            }).join(", ");
        }
        return String(v);
    }

    // Aplana objetos anidados: { banda: { nombre: "X" } } -> { "Banda › Nombre": "X" }
    function aplanar(obj, prefijo, mapa) {
        Object.keys(obj).forEach(function (k) {
            if (OCULTOS.indexOf(k) !== -1) return;
            var v = obj[k];
            var etiqueta = (prefijo ? prefijo + " › " : "") + humanizar(k);
            if (v !== null && typeof v === "object" && !Array.isArray(v)) {
                aplanar(v, etiqueta, mapa);
            } else {
                mapa[etiqueta] = formatear(v);
            }
        });
        return mapa;
    }

    // GET a la API. Errores: "RED" (sin conexión), "NO_EXISTE" (404 o cuerpo vacío), "HTTP nnn"
    function pedir(ruta) {
        return fetch(API_URL + ruta).then(function (res) {
            if (res.status === 404) throw new Error("NO_EXISTE");
            if (!res.ok) throw new Error("HTTP " + res.status);
            return res.text();
        }, function () {
            // Solo acá se considera error de conexión
            throw new Error("RED");
        }).then(function (texto) {
            if (!texto) throw new Error("NO_EXISTE");
            return JSON.parse(texto);
        });
    }

    function tabla(contenedor, lista) {
        contenedor.innerHTML = "";
        if (!Array.isArray(lista) || !lista.length) {
            var vacio = document.createElement("p");
            vacio.textContent = "No hay registros para mostrar.";
            contenedor.appendChild(vacio);
            return;
        }
        var filas = lista.map(function (x) { return aplanar(x, "", {}); });
        var columnas = [];
        filas.forEach(function (f) {
            Object.keys(f).forEach(function (c) {
                if (columnas.indexOf(c) === -1) columnas.push(c);
            });
        });

        var t = document.createElement("table");
        t.className = "tabla-datos";
        var cabecera = document.createElement("tr");
        columnas.forEach(function (c) {
            var th = document.createElement("th");
            th.textContent = c;
            cabecera.appendChild(th);
        });
        var thead = document.createElement("thead");
        thead.appendChild(cabecera);
        t.appendChild(thead);

        var tbody = document.createElement("tbody");
        filas.forEach(function (f) {
            var tr = document.createElement("tr");
            columnas.forEach(function (c) {
                var td = document.createElement("td");
                td.textContent = Object.prototype.hasOwnProperty.call(f, c) ? f[c] : "—";
                tr.appendChild(td);
            });
            tbody.appendChild(tr);
        });
        t.appendChild(tbody);

        var envoltorio = document.createElement("div");
        envoltorio.className = "tabla-scroll";
        envoltorio.appendChild(t);
        contenedor.appendChild(envoltorio);
    }

    function ficha(contenedor, obj) {
        contenedor.innerHTML = "";
        var mapa = aplanar(obj, "", {});
        Object.keys(mapa).forEach(function (etiqueta) {
            var fila = document.createElement("div");
            fila.className = "fila";
            var e = document.createElement("span");
            e.className = "etiqueta";
            e.textContent = etiqueta;
            var v = document.createElement("span");
            v.className = "valor";
            v.textContent = mapa[etiqueta];
            fila.appendChild(e);
            fila.appendChild(v);
            contenedor.appendChild(fila);
        });
    }

    function mostrarError(texto) {
        var m = document.getElementById("mensaje");
        m.textContent = texto;
        m.style.display = "block";
    }

    function ocultarError() {
        document.getElementById("mensaje").style.display = "none";
    }

    function textoError(err, textoNoExiste) {
        if (err.message === "RED") return "No se pudo conectar con el servidor.";
        if (err.message === "NO_EXISTE") return textoNoExiste;
        return "No se pudo completar la consulta (" + err.message + ").";
    }

    return {
        pedir: pedir,
        tabla: tabla,
        ficha: ficha,
        mostrarError: mostrarError,
        ocultarError: ocultarError,
        textoError: textoError
    };
})();
