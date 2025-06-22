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
    PreparedStatement ps = null; // Declarar PreparedStatement aquí para cierre en finally

    String tipo = request.getParameter("campo");
    String nombre = request.getParameter("nombre");
    String usuario = request.getParameter("usuario");
    String contra = request.getParameter("contra");
    String pk = request.getParameter("pk");

    // Limpiar espacios en blanco al inicio y al final para una mejor validación
    if (nombre != null) nombre = nombre.trim();
    if (usuario != null) usuario = usuario.trim();

    if (tipo != null) {
        if (tipo.equals("guardar")) {
            try {
                // 1. Verificar si el usuario ya existe (case-insensitive)
                String checkUserSql = "SELECT COUNT(*) FROM Usuarios WHERE LOWER(usuario) = LOWER(?)";
                ps = conn.prepareStatement(checkUserSql);
                ps.setString(1, usuario);
                ResultSet checkUserRs = ps.executeQuery();
                checkUserRs.next();
                if (checkUserRs.getInt(1) > 0) {
                    out.print("usuario_existe");
                    if (checkUserRs != null) checkUserRs.close();
                    if (ps != null) ps.close();
                    return; // Detener la ejecución si el usuario ya existe
                }
                if (checkUserRs != null) checkUserRs.close();
                if (ps != null) ps.close(); // Cerrar ps antes de reasignar

                // 2. Verificar si el nombre ya existe (case-insensitive)
                String checkNameSql = "SELECT COUNT(*) FROM Usuarios WHERE LOWER(nombre) = LOWER(?)";
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

                // 3. Si no hay duplicados, proceder con la inserción
                String insertSql = "INSERT INTO Usuarios(nombre, usuario, contrasena) VALUES(?, ?, ?)";
                ps = conn.prepareStatement(insertSql);
                ps.setString(1, nombre);
                ps.setString(2, usuario);
                ps.setString(3, contra);
                ps.executeUpdate();
                out.print("exito"); // Indicar que la operación fue exitosa

            } catch (SQLException e) {
                e.printStackTrace();
                out.print("error_bd"); // Enviar señal de error de base de datos
            } finally {
                // Asegúrate de que ps se cierra aquí, incluso si se cerró antes en el return
                if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
            }
        } else if (tipo.equals("listar")) {
            try {
                st = conn.createStatement();
                rs = st.executeQuery("SELECT id, nombre, usuario, contrasena, fecha_registro FROM Usuarios ORDER BY id DESC"); // Agregado ORDER BY para mejor visualización
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                while (rs.next()) {
                    int id = rs.getInt("id");
                    String nom = rs.getString("nombre");
                    String user = rs.getString("usuario");
                    // No pasar la contraseña directamente si no es necesario para la edición
                    String pass = rs.getString("contrasena"); // Para la edición, si se envía de nuevo
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
                // 1. Verificar si el usuario ya existe en OTRO registro (case-insensitive)
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
                if (ps != null) ps.close(); // Cerrar ps antes de reasignar

                // 2. Verificar si el nombre ya existe en OTRO registro (case-insensitive)
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
                if (ps != null) ps.close(); // Cerrar ps antes de reasignar

                // 3. Si no hay duplicados, proceder con la actualización
                String updateSql = "UPDATE Usuarios SET nombre=?, usuario=?, contrasena=? WHERE id=?";
                ps = conn.prepareStatement(updateSql);
                ps.setString(1, nombre);
                ps.setString(2, usuario);
                ps.setString(3, contra);
                ps.setInt(4, Integer.parseInt(pk));
                ps.executeUpdate();
                out.print("exito"); // Indicar que la operación fue exitosa

            } catch (SQLException e) {
                e.printStackTrace();
                out.print("error_bd"); // Enviar señal de error de base de datos
            } finally {
                 // Asegúrate de que ps se cierra aquí, incluso si se cerró antes en el return
                if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
            }
        } else if (tipo.equals("eliminar")) {
            try {
                String sql = "DELETE FROM Usuarios WHERE id=?";
                ps = conn.prepareStatement(sql); // Usar PreparedStatement para eliminar también
                ps.setInt(1, Integer.parseInt(pk));
                ps.executeUpdate();
                out.print("exito"); // Indicar éxito al cliente
            } catch (SQLException e) {
                e.printStackTrace();
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