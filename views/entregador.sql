-- View de entregadores ativos
CREATE OR REPLACE VIEW vw_entregadores_ativos AS
SELECT cod_entregador, nome, cpf, telefone
FROM entregador
WHERE deletado = FALSE;

-- View de entregadores inativos
CREATE OR REPLACE VIEW vw_entregadores_inativos AS
SELECT cod_entregador, nome, cpf, telefone
FROM entregador
WHERE deletado = TRUE;