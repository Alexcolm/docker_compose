<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion/Conexion.jsp" %>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.SQLException"%>
<%@page import="jakarta.servlet.http.HttpServletResponse"%>
<%
    Statement st = null;
    ResultSet rs = null;
    PreparedStatement ps = null; // Declarar PreparedStatement aquí para cierre en finally
    String tipo = request.getParameter("campo");
    String pk = request.getParameter("pk");

    // Recoger y limpiar el nombre y el precio, si están presentes
    String nombre = request.getParameter("nombreCombustible");
    String precioLitroStr = request.getParameter("precioLitro");

    if (nombre != null) nombre = nombre.trim();

    if (tipo != null) {
        if (tipo.equals("guardar")) {
            try {
                // 1. Verificar si el nombre del combustible ya existe (case-insensitive)
                String checkNameSql = "SELECT COUNT(*) FROM combustibles WHERE LOWER(nombre) = LOWER(?)";
                ps = conn.prepareStatement(checkNameSql);
                ps.setString(1, nombre);
                ResultSet checkNameRs = ps.executeQuery();
                checkNameRs.next();
                if (checkNameRs.getInt(1) > 0) {
                    out.print("nombre_existe");
                    if (checkNameRs != null) checkNameRs.close();
                    if (ps != null) ps.close();
                    return; // Detener la ejecución si el nombre ya existe
                }
                if (checkNameRs != null) checkNameRs.close();
                if (ps != null) ps.close(); // Cerrar ps antes de reasignar

                // 2. Si no hay duplicados, proceder con la inserción
                String insertSql = "INSERT INTO combustibles(nombre, precio_litro) VALUES(?, ?)";
                ps = conn.prepareStatement(insertSql);
                ps.setString(1, nombre);
                ps.setDouble(2, Double.parseDouble(precioLitroStr));
                ps.executeUpdate();
                out.print("exito"); // Indicar que la operación fue exitosa

            } catch (SQLException e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("error_bd"); // Enviar señal de error de base de datos
            } catch (NumberFormatException e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("error_formato_precio"); // Enviar señal de error de formato de precio
            } finally {
                if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
            }
        } else if (tipo.equals("listar")) {
            try {
                st = conn.createStatement();
                rs = st.executeQuery("SELECT id_combustible, nombre, precio_litro FROM combustibles ORDER BY nombre;");
                while (rs.next()) {
%>
<tr>
    <td><% out.print(rs.getInt("id_combustible"));%></td>
    <td><% out.print(rs.getString("nombre"));%></td>
    <td><% out.print(rs.getDouble("precio_litro"));%></td>
    <td>
        <a style="cursor: pointer" onclick="datosModifCombustible(
            '<% out.print(rs.getInt("id_combustible"));%>',
            '<% out.print(rs.getString("nombre"));%>',
            '<% out.print(rs.getDouble("precio_litro"));%>'
        )"><i class="fas fa-edit" style="color:green"></i></a>
        <a style="cursor: pointer" onclick="dellCombustible(<% out.print(rs.getInt("id_combustible"));%>)"><i class="fas fa-trash-alt" style="color:red"></i></a>
    </td>
</tr>
<%
                }
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
                if (st != null) try { st.close(); } catch (SQLException ignore) {}
            }
        } else if (tipo.equals("modificar")) {
            try {
                // 1. Verificar si el nombre del combustible ya existe en OTRO registro (case-insensitive)
                String checkNameSql = "SELECT COUNT(*) FROM combustibles WHERE LOWER(nombre) = LOWER(?) AND id_combustible <> ?";
                ps = conn.prepareStatement(checkNameSql);
                ps.setString(1, nombre);
                ps.setInt(2, Integer.parseInt(pk));
                ResultSet checkNameRs = ps.executeQuery();
                checkNameRs.next();
                if (checkNameRs.getInt(1) > 0) {
                    out.print("nombre_existe");
                    if (checkNameRs != null) checkNameRs.close();
                    if (ps != null) ps.close();
                    return;
                }
                if (checkNameRs != null) checkNameRs.close();
                if (ps != null) ps.close(); // Cerrar ps antes de reasignar

                // 2. Si no hay duplicados, proceder con la actualización
                String updateSql = "UPDATE combustibles SET nombre=?, precio_litro=? WHERE id_combustible=?";
                ps = conn.prepareStatement(updateSql);
                ps.setString(1, nombre);
                ps.setDouble(2, Double.parseDouble(precioLitroStr));
                ps.setInt(3, Integer.parseInt(pk));
                ps.executeUpdate();
                out.print("exito"); // Indicar que la operación fue exitosa

            } catch (SQLException e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("error_bd"); // Enviar señal de error de base de datos
            } catch (NumberFormatException e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("error_formato_precio"); // Enviar señal de error de formato de precio
            } finally {
                if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
            }
        } else if (tipo.equals("eliminar")) {
            try {
                String deleteSql = "DELETE FROM combustibles WHERE id_combustible=?";
                ps = conn.prepareStatement(deleteSql);
                ps.setInt(1, Integer.parseInt(pk));
                int rowsAffected = ps.executeUpdate();
                if (rowsAffected > 0) {
                    out.print("exito"); // Indicar éxito al cliente
                } else {
                    out.print("no_encontrado"); // Indicar que el registro no fue encontrado
                }
            } catch (SQLException e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("error_bd");
            } finally {
                if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
            }
        }
    }

    // Cerrar la conexión al final del JSP
    if (conn != null && !conn.isClosed()) {
        try { conn.close(); } catch (SQLException ignore) {}
    }
%>