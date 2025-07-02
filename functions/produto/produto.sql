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