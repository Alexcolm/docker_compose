<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion/Conexion.jsp" %>
<%@page import="java.sql.PreparedStatement" %>
<%@page import="java.sql.Statement" %>
<%@page import="java.sql.ResultSet" %>
<%@page import="java.sql.Timestamp" %>
<%@page import="java.text.SimpleDateFormat" %>
<%@page import="java.sql.SQLException" %>
<%@page import="jakarta.servlet.http.HttpServletResponse"%> <%-- Usando Jakarta EE --%>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    PreparedStatement ps = null;
    Statement st = null;
    ResultSet rs = null;

    String tipo = request.getParameter("campo");
    String pk = request.getParameter("pk");

    // Recoger y limpiar parámetros
    String empresa = request.getParameter("Empresa") != null ? request.getParameter("Empresa").trim() : "";
    String ruc = request.getParameter("RUC") != null ? request.getParameter("RUC").trim() : "";
    String contacto = request.getParameter("contacto") != null ? request.getParameter("contacto").trim() : "";
    String telefono = request.getParameter("telefono") != null ? request.getParameter("telefono").trim() : "";
    String correo = request.getParameter("correo") != null ? request.getParameter("correo").trim() : "";

    try {
        if (tipo == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("Tipo de operación no especificado.");
            return;
        }

        switch (tipo) {
            case "guardar":
                // --- Validaciones de duplicados al guardar ---
                String checkSql;
                ResultSet checkRs;

                // 1. Verificar Nombre de Empresa (case-insensitive)
                checkSql = "SELECT COUNT(*) FROM cliente WHERE LOWER(nombre_empresa) = LOWER(?)";
                ps = conn.prepareStatement(checkSql);
                ps.setString(1, empresa);
                checkRs = ps.executeQuery();
                checkRs.next();
                if (checkRs.getInt(1) > 0) {
                    out.print("empresa_existe");
                    return;
                }
                checkRs.close();
                ps.close();

                // 2. Verificar RUC
                checkSql = "SELECT COUNT(*) FROM cliente WHERE ruc = ?";
                ps = conn.prepareStatement(checkSql);
                ps.setString(1, ruc);
                checkRs = ps.executeQuery();
                checkRs.next();
                if (checkRs.getInt(1) > 0) {
                    out.print("ruc_existe");
                    return;
                }
                checkRs.close();
                ps.close();

                // 3. Verificar Telefono
                checkSql = "SELECT COUNT(*) FROM cliente WHERE telefono_contacto = ?";
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

                // 4. Verificar Correo (case-insensitive)
                checkSql = "SELECT COUNT(*) FROM cliente WHERE LOWER(email_contacto) = LOWER(?)";
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

                // Si todas las validaciones pasan, proceder con la inserción
                String insertSql = "INSERT INTO cliente(nombre_empresa, ruc, nombre_contacto, telefono_contacto, email_contacto) VALUES(?, ?, ?, ?, ?)";
                ps = conn.prepareStatement(insertSql);
                ps.setString(1, empresa);
                ps.setString(2, ruc);
                ps.setString(3, contacto);
                ps.setString(4, telefono);
                ps.setString(5, correo);
                ps.executeUpdate();
                out.print("exito");
                break;

            case "listar":
                st = conn.createStatement();
                rs = st.executeQuery("SELECT id_cliente, nombre_empresa, ruc, nombre_contacto, telefono_contacto, email_contacto, fecha_registro FROM cliente ORDER BY id_cliente DESC;");
                
                SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");

                while (rs.next()) {
                    Timestamp fechaRegistro = rs.getTimestamp("fecha_registro");
                    String fechaFormateada = (fechaRegistro != null) ? sdf.format(fechaRegistro) : "";
%>
<tr>
    <td><% out.print(rs.getString("id_cliente")); %></td>
    <td><% out.print(rs.getString("nombre_empresa")); %></td>
    <td><% out.print(rs.getString("ruc")); %></td>
    <td><% out.print(rs.getString("nombre_contacto")); %></td>
    <td><% out.print(rs.getString("telefono_contacto")); %></td>
    <td><% out.print(rs.getString("email_contacto")); %></td>
    <td><% out.print(fechaFormateada); %></td>
    <td>
        <a style="cursor: pointer" onclick="datosModif(
            '<% out.print(rs.getString("id_cliente")); %>', 
            '<% out.print(rs.getString("nombre_empresa")); %>', 
            '<% out.print(rs.getString("ruc")); %>', 
            '<% out.print(rs.getString("nombre_contacto")); %>', 
            '<% out.print(rs.getString("telefono_contacto")); %>', 
            '<% out.print(rs.getString("email_contacto")); %>')" 
            data-toggle="modal" data-target="#exampleModal">
            <i class="fas fa-edit" style="color:green"></i>
        </a>
        <a style="cursor: pointer" onclick="dell(<% out.print(rs.getString("id_cliente")); %>)">
            <i class="fas fa-trash-alt" style="color:red"></i>
        </a>
    </td>
</tr>
<%
                }
                break;

            case "modificar":
                // --- Validaciones de duplicados al modificar (excluyendo el propio registro) ---
                int currentPk = Integer.parseInt(pk);

                // 1. Verificar Nombre de Empresa (case-insensitive)
                checkSql = "SELECT COUNT(*) FROM cliente WHERE LOWER(nombre_empresa) = LOWER(?) AND id_cliente <> ?";
                ps = conn.prepareStatement(checkSql);
                ps.setString(1, empresa);
                ps.setInt(2, currentPk);
                checkRs = ps.executeQuery();
                checkRs.next();
                if (checkRs.getInt(1) > 0) {
                    out.print("empresa_existe");
                    return;
                }
                checkRs.close();
                ps.close();

                // 2. Verificar RUC
                checkSql = "SELECT COUNT(*) FROM cliente WHERE ruc = ? AND id_cliente <> ?";
                ps = conn.prepareStatement(checkSql);
                ps.setString(1, ruc);
                ps.setInt(2, currentPk);
                checkRs = ps.executeQuery();
                checkRs.next();
                if (checkRs.getInt(1) > 0) {
                    out.print("ruc_existe");
                    return;
                }
                checkRs.close();
                ps.close();

                // 3. Verificar Telefono
                checkSql = "SELECT COUNT(*) FROM cliente WHERE telefono_contacto = ? AND id_cliente <> ?";
                ps = conn.prepareStatement(checkSql);
                ps.setString(1, telefono);
                ps.setInt(2, currentPk);
                checkRs = ps.executeQuery();
                checkRs.next();
                if (checkRs.getInt(1) > 0) {
                    out.print("telefono_existe");
                    return;
                }
                checkRs.close();
                ps.close();

                // 4. Verificar Correo (case-insensitive)
                checkSql = "SELECT COUNT(*) FROM cliente WHERE LOWER(email_contacto) = LOWER(?) AND id_cliente <> ?";
                ps = conn.prepareStatement(checkSql);
                ps.setString(1, correo);
                ps.setInt(2, currentPk);
                checkRs = ps.executeQuery();
                checkRs.next();
                if (checkRs.getInt(1) > 0) {
                    out.print("correo_existe");
                    return;
                }
                checkRs.close();
                ps.close();

                // Si todas las validaciones pasan, proceder con la actualización
                String updateSql = "UPDATE cliente SET nombre_empresa=?, ruc=?, nombre_contacto=?, telefono_contacto=?, email_contacto=? WHERE id_cliente=?";
                ps = conn.prepareStatement(updateSql);
                ps.setString(1, empresa);
                ps.setString(2, ruc);
                ps.setString(3, contacto);
                ps.setString(4, telefono);
                ps.setString(5, correo);
                ps.setInt(6, currentPk);
                ps.executeUpdate();
                out.print("exito");
                break;

            case "eliminar":
                String deleteSql = "DELETE FROM cliente WHERE id_cliente = ?";
                ps = conn.prepareStatement(deleteSql);
                ps.setInt(1, Integer.parseInt(pk));
                int rowsAffected = ps.executeUpdate();
                if (rowsAffected > 0) {
                    out.print("exito");
                } else {
                    out.print("no_encontrado"); // Indicar que no se encontró el registro para eliminar
                }
                break;

            default:
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("Tipo de operación no reconocido.");
                break;
        }
    } catch (NumberFormatException e) {
        // Manejar error si pk no es un número válido
        e.printStackTrace();
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        out.print("error_formato_id");
    } catch (SQLException e) {
        // Manejar errores de SQL
        e.printStackTrace();
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        out.print("error_bd");
    } catch (Exception e) {
        // Manejar cualquier otra excepción inesperada
        e.printStackTrace();
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        out.print("error_inesperado");
    } finally {
        // Asegurarse de cerrar todos los recursos de la base de datos
        if (rs != null) try { rs.close(); } catch (SQLException e) { /* log error */ }
        if (st != null) try { st.close(); } catch (SQLException e) { /* log error */ }
        if (ps != null) try { ps.close(); } catch (SQLException e) { /* log error */ }
        if (conn != null && !conn.isClosed()) try { conn.close(); } catch (SQLException e) { /* log error */ }
    }
%>