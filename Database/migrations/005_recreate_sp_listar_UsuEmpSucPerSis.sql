-- ─────────────────────────────────────────────────────────────
-- Migracion 005: recrear sp_listar_UsuEmpSucPerSis
-- Devuelve el contexto (empresa/sucursal/perfil) de un usuario desde
-- usuario_empresa_sucursal_perfil_sistema. Lo consume
-- UsuarioRepository.GetUsuarioContextoAsync al crear un ticket.
-- Parametros (segun el C#): w_usuarioID, w_empresaID(-1=any),
-- w_sucursalID(-1=any), w_sistemaID (ej 'CDK_TKT'), w_perfilID(0=any),
-- w_habilitado (1=solo habilitados, -1=any).
-- ─────────────────────────────────────────────────────────────

DROP PROCEDURE IF EXISTS sp_listar_UsuEmpSucPerSis;

DELIMITER //
CREATE PROCEDURE sp_listar_UsuEmpSucPerSis(
  IN w_usuarioID  INT,
  IN w_empresaID  INT,
  IN w_sucursalID INT,
  IN w_sistemaID  VARCHAR(8),
  IN w_perfilID   INT,
  IN w_habilitado INT
)
BEGIN
  SELECT
    m.idUsuario  AS idUsuario,
    m.idEmpresa  AS idEmpresa,
    m.idSucursal AS idSucursal,
    m.idPerfil   AS idPerfil,
    m.idSistema  AS idSistema,
    m.habilitado AS habilitado
  FROM usuario_empresa_sucursal_perfil_sistema m
  WHERE m.idUsuario = w_usuarioID
    AND (w_empresaID  = -1 OR m.idEmpresa  = w_empresaID)
    AND (w_sucursalID = -1 OR m.idSucursal = w_sucursalID)
    AND (w_sistemaID IS NULL OR w_sistemaID = '' OR m.idSistema = w_sistemaID)
    AND (w_perfilID   =  0 OR m.idPerfil    = w_perfilID)
    AND (w_habilitado = -1 OR m.habilitado  = w_habilitado)
  ORDER BY m.habilitado DESC, m.ID ASC
  LIMIT 1;
END //
DELIMITER ;
