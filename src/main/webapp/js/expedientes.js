// js/expedientes.js
// Formulario compartido de Expediente (con su Ilícito) + utilidades.
// Requiere js/sesion.js (API_URL) y js/vistas.js cargados antes.
var Expedientes = (function () {
    var css = ""
        + ".exp-form .campo{margin-bottom:14px}"
        + ".exp-form label{font-weight:bold;font-size:14px;display:block;margin-bottom:5px}"
        + ".exp-form input[type=text],.exp-form input[type=number],.exp-form input[type=date],.exp-form select,.exp-form textarea{width:100%;padding:9px;border:1px solid #ced4da;border-radius:4px;box-sizing:border-box;font-size:14px;font-family:inherit}"
        + ".exp-form input:focus,.exp-form select:focus,.exp-form textarea:focus{border-color:#007bff;outline:none}"
        + ".exp-form .check{display:flex;align-items:center;gap:8px;margin-bottom:10px;font-size:14px}"
        + ".exp-form .check label{margin:0;font-weight:normal}"
        + ".exp-form .seccion{font-size:15px;font-weight:bold;color:#007bff;margin:22px 0 10px;text-transform:uppercase;letter-spacing:.5px;border-top:1px solid #e3e7ec;padding-top:14px}"
        + ".exp-form .ayuda{font-size:12px;color:#6c757d;margin-top:3px}"
        + ".exp-form button[type=submit],.btn-accion{background:#007bff;color:#fff;padding:11px;border:none;border-radius:4px;font-size:15px;font-weight:bold;cursor:pointer;width:100%;margin-top:10px}"
        + ".exp-form button[type=submit]:hover,.btn-accion:hover{background:#0056b3}"
        + ".exp-form button:disabled,.btn-accion:disabled{background:#9bbbe0;cursor:not-allowed}"
        + ".btn-peligro{background:#dc3545}.btn-peligro:hover{background:#b02a37}"
        + ".aviso{display:none;margin-top:15px;padding:12px;border-radius:4px;font-size:14px;text-align:center}"
        + ".aviso.ok{background:#d4edda;color:#155724;border:1px solid #c3e6cb}"
        + ".aviso.err{background:#f8d7da;color:#721c24;border:1px solid #f5c6cb}";
    var estilo = document.createElement("style");
    estilo.textContent = css;
    document.head.appendChild(estilo);

    // Rutas del back (ExpedienteController). Si las cambiás allá, cambialas solo acá.
    var RUTAS = {
        listar: "/expedientes",
        buscar: function (id) { return "/expedientes/buscar/" + encodeURIComponent(id); },
        crear: "/expedientes",
        modificar: function (id) { return "/expedientes/modificar/" + encodeURIComponent(id); },
        eliminar: function (id) { return "/expedientes/eliminar/" + encodeURIComponent(id); }
    };

    var catalogos = null;   // { juridicos: [...], acciones: [...], intenciones: [...] }

    function cargarCatalogos() {
        if (catalogos) return Promise.resolve(catalogos);
        return Promise.all([
            Vistas.pedir("/catalogos/tipos-juridicos"),
            Vistas.pedir("/catalogos/tipos-accion"),
            Vistas.pedir("/catalogos/tipos-intencion")
        ]).then(function (r) {
            catalogos = { juridicos: r[0], acciones: r[1], intenciones: r[2] };
            return catalogos;
        });
    }

    function nombreDe(lista, id) {
        for (var i = 0; i < lista.length; i++) if (lista[i].id === id) return lista[i].nombre;
        return id === null || id === undefined ? null : "#" + id;
    }

    // Convierte un expediente en algo legible (ids de tipos -> nombres) para tabla/ficha
    function legible(e) {
        var il = e.ilicito || {};
        return {
            nroExpediente: e.nroExpediente,
            fecha: e.fecha,
            codigoSucursal: e.codigoSucursal,
            claveJuez: e.claveJuez,
            clavesDelincuentes: e.clavesDelincuentes,
            descripcion: e.descripcion,
            esCulpable: e.esCulpable,
            tieneCondena: e.tieneCondena,
            anosCondena: e.anosCondena,
            anosVigenciaCondena: e.anosVigenciaCondena,
            condenaVigente: e.condenaVigente,
            ilicito: {
                id: il.id,
                descripcion: il.descripcion,
                anosCondena: il.anosCondena,
                tipoJuridico: nombreDe(catalogos.juridicos, il.idTipoJuridico),
                tipoAccion: nombreDe(catalogos.acciones, il.idTipoAccion),
                tipoIntencion: nombreDe(catalogos.intenciones, il.idTipoIntencion)
            }
        };
    }

    // ------------------------------------------------------------------
    // Formulario
    // ------------------------------------------------------------------
    var HTML = ""
        + '<form id="formExpediente" class="exp-form">'
        + '  <div class="seccion" style="border-top:none;margin-top:0;padding-top:0">Datos del expediente</div>'
        + '  <div class="campo"><label for="fecha">Fecha:</label><input type="date" id="fecha" required></div>'
        + '  <div class="campo"><label for="codigoSucursal">Código de sucursal:</label><div id="selSucursal"></div></div>'
        + '  <div class="campo"><label for="claveJuez">Clave del juez:</label><div id="selJuez"></div></div>'
        + '  <div class="campo"><label for="clavesDelincuentes">Delincuentes (uno o varios):</label><div id="selDelincuentes"></div></div>'
        + '  <div class="campo"><label for="descripcionExp">Descripción del expediente:</label><textarea id="descripcionExp" rows="3" placeholder="Opcional"></textarea></div>'
        + '  <div class="seccion">Ilícito</div>'
        + '  <div class="campo"><label for="descripcionIl">Descripción del ilícito:</label><textarea id="descripcionIl" rows="2" required placeholder="Ej: Robo agravado"></textarea></div>'
        + '  <div class="campo"><label for="anosIl">Años de condena que prevé el ilícito:</label><input type="number" id="anosIl" min="0" required placeholder="Ej: 5"></div>'
        + '  <div class="campo"><label for="tipoJuridico">Tipo jurídico:</label><select id="tipoJuridico" required></select></div>'
        + '  <div class="campo"><label for="tipoAccion">Tipo de acción:</label><select id="tipoAccion" required></select></div>'
        + '  <div class="campo"><label for="tipoIntencion">Tipo de intención:</label><select id="tipoIntencion" required></select></div>'
        + '  <div class="seccion">Resultado judicial</div>'
        + '  <div class="check"><input type="checkbox" id="esCulpable"><label for="esCulpable">Es culpable</label></div>'
        + '  <div class="check"><input type="checkbox" id="tieneCondena"><label for="tieneCondena">Tiene condena</label></div>'
        + '  <div class="campo"><label for="anosCondena">Años de condena aplicados:</label><input type="number" id="anosCondena" min="0" value="0"></div>'
        + '  <div class="campo"><label for="anosVigenciaCondena">Años de vigencia de la condena:</label><input type="number" id="anosVigenciaCondena" min="0" value="0"></div>'
        + '  <div class="check"><input type="checkbox" id="condenaVigente"><label for="condenaVigente">Condena vigente</label></div>'
        + '  <button type="submit" id="btnGuardar"></button>'
        + '</form>';

    function $(id) { return document.getElementById(id); }

    function llenarSelect(sel, lista) {
        sel.innerHTML = "";
        var vacio = document.createElement("option");
        vacio.value = "";
        vacio.textContent = "— Elegí una opción —";
        sel.appendChild(vacio);
        lista.forEach(function (t) {
            var o = document.createElement("option");
            o.value = t.id;
            o.textContent = t.nombre + (t.descripcion ? " — " + t.descripcion : "");
            sel.appendChild(o);
        });
    }

    // La condena solo se completa si "Tiene condena" está tildado
    function actualizarCondena() {
        var tiene = $("tieneCondena").checked;
        ["anosCondena", "anosVigenciaCondena", "condenaVigente"].forEach(function (id) {
            $(id).disabled = !tiene;
        });
        if (!tiene) {
            $("anosCondena").value = 0;
            $("anosVigenciaCondena").value = 0;
            $("condenaVigente").checked = false;
        }
    }

    // Dibuja el formulario dentro de #idContenedor y carga los desplegables.
    // onGuardar(expedienteJson) se llama al enviar. Devuelve una Promise (listo cuando están los catálogos).
    function montar(idContenedor, textoBoton, onGuardar) {
        $(idContenedor).innerHTML = HTML;
        $("btnGuardar").textContent = textoBoton;
        $("tieneCondena").addEventListener("change", actualizarCondena);
        actualizarCondena();

        selSucursal = Selector.crear({ contenedor: $("selSucursal"), id: "codigoSucursal", placeholder: "Buscá o elegí una sucursal" });
        selJuez = Selector.crear({ contenedor: $("selJuez"), id: "claveJuez", placeholder: "Buscá o elegí un juez" });
        selDelincuentes = Selector.crear({ contenedor: $("selDelincuentes"), id: "clavesDelincuentes", placeholder: "Buscá y elegí uno o más delincuentes", multiple: true });

        $("formExpediente").addEventListener("submit", function (ev) {
            ev.preventDefault();
            var problema = validarSelectores();
            if (problema) { aviso("err", problema); return; }
            onGuardar(leer());
        });

        // Las listas de personas se piden aparte: si una falla, ese campo queda en modo manual
        function cargarLista(ruta, selector, claves, detalle) {
            return Vistas.pedir(ruta).then(function (lista) {
                selector.setItems(Selector.items(lista, claves, detalle));
            }, function (err) {
                console.error(ruta, err);
                selector.setLibre();
                avisosLista.push(ruta);
            });
        }
        var avisosLista = [];
        var nombreCompleto = function (o) { return ((o.nombre || "") + " " + (o.apellido || "")).trim(); };
        return Promise.all([
            cargarCatalogos().then(function (c) {
                llenarSelect($("tipoJuridico"), c.juridicos);
                llenarSelect($("tipoAccion"), c.acciones);
                llenarSelect($("tipoIntencion"), c.intenciones);
            }),
            cargarLista("/sucursales", selSucursal, CLAVES.sucursal, function (o) { return o.direccion; }),
            cargarLista("/jueces", selJuez, CLAVES.juez, nombreCompleto),
            cargarLista("/delincuentes", selDelincuentes, CLAVES.delincuente, nombreCompleto)
        ]).then(function () {
            if (avisosLista.length) {
                aviso("err", "No se pudo cargar la lista de: " + avisosLista.join(", ") + ". Esos campos se completan a mano.");
            }
        });
    }

    var selSucursal, selJuez, selDelincuentes;

    // Nombres posibles del campo "clave" en el JSON de cada entidad (el primero que exista)
    var CLAVES = {
        sucursal: ["id", "idSucursal", "codigoSucursal"],   // NO "codigoEntidad": ese es el código del banco y se repite
        juez: ["claveJuzgado", "claveJuez", "clave", "id"],
        delincuente: ["claveDelincuente", "clave", "id"]
    };

    function validarSelectores() {
        if (!selSucursal.getValor()) return "Elegí una sucursal de la lista.";
        if (isNaN(parseInt(selSucursal.getValor(), 10))) return "El código de sucursal debe ser un número.";
        if (!selJuez.getValor()) return "Elegí un juez de la lista.";
        if (!selDelincuentes.getValores().length) return "Elegí al menos un delincuente.";
        return null;
    }

    var idIlicitoActual = null;   // solo en modificación

    function entero(id) { var n = parseInt($(id).value, 10); return isNaN(n) ? 0 : n; }
    function elegido(id) { var n = parseInt($(id).value, 10); return isNaN(n) ? null : n; }

    // Arma el JSON que espera el back: el ilícito va ANIDADO dentro del expediente
    function leer() {
        var ilicito = {
            descripcion: $("descripcionIl").value.trim(),
            anosCondena: entero("anosIl"),
            idTipoJuridico: elegido("tipoJuridico"),
            idTipoAccion: elegido("tipoAccion"),
            idTipoIntencion: elegido("tipoIntencion")
        };
        if (idIlicitoActual !== null) ilicito.id = idIlicitoActual;   // modificar: se actualiza ese ilícito

        return {
            fecha: $("fecha").value,
            codigoSucursal: parseInt(selSucursal.getValor(), 10),
            claveJuez: selJuez.getValor(),
            clavesDelincuentes: selDelincuentes.getValores(),
            descripcion: $("descripcionExp").value.trim(),
            esCulpable: $("esCulpable").checked,
            tieneCondena: $("tieneCondena").checked,
            anosCondena: entero("anosCondena"),
            anosVigenciaCondena: entero("anosVigenciaCondena"),
            condenaVigente: $("condenaVigente").checked,
            ilicito: ilicito
        };
    }

    function llenar(e) {
        var il = e.ilicito || {};
        idIlicitoActual = il.id === undefined ? null : il.id;
        $("fecha").value = e.fecha || "";
        selSucursal.setValor(e.codigoSucursal);
        selJuez.setValor(e.claveJuez);
        selDelincuentes.setValores(e.clavesDelincuentes);
        $("descripcionExp").value = e.descripcion || "";
        $("descripcionIl").value = il.descripcion || "";
        $("anosIl").value = il.anosCondena === null || il.anosCondena === undefined ? "" : il.anosCondena;
        $("tipoJuridico").value = il.idTipoJuridico === null || il.idTipoJuridico === undefined ? "" : il.idTipoJuridico;
        $("tipoAccion").value = il.idTipoAccion === null || il.idTipoAccion === undefined ? "" : il.idTipoAccion;
        $("tipoIntencion").value = il.idTipoIntencion === null || il.idTipoIntencion === undefined ? "" : il.idTipoIntencion;
        $("esCulpable").checked = !!e.esCulpable;
        $("tieneCondena").checked = !!e.tieneCondena;
        actualizarCondena();
        if (e.tieneCondena) {
            $("anosCondena").value = e.anosCondena || 0;
            $("anosVigenciaCondena").value = e.anosVigenciaCondena || 0;
            $("condenaVigente").checked = !!e.condenaVigente;
        }
    }

    function limpiar() {
        idIlicitoActual = null;
        $("formExpediente").reset();
        selSucursal.limpiar();
        selJuez.limpiar();
        selDelincuentes.limpiar();
        actualizarCondena();
    }

    // ------------------------------------------------------------------
    // Envío (POST / PUT / DELETE)
    // ------------------------------------------------------------------
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
        if (err.estado === 404) return "No existe un expediente con ese número.";
        if (err.detalle) return err.detalle;
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

    return {
        rutas: RUTAS,
        cargarCatalogos: cargarCatalogos,
        legible: legible,
        montar: montar,
        leer: leer,
        llenar: llenar,
        limpiar: limpiar,
        enviar: enviar,
        textoError: textoError,
        aviso: aviso,
        ocultarAviso: ocultarAviso
    };
})();
