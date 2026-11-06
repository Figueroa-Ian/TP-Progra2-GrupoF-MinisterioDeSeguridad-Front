<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sistema - Listado de Delitos</title>
        <link rel="stylesheet" href="js/estilos.css">
        <style>
            .menu { max-width: 1100px; margin: 40px auto; }
            .tabla-scroll { overflow-x: auto; }
            .tabla-delitos { width: 100%; border-collapse: collapse; margin-top: 16px; }
            .tabla-delitos th,
            .tabla-delitos td { border-bottom: 1px solid #e3e7ec; padding: 10px 12px; text-align: left; }
            .tabla-delitos th { background: #f4f6f9; color: #1a252f; }
            .estado { text-align: center !important; color: #6c757d; }
            #mensaje { display: none; margin-top: 16px; }
        </style>
    </head>
    <body>
        <div class="barra">
            <span id="saludo"></span>
            <a href="#" onclick="Sesion.cerrar(); return false;">Cerrar sesión</a>
        </div>

        <div class="menu contenedor">
            <h1>Listado de Delitos</h1>

            <div class="tabla-scroll">
                <table class="tabla-delitos">
                    <thead>
                        <tr>
                            <th>Descripción</th>
                            <th>Tipo jurídico</th>
                            <th>Tipo de acción</th>
                            <th>Tipo de intención</th>
                        </tr>
                    </thead>
                    <tbody id="cuerpoTabla">
                        <tr><td class="estado" colspan="4">Cargando delitos…</td></tr>
                    </tbody>
                </table>
            </div>

            <div id="mensaje" class="mensaje error" role="alert"></div>
            <a id="btnVolver" class="volver" href="menuDelitos.jsp">← Volver al menú</a>
        </div>

        <script src="js/sesion.js"></script>
        <script src="js/vistas.js"></script>
        <script>
            var usuario = Sesion.exigir(["ADMIN", "ADMINISTRADOR", "INVESTIGADOR", "CHUSMA"]);
            if (usuario) {
                var rol = (usuario.rol || "").toUpperCase();
                document.getElementById("saludo").textContent = rol + " · " + (usuario.mail || "");
                if (rol === "INVESTIGADOR") {
                    document.getElementById("btnVolver").href = "investigador.jsp";
                }
                cargarDelitos();
            }

            function mapaPorId(lista) {
                var mapa = {};
                lista.forEach(function (item) {
                    mapa[String(item.id)] = item.nombre;
                });
                return mapa;
            }

            function agregarCelda(fila, texto) {
                var celda = document.createElement("td");
                celda.textContent = texto || "—";
                fila.appendChild(celda);
            }

            function cargarDelitos() {
                Promise.all([
                    Vistas.pedir("/delitos"),
                    Vistas.pedir("/catalogos/tipos-juridicos"),
                    Vistas.pedir("/catalogos/tipos-accion"),
                    Vistas.pedir("/catalogos/tipos-intencion")
                ]).then(function (datos) {
                    var delitos = datos[0];
                    var juridicos = mapaPorId(datos[1]);
                    var acciones = mapaPorId(datos[2]);
                    var intenciones = mapaPorId(datos[3]);
                    var cuerpo = document.getElementById("cuerpoTabla");
                    cuerpo.innerHTML = "";

                    if (!Array.isArray(delitos) || delitos.length === 0) {
                        var filaVacia = document.createElement("tr");
                        var celdaVacia = document.createElement("td");
                        celdaVacia.className = "estado";
                        celdaVacia.colSpan = 4;
                        celdaVacia.textContent = "No hay delitos registrados.";
                        filaVacia.appendChild(celdaVacia);
                        cuerpo.appendChild(filaVacia);
                        return;
                    }

                    delitos.forEach(function (delito) {
                        var fila = document.createElement("tr");
                        agregarCelda(fila, delito.descripcion);
                        agregarCelda(fila, juridicos[String(delito.idTipoJuridico)]);
                        agregarCelda(fila, acciones[String(delito.idTipoAccion)]);
                        agregarCelda(fila, intenciones[String(delito.idTipoIntencion)]);
                        cuerpo.appendChild(fila);
                    });
                }).catch(function (error) {
                    console.error("Error al cargar los delitos:", error);
                    var cuerpo = document.getElementById("cuerpoTabla");
                    cuerpo.innerHTML = "";
                    var filaError = document.createElement("tr");
                    var celdaError = document.createElement("td");
                    celdaError.className = "estado";
                    celdaError.colSpan = 4;
                    celdaError.textContent = "No se pudo cargar el listado.";
                    filaError.appendChild(celdaError);
                    cuerpo.appendChild(filaError);
                    Vistas.mostrarError(Vistas.textoError(error, "No se pudo obtener el listado de delitos."));
                });
            }
        </script>
    </body>
</html>
