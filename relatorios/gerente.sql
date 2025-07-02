-- ============================================
-- FUNÇÃO: Relatório de Resumo de Vendas por Período
-- Retorna total de pedidos, faturamento e ticket médio 
-- agrupado por dia, semana ou mês, no intervalo definido.
-- ============================================
CREATE OR REPLACE FUNCTION relatorio_resumo_vendas_por_periodo(
    p_periodo TEXT,           -- 'DIA', 'SEMANA' ou 'MES'
    p_data_inicio TIMESTAMP,  -- data inicial do filtro
    p_data_fim TIMESTAMP      -- data final do filtro
)
RETURNS TABLE (
    periodo TEXT,
    qtd_pedidos BIGINT,
    faturamento_total NUMERIC,
    ticket_medio NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
	-- Validação do parâmetro p_periodo
    IF p_periodo NOT IN ('DIA', 'SEMANA', 'MES') THEN
        RAISE EXCEPTION 'Valor inválido para o parâmetro "p_periodo". Valores aceitos: DIA, SEMANA, MES.';
    END IF;

    -- Validação dos parâmetros de data
    IF p_data_inicio IS NULL OR p_data_fim IS NULL THEN
        RAISE EXCEPTION 'Os parâmetros de data não podem ser nulos.';
    END IF;

    IF p_data_inicio > p_data_fim THEN
        RAISE EXCEPTION 'A data de início não pode ser maior que a data de fim.';
    END IF;

    RETURN QUERY
    SELECT 
        -- Agrupa o pedido de acordo com o valor passado
        CASE 
            WHEN p_periodo = 'DIA' THEN TO_CHAR(data_hora_pedido, 'YYYY-MM-DD')
            WHEN p_periodo = 'SEMANA' THEN TO_CHAR(data_hora_pedido, 'IYYY-"W"IW')
            WHEN p_periodo = 'MES' THEN TO_CHAR(data_hora_pedido, 'YYYY-MM')
            ELSE 'Outro'
        END AS periodo,

        -- Total de pedidos no período
        COUNT(*) AS qtd_pedidos,

        -- Faturamento total do período
        SUM(valor_total) AS faturamento_total,

        -- Ticket médio do período
        ROUND(AVG(valor_total), 2) AS ticket_medio

    FROM pedido
    -- Considera apenas os pedidos finalizados ou entregues
    WHERE status IN ('SAIU PARA ENTREGA', 'ENTREGUE')

    -- Filtro pelo intervalo de datas informado
    AND data_hora_pedido BETWEEN p_data_inicio AND p_data_fim

    -- Agrupa pelo valor calculado no CASE
    GROUP BY 1
    ORDER BY 1;
END;
$$;


-- ============================================
-- FUNÇÃO: Relatório de Status dos Pedidos
-- Retorna a quantidade de pedidos agrupada por status
-- Considera todos os pedidos cadastrados no sistema
-- ============================================
CREATE OR REPLACE FUNCTION relatorio_status_pedidos()
RETURNS TABLE (
    status TEXT,
    qtd_pedidos INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_pedidos INT;
BEGIN
    -- Verificar se existe pelo menos um pedido no sistema
    SELECT COUNT(*) INTO v_total_pedidos
    FROM pedido;

    IF v_total_pedidos = 0 THEN
        RAISE EXCEPTION 'Nenhum pedido registrado no sistema até o momento.';
    END IF;

    -- Retornar relatório agrupado por status
    RETURN QUERY
    SELECT 
        pedido.status::TEXT,
        COUNT(*)::INT
    FROM pedido
    GROUP BY pedido.status
    ORDER BY pedido.status;

END;
$$;


-- ============================================
-- FUNÇÃO: Relatório de Produtos Mais Vendidos
-- Retorna ranking dos produtos mais vendidos 
-- com total de vendas e valor arrecadado, 
-- considerando pedidos finalizados.
-- ============================================
CREATE OR REPLACE FUNCTION relatorio_produtos_mais_vendidos()
RETURNS TABLE (
    produto TEXT,
    qtd_vendida INT,
    valor_total NUMERIC(10,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_pedidos INT;
BEGIN
    -- Verificar se há pelo menos um pedido finalizado ou entregue
    SELECT COUNT(*) INTO v_total_pedidos
    FROM pedido
    WHERE status IN ('SAIU PARA ENTREGA', 'ENTREGUE');

    IF v_total_pedidos = 0 THEN
        RAISE EXCEPTION 'Não há pedidos finalizados ou entregues para gerar o relatório.';
    END IF;

    -- Retornar ranking dos produtos
    RETURN QUERY
    SELECT 
        p.nome::TEXT,
        SUM(ip.quantidade)::INT AS qtd_vendida,
        SUM(ip.quantidade * p.valor_unitario)::NUMERIC(10,2) AS valor_total
    FROM item_pedido ip
    JOIN pedido pd ON pd.cod_pedido = ip.cod_pedido
    JOIN produto p ON p.cod_produto = ip.cod_produto
    WHERE pd.status IN ('SAIU PARA ENTREGA', 'ENTREGUE')
    GROUP BY p.nome
    ORDER BY qtd_vendida DESC;

END;
$$;


-- ============================================
-- FUNÇÃO: Relatório de Controle de Estoque de Ingredientes (com limite parametrizado)
-- Lista ingredientes com estoque abaixo do valor informado.
-- ============================================
CREATE OR REPLACE FUNCTION relatorio_estoque_baixo(p_limite NUMERIC)
RETURNS TABLE (
    ingrediente TEXT,
	unidade TEXT,
    qtd_em_estoque NUMERIC(10,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validação de limite mínimo
    IF p_limite IS NULL OR p_limite < 0 THEN
        RAISE EXCEPTION 'Informe um valor de limite de estoque válido.';
    END IF;

    -- Retornar ingredientes com estoque abaixo do valor informado
    RETURN QUERY
    SELECT 
        nome::TEXT,
		unidade_medida::TEXT,
        qtd_estoque::NUMERIC
    FROM ingrediente
    WHERE qtd_estoque < p_limite
      AND deletado = FALSE
    ORDER BY qtd_estoque ASC;

END;
$$;


-- ============================================
-- FUNÇÃO: Relatório de Compras por Fornecedor
-- Lista compras realizadas agrupadas por fornecedor, 
-- com filtro opcional por status de compra.
-- Valida se o status passado é permitido.
-- ============================================
CREATE OR REPLACE FUNCTION relatorio_compras_por_fornecedor(p_status TEXT DEFAULT NULL)
RETURNS TABLE (
    fornecedor TEXT,
    data_compra TIMESTAMP,
    valor_total NUMERIC(10,2),
    status TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validação do parâmetro (se informado)
    IF p_status IS NOT NULL THEN
        IF p_status NOT IN ('EM ANDAMENTO', 'FINALIZADA', 'CANCELADA', 'PENDENTE') THEN
            RAISE EXCEPTION 'Status de compra "%" inválido. Valores permitidos: EM ANDAMENTO, FINALIZADA, CANCELADA, PENDENTE.', p_status;
        END IF;
    END IF;

    -- Consulta com ou sem filtro
    RETURN QUERY
    SELECT 
        f.nome::TEXT,
        c.data_compra::TIMESTAMP,
        c.valor_total::NUMERIC,
        c.status::TEXT
    FROM compra c
    JOIN fornecedor f ON c.cod_fornecedor = f.cod_fornecedor
    WHERE f.deletado = FALSE
      AND (p_status IS NULL OR c.status::TEXT = p_status)
    ORDER BY f.nome, c.data_compra DESC;
END;
$$;




