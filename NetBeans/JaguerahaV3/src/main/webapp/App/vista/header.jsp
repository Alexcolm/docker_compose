<%@page contentType="text/html" pageEncoding="UTF-8"%>
<head>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>JAGUERAHA | Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="title" content="AdminLTE v4 | Dashboard" />
    <meta name="author" content="ColorlibHQ" />
    <meta
        name="description"
        content="AdminLTE is a Free Bootstrap 5 Admin Dashboard, 30 example pages using Vanilla JS."
        />
    <meta
        name="keywords"
        content="bootstrap 5, bootstrap, bootstrap 5 admin dashboard, bootstrap 5 dashboard, bootstrap 5 charts, bootstrap 5 calendar, bootstrap 5 datepicker, bootstrap 5 tables, bootstrap 5 datatable, vanilla js datatable, colorlibhq, colorlibhq dashboard, colorlibhq admin dashboard"
        />
    <!--end::Primary Meta Tags-->
    <!--begin::Fonts-->
    <link
        rel="stylesheet"
        href="https://cdn.jsdelivr.net/npm/@fontsource/source-sans-3@5.0.12/index.css"
        integrity="sha256-tXJfXfp6Ewt1ilPzLDtQnJV4hclT9XuaZUKyUvmyr+Q="
        crossorigin="anonymous"
        />
    <!--end::Fonts-->
    <!--begin::Third Party Plugin(OverlayScrollbars)-->
    <link
        rel="stylesheet"
        href="https://cdn.jsdelivr.net/npm/overlayscrollbars@2.10.1/styles/overlayscrollbars.min.css"
        integrity="sha256-tZHrRjVqNSRyWg2wbppGnT833E/Ys0DHWGwT04GiqQg="
        crossorigin="anonymous"
        />
    <!--end::Third Party Plugin(OverlayScrollbars)-->
    <!--begin::Third Party Plugin(Bootstrap Icons)-->
    <link
        rel="stylesheet"
        href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
        integrity="sha256-9kPW/n5nn53j4WMRYAxe9c1rCY96Oogo/MKSVdKzPmI="
        crossorigin="anonymous"
        />
    <!--end::Third Party Plugin(Bootstrap Icons)-->
    <!--begin::Required Plugin(AdminLTE)-->
    <link rel="stylesheet" href="../css/adminlte.css" />
    <!--end::Required Plugin(AdminLTE)-->
    <!-- apexcharts -->
    <link
        rel="stylesheet"
        href="https://cdn.jsdelivr.net/npm/apexcharts@3.37.1/dist/apexcharts.css"
        integrity="sha256-4MX+61mt9NVvvuPjUWdUdyfZfxSB1/Rf9WtqRHgG5S0="
        crossorigin="anonymous"
        />
    <!-- jsvectormap -->
    <link
        rel="stylesheet"
        href="https://cdn.jsdelivr.net/npm/jsvectormap@1.5.3/dist/css/jsvectormap.min.css"
        integrity="sha256-+uGLJmmTKOqBr+2E6KDYs/NRsHxSkONXFHUL0fy2O/4="
        crossorigin="anonymous"
        />
</head>
<!--end::Head-->
<!--begin::Body-->
<body class="layout-fixed sidebar-expand-lg bg-body-tertiary">
    <!--begin::App Wrapper-->
    <div class="app-wrapper">
        <aside class="app-sidebar shadow" data-bs-theme="dark" style="background-color: #0EA57B;">
            <!--begin::Sidebar Brand-->
            <div class="sidebar-brand">
                <!--begin::Brand Link-->
                <a href="#" class="brand-link">
                    <!--begin::Brand Image-->
                    <img
                        src="../assets/output-onlinepngtools.png"
                        alt="JAGUERAHA Logo"
                        class="brand-image"
                        />
                    <!--end::Brand Image-->
                    <!--begin::Brand Text-->
                    <span class="brand-text fw-light" style="font-size: 30px;">JAGUERAHA</span>
                    <!--end::Brand Text-->
                </a>
                <!--end::Brand Link-->
            </div>
            <!--end::Sidebar Brand-->
            <!--begin::Sidebar Wrapper-->
            <div class="sidebar-wrapper">
                <nav class="mt-2">
                    <!--begin::Sidebar Menu-->
                    <ul
                        class="nav sidebar-menu flex-column"
                        data-lte-toggle="treeview"
                        role="menu"
                        data-accordion="false"
                        >
                        <li class="nav-item menu-open">
                            <a href="#" class="nav-link active">
                                <i class="nav-icon bi bi-speedometer"></i>
                                <p>
                                    Gestion de Datos
                                    <i class="nav-arrow bi bi-chevron-right"></i>
                                </p>
                            </a>
                            <ul class="nav nav-treeview">
                                <li class="nav-item">
                                    <a href="./Clientes.jsp" class="nav-link ">
                                        <p>Clientes</p>
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a href="./Usuarios.jsp" class="nav-link">
                                        <p>Usuarios</p>
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a href="./Personales.jsp" class="nav-link">
                                        <p>Personales</p>
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a href="./Vehiculos.jsp" class="nav-link">
                                        <p>Vehiculos</p>
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a href="./Marcas.jsp" class="nav-link">
                                        <p>Marcas de los vehiculos</p>
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a href="./Modelos.jsp" class="nav-link">
                                        <p>Modelos de los Vehiculos</p>
                                    </a>
                                </li>
                                 <li class="nav-item">
                                    <a href="./Mantenimientos.jsp" class="nav-link">
                                        <p>Mantenimiento de Vehiculos</p>
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a href="./Combustibles.jsp" class="nav-link">
                                        <p>Tipos de combustible</p>
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a href="./Ciudades.jsp" class="nav-link">
                                        <p>Ciudades</p>
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a href="./Pedidos.jsp" class="nav-link">
                                        <p>Pedidos</p>
                                    </a>
                                </li>
                            </ul>
                        </li>
                        <li class="nav-item">
                            <a href="./UI/icons.html" class="nav-link">
                                <i class="nav-icon bi bi-pencil-square"></i>
                                <p>Facturacion</p>
                            </a>
                        </li>
                        <!--end::Sidebar Menu-->
                </nav>
            </div>
            <!--end::Sidebar Wrapper-->
        </aside>
        <!--end::Sidebar-->
        <!--begin::App Main-->
        <main class="app-main">
            <!--begin::App Content Header-->
            <div class="app-content-header">
                <!--begin::Container-->
                <div class="container-fluid">
                    <!--begin::Row-->
                    <div class="row">
                        <div class="col-sm-6"><h3 class="mb-0">Panel de Control</h3></div>
                        <div class="col-sm-6">
                        </div>
                    </div>
                    <!--end::Row-->
                </div>
                <!--end::Container-->
            </div>
