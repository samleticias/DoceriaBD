-- ============================================
-- FUNÇÃO: Relatório de Controle de Estoque de Ingredientes (com limite parametrizado)
-- Lista ingredientes com estoque abaixo do valor informado.
-- Lança erro se não houver ingredientes cadastrados.
-- ============================================
CREATE OR REPLACE FUNCTION relatorio_estoque_baixo(p_limite NUMERIC)
RETURNS TABLE (
    ingrediente TEXT,
	unidade TEXT,
    qtd_em_estoque NUMERIC(10,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_ingredientes INT;
BEGIN
    -- Validação de limite mínimo
    IF p_limite IS NULL OR p_limite < 0 THEN
        RAISE EXCEPTION 'Informe um valor de limite de estoque válido.';
    END IF;

    -- Quantidade de ingredientes cadastrados
    SELECT COUNT(*) INTO v_total_ingredientes 
    FROM ingrediente
    WHERE deletado = FALSE;

    -- Valida se a quantidade de ingredientes é igual a zero e lança erro
    IF v_total_ingredientes = 0 THEN
        RAISE EXCEPTION 'Não há ingredientes cadastrados para gerar o relatório.';
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
-- FUNÇÃO: Relatório de Compras em Andamento
-- Lista todas as compras com status 'EM ANDAMENTO'.
-- Lança erro se não houver compras cadastrados.
-- ============================================
CREATE OR REPLACE FUNCTION relatorio_compras_em_andamento()
RETURNS TABLE (
    cod_compra INT,
    fornecedor TEXT,
    data_compra TIMESTAMP,
    valor_total NUMERIC(10,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_compras INT;
BEGIN
    -- Quantidade de compras cadastradas
    SELECT COUNT(*) INTO v_total_compras 
    FROM compra;

    -- Valida se a quantidade de compras é igual a zero e lança erro
    IF v_total_compras = 0 THEN
        RAISE EXCEPTION 'Não há compras cadastradas para gerar o relatório.';
    END IF;

    RETURN QUERY
    SELECT 
        c.cod_compra,
        f.nome::TEXT,
        c.data_compra,
        c.valor_total
    FROM compra c
    JOIN fornecedor f ON c.cod_fornecedor = f.cod_fornecedor
    WHERE c.status = 'EM ANDAMENTO'
      AND f.deletado = FALSE
    ORDER BY c.data_compra DESC;
END;
$$;

-- ============================================
-- FUNÇÃO: Relatório de Estoque Atual dos Ingredientes
-- Lista todos os ingredientes com suas quantidades em estoque.
-- Lança erro se não houver ingredientes cadastrados.
-- ============================================
CREATE OR REPLACE FUNCTION relatorio_estoque_atual()
RETURNS TABLE (
    ingrediente TEXT,
    unidade TEXT,
    qtd_em_estoque NUMERIC(10,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_ingredientes INT;
BEGIN
    -- Quantidade de ingredientes cadastrados
    SELECT COUNT(*) INTO v_total_ingredientes 
    FROM ingrediente
    WHERE deletado = FALSE;

    -- Valida se a quantidade de ingredientes é igual a zero e lança erro
    IF v_total_ingredientes = 0 THEN
        RAISE EXCEPTION 'Não há ingredientes cadastrados para gerar o relatório.';
    END IF;

    RETURN QUERY
    SELECT 
        nome::TEXT,
        unidade_medida::TEXT,
        qtd_estoque
    FROM ingrediente
    WHERE deletado = FALSE
    ORDER BY nome;
END;
$$;

-- ============================================
-- FUNÇÃO: Relatório de Consumo de Ingredientes
-- Calcula o total consumido de cada ingrediente
-- com base nos pedidos finalizados ou entregues.
-- ============================================
CREATE OR REPLACE FUNCTION relatorio_consumo_ingredientes()
RETURNS TABLE (
    ingrediente TEXT,
    unidade TEXT,
    total_consumido NUMERIC(10,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total INT;
BEGIN
    -- Verificar se existem pedidos com status finalizado/entregue
    SELECT COUNT(*) INTO v_total
    FROM pedido
    WHERE status IN ('SAIU PARA ENTREGA', 'ENTREGUE');

    IF v_total = 0 THEN
        RAISE EXCEPTION 'Não há pedidos finalizados ou entregues para gerar o relatório de consumo.';
    END IF;

    RETURN QUERY
    SELECT 
        i.nome::TEXT,
        i.unidade_medida::TEXT,
        SUM(pi.qtd_utilizada * ip.quantidade)::NUMERIC(10,2) AS total_consumido
    FROM pedido p
    JOIN item_pedido ip ON p.cod_pedido = ip.cod_pedido
    JOIN produto_ingrediente pi ON ip.cod_produto = pi.cod_produto
    JOIN ingrediente i ON i.cod_ingrediente = pi.cod_ingrediente
    WHERE p.status IN ('SAIU PARA ENTREGA', 'ENTREGUE')
    GROUP BY i.nome, i.unidade_medida
    ORDER BY total_consumido DESC;
END;
$$;

-- ============================================
-- FUNÇÃO: Relatório de Compras por Fornecedor
-- Agrupa e soma o valor total de compras feitas por cada fornecedor.
-- Lança erro se não houver compras cadastradas.
-- ============================================
CREATE OR REPLACE FUNCTION relatorio_compras_por_fornecedor()
RETURNS TABLE (
    fornecedor TEXT,
    total_compras NUMERIC(10,2),
    quantidade_compras INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_compras INT;
BEGIN
    -- Verifica se há compras cadastradas
    SELECT COUNT(*) INTO v_total_compras
    FROM compra;

    IF v_total_compras = 0 THEN
        RAISE EXCEPTION 'Não há compras cadastradas para gerar o relatório.';
    END IF;

    RETURN QUERY
    SELECT 
        f.nome::TEXT AS fornecedor,
        SUM(c.valor_total)::NUMERIC(10,2) AS total_compras,
        COUNT(c.cod_compra)::INT AS quantidade_compras
    FROM compra c
    JOIN fornecedor f ON c.cod_fornecedor = f.cod_fornecedor
    WHERE f.deletado = FALSE
    GROUP BY f.nome
    ORDER BY total_compras DESC;
END;
$$;