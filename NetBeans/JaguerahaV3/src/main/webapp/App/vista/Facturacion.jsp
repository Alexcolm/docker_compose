<!doctype html>
<html lang="en">
    <%@ include file="header.jsp" %>
    <div class="app-content-header">
    <div class="container-fluid">
        <div class="row">
            <div class="col-sm-6"><h3 class="mb-0">Gestión de Facturas</h3></div>
            <div class="col-sm-6">
                <!-- Espacio para posibles elementos adicionales en el encabezado -->
            </div>
        </div>
    </div>
</div>
<div class="app-content">
    <!-- Importación de CSS de Bootstrap para modales y clases auxiliares.
         Es importante incluirlos aquí ya que este JSP se carga dinámicamente. -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <!-- CDN de Tailwind CSS para estilos personalizados. -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Font Awesome para íconos. -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

    <!-- Librerías de JavaScript para Bootstrap, necesarias para el funcionamiento de los modales.
         Deben estar después de jQuery (que se carga en header.jsp) y antes de tu script personalizado. -->
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.3/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>

    <!-- Estilos CSS personalizados para complementar AdminLTE y Bootstrap. -->
    <style>
        /* Estilos generales para modales y botones para asegurar consistencia visual. */
        .modal-content {
            border-radius: 0.75rem; /* Bordes redondeados */
        }
        /* Color personalizado para los encabezados de los modales */
        .modal-header-custom-color {
            background-color: #0EA57B; /* El color deseado */
            color: white;
            border-top-left-radius: 0.75rem;
            border-top-right-radius: 0.75rem;
        }
        .btn {
            padding: 0.75rem 1.5rem;
            border-radius: 0.5rem; /* Bordes redondeados */
            font-weight: 600;
            transition: all 0.2s ease-in-out; /* Transición suave para hover */
        }
        /* Color personalizado para botones primarios y de éxito */
        .btn-primary, .btn-success {
            background-color: #0EA57B; /* El color deseado */
            color: white;
            border: none;
        }
        .btn-primary:hover, .btn-success:hover {
            background-color: #0c8a66; /* Un tono más oscuro para el hover */
        }
        .btn-danger {
            background-color: #ef4444; /* Color rojo */
            color: white;
            border: none;
        }
        .btn-danger:hover {
            background-color: #dc2626;
        }
        .btn-secondary {
            background-color: #6b7280; /* Color gris */
            color: white;
            border: none;
        }
        .btn-secondary:hover {
            background-color: #4b5563;
        }
        /* Estilos para la tabla personalizada */
        .table-custom {
            width: 100%;
            border-collapse: collapse; /* Elimina el espacio entre las celdas del borde */
        }
        .table-custom th, .table-custom td {
            padding: 0.75rem;
            text-align: left;
            border-bottom: 1px solid #e5e7eb; /* Borde inferior ligero */
        }
        .table-custom thead th {
            background-color: #f9fafb; /* Fondo gris claro para el encabezado */
            font-weight: 700;
            text-transform: uppercase;
            font-size: 0.875rem;
            color: #4b5563;
        }
        .table-custom tbody tr:nth-child(even) {
            background-color: #f9fafb; /* Fondo rayado para filas pares */
        }
        .table-custom tbody tr:hover {
            background-color: #eef2ff; /* Resaltado al pasar el mouse */
        }
        /* Estilos para el modal de mensaje/alerta personalizado */
        #customMessageModal .modal-content {
            border-radius: 0.75rem;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        /* El header de customMessageModal ya usa .modal-header-custom-color */
        #customMessageModal .modal-body {
            padding: 2rem;
            text-align: center;
            font-size: 1.125rem;
            color: #374151;
        }
        #customMessageModal .modal-footer {
            justify-content: center;
            border-top: none;
            padding-bottom: 1.5rem;
        }
    </style>

    <div class="container mx-auto bg-white shadow-xl rounded-lg p-8 mt-5">
        <div class="flex justify-center mb-6">
            <button type="button" class="btn btn-success" data-toggle="modal" data-target="#facturaModal" onclick="nuevaFactura()">
                <i class="fas fa-plus-circle mr-2"></i>Agregar Factura
            </button>
        </div>

        <div class="overflow-x-auto">
            <table class="table-custom min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                    <tr>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Número Factura</th>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Fecha Emisión</th>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Cliente ID</th>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Total a Pagar</th>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Estado</th>
                        <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Acciones</th>
                    </tr>
                </thead>
                <tbody id="listaFacturas" class="bg-white divide-y divide-gray-200">
                    <!-- Las facturas se cargarán aquí mediante JavaScript -->
                </tbody >
            </table>
        </div>

        <!-- Modal Principal de Factura (Agregar/Modificar) -->
        <div class="modal fade" id="facturaModal" tabindex="-1" aria-labelledby="facturaModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-xl"> <!-- Tamaño extra grande para acomodar los detalles -->
                <div class="modal-content">
                    <div class="modal-header modal-header-custom-color p-4 rounded-t-lg">
                        <h5 class="modal-title text-xl font-semibold" id="facturaModalLabel">Agregar/Modificar Factura</h5>
                        <button type="button" class="close text-white" data-dismiss="modal" aria-label="Cerrar">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body p-6">
                        <form id="facturaForm" name="facturaForm" class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <input type="hidden" name="campo" id="campoFactura" value="guardar">
                            <input type="hidden" name="id_factura" id="idFactura" value="">

                            <!-- Campos de la tabla 'facturas' -->
                            <div class="col-span-1">
                                <label for="numero_factura" class="block text-sm font-medium text-gray-700">Número de Factura</label>
                                <input type="text" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50 p-2" name="numero_factura" id="numero_factura" required>
                            </div>
                            <div class="col-span-1">
                                <label for="fecha_emision" class="block text-sm font-medium text-gray-700">Fecha de Emisión</label>
                                <input type="date" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50 p-2" name="fecha_emision" id="fecha_emision" required>
                            </div>
                            <div class="col-span-1">
                                <label for="fecha_vencimiento" class="block text-sm font-medium text-gray-700">Fecha de Vencimiento</label>
                                <input type="date" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50 p-2" name="fecha_vencimiento" id="fecha_vencimiento">
                            </div>
                            <div class="col-span-1">
                                <label for="id_cliente" class="block text-sm font-medium text-gray-700">ID Cliente</label>
                                <input type="number" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50 p-2" name="id_cliente" id="id_cliente" required>
                            </div>
                            <div class="col-span-1">
                                <label for="metodo_pago" class="block text-sm font-medium text-gray-700">Método de Pago</label>
                                <select class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50 p-2" name="metodo_pago" id="metodo_pago" required>
                                    <option value="Efectivo">Efectivo</option>
                                    <option value="Tarjeta">Tarjeta</option>
                                    <option value="Transferencia">Transferencia</option>
                                    <option value="Cheque">Cheque</option>
                                </select>
                            </div>
                            <div class="col-span-1">
                                <label for="moneda" class="block text-sm font-medium text-gray-700">Moneda</label>
                                <select class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50 p-2" name="moneda" id="moneda" required>
                                    <option value="USD">USD</option>
                                    <option value="EUR">EUR</option>
                                    <option value="PYG">PYG</option>
                                </select>
                            </div>
                            <div class="col-span-1">
                                <label for="estado_factura" class="block text-sm font-medium text-gray-700">Estado de Factura</label>
                                <select class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50 p-2" name="estado_factura" id="estado_factura" required>
                                    <option value="Pendiente">Pendiente</option>
                                    <option value="Pagada">Pagada</option>
                                    <option value="Anulada">Anulada</option>
                                    <option value="Vencida">Vencida</option>
                                </select>
                            </div>
                            <div class="col-span-1">
                                <label for="descuento_total" class="block text-sm font-medium text-gray-700">Descuento Total</label>
                                <input type="number" step="0.01" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50 p-2" name="descuento_total" id="descuento_total" value="0.00">
                            </div>
                            <!-- Campos de totalización (se calculan dinámicamente) -->
                            <div class="col-span-1">
                                <label for="subtotal" class="block text-sm font-medium text-gray-700">Subtotal</label>
                                <input type="number" step="0.01" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50 p-2 bg-gray-100" name="subtotal" id="subtotal" readonly>
                            </div>
                            <div class="col-span-1">
                                <label for="monto_iva" class="block text-sm font-medium text-gray-700">Monto IVA</label>
                                <input type="number" step="0.01" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50 p-2 bg-gray-100" name="monto_iva" id="monto_iva" readonly>
                            </div>
                            <div class="col-span-1">
                                <label for="monto_retencion" class="block text-sm font-medium text-gray-700">Monto Retención</label>
                                <input type="number" step="0.01" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50 p-2 bg-gray-100" name="monto_retencion" id="monto_retencion" value="0.00" readonly>
                            </div>
                            <div class="col-span-1">
                                <label for="total_pagar" class="block text-sm font-medium text-gray-700">Total a Pagar</label>
                                <input type="number" step="0.01" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50 p-2 bg-gray-100" name="total_pagar" id="total_pagar" readonly>
                            </div>

                            <!-- Sección de Detalles de Factura -->
                            <div class="col-span-2 mt-6 border-t pt-6 border-gray-200">
                                <h6 class="text-lg font-semibold text-gray-800 mb-4">Detalles de Factura</h6>
                                <button type="button" class="btn btn-primary mb-4" onclick="agregarDetalleFactura()">
                                    <i class="fas fa-plus-circle mr-2"></i>Agregar Detalle
                                </button>

                                <div class="overflow-x-auto">
                                    <table class="table-custom min-w-full divide-y divide-gray-200" id="tablaDetallesFactura">
                                        <thead>
                                            <tr>
                                                <th class="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Descripción</th>
                                                <th class="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Cantidad</th>
                                                <th class="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Precio Unitario</th>
                                                <th class="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Subtotal Item</th>
                                                <th class="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">IVA Item</th>
                                                <th class="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Acciones</th>
                                            </tr>
                                        </thead>
                                        <tbody id="listaDetallesFactura">
                                            <!-- Los detalles se agregarán aquí dinámicamente (server-side rendering) -->
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                            <div class="modal-footer col-span-2 flex justify-end gap-3 mt-6 border-t pt-4">
                                <button type="button" id="cerrarFacturaModal" class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
                                <button type="button" class="btn btn-primary" id="guardarFacturaBtn">Guardar Factura</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <!-- Modal de Detalle de Factura (para agregar/modificar un detalle individual) -->
        <div class="modal fade" id="detalleFacturaModal" tabindex="-1" aria-labelledby="detalleFacturaModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header modal-header-custom-color p-4 rounded-t-lg">
                        <h5 class="modal-title text-xl font-semibold" id="detalleFacturaModalLabel">Agregar/Modificar Detalle</h5>
                        <button type="button" class="close text-white" data-dismiss="modal" aria-label="Cerrar">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body p-6">
                        <form id="detalleForm" name="detalleForm">
                            <input type="hidden" name="campoDetalle" id="campoDetalle" value="guardarDetalle">
                            <input type="hidden" name="id_factura_detalle" id="idFacturaDetalle" value=""> <!-- ID de la factura a la que pertenece el detalle -->
                            <input type="hidden" name="id_detalle" id="idDetalle" value=""> <!-- ID del detalle si es una modificación -->

                            <div class="mb-4">
                                <label for="descripcion_servicio" class="block text-sm font-medium text-gray-700">Descripción del Servicio</label>
                                <input type="text" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm p-2" name="descripcion_servicio" id="descripcion_servicio" required>
                            </div>
                            <div class="mb-4">
                                <label for="tipo_combustible" class="block text-sm font-medium text-gray-700">Tipo de Combustible</label>
                                <input type="text" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm p-2" name="tipo_combustible" id="tipo_combustible" required>
                            </div>
                            <div class="mb-4">
                                <label for="cantidad" class="block text-sm font-medium text-gray-700">Cantidad</label>
                                <input type="number" step="0.001" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm p-2" name="cantidad" id="cantidad" required>
                            </div>
                            <div class="mb-4">
                                <label for="unidad_medida" class="block text-sm font-medium text-gray-700">Unidad de Medida</label>
                                <input type="text" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm p-2" name="unidad_medida" id="unidad_medida" required>
                            </div>
                            <div class="mb-4">
                                <label for="precio_unitario" class="block text-sm font-medium text-gray-700">Precio Unitario</label>
                                <input type="number" step="0.01" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm p-2" name="precio_unitario" id="precio_unitario" required>
                            </div>
                             <div class="mb-4">
                                <label for="alicuota_iva" class="block text-sm font-medium text-gray-700">Alícuota IVA (%)</label>
                                <input type="number" step="0.01" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm p-2" name="alicuota_iva" id="alicuota_iva" required>
                            </div>
                            <div class="mb-4">
                                <label for="origen_transporte" class="block text-sm font-medium text-gray-700">Origen Transporte</label>
                                <input type="text" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm p-2" name="origen_transporte" id="origen_transporte" required>
                            </div>
                            <div class="mb-4">
                                <label for="destino_transporte" class="block text-sm font-medium text-gray-700">Destino Transporte</label>
                                <input type="text" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm p-2" name="destino_transporte" id="destino_transporte" required>
                            </div>
                            <div class="mb-4">
                                <label for="numero_guia_remision" class="block text-sm font-medium text-gray-700">Número Guía Remisión</label>
                                <input type="text" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm p-2" name="numero_guia_remision" id="numero_guia_remision">
                            </div>
                            <div class="mb-4">
                                <label for="patente_vehiculo" class="block text-sm font-medium text-gray-700">Patente Vehículo</label>
                                <input type="text" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm p-2" name="patente_vehiculo" id="patente_vehiculo">
                            </div>
                            <div class="mb-4">
                                <label for="nombre_conductor" class="block text-sm font-medium text-gray-700">Nombre Conductor</label>
                                <input type="text" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm p-2" name="nombre_conductor" id="nombre_conductor">
                            </div>

                            <div class="modal-footer flex justify-end gap-3 mt-6 border-t pt-4">
                                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                                <button type="button" class="btn btn-primary" id="guardarDetalleBtn">Guardar Detalle</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <!-- Modal de Mensaje Personalizado (para alertas) -->
        <div class="modal fade" id="customMessageModal" tabindex="-1" aria-labelledby="customMessageModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-sm">
                <div class="modal-content">
                    <div class="modal-header modal-header-custom-color">
                        <h5 class="modal-title" id="customMessageModalLabel">Mensaje</h5>
                        <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body" id="customMessageModalBody">
                        <!-- El mensaje se insertará aquí -->
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-primary" data-dismiss="modal">Aceptar</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Modal de Confirmación de Eliminación -->
        <div class="modal fade" id="confirmarEliminarModal" tabindex="-1" aria-labelledby="confirmarEliminarModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header bg-red-600 text-white p-4 rounded-t-lg">
                        <h5 class="modal-title text-xl font-semibold" id="confirmarEliminarModalLabel">Confirmar Eliminación</h5>
                        <button type="button" class="close text-white" data-dismiss="modal" aria-label="Cerrar">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body p-6">
                        ¿Estás seguro de que deseas eliminar esta Factura? Esta acción es irreversible y eliminará todos sus detalles asociados.
                    </div>
                    <div class="modal-footer flex justify-end gap-3 mt-6 border-t pt-4">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                        <button type="button" class="btn btn-danger" id="confirmarEliminarFacturaBtn">Eliminar</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Script de JavaScript para la lógica de facturación -->
    <script>
        let idFacturaAEliminar = null; // Variable para almacenar el ID de la factura a eliminar
        let currentFacturaId = null; // Para guardar el ID de la factura actual en edición

        $(document).ready(function () {
            rellenarFacturas(); // Carga las facturas al iniciar la página

            // Evento para cerrar el modal principal de factura
            $("#cerrarFacturaModal").click(function() {
                nuevaFactura(); // Reinicia el formulario al cerrar el modal
                $('#facturaModal').modal('hide');
            });

            // Evento para guardar la factura principal
            $("#guardarFacturaBtn").click(function () {
                guardarFactura();
            });

            // Evento para guardar un detalle desde el modal de detalle
            $("#guardarDetalleBtn").click(function () {
                guardarDetalle();
            });

            // Evento para confirmar la eliminación de una factura
            $("#confirmarEliminarFacturaBtn").click(function () {
                if (idFacturaAEliminar !== null) {
                    eliminarFactura(idFacturaAEliminar);
                }
            });

            // Recalcular el subtotal del item y el IVA del item cuando cambian cantidad, precio o alícuota en el modal de detalle
            // Nota: Estos campos ahora están en el modal de detalle.
            $('#cantidad, #precio_unitario, #alicuota_iva').on('input', function() {
                calcularSubtotalItem();
            });

            // --- Solución al problema de modal pegado para modales anidados ---
            $('#detalleFacturaModal').on('hidden.bs.modal', function (e) {
                if ($('#facturaModal').hasClass('show')) {
                    $('body').addClass('modal-open');
                }
            });
            $('#customMessageModal').on('hidden.bs.modal', function (e) {
                if ($('#facturaModal').hasClass('show')) {
                    $('body').addClass('modal-open');
                }
            });
            $('#facturaModal').on('shown.bs.modal', function (e) {
                if (!$('body').hasClass('modal-open')) {
                    $('body').addClass('modal-open');
                }
            });
            $('#facturaModal').on('hidden.bs.modal', function (e) {
                $('body').removeClass('modal-open');
            });
        });

        // Función para calcular el subtotal_item y monto_iva_item en el modal de detalle
        // Estos valores se calcularán en el frontend pero se enviarán al backend para su almacenamiento.
        function calcularSubtotalItem() {
            const cantidad = parseFloat($('#cantidad').val()) || 0;
            const precioUnitario = parseFloat($('#precio_unitario').val()) || 0;
            const alicuotaIva = parseFloat($('#alicuota_iva').val()) || 0;

            const subtotalItem = (cantidad * precioUnitario);
            const montoIvaItem = (subtotalItem * (alicuotaIva / 100));

            // No se actualizan inputs directamente en el modal de detalle, solo se calculan.
            // Los campos "subtotal_item" y "monto_iva_item" serán enviados como parte del formulario serializado.
        }

        // Función para recalcular los totales de la factura principal
        // Esta función ahora tendrá que obtener los detalles guardados en DB para recalcular
        // Esto requeriría otra llamada al servidor o que el servidor recalcule al guardar.
        // Por simplicidad y semejanza al código de ciudades, los totales se recalcularán en el backend.
        // Aquí solo se inicializan o se cargan los valores preexistentes.
        function calcularTotalesFactura() {
            // Con el nuevo enfoque, los totales (subtotal, iva, total) serán gestionados y recalculados por el backend
            // cuando se guarda la factura principal o un detalle.
            // Por ahora, esta función puede permanecer vacía o solo actualizar los valores mostrados si ya existen.
            // Para mantener la consistencia, el backend es quien retornará los totales actualizados en la respuesta de guardar factura.
        }


        // --- Funciones de Factura (Maestro) ---

        // Obtiene y muestra todas las facturas en la tabla principal
        function rellenarFacturas() {
            $.get("../controles/Control_facturacion.jsp", {campo: 'listar'}, function (data) {
                $("#listaFacturas").html(data);
            }).fail(function(jqXHR, textStatus, errorThrown) {
                console.error("Error al listar facturas:", textStatus, errorThrown, jqXHR.responseText);
                showCustomAlert("Error al cargar las facturas. Consulte la consola para más detalles.");
            });
        }

        // Reinicia el formulario de factura para una nueva entrada
        function nuevaFactura() {
            $("#facturaForm")[0].reset();
            $("#campoFactura").val("guardar");
            $("#idFactura").val("");
            currentFacturaId = null; // Reset el ID de la factura actual
            $('#listaDetallesFactura').html('<tr><td colspan="6" class="text-center text-gray-500 py-4">Guarde la factura para agregar detalles.</td></tr>');
            $('#facturaModalLabel').text('Agregar Factura'); // Actualiza el título del modal
            $('#descuento_total').val('0.00'); // Asegura valores predeterminados
            $('#monto_retencion').val('0.00'); // Asegura valores predeterminados
            $('#subtotal').val('0.00');
            $('#monto_iva').val('0.00');
            $('#total_pagar').val('0.00');

            // Deshabilitar botón de agregar detalles para nuevas facturas hasta que se guarden
            $("#facturaModal button[onclick='agregarDetalleFactura()']").prop('disabled', true).text('Guardar Factura para agregar detalles');
        }

        // Rellena el formulario de factura para edición y carga sus detalles
        function datosModifFactura(idFactura, numeroFactura, fechaEmision, fechaVencimiento, idCliente, metodoPago, subtotal, descuentoTotal, montoIva, montoRetencion, totalPagar, moneda, estadoFactura) {
            $("#idFactura").val(idFactura);
            $("#numero_factura").val(numeroFactura);
            $("#fecha_emision").val(fechaEmision);
            $("#fecha_vencimiento").val(fechaVencimiento);
            $("#id_cliente").val(idCliente);
            $("#metodo_pago").val(metodoPago);
            $("#descuento_total").val(descuentoTotal.toFixed(2));
            $("#moneda").val(moneda);
            $("#estado_factura").val(estadoFactura);

            $("#subtotal").val(subtotal.toFixed(2));
            $("#monto_iva").val(montoIva.toFixed(2));
            $("#monto_retencion").val(montoRetencion.toFixed(2));
            $("#total_pagar").val(totalPagar.toFixed(2));

            $("#campoFactura").val("modificar");
            $('#facturaModalLabel').text('Modificar Factura'); // Actualiza el título del modal
            currentFacturaId = idFactura; // Guarda el ID de la factura que se está editando

            // Habilitar botón de agregar detalles
            $("#facturaModal button[onclick='agregarDetalleFactura()']").prop('disabled', false).text('Agregar Detalle');

            // Cargar los detalles de la factura seleccionada
            rellenarDetallesFactura(idFactura);

            $('#facturaModal').modal('show');
        }

        // Maneja el guardado/actualización de una factura principal
        function guardarFactura() {
            const id_factura = $("#idFactura").val();
            const operation = $("#campoFactura").val(); // "guardar" o "modificar"

            // Serializar el formulario de factura
            let formData = $("#facturaForm").serialize();
            formData += "&campo=" + operation; // Añadir el campo de operación explícitamente

            $.ajax({
                url: '../controles/Control_facturacion.jsp',
                type: 'POST',
                data: formData, // Enviar datos del formulario serializados
                success: function (response) {
                    const trimmedResponse = response.trim();
                    if (trimmedResponse.startsWith("exito_guardado:")) {
                        const newFacturaId = trimmedResponse.split(":")[1]; // Extraer el nuevo ID de factura
                        $("#idFactura").val(newFacturaId); // Actualizar el ID en el formulario
                        currentFacturaId = newFacturaId; // Actualizar el ID de la factura actual
                        $("#campoFactura").val("modificar"); // Cambiar a modo modificar
                        showCustomAlert("Factura guardada exitosamente. Ahora puede agregar detalles.");
                        rellenarFacturas(); // Recargar la tabla principal
                        
                        // Habilitar botón de agregar detalles
                        $("#facturaModal button[onclick='agregarDetalleFactura()']").prop('disabled', false).text('Agregar Detalle');
                        rellenarDetallesFactura(newFacturaId); // Recargar detalles (que estará vacío inicialmente)

                    } else if (trimmedResponse === "exito_modificado") {
                        showCustomAlert("Factura modificada exitosamente.");
                        rellenarFacturas(); // Recargar la tabla principal
                        rellenarDetallesFactura(currentFacturaId); // Recargar detalles con los totales actualizados
                    } else if (trimmedResponse === "existe") {
                        showCustomAlert("Error: Ya existe una factura con ese número.");
                    } else if (trimmedResponse.startsWith("error_validacion")) {
                        showCustomAlert("Error de validación: " + trimmedResponse.substring(trimmedResponse.indexOf(":") + 1));
                    } else {
                        showCustomAlert("Respuesta inesperada del servidor: " + trimmedResponse);
                        console.log("Respuesta completa del servidor:", response);
                    }
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    console.error("Error de comunicación con el servidor:", textStatus, errorThrown, jqXHR.responseText);
                    showCustomAlert("Ocurrió un error al intentar guardar la factura. Por favor, intente de nuevo.");
                }
            });
        }

        // Inicia el proceso de eliminación de una factura
        function confirmarEliminarFactura(id) {
            idFacturaAEliminar = id;
            $('#confirmarEliminarModal').modal('show');
        }

        // Realiza la eliminación real de una factura
        function eliminarFactura(id) {
            $.ajax({
                url: '../controles/Control_facturacion.jsp',
                type: 'GET',
                data: {campo: 'eliminar', id_factura: id},
                success: function (response) {
                    const trimmedResponse = response.trim();
                    if (trimmedResponse === "exito") {
                        $('#confirmarEliminarModal').modal('hide');
                        rellenarFacturas();
                        idFacturaAEliminar = null;
                        showCustomAlert("Factura eliminada exitosamente.");
                    } else if (trimmedResponse === "no_encontrado") {
                        showCustomAlert("Error: La factura no fue encontrada.");
                    } else {
                        showCustomAlert("Respuesta inesperada al eliminar: " + trimmedResponse);
                    }
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    console.error("Error de comunicación al eliminar:", textStatus, errorThrown, jqXHR.responseText);
                    showCustomAlert('Error de comunicación al eliminar la factura.');
                }
            });
        }

        // --- Funciones de Detalle de Factura (Detalle) ---

        // Rellena la tabla de detalles con HTML generado por el servidor
        function rellenarDetallesFactura(idFactura) {
            // Asegúrate de que el currentFacturaId esté establecido para cargar detalles
            if (idFactura === null || idFactura === undefined || idFactura <= 0) {
                $('#listaDetallesFactura').html('<tr><td colspan="6" class="text-center text-gray-500 py-4">Guarde la factura para agregar detalles.</td></tr>');
                return;
            }

            $.get("../controles/Control_facturacion.jsp", {campo: 'listarDetalles', id_factura: idFactura}, function (data) {
                $("#listaDetallesFactura").html(data);
            }).fail(function(jqXHR, textStatus, errorThrown) {
                console.error("Error al listar detalles:", textStatus, errorThrown, jqXHR.responseText);
                showCustomAlert("Error al cargar los detalles de la factura. Consulte la consola.");
                $('#listaDetallesFactura').html('<tr><td colspan="6" class="text-center text-red-500 py-4">Error al cargar detalles.</td></tr>');
            });
        }

        // Abre el modal de detalle para agregar un nuevo detalle
        function agregarDetalleFactura() {
            if (currentFacturaId === null || currentFacturaId <= 0) {
                showCustomAlert("Por favor, guarde la factura principal antes de agregar detalles.");
                return;
            }
            $("#detalleForm")[0].reset();
            $("#campoDetalle").val("guardarDetalle"); // Indica que es un nuevo detalle
            $("#idFacturaDetalle").val(currentFacturaId); // Asigna el ID de la factura actual
            $("#idDetalle").val(""); // Limpia el ID del detalle
            $('#detalleFacturaModalLabel').text('Agregar Nuevo Detalle');
            $('#alicuota_iva').val('10.00'); // Ejemplo de valor predeterminado
            $('#detalleFacturaModal').modal('show');
        }

        // Abre el modal de detalle para editar un detalle existente
        function editarDetalleFactura(idDetalle, idFactura, descripcionServicio, tipoCombustible, cantidad, unidadMedida, precioUnitario, subtotalItem, alicuotaIva, montoIvaItem, origenTransporte, destinoTransporte, numeroGuiaRemision, patenteVehiculo, nombreConductor) {
            $("#campoDetalle").val("modificarDetalle");
            $("#idFacturaDetalle").val(idFactura); // Asigna el ID de la factura padre
            $("#idDetalle").val(idDetalle); // Asigna el ID del detalle a modificar
            $("#descripcion_servicio").val(descripcionServicio);
            $("#tipo_combustible").val(tipoCombustible);
            $("#cantidad").val(cantidad);
            $("#unidad_medida").val(unidadMedida);
            $("#precio_unitario").val(precioUnitario);
            $("#alicuota_iva").val(alicuotaIva);
            $("#origen_transporte").val(origenTransporte);
            $("#destino_transporte").val(destinoTransporte);
            $("#numero_guia_remision").val(numeroGuiaRemision);
            $("#patente_vehiculo").val(patenteVehiculo);
            $("#nombre_conductor").val(nombreConductor);

            $('#detalleFacturaModalLabel').text('Modificar Detalle');
            $('#detalleFacturaModal').modal('show');
        }

        // Guarda un detalle (nuevo o editado)
        function guardarDetalle() {
            const idFacturaDetalle = $("#idFacturaDetalle").val();
            if (idFacturaDetalle === null || idFacturaDetalle <= 0) {
                showCustomAlert("Error: La factura principal no está guardada. Guarde la factura primero.");
                return;
            }

            // Calcular subtotal_item y monto_iva_item antes de serializar
            const cantidad = parseFloat($("#cantidad").val()) || 0;
            const precioUnitario = parseFloat($("#precio_unitario").val()) || 0;
            const alicuotaIva = parseFloat($("#alicuota_iva").val()) || 0;
            const subtotalItem = (cantidad * precioUnitario);
            const montoIvaItem = (subtotalItem * (alicuotaIva / 100));

            // Validación básica para los campos del detalle (frontend)
            const descripcion_servicio = $("#descripcion_servicio").val().trim();
            const tipo_combustible = $("#tipo_combustible").val().trim();
            const unidad_medida = $("#unidad_medida").val().trim();
            const origen_transporte = $("#origen_transporte").val().trim();
            const destino_transporte = $("#destino_transporte").val().trim();

            if (!descripcion_servicio || !tipo_combustible || isNaN(cantidad) || !unidad_medida || isNaN(precioUnitario) || isNaN(alicuotaIva) || !origen_transporte || !destino_transporte) {
                showCustomAlert("Por favor, complete todos los campos obligatorios del detalle.");
                return;
            }
            if (cantidad <= 0 || precioUnitario <= 0 || alicuotaIva < 0) {
                showCustomAlert("Cantidad y Precio Unitario deben ser mayores que cero. La Alícuota IVA no puede ser negativa.");
                return;
            }

            let formData = $("#detalleForm").serialize();
            formData += "&subtotal_item=" + subtotalItem.toFixed(2);
            formData += "&monto_iva_item=" + montoIvaItem.toFixed(2);

            $.ajax({
                url: '../controles/Control_facturacion.jsp',
                type: 'POST',
                data: formData, // Enviar datos del formulario serializados
                success: function (response) {
                    const trimmedResponse = response.trim();
                    if (trimmedResponse === "exito") {
                        $('#detalleFacturaModal').modal('hide');
                        rellenarDetallesFactura(idFacturaDetalle); // Recargar la tabla de detalles
                        rellenarFacturas(); // Recargar la tabla principal para actualizar totales
                        showCustomAlert("Detalle guardado exitosamente.");
                    } else if (trimmedResponse.startsWith("error_validacion")) {
                        showCustomAlert("Error de validación: " + trimmedResponse.substring(trimmedResponse.indexOf(":") + 1));
                    } else {
                        showCustomAlert("Respuesta inesperada del servidor al guardar detalle: " + trimmedResponse);
                        console.log("Respuesta completa del servidor:", response);
                    }
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    console.error("Error de comunicación con el servidor al guardar detalle:", textStatus, errorThrown, jqXHR.responseText);
                    showCustomAlert("Ocurrió un error al intentar guardar el detalle. Por favor, intente de nuevo.");
                }
            });
        }

        // Elimina un detalle
        function removerDetalleFactura(idDetalle, idFactura) {
            showConfirmDialog("¿Estás seguro de que deseas eliminar este detalle?", function() {
                $.ajax({
                    url: '../controles/Control_facturacion.jsp',
                    type: 'GET', // O POST, según la implementación del backend
                    data: {campo: 'eliminarDetalle', id_detalle: idDetalle},
                    success: function (response) {
                        const trimmedResponse = response.trim();
                        if (trimmedResponse === "exito") {
                            showCustomAlert("Detalle eliminado exitosamente.");
                            rellenarDetallesFactura(idFactura); // Recargar la tabla de detalles
                            rellenarFacturas(); // Recargar la tabla principal para actualizar totales
                        } else if (trimmedResponse === "no_encontrado") {
                            showCustomAlert("Error: El detalle no fue encontrado.");
                        } else {
                            showCustomAlert("Respuesta inesperada al eliminar detalle: " + trimmedResponse);
                        }
                    },
                    error: function (jqXHR, textStatus, errorThrown) {
                        console.error("Error de comunicación al eliminar detalle:", textStatus, errorThrown, jqXHR.responseText);
                        showCustomAlert('Error de comunicación al eliminar el detalle.');
                    }
                });
            });
        }


        // --- Funciones de Alerta/Confirmación Personalizadas (usando Modales de Bootstrap) ---

        /**
         * Muestra un modal de alerta personalizado.
         * @param {string} message El mensaje a mostrar.
         * @param {string} title Título opcional para el modal. Por defecto es "Mensaje".
         */
        function showCustomAlert(message, title = "Mensaje") {
            $('#customMessageModalLabel').text(title);
            $('#customMessageModalBody').html(message);
            $('#customMessageModal').modal('show');
        }

        /**
         * Muestra un modal de diálogo de confirmación personalizado.
         * @param {string} message El mensaje de confirmación.
         * @param {function} onConfirm Función de callback a ejecutar si se confirma.
         * @param {function} onCancel Función de callback a ejecutar si se cancela (opcional).
         */
        function showConfirmDialog(message, onConfirm, onCancel = null) {
            $('#confirmarEliminarModalLabel').text('Confirmar Acción'); // Reutiliza el modal de eliminación para confirmación general
            $('#confirmarEliminarModal .modal-body').html(message);
            $('#confirmarEliminarModal').modal('show');

            // Limpiar controladores de eventos anteriores para evitar múltiples activaciones
            $('#confirmarEliminarFacturaBtn').off('click');
            $('#confirmarEliminarModal').off('hidden.bs.modal'); // Escucha el evento de cierre del modal

            $('#confirmarEliminarFacturaBtn').on('click', function() {
                $('#confirmarEliminarModal').modal('hide'); // Ocultar el modal primero
                if (onConfirm && typeof onConfirm === 'function') {
                    onConfirm();
                }
            });

            $('#confirmarEliminarModal').on('hidden.bs.modal', function(e) {
                // Solo si el modal fue cerrado sin confirmar (e.g., clic fuera, botón 'Cancelar', tecla Esc)
                if (!$(e.relatedTarget).is('#confirmarEliminarFacturaBtn')) {
                    if (onCancel && typeof onCancel === 'function') {
                        onCancel();
                    }
                }
                // Importante: Desregistrar el evento para evitar múltiples llamadas en futuras aperturas
                $('#confirmarEliminarModal').off('hidden.bs.modal');
            });
        }
    </script>
</div>
</div>
<%@include file="footer.jsp" %>