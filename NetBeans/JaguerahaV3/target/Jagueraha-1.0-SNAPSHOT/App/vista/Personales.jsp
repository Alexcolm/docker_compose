<!doctype html>
<html lang="en">
    <%@include file="header.jsp" %>
    <div class="app-content-header">
        <div class="container-fluid">
            <div class="row">
                <div class="col-sm-6"><h3 class="mb-0">Gestión de Personales</h3></div>
                <div class="col-sm-6">
                    <!-- Espacio para posibles elementos adicionales en el encabezado -->
                </div>
            </div>
        </div>
    </div>
    <div class="app-content">
        <!--begin::Container-->
        <div class="botones" style="display: flex; justify-content: center; align-items: center; padding: 10px;">
            <button type="button" class="Modal btn btn-success" data-toggle="modal" data-target="#exampleModal" onclick="nuevoRegistro()">
                Agregar personal
            </button>
        </div>
        <table class="table client">
            <thead class="thead-light">
                <tr>
                    <th scope="col">ID</th>
                    <th scope="col">Cedula</th>
                    <th scope="col">Nombre completo</th>
                    <th scope="col">Cargo</th>
                    <th scope="col">Telefono</th>
                    <th scope="col">Correo electronico</th>
                    <th scope="col">Estado</th>
                    <th scope="col">fecha de ingreso</th>
                    <th scope="col"></th>
                </tr>
            </thead>
            <tbody id="listadopersonales">

            </tbody >
        </table>
        <div class="modal fade" id="exampleModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="exampleModalLabel">Agregar Personales</h5>

                    </div>
                    <div class="modal-body">
                        <form id="form" name="form">
                            <div class="form-group ">
                                <input type="hidden" class="form-control" name="campo" id="campo" value="guardar">
                                <input type="hidden" class="form-control" name="pk" id="pk" value="">
                                <h6>Cedula</h6>
                                <input type="text" class="form-control modal-form" name="cedula" id="cedula" required>
                                <h6>Nombre</h6>
                                <input type="text" class="form-control modal-form" name="nombre" id="nombre" required>
                                <h6>Cargo</h6>
                                <input type="text" class="form-control modal-form" name="cargo" id="cargo" required>
                                <h6>Telefono</h6>
                                <input type="text" class="form-control modal-form" name="telefono" id="telefono" required>
                                <h6>Correo Electronico</h6>
                                <input type="text" class="form-control modal-form" name="correo" id="correo" required>
                                <h6>Estado</h6>
                                <select class="form-control modal-form" name="estado" id="estado" required>
                                    <option value="Activo">Activo</option>
                                    <option value="Inactivo">Inactivo</option>
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
                        ¿Estás seguro de que deseas eliminar este Personal?
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
            var idPersonalEliminar = null;

            $(document).ready(function () {
                rellenar();
                $("#cerrar").click(function () {
                    $("#form")[0].reset();
                    $("#campo").val("guardar");
                    $("#pk").val("");
                });
            });

            function rellenar() {
                $.get("../controles/Personales.jsp", {campo: 'listar'}, function (data) {
                    $("#listadopersonales").html(data);
                });
            }

            $("#guardarRegistro").click(function () {
                
                const cedula = $("#cedula").val().trim();
                const nombre = $("#nombre").val().trim();
                const telefono = $("#telefono").val().trim();
                const correo = $("#correo").val().trim();
                const cargo = $("#cargo").val().trim();

                if (cedula === '') {
                    alert("La cédula no puede estar vacía.");
                    return;
                }
                if (nombre === '') {
                    alert("El nombre no puede estar vacío.");
                    return;
                }
                if (cargo === '') {
                    alert("El cargo no puede estar vacío.");
                    return;
                }
                if (telefono === '') {
                    alert("El teléfono no puede estar vacío.");
                    return;
                }
                if (correo === '') {
                    alert("El correo electrónico no puede estar vacío.");
                    return;
                }
                
                if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(correo)) {
                    alert("Por favor, introduce un correo electrónico válido.");
                    return;
                }


                datosform = $("#form").serialize();
                $.ajax({
                    data: datosform,
                    url: '../controles/Personales.jsp',
                    type: 'get',
                    beforeSend: function () {
                        
                    },
                    success: function (response) {
                        const trimmedResponse = response.trim();
                        if (trimmedResponse === "cedula_existe") {
                            alert("Error: Ya existe un personal con esa CÉDULA.");
                        } else if (trimmedResponse === "nombre_existe") {
                            alert("Error: Ya existe un personal con ese NOMBRE completo.");
                        } else if (trimmedResponse === "telefono_existe") {
                            alert("Error: Ya existe un personal con ese TELÉFONO.");
                        } else if (trimmedResponse === "correo_existe") {
                            alert("Error: Ya existe un personal con ese CORREO ELECTRÓNICO.");
                        } else if (trimmedResponse === "error_bd") {
                            alert("Ocurrió un error en la base de datos al intentar guardar/modificar el personal.");
                        } else if (trimmedResponse === "error_formato_id") {
                            alert("Error de formato en el ID del personal. Por favor, contacte a soporte.");
                        } else if (trimmedResponse === "exito") {
                            $("#cerrar").click();
                            rellenar();
                        } else {
                            alert("Respuesta inesperada del servidor: " + response);
                            console.log("Respuesta completa del servidor:", response);
                        }
                    },
                    error: function(jqXHR, textStatus, errorThrown) {
                        console.error("Error al comunicarse con el servidor:", textStatus, errorThrown, jqXHR.responseText);
                        alert("Error de comunicación con el servidor. Por favor, intente de nuevo más tarde.");
                    }
                });
            });

            function datosModif(id, cedula, nombre, cargo, telefono, correo, estado) {
                $("#pk").val(id);
                $("#cedula").val(cedula);
                $("#nombre").val(nombre);
                $("#cargo").val(cargo);
                $("#telefono").val(telefono);
                $("#correo").val(correo);
                $("#estado").val(estado);
                $("#campo").val("modificar");
                $('#exampleModal').modal('show');
            }

            function nuevoRegistro() {
                $("#form")[0].reset();
                $("#campo").val("guardar");
                $("#pk").val("");
            }

            function dell(id) {
                idPersonalEliminar = id;
                $('#confirmarEliminarModal').modal('show');
            }

            $("#confirmarEliminarBtn").click(function () {
                if (idPersonalEliminar !== null) {
                    $.ajax({
                        url: '../controles/Personales.jsp',
                        type: 'GET',
                        data: {campo: 'eliminar', pk: idPersonalEliminar},
                        success: function (response) {
                            const trimmedResponse = response.trim();
                            if (trimmedResponse === "exito") {
                                $('#confirmarEliminarModal').modal('hide');
                                rellenar();
                                idPersonalEliminar = null;
                            } else if (trimmedResponse === "no_encontrado") {
                                alert("El personal que intentas eliminar no fue encontrado.");
                            } else if (trimmedResponse === "error_bd") {
                                alert("Ocurrió un error en la base de datos al intentar eliminar el personal.");
                            } else {
                                alert('Error al eliminar el personal: ' + response);
                            }
                        },
                        error: function () {
                            alert('Error de comunicación al intentar eliminar el personal.');
                        }
                    });
                }
            });
        </script>
        <!--end::Container-->
    </div>
    <!--end::App Content-->
</main>
</div>
<%@include file="footer.jsp" %>