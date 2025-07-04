-- ============================================
-- FUNÇÃO: Adicionar ingrediente a receita de um produto
-- ============================================
CREATE OR REPLACE FUNCTION adicionar_ingrediente_produto(
    p_nome_produto TEXT,
    p_nome_ingrediente TEXT,
    p_qtd NUMERIC
)
RETURNS VOID
AS $$
DECLARE
    v_cod_produto INT;
    v_cod_ingrediente INT;
BEGIN
    -- Valida nome produto
    SELECT cod_produto INTO v_cod_produto
    FROM produto
    WHERE nome ILIKE p_nome_produto AND deletado = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Produto "%" não encontrado.', p_nome_produto;
    END IF;

    -- Valida nome ingrediente
    SELECT cod_ingrediente INTO v_cod_ingrediente
    FROM ingrediente
    WHERE nome ILIKE p_nome_ingrediente AND deletado = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Ingrediente "%" não encontrado.', p_nome_ingrediente;
    END IF;

    -- Valida quantidade
    IF p_qtd IS NULL OR p_qtd <= 0 THEN
        RAISE EXCEPTION 'Quantidade deve ser maior que zero.';
    END IF;

    -- Verifica se ingrediente já está na receita
    PERFORM 1 FROM produto_ingrediente
    WHERE cod_produto = v_cod_produto AND cod_ingrediente = v_cod_ingrediente;

    IF FOUND THEN
        RAISE EXCEPTION 'Ingrediente "%" já está na receita do produto "%".', p_nome_ingrediente, p_nome_produto;
    END IF;

    -- Insere ingrediente na receita
    INSERT INTO produto_ingrediente (cod_produto, cod_ingrediente, qtd_utilizada)
    VALUES (v_cod_produto, v_cod_ingrediente, p_qtd);

    RAISE NOTICE 'Ingrediente "%" adicionado na receita de "%".', p_nome_ingrediente, p_nome_produto;
END;
$$ LANGUAGE plpgsql;
