-- ============================================
-- FUNÇÃO: Fluxo de Caixa Diário/Mensal
-- Mostra entradas (pedidos pagos) e saídas (compras realizadas)
-- agrupadas por data.
-- ============================================
CREATE OR REPLACE FUNCTION relatorio_fluxo_caixa()
RETURNS TABLE (
    data DATE,
    entradas NUMERIC(10,2),
    saidas NUMERIC(10,2),
    saldo NUMERIC(10,2)
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_total_compras INT;
    v_total_pedidos INT;
BEGIN
    -- Quantidade de compras cadastradas
    SELECT COUNT(*) INTO v_total_compras FROM compra;

    -- Quantidade de pedidos cadastrados
    SELECT COUNT(*) INTO v_total_pedidos FROM pedido;

    IF v_total_compras = 0 AND v_total_pedidos = 0 THEN
        RAISE EXCEPTION 'Não há compras nem pedidos cadastrados para gerar o relatório.';
    END IF;

    RETURN QUERY
    SELECT 
        d.data_ref,
        COALESCE(SUM(p.valor_total), 0) AS entradas,
        COALESCE(SUM(c.valor_total), 0) AS saidas,
        COALESCE(SUM(p.valor_total), 0) - COALESCE(SUM(c.valor_total), 0) AS saldo
    FROM (
        SELECT data_hora_pedido::DATE AS data_ref FROM pedido
        UNION
        SELECT data_compra::DATE FROM compra
    ) d
    LEFT JOIN pedido p ON p.pago = TRUE AND p.data_hora_pedido::DATE = d.data_ref
    LEFT JOIN compra c ON c.data_compra::DATE = d.data_ref
    GROUP BY d.data_ref
    ORDER BY d.data_ref;
END;
$$;

-- ============================================
-- FUNÇÃO: Relatório de Formas de Pagamento Utilizadas
-- Mostra quantos pedidos pagos foram feitos com cada tipo de pagamento.
-- ============================================
CREATE OR REPLACE FUNCTION relatorio_formas_pagamento()
RETURNS TABLE (
    tipo_pagamento TEXT,
    qtd_pedidos INT,
    total_recebido NUMERIC(10,2)
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_total_pedidos INT;
	v_total_pedidos_pagos INT;
BEGIN
    -- Quantidade de pedidos cadastrados
    SELECT COUNT(*) INTO v_total_pedidos FROM pedido;

    IF v_total_pedidos = 0 THEN
        RAISE EXCEPTION 'Não há pedidos cadastrados para gerar o relatório.';
    END IF;
	
	-- Verifica se há pedidos pagos
    SELECT COUNT(*) INTO v_total_pedidos_pagos FROM pedido WHERE pago = TRUE;

    IF v_total_pedidos_pagos = 0 THEN
        RAISE EXCEPTION 'Não há pedidos pagos para gerar o relatório.';
    END IF;

    RETURN QUERY
    SELECT 
        tp.nome::TEXT,
        COUNT(p.cod_pedido)::INT,
        SUM(p.valor_total)::NUMERIC(10,2)
    FROM pedido p
    JOIN tipo_pagamento tp ON p.cod_tipo_pagamento = tp.cod_tipo_pagamento
    WHERE p.pago = TRUE
    GROUP BY tp.nome
    ORDER BY total_recebido DESC;
END;
$$;

-- ============================================
-- FUNÇÃO: Vendas e Compras Consolidadas
-- Mostra pedidos pagos (vendas) e compras realizadas em um só relatório.
-- ============================================
CREATE OR REPLACE FUNCTION relatorio_vendas_compras_consolidadas()
RETURNS TABLE (
    data DATE,
    tipo TEXT,
    total NUMERIC(10,2)
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_total_compras INT;
    v_total_pedidos_pagos INT;
BEGIN
    -- Verifica total de compras cadastradas
    SELECT COUNT(*) INTO v_total_compras 
    FROM compra;

    -- Verifica total de pedidos pagos
    SELECT COUNT(*) INTO v_total_pedidos_pagos 
    FROM pedido 
    WHERE pago = TRUE;

    -- Se não houver nenhum dos dois, lança erro
    IF v_total_compras = 0 AND v_total_pedidos_pagos = 0 THEN
        RAISE EXCEPTION 'Não há compras cadastradas nem pedidos pagos para gerar o relatório.';
    END IF;

    -- Gera relatório unificado
    RETURN QUERY
    SELECT 
        p.data_hora_pedido::DATE AS data,
        'VENDA'::TEXT AS tipo,
        p.valor_total
    FROM pedido p
    WHERE p.pago = TRUE

    UNION ALL

    SELECT 
        c.data_compra::DATE AS data,
        'COMPRA'::TEXT AS tipo,
        c.valor_total
    FROM compra c

    ORDER BY data, tipo;
END;
$$;