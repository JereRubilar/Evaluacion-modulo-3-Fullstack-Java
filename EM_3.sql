CREATE SCHEMA clinica_veterinaria;

USE clinica_veterinaria;

CREATE TABLE dueño (
	id_dueño INT AUTO_INCREMENT,
    nombre VARCHAR(100),
    direccion VARCHAR(200),
    telefono VARCHAR(20),
    PRIMARY KEY (id_dueño)
);

CREATE TABLE mascota (
	id_mascota INT AUTO_INCREMENT,
    nombre VARCHAR(100),
    especie VARCHAR(50),
    fecha_nacimiento DATE,
    id_dueño INT,
    PRIMARY KEY (id_mascota),
    FOREIGN KEY (id_dueño) REFERENCES dueño(id_dueño)
);

CREATE TABLE profesional (
	id_profesional INT AUTO_INCREMENT,
    nombre VARCHAR(100),
    especialidad VARCHAR(100),
    PRIMARY KEY (id_profesional)
);

CREATE TABLE atencion (
	id_atencion INT AUTO_INCREMENT,
    fecha_atencion DATE,
    descripcion TEXT,
    id_mascota INT,
    id_profesional INT,
    PRIMARY KEY (id_atencion),
    FOREIGN KEY (id_mascota) REFERENCES mascota(id_mascota),
    FOREIGN KEY (id_profesional) REFERENCES profesional(id_profesional)
);
