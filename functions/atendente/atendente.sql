-- FUNÇÃO: Procura um atendente pelo nome
CREATE OR REPLACE FUNCTION buscar_cod_atendente(p_nome TEXT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_cod INT;
BEGIN
    SELECT cod_atendente INTO v_cod
    FROM atendente
    WHERE nome ILIKE p_nome AND deletado = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Atendente % não encontrado ou inativo.', p_nome;
    END IF;

    RETURN v_cod;
END;
$$;