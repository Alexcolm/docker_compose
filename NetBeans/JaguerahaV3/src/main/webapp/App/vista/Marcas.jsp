<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <%@include file="header.jsp" %>
    <div class="botones" style="display: flex; justify-content: center; align-items: center; padding: 10px;">
        <button type="button" class="Modal btn btn-success" data-toggle="modal" data-target="#exampleModal" onclick="nuevoRegistro()">
            Agregar Marca
        </button>
    </div>
    <table class="table client">
        <thead class="thead-light">
            <tr>
                <th scope="col">ID</th> <%-- Added ID column for clarity --%>
                <th scope="col">Nombre De la Marca</th>
                <th scope="col">Acciones</th> <%-- Renamed for clarity --%>
            </tr>
        </thead>
        <tbody id="listadomarcas">

        </tbody >
    </table>
    <div class="modal fade" id="exampleModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLabel">Agregar/Modificar Marca</h5> <%-- Title change --%>
                </div>
                <div class="modal-body">
                    <form id="form" name="form">
                        <div class="form-group ">
                            <input type="hidden" class="form-control" name="campo" id="campo" value="guardar">
                            <input type="hidden" class="form-control" name="pk" id="pk" value="">
                            <h6>Nombre de la marca</h6>
                            <input type="text" class="form-control modal-form" name="marca" id="marca" required>
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
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    ¿Estás seguro de que deseas eliminar esta Marca?
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                    <button type="button" class="btn btn-danger" id="confirmarEliminarBtn">Eliminar</button> <%-- Changed to btn-danger --%>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script>
        var idMarcaEliminar = null; // Changed variable name for clarity

        $(document).ready(function () {
            rellenar();
            // Reset form on modal close
            $("#cerrar, #closeModalButton").click(function() {
                nuevoRegistro(); // Use the reset function
            });
        });

        function rellenar() {
            $.get("../controles/Marca.jsp", {campo: 'listar'}, function (data) {
                $("#listadomarcas").html(data);
            });
        }

        $("#guardarRegistro").click(function () {
            var marcaNombre = $("#marca").val().trim(); // Get and trim the input

            if (marcaNombre === '') {
                alert("El nombre de la marca no puede estar vacío.");
                return; // Stop the function if validation fails
            }

            datosform = $("#form").serialize();
            $.ajax({
                data: datosform,
                url: '../controles/Marca.jsp',
                type: 'post',
                beforeSend: function () {
                    // Consider adding a loading indicator here
                },
                success: function (response) {
                    const trimmedResponse = response.trim(); // Trim whitespace from response
                    if (trimmedResponse === "marca_existe") {
                        alert("Error: Ya existe una marca con ese nombre.");
                    } else if (trimmedResponse === "campos_vacios") {
                        alert("Error: El nombre de la marca no puede estar vacío.");
                    } else if (trimmedResponse === "error_bd") {
                        alert("Ocurrió un error en la base de datos al intentar guardar/modificar la marca.");
                    } else if (trimmedResponse === "exito") {
                        $("#cerrar").click(); // Close the modal
                        rellenar(); // Reload the list
                        // The form is reset by nuevoRegistro() when modal closes
                    } else {
                        alert("Respuesta inesperada del servidor: " + response);
                        console.log("Respuesta completa del servidor:", response);
                    }
                },
                error: function(jqXHR, textStatus, errorThrown) {
                    console.error("Error de comunicación:", textStatus, errorThrown, jqXHR.responseText);
                    alert("Ocurrió un error de comunicación con el servidor.");
                }
            });
        });

        function datosModif(id, nombreMarca) {
            $("#pk").val(id);
            $("#marca").val(nombreMarca);
            $("#campo").val("modificar");
            $("#exampleModalLabel").text("Modificar Marca"); // Change modal title
            $('#exampleModal').modal('show'); // Open the modal
        }

        function nuevoRegistro() {
            $("#form")[0].reset(); // Resets all form fields
            $("#campo").val("guardar"); // Ensure 'campo' is set to 'guardar'
            $("#pk").val(""); // Clear primary key
            $("#exampleModalLabel").text("Agregar Marca"); // Reset modal title
        }

        function dell(id) {
            idMarcaEliminar = id; // Store the ID to be deleted
            $('#confirmarEliminarModal').modal('show'); // Show confirmation modal
        }

        $("#confirmarEliminarBtn").click(function () {
            if (idMarcaEliminar !== null) {
                $.ajax({
                    url: '../controles/Marca.jsp',
                    type: 'GET', // Using GET for deletion as per your original code
                    data: {campo: 'eliminar', pk: idMarcaEliminar},
                    success: function (response) {
                        const trimmedResponse = response.trim();
                        if (trimmedResponse === "exito") {
                            $('#confirmarEliminarModal').modal('hide'); // Hide confirmation modal
                            rellenar(); // Reload the list
                            idMarcaEliminar = null; // Reset the stored ID
                        } else if (trimmedResponse === "marca_con_modelos") {
                            alert("No se puede eliminar la marca porque tiene modelos asociados.");
                        } else if (trimmedResponse === "no_encontrado") {
                            alert("La marca que intenta eliminar no fue encontrada.");
                        } else if (trimmedResponse === "error_bd") {
                            alert("Ocurrió un error en la base de datos al intentar eliminar la marca.");
                        } else {
                            alert('Error al eliminar la marca: ' + response);
                            console.log("Respuesta completa del servidor:", response);
                        }
                    },
                    error: function (jqXHR, textStatus, errorThrown) {
                        console.error("Error de comunicación al intentar eliminar:", textStatus, errorThrown, jqXHR.responseText);
                        alert('Error de comunicación con el servidor al intentar eliminar la marca.');
                    }
                });
            }
        });
    </script>
</div>
</main>
</div>
<%@include file="footer.jsp" %>