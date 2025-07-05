-- ==============================================
-- ROLE: financeiro
-- ==============================================

-- Cria a role financeiro
CREATE ROLE financeiro;

-- Cria um usuário para testes e atribui a role financeiro
CREATE USER ana_financeiro WITH PASSWORD 'financeiro123';
GRANT financeiro TO ana_financeiro;

-- ==============================================
-- DEFINE PERMISSÕES PARA A ROLE financeiro
-- ==============================================

-- Permissão para gerar o relatório de fluxo de caixa (entradas, saídas e saldo por data)
GRANT EXECUTE ON FUNCTION relatorio_fluxo_caixa() TO financeiro;

-- Permissão para gerar o relatório de formas de pagamento utilizadas nos pedidos pagos
GRANT EXECUTE ON FUNCTION relatorio_formas_pagamento() TO financeiro;

-- Permissão para gerar o relatório consolidado de vendas (pedidos pagos) e compras realizadas
GRANT EXECUTE ON FUNCTION relatorio_vendas_compras_consolidadas() TO financeiro;