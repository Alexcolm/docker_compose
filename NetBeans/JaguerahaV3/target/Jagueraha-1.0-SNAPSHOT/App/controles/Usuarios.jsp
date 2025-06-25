<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion/Conexion.jsp" %>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.Timestamp"%>
<%@page import="java.text.SimpleDateFormat"%>
<%
    Statement st = null;
    ResultSet rs = null;
    PreparedStatement ps = null; 

    String tipo = request.getParameter("campo");
    String nombre = request.getParameter("nombre");
    String usuario = request.getParameter("usuario");
    String contra = request.getParameter("contra");
    String pk = request.getParameter("pk");

    
    if (nombre != null) nombre = nombre.trim();
    if (usuario != null) usuario = usuario.trim();

    if (tipo != null) {
        if (tipo.equals("guardar")) {
            try {
               
                String checkUserSql = "SELECT COUNT(*) FROM Usuarios WHERE LOWER(usuario) = LOWER(?)";
                ps = conn.prepareStatement(checkUserSql);
                ps.setString(1, usuario);
                ResultSet checkUserRs = ps.executeQuery();
                checkUserRs.next();
                if (checkUserRs.getInt(1) > 0) {
                    out.print("usuario_existe");
                    if (checkUserRs != null) checkUserRs.close();
                    if (ps != null) ps.close();
                    return; 
                }
                if (checkUserRs != null) checkUserRs.close();
                if (ps != null) ps.close(); 

                
                String checkNameSql = "SELECT COUNT(*) FROM Usuarios WHERE LOWER(nombre) = LOWER(?)";
                ps = conn.prepareStatement(checkNameSql);
                ps.setString(1, nombre);
                ResultSet checkNameRs = ps.executeQuery();
                checkNameRs.next();
                if (checkNameRs.getInt(1) > 0) {
                    out.print("nombre_existe");
                    if (checkNameRs != null) checkNameRs.close();
                    if (ps != null) ps.close();
                    return;
                }
                if (checkNameRs != null) checkNameRs.close();
                if (ps != null) ps.close(); 

                
                String insertSql = "INSERT INTO Usuarios(nombre, usuario, contrasena) VALUES(?, ?, ?)";
                ps = conn.prepareStatement(insertSql);
                ps.setString(1, nombre);
                ps.setString(2, usuario);
                ps.setString(3, contra);
                ps.executeUpdate();
                out.print("exito"); 
            } catch (SQLException e) {
                e.printStackTrace();
                out.print("error_bd"); 
            } finally {
                
                if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
            }
        } else if (tipo.equals("listar")) {
            try {
                st = conn.createStatement();
                rs = st.executeQuery("SELECT id, nombre, usuario, contrasena, fecha_registro FROM Usuarios ORDER BY id DESC"); 
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                while (rs.next()) {
                    int id = rs.getInt("id");
                    String nom = rs.getString("nombre");
                    String user = rs.getString("usuario");
                    String pass = rs.getString("contrasena"); 
                    Timestamp fechaCreacion = rs.getTimestamp("fecha_registro");
                    String fechaFormateada = "";
                    if (fechaCreacion != null) {
                        fechaFormateada = sdf.format(fechaCreacion);
                    }
%>
<tr>
    <td><%= id%></td>
    <td><%= nom%></td>
    <td><%= user%></td>
    <td><%= pass%></td> <%-- CUIDADO: Mostrar la contraseña es un riesgo de seguridad --%>
    <td><%= fechaFormateada%></td>
    <td>
        <a style="cursor: pointer">
            <i class="fas fa-edit" style="color:green"
               onclick="datosModif('<%= id%>', '<%= nom%>', '<%= user%>', '<%= pass%>')"
               data-toggle="modal" data-target="#exampleModal"></i>
        </a>
        <a style="cursor: pointer">
            <i class="fas fa-trash-alt" style="color:red"
               onclick="dell(<%= id%>)"></i>
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
        } else if (tipo.equals("modificar")) {
            try {
                
                String checkUserSql = "SELECT COUNT(*) FROM Usuarios WHERE LOWER(usuario) = LOWER(?) AND id <> ?";
                ps = conn.prepareStatement(checkUserSql);
                ps.setString(1, usuario);
                ps.setInt(2, Integer.parseInt(pk));
                ResultSet checkUserRs = ps.executeQuery();
                checkUserRs.next();
                if (checkUserRs.getInt(1) > 0) {
                    out.print("usuario_existe");
                    if (checkUserRs != null) checkUserRs.close();
                    if (ps != null) ps.close();
                    return;
                }
                if (checkUserRs != null) checkUserRs.close();
                if (ps != null) ps.close(); 

                
                String checkNameSql = "SELECT COUNT(*) FROM Usuarios WHERE LOWER(nombre) = LOWER(?) AND id <> ?";
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
                if (ps != null) ps.close(); 
                String updateSql = "UPDATE Usuarios SET nombre=?, usuario=?, contrasena=? WHERE id=?";
                ps = conn.prepareStatement(updateSql);
                ps.setString(1, nombre);
                ps.setString(2, usuario);
                ps.setString(3, contra);
                ps.setInt(4, Integer.parseInt(pk));
                ps.executeUpdate();
                out.print("exito"); 

            } catch (SQLException e) {
                e.printStackTrace();
                out.print("error_bd");
            } finally {
                if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
            }
        } else if (tipo.equals("eliminar")) {
            try {
                String sql = "DELETE FROM Usuarios WHERE id=?";
                ps = conn.prepareStatement(sql); 
                ps.setInt(1, Integer.parseInt(pk));
                ps.executeUpdate();
                out.print("exito"); 
            } catch (SQLException e) {
                e.printStackTrace();
                out.print("error_bd");
            } finally {
                if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
            }
        }
    }
    if (conn != null && !conn.isClosed()) {
        try { conn.close(); } catch (SQLException ignore) {}
    }
%>