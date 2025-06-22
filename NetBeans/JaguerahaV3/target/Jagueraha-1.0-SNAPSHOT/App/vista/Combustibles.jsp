<!doctype html>
<html lang="en">
    <%@ include file="header.jsp" %>
    <div class="app-content">
        <div class="botones" style="display: flex; justify-content: center; align-items: center; padding: 10px;">
            <button type="button" class="Modal btn btn-success" data-toggle="modal" data-target="#combustibleModal" onclick="nuevoCombustible()">
                Agregar Combustible
            </button>
        </div>
        <table class="table client">
            <thead class="thead-light">
                <tr>
                    <th scope="col">ID Combustible</th>
                    <th scope="col">Nombre</th>
                    <th scope="col">Precio por Litro</th>
                    <th scope="col"></th>
                </tr>
            </thead>
            <tbody id="listadocombustibles">

            </tbody >
        </table>

        <div class="modal fade" id="combustibleModal" tabindex="-1" aria-labelledby="combustibleModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="combustibleModalLabel">Agregar Combustible</h5>
                    </div>
                    <div class="modal-body">
                        <form id="formCombustible" name="formCombustible">
                            <div class="form-group">
                                <input type="hidden" class="form-control" name="campo" id="campoCombustible" value="guardar">
                                <input type="hidden" class="form-control" name="pk" id="pkCombustible" value="">

                                <label for="nombreCombustible">Nombre del Combustible</label>
                                <input type="text" class="form-control modal-form" name="nombreCombustible" id="nombreCombustible" required>

                                <label for="precioLitro">Precio por Litro</label>
                                <input type="number" step="0.01" class="form-control modal-form" name="precioLitro" id="precioLitro" required>
                            </div>
                            <div class="modal-footer">
                                <button type="button" id="cerrarCombustibleModal" class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
                                <button type="button" class="btn btn-primary" id="guardarCombustible">Guardar</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <div class="modal fade" id="confirmarEliminarCombustibleModal" tabindex="-1" aria-labelledby="confirmarEliminarCombustibleModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="confirmarEliminarCombustibleModalLabel">Confirmar Eliminación de Combustible</h5>
                    </div>
                    <div class="modal-body">
                        ¿Estás seguro de que deseas eliminar este Combustible?
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                        <button type="button" class="btn btn-success" id="confirmarEliminarCombustibleBtn">Eliminar</button>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
        <script>
            var idCombustibleEliminar = null;

            $(document).ready(function () {
                rellenarCombustibles();

                $("#cerrarCombustibleModal").click(function () {
                    $("#formCombustible")[0].reset();
                    $("#campoCombustible").val("guardar");
                    $("#pkCombustible").val("");
                    $("#combustibleModalLabel").text("Agregar Combustible");
                });
            });

            function rellenarCombustibles() {
                $.get("../controles/Combustible_control.jsp", {campo: 'listar'}, function (data) {
                    $("#listadocombustibles").html(data);
                });
            }

            $("#guardarCombustible").click(function () {
                // Validación básica de campos vacíos en el cliente
                const nombreCombustible = $("#nombreCombustible").val().trim();
                const precioLitro = $("#precioLitro").val().trim();

                if (nombreCombustible === '') {
                    alert("El nombre del combustible no puede estar vacío.");
                    return;
                }
                if (precioLitro === '') {
                    alert("El precio por litro no puede estar vacío.");
                    return;
                }
                if (isNaN(precioLitro) || parseFloat(precioLitro) < 0) {
                    alert("El precio por litro debe ser un número válido y no negativo.");
                    return;
                }

                datosform = $("#formCombustible").serialize();
                $.ajax({
                    data: datosform,
                    url: '../controles/Combustible_control.jsp',
                    type: 'post',
                    beforeSend: function () {
                        // Opcional: mostrar un spinner o mensaje de carga
                    },
                    success: function (response) {
                        const trimmedResponse = response.trim(); // Eliminar espacios en blanco
                        if (trimmedResponse === "nombre_existe") {
                            alert("Error: Ya existe un combustible con ese nombre.");
                        } else if (trimmedResponse === "error_bd") {
                            alert("Ocurrió un error en la base de datos al intentar guardar/modificar el combustible.");
                        } else if (trimmedResponse === "error_formato_precio") {
                            alert("Error: El formato del precio por litro no es válido.");
                        } else if (trimmedResponse === "exito") { // Asumir éxito si la respuesta es "exito"
                            $("#cerrarCombustibleModal").click(); // Cierra el modal y resetea el formulario
                            rellenarCombustibles(); // Recarga la tabla de combustibles
                        } else {
                            // En caso de una respuesta inesperada del servidor
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

            function datosModifCombustible(pk, nombre, precio) {
                $("#pkCombustible").val(pk);
                $("#nombreCombustible").val(nombre);
                $("#precioLitro").val(precio);
                $("#campoCombustible").val("modificar");
                $("#combustibleModalLabel").text("Modificar Combustible");
                $('#combustibleModal').modal('show');
            }

            function nuevoCombustible() {
                $("#formCombustible")[0].reset();
                $("#campoCombustible").val("guardar");
                $("#pkCombustible").val("");
                $("#combustibleModalLabel").text("Agregar Combustible");
            }

            function dellCombustible(id) {
                idCombustibleEliminar = id;
                $('#confirmarEliminarCombustibleModal').modal('show');
            }

            $("#confirmarEliminarCombustibleBtn").click(function () {
                if (idCombustibleEliminar !== null) {
                    $.ajax({
                        url: '../controles/Combustible_control.jsp',
                        type: 'GET',
                        data: {campo: 'eliminar', pk: idCombustibleEliminar},
                        success: function (response) {
                            const trimmedResponse = response.trim();
                            if (trimmedResponse === "exito") {
                                $('#confirmarEliminarCombustibleModal').modal('hide');
                                rellenarCombustibles();
                                idCombustibleEliminar = null;
                            } else if (trimmedResponse === "no_encontrado") {
                                alert("El combustible que intentas eliminar no fue encontrado.");
                            } else if (trimmedResponse === "error_bd") {
                                alert("Ocurrió un error en la base de datos al intentar eliminar el combustible.");
                            } else {
                                alert('Error al eliminar el combustible: ' + response);
                            }
                        },
                        error: function () {
                            alert('Error de comunicación al intentar eliminar el combustible.');
                        }
                    });
                }
            });
        </script>
    </div>
</main>
</div>
<%@ include file="footer.jsp" %>