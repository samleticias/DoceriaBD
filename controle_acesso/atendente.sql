-- ==============================================
-- ROLE: atendente
-- ==============================================
select * from atendente;
-- Cria a role atendente
CREATE ROLE atendente;

-- Cria um usuário para testes e atribui a role atendente
CREATE USER paulo_atendente WITH PASSWORD 'atendente123';
GRANT atendente TO paulo_atendente;

-- ==============================================
-- DEFINE PERMISSÕES PARA A ROLE atendente
-- ==============================================

-- Permissão para finalizar pedido
GRANT EXECUTE ON FUNCTION finalizar_pedido(INT, TEXT) TO atendente;

-- Permissão para consultar pedidos abertos do cliente
GRANT EXECUTE ON FUNCTION relatorio_pedidos_abertos_cliente(TEXT) TO atendente;

-- Permissão para consultar histórico de pedidos de cliente
GRANT EXECUTE ON FUNCTION historico_pedidos_cliente(TEXT) TO atendente;

-- Permissão para consultar produtos mais solicitados pelo cliente
GRANT EXECUTE ON FUNCTION produtos_mais_solicitados_cliente(TEXT) TO atendente;

-- Permissão para consultar pedidos cancelados por cliente
GRANT EXECUTE ON FUNCTION pedidos_cancelados_cliente(TEXT) TO atendente;

-- Permissão para consultar pedidos pendentes de pagamento
GRANT EXECUTE ON FUNCTION pedidos_pendentes_pagamento() TO atendente;

-- Permissão para consultar os produtos ativos
GRANT SELECT ON vw_produtos_ativos TO atendente;

-- Permissão para consultar os tipos de pagamento ativos
GRANT SELECT ON vw_tipos_pagamento_ativos TO atendente;