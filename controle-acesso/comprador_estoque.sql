-- ==============================================
-- ROLE: comprador estoque
-- ==============================================

-- Cria a role comprador estoque
CREATE ROLE comprador_estoque;

-- Cria um usuário para testes e atribui a role comprador estoque
CREATE USER gabriel_comprador WITH PASSWORD 'comprador123';
GRANT comprador_estoque TO gabriel_comprador;

-- ==============================================
-- DEFINE PERMISSÕES PARA A ROLE comprador_estoque
-- ==============================================

-- Permissão para criar compras
GRANT EXECUTE ON FUNCTION criar_compra(text) TO comprador_estoque;

-- Permissão para visualizar as informações de compras em aberto de um determinado fornecedor
GRANT EXECUTE ON FUNCTION listar_compras_em_aberto(text) TO comprador_estoque;

-- Permissão para adicionar itens à compra
GRANT EXECUTE ON FUNCTION adicionar_item_compra(int, text, numeric, int) TO comprador_estoque;

-- Permissão para finalizar compra
GRANT EXECUTE ON FUNCTION finalizar_compra(int) TO comprador_estoque;

-- ==============================================
-- PERMISSÕES DE EXECUÇÃO DOS RELATÓRIOS PARA A ROLE comprador_estoque
-- ==============================================

-- Permissão para consultar ingredientes em estoque baixo
GRANT EXECUTE ON FUNCTION relatorio_estoque_baixo(numeric) TO comprador_estoque;

-- Permissão para consultar compras em andamento
GRANT EXECUTE ON FUNCTION relatorio_compras_em_andamento() TO comprador_estoque;

-- Permissão para consultar estoque atual de todos os ingredientes
GRANT EXECUTE ON FUNCTION relatorio_estoque_atual() TO comprador_estoque;

--Permissão para consultar consumo de ingredientes com base nos pedidos entregues ou finalizados
GRANT EXECUTE ON FUNCTION relatorio_consumo_ingredientes() TO comprador_estoque;

-- Permissão para consultar compras por fornecedor
GRANT EXECUTE ON FUNCTION relatorio_compras_por_fornecedor() TO comprador_estoque;
