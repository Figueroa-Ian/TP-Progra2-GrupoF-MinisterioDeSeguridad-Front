// js/selectores.js
// Desplegable con búsqueda. Muestra "clave — detalle" en la lista, pero al elegir
// en el campo queda SOLO la clave. Al volver a hacer click se reabre la lista completa.
//   - simple:   Selector.crear({ contenedor, id, placeholder })               -> getValor()
//   - múltiple: Selector.crear({ contenedor, id, placeholder, multiple:true }) -> getValores()  (chips con ×)
var Selector = (function () {
    var css = ""
        + ".selector{position:relative}"
        + ".selector .chips{display:flex;flex-wrap:wrap;gap:6px;margin-bottom:6px}"
        + ".selector .chip{display:inline-flex;align-items:center;gap:6px;background:#e7f1ff;color:#0b4a9e;border:1px solid #b6d4fe;border-radius:14px;padding:3px 6px 3px 10px;font-size:13px}"
        + ".selector .chip button{background:none;border:none;color:#0b4a9e;cursor:pointer;font-size:15px;line-height:1;padding:0 2px;width:auto;margin:0}"
        + ".selector .chip button:hover{color:#dc3545;background:none}"
        + ".selector .sug{display:none;position:absolute;left:0;right:0;z-index:20;margin:2px 0 0;padding:0;list-style:none;background:#fff;border:1px solid #ced4da;border-radius:4px;box-shadow:0 6px 16px rgba(0,0,0,.12);max-height:220px;overflow-y:auto}"
        + ".selector .sug li{padding:8px 10px;font-size:14px;cursor:pointer;border-bottom:1px solid #f0f2f5}"
        + ".selector .sug li:last-child{border-bottom:none}"
        + ".selector .sug li.activo,.selector .sug li:hover{background:#e7f1ff}"
        + ".selector .sug li.vacio{color:#6c757d;cursor:default;background:#fff}"
        + ".selector .sug li .clave{font-weight:bold}"
        + ".selector .sug li .detalle{color:#6c757d}";
    var estilo = document.createElement("style");
    estilo.textContent = css;
    document.head.appendChild(estilo);

    function crear(cfg) {
        var multiple = !!cfg.multiple;
        var contenedor = cfg.contenedor;
        contenedor.className = "selector";
        contenedor.innerHTML = "";

        var items = [];            // [{ clave: "JUZ-1", texto: "Ana Pérez" }]
        var cargando = true;
        var libre = false;         // si no se pudo cargar la lista, se acepta lo tipeado
        var elegido = null;        // modo simple
        var elegidos = [];         // modo múltiple
        var tecleado = false;      // true cuando el usuario escribió algo desde la última elección
        var activo = -1;
        var visibles = [];

        var chips = null;
        if (multiple) {
            chips = document.createElement("div");
            chips.className = "chips";
            contenedor.appendChild(chips);
        }
        var input = document.createElement("input");
        input.type = "text";
        input.id = cfg.id;
        input.autocomplete = "off";
        input.placeholder = cfg.placeholder || "";
        contenedor.appendChild(input);
        var lista = document.createElement("ul");
        lista.className = "sug";
        contenedor.appendChild(lista);

        function ocultar() { lista.style.display = "none"; activo = -1; }

        function opciones() {
            var f = tecleado ? input.value.trim().toLowerCase() : "";
            return items.filter(function (it) {
                if (multiple && elegidos.indexOf(it.clave) !== -1) return false;
                return !f || (it.clave + " " + it.texto).toLowerCase().indexOf(f) !== -1;
            });
        }

        function marcarActivo() {
            var lis = lista.querySelectorAll("li:not(.vacio)");
            for (var i = 0; i < lis.length; i++) lis[i].className = i === activo ? "activo" : "";
            if (lis[activo] && lis[activo].scrollIntoView) lis[activo].scrollIntoView({ block: "nearest" });
        }

        function mostrar() {
            visibles = opciones();
            lista.innerHTML = "";
            if (!visibles.length) {
                var v = document.createElement("li");
                v.className = "vacio";
                v.textContent = cargando ? "Cargando…" : (libre ? "No se pudo cargar la lista: escribí el dato a mano." : "Sin resultados");
                lista.appendChild(v);
            }
            visibles.forEach(function (it) {
                var li = document.createElement("li");
                var c = document.createElement("span");
                c.className = "clave";
                c.textContent = it.clave;
                li.appendChild(c);
                if (it.texto) {
                    var d = document.createElement("span");
                    d.className = "detalle";
                    d.textContent = " — " + it.texto;
                    li.appendChild(d);
                }
                // mousedown (y no click) para elegir antes de que el input pierda el foco
                li.addEventListener("mousedown", function (ev) { ev.preventDefault(); elegir(it.clave); });
                lista.appendChild(li);
            });
            activo = -1;
            lista.style.display = "block";
        }

        function dibujarChips() {
            if (!multiple) return;
            chips.innerHTML = "";
            elegidos.forEach(function (clave) {
                var chip = document.createElement("span");
                chip.className = "chip";
                chip.appendChild(document.createTextNode(clave));
                var x = document.createElement("button");
                x.type = "button";
                x.title = "Quitar";
                x.textContent = "×";
                x.addEventListener("click", function () {
                    elegidos = elegidos.filter(function (k) { return k !== clave; });
                    dibujarChips();
                });
                chip.appendChild(x);
                chips.appendChild(chip);
            });
        }

        function elegir(clave) {
            if (multiple) {
                if (elegidos.indexOf(clave) === -1) elegidos.push(clave);
                dibujarChips();
                input.value = "";
                tecleado = false;
                mostrar();          // la lista sigue abierta para sumar más
                input.focus();
            } else {
                elegido = clave;
                input.value = clave;   // queda solo el dato que pide el campo
                tecleado = false;
                ocultar();
            }
        }

        input.addEventListener("focus", mostrar);
        input.addEventListener("click", mostrar);   // volver a abrir la lista completa
        input.addEventListener("input", function () {
            tecleado = true;
            if (!multiple) elegido = libre ? (input.value.trim() || null) : null;
            mostrar();
        });
        input.addEventListener("blur", function () {
            ocultar();
            if (!multiple && elegido === null && input.value.trim()) {
                // si lo escrito coincide exactamente con una clave, se toma como elegida
                var t = input.value.trim().toLowerCase();
                for (var i = 0; i < items.length; i++) {
                    if (items[i].clave.toLowerCase() === t) { elegido = items[i].clave; input.value = elegido; break; }
                }
            }
            if (multiple && libre && input.value.trim()) {
                if (elegidos.indexOf(input.value.trim()) === -1) elegidos.push(input.value.trim());
                input.value = "";
                dibujarChips();
            }
        });
        input.addEventListener("keydown", function (ev) {
            if (ev.key === "ArrowDown" || ev.key === "ArrowUp") {
                ev.preventDefault();
                if (lista.style.display !== "block") mostrar();
                if (!visibles.length) return;
                activo = ev.key === "ArrowDown" ? (activo + 1) % visibles.length : (activo <= 0 ? visibles.length - 1 : activo - 1);
                marcarActivo();
            } else if (ev.key === "Enter") {
                if (activo >= 0 && visibles[activo]) { ev.preventDefault(); elegir(visibles[activo].clave); }
                else if (visibles.length === 1 && lista.style.display === "block") { ev.preventDefault(); elegir(visibles[0].clave); }
                else if (lista.style.display === "block") { ev.preventDefault(); }   // no enviar el formulario con la lista abierta
            } else if (ev.key === "Escape") {
                ocultar();
            } else if (ev.key === "Backspace" && multiple && !input.value && elegidos.length) {
                elegidos.pop();
                dibujarChips();
            }
        });

        return {
            input: input,
            setItems: function (lista) { items = lista; cargando = false; libre = false; },
            setLibre: function () { items = []; cargando = false; libre = true; },
            getValor: function () { return elegido; },
            getValores: function () { return elegidos.slice(); },
            setValor: function (v) {
                elegido = (v === null || v === undefined || v === "") ? null : String(v);
                input.value = elegido === null ? "" : elegido;
                tecleado = false;
            },
            setValores: function (arr) {
                elegidos = (arr || []).map(String);
                input.value = "";
                tecleado = false;
                dibujarChips();
            },
            limpiar: function () {
                elegido = null; elegidos = []; input.value = ""; tecleado = false; dibujarChips();
            }
        };
    }

    // Toma el primer campo que exista de una lista de nombres posibles
    function primero(obj, candidatos) {
        for (var i = 0; i < candidatos.length; i++) {
            var v = obj[candidatos[i]];
            if (v !== undefined && v !== null && v !== "") return v;
        }
        return null;
    }

    // Convierte la lista que devuelve el back en items [{clave, texto}]
    //   claves: nombres posibles del campo clave; detalle: función obj -> texto
    function items(lista, claves, detalle) {
        var salida = [];
        (Array.isArray(lista) ? lista : []).forEach(function (o) {
            var k = primero(o, claves);
            if (k === null) return;
            salida.push({ clave: String(k), texto: detalle(o) || "" });
        });
        return salida;
    }

    return { crear: crear, primero: primero, items: items };
})();
