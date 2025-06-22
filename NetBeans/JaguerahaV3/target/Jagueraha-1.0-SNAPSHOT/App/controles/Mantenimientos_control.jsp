<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion/Conexion.jsp" %>
<%@page import="java.sql.PreparedStatement" %>
<%@page import="java.sql.Statement" %>
<%@page import="java.sql.ResultSet" %>
<%@page import="java.sql.Date" %>
<%@page import="java.text.SimpleDateFormat" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    PreparedStatement ps = null;
    Statement st = null;
    ResultSet rs = null;

    String tipo = request.getParameter("campo");
    String pk = request.getParameter("pk");

    try {
        if (tipo.equals("guardar")) {
            String idVehiculo = request.getParameter("idVehiculo");
            String fechaMantenimiento = request.getParameter("fechaMantenimiento");
            String kilometraje = request.getParameter("kilometraje");
            String tipoMantenimiento = request.getParameter("tipoMantenimiento");
            String descripcion = request.getParameter("descripcion");
            String costo = request.getParameter("costo");
            String tallerResponsable = request.getParameter("tallerResponsable");
            String fechaProximoServicio = request.getParameter("ProximoServicio");

            String sql = "INSERT INTO mantenimientos(id_vehiculo, fecha_mantenimiento, kilometraje, tipo_mantenimiento, descripcion, costo, taller_responsable, proximo_servicio) VALUES(?, ?, ?, ?, ?, ?, ?, ?)";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(idVehiculo));
            ps.setDate(2, Date.valueOf(fechaMantenimiento));
            ps.setInt(3, Integer.parseInt(kilometraje));
            ps.setString(4, tipoMantenimiento);
            ps.setString(5, descripcion);
            ps.setDouble(6, Double.parseDouble(costo));
            ps.setString(7, tallerResponsable);
            
            if (fechaProximoServicio != null && !fechaProximoServicio.isEmpty()) {
                ps.setDate(8, Date.valueOf(fechaProximoServicio));
            } else {
                ps.setNull(8, java.sql.Types.DATE);
            }
            
            ps.executeUpdate();
            out.print("success");

        } else if (tipo.equals("listar")) {
            st = conn.createStatement();
            rs = st.executeQuery("SELECT m.*, v.descripcion as vehiculo_desc, v.chapa as vehiculo_chapa "
                                + "FROM mantenimientos m "
                                + "JOIN vehiculos v ON m.id_vehiculo = v.id "
                                + "ORDER BY m.id_mantenimiento DESC;");

            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");

            while (rs.next()) {
                Date fechaMantenimiento = rs.getDate("fecha_mantenimiento");
                String fechaFormateada = (fechaMantenimiento != null) ? sdf.format(fechaMantenimiento) : "";
                
                Date fechaProximo = rs.getDate("fecha_proximo_servicio");
                String fechaProximoFormateada = (fechaProximo != null) ? sdf.format(fechaProximo) : "N/A";

%>
<tr>
    <td><% out.print(rs.getString("id_mantenimiento")); %></td>
    <td><% out.print(rs.getString("vehiculo_desc") + " (" + rs.getString("vehiculo_chapa") + ")"); %></td>
    <td><% out.print(fechaFormateada); %></td>
    <td><% out.print(rs.getString("kilometraje")); %></td>
    <td><% out.print(rs.getString("tipo_mantenimiento")); %></td>
    <td><% out.print(String.format("%,.0f", rs.getDouble("costo")).replace(",",".")); %></td>
    <td>
        <a style="cursor: pointer" onclick="datosModifMantenimiento(
            '<% out.print(rs.getString("id_mantenimiento")); %>',
            '<% out.print(rs.getString("id_vehiculo")); %>',
            '<% out.print(rs.getString("fecha_mantenimiento")); %>',
            '<% out.print(rs.getString("kilometraje")); %>',
            '<% out.print(rs.getString("tipo_mantenimiento")); %>',
            '<% out.print(rs.getString("descripcion")); %>',
            '<% out.print(rs.getString("costo")); %>',
            '<% out.print(rs.getString("taller_responsable")); %>',
            '<% out.print(rs.getDate("fecha_proximo_servicio") != null ? rs.getString("fecha_proximo_servicio") : ""); %>'
        )"><i class="fas fa-edit" style="color:green"></i></a>
        <a style="cursor: pointer" onclick="dellMantenimiento('<% out.print(rs.getString("id_mantenimiento")); %>')"><i class="fas fa-trash-alt" style="color:red"></i></a>
    </td>
</tr>
<%
            }
        } else if (tipo.equals("modificar")) {
            String idVehiculo = request.getParameter("idVehiculo");
            String fechaMantenimiento = request.getParameter("fechaMantenimiento");
            String kilometraje = request.getParameter("kilometraje");
            String tipoMantenimiento = request.getParameter("tipoMantenimiento");
            String descripcion = request.getParameter("descripcion");
            String costo = request.getParameter("costo");
            String tallerResponsable = request.getParameter("tallerResponsable");
            String fechaProximoServicio = request.getParameter("fechaProximoServicio");

            String sql = "UPDATE mantenimientos SET id_vehiculo=?, fecha_mantenimiento=?, kilometraje=?, tipo_mantenimiento=?, descripcion=?, costo=?, taller_responsable=?, fecha_proximo_servicio=? WHERE id_mantenimiento=?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(idVehiculo));
            ps.setDate(2, Date.valueOf(fechaMantenimiento));
            ps.setInt(3, Integer.parseInt(kilometraje));
            ps.setString(4, tipoMantenimiento);
            ps.setString(5, descripcion);
            ps.setDouble(6, Double.parseDouble(costo));
            ps.setString(7, tallerResponsable);

            if (fechaProximoServicio != null && !fechaProximoServicio.isEmpty()) {
                ps.setDate(8, Date.valueOf(fechaProximoServicio));
            } else {
                ps.setNull(8, java.sql.Types.DATE);
            }
            ps.setInt(9, Integer.parseInt(pk));
            ps.executeUpdate();
            out.print("success");

        } else if (tipo.equals("eliminar")) {
            String sql = "DELETE FROM mantenimientos WHERE id_mantenimiento = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(pk));
            ps.executeUpdate();
            out.print("success");

        } else if (tipo.equals("listarVehiculos")) {
            st = conn.createStatement();
            rs = st.executeQuery("SELECT id, descripcion, chapa FROM vehiculos ORDER BY descripcion;");
            while (rs.next()) {
%>
<option value="<%= rs.getString("id")%>"><%= rs.getString("descripcion") + " (" + rs.getString("chapa") + ")" %></option>
<%
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        out.print("Error en el controlador: " + e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (st != null) try { st.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (conn != null && !conn.isClosed()) try { conn.close(); } catch (Exception e) {}
    }
%>