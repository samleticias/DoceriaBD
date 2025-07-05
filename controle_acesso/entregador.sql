-- ==============================================
-- ROLE: entregador
-- ==============================================

-- Cria a role entregador
CREATE ROLE entregador;

-- Cria um usuário para testes e atribui a role entregador
CREATE USER bruno_entregador WITH PASSWORD 'entregador123';
GRANT entregador TO bruno_entregador;

-- ==============================================
-- DEFINE PERMISSÕES PARA A ROLE entregador
-- ==============================================

-- Permissão para consultar pedidos disponíveis para entrega
GRANT EXECUTE ON FUNCTION relatorio_pedidos_disponiveis_entrega() TO entregador;

-- Permissão para consultar histórico de entregas do entregador
GRANT EXECUTE ON FUNCTION relatorio_historico_entregas(TEXT) TO entregador;

-- Permissão para consultar pedidos atrasados ou com problemas
GRANT EXECUTE ON FUNCTION relatorio_pedidos_atrasados() TO entregador;

-- Permissão para consultar desempenho de entregas
GRANT EXECUTE ON FUNCTION relatorio_desempenho_entregas() TO entregador;
