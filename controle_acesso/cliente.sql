-- ==============================================
-- ROLE: cliente
-- ==============================================

-- Cria a role cliente
CREATE ROLE cliente;

-- Cria um usuário para testes e atribui a role cliente
CREATE USER maria_cliente WITH PASSWORD 'cliente123';
GRANT cliente TO maria_cliente;

-- ==============================================
-- DEFINE PERMISSÕES PARA A ROLE cliente
-- ==============================================

-- Permissão para criar pedido
GRANT EXECUTE ON FUNCTION criar_pedido(text) TO cliente;

-- Permissão para adicionar item no pedido
GRANT EXECUTE ON FUNCTION adicionar_item_pedido(int, text, int) TO cliente;

-- Permissão para pagar pedido
GRANT EXECUTE ON FUNCTION pagar_pedido(int, text) TO cliente;

-- Permissão para consultar itens do pedido
GRANT EXECUTE ON FUNCTION consultar_itens_pedido(int) TO cliente;

-- Permissão para consultar seus pedidos em aberto
GRANT EXECUTE ON FUNCTION listar_pedidos_abertos(text) TO cliente;

-- Permissão para consultar seu histórico de pedidos
GRANT EXECUTE ON FUNCTION historico_pedidos_cliente(text) TO cliente;

-- Permissão para consultar produtos mais solicitados
GRANT EXECUTE ON FUNCTION produtos_mais_solicitados_cliente(text) TO cliente;

-- Permissão para consultar pedidos cancelados
GRANT EXECUTE ON FUNCTION pedidos_cancelados_cliente(text) TO cliente;

-- Permissão para consultar valor total gasto em compras
GRANT EXECUTE ON FUNCTION relatorio_total_gasto_cliente_mes(text) TO cliente;

-- Permissão para consultar os produtos ativos
GRANT SELECT ON vw_produtos_ativos TO cliente;

-- Permissão para consultar os tipos de pagamento ativos
GRANT SELECT ON vw_tipos_pagamento_ativos TO cliente;

