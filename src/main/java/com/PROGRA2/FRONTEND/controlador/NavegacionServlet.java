package com.PROGRA2.FRONTEND.controlador;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/buscar")
public class NavegacionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. URL de tu Backend de Spring Boot (puerto 8080)
        String urlBackend = "http://localhost:8080/api/jueces";
        List<String> listaParaMostrar = new ArrayList<>();

        try {
            // 2. Cliente HTTP nativo de Java para pedir el JSON al Backend
            HttpClient cliente = HttpClient.newHttpClient();
            HttpRequest peticion = HttpRequest.newBuilder()
                    .uri(URI.create(urlBackend))
                    .GET()
                    .build();

            HttpResponse<String> respuesta = cliente.send(peticion, HttpResponse.BodyHandlers.ofString());
            String jsonRaw = respuesta.body().trim();

            // 3. Procesamiento manual del JSON (técnica del profesor)
            if (jsonRaw.length() > 2) {
                // Elimina los corchetes "[" y "]" de los extremos
                String limpio = jsonRaw.substring(1, jsonRaw.length() - 1);
                
                // Separa cada objeto del arreglo
                String[] objetosJson = limpio.split("\\},\\{");

                for (String obj : objetosJson) {
                    obj = obj.replace("{", "").replace("}", "");
                    String[] propiedades = obj.split(",");

                    String idVal = "";
                    String dniVal = "";
                    String nombreVal = "";
                    String apellidoVal = "";
                    String juzgadoVal = "";

                    for (String prop : propiedades) {
                        String[] claveValor = prop.split(":");
                        if (claveValor.length >= 2) {
                            String clave = claveValor[0].replace("\"", "").trim();
                            String valor = claveValor[1].replace("\"", "").trim();

                            if (clave.equals("id")) idVal = valor;
                            if (clave.equals("dni")) dniVal = valor;
                            if (clave.equals("nombre")) nombreVal = valor;
                            if (clave.equals("apellido")) apellidoVal = valor;
                            if (clave.equals("claveJuzgado")) juzgadoVal = valor;
                        }
                    }

                    // 4. Empaquetado plano separado por '|'
                    String lineaJuez = idVal + "|" + dniVal + "|" + nombreVal + "|" + apellidoVal + "|" + juzgadoVal;
                    listaParaMostrar.add(lineaJuez);
                }
            }

        } catch (Exception e) {
            System.out.println("Error de comunicación: " + e.getMessage());
        }

        // 5. Enviamos la lista de Strings al JSP
        request.setAttribute("listaParaMostrar", listaParaMostrar);
        request.getRequestDispatcher("resultados.jsp").forward(request, response);
    }
}