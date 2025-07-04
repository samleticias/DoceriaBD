-- View de fornecedores ativos
CREATE OR REPLACE VIEW vw_fornecedores_ativos AS
SELECT cod_fornecedor, nome, email, telefone
FROM fornecedor
WHERE deletado = FALSE;

-- View de fornecedores inativos
CREATE OR REPLACE VIEW vw_fornecedores_inativos AS
SELECT cod_fornecedor, nome, email, telefone
FROM fornecedor
WHERE deletado = TRUE;
