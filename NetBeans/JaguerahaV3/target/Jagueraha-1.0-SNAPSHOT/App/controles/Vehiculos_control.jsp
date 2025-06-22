<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion/Conexion.jsp" %>
<%@page import="java.sql.PreparedStatement" %>
<%@page import="java.sql.SQLException" %>
<%@page import="jakarta.servlet.http.HttpServletResponse" %>

<%
    Statement st = null;
    ResultSet rs = null;
    PreparedStatement ps = null;

    // Obtener y limpiar todos los parámetros de entrada
    String tipo = request.getParameter("campo") != null ? request.getParameter("campo").trim() : "";
    String pk = request.getParameter("pk") != null ? request.getParameter("pk").trim() : "";

    String descripcion = request.getParameter("descripcion") != null ? request.getParameter("descripcion").trim() : "";
    String color = request.getParameter("color") != null ? request.getParameter("color").trim() : "";
    String chapa = request.getParameter("chapa") != null ? request.getParameter("chapa").trim() : "";
    String capacidadStr = request.getParameter("capacidad") != null ? request.getParameter("capacidad").trim() : "";
    String id_modeloStr = request.getParameter("id_modelo") != null ? request.getParameter("id_modelo").trim() : "";
    String id_marcaStr = request.getParameter("id_marca") != null ? request.getParameter("id_marca").trim() : ""; // Aunque no se usa directamente para guardar/modificar vehículo, puede ser útil para validación o logs.

    int id_modelo = -1;
    double capacidad_litros = -1.0;

    // Intentar parsear los valores numéricos
    try {
        if (!id_modeloStr.isEmpty()) {
            id_modelo = Integer.parseInt(id_modeloStr);
        }
        if (!capacidadStr.isEmpty()) {
            capacidad_litros = Double.parseDouble(capacidadStr);
        }
    } catch (NumberFormatException e) {
        // Ignorar aquí, se manejará en la validación de campos si es necesario.
        // Podrías loguear e.printStackTrace() para depuración.
    }

    if (tipo.isEmpty()) {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        out.print("operacion_no_especificada");
        // Asegúrate de cerrar la conexión aquí si sales temprano.
        if (conn != null && !conn.isClosed()) {
            try { conn.close(); } catch (SQLException ignore) {}
        }
        return;
    }

    switch (tipo) {
        case "guardar":
        case "modificar":
            // --- Validaciones de campos vacíos y formato ---
            if (descripcion.isEmpty() || color.isEmpty() || chapa.isEmpty() || capacidadStr.isEmpty() || id_modeloStr.isEmpty()) {
                out.print("campos_vacios");
                break; // Salir del switch
            }
            if (id_modelo == -1) { // Si la conversión de id_modelo falló o estaba vacío
                out.print("marca_modelo_invalidos");
                break;
            }
            // Validación de capacidad: debe ser un número válido y mayor a cero
            if (capacidad_litros <= 0) {
                out.print("capacidad_invalida");
                break;
            }

            // --- Lógica de duplicados (chapa) ---
            String checkSql = "";
            ResultSet checkRs = null;
            try {
                if (tipo.equals("guardar")) {
                    checkSql = "SELECT COUNT(*) FROM Vehiculos WHERE LOWER(chapa) = LOWER(?)";
                    ps = conn.prepareStatement(checkSql);
                    ps.setString(1, chapa);
                } else { // tipo.equals("modificar")
                    int currentPk = -1;
                    try {
                        currentPk = Integer.parseInt(pk);
                    } catch (NumberFormatException e) {
                        out.print("error_formato_id"); // PK no es un número válido
                        break;
                    }
                    checkSql = "SELECT COUNT(*) FROM Vehiculos WHERE LOWER(chapa) = LOWER(?) AND id <> ?";
                    ps = conn.prepareStatement(checkSql);
                    ps.setString(1, chapa);
                    ps.setInt(2, currentPk);
                }
                checkRs = ps.executeQuery();
                checkRs.next();
                if (checkRs.getInt(1) > 0) {
                    out.print("chapa_existe");
                    break; // Salir del switch
                }
                // Cierra los recursos de la verificación de duplicados
                if (checkRs != null) checkRs.close();
                if (ps != null) ps.close();

                // Si las validaciones y comprobaciones de duplicados pasan, procede con la operación
                if (tipo.equals("guardar")) {
                    String insertSql = "INSERT INTO Vehiculos(descripcion, color, chapa, capacidad_litros, id_modelo) VALUES(?, ?, ?, ?, ?)";
                    ps = conn.prepareStatement(insertSql);
                    ps.setString(1, descripcion);
                    ps.setString(2, color);
                    ps.setString(3, chapa);
                    ps.setDouble(4, capacidad_litros);
                    ps.setInt(5, id_modelo);
                    ps.executeUpdate();
                    out.print("exito");
                } else { // tipo.equals("modificar")
                    int currentPk = Integer.parseInt(pk); // Ya validado arriba
                    String updateSql = "UPDATE Vehiculos SET descripcion=?, color=?, chapa=?, capacidad_litros=?, id_modelo=? WHERE id=?";
                    ps = conn.prepareStatement(updateSql);
                    ps.setString(1, descripcion);
                    ps.setString(2, color);
                    ps.setString(3, chapa);
                    ps.setDouble(4, capacidad_litros);
                    ps.setInt(5, id_modelo);
                    ps.setInt(6, currentPk);
                    ps.executeUpdate();
                    out.print("exito");
                }
            } catch (SQLException e) {
                e.printStackTrace();
                out.print("error_bd");
            } catch (NumberFormatException e) {
                e.printStackTrace();
                out.print("error_formato_numerico"); // Error en la conversión de capacidad o PK
            } catch (Exception e) {
                e.printStackTrace();
                out.print("error_inesperado");
            } finally {
                // Asegurar que los PreparedStatement y ResultSet se cierren en el bloque 'finally'
                if (checkRs != null) try { checkRs.close(); } catch (SQLException ignore) {}
                if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
            }
            break;

        case "listar":
            try {
                st = conn.createStatement();
                rs = st.executeQuery("SELECT v.id, ma.nombre AS marca_nombre, mo.nombre AS modelo_nombre, v.descripcion, v.color, v.chapa, v.capacidad_litros, ma.id as marca_id, mo.id as modelo_id FROM Vehiculos v JOIN Modelos mo ON v.id_modelo = mo.id JOIN Marcas ma ON mo.id_marca = ma.id ORDER BY v.id DESC;");
                while (rs.next()) {
%>
<tr>
    <td><% out.print(rs.getString("id"));%></td>
    <td><% out.print(rs.getString("marca_nombre"));%></td>
    <td><% out.print(rs.getString("modelo_nombre"));%></td>
    <td><% out.print(rs.getString("descripcion"));%></td>
    <td><% out.print(rs.getString("color"));%></td>
    <td><% out.print(rs.getString("chapa"));%></td>
    <td><% out.print(rs.getString("capacidad_litros"));%></td>
    <td>
        <a style="cursor: pointer" data-toggle="modal" data-target="#exampleModal" onclick="datosModif(
            '<% out.print(rs.getString("id"));%>',
            '<% out.print(rs.getString("marca_id"));%>',
            '<% out.print(rs.getString("modelo_id"));%>',
            '<% out.print(rs.getString("descripcion").replace("'", "\\'"));%>', <%-- Escapar comillas simples --%>
            '<% out.print(rs.getString("color").replace("'", "\\'"));%>',
            '<% out.print(rs.getString("chapa").replace("'", "\\'"));%>',
            '<% out.print(rs.getString("capacidad_litros"));%>'
        )"><i class="fas fa-edit" style="color:green"></i></a>
        <a style="cursor: pointer" onclick="dell(<% out.print(rs.getString("id"));%>)"><i class="fas fa-trash-alt" style="color:red"></i></a>
    </td>
</tr>
<%
                }
            } catch (SQLException e) {
                e.printStackTrace();
                // En este caso, no se envía un mensaje al cliente, simplemente la tabla estará vacía o no se actualizará.
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
                if (st != null) try { st.close(); } catch (SQLException ignore) {}
            }
            break;

        case "eliminar":
            try {
                int idToDelete = Integer.parseInt(pk);
                String deleteSql = "DELETE FROM Vehiculos WHERE id = ?";
                ps = conn.prepareStatement(deleteSql);
                ps.setInt(1, idToDelete);
                int rowsAffected = ps.executeUpdate();
                if (rowsAffected > 0) {
                    out.print("exito");
                } else {
                    out.print("no_encontrado"); // El vehículo no existía o ya fue eliminado
                }
            } catch (NumberFormatException e) {
                e.printStackTrace();
                out.print("error_formato_id");
            } catch (SQLException e) {
                e.printStackTrace();
                out.print("error_bd");
            } catch (Exception e) {
                e.printStackTrace();
                out.print("error_inesperado");
            } finally {
                if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
            }
            break;

        case "listarMarcas":
            try {
                st = conn.createStatement();
                rs = st.executeQuery("SELECT id, nombre FROM Marcas ORDER BY nombre;");
                while (rs.next()) {
%>
<option value="<%= rs.getString("id")%>"><%= rs.getString("nombre")%></option>
<%
                }
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
                if (st != null) try { st.close(); } catch (SQLException ignore) {}
            }
            break;

        case "listarModelos":
            if (id_marcaStr != null && !id_marcaStr.isEmpty()) {
                try {
                    int idMarca = Integer.parseInt(id_marcaStr);
                    String sql = "SELECT id, nombre FROM Modelos WHERE id_marca = ? ORDER BY nombre;";
                    ps = conn.prepareStatement(sql);
                    ps.setInt(1, idMarca);
                    rs = ps.executeQuery();
                    while (rs.next()) {
%>
<option value="<%= rs.getString("id")%>"><%= rs.getString("nombre")%></option>
<%
                    }
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                    // out.print("error_formato_id_marca"); // Podrías enviar esto al cliente si quieres manejarlo específicamente
                } catch (SQLException e) {
                    e.printStackTrace();
                    // out.print("error_bd_modelos");
                } finally {
                    if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
                    if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
                }
            }
            break;

        default:
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("operacion_no_reconocida");
            break;
    }

    // Cerrar la conexión al final del JSP
    if (conn != null && !conn.isClosed()) {
        try { conn.close(); } catch (SQLException ignore) {}
    }
%>