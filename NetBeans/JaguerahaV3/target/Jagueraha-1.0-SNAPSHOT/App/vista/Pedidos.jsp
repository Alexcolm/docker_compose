<!doctype html>
<html lang="en">
    <%@include file="header.jsp" %>
    <div class="app-content">
        <div class="botones" style="display: flex; justify-content: center; align-items: center; padding: 10px;">
            <button type="button" class="Modal btn btn-success" data-toggle="modal" data-target="#pedidoModal" onclick="nuevoPedido()">
                Agregar Pedido
            </button>
        </div>
        <table class="table client">
            <thead class="thead-light">
                <tr>
                    <th scope="col">ID Pedido</th>
                    <th scope="col">Cliente</th>
                    <th scope="col">Combustible</th>
                    <th scope="col">Cantidad (Lts)</th>
                    <th scope="col">Dirección</th>
                    <th scope="col">Ciudad</th>
                    <th scope="col">Fecha Pedido</th>
                    <th scope="col">Estado</th>
                    <th scope="col"></th>
                </tr>
            </thead>
            <tbody id="listadopedidos">

            </tbody >
        </table>

        <div class="modal fade" id="pedidoModal" tabindex="-1" aria-labelledby="pedidoModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="pedidoModalLabel">Agregar Pedido</h5>
                    </div>
                    <div class="modal-body">
                        <form id="formPedido" name="formPedido">
                            <div class="form-group">
                                <input type="hidden" class="form-control" name="campo" id="campoPedido" value="guardar">
                                <input type="hidden" class="form-control" name="pk" id="pkPedido" value="">

                                <label for="idCliente">Cliente</label>
                                <select class="form-control modal-form" name="idCliente" id="idCliente">
                                    <option value="">Seleccione Cliente</option>
                                </select>

                                <label for="idCombustible">Tipo de Combustible</label>
                                <select class="form-control modal-form" name="idCombustible" id="idCombustible">
                                    <option value="">Seleccione Combustible</option>
                                </select>

                                <label for="cantidadLitros">Cantidad de Litros</label>
                                <input type="number" step="0.01" class="form-control modal-form" name="cantidadLitros" id="cantidadLitros" required>

                                <label for="direccionEntrega">Dirección de Entrega</label>
                                <input type="text" class="form-control modal-form" name="direccionEntrega" id="direccionEntrega" required>

                                <label for="idCiudad">Ciudad de Entrega</label>
                                <select class="form-control modal-form" name="idCiudad" id="idCiudad">
                                    <option value="">Seleccione Ciudad</option>
                                </select>

                                <label for="estado">Estado del Pedido</label>
                                <select class="form-control modal-form" name="estado" id="estado">
                                    <option value="pendiente">Pendiente</option>
                                    <option value="en_proceso">En Proceso</option>
                                    <option value="entregado">Entregado</option>
                                    <option value="cancelado">Cancelado</option>
                                </select>
                            </div>
                            <div class="modal-footer">
                                <button type="button" id="cerrarPedidoModal" class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
                                <button type="button" class="btn btn-primary" id="guardarPedido">Guardar</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <div class="modal fade" id="confirmarEliminarPedidoModal" tabindex="-1" aria-labelledby="confirmarEliminarPedidoModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="confirmarEliminarPedidoModalLabel">Confirmar Eliminación de Pedido</h5>
                    </div>
                    <div class="modal-body">
                        ¿Estás seguro de que deseas eliminar este Pedido?
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                        <button type="button" class="btn btn-success" id="confirmarEliminarPedidoBtn">Eliminar</button>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
        <script>
            var idPedidoEliminar = null;

            $(document).ready(function () {
                rellenarPedidos();
                cargarClientes();
                cargarCombustibles();
                cargarCiudades(); 

                $("#cerrarPedidoModal").click(function () {
                    $("#formPedido")[0].reset();
                    $("#campoPedido").val("guardar");
                    $("#pkPedido").val("");
                    $("#idCliente").val("");
                    $("#idCombustible").val(""); 
                    $("#idCiudad").val("");
                    $("#pedidoModalLabel").text("Agregar Pedido");
                });
            });

            function rellenarPedidos() {
                $.get("../controles/Pedidos_control.jsp", {campo: 'listar'}, function (data) {
                    $("#listadopedidos").html(data);
                });
            }

            function cargarClientes(idClienteSeleccionado = null) {
                $.get("../controles/Pedidos_control.jsp", {campo: 'listarClientes'}, function (data) {
                    $("#idCliente").html('<option value="">Seleccione Cliente</option>' + data);
                    if (idClienteSeleccionado) {
                        $("#idCliente").val(idClienteSeleccionado);
                    }
                });
            }

            function cargarCombustibles(idCombustibleSeleccionado = null) {
                $.get("../controles/Pedidos_control.jsp", {campo: 'listarCombustibles'}, function (data) {
                    $("#idCombustible").html('<option value="">Seleccione Combustible</option>' + data);
                    if (idCombustibleSeleccionado) {
                        $("#idCombustible").val(idCombustibleSeleccionado);
                    }
                });
            }

            function cargarCiudades(idCiudadSeleccionada = null) {
                $.get("../controles/Pedidos_control.jsp", {campo: 'listarCiudades'}, function (data) {
                    $("#idCiudad").html('<option value="">Seleccione Ciudad</option>' + data);
                    if (idCiudadSeleccionada) {
                        $("#idCiudad").val(idCiudadSeleccionada);
                    }
                });
            }

            $("#guardarPedido").click(function () {
                datosform = $("#formPedido").serialize();
                $.ajax({
                    data: datosform,
                    url: '../controles/Pedidos_control.jsp',
                    type: 'post',
                    beforeSend: function () {
                    },
                    success: function (response) {
                        $("#cerrarPedidoModal").click();
                        rellenarPedidos();
                        
                        $("#cantidadLitros").val('');
                        $("#direccionEntrega").val('');
                        $("#estado").val('pendiente');
                        $("#idCliente").val('');
                        $("#idCombustible").val('');
                        $("#idCiudad").val('');
                    },
                    error: function(jqXHR, textStatus, errorThrown) {
                        console.error("Error al guardar/modificar pedido:", textStatus, errorThrown, jqXHR.responseText);
                        alert("Error al guardar/modificar el pedido. Consulta la consola para más detalles.");
                    }
                });
            });

            function datosModifPedido(pk, id_cliente, id_combustible, cantidad_litros, direccion_entrega, id_ciudad, estado) {
                $("#pkPedido").val(pk);
                $("#cantidadLitros").val(cantidad_litros);
                $("#direccionEntrega").val(direccion_entrega);
                $("#estado").val(estado);
                cargarClientes(id_cliente);
                cargarCombustibles(id_combustible); 
                cargarCiudades(id_ciudad); 
                $("#campoPedido").val("modificar");
                $("#pedidoModalLabel").text("Modificar Pedido"); 
                $('#pedidoModal').modal('show'); 
            }

            function nuevoPedido() {
                $("#formPedido")[0].reset();
                $("#campoPedido").val("guardar");
                $("#pkPedido").val("");
                $("#idCliente").val(""); 
                $("#idCombustible").val(""); 
                $("#idCiudad").val(""); 
                $("#pedidoModalLabel").text("Agregar Pedido"); 
                cargarClientes();
                cargarCombustibles(); 
                cargarCiudades(); 
            }

            function dellPedido(id) {
                idPedidoEliminar = id;
                $('#confirmarEliminarPedidoModal').modal('show');
            }

            $("#confirmarEliminarPedidoBtn").click(function () {
                if (idPedidoEliminar !== null) {
                    $.ajax({
                        url: '../controles/Pedidos_control.jsp',
                        type: 'GET',
                        data: {campo: 'eliminar', pk: idPedidoEliminar},
                        success: function (data) {
                            $('#confirmarEliminarPedidoModal').modal('hide');
                            rellenarPedidos();
                            idPedidoEliminar = null;
                        },
                        error: function () {
                            alert('Error al eliminar el pedido.');
                        }
                    });
                }
            });
        </script>
    </div>
</main>
</div>
<%@include file="footer.jsp" %>