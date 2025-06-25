<!doctype html>
<html lang="en">
    <%@ include file="header.jsp" %>
    <div class="app-content-header">
        <div class="container-fluid">
            <div class="row">
                <div class="col-sm-6"><h3 class="mb-0">Gestión de Ciudades</h3></div>
                <div class="col-sm-6">
                    <!-- Espacio para posibles elementos adicionales en el encabezado -->
                </div>
            </div>
        </div>
    </div>
    <div class="app-content">
        <div class="botones" style="display: flex; justify-content: center; align-items: center; padding: 10px;">
            <button type="button" class="Modal btn btn-success" data-toggle="modal" data-target="#exampleModal" onclick="nuevoRegistro()">
                Agregar Ciudad
            </button>
        </div>
        <table class="table client">
            <thead class="thead-light">
                <tr>
                    <th scope="col">ID</th>
                    <th scope="col">Ciudad</th>
                    <th scope="col">Acciones</th>
                </tr>
            </thead>
            <tbody id="listadociudad">

            </tbody >
        </table>
        <div class="modal fade" id="exampleModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="exampleModalLabel">Agregar/Modificar Ciudad</h5> <%-- Updated title --%>
                    </div>
                    <div class="modal-body">
                        <form id="form" name="form">
                            <div class="form-group ">
                                <input type="hidden" class="form-control" name="campo" id="campo" value="guardar">
                                <input type="hidden" class="form-control" name="pk" id="pk" value="">
                                <h6>Nombre de la ciudad</h6>
                                <input type="text" class="form-control modal-form" name="ciudad" id="ciudad" required> <%-- Added 'required' attribute --%>
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
                        <h5 class="modal-title" id="confirmarEliminarModalLabel">Confirmar Eliminación</h5>
                    </div>
                    <div class="modal-body">
                        ¿Estás seguro de que deseas eliminar esta Ciudad?
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
                $(document).ready(function () {
                    rellenar();
                   
                    $("#cerrar").click(function() {
                        nuevoRegistro();
                        $('#exampleModal').modal('hide');
                    });
                });

                function rellenar() {
                    $.get("../controles/Ciudades.jsp", {campo: 'listar'}, function (data) {
                        $("#listadociudad").html(data);
                    });
                }

                $("#guardarRegistro").click(function () {
                   
                    const ciudadInput = $("#ciudad").val().trim();
                    if (ciudadInput === "") {
                        alert("El nombre de la ciudad no puede estar vacío.");
                        return;
                    }

                    datosform = $("#form").serialize();
                    $.ajax({
                        data: datosform,
                        url: '../controles/Ciudades.jsp',
                        type: 'post',
                        beforeSend: function () {
                           
                        },
                        success: function (response) {
                            const trimmedResponse = response.trim();
                            if (trimmedResponse === "existe") {
                                alert("Error: Ya existe una ciudad con ese nombre.");
                            } else if (trimmedResponse === "vacio") { 
                                alert("Error: El nombre de la ciudad no puede estar vacío (server-side check).");
                            } else if (trimmedResponse === "exito") {
                                $('#exampleModal').modal('hide');
                                rellenar();
                                nuevoRegistro(); 
                            } else {
                                alert("Respuesta inesperada del servidor: " + response);
                                console.log("Respuesta completa del servidor:", response);
                            }
                        },
                        error: function (jqXHR, textStatus, errorThrown) {
                            console.error("Error de comunicación con el servidor:", textStatus, errorThrown, jqXHR.responseText);
                            alert("Ocurrió un error al intentar guardar la ciudad. Por favor, intente de nuevo.");
                        }
                    });
                });

                function datosModif(id, ciudadNombre) {
                    $("#pk").val(id);
                    $("#ciudad").val(ciudadNombre);
                    $("#campo").val("modificar"); 
                    $('#exampleModal').modal('show');
                }

                function nuevoRegistro() {
                    $("#form")[0].reset();
                    $("#campo").val("guardar");
                    $("#pk").val("");
                }

                var idCiudadEliminar = null;


                function dell(id) { 
                    idCiudadEliminar = id;
                    $('#confirmarEliminarModal').modal('show');
                }

                $("#confirmarEliminarBtn").click(function () {
                    if (idCiudadEliminar !== null) {
                        $.ajax({
                            url: '../controles/Ciudades.jsp',
                            type: 'GET',
                            data: {campo: 'eliminar', pk: idCiudadEliminar},
                            success: function (response) { 
                                const trimmedResponse = response.trim();
                                if (trimmedResponse === "exito") { 
                                    $('#confirmarEliminarModal').modal('hide');
                                    rellenar();
                                    idCiudadEliminar = null;
                                } else if (trimmedResponse === "error") {
                                    alert('Error al eliminar la ciudad en el servidor.');
                                } else {
                                    alert('Respuesta inesperada al eliminar: ' + response);
                                }
                            },
                            error: function (jqXHR, textStatus, errorThrown) {
                                console.error("Error de comunicación al eliminar:", textStatus, errorThrown, jqXHR.responseText);
                                alert('Error de comunicación al eliminar la ciudad.');
                            }
                        });
                    }
                });
        </script>
        </div>
    </main>

<%@ include file="footer.jsp" %>