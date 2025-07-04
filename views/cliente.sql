-- View de clientes ativos
CREATE OR REPLACE VIEW vw_clientes_ativos AS
SELECT cod_cliente, nome, email, telefone
FROM cliente
WHERE deletado = FALSE;

-- View de clientes inativos
CREATE OR REPLACE VIEW vw_clientes_inativos AS
SELECT cod_cliente, nome, email, telefone
FROM cliente
WHERE deletado = TRUE;