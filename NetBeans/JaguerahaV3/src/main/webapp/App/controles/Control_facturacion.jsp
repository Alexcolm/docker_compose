<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../conexion/Conexion.jsp" %>
<%@page import="java.sql.PreparedStatement" %>
<%@page import="java.sql.Statement" %>
<%@page import="java.sql.ResultSet" %>
<%@page import="java.sql.SQLException" %>
<%@page import="jakarta.servlet.http.HttpServletResponse" %>
<%@page import="java.io.BufferedReader" %>
<%@page import="java.io.InputStreamReader" %>
<%@page import="java.util.List" %>
<%@page import="java.util.ArrayList" %>
<%@page import="java.sql.Date" %>
<%@page import="java.net.URLEncoder" %>
<%@page import="java.text.DecimalFormat" %>
<%@page import="java.sql.ResultSetMetaData" %>

<%!
    // Helper para formatear números a dos decimales para los onclick en HTML
    private String formatDouble(double value) {
        DecimalFormat df = new DecimalFormat("#.00");
        // Asegúrate de que el separador decimal sea un punto, no una coma, para JS.
        return df.format(value).replace(',', '.'); 
    }

    // Función para recalcular los totales de una factura
    // Esto se llamará después de cada operación de detalle
    private void recalcularTotalesFactura(int idFactura, Connection conn) throws SQLException {
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            // Calcular subtotal_item y monto_iva_item
            String selectDetailsTotalsSql = "SELECT COALESCE(SUM(subtotal_item), 0.0) AS total_subtotal, COALESCE(SUM(monto_iva_item), 0.0) AS total_iva FROM detalles_factura WHERE id_factura = ?";
            ps = conn.prepareStatement(selectDetailsTotalsSql);
            ps.setInt(1, idFactura);
            rs = ps.executeQuery();

            double newSubtotal = 0.0;
            double newMontoIva = 0.0;

            if (rs.next()) {
                newSubtotal = rs.getDouble("total_subtotal");
                newMontoIva = rs.getDouble("total_iva");
            }
            rs.close();
            ps.close();

            // Obtener descuento_total y monto_retencion de la factura principal
            String selectFacturaInfoSql = "SELECT descuento_total, monto_retencion FROM facturas WHERE id_factura = ?";
            ps = conn.prepareStatement(selectFacturaInfoSql);
            ps.setInt(1, idFactura);
            rs = ps.executeQuery();

            double descuentoTotal = 0.0;
            double montoRetencion = 0.0;
            if (rs.next()) {
                descuentoTotal = rs.getDouble("descuento_total");
                montoRetencion = rs.getDouble("monto_retencion");
            }
            rs.close();
            ps.close();

            // Calcular el total a pagar
            double newTotalPagar = newSubtotal + newMontoIva - descuentoTotal - montoRetencion;

            // Actualizar los campos de la factura
            String updateFacturaTotalsSql = "UPDATE facturas SET subtotal = ?, monto_iva = ?, total_pagar = ? WHERE id_factura = ?";
            ps = conn.prepareStatement(updateFacturaTotalsSql);
            ps.setDouble(1, newSubtotal);
            ps.setDouble(2, newMontoIva);
            ps.setDouble(3, newTotalPagar);
            ps.setInt(4, idFactura);
            ps.executeUpdate();

        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { System.err.println("Error closing ResultSet in recalcularTotalesFactura: " + e.getMessage()); }
            if (ps != null) try { ps.close(); } catch (SQLException e) { System.err.println("Error closing PreparedStatement in recalcularTotalesFactura: " + e.getMessage()); }
        }
    }
%>

<%
    // Set headers to prevent caching
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
    response.setContentType("text/plain;charset=UTF-8"); // Ensure proper character encoding for response

    PreparedStatement ps = null;
    Statement st = null;
    ResultSet rs = null;

    String tipo = request.getParameter("campo");
    // Para operaciones de detalles, usamos un campo diferente para distinguirlo
    String tipoDetalle = request.getParameter("campoDetalle");

    try {
        if (tipo == null && tipoDetalle == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("error: tipo de operación no especificado");
            return;
        }

        // Si es una operación de detalle, usamos tipoDetalle, si no, usamos tipo
        String operationType = (tipoDetalle != null) ? tipoDetalle : tipo;

        switch (operationType) {
            case "guardar":
            case "modificar":
                // Lógica para guardar/modificar Factura Principal
                String idFacturaStr = request.getParameter("id_factura");
                int id_factura = (idFacturaStr != null && !idFacturaStr.isEmpty() && !idFacturaStr.equals("null")) ? Integer.parseInt(idFacturaStr) : 0;

                String numero_factura = request.getParameter("numero_factura");
                String fecha_emision_str = request.getParameter("fecha_emision");
                Date fecha_emision = (fecha_emision_str != null && !fecha_emision_str.isEmpty()) ? Date.valueOf(fecha_emision_str) : null;

                String fecha_vencimiento_str = request.getParameter("fecha_vencimiento");
                Date fecha_vencimiento = (fecha_vencimiento_str != null && !fecha_vencimiento_str.isEmpty() && !fecha_vencimiento_str.equals("null")) ? Date.valueOf(fecha_vencimiento_str) : null;

                String idClienteStr = request.getParameter("id_cliente");
                int id_cliente = (idClienteStr != null && !idClienteStr.equals("null")) ? Integer.parseInt(idClienteStr) : 0;

                String metodo_pago = request.getParameter("metodo_pago");
                String descuentoTotalStr = request.getParameter("descuento_total");
                double descuento_total = (descuentoTotalStr != null && !descuentoTotalStr.equals("null")) ? Double.parseDouble(descuentoTotalStr) : 0.0;
                
                String moneda = request.getParameter("moneda");
                String estado_factura = request.getParameter("estado_factura");

                // Subtotal, monto_iva, monto_retencion, total_pagar NO se reciben, se gestionan con la BD o se inicializan.
                // Para el "guardar", se inicializan en 0.0 o se obtienen de los detalles si ya existen.
                // Para el "modificar", se recalculan a partir de los detalles existentes.
                double subtotal = 0.0; // Se recalculará
                double monto_iva = 0.0; // Se recalculará
                double monto_retencion = (request.getParameter("monto_retencion") != null && !request.getParameter("monto_retencion").equals("null")) ? Double.parseDouble(request.getParameter("monto_retencion")) : 0.0;
                double total_pagar = 0.0; // Se recalculará

                // --- Server-side Validation for Factura ---
                if (numero_factura == null || numero_factura.isEmpty() || fecha_emision == null || id_cliente <= 0 || metodo_pago == null || metodo_pago.isEmpty() || moneda == null || moneda.isEmpty() || estado_factura == null || estado_factura.isEmpty()) {
                    out.print("error_validacion: Campos obligatorios de factura incompletos.");
                    return;
                }

                // Check for existing invoice number (for both new and update, excluding self for update)
                String checkExistSql = "SELECT COUNT(*) FROM facturas WHERE LOWER(numero_factura) = LOWER(?)";
                if ("modificar".equals(operationType)) {
                    checkExistSql += " AND id_factura <> ?";
                }
                ps = conn.prepareStatement(checkExistSql);
                ps.setString(1, numero_factura);
                if ("modificar".equals(operationType)) {
                    ps.setInt(2, id_factura);
                }
                rs = ps.executeQuery();
                rs.next();
                if (rs.getInt(1) > 0) {
                    out.print("existe"); // Invoice with this number already exists
                    rs.close();
                    ps.close();
                    return;
                }
                rs.close();
                ps.close();

                conn.setAutoCommit(false); // Iniciar transacción

                if ("guardar".equals(operationType)) {
                    String insertFacturaSql = "INSERT INTO facturas(numero_factura, fecha_emision, fecha_vencimiento, id_cliente, metodo_pago, subtotal, descuento_total, monto_iva, monto_retencion, total_pagar, moneda, estado_factura) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                    ps = conn.prepareStatement(insertFacturaSql, Statement.RETURN_GENERATED_KEYS);
                    ps.setString(1, numero_factura);
                    ps.setDate(2, fecha_emision);
                    ps.setDate(3, fecha_vencimiento);
                    ps.setInt(4, id_cliente);
                    ps.setString(5, metodo_pago);
                    ps.setDouble(6, 0.0); // Inicializar subtotal
                    ps.setDouble(7, descuento_total);
                    ps.setDouble(8, 0.0); // Inicializar monto_iva
                    ps.setDouble(9, monto_retencion);
                    ps.setDouble(10, 0.0); // Inicializar total_pagar
                    ps.setString(11, moneda);
                    ps.setString(12, estado_factura);
                    ps.executeUpdate();

                    rs = ps.getGeneratedKeys();
                    if (rs.next()) {
                        id_factura = rs.getInt(1); // Get the newly generated invoice ID
                    } else {
                        throw new SQLException("No se pudo obtener el ID de la factura insertada.");
                    }
                    rs.close();
                    out.print("exito_guardado:" + id_factura); // Devolver el nuevo ID
                } else if ("modificar".equals(operationType)) {
                    String updateFacturaSql = "UPDATE facturas SET numero_factura=?, fecha_emision=?, fecha_vencimiento=?, id_cliente=?, metodo_pago=?, descuento_total=?, monto_retencion=?, moneda=?, estado_factura=? WHERE id_factura=?";
                    ps = conn.prepareStatement(updateFacturaSql);
                    ps.setString(1, numero_factura);
                    ps.setDate(2, fecha_emision);
                    ps.setDate(3, fecha_vencimiento);
                    ps.setInt(4, id_cliente);
                    ps.setString(5, metodo_pago);
                    ps.setDouble(6, descuento_total);
                    ps.setDouble(7, monto_retencion);
                    ps.setString(8, moneda);
                    ps.setString(9, estado_factura);
                    ps.setInt(10, id_factura);
                    int rowsUpdated = ps.executeUpdate();
                    if (rowsUpdated == 0) {
                        conn.rollback();
                        out.print("no_encontrado");
                        ps.close();
                        return;
                    }
                    out.print("exito_modificado");
                }
                conn.commit(); // Commit al guardar/modificar factura
                ps.close();
                break;

            case "listar":
                st = conn.createStatement();
                String listFacturasSql = "SELECT id_factura, numero_factura, fecha_emision, id_cliente, total_pagar, estado_factura, " +
                                     "fecha_vencimiento, metodo_pago, subtotal, descuento_total, monto_iva, monto_retencion, moneda " +
                                     "FROM facturas ORDER BY fecha_emision DESC;";
                System.out.println("DEBUG SERVER: Executing query for listar: " + listFacturasSql);
                rs = st.executeQuery(listFacturasSql);
                
                // --- INICIO DEPURACIÓN DE COLUMNAS ---
                try {
                    ResultSetMetaData rsmd = rs.getMetaData();
                    int columnCount = rsmd.getColumnCount();
                    System.out.print("DEBUG SERVER: Columns available in ResultSet (listar): ");
                    for (int i = 1; i <= columnCount; i++) {
                        System.out.print(rsmd.getColumnLabel(i) + "(" + rsmd.getColumnName(i) + ")" + (i == columnCount ? "" : ", "));
                    }
                    System.out.println();
                } catch (SQLException e) {
                    System.err.println("DEBUG SERVER: Error getting ResultSetMetaData for listar: " + e.getMessage());
                }
                // --- FIN DEPURACIÓN DE COLUMNAS ---


                while (rs.next()) {
                    // Prepara los valores para pasarlos directamente al onclick, escapando cadenas y formateando números
                    String idFacturaForJs = rs.getString("id_factura");
                    // Asegúrate de que los valores null de la base de datos se manejen como cadenas "null" para JS o valores por defecto
                    String numeroFacturaForJs = URLEncoder.encode(rs.getString("numero_factura") != null ? rs.getString("numero_factura") : "", "UTF-8");
                    String fechaEmisionForJs = URLEncoder.encode(rs.getDate("fecha_emision") != null ? rs.getDate("fecha_emision").toString() : "", "UTF-8");
                    String fechaVencimientoForJs = (rs.getDate("fecha_vencimiento") != null) ? URLEncoder.encode(rs.getDate("fecha_vencimiento").toString(), "UTF-8") : ""; // Use empty string for null
                    String idClienteForJs = rs.getString("id_cliente");
                    String metodoPagoForJs = URLEncoder.encode(rs.getString("metodo_pago") != null ? rs.getString("metodo_pago") : "", "UTF-8");
                    String subtotalForJs = formatDouble(rs.getDouble("subtotal"));
                    String descuentoTotalForJs = formatDouble(rs.getDouble("descuento_total"));
                    String montoIvaForJs = formatDouble(rs.getDouble("monto_iva"));
                    String montoRetencionForJs = formatDouble(rs.getDouble("monto_retencion"));
                    String totalPagarForJs = formatDouble(rs.getDouble("total_pagar"));
                    String monedaForJs = URLEncoder.encode(rs.getString("moneda") != null ? rs.getString("moneda") : "", "UTF-8");
                    String estadoFacturaForJs = URLEncoder.encode(rs.getString("estado_factura") != null ? rs.getString("estado_factura") : "", "UTF-8");
%>
<tr>
    <td class="px-6 py-4 whitespace-nowrap"><%= rs.getString("id_factura") %></td>
    <td class="px-6 py-4 whitespace-nowrap"><%= rs.getString("numero_factura") %></td>
    <td class="px-6 py-4 whitespace-nowrap"><%= rs.getDate("fecha_emision").toString() %></td>
    <td class="px-6 py-4 whitespace-nowrap"><%= rs.getString("id_cliente") %></td>
    <td class="px-6 py-4 whitespace-nowrap"><%= String.format("%.2f", rs.getDouble("total_pagar")) + " " + rs.getString("moneda") %></td>
    <td class="px-6 py-4 whitespace-nowrap"><%= rs.getString("estado_factura") %></td>
    <td class="px-6 py-4 whitespace-nowrap">
        <a style="cursor: pointer" onclick="datosModifFactura('<%= idFacturaForJs %>', '<%= numeroFacturaForJs %>', '<%= fechaEmisionForJs %>', '<%= fechaVencimientoForJs %>', '<%= idClienteForJs %>', '<%= metodoPagoForJs %>', <%= subtotalForJs %>, <%= descuentoTotalForJs %>, <%= montoIvaForJs %>, <%= montoRetencionForJs %>, <%= totalPagarForJs %>, '<%= monedaForJs %>', '<%= estadoFacturaForJs %>')" class="text-blue-600 hover:text-blue-900 mx-1">
            <i class="fas fa-edit"></i>
        </a>
        <a style="cursor: pointer" onclick="confirmarEliminarFactura(<%= rs.getString("id_factura") %>)" class="text-red-600 hover:text-red-900 mx-1">
            <i class="fas fa-trash-alt"></i>
        </a>
    </td>
</tr>
<%
                }
                break;

            case "eliminar":
                String idFacturaEliminarStr = request.getParameter("id_factura");
                if (idFacturaEliminarStr == null || idFacturaEliminarStr.isEmpty()) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("error: ID de factura para eliminar no especificado");
                    return;
                }
                int id_factura_eliminar = Integer.parseInt(idFacturaEliminarStr);

                conn.setAutoCommit(false); // Disable auto-commit

                try {
                    String deleteDetailsSql = "DELETE FROM detalles_factura WHERE id_factura = ?";
                    ps = conn.prepareStatement(deleteDetailsSql);
                    ps.setInt(1, id_factura_eliminar);
                    ps.executeUpdate();
                    ps.close();

                    String deleteFacturaSql = "DELETE FROM facturas WHERE id_factura = ?";
                    ps = conn.prepareStatement(deleteFacturaSql);
                    ps.setInt(1, id_factura_eliminar);
                    int rowsDeleted = ps.executeUpdate();

                    if (rowsDeleted > 0) {
                        conn.commit();
                        out.print("exito");
                    } else {
                        conn.rollback();
                        out.print("no_encontrado");
                    }
                } catch (SQLException e) {
                    conn.rollback();
                    throw e;
                } finally {
                    conn.setAutoCommit(true);
                }
                break;

            // --- Nuevos casos para la gestión de DETALLES individuales ---
            case "listarDetalles":
                String facturaIdParam = request.getParameter("id_factura");
                int facturaIdDetalleListar = 0;
                try {
                    facturaIdDetalleListar = Integer.parseInt(facturaIdParam);
                } catch (NumberFormatException e) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("error_validacion: ID de factura inválido para listar detalles.");
                    return;
                }

                String selectDetallesSql = "SELECT id_detalle, id_factura, descripcion_servicio, tipo_combustible, cantidad, unidad_medida, " +
                                            "precio_unitario, subtotal_item, alicuota_iva, monto_iva_item, " +
                                            "origen_transporte, destino_transporte, numero_guia_remision, patente_vehiculo, nombre_conductor " +
                                            "FROM detalles_factura WHERE id_factura = ?";
                ps = conn.prepareStatement(selectDetallesSql);
                ps.setInt(1, facturaIdDetalleListar);
                rs = ps.executeQuery();
                
                // --- INICIO DEPURACIÓN DE COLUMNAS PARA DETALLES ---
                try {
                    ResultSetMetaData rsmdDetalle = rs.getMetaData();
                    int columnCountDetalle = rsmdDetalle.getColumnCount();
                    System.out.print("DEBUG SERVER: Columns available in ResultSet (listarDetalles): ");
                    for (int i = 1; i <= columnCountDetalle; i++) {
                        System.out.print(rsmdDetalle.getColumnLabel(i) + "(" + rsmdDetalle.getColumnName(i) + ")" + (i == columnCountDetalle ? "" : ", "));
                    }
                    System.out.println();
                } catch (SQLException e) {
                    System.err.println("DEBUG SERVER: Error getting ResultSetMetaData for listarDetalles: " + e.getMessage());
                }
                // --- FIN DEPURACIÓN DE COLUMNAS PARA DETALLES ---


                // Generar HTML directamente para los detalles
                while (rs.next()) {
                    // Escapar y formatear los valores para pasarlos directamente en el onclick
                    String idDetalleForJs = rs.getString("id_detalle");
                    String idFacturaForJs = rs.getString("id_factura"); // Asegúrate que esta columna exista en el RS
                    String descServicioForJs = URLEncoder.encode(rs.getString("descripcion_servicio") != null ? rs.getString("descripcion_servicio") : "", "UTF-8");
                    String tipoCombustibleForJs = URLEncoder.encode(rs.getString("tipo_combustible") != null ? rs.getString("tipo_combustible") : "", "UTF-8");
                    String cantidadForJs = formatDouble(rs.getDouble("cantidad"));
                    String unidadMedidaForJs = URLEncoder.encode(rs.getString("unidad_medida") != null ? rs.getString("unidad_medida") : "", "UTF-8");
                    String precioUnitarioForJs = formatDouble(rs.getDouble("precio_unitario"));
                    String subtotalItemForJs = formatDouble(rs.getDouble("subtotal_item"));
                    String alicuotaIvaForJs = formatDouble(rs.getDouble("alicuota_iva"));
                    String montoIvaItemForJs = formatDouble(rs.getDouble("monto_iva_item"));
                    String origenTransporteForJs = URLEncoder.encode(rs.getString("origen_transporte") != null ? rs.getString("origen_transporte") : "", "UTF-8");
                    String destinoTransporteForJs = URLEncoder.encode(rs.getString("destino_transporte") != null ? rs.getString("destino_transporte") : "", "UTF-8");
                    String numeroGuiaForJs = (rs.getString("numero_guia_remision") != null) ? URLEncoder.encode(rs.getString("numero_guia_remision"), "UTF-8") : "''"; // Usar '' para cadenas vacías
                    String patenteVehiculoForJs = (rs.getString("patente_vehiculo") != null) ? URLEncoder.encode(rs.getString("patente_vehiculo"), "UTF-8") : "''";
                    String nombreConductorForJs = (rs.getString("nombre_conductor") != null) ? URLEncoder.encode(rs.getString("nombre_conductor"), "UTF-8") : "''";
%>
<tr>
    <td class="px-3 py-2 whitespace-nowrap"><%= rs.getString("descripcion_servicio") %></td>
    <td class="px-3 py-2 whitespace-nowrap"><%= String.format("%.3f", rs.getDouble("cantidad")) %> <%= rs.getString("unidad_medida") %></td>
    <td class="px-3 py-2 whitespace-nowrap"><%= String.format("%.2f", rs.getDouble("precio_unitario")) %></td>
    <td class="px-3 py-2 whitespace-nowrap"><%= String.format("%.2f", rs.getDouble("subtotal_item")) %></td>
    <td class="px-3 py-2 whitespace-nowrap"><%= String.format("%.2f", rs.getDouble("monto_iva_item")) %></td>
    <td class="px-3 py-2 whitespace-nowrap">
        <a style="cursor: pointer" onclick="editarDetalleFactura(<%= idDetalleForJs %>, <%= idFacturaForJs %>, '<%= descServicioForJs %>', '<%= tipoCombustibleForJs %>', <%= cantidadForJs %>, '<%= unidadMedidaForJs %>', <%= precioUnitarioForJs %>, <%= subtotalItemForJs %>, <%= alicuotaIvaForJs %>, <%= montoIvaItemForJs %>, '<%= origenTransporteForJs %>', '<%= destinoTransporteForJs %>', '<%= numeroGuiaForJs %>', '<%= patenteVehiculoForJs %>', '<%= nombreConductorForJs %>')" class="text-green-500 hover:text-green-700 mx-1">
            <i class="fas fa-edit"></i>
        </a>
        <a style="cursor: pointer" onclick="removerDetalleFactura(<%= idDetalleForJs %>, <%= idFacturaForJs %>)" class="text-red-500 hover:text-red-700 mx-1">
            <i class="fas fa-trash-alt"></i>
        </a>
    </td>
</tr>
<%
                }
                break;

            case "guardarDetalle":
            case "modificarDetalle":
                // Lógica para guardar/modificar un Detalle individual
                String idFacturaDetalleStr = request.getParameter("id_factura_detalle");
                int id_factura_detalle = (idFacturaDetalleStr != null && !idFacturaDetalleStr.isEmpty()) ? Integer.parseInt(idFacturaDetalleStr) : 0;
                
                String idDetalleStr = request.getParameter("id_detalle");
                int id_detalle = (idDetalleStr != null && !idDetalleStr.isEmpty()) ? Integer.parseInt(idDetalleStr) : 0;

                String descripcion_servicio = request.getParameter("descripcion_servicio");
                String tipo_combustible = request.getParameter("tipo_combustible");
                String cantidadStr = request.getParameter("cantidad");
                double cantidad = (cantidadStr != null && !cantidadStr.isEmpty()) ? Double.parseDouble(cantidadStr) : 0.0;
                String unidad_medida = request.getParameter("unidad_medida");
                String precioUnitarioStr = request.getParameter("precio_unitario");
                double precio_unitario = (precioUnitarioStr != null && !precioUnitarioStr.isEmpty()) ? Double.parseDouble(precioUnitarioStr) : 0.0;
                
                // Recibir subtotal_item y monto_iva_item calculados del frontend
                String subtotalItemStr = request.getParameter("subtotal_item");
                double subtotal_item = (subtotalItemStr != null && !subtotalItemStr.isEmpty()) ? Double.parseDouble(subtotalItemStr) : 0.0;
                String alicuotaIvaStr = request.getParameter("alicuota_iva");
                double alicuota_iva = (alicuotaIvaStr != null && !alicuotaIvaStr.isEmpty()) ? Double.parseDouble(alicuotaIvaStr) : 0.0;
                String montoIvaItemStr = request.getParameter("monto_iva_item");
                double monto_iva_item = (montoIvaItemStr != null && !montoIvaItemStr.isEmpty()) ? Double.parseDouble(montoIvaItemStr) : 0.0;

                String origen_transporte = request.getParameter("origen_transporte");
                String destino_transporte = request.getParameter("destino_transporte");
                String numero_guia_remision = request.getParameter("numero_guia_remision");
                String patente_vehiculo = request.getParameter("patente_vehiculo");
                String nombre_conductor = request.getParameter("nombre_conductor");

                // --- Server-side Validation for Detail ---
                if (id_factura_detalle <= 0 || descripcion_servicio == null || descripcion_servicio.isEmpty() || tipo_combustible == null || tipo_combustible.isEmpty() ||
                    cantidad <= 0 || unidad_medida == null || unidad_medida.isEmpty() ||
                    precio_unitario <= 0 || alicuota_iva < 0 || origen_transporte == null || origen_transporte.isEmpty() ||
                    destino_transporte == null || destino_transporte.isEmpty()) {
                    out.print("error_validacion: Campos obligatorios de detalle incompletos o valores negativos inválidos.");
                    return;
                }

                conn.setAutoCommit(false); // Iniciar transacción para el detalle y la actualización de la factura

                if ("guardarDetalle".equals(operationType)) {
                    String insertDetalleSql = "INSERT INTO detalles_factura(id_factura, descripcion_servicio, tipo_combustible, cantidad, unidad_medida, precio_unitario, subtotal_item, alicuota_iva, monto_iva_item, origen_transporte, destino_transporte, numero_guia_remision, patente_vehiculo, nombre_conductor) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                    ps = conn.prepareStatement(insertDetalleSql);
                    ps.setInt(1, id_factura_detalle);
                    ps.setString(2, descripcion_servicio);
                    ps.setString(3, tipo_combustible);
                    ps.setDouble(4, cantidad);
                    ps.setString(5, unidad_medida);
                    ps.setDouble(6, precio_unitario);
                    ps.setDouble(7, subtotal_item);
                    ps.setDouble(8, alicuota_iva);
                    ps.setDouble(9, monto_iva_item);
                    ps.setString(10, origen_transporte);
                    ps.setString(11, destino_transporte);
                    ps.setString(12, numero_guia_remision != null && !numero_guia_remision.isEmpty() ? numero_guia_remision : null);
                    ps.setString(13, patente_vehiculo != null && !patente_vehiculo.isEmpty() ? patente_vehiculo : null);
                    ps.setString(14, nombre_conductor != null && !nombre_conductor.isEmpty() ? nombre_conductor : null);
                    ps.executeUpdate();
                    out.print("exito");

                } else if ("modificarDetalle".equals(operationType)) {
                    if (id_detalle <= 0) {
                        out.print("error_validacion: ID de detalle no especificado para modificar.");
                        conn.rollback();
                        return;
                    }
                    String updateDetalleSql = "UPDATE detalles_factura SET descripcion_servicio=?, tipo_combustible=?, cantidad=?, unidad_medida=?, precio_unitario=?, subtotal_item=?, alicuota_iva=?, monto_iva_item=?, origen_transporte=?, destino_transporte=?, numero_guia_remision=?, patente_vehiculo=?, nombre_conductor=? WHERE id_detalle=? AND id_factura=?";
                    ps = conn.prepareStatement(updateDetalleSql);
                    ps.setString(1, descripcion_servicio);
                    ps.setString(2, tipo_combustible);
                    ps.setDouble(3, cantidad);
                    ps.setString(4, unidad_medida);
                    ps.setDouble(5, precio_unitario);
                    ps.setDouble(6, subtotal_item);
                    ps.setDouble(7, alicuota_iva);
                    ps.setDouble(8, monto_iva_item);
                    ps.setString(9, origen_transporte);
                    ps.setString(10, destino_transporte);
                    ps.setString(11, numero_guia_remision != null && !numero_guia_remision.isEmpty() ? numero_guia_remision : null);
                    ps.setString(12, patente_vehiculo != null && !patente_vehiculo.isEmpty() ? patente_vehiculo : null);
                    ps.setString(13, nombre_conductor != null && !nombre_conductor.isEmpty() ? nombre_conductor : null);
                    ps.setInt(14, id_detalle);
                    ps.setInt(15, id_factura_detalle);
                    int rowsUpdated = ps.executeUpdate();
                    if (rowsUpdated == 0) {
                        conn.rollback();
                        out.print("no_encontrado");
                        ps.close();
                        return;
                    }
                    out.print("exito");
                }
                ps.close();
                // RECALCULAR TOTALES DE LA FACTURA PRINCIPAL DESPUÉS DE CADA OPERACIÓN DE DETALLE
                recalcularTotalesFactura(id_factura_detalle, conn);
                conn.commit(); // Commit el detalle y la actualización de la factura
                break;

            case "eliminarDetalle":
                String idDetalleEliminarStr = request.getParameter("id_detalle");
                String idFacturaPadreStr = request.getParameter("id_factura"); // Necesario para recalcular totales
                
                if (idDetalleEliminarStr == null || idDetalleEliminarStr.isEmpty() || idFacturaPadreStr == null || idFacturaPadreStr.isEmpty()) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("error: ID de detalle o ID de factura no especificado para eliminar.");
                    return;
                }
                int id_detalle_eliminar = Integer.parseInt(idDetalleEliminarStr);
                int id_factura_padre = Integer.parseInt(idFacturaPadreStr);

                conn.setAutoCommit(false); // Iniciar transacción

                try {
                    String deleteDetalleSql = "DELETE FROM detalles_factura WHERE id_detalle = ?";
                    ps = conn.prepareStatement(deleteDetalleSql);
                    ps.setInt(1, id_detalle_eliminar);
                    int rowsDeleted = ps.executeUpdate();

                    if (rowsDeleted > 0) {
                        // RECALCULAR TOTALES DE LA FACTURA PRINCIPAL DESPUÉS DE ELIMINAR UN DETALLE
                        recalcularTotalesFactura(id_factura_padre, conn);
                        conn.commit();
                        out.print("exito");
                    } else {
                        conn.rollback();
                        out.print("no_encontrado");
                    }
                } catch (SQLException e) {
                    conn.rollback();
                    throw e;
                } finally {
                    conn.setAutoCommit(true);
                }
                break;

            default:
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("error: tipo de operación no reconocido");
                break;
        }
    } catch (NumberFormatException e) {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        out.print("error: formato de ID o número inválido. Detalles: " + e.getMessage());
        e.printStackTrace();
    } catch (SQLException e) {
        e.printStackTrace();
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        out.print("error_bd: " + e.getMessage());
    } catch (Exception e) {
        e.printStackTrace();
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        out.print("error_inesperado: " + e.getMessage());
    } finally {
        // Asegúrate de cerrar los recursos incluso si hay una excepción
        if (rs != null) try { rs.close(); } catch (SQLException e) { System.err.println("Error closing ResultSet: " + e.getMessage()); }
        if (st != null) try { st.close(); } catch (SQLException e) { System.err.println("Error closing Statement: " + e.getMessage()); }
        if (ps != null) try { ps.close(); } catch (SQLException e) { System.err.println("Error closing PreparedStatement: " + e.getMessage()); }
        if (conn != null) try { conn.close(); } catch (SQLException e) { System.err.println("Error closing Connection: " + e.getMessage()); }
    }
%>