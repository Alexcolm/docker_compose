-- creando base de datos jagueraha
CREATE DATABASE jagueraha;

\connect jagueraha

-- Crear tabla de ciudades
create table ciudades (
    id serial primary key,
    nombre varchar(30) not null unique
);

create unique index unique_ciudad_lowercase on ciudades(lower(nombre));

-- Crear tabla de combustibles
create table combustibles (
    id_combustible serial primary key,
    nombre varchar(50) not null unique,
    precio_litro decimal(10,2) not null
);

create unique index unique_combustible_lowercase on combustibles(lower(nombre));

-- Crear tabla de marcas
create table marcas (
    id serial primary key,
    nombre varchar(30) not null unique
);

create unique index unique_marca_lowercase on marcas(lower(nombre));

-- Crear tabla de modelos
create table modelos (
    id serial primary key,
    nombre varchar(30) not null unique,
    num_puertas varchar(6) not null,
    num_plazas varchar(30) not null,
    id_marca int references marcas(id)
);

create unique index unique_modelo_lowercase on modelos(lower(nombre));

-- Crear tabla de vehículos
create table vehiculos (
    id serial primary key,
    descripcion varchar(180) unique,
    color varchar(30) not null,
    chapa varchar(30) not null unique, 
    capacidad_litros varchar(20) not null unique,
    id_modelo int references modelos(id),
    id_marca int references marcas(id)
);

create unique index unique_chapa_lowercase on vehiculos(lower(chapa));

-- Crear tabla de mantenimientos
create table mantenimientos (
    id_mantenimiento serial primary key,
    id_vehiculo int not null unique references vehiculos(id),
    fecha_mantenimiento date not null,
    kilometraje decimal(10,2) not null,
    tipo_mantenimiento varchar(100) not null,
    descripcion text,
    costo decimal(10,2) not null,
    taller_responsable varchar(150) not null,
    proximo_servicio decimal(10,2)
);

-- Crear tabla de usuarios
create table usuarios (
    id serial primary key,
    nombre varchar(30) not null,
    usuario varchar(30) not null unique,
    contrasena varchar(30) not null unique,
    fecha_registro timestamp default current_timestamp
);

create unique index unique_usuario_lowercase on usuarios(lower(usuario));

-- Crear tabla de puesto
create table puesto (
    id serial primary key,
    rol varchar(15) not null unique
);

-- Crear tabla de personales
create table personales (
    id serial primary key,
    cedula int not null unique,
    nombre_completo varchar(50) not null,
    cargo varchar(30) not null,
    telefono varchar(30) not null unique,
    estado varchar(30) not null,
    correo varchar(30) not null unique,
    fecha_registro timestamp default current_timestamp
);

create unique index unique_correo_lowercase on personales(lower(correo));

-- Crear tabla de cliente
create table cliente (
    id_cliente serial primary key,
    nombre_empresa varchar(100) not null unique,
    ruc varchar(20) not null unique,
    nombre_contacto varchar(100) not null,
    telefono_contacto varchar(20) not null unique,
    email_contacto varchar(100) not null unique,
    fecha_registro timestamp default current_timestamp
);

create unique index unique_empresa_lowercase on cliente(lower(nombre_empresa));
create unique index unique_ruc_lowercase on cliente(lower(ruc));

-- Crear tabla de pedidos
create table pedidos (
    id_pedido serial primary key,
    id_cliente int references cliente(id_cliente),
    id_combustible int references combustibles(id_combustible),
    id_ciudad int references ciudades(id),
    cantidad_litros decimal(10,2) not null,
    direccion_entrega text not null,
    ciudad_entrega varchar(50),
    fecha_pedido timestamp default current_timestamp not null,
    estado varchar(30) default 'pendiente' not null
);

