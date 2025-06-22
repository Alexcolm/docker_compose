<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion/Conexion.jsp" %>
<%@page import="java.sql.PreparedStatement" %>
<%@page import="java.sql.Statement" %>
<%@page import="java.sql.ResultSet" %>
<%@page import="java.sql.Timestamp" %>

<%
    Statement st = null;
    ResultSet rs = null;
    PreparedStatement ps = null;
    String tipo = request.getParameter("campo");

    String pk = request.getParameter("pk");

    try {
        if (tipo.equals("guardar")) {
            String idCliente = request.getParameter("idCliente");
            String idCombustible = request.getParameter("idCombustible");
            String cantidadLitros = request.getParameter("cantidadLitros");
            String direccionEntrega = request.getParameter("direccionEntrega");
            String idCiudad = request.getParameter("idCiudad");
            String estado = request.getParameter("estado");

            String sql = "INSERT INTO pedidos(id_cliente, id_combustible, cantidad_litros, direccion_entrega, id_ciudad, estado) VALUES(?, ?, ?, ?, ?, ?)";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(idCliente));
            ps.setInt(2, Integer.parseInt(idCombustible));
            ps.setDouble(3, Double.parseDouble(cantidadLitros));
            ps.setString(4, direccionEntrega);
            ps.setInt(5, Integer.parseInt(idCiudad));
            ps.setString(6, estado);
            ps.executeUpdate();
            out.print("success");

        } else if (tipo.equals("listar")) {
            st = conn.createStatement();
            rs = st.executeQuery("SELECT p.id_pedido, c.nombre_empresa AS cliente_nombre, co.nombre AS combustible_nombre, " +
                                 "p.cantidad_litros, p.direccion_entrega, ciu.nombre AS ciudad_nombre, p.fecha_pedido, p.estado, " +
                                 "p.id_cliente, p.id_combustible, p.id_ciudad " +
                                 "FROM pedidos p " +
                                 "JOIN cliente c ON p.id_cliente = c.id_cliente " +
                                 "JOIN combustibles co ON p.id_combustible = co.id_combustible " +
                                 "JOIN Ciudades ciu ON p.id_ciudad = ciu.id " +
                                 "ORDER BY p.id_pedido DESC;");
            while (rs.next()) {
                Timestamp fechaPedido = rs.getTimestamp("fecha_pedido");
                String fechaFormateada = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(fechaPedido);
%>
<tr>
    <td><% out.print(rs.getString("id_pedido"));%></td>
    <td><% out.print(rs.getString("cliente_nombre"));%></td>
    <td><% out.print(rs.getString("combustible_nombre"));%></td>
    <td><% out.print(rs.getString("cantidad_litros"));%></td>
    <td><% out.print(rs.getString("direccion_entrega"));%></td>
    <td><% out.print(rs.getString("ciudad_nombre"));%></td> <%-- Mostrar nombre de la ciudad --%>
    <td><% out.print(fechaFormateada);%></td>
    <td><% out.print(rs.getString("estado"));%></td>
    <td>
        <a style="cursor: pointer" onclick="datosModifPedido(
            '<% out.print(rs.getString("id_pedido"));%>',
            '<% out.print(rs.getString("id_cliente"));%>',
            '<% out.print(rs.getString("id_combustible"));%>',
            '<% out.print(rs.getString("cantidad_litros"));%>',
            '<% out.print(rs.getString("direccion_entrega"));%>',
            '<% out.print(rs.getString("id_ciudad"));%>', <%-- Pasar id_ciudad --%>
            '<% out.print(rs.getString("estado"));%>'
        )"><i class="fas fa-edit" style="color:green"></i></a>
        <a style="cursor: pointer" onclick="dellPedido(<% out.print(rs.getString("id_pedido"));%>)"><i class="fas fa-trash-alt" style="color:red"></i></a>
    </td>
</tr>
<%
            }
        } else if (tipo.equals("modificar")) {
            String idCliente = request.getParameter("idCliente");
            String idCombustible = request.getParameter("idCombustible");
            String cantidadLitros = request.getParameter("cantidadLitros");
            String direccionEntrega = request.getParameter("direccionEntrega");
            String idCiudad = request.getParameter("idCiudad");
            String estado = request.getParameter("estado");

            String sql = "UPDATE pedidos SET id_cliente=?, id_combustible=?, cantidad_litros=?, direccion_entrega=?, id_ciudad=?, estado=? WHERE id_pedido=?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(idCliente));
            ps.setInt(2, Integer.parseInt(idCombustible));
            ps.setDouble(3, Double.parseDouble(cantidadLitros));
            ps.setString(4, direccionEntrega);
            ps.setInt(5, Integer.parseInt(idCiudad));
            ps.setString(6, estado);
            ps.setInt(7, Integer.parseInt(pk));
            ps.executeUpdate();
            out.print("success");

        } else if (tipo.equals("eliminar")) {
            st = conn.createStatement();
            st.executeUpdate("DELETE FROM pedidos WHERE id_pedido=" + pk);
            out.print("success");

        } else if (tipo.equals("listarClientes")) {
            st = conn.createStatement();
            rs = st.executeQuery("SELECT id_cliente, nombre_empresa FROM cliente ORDER BY nombre_empresa;");
            while (rs.next()) {
%>
<option value="<%= rs.getString("id_cliente")%>"><%= rs.getString("nombre_empresa")%></option>
<%
            }
        } else if (tipo.equals("listarCombustibles")) {
            st = conn.createStatement();
            rs = st.executeQuery("SELECT id_combustible, nombre FROM combustibles ORDER BY nombre;");
            while (rs.next()) {
%>
<option value="<%= rs.getString("id_combustible")%>"><%= rs.getString("nombre")%></option>
<%
            }
        } else if (tipo.equals("listarCiudades")) {
            st = conn.createStatement();
            rs = st.executeQuery("SELECT id, nombre FROM Ciudades ORDER BY nombre;");
            while (rs.next()) {
%>
<option value="<%= rs.getString("id")%>"><%= rs.getString("nombre")%></option>
<%
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        out.print("Error en el controlador: " + e.getMessage());
    } finally {
        if (rs != null) { try { rs.close(); } catch (Exception e) {} }
        if (st != null) { try { st.close(); } catch (Exception e) {} }
        if (ps != null) { try { ps.close(); } catch (Exception e) {} }
        if (conn != null && !conn.isClosed()) {
            try { conn.close(); } catch (Exception e) {}
        }
    }
%>