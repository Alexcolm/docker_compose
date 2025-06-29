<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion/Conexion.jsp" %>
<%@page import="java.sql.PreparedStatement" %> <%-- Added for PreparedStatement --%>
<%@page import="java.sql.Statement" %>
<%@page import="java.sql.ResultSet" %>
<%@page import="java.sql.SQLException" %>
<%@page import="jakarta.servlet.http.HttpServletResponse" %> <%-- For setting HTTP status codes --%>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    PreparedStatement ps = null; // Using PreparedStatement for all operations for safety
    Statement st = null; // Keeping Statement for listing, but PreparedStatement is generally preferred
    ResultSet rs = null;

    String tipo = request.getParameter("campo");
    String ciudad = request.getParameter("ciudad") != null ? request.getParameter("ciudad").trim() : ""; // Trim whitespace
    String pk = request.getParameter("pk");

    try {
        if (tipo == null || tipo.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("error: tipo de operación no especificado");
            return;
        }

        switch (tipo) {
            case "guardar":
                // Server-side validation for empty field
                if (ciudad.isEmpty()) {
                    out.print("vacio");
                    return;
                }

                // Check for duplicate city name (case-insensitive)
                String checkExistSql = "SELECT COUNT(*) FROM Ciudades WHERE LOWER(nombre) = LOWER(?)";
                ps = conn.prepareStatement(checkExistSql);
                ps.setString(1, ciudad);
                rs = ps.executeQuery();
                rs.next();
                if (rs.getInt(1) > 0) {
                    out.print("existe");
                    return;
                }
                rs.close();
                ps.close();

                // Insert new city
                String insertSql = "INSERT INTO Ciudades(nombre) VALUES(?)";
                ps = conn.prepareStatement(insertSql);
                ps.setString(1, ciudad);
                ps.executeUpdate();
                out.print("exito"); // Consistent success message
                break;

            case "listar":
                st = conn.createStatement();
                rs = st.executeQuery("SELECT id, nombre FROM Ciudades ORDER BY nombre ASC;"); // Order by name for better UX
                while (rs.next()) { %>
<tr>
    <td><% out.print(rs.getString("id"));%></td> <%-- Using column names for clarity --%>
    <td><% out.print(rs.getString("nombre"));%></td>
    <td>
        <a style="cursor: pointer" onclick="datosModif('<% out.print(rs.getString("id"));%>', '<% out.print(rs.getString("nombre"));%>')" data-toggle="modal" data-target="#exampleModal">
            <i class="fas fa-edit" style="color:green"></i>
        </a>
        <a style="cursor: pointer" onclick="dell(<% out.print(rs.getString("id"));%>)">
            <i class="fas fa-trash-alt" style="color:red"></i>
        </a>
    </td>
</tr>
<%
                }
                break;

            case "modificar":
                // Server-side validation for empty field
                if (ciudad.isEmpty()) {
                    out.print("vacio");
                    return;
                }

                if (pk == null || pk.isEmpty()) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("error: ID para modificar no especificado");
                    return;
                }

                // Check for duplicate city name for other IDs (case-insensitive)
                checkExistSql = "SELECT COUNT(*) FROM Ciudades WHERE LOWER(nombre) = LOWER(?) AND id <> ?";
                ps = conn.prepareStatement(checkExistSql);
                ps.setString(1, ciudad);
                ps.setInt(2, Integer.parseInt(pk));
                rs = ps.executeQuery();
                rs.next();
                if (rs.getInt(1) > 0) {
                    out.print("existe");
                    return;
                }
                rs.close();
                ps.close();

                // Update city
                String updateSql = "UPDATE Ciudades SET nombre=? WHERE id=?";
                ps = conn.prepareStatement(updateSql);
                ps.setString(1, ciudad);
                ps.setInt(2, Integer.parseInt(pk));
                int rowsUpdated = ps.executeUpdate();
                if (rowsUpdated > 0) {
                    out.print("exito"); // Consistent success message
                } else {
                    out.print("no_encontrado"); // Indicate if record not found for update
                }
                break;

            case "eliminar":
                if (pk == null || pk.isEmpty()) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("error: ID para eliminar no especificado");
                    return;
                }
                String deleteSql = "DELETE FROM Ciudades WHERE id=?";
                ps = conn.prepareStatement(deleteSql);
                ps.setInt(1, Integer.parseInt(pk));
                int rowsDeleted = ps.executeUpdate();
                if (rowsDeleted > 0) {
                    out.print("exito"); // Consistent success message
                } else {
                    out.print("no_encontrado"); // Indicate if record not found for deletion
                }
                break;

            default:
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("error: tipo de operación no reconocido");
                break;
        }
    } catch (NumberFormatException e) {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        out.print("error: formato de ID inválido");
    } catch (SQLException e) {
        e.printStackTrace();
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        out.print("error_bd"); // Generic database error message
    } catch (Exception e) {
        e.printStackTrace();
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        out.print("error_inesperado"); // Catch any other unexpected errors
    } finally {
        // Close resources in reverse order of creation
        if (rs != null) try { rs.close(); } catch (SQLException e) { /* Log error if closing fails */ }
        if (st != null) try { st.close(); } catch (SQLException e) { /* Log error if closing fails */ }
        if (ps != null) try { ps.close(); } catch (SQLException e) { /* Log error if closing fails */ }
        if (conn != null) try { conn.close(); } catch (SQLException e) { /* Log error if closing fails */ }
    }
%>