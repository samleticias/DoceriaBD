-- =====================================================
-- FUNÇÃO: Extrato de Compras por Período (Cliente)
-- Retorna quantidade de pedidos, valor total gasto e 
-- ticket médio no período para um cliente específico.
-- Exibe aviso amigável se o cliente não possuir pedidos.
-- =====================================================
CREATE OR REPLACE FUNCTION relatorio_extrato_cliente_por_periodo(
    p_nome_cliente TEXT,
    p_data_inicio TIMESTAMP,
    p_data_fim TIMESTAMP
)
RETURNS TABLE (
    qtd_pedidos INT,
    valor_total NUMERIC(10,2),
    ticket_medio NUMERIC(10,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cod_cliente INT;
    v_total_pedidos INT;
BEGIN
    -- Valida se cliente existe e está ativo
    SELECT cod_cliente INTO v_cod_cliente
    FROM cliente 
    WHERE nome ILIKE p_nome_cliente AND deletado = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Cliente "%" não encontrado ou deletado.', p_nome_cliente;
    END IF;

    -- Valida se datas são válidas
    IF p_data_inicio IS NULL OR p_data_fim IS NULL THEN
        RAISE EXCEPTION 'As datas de início e fim devem ser informadas.';
    ELSIF p_data_inicio > p_data_fim THEN
        RAISE EXCEPTION 'Data inicial não pode ser posterior à data final.';
    END IF;

    -- Verifica se há pedidos no período
    SELECT COUNT(*) INTO v_total_pedidos
    FROM pedido
    WHERE cod_cliente = v_cod_cliente
      AND status = 'ENTREGUE'
      AND data_hora_pedido BETWEEN p_data_inicio AND p_data_fim;

    IF v_total_pedidos = 0 THEN
        RAISE NOTICE 'O cliente "%" não possui pedidos entregues no período informado.', p_nome_cliente;

        -- Retorna linha zerada mesmo assim pra manter a estrutura do retorno
        RETURN QUERY SELECT 0, 0.00, 0.00;
        RETURN;
    END IF;

    -- Retorna extrato de compras
    RETURN QUERY
    SELECT 
        COUNT(*) AS qtd_pedidos,
        COALESCE(SUM(valor_total), 0),
        ROUND(COALESCE(AVG(valor_total), 0), 2)
    FROM pedido
    WHERE cod_cliente = v_cod_cliente
      AND status = 'ENTREGUE'
      AND data_hora_pedido BETWEEN p_data_inicio AND p_data_fim;

END;
$$;


-- =====================================================
-- FUNÇÃO: Produto Favorito do Cliente
-- Retorna o produto mais comprado pelo cliente em pedidos entregues.
-- Exibe mensagem se não houver histórico.
-- =====================================================
CREATE OR REPLACE FUNCTION relatorio_produto_favorito_cliente(
    p_nome_cliente TEXT
)
RETURNS TABLE (
    produto_favorito TEXT,
    total_vendido INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cod_cliente INT;
    v_qtd_pedidos INT;
BEGIN
    -- Verifica se o cliente existe e está ativo
    SELECT cod_cliente INTO v_cod_cliente
    FROM cliente
    WHERE nome ILIKE p_nome_cliente AND deletado = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Cliente "%" não encontrado ou deletado.', p_nome_cliente;
    END IF;

    -- Verifica se há pedidos entregues
    SELECT COUNT(*) INTO v_qtd_pedidos
    FROM pedido
    WHERE cod_cliente = v_cod_cliente AND status = 'ENTREGUE';

    IF v_qtd_pedidos = 0 THEN
        RAISE NOTICE 'O cliente "%" ainda não possui pedidos entregues.', p_nome_cliente;

        -- Retorna linha nula pra manter estrutura da consulta
        RETURN QUERY SELECT NULL::TEXT, 0;
        RETURN;
    END IF;

    -- Retorna o produto mais comprado
    RETURN QUERY
    SELECT p.nome::TEXT, SUM(ip.quantidade)::INT
    FROM pedido pe
    JOIN item_pedido ip ON pe.cod_pedido = ip.cod_pedido
    JOIN produto p ON p.cod_produto = ip.cod_produto
    WHERE pe.cod_cliente = v_cod_cliente AND pe.status = 'ENTREGUE'
    GROUP BY p.nome
    ORDER BY SUM(ip.quantidade) DESC
    LIMIT 1;

END;
$$;


-- ==========================================================
-- FUNÇÃO: Total Gasto pelo Cliente no Mês Atual
-- Retorna o valor total gasto pelo cliente em pedidos entregues
-- no mês corrente. Caso não tenha, retorna mensagem amigável.
-- ==========================================================
CREATE OR REPLACE FUNCTION relatorio_total_gasto_cliente_mes(
    p_nome_cliente TEXT
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_cod_cliente INT;
    v_total NUMERIC := 0;
BEGIN
    -- Valida se o cliente existe e está ativo
    SELECT cod_cliente INTO v_cod_cliente
    FROM cliente
    WHERE nome ILIKE p_nome_cliente AND deletado = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Cliente "%" não encontrado ou deletado.', p_nome_cliente;
    END IF;

    -- Calcula total gasto no mês atual
    SELECT COALESCE(SUM(valor_total), 0)
    INTO v_total
    FROM pedido
    WHERE cod_cliente = v_cod_cliente
      AND status = 'ENTREGUE'
      AND DATE_TRUNC('month', data_hora_pedido) = DATE_TRUNC('month', NOW());

    -- Se não houve pedidos no mês
    IF v_total = 0 THEN
        RAISE NOTICE 'O cliente "%" não possui pedidos entregues no mês atual.', p_nome_cliente;
    END IF;

    RETURN v_total;
END;
$$;



