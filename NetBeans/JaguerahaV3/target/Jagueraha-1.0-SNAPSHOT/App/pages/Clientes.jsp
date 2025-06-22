<!doctype html>
<html lang="en">
  <%@ include file="header.jsp" %>
        <div class="app-content">
          <!--begin::Container-->
          <div class="botones"  style="display: flex; justify-content: center; align-items: center; padding: 10px;">
              <button type="button" class="Moda btn btn-success" data-toggle="modal" data-target="#exampleModal" onclick="nuevoRegistro()">
            Agregar Clientes
        </button>
        </div>
        <table class="table client">
            <thead class="thead-light">
                <tr>
                    <th scope="col"></th>
                    <th scope="col">Nombre De la Empresa</th>
                    <th scope="col">RUC</th>
                    <th scope="col">Nombre del Contacto</th>
                    <th scope="col">Telefono</th>
                    <th scope="col">Correo electronico</th>
                    <th scope="col">Direccion</th>
                    <th scope="col">Ciudad</th>
                    <th scope="col">Tipo de combustible</th>
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
                                <input type="text" class="form-control modal-form" name="Empresa" id="Empresa" placeholder="Nombre de la empresa">
                                <input type="text" class="form-control modal-form" name="RUC" id="RUC" placeholder="RUC">
                                <input type="text" class="form-control modal-form" name="contacto" id="contacto" placeholder="Nombre del contacto">
                                <input type="text" class="form-control modal-form" name="telefono" id="telefono" placeholder="Telefono">
                                <input type="text" class="form-control modal-form" name="correo" id="correo" placeholder="Correo electrÃ³nico">
                                <input type="text" class="form-control modal-form" name="direccion" id="direccion" placeholder="Direccion">
                                <input type="text" class="form-control modal-form" name="ciudad" id="ciudad" placeholder="Ciudad">
                                <input type="text" class="form-control modal-form" name="tipo_combustible" id="tipo_combustible" placeholder="Tipo de combustible">
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
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
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
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
        <script>
            $(document).ready(function () {
                rellenar();
            });
            function rellenar() {
                $.get("../controles/clientes.jsp", {campo: 'listar'}, function (data) {
                    $("#listadoclientes").html(data);
                });
            }
            $("#guardarRegistro").click(function () {
                datosform = $("#form").serialize();
                $.ajax({
                    data: datosform,
                    url: '../controles/clientes.jsp',
                    type: 'post',
                    beforeSend: function () {
                        $("#resultado").html("Procesando, espere por favor...");
                    },
                    success: function (response) {
                        $("#cerrar").click();
                        rellenar();
                        $("#campo").val('');
                        $("#Empresa").val('');
                        $("#RUC").val('');
                        $("#contacto").val('');
                        $("#telefono").val('');
                        $("#correo").val('');
                        $("#direccion").val('');
                        $("#ciudad").val('');
                        $("#tipo_combustible").val('');
                        $("#fecha").val('');
                    }
                });
            });
             function datosModif(a, b, c, d, e, f, g, h, i, j) {
                $("#pk").val(a);
                $("#Empresa").val(b);
                $("#RUC").val(c);
                $("#contacto").val(d);
                $("#telefono").val(e);
                $("#correo").val(f);
                $("#direccion").val(g);
                $("#ciudad").val(h);
                $("#tipo_combustible").val(i);
                $("#campo").val("modificar");
            }
            function nuevoRegistro() {
                $("#form")[0].reset(); 
                $("#campo").val("guardar");
                $("#pk").val(""); 
            }

            var idClienteEliminar = null;


            function dell(a) {
                idClienteEliminar = a;
                $('#confirmarEliminarModal').modal('show');
            }

            $("#confirmarEliminarBtn").click(function () {
                if (idClienteEliminar !== null) {
                    $.ajax({
                        url: '../controles/clientes.jsp',
                        type: 'GET',
                        data: { campo: 'eliminar', pk: idClienteEliminar },
                        success: function (data) {
                            $('#confirmarEliminarModal').modal('hide'); 
                            rellenar(); 
                            idClienteEliminar = null; 
                        },
                            error: function () {
                            alert('Error al eliminar el cliente.');
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
    <!--end::App Wrapper-->
    <!--begin::Script-->
    <!--begin::Third Party Plugin(OverlayScrollbars)-->
<%@ include file="footer.jsp" %>
