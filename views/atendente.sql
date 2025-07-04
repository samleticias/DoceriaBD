-- View de atendentes ativos
CREATE OR REPLACE VIEW vw_atendentes_ativos AS
SELECT cod_atendente, nome, cpf, email
FROM atendente
WHERE deletado = FALSE;

-- View de atendentes inativos
CREATE OR REPLACE VIEW vw_atendentes_inativos AS
SELECT cod_atendente, nome, cpf, email
FROM atendente
WHERE deletado = TRUE;