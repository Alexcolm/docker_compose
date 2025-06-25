<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion/Conexion.jsp" %>
<%@page import="java.sql.PreparedStatement" %>
<%@page import="java.sql.SQLException" %>
<%@page import="jakarta.servlet.http.HttpServletResponse" %>

<%
    Statement st = null;
    ResultSet rs = null;
    PreparedStatement ps = null;
    String tipo = request.getParameter("campo") != null ? request.getParameter("campo").trim() : "";
    String marcaNombre = request.getParameter("marca") != null ? request.getParameter("marca").trim() : "";
    String pkStr = request.getParameter("pk") != null ? request.getParameter("pk").trim() : "";
    if (tipo.isEmpty()) {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        out.print("operacion_no_especificada");
        if (conn != null && !conn.isClosed()) {
            try { conn.close(); } catch (SQLException ignore) {}
        }
        return;
    }

    switch (tipo) {
        case "guardar":
        case "modificar":
            if (marcaNombre.isEmpty()) {
                out.print("campos_vacios");
                break; 
            }
            String checkSql = "";
            ResultSet checkRs = null;
            try {
                if (tipo.equals("guardar")) {
                    checkSql = "SELECT COUNT(*) FROM Marcas WHERE LOWER(nombre) = LOWER(?)";
                    ps = conn.prepareStatement(checkSql);
                    ps.setString(1, marcaNombre);
                } else {
                    int pk = -1;
                    try {
                        pk = Integer.parseInt(pkStr);
                    } catch (NumberFormatException e) {
                        out.print("error_formato_id");
                        break;
                    }
                    checkSql = "SELECT COUNT(*) FROM Marcas WHERE LOWER(nombre) = LOWER(?) AND id <> ?";
                    ps = conn.prepareStatement(checkSql);
                    ps.setString(1, marcaNombre);
                    ps.setInt(2, pk);
                }
                checkRs = ps.executeQuery();
                checkRs.next();
                if (checkRs.getInt(1) > 0) {
                    out.print("marca_existe");
                    break; 
                }
                
                if (checkRs != null) checkRs.close();
                if (ps != null) ps.close();

                
                if (tipo.equals("guardar")) {
                    String insertSql = "INSERT INTO Marcas(nombre) VALUES(?)";
                    ps = conn.prepareStatement(insertSql);
                    ps.setString(1, marcaNombre);
                    ps.executeUpdate();
                    out.print("exito");
                } else { 
                    int pk = Integer.parseInt(pkStr);
                    String updateSql = "UPDATE Marcas SET nombre=? WHERE id=?";
                    ps = conn.prepareStatement(updateSql);
                    ps.setString(1, marcaNombre);
                    ps.setInt(2, pk);
                    ps.executeUpdate();
                    out.print("exito");
                }
            } catch (SQLException e) {
                e.printStackTrace();
                out.print("error_bd");
            } catch (NumberFormatException e) {
                e.printStackTrace();
                out.print("error_formato_id");
            } catch (Exception e) {
                e.printStackTrace();
                out.print("error_inesperado");
            } finally {
                
                if (checkRs != null) try { checkRs.close(); } catch (SQLException ignore) {}
                if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
            }
            break;

        case "listar":
            try {
                st = conn.createStatement();
                rs = st.executeQuery("SELECT id, nombre FROM Marcas ORDER BY nombre ASC;");
                while (rs.next()) {
%>
<tr>
    <td><% out.print(rs.getString("id"));%></td> <%-- Display ID --%>
    <td><% out.print(rs.getString("nombre"));%></td>
    <td>
        <a style="cursor: pointer" onclick="datosModif('<% out.print(rs.getString("id"));%>', '<%= rs.getString("nombre").replace("'", "\\'")%>')" data-toggle="modal" data-target="#exampleModal">
            <i class="fas fa-edit" style="color:green"></i>
        </a>
        <a style="cursor: pointer" onclick="dell(<% out.print(rs.getString("id"));%>)">
            <i class="fas fa-trash-alt" style="color:red"></i>
        </a>
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
            break;

        case "eliminar":
            try {
                int pk = Integer.parseInt(pkStr);
                String checkModelsSql = "SELECT COUNT(*) FROM Modelos WHERE id_marca = ?";
                ps = conn.prepareStatement(checkModelsSql);
                ps.setInt(1, pk);
                ResultSet modelCountRs = ps.executeQuery();
                modelCountRs.next();
                if (modelCountRs.getInt(1) > 0) {
                    out.print("marca_con_modelos"); 
                    break;
                }
                if (modelCountRs != null) modelCountRs.close();
                if (ps != null) ps.close();
                String deleteSql = "DELETE FROM Marcas WHERE id = ?";
                ps = conn.prepareStatement(deleteSql);
                ps.setInt(1, pk);
                int rowsAffected = ps.executeUpdate();
                if (rowsAffected > 0) {
                    out.print("exito");
                } else {
                    out.print("no_encontrado");
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
                if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
                if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
            }
            break;

        default:
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("operacion_no_reconocida");
            break;
    }
    if (conn != null && !conn.isClosed()) {
        try { conn.close(); } catch (SQLException ignore) {}
    }
%>