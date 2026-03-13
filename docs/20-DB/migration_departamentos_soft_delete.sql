-- =====================================================================
-- Migration: Departamentos Soft Delete + Campos adicionales
-- Fecha: 2025-01
-- Descripción: Agrega Habilitado, fechaBaja y Descripcion a departamento
--              Crea SPs de toggle, editar y listar activos
-- =====================================================================

-- 1. ALTER TABLE: agregar columnas faltantes
ALTER TABLE `departamento`
  ADD COLUMN `Descripcion` VARCHAR(255) NULL DEFAULT NULL AFTER `Nombre`,
  ADD COLUMN `Habilitado` TINYINT(1) NOT NULL DEFAULT 1 AFTER `Descripcion`,
  ADD COLUMN `fechaBaja` DATETIME NULL DEFAULT NULL AFTER `Habilitado`;

-- 2. Recrear SP: sp_listar_departamento (actualmente tiene cuerpo vacío)
DROP PROCEDURE IF EXISTS `sp_listar_departamento`;
DELIMITER $$
CREATE PROCEDURE `sp_listar_departamento`()
BEGIN
  SELECT
    Id_Departamento,
    Nombre,
    COALESCE(Descripcion, '') AS Descripcion,
    Habilitado AS Activo,
    fechaBaja
  FROM departamento
  ORDER BY Nombre ASC;
END$$
DELIMITER ;

-- 3. Nuevo SP: sp_obtener_departamentos_activos
DROP PROCEDURE IF EXISTS `sp_obtener_departamentos_activos`;
DELIMITER $$
CREATE PROCEDURE `sp_obtener_departamentos_activos`()
BEGIN
  SELECT
    Id_Departamento,
    Nombre,
    COALESCE(Descripcion, '') AS Descripcion,
    1 AS Activo
  FROM departamento
  WHERE Habilitado = 1
  ORDER BY Nombre ASC;
END$$
DELIMITER ;

-- 4. Nuevo SP: sp_toggle_departamento
DROP PROCEDURE IF EXISTS `sp_toggle_departamento`;
DELIMITER $$
CREATE PROCEDURE `sp_toggle_departamento`(
  IN p_id INT
)
BEGIN
  DECLARE v_current TINYINT;

  SELECT Habilitado INTO v_current
  FROM departamento
  WHERE Id_Departamento = p_id;

  IF v_current IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Departamento no encontrado';
  END IF;

  IF v_current = 1 THEN
    UPDATE departamento
    SET Habilitado = 0, fechaBaja = NOW()
    WHERE Id_Departamento = p_id;
  ELSE
    UPDATE departamento
    SET Habilitado = 1, fechaBaja = NULL
    WHERE Id_Departamento = p_id;
  END IF;

  SELECT
    Id_Departamento,
    Nombre,
    COALESCE(Descripcion, '') AS Descripcion,
    Habilitado AS Activo,
    fechaBaja
  FROM departamento
  WHERE Id_Departamento = p_id;
END$$
DELIMITER ;

-- 5. Recrear SP: sp_departamento_actualizar (agregar Descripcion)
DROP PROCEDURE IF EXISTS `sp_departamento_actualizar`;
DELIMITER $$
CREATE PROCEDURE `sp_departamento_actualizar`(
  IN p_id INT,
  IN p_nombre VARCHAR(50),
  IN p_descripcion VARCHAR(255),
  OUT p_resultado VARCHAR(255)
)
BEGIN
  DECLARE v_exists INT DEFAULT 0;
  DECLARE v_dup INT DEFAULT 0;

  -- Verificar que existe
  SELECT COUNT(*) INTO v_exists FROM departamento WHERE Id_Departamento = p_id;
  IF v_exists = 0 THEN
    SET p_resultado = 'Error: Departamento no encontrado';
  ELSE
    -- Verificar nombre duplicado (excluir el propio)
    SELECT COUNT(*) INTO v_dup
    FROM departamento
    WHERE Nombre = p_nombre AND Id_Departamento != p_id;

    IF v_dup > 0 THEN
      SET p_resultado = 'Error: Ya existe un departamento con ese nombre';
    ELSE
      UPDATE departamento
      SET Nombre = p_nombre,
          Descripcion = p_descripcion
      WHERE Id_Departamento = p_id;
      SET p_resultado = 'OK';
    END IF;
  END IF;
END$$
DELIMITER ;
