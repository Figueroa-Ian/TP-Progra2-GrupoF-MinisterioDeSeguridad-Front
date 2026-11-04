/* Manejo de sesión en el navegador.
 La sesión REAL vive en el back (cookie de sesión HTTPS + Spring Security); acá solo se guarda
 lo necesario para mostrar la interfaz. Los permisos de verdad los valida siempre el back. */
var API_URL = "http://localhost:8080/api";
//var API_URL = "http://10.96.49.75:8080/api";   // <-- IP de la maquina del backend

// Todas las llamadas a la API van con la cookie de sesión y, si modifican datos, con el token CSRF.
// Así no hace falta tocar cada fetch de cada página.
(function () {
    var fetchOriginal = window.fetch.bind(window);
    var SEGUROS = ["GET", "HEAD", "OPTIONS"];

    window.fetch = function (entrada, opciones) {
        var url = typeof entrada === "string" ? entrada : ((entrada && entrada.url) || "");
        if (url.indexOf(API_URL) !== 0)
            return fetchOriginal(entrada, opciones);

        opciones = Object.assign({}, opciones);
        opciones.credentials = "include";
        var metodo = String(opciones.method || "GET").toUpperCase();
        if (SEGUROS.indexOf(metodo) < 0) {
            var token = Sesion.csrf();
            if (token) {
                var cab = new Headers(opciones.headers || {});
                cab.set("X-CSRF-TOKEN", token);
                opciones.headers = cab;
            }
        }

        return fetchOriginal(entrada, opciones).then(function (res) {
            var ruta = url.split("?")[0];
            var esLogin = /\/auth\/(login|csrf)$/.test(ruta);
            if (res.status === 401 && !esLogin) {          // sesión vencida o inexistente
                Sesion.limpiar();
                window.location.href = "index.jsp";
            } else if (res.status === 403 && !esLogin) {   // token CSRF inválido = sesión vencida
                res.clone().json().then(function (d) {
                    if (d && d.codigo === "CSRF") {
                        Sesion.limpiar();
                        window.location.href = "index.jsp";
                    }
                }, function () { /* cuerpo no JSON */
                });
            }
            return res;
        });
    };
})();

var Sesion = {
    guardar: function (usuario) {
        sessionStorage.setItem("usuario", JSON.stringify(usuario));
    },
    obtener: function () {
        try {
            return JSON.parse(sessionStorage.getItem("usuario"));
        } catch (e) {
            return null;
        }
    },
    csrf: function () {
        try {
            return sessionStorage.getItem("csrf");
        } catch (e) {
            return null;
        }
    },
    /* Pide un token CSRF nuevo al back. Hay que llamarlo antes del login y de nuevo después
     (al iniciar sesión el back crea una sesión nueva y el token anterior deja de valer). */
    cargarCsrf: function () {
        return fetch(API_URL + "/auth/csrf").then(function (res) {
            if (!res.ok)
                throw new Error("HTTP " + res.status);
            return res.json();
        }).then(function (d) {
            sessionStorage.setItem("csrf", d.token);
            return d.token;
        });
    },
    limpiar: function () {
        sessionStorage.removeItem("usuario");
        sessionStorage.removeItem("csrf");
    },
    cerrar: function () {
        var fin = function () {
            Sesion.limpiar();
            window.location.href = "index.jsp";
        };
        fetch(API_URL + "/auth/logout", {method: "POST"}).then(fin, fin);   // invalida la sesión en el back
    },
    /* Vista a la que va cada rol. */
    destino: function (rol) {
        var r = (rol || "").toUpperCase();
        if (r === "ADMIN" || r === "ADMINISTRADOR")
            return "admin.jsp";
        if (r === "INVESTIGADOR")
            return "investigador.jsp";
        if (r === "CHUSMA")
            return "chusma.jsp";
        return "panel.jsp"; // VIGILANTE, JUEZ, etc.
    },
    /* Llamar al inicio de cada vista protegida: si no hay sesión (o no corresponde el rol) vuelve al login.
     Es solo comodidad de navegación: lo que protege los datos es el back. */
    exigir: function (rolesPermitidos) {
        var u = this.obtener();
        var rol = u && u.rol ? u.rol.toUpperCase() : null;
        if (!u || (rolesPermitidos && rolesPermitidos.indexOf(rol) < 0)) {
            window.location.href = "index.jsp";
            return null;
        }
        return u;
    },
    /* Comprueba con el back que la sesión sigue viva (si no, el fetch redirige solo al login). */
    verificar: function () {
        if (!this.obtener())
            return;
        fetch(API_URL + "/auth/yo").then(function (res) {
            return res.ok ? res.json() : null;
        }).then(function (yo) {
            if (yo)
                Sesion.guardar(yo);   // el rol que vale es el que dice el back
        }).catch(function () { /* sin conexión: se ve en cada pantalla */
        });
    }
};

Sesion.verificar();
