<!doctype html>
<html lang="en">
    <%@include file="header.jsp" %>
    <div class="app-content">
        <div class="botones" style="display: flex; justify-content: center; align-items: center; padding: 10px;">
            <button type="button" class="Modal btn btn-success" data-toggle="modal" data-target="#exampleModal" onclick="nuevoRegistro()">
                Agregar Vehiculo
            </button>
        </div>
        <table class="table client">
            <thead class="thead-light">
                <tr>
                    <th scope="col">ID</th>
                    <th scope="col">Marca</th>
                    <th scope="col">Modelo</th>
                    <th scope="col">Descripcion</th>
                    <th scope="col">Color</th>
                    <th scope="col">Chapa</th>
                    <th scope="col">Capacidad del tanque</th>
                    <th scope="col"></th>
                </tr>
            </thead>
            <tbody id="listadovehiculos">

            </tbody >
        </table>
        <div class="modal fade" id="exampleModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="exampleModalLabel">Agregar Vehiculo</h5>
                    </div>
                    <div class="modal-body">
                        <form id="form" name="form">
                            <div class="form-group ">
                                <input type="hidden" class="form-control" name="campo" id="campo" value="guardar">
                                <input type="hidden" class="form-control" name="pk" id="pk" value="">
                                <h6>Seleccione una Marca</h6>
                                <select class="form-control modal-form" name="id_marca" id="id_marca" onchange="cargarModelosPorMarca()" required>
                                    <option value="">Seleccione marca</option>
                                </select>
                                <h6>Seleccione un modelo</h6>
                                <select class="form-control modal-form" name="id_modelo" id="id_modelo" required>
                                    <option value="">Seleccione modelo</option>
                                </select>
                                <h6>Descripcion</h6>
                                <input type="text" class="form-control modal-form" name="descripcion" id="descripcion" required>
                                <h6>Color</h6>
                                <input type="text" class="form-control modal-form" name="color" id="color" required>
                                <h6>Chapa</h6>
                                <input type="text" class="form-control modal-form" name="chapa" id="chapa" required>
                                <h6>Capacidad del tanque</h6>
                                <input type="text" class="form-control modal-form" name="capacidad" id="capacidad" required pattern="[0-9]*\.?[0-9]+" title="Solo números y opcionalmente un punto decimal">

                            </div>
                            <div class="modal-footer">
                                <button type="button" id="cerrar" class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
                                <button type="button" class="btn btn-primary" id="guardarRegistro">Guardar</button>
                            </div>
                        </form>
                    </div>

                </div>
            </div>
        </div>

        <div class="modal fade" id="confirmarEliminarModal" tabindex="-1" aria-labelledby="confirmarEliminarModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="confirmarEliminarModalLabel">Confirmar Eliminacion</h5>
                    </div>
                    <div class="modal-body">
                        ¿Estás seguro de que deseas eliminar este Vehiculo?
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                        <button type="button" class="btn btn-success" id="confirmarEliminarBtn">Eliminar</button>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
        <script>
            var idVehiculoEliminar = null;

            $(document).ready(function () {
                rellenar();
                cargarMarcas();
                $("#cerrar").click(function () {
                    $("#form")[0].reset();
                    $("#campo").val("guardar");
                    $("#id_modelo").html('<option value="">Seleccione Modelo</option>');
                    $("#id_marca").val('');
                    $("#pk").val('');
                });
            });

            function rellenar() {
                $.get("../controles/Vehiculos_control.jsp", {campo: 'listar'}, function (data) {
                    $("#listadovehiculos").html(data);
                });
            }

            function cargarMarcas() {
                $.get("../controles/Vehiculos_control.jsp", {campo: 'listarMarcas'}, function (data) {
                    $("#id_marca").html('<option value="">Seleccione Marca</option>' + data);
                });
            }

            function cargarModelosPorMarca(id_marca_seleccionada = null, id_modelo_seleccionado = null) {
                var idMarca = id_marca_seleccionada || $("#id_marca").val();
                if (idMarca) {
                    $.get("../controles/Vehiculos_control.jsp", {campo: 'listarModelos', id_marca: idMarca}, function (data) {
                        $("#id_modelo").html('<option value="">Seleccione Modelo</option>' + data);
                        if (id_modelo_seleccionado) {
                            $("#id_modelo").val(id_modelo_seleccionado);
                        }
                    });
                } else {
                    $("#id_modelo").html('<option value="">Seleccione Modelo</option>');
                }
            }

            $("#guardarRegistro").click(function () {
                if ($("#chapa").val().trim() === '') {
                    alert("La chapa no puede estar vacía.");
                    return;
                }
                if ($("#descripcion").val().trim() === '') {
                    alert("La descripción no puede estar vacía.");
                    return;
                }
                if ($("#color").val().trim() === '') {
                    alert("El color no puede estar vacía.");
                    return;
                }
                if ($("#id_marca").val() === '') {
                    alert("Debe seleccionar una marca.");
                    return;
                }
                if ($("#id_modelo").val() === '') {
                    alert("Debe seleccionar un modelo.");
                    return;
                }
                const capacidadVal = $("#capacidad").val().trim();
                const numericRegex = /^[0-9]+(\.[0-9]+)?$/;
                if (capacidadVal === '' || !numericRegex.test(capacidadVal) || parseFloat(capacidadVal) <= 0) {
                    alert("La capacidad del tanque debe ser un número válido y mayor a cero (p. ej., 50 o 45.5).");
                    return;
                }

                datosform = $("#form").serialize();
                $.ajax({
                    data: datosform,
                    url: '../controles/Vehiculos_control.jsp',
                    type: 'post',
                    beforeSend: function () {
                    },
                    success: function (response) {
                        const trimmedResponse = response.trim();
                        if (trimmedResponse === "chapa_existe") {
                            alert("Error: Ya existe un vehículo con esa chapa.");
                        } else if (trimmedResponse === "capacidad_invalida") {
                            alert("Error: La capacidad del tanque debe ser un número válido y positivo.");
                        } else if (trimmedResponse === "marca_modelo_invalidos") {
                            alert("Error: Marca o modelo seleccionados son inválidos.");
                        } else if (trimmedResponse === "campos_vacios") {
                            alert("Error: Por favor, complete todos los campos.");
                        } else if (trimmedResponse === "error_bd") {
                            alert("Ocurrió un error en la base de datos al intentar guardar/modificar el vehículo.");
                        } else if (trimmedResponse === "error_inesperado") {
                            alert("Ocurrió un error inesperado en el servidor.");
                        } else if (trimmedResponse === "exito") {
                            $("#cerrar").click();
                            rellenar();
                        } else {
                            alert("Respuesta inesperada del servidor: " + response);
                            console.log("Respuesta completa del servidor:", response);
                        }
                    },
                    error: function(jqXHR, textStatus, errorThrown) {
                        console.error("Error de comunicación al guardar:", textStatus, errorThrown, jqXHR.responseText);
                        alert("Error de comunicación con el servidor. Por favor, intente de nuevo más tarde.");
                    }
                });
            });

            function datosModif(pk, id_marca, id_modelo, descripcion, color, chapa, capacidad) {
                $("#pk").val(pk);
                $("#descripcion").val(descripcion);
                $("#color").val(color);
                $("#chapa").val(chapa);
                $("#capacidad").val(capacidad);
                $("#id_marca").val(id_marca);
                cargarModelosPorMarca(id_marca, id_modelo);
                $("#campo").val("modificar");
                $('#exampleModal').modal('show');
            }

            function nuevoRegistro() {
                $("#form")[0].reset();
                $("#campo").val("guardar");
                $("#pk").val("");
                $("#id_marca").val('');
                $("#id_modelo").html('<option value="">Seleccione Modelo</option>');
            }

            function dell(a) {
                idVehiculoEliminar = a;
                $('#confirmarEliminarModal').modal('show');
            }

            $("#confirmarEliminarBtn").click(function () {
                if (idVehiculoEliminar !== null) {
                    $.ajax({
                        url: '../controles/Vehiculos_control.jsp',
                        type: 'GET',
                        data: {campo: 'eliminar', pk: idVehiculoEliminar},
                        success: function (response) {
                            const trimmedResponse = response.trim();
                            if (trimmedResponse === "exito") {
                                $('#confirmarEliminarModal').modal('hide');
                                rellenar();
                                idVehiculoEliminar = null;
                            } else if (trimmedResponse === "no_encontrado") {
                                alert("El vehículo que intentas eliminar no fue encontrado.");
                            } else if (trimmedResponse === "error_bd") {
                                alert("Ocurrió un error en la base de datos al intentar eliminar el vehículo.");
                            } else {
                                alert('Error al eliminar el vehículo: ' + response);
                                console.log("Respuesta completa del servidor:", response);
                            }
                        },
                        error: function (jqXHR, textStatus, errorThrown) {
                            console.error("Error de comunicación al intentar eliminar el vehículo:", textStatus, errorThrown, jqXHR.responseText);
                            alert('Error de comunicación al intentar eliminar el vehículo.');
                        }
                    });
                }
            });
        </script>
        </div>
    </main>
</div>
<%@include file="footer.jsp" %>