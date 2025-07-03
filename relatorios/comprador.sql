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
-- FUNÇÃO: Relatório de Compras em Andamento
-- Lista todas as compras com status 'EM ANDAMENTO'.
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
BEGIN
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
-- ============================================
CREATE OR REPLACE FUNCTION relatorio_estoque_atual()
RETURNS TABLE (
    ingrediente TEXT,
    unidade TEXT,
    qtd_em_estoque NUMERIC(10,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
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
BEGIN
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