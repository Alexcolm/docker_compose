<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion/Conexion.jsp" %>
<%
    Statement st = null;
    ResultSet rs = null;
    String tipo = request.getParameter("campo");
    String nombre = request.getParameter("nombre"); // Nombre del modelo
    String puerta = request.getParameter("puerta");
    String plaza = request.getParameter("plaza");
    String pk = request.getParameter("pk");
    String marcaId = request.getParameter("marca"); // ID de la marca seleccionada

    if (tipo != null) {
        if (tipo.equals("guardar")) {
            try {
                st = conn.createStatement();
                // **Validación de duplicados: Modelo con el mismo nombre y la misma marca (case-insensitive)**
                String checkSql = "SELECT COUNT(*) FROM Modelos WHERE LOWER(nombre) = LOWER('" + nombre + "') AND id_marca = " + marcaId + ";";
                ResultSet checkRs = st.executeQuery(checkSql);
                checkRs.next();
                if (checkRs.getInt(1) > 0) {
                    out.print("existe"); // Enviar señal de que el modelo ya existe para esa marca
                } else {
                    st.executeUpdate("insert into Modelos(nombre, num_puertas, num_plazas, id_marca) values('" + nombre + "','" + puerta + "','" + plaza + "', " + marcaId + ")");
                }
                if (checkRs != null) try { checkRs.close(); } catch (SQLException ignore) {}
            } catch (SQLException e) {
                e.printStackTrace();
                out.print("error"); // Manejo básico de errores SQL
            } finally {
                // Cerrar recursos de forma segura
                if (st != null) try { st.close(); } catch (SQLException e) { /* ignore */ }
            }
        } else if (tipo.equals("listar")) {
            try {
                st = conn.createStatement();
                rs = st.executeQuery("SELECT m.id, m.nombre, m.num_puertas, m.num_plazas, ma.nombre as nombre_marca, ma.id as id_marca FROM Modelos m JOIN Marcas ma ON m.id_marca = ma.id ORDER BY m.id;");
                while (rs.next()) {
%>
<tr>
    <td><% out.print(rs.getString("id"));%></td>
    <td><% out.print(rs.getString("nombre"));%></td>
    <td><% out.print(rs.getString("num_puertas"));%></td>
    <td><% out.print(rs.getString("num_plazas"));%></td>
    <td><% out.print(rs.getString("nombre_marca"));%></td>
    <td>
        <a style="cursor: pointer"><i class="fas fa-edit" style="color:green" onclick="datosModif('<% out.print(rs.getString("id"));%>', '<% out.print(rs.getString("nombre"));%>', '<% out.print(rs.getString("num_puertas"));%>', '<% out.print(rs.getString("num_plazas"));%>', '<% out.print(rs.getString("id_marca"));%>')" data-toggle="modal"></i></a>
        <a style="cursor: pointer"><i class="fas fa-trash-alt" style="color:red" onclick="dell(<% out.print(rs.getString("id"));%>)"></i></a>
    </td>
</tr>
<%
                }
            } catch (SQLException e) { // Cambiado de Exception a SQLException para ser más específico
                e.printStackTrace();
            } finally {
                if (st != null) try { st.close(); } catch (SQLException ignore) {}
                if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
            }
        } else if (tipo.equals("modificar")) {
            try {
                st = conn.createStatement();
                // Considerar una validación de duplicados similar si el nombre o la marca cambian durante la modificación
                st.executeUpdate("update Modelos set nombre='" + nombre + "', num_puertas='" + puerta + "', num_plazas='" + plaza + "', id_marca=" + marcaId + " where id=" + pk);
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                if (st != null) try { st.close(); } catch (SQLException ignore) {}
            }
        } else if (tipo.equals("eliminar")) {
            try {
                st = conn.createStatement();
                st.executeUpdate("delete from Modelos where id=" + pk + "");
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                if (st != null) try { st.close(); } catch (SQLException ignore) {}
            }
        } else if (tipo.equals("listarMarcas")) {
            try {
                st = conn.createStatement();
                rs = st.executeQuery("SELECT id, nombre FROM Marcas ORDER BY nombre;");
                while (rs.next()) {
%>
<option value="<%= rs.getString("id") %>"><%= rs.getString("nombre") %></option>
<%
                }
            } catch (SQLException e) { // Cambiado de Exception a SQLException para ser más específico
                e.printStackTrace();
            } finally {
                if (st != null) try { st.close(); } catch (SQLException ignore) {}
                if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
            }
        }
    }
    // Estos finally blocks son redundantes si ya están dentro de cada if/else if.
    // Es mejor que cada bloque maneje su propio cierre de recursos.
    // if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
    // if (st != null) try { st.close(); } catch (SQLException ignore) {}
%>