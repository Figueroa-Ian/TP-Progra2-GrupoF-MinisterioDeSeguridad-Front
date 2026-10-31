/* Manejo simple de sesión en el navegador (sessionStorage).
   Nota: es control de navegación, no seguridad real; la validación de verdad es la del Back. */
var API_URL = "http://localhost:8080/api";

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
    cerrar: function () {
        sessionStorage.removeItem("usuario");
        window.location.href = "index.jsp";
    },
    /* Vista a la que va cada rol. Cambiá acá los destinos cuando existan más pantallas. */
    destino: function (rol) {
        var r = (rol || "").toUpperCase();
        if (r === "ADMIN" || r === "ADMINISTRADOR") return "admin.jsp";
        return "panel.jsp"; // JUEZ, VIGILANTE, INVESTIGADOR, etc.
    },
    /* Llamar al inicio de cada vista protegida. Si no hay sesión (o no corresponde el rol) vuelve al login. */
    exigir: function (rolesPermitidos) {
        var u = this.obtener();
        var rol = u && u.rol ? u.rol.toUpperCase() : null;
        if (!u || (rolesPermitidos && rolesPermitidos.indexOf(rol) < 0)) {
            window.location.href = "index.jsp";
            return null;
        }
        return u;
    }
};
