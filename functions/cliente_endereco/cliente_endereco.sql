-- ============================================
-- FUNÇÃO: Vincular cliente a um endereço
-- ============================================
CREATE OR REPLACE FUNCTION vincular_cliente_endereco(p_nome_cliente TEXT, p_cod_endereco INT)
RETURNS VOID
AS $$
DECLARE
    v_cod_cliente INT;
BEGIN
    -- Valida cliente
    SELECT cod_cliente INTO v_cod_cliente
    FROM cliente
    WHERE nome ILIKE p_nome_cliente AND deletado = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Cliente "%" não encontrado ou deletado.', p_nome_cliente;
    END IF;

    -- Valida endereço
    PERFORM 1 FROM endereco WHERE cod_endereco = p_cod_endereco AND deletado = FALSE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Endereço código % não encontrado ou deletado.', p_cod_endereco;
    END IF;

    -- Verifica se já existe esse vínculo
    PERFORM 1 FROM cliente_endereco WHERE cod_cliente = v_cod_cliente AND cod_endereco = p_cod_endereco;
    IF FOUND THEN
        RAISE EXCEPTION 'Cliente "%" já está vinculado a esse endereço.', p_nome_cliente;
    END IF;

    -- Realiza o vínculo
    INSERT INTO cliente_endereco (cod_cliente, cod_endereco)
    VALUES (v_cod_cliente, p_cod_endereco);

    RAISE NOTICE 'Cliente "%" vinculado ao endereço % com sucesso.', p_nome_cliente, p_cod_endereco;
END;
$$ LANGUAGE plpgsql;
