<!doctype html>
<html lang="en">
  <%@include file="header.jsp" %>
        <div class="app-content">
          <!--begin::Container-->
        <div class="botones" style="display: flex; justify-content: center; align-items: center; padding: 10px;">
            <button type="button" class="Modal btn btn-success" data-toggle="modal" data-target="#exampleModal" onclick="nuevoRegistro()">
            Agregar Vehiculo
        </button>
        </div>
        <table class="table client">
            <thead class="thead-light">
                <tr>
                    <th scope="col"></th>
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
                                <input type="text" class="form-control modal-form" name="marca" id="marca" placeholder="Marca">
                                <input type="text" class="form-control modal-form" name="modelo" id="modelo" placeholder="Modelo">
                                <input type="text" class="form-control modal-form" name="descripcion" id="descripcion" placeholder="Descripcion">
                                <input type="text" class="form-control modal-form" name="color" id="color" placeholder="Color">
                                <input type="text" class="form-control modal-form" name="chapa" id="chapa" placeholder="Chapa">
                                <input type="text" class="form-control modal-form" name="capacidad" id="capacidad" placeholder="Capacidad del tanque">
                                
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
                    ¿Estás seguro de que deseas eliminar este Vehiculo?
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
                $("#cerrar").click(function () {
                    $("#form")[0].reset();
                    $("#campo").val("guardar"); 
});
            });
            function rellenar() {
                $.get("../controles/Vehiculos.jsp", {campo: 'listar'}, function (data) {
                    $("#listadovehiculos").html(data);
                });
            }
            $("#guardarRegistro").click(function () {
                datosform = $("#form").serialize();
                $.ajax({
                    data: datosform,
                    url: '../controles/Vehiculos.jsp',
                    type: 'post',
                    beforeSend: function () {
                        $("#resultado").html("Procesando, espere por favor...");
                    },
                    success: function (response) {
                        $("#cerrar").click();
                        rellenar();
                        $("#marca").val('');
                        $("#modelo").val('');
                        $("#descripcion").val('');
                        $("#color").val('');
                        $("#chapa").val('');
                        $("#capacidad").val('');
                    }
                });
            });
             function datosModif(a, b, c, d, e, f, g) {
                $("#pk").val(a);
                $("#marca").val(b);
                $("#modelo").val(c);
                $("#descripcion").val(d);
                $("#color").val(e);
                $("#chapa").val(f);
                $("#capacidad").val(g);
                $("#campo").val("modificar");
            }
            
            function nuevoRegistro() {
                $("#form")[0].reset(); // Limpia todos los campos del formulario
                $("#campo").val("guardar");
                $("#pk").val(""); // Por si quedó algún ID viejo
}
           var idClienteEliminar = null;


            function dell(a) {
                idClienteEliminar = a;
                $('#confirmarEliminarModal').modal('show');
            }

            $("#confirmarEliminarBtn").click(function () {
                if (idClienteEliminar !== null) {
                    $.ajax({
                        url: '../controles/Vehiculos.jsp',
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
    <%@include file="footer.jsp" %>