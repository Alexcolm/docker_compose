<!doctype html>
<html lang="en">
    <%@ include file="header.jsp" %>
    <div class="app-content">
        <div class="botones"  style="display: flex; justify-content: center; align-items: center; padding: 10px;">
            <button type="button" class="Modal btn btn-success" data-toggle="modal" data-target="#exampleModal" onclick="nuevoRegistro()">
                Agregar Clientes
            </button>
        </div>
        <table class="table client">
            <thead class="thead-light">
                <tr>
                    <th scope="col">ID</th> <%-- Agregué la columna ID --%>
                    <th scope="col">Nombre De la Empresa</th>
                    <th scope="col">RUC</th>
                    <th scope="col">Nombre del Contacto</th>
                    <th scope="col">Telefono</th>
                    <th scope="col">Correo electrónico</th>
                    <th scope="col">Fecha de registro</th>
                    <th scope="col"></th>
                </tr>
            </thead>
            <tbody id="listadoclientes">

            </tbody >
        </table>
        <div class="modal fade" id="exampleModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="exampleModalLabel">Agregar Cliente</h5>
                    </div>
                    <div class="modal-body">
                        <form id="form" name="form">
                            <div class="form-group ">
                                <input type="hidden" class="form-control" name="campo" id="campo" value="guardar">
                                <input type="hidden" class="form-control" name="pk" id="pk" value="">
                                <h6>Nombre de la empresa</h6>
                                <input type="text" class="form-control modal-form" name="Empresa" id="Empresa" required>
                                <h6>RUC</h6>
                                <input type="text" class="form-control modal-form" name="RUC" id="RUC" required>
                                <h6>Nombre del contacto</h6>
                                <input type="text" class="form-control modal-form" name="contacto" id="contacto" required>
                                <h6>Telefono</h6>
                                <input type="text" class="form-control modal-form" name="telefono" id="telefono" required>
                                <h6>Correo electronico</h6>
                                <input type="email" class="form-control modal-form" name="correo" id="correo" required> <%-- type="email" para validación básica de HTML5 --%>
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
                        <h5 class="modal-title" id="confirmarEliminarModalLabel">Confirmar Eliminación</h5> <%-- Cambié el título --%>
                    </div>

                    <div class="modal-body">
                        ¿Estás seguro de que deseas eliminar este cliente?
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
                // Resetear el formulario al cerrar el modal con el botón "Cerrar"
                $("#cerrar").click(function() {
                    nuevoRegistro(); // Llama a la función que resetea el formulario
                    $('#exampleModal').modal('hide'); // Asegura que el modal se cierre
                });
            });

            function rellenar() {
                $.get("../controles/Clientes_control.jsp", {campo: 'listar'}, function (data) {
                    $("#listadoclientes").html(data);
                });
            }

            $("#guardarRegistro").click(function () {
                // Validación básica de campos vacíos en el cliente
                const empresa = $("#Empresa").val().trim();
                const ruc = $("#RUC").val().trim();
                const contacto = $("#contacto").val().trim();
                const telefono = $("#telefono").val().trim();
                const correo = $("#correo").val().trim();

                if (empresa === '' || ruc === '' || contacto === '' || telefono === '' || correo === '') {
                    alert("Por favor, complete todos los campos obligatorios.");
                    return;
                }

                // Validación simple de formato de email (el input type="email" ya ayuda)
                if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(correo)) {
                    alert("Por favor, introduce un correo electrónico válido.");
                    return;
                }

                const datosform = $("#form").serialize();
                $.ajax({
                    data: datosform,
                    url: '../controles/Clientes_control.jsp',
                    type: 'post', // Asegurarse de que coincida con el controlador
                    beforeSend: function () {
                        // Opcional: mostrar un spinner o mensaje de carga
                    },
                    success: function (response) {
                        const trimmedResponse = response.trim(); // Limpiar la respuesta

                        if (trimmedResponse === "empresa_existe") {
                            alert("Error: Ya existe un cliente con ese NOMBRE DE EMPRESA.");
                        } else if (trimmedResponse === "ruc_existe") {
                            alert("Error: Ya existe un cliente con ese RUC.");
                        } else if (trimmedResponse === "telefono_existe") {
                            alert("Error: Ya existe un cliente con ese NÚMERO DE TELÉFONO.");
                        } else if (trimmedResponse === "correo_existe") {
                            alert("Error: Ya existe un cliente con ese CORREO ELECTRÓNICO.");
                        } else if (trimmedResponse === "error_bd") {
                            alert("Ocurrió un error en la base de datos al intentar guardar/modificar el cliente.");
                        } else if (trimmedResponse === "error_formato_id") {
                            alert("Error de formato en el ID del cliente. Por favor, contacte a soporte.");
                        } else if (trimmedResponse === "error_inesperado") {
                            alert("Ocurrió un error inesperado. Por favor, intente de nuevo o contacte a soporte.");
                        } else if (trimmedResponse === "exito") { // Cambiado de "success" a "exito"
                            $('#exampleModal').modal('hide');
                            rellenar();
                            nuevoRegistro(); // Resetear el formulario después de guardar/modificar con éxito
                        } else {
                            alert("Respuesta inesperada del servidor: " + response);
                            console.log("Respuesta completa del servidor:", response);
                        }
                    },
                    error: function(jqXHR, textStatus, errorThrown) {
                        console.error("Error de comunicación con el servidor:", textStatus, errorThrown, jqXHR.responseText);
                        alert("Error de comunicación con el servidor. Por favor, intente de nuevo más tarde.");
                    }
                });
            });

            function datosModif(id, empresa, ruc, contacto, telefono, correo) {
                $("#pk").val(id);
                $("#Empresa").val(empresa);
                $("#RUC").val(ruc);
                $("#contacto").val(contacto);
                $("#telefono").val(telefono);
                $("#correo").val(correo);
                $("#campo").val("modificar");
                $('#exampleModal').modal('show'); // Abrir el modal para edición
            }

            function nuevoRegistro() {
                $("#form")[0].reset(); // Resetea todos los campos del formulario
                $("#campo").val("guardar"); // Asegura que el campo oculto "campo" sea "guardar"
                $("#pk").val(""); // Limpia el pk
            }

            function dell(id) {
                idClienteEliminar = id;
                $('#confirmarEliminarModal').modal('show');
            }

            $("#confirmarEliminarBtn").click(function () {
                if (idClienteEliminar !== null) {
                    $.ajax({
                        url: '../controles/Clientes_control.jsp',
                        type: 'GET', // La eliminación se puede hacer por GET o POST, asegúrate de que el controlador lo acepte
                        data: {campo: 'eliminar', pk: idClienteEliminar},
                        success: function (response) {
                            const trimmedResponse = response.trim();
                            if (trimmedResponse === "exito") { // Cambiado de "success" a "exito"
                                $('#confirmarEliminarModal').modal('hide');
                                rellenar();
                                idClienteEliminar = null;
                            } else if (trimmedResponse === "no_encontrado") {
                                alert("El cliente que intentas eliminar no fue encontrado.");
                            } else if (trimmedResponse === "error_bd") {
                                alert("Ocurrió un error en la base de datos al intentar eliminar el cliente.");
                            } else {
                                alert('Error al eliminar el cliente: ' + response);
                            }
                        },
                        error: function (jqXHR, textStatus, errorThrown) {
                            console.error("Error de comunicación al intentar eliminar el cliente:", textStatus, errorThrown, jqXHR.responseText);
                            alert('Error de comunicación al intentar eliminar el cliente.');
                        }
                    });
                }
            });
        </script>
        </div>
    </main>
</div>
<%@ include file="footer.jsp" %>