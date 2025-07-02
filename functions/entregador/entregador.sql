-- FUNÇÃO: Procura um entregador pelo nome
CREATE OR REPLACE FUNCTION buscar_cod_entregador(p_nome TEXT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_cod INT;
BEGIN
    SELECT cod_entregador INTO v_cod
    FROM entregador
    WHERE nome ILIKE p_nome AND deletado = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Entregador % não encontrado ou inativo.', p_nome;
    END IF;

    RETURN v_cod;
END;
$$;