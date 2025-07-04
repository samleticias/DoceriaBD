-- FUNÇAÕ: Procura um produto pelo nome
CREATE OR REPLACE FUNCTION buscar_cod_produto(p_nome TEXT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_cod INT;
BEGIN
    SELECT cod_produto INTO v_cod
    FROM produto
    WHERE nome ILIKE p_nome AND deletado = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Produto % não encontrado.', p_nome;
    END IF;

    RETURN v_cod;
END;
$$;

-- ============================================
-- FUNÇÃO: Consultar receita de um produto
-- Lista ingredientes, unidade de medida e quantidade usada no produto
-- ============================================
CREATE OR REPLACE FUNCTION consultar_receita_produto(p_nome_produto TEXT)
RETURNS TABLE (
    ingrediente TEXT,
    unidade_medida TEXT,
    qtd_utilizada NUMERIC(10, 2)
)
AS $$
DECLARE
    v_cod_produto INT;
BEGIN
    -- Verificar se o produto existe e está ativo
    SELECT cod_produto INTO v_cod_produto
    FROM produto
    WHERE nome ILIKE p_nome_produto AND deletado = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Produto "%" não encontrado ou deletado.', p_nome_produto;
    END IF;

    -- Verificar se o produto possui receita cadastrada
    PERFORM 1 FROM produto_ingrediente WHERE cod_produto = v_cod_produto;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Produto "%" não possui receita cadastrada.', p_nome_produto;
    END IF;

    -- Retornar receita
    RETURN QUERY
    SELECT 
        i.nome::TEXT,
        i.unidade_medida::TEXT,
        pi.qtd_utilizada::NUMERIC
    FROM produto_ingrediente pi
    JOIN ingrediente i ON i.cod_ingrediente = pi.cod_ingrediente
    WHERE pi.cod_produto = v_cod_produto;

END;
$$ LANGUAGE plpgsql;
