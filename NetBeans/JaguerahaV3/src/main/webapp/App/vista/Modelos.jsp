<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!doctype html>
<html lang="en">
    <%@ include file="header.jsp" %>
    <div class="app-content-header">
        <div class="container-fluid">
            <div class="row">
                <div class="col-sm-6"><h3 class="mb-0">Gestión de Modelos</h3></div>
                <div class="col-sm-6">
                    <!-- Espacio para posibles elementos adicionales en el encabezado -->
                </div>
            </div>
        </div>
    </div>
    <div class="app-content">
        <div class="botones" style="display: flex; justify-content: center; align-items: center; padding: 10px;">
            <button type="button" class="Modal  btn btn-success" data-toggle="modal" data-target="#exampleModal" onclick="nuevoRegistro()">
                Agregar Modelo
            </button>
        </div>
        <table class="table client">
            <thead class="thead-light">
                <tr>
                    <th scope="col"></th>
                    <th scope="col">Modelo</th>
                    <th scope="col">cantidad de puertas</th>
                    <th scope="col">Cantidad de plazas</th>
                    <th scope="col">Marca</th>
                    <th scope="col"></th>
                </tr>
            </thead>
            <tbody id="listadomodelo">
            </tbody>
        </table>

        <div class="modal fade" id="exampleModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="exampleModalLabel">Agregar Modelo</h5>
                    </div>
                    <div class="modal-body">
                        <form id="form" name="form">
                            <div class="form-group ">
                                <input type="hidden" class="form-control" name="campo" id="campo" value="guardar">
                                <input type="hidden" class="form-control" name="pk" id="pk" value="">
                                <h6>Nombre del modelo</h6>
                                <input type="text" class="form-control modal-form" name="nombre" id="nombre" required>
                                <h6>Cantidad de puertas</h6>
                                <input type="text" class="form-control modal-form" name="puerta" id="puerta" required>
                                <h6>Cantidad de plazas</h6>
                                <input type="text" class="form-control modal-form" name="plaza" id="plaza"required>
                                <select class="form-control modal-form" name="marca" id="marca">
                                    <option value="">Seleccione una marca</option>
                                </select>
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
                        ¿Estás seguro de que deseas eliminar este Modelo?
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                        <button type="button" class="btn btn-success" id="confirmarEliminarBtn">Eliminar</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script>
        $(document).ready(function () {
            rellenar();

            $("#cerrar").click(function () {
                $("#form")[0].reset();
                $("#campo").val("guardar");
                $("#pk").val("");
                $("#marca").val("");
            });

            $('#exampleModal').on('show.bs.modal', function (event) {
                
                $("#marca option:not(:first)").remove();
                cargarMarcas();
            });
        });

        function cargarMarcas() {
            $.get("../controles/Modelos_control.jsp", {campo: 'listarMarcas'}, function (data) {
                $("#marca").append(data);
            });
        }

        function rellenar() {
            $.get("../controles/Modelos_control.jsp", {campo: 'listar'}, function (data) {
                $("#listadomodelo").html(data);
            });
        }

        $("#guardarRegistro").click(function () {
            let puertaVal = $('#puerta').val();
            let plazaVal = $('#plaza').val();

            if (isNaN(puertaVal) || isNaN(plazaVal) || puertaVal.trim() === '' || plazaVal.trim() === '') {
                alert("Por favor, ingrese valores numéricos válidos para 'Cantidad de puertas' y 'Cantidad de plazas'.");
                return; 
            }
            if ($("#nombre").val().trim() === '') {
                alert("El nombre del modelo no puede estar vacío.");
                return;
            }
            if ($("#marca").val() === '') {
                alert("Debe seleccionar una marca.");
                return;
            }

            datosform = $("#form").serialize();
            $.ajax({
                data: datosform,
                url: '../controles/Modelos_control.jsp',
                type: 'post',
                beforeSend: function () {
                   
                },
                success: function (response) {
                    const trimmedResponse = response.trim();
                    if (trimmedResponse === "existe") {
                        alert("Error: Ya existe un modelo con ese nombre para la marca seleccionada.");
                    } else if (trimmedResponse === "error") {
                        alert("Ocurrió un error en el servidor al intentar guardar el modelo.");
                    } else {
                        $('#exampleModal').modal('hide');
                        $("#form")[0].reset();
                        $("#campo").val("guardar");
                        $("#pk").val("");
                        $("#marca").val(""); 
                        rellenar();
                    }
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    console.error("Error saving record: ", textStatus, errorThrown);
                    alert("Error de comunicación con el servidor al intentar guardar el registro.");
                }
            });
        });

        function datosModif(a, b, c, d, e) {
            $("#pk").val(a);
            $("#nombre").val(b);
            $("#puerta").val(c);
            $("#plaza").val(d);
            $("#marca").val(e);
            $("#campo").val("modificar");
            $('#exampleModal').modal('show');
        }

        var idModeloEliminar = null;

        function dell(a) {
            idModeloEliminar = a;
            $('#confirmarEliminarModal').modal('show');
        }

        $("#confirmarEliminarBtn").click(function () {
            if (idModeloEliminar !== null) {
                $.ajax({
                    url: '../controles/Modelos_control.jsp',
                    type: 'GET',
                    data: {campo: 'eliminar', pk: idModeloEliminar},
                    success: function (data) {
                        $('#confirmarEliminarModal').modal('hide');
                        rellenar();
                        idModeloEliminar = null;
                    },
                    error: function (jqXHR, textStatus, errorThrown) {
                        console.error("Error deleting record: ", textStatus, errorThrown);
                        alert('Error al eliminar el modelo.');
                    }
                });
            }
        });
    </script>
        </div>
    </main>
<%@ include file="footer.jsp" %>