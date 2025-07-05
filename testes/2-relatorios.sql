-- TESTE: executar e validar principais relatórios por ator

-- ==============================
-- MÓDULO A: RELATÓRIOS DO GERENTE
-- ==============================
select * from pedido;
-- 1. Resumo de Vendas por Período
SELECT * FROM relatorio_resumo_vendas_por_periodo(
    'DIA',
    '2025-07-01'::timestamp,
    '2025-07-08'::timestamp
);

-- 2. Status dos Pedidos
SELECT * FROM relatorio_status_pedidos();

-- 3. Produtos Mais Vendidos
SELECT * FROM relatorio_produtos_mais_vendidos();

-- 4. Desempenho dos Funcionários
SELECT * FROM relatorio_desempenho_funcionarios();

-- 5. Pedidos Cancelados e Motivos
SELECT * FROM relatorio_pedidos_cancelados();

-- 6. Resumo Financeiro Geral
SELECT * FROM resumo_financeiro_totais();


-- ==============================
-- MÓDULO B: RELATÓRIOS DO ATENDENTE
-- ==============================

-- 1. Pedidos Abertos do Cliente 'Thiago Elias'
SELECT * FROM relatorio_pedidos_abertos_cliente('Thiago elias');

-- 2. Histórico de Pedidos do Cliente
SELECT * FROM historico_pedidos_cliente('Thiago elias');

-- 3. Produtos Mais Solicitados pelo Cliente
SELECT * FROM produtos_mais_solicitados_cliente('Thiago elias');

-- 4. Pedidos Cancelados pelo Cliente
SELECT * FROM pedidos_cancelados_cliente('Thiago elias');

-- 5. Pedidos Pendentes de Pagamento
SELECT * FROM pedidos_pendentes_pagamento();


-- ==============================
-- MÓDULO C: RELATÓRIOS DO ENTREGADOR
-- ==============================

-- 1. Pedidos Disponíveis para Entrega
SELECT * FROM relatorio_pedidos_disponiveis_entrega();

-- 2. Histórico de Entregas do Entregador 'Enzo Melo'
SELECT * FROM relatorio_historico_entregas('Enzo Melo');

-- 3. Pedidos Atrasados
SELECT * FROM relatorio_pedidos_atrasados();


-- ==============================
-- MÓDULO D: RELATÓRIOS DO CLIENTE
-- ==============================

-- 1. Itens do Pedido (pedido 1)
SELECT * FROM consultar_itens_pedido(1);

-- 2. Receita de Produto 'Brigadeiro Gourmet'
SELECT * FROM relatorio_produto_favorito_cliente('Thiago elias');

-- 3. Total Gasto no Mês por Cliente
SELECT * FROM relatorio_total_gasto_cliente_mes('Thiago elias');


-- ==============================
-- MÓDULO D: RELATÓRIOS DO ALALISTA FINANCEIRO
-- ==============================

-- 1. Fluxo de Caixa Diário/Mensal
SELECT * FROM relatorio_fluxo_caixa();

-- 2. Relatório de Formas de Pagamento Utilizadas
SELECT * FROM relatorio_formas_pagamento();

-- 3. Vendas e Compras Consolidadas
SELECT * FROM relatorio_vendas_compras_consolidadas();


-- ==============================
-- MÓDULO D: RELATÓRIOS DO COMPRADOR / ESTOQUE
-- ==============================

-- 1. Controle de Estoque dos Ingredientes (limite 10)
SELECT * FROM relatorio_estoque_baixo(10);

-- 2. Relatório de Compras por Fornecedor
SELECT * FROM relatorio_compras_por_fornecedor();






