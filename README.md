# Sistema de Gestión del Ministerio de Seguridad - Front-End

Este repositorio contiene la interfaz de usuario (Front-End) para el Sistema de Gestión del Ministerio de Seguridad, desarrollado como Trabajo Práctico Final para la materia Programación 2 (Instituto Nacional Superior del Profesorado Técnico).

La aplicación consume una API RESTful desarrollada en Spring Boot y proporciona una interfaz web dinámica para la gestión de entidades judiciales, sucursales y personal de vigilancia, con renderizado basado en roles.

## 💻 Tecnologías Utilizadas

* **Estructura y Estilos:** HTML5, CSS3, JSP (JavaServer Pages)
* **Lógica de Cliente:** JavaScript (Vanilla JS)
* **Peticiones HTTP:** Fetch API (manejo de promesas y JSON)
* **Despliegue:** Empaquetado como WAR integrado con el servidor embebido del Back-End o en Tomcat.

## 👤 Actores y Roles del Sistema

El sistema implementa control de acceso basado en roles (RBAC). Las vistas y menús se adaptan según el perfil del usuario autenticado:

1. **Administrador:** Tiene acceso total al sistema. Puede realizar operaciones CRUD (Alta, Baja, Modificación y Consulta) en todos los módulos.
2. **Investigador:** Perfil de análisis y auditoría. Tiene permisos de solo lectura (listados y búsquedas); no puede crear, modificar ni eliminar registros.
3. **Vigilante:** Perfil operativo. Solo puede acceder en modo lectura a sus propios datos personales y de contratación. No tiene acceso al resto de las entidades.

## ⚙️ Alcance Funcional (Módulos)

El front-end está dividido en módulos independientes accesibles desde el panel de control:

* **Jueces / Investigadores:** Altas, bajas, modificaciones y listados.
* **Delincuentes y Bandas:** Gestión de individuos y su vinculación con agrupaciones delictivas (búsquedas por ID y por banda).
* **Sucursales y Vigilantes:** Gestión de ubicaciones físicas y personal asignado.
* **Contrataciones:** Interfaz transaccional para asignar vigilantes a sucursales en fechas específicas, indicando si portan armas.
* **Expedientes e Ilícitos:** Flujo de creación conjunta donde se asocia un expediente judicial con su respectivo ilícito (tipificación, juez a cargo, sucursal afectada y delincuentes involucrados).

## 📂 Estructura del Proyecto

El cliente está estructurado de manera modular para facilitar el mantenimiento:

```text
src/main/webapp/
├── index.jsp                  # Pantalla de Login
├── admin.jsp / vigilante.jsp  # Paneles de control principales según rol
├── menu<Entidad>.jsp          # Menús de navegación por módulo
├── crear<Entidad>.jsp         # Formularios de alta
├── modificar<Entidad>.jsp     # Formularios de actualización
└── js/                        # Scripts core del frontend
    ├── sesion.js              # Manejo de token, sesión y RBAC en cliente
    ├── vistas.js              # Helpers de renderizado de tablas y DOM
    └── <modulo>.js            # Lógica y llamadas Fetch específicas por entidad
