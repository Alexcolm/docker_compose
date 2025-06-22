<!doctype html>
<html lang="en">
    <%@include file="header.jsp" %>
    <div class="app-content">
        <div class="botones" style="display: flex; justify-content: center; align-items: center; padding: 10px;">
            <button type="button" class="Modal btn btn-success" data-toggle="modal" data-target="#exampleModal" onclick="nuevoRegistro()">
                Agregar Usuario
            </button>
        </div>
        <table class="table client">
            <thead class="thead-light">
                <tr>
                    <th scope="col">ID</th> <%-- Added ID column header for consistency with listing --%>
                    <th scope="col">Nombre</th>
                    <th scope="col">Usuario</th>
                    <th scope="col">contraseña</th>
                    <th scope="col">Fecha de creacion</th>
                    <th scope="col"></th>
                </tr>
            </thead>
            <tbody id="listadousuarios">

            </tbody >
        </table>
        <div class="modal fade" id="exampleModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="exampleModalLabel">Agregar Usuario</h5>

                    </div>
                    <div class="modal-body">
                        <form id="form" name="form">
                            <div class="form-group ">
                                <input type="hidden" class="form-control" name="campo" id="campo" value="guardar">
                                <input type="hidden" class="form-control" name="pk" id="pk" value="">
                                <h6>Nombre</h6>
                                <input type="text" class="form-control modal-form" name="nombre" id="nombre" required>
                                <h6>Usuario</h6>
                                <input type="text" class="form-control modal-form" name="usuario" id="usuario" required>
                                <h6>Contraseña</h6>
                                <input type="password" class="form-control modal-form" name="contra" id="contra" required>
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
                        ¿Estás seguro de que deseas eliminar este usuario?
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
            var idClienteEliminar = null;

            $(document).ready(function () {
                rellenar();
                $("#cerrar").click(function () {
                    $("#form")[0].reset();
                    $("#campo").val("guardar");
                    $("#pk").val("");
                });
            });

            function rellenar() {
                $.get("../controles/Usuarios.jsp", {campo: 'listar'}, function (data) {
                    $("#listadousuarios").html(data);
                });
            }

            $("#guardarRegistro").click(function () {
                if ($("#nombre").val().trim() === '') {
                    alert("El nombre no puede estar vacío.");
                    return;
                }
                if ($("#usuario").val().trim() === '') {
                    alert("El usuario no puede estar vacío.");
                    return;
                }
                if ($("#contra").val().trim() === '' && $("#campo").val() === 'guardar') {
                    alert("La contraseña no puede estar vacía.");
                    return;
                }

                datosform = $("#form").serialize();
                $.ajax({
                    data: datosform,
                    url: '../controles/Usuarios.jsp',
                    type: 'post',
                    beforeSend: function () {
                    },
                    success: function (response) {
                        const trimmedResponse = response.trim();
                        if (trimmedResponse === "usuario_existe") {
                            alert("Error: Ya existe un usuario con ese nombre de USUARIO.");
                        } else if (trimmedResponse === "nombre_existe") {
                            alert("Error: Ya existe un usuario con ese NOMBRE.");
                        } else if (trimmedResponse === "error_bd") {
                            alert("Ocurrió un error en la base de datos al intentar guardar/modificar el usuario.");
                        } else { 
                            $("#cerrar").click(); 
                            rellenar(); 
                        }
                    },
                    error: function(jqXHR, textStatus, errorThrown) {
                        console.error("Error al comunicarse con el servidor:", textStatus, errorThrown, jqXHR.responseText);
                        alert("Error de comunicación con el servidor. Por favor, intente de nuevo más tarde.");
                    }
                });
            });

            function datosModif(id, nombre, usuario, contra) {
                $("#pk").val(id);
                $("#nombre").val(nombre);
                $("#usuario").val(usuario);
                $("#contra").val(contra);
                $("#campo").val("modificar");
                $('#exampleModal').modal('show'); 
            }

            function nuevoRegistro() {
                $("#form")[0].reset();
                $("#campo").val("guardar");
                $("#pk").val("");
            }

            function dell(id) {
                idClienteEliminar = id; 
                $('#confirmarEliminarModal').modal('show');
            }

            $("#confirmarEliminarBtn").click(function () {
                if (idClienteEliminar !== null) {
                    $.ajax({
                        url: '../controles/Usuarios.jsp',
                        type: 'GET',
                        data: {campo: 'eliminar', pk: idClienteEliminar},
                        success: function (response) {
                            const trimmedResponse = response.trim();
                            if (trimmedResponse === "exito") {
                                $('#confirmarEliminarModal').modal('hide');
                                rellenar();
                                idClienteEliminar = null;
                            } else {
                                alert('Error al eliminar el usuario.');
                            }
                        },
                        error: function () {
                            alert('Error de comunicación al intentar eliminar el usuario.');
                        }
                    });
                }
            });
        </script>
        </div>
    </main>
</div>
<%@include file="footer.jsp" %>