<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion/Conexion.jsp" %>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Timestamp"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.sql.SQLException"%>
<%@page import="jakarta.servlet.http.HttpServletResponse"%>

<%
    PreparedStatement ps = null;
    ResultSet rs = null;
    Statement st = null;

    String tipo = request.getParameter("campo");
    String cedula = request.getParameter("cedula");
    String nombre = request.getParameter("nombre");
    String cargo = request.getParameter("cargo");
    String correo = request.getParameter("correo");
    String telefono = request.getParameter("telefono");
    String estado = request.getParameter("estado");
    String pk = request.getParameter("pk");
    if (cedula != null) cedula = cedula.trim();
    if (nombre != null) nombre = nombre.trim();
    if (cargo != null) cargo = cargo.trim();
    if (correo != null) correo = correo.trim();
    if (telefono != null) telefono = telefono.trim();
    if (estado != null) estado = estado.trim();


    if (tipo == null) {
        
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        out.print("Tipo de operación no especificado.");
        return;
    }

    try {
        switch (tipo) {
            case "guardar":
                String checkSql;
                ResultSet checkRs;
                checkSql = "SELECT COUNT(*) FROM Personales WHERE cedula = ?";
                ps = conn.prepareStatement(checkSql);
                ps.setString(1, cedula);
                checkRs = ps.executeQuery();
                checkRs.next();
                if (checkRs.getInt(1) > 0) {
                    out.print("cedula_existe");
                    return;
                }
                checkRs.close();
                ps.close();
                checkSql = "SELECT COUNT(*) FROM Personales WHERE telefono = ?";
                ps = conn.prepareStatement(checkSql);
                ps.setString(1, telefono);
                checkRs = ps.executeQuery();
                checkRs.next();
                if (checkRs.getInt(1) > 0) {
                    out.print("telefono_existe");
                    return;
                }
                checkRs.close();
                ps.close();
                checkSql = "SELECT COUNT(*) FROM Personales WHERE LOWER(correo) = LOWER(?)";
                ps = conn.prepareStatement(checkSql);
                ps.setString(1, correo);
                checkRs = ps.executeQuery();
                checkRs.next();
                if (checkRs.getInt(1) > 0) {
                    out.print("correo_existe");
                    return;
                }
                checkRs.close();
                ps.close();
                checkSql = "SELECT COUNT(*) FROM Personales WHERE LOWER(nombre_completo) = LOWER(?)";
                ps = conn.prepareStatement(checkSql);
                ps.setString(1, nombre);
                checkRs = ps.executeQuery();
                checkRs.next();
                if (checkRs.getInt(1) > 0) {
                    out.print("nombre_existe");
                    return;
                }
                checkRs.close();
                ps.close();
                String insertSql = "INSERT INTO Personales(cedula, nombre_completo, cargo, telefono, estado, correo) VALUES(?, ?, ?, ?, ?, ?)";
                ps = conn.prepareStatement(insertSql);
                ps.setString(1, cedula);
                ps.setString(2, nombre);
                ps.setString(3, cargo);
                ps.setString(4, telefono);
                ps.setString(5, estado);
                ps.setString(6, correo);
                ps.executeUpdate();
                out.print("exito"); 
                break;

            case "listar":
                st = conn.createStatement();
                rs = st.executeQuery("SELECT id, cedula, nombre_completo, cargo, telefono, estado, correo, fecha_registro FROM Personales ORDER BY id DESC"); 
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");

                while (rs.next()) {
                    int id = rs.getInt("id");
                    String ced = rs.getString("cedula");
                    String nom = rs.getString("nombre_completo");
                    String car = rs.getString("cargo");
                    String tel = rs.getString("telefono");
                    String est = rs.getString("estado");
                    String corr = rs.getString("correo");
                    Timestamp fechaRegistro = rs.getTimestamp("fecha_registro");
                    String fechaFormateada = "";
                    if (fechaRegistro != null) {
                        fechaFormateada = sdf.format(fechaRegistro);
                    }
%>
<tr>
    <td><%= id%></td>
    <td><%= ced%></td>
    <td><%= nom%></td>
    <td><%= car%></td>
    <td><%= tel%></td>
    <td><%= corr%></td>
    <td><%= est%></td>
    <td><%= fechaFormateada%></td>
    <td>
        <a style="cursor: pointer">
            <i class="fas fa-edit" style="color:green"
               onclick="datosModif('<%= id%>', '<%= ced%>', '<%= nom%>', '<%= car%>', '<%= tel%>', '<%= corr%>', '<%= est%>')"
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
                break;

            case "modificar":
                checkSql = "SELECT COUNT(*) FROM Personales WHERE cedula = ? AND id <> ?";
                ps = conn.prepareStatement(checkSql);
                ps.setString(1, cedula);
                ps.setInt(2, Integer.parseInt(pk));
                checkRs = ps.executeQuery();
                checkRs.next();
                if (checkRs.getInt(1) > 0) {
                    out.print("cedula_existe");
                    return;
                }
                checkRs.close();
                ps.close();
                checkSql = "SELECT COUNT(*) FROM Personales WHERE telefono = ? AND id <> ?";
                ps = conn.prepareStatement(checkSql);
                ps.setString(1, telefono);
                ps.setInt(2, Integer.parseInt(pk));
                checkRs = ps.executeQuery();
                checkRs.next();
                if (checkRs.getInt(1) > 0) {
                    out.print("telefono_existe");
                    return;
                }
                checkRs.close();
                ps.close();
                checkSql = "SELECT COUNT(*) FROM Personales WHERE LOWER(correo) = LOWER(?) AND id <> ?";
                ps = conn.prepareStatement(checkSql);
                ps.setString(1, correo);
                ps.setInt(2, Integer.parseInt(pk));
                checkRs = ps.executeQuery();
                checkRs.next();
                if (checkRs.getInt(1) > 0) {
                    out.print("correo_existe");
                    return;
                }
                checkRs.close();
                ps.close();
                checkSql = "SELECT COUNT(*) FROM Personales WHERE LOWER(nombre_completo) = LOWER(?) AND id <> ?";
                ps = conn.prepareStatement(checkSql);
                ps.setString(1, nombre);
                ps.setInt(2, Integer.parseInt(pk));
                checkRs = ps.executeQuery();
                checkRs.next();
                if (checkRs.getInt(1) > 0) {
                    out.print("nombre_existe");
                    return;
                }
                checkRs.close();
                ps.close();

                
                String updateSql = "UPDATE Personales SET cedula=?, nombre_completo=?, cargo=?, telefono=?, correo=?, estado=? WHERE id=?";
                ps = conn.prepareStatement(updateSql);
                ps.setString(1, cedula);
                ps.setString(2, nombre);
                ps.setString(3, cargo);
                ps.setString(4, telefono);
                ps.setString(5, correo);
                ps.setString(6, estado);
                ps.setInt(7, Integer.parseInt(pk));
                ps.executeUpdate();
                out.print("exito"); 
                break;

            case "eliminar":
                String deleteSql = "DELETE FROM Personales WHERE id=?";
                ps = conn.prepareStatement(deleteSql);
                ps.setInt(1, Integer.parseInt(pk));
                int rowsAffected = ps.executeUpdate();
                if (rowsAffected > 0) {
                    out.print("exito");
                } else {
                    out.print("no_encontrado");
                }
                break;

            default:
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("Tipo de operación no reconocido.");
                break;
        }
    } catch (SQLException e) {
        e.printStackTrace();
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        out.print("error_bd"); 
    } catch (NumberFormatException e) {
        e.printStackTrace();
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        out.print("error_formato_id");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (st != null) try { st.close(); } catch (SQLException ignore) {}
        if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
        if (conn != null && !conn.isClosed()) {
            try { conn.close(); } catch (SQLException ignore) {}
        }
    }
%>