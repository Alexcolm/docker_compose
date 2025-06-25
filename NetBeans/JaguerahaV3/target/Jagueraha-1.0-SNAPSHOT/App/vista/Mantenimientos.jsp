<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!doctype html>
<html lang="es">
    <%@include file="header.jsp" %>
    <div class="app-content-header">
        <div class="container-fluid">
            <div class="row">
                <div class="col-sm-6"><h3 class="mb-0">Gestión de Mantenimientos</h3></div>
                <div class="col-sm-6">
                    <!-- Espacio para posibles elementos adicionales en el encabezado -->
                </div>
            </div>
        </div>
    </div>
    <div class="app-content">
        <div class="botones" style="display: flex; justify-content: center; align-items: center; padding: 10px;">
            <button type="button" class="Modal btn btn-success" data-toggle="modal" data-target="#mantenimientoModal" onclick="nuevoMantenimiento()">
                Registrar Mantenimiento
            </button>
        </div>
        <table class="table client">
            <thead class="thead-light">
                <tr>
                    <th scope="col">ID</th>
                    <th scope="col">Vehículo (Chapa)</th>
                    <th scope="col">Fecha</th>
                    <th scope="col">Kilometraje</th>
                    <th scope="col">Tipo de Mantenimiento</th>
                    <th scope="col">Costo (Gs.)</th>
                    <th scope="col">Acciones</th>
                </tr>
            </thead>
            <tbody id="listadoMantenimientos">
                </tbody>
        </table>

        <div class="modal fade" id="mantenimientoModal" tabindex="-1" aria-labelledby="mantenimientoModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="mantenimientoModalLabel">Registrar Mantenimiento</h5>
                    </div>
                    <div class="modal-body">
                        <form id="formMantenimiento" name="formMantenimiento">
                            <input type="hidden" name="campo" id="campoMantenimiento" value="guardar">
                            <input type="hidden" name="pk" id="pkMantenimiento" value="">

                            <div class="form-group">
                                <label for="idVehiculo">Vehículo</label>
                                <select class="form-control modal-form" name="idVehiculo" id="idVehiculo" required>
                                    <option value="">Seleccione un Vehículo</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label for="fechaMantenimiento">Fecha del Mantenimiento</label>
                                <input type="date" class="form-control modal-form" name="fechaMantenimiento" id="fechaMantenimiento" required>
                            </div>

                            <div class="form-group">
                                <label for="kilometraje">Kilometraje</label>
                                <input type="number" class="form-control modal-form" name="kilometraje" id="kilometraje" required>
                            </div>

                            <div class="form-group">
                                <label for="tipoMantenimiento">Tipo de Mantenimiento</label>
                                <input type="text" class="form-control modal-form" name="tipoMantenimiento" id="tipoMantenimiento" required>
                            </div>
                            
                             <div class="form-group">
                                <label for="costo">Costo Total (Gs.)</label>
                                <input type="number" class="form-control modal-form" name="costo" id="costo"  required>
                            </div>

                            <div class="form-group">
                                <label for="tallerResponsable">Taller o Responsable</label>
                                <input type="text" class="form-control modal-form" name="tallerResponsable" id="tallerResponsable">
                            </div>
                            
                            <div class="form-group">
                                <label for="fechaProximoServicio">Fecha Próximo Servicio (Opcional)</label>
                                <input type="date" class="form-control modal-form" name="fechaProximoServicio" id="fechaProximoServicio">
                            </div>
                            
                             <div class="form-group">
                                <label for="descripcion">Descripción / Notas</label>
                                <textarea class="form-control modal-form" name="descripcion" id="descripcion" rows="3"></textarea>
                            </div>

                            <div class="modal-footer">
                                <button type="button" id="cerrarMantenimientoModal" class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
                                <button type="button" class="btn btn-primary" id="guardarMantenimiento">Guardar</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <div class="modal fade" id="confirmarEliminarMantenimientoModal" tabindex="-1" aria-labelledby="confirmarEliminarModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="confirmarEliminarModalLabel">Confirmar Eliminación</h5>
                    </div>
                    <div class="modal-body">
                        ¿Estás seguro de que deseas eliminar este registro de mantenimiento?
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                        <button type="button" class="btn btn-success" id="confirmarEliminarMantenimientoBtn">Eliminar</button>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
        <script>
            var idMantenimientoEliminar = null;

            $(document).ready(function () {
                rellenarMantenimientos();

                // Limpiar modal al cerrar
                $('#mantenimientoModal').on('hidden.bs.modal', function () {
                    $("#formMantenimiento")[0].reset();
                    $("#campoMantenimiento").val("guardar");
                    $("#pkMantenimiento").val("");
                    $("#mantenimientoModalLabel").text("Registrar Mantenimiento");
                });
            });

            function rellenarMantenimientos() {
                $.get("../controles/Mantenimientos_control.jsp", {campo: 'listar'}, function (data) {
                    $("#listadoMantenimientos").html(data);
                });
            }

            function cargarVehiculos(idVehiculoSeleccionado = null) {
                $.get("../controles/Mantenimientos_control.jsp", {campo: 'listarVehiculos'}, function (data) {
                    $("#idVehiculo").html('<option value="">Seleccione un Vehículo</option>' + data);
                    if (idVehiculoSeleccionado) {
                        $("#idVehiculo").val(idVehiculoSeleccionado);
                    }
                });
            }

            $("#guardarMantenimiento").click(function () {
                // Validación simple
                if ($('#idVehiculo').val() === '' || $('#fechaMantenimiento').val() === '' || $('#kilometraje').val() === '' || $('#tipoMantenimiento').val() === '' || $('#costo').val() === '') {
                    alert('Por favor, complete todos los campos obligatorios.');
                    return;
                }
            
                var datosform = $("#formMantenimiento").serialize();
                $.ajax({
                    data: datosform,
                    url: '../controles/Mantenimientos_control.jsp',
                    type: 'post',
                    success: function (response) {
                        if (response.trim() === 'success') {
                            $('#mantenimientoModal').modal('hide');
                            rellenarMantenimientos();
                        } else {
                            alert("Error: " + response);
                        }
                    },
                    error: function (jqXHR, textStatus, errorThrown) {
                        alert("Error al guardar el registro. Revisa la consola para más detalles.");
                        console.error(textStatus, errorThrown, jqXHR.responseText);
                    }
                });
            });

            function nuevoMantenimiento() {
                // Limpiar el formulario antes de mostrar el modal
                $("#formMantenimiento")[0].reset();
                $("#campoMantenimiento").val("guardar");
                $("#pkMantenimiento").val("");
                $("#mantenimientoModalLabel").text("Registrar Mantenimiento");
                cargarVehiculos();
            }

            function datosModifMantenimiento(pk, id_vehiculo, fecha, km, tipo, desc, costo, taller, fecha_prox) {
                $("#pkMantenimiento").val(pk);
                $("#fechaMantenimiento").val(fecha);
                $("#kilometraje").val(km);
                $("#tipoMantenimiento").val(tipo);
                $("#descripcion").val(desc);
                $("#costo").val(costo);
                $("#tallerResponsable").val(taller);
                $("#fechaProximoServicio").val(fecha_prox);
                
                cargarVehiculos(id_vehiculo);
                
                $("#campoMantenimiento").val("modificar");
                $("#mantenimientoModalLabel").text("Modificar Mantenimiento");
                $('#mantenimientoModal').modal('show');
            }

            function dellMantenimiento(id) {
                idMantenimientoEliminar = id;
                $('#confirmarEliminarMantenimientoModal').modal('show');
            }

            $("#confirmarEliminarMantenimientoBtn").click(function () {
                if (idMantenimientoEliminar !== null) {
                    $.ajax({
                        url: '../controles/Mantenimientos_control.jsp',
                        type: 'GET',
                        data: {campo: 'eliminar', pk: idMantenimientoEliminar},
                        success: function (response) {
                            if(response.trim() === 'success'){
                                $('#confirmarEliminarMantenimientoModal').modal('hide');
                                rellenarMantenimientos();
                                idMantenimientoEliminar = null;
                            } else {
                                alert("Error al eliminar: " + response);
                            }
                        },
                        error: function () {
                            alert('Error de comunicación al intentar eliminar el registro.');
                        }
                    });
                }
            });
        </script>
    </div>
    <%@include file="footer.jsp" %>
</html>