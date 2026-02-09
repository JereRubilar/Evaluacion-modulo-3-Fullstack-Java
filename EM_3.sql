CREATE SCHEMA clinica_veterinaria;

USE clinica_veterinaria;

-- Creación de tablas
CREATE TABLE dueño (
	id_dueño INT AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(200),
    telefono VARCHAR(20),
    PRIMARY KEY (id_dueño)
);

CREATE TABLE mascota (
	id_mascota INT AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    especie VARCHAR(50),
    fecha_nacimiento DATE,
    id_dueño INT NOT NULL,
    PRIMARY KEY (id_mascota),
    FOREIGN KEY (id_dueño) REFERENCES dueño(id_dueño) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE profesional (
	id_profesional INT AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    especialidad VARCHAR(100),
    PRIMARY KEY (id_profesional)
);

CREATE TABLE atencion (
	id_atencion INT AUTO_INCREMENT,
    fecha_atencion DATE,
    descripcion TEXT,
    id_mascota INT NOT NULL,
    id_profesional INT NOT NULL,
    PRIMARY KEY (id_atencion),
    FOREIGN KEY (id_mascota) REFERENCES mascota(id_mascota) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (id_profesional) REFERENCES profesional(id_profesional) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Creacion de procedimiento para atencion

DELIMITER $$

CREATE PROCEDURE nuevo_ingreso (
	IN d_nombre VARCHAR(100),
    IN d_direccion VARCHAR(200),
    IN d_telefono VARCHAR(20),
	IN m_nombre VARCHAR(100),
    IN m_especie VARCHAR(50),
    IN m_fecha_nacimiento DATE,
	IN a_fecha_atencion DATE,
    IN a_descripcion TEXT,
    IN a_id_profesional INT
)

BEGIN
	DECLARE v_id_dueño INT;
    DECLARE v_id_mascota INT;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		ROLLBACK;
        RESIGNAL;
	END;
    
    START TRANSACTION;
    
    SELECT id_dueño INTO v_id_dueño
    FROM dueño
    WHERE nombre = d_nombre AND telefono = d_telefono
    LIMIT 1;
    
    IF v_id_dueño IS NULL THEN
		INSERT INTO dueño (nombre, direccion, telefono)
		VALUES (d_nombre, d_direccion, d_telefono);

    SET v_id_dueño = LAST_INSERT_ID();
    
	END IF;
    
    INSERT INTO mascota (nombre, especie, fecha_nacimiento, id_dueño)
    VALUES (m_nombre, m_especie, m_fecha_nacimiento, v_id_dueño);
    
    SET v_id_mascota = LAST_INSERT_ID();
    
    IF a_fecha_atencion < curdate()
    THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ingrese una fecha valida';
	ELSE
		INSERT INTO atencion (fecha_atencion, descripcion, id_profesional, id_mascota)
        VALUES (a_fecha_atencion, a_descripcion, a_id_profesional, v_id_mascota);
	END IF;
    
    COMMIT;
END $$

DELIMITER ;

-- Inserciones de datos

INSERT INTO dueño (nombre, direccion, telefono)
VALUES ('Juan Pérez', 'Calle falsa 123', '555-1234'),
	   ('Ana Goméz','Avenida Siempre Viva 456','555-5678'),
       ('Carlos Ruiz','Calle 8 de Octubre 789','555-8765');
       
INSERT INTO mascota (nombre, especie, fecha_nacimiento, id_dueño)
VALUES ('Rex','Perro','2020-05-10', 1),
	   ('Luna','Gato','2019-02-20', 2),
       ('Fido','Perro','2021-03-15', 3);
       
INSERT INTO profesional (nombre, especialidad)
VALUES ('Dr. Martinez','Veterinario'),
	   ('Dr. Pérez','Especialista en dermatología'),
       ('Dr. López','Cardiólogo veterinario');
       
INSERT INTO atencion (fecha_atencion, descripcion, id_mascota, id_profesional)
VALUES ('2025-03-01','Chequeo general', 1, 1),
	   ('2025-03-05','Tratamiento dermatologico', 2, 2), 
       ('2025-03-07','Consulta cardiologa', 3, 3);
       
-- Consultas solicitadas

SELECT * FROM mascota;  -- Consultas generales de tablas
SELECT * FROM dueño;
SELECT * FROM profesional;
SELECT * FROM atencion;

SELECT d.nombre AS 'Nombre del dueño', d.telefono AS 'Contacto', GROUP_CONCAT(m.nombre SEPARATOR ', ') AS 'Mascotas' -- Obtener todos los dueños y sus mascotas
FROM mascota m
JOIN dueño d ON m.id_dueño = d.id_dueño
GROUP BY d.nombre, d.id_dueño;

SELECT m.nombre AS 'Mascota atendida', a.fecha_atencion AS 'Fecha de atención', a.descripcion AS 'Descripcion de consulta', p.nombre 'Nombre de profesional', p.especialidad AS 'Especialidad'
FROM atencion a -- Atenciones realizadas con los detalles del profesional que las atendio
JOIN mascota m ON a.id_mascota = m.id_mascota
JOIN profesional p ON a.id_profesional = p.id_profesional;

SELECT p.nombre AS 'Nombre de profesional', COUNT(*) AS 'Numero de atenciones' -- Cantidad de atenciones por profesional
FROM atencion a
JOIN profesional p ON a.id_profesional = p.id_profesional
GROUP BY p.id_profesional, p.nombre;

-- Actualizacion y eliminacion de datos

UPDATE dueño  -- Actualización dirección
SET direccion = 'P. Sherman 42, Wallaby, Sidney'
WHERE id_dueño = 1;

DELETE FROM atencion -- Eliminación de atención
WHERE id_atencion = 2;

-- Ingreso de nuevo paciente/atención con procedimiento almacenado

CALL nuevo_ingreso('Pierre Nodoyuna', 'Rue de Morgue 41, Paris', '555-7887','Patan','Perro','1968-09-14', '2026-03-14','Rotura de pierna por atropello' ,3);
CALL nuevo_ingreso('Charlie Brown', 'Pearblossom Highway 8317', '555-8778','Snoopy','Perro','1950-10-04', '2026-02-16','Vomitos y nausea con fiebre' ,1);
