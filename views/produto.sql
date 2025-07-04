-- View de produtos ativos
CREATE OR REPLACE VIEW vw_produtos_ativos AS
SELECT cod_produto, nome, descricao, valor_unitario
FROM produto
WHERE deletado = FALSE;

-- View de produtos inativos
CREATE OR REPLACE VIEW vw_produtos_inativos AS
SELECT cod_produto, nome, descricao, valor_unitario
FROM produto
WHERE deletado = TRUE;
