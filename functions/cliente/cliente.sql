-- FUNÇÃO: associar cliente a endereço já cadastrado 
CREATE OR REPLACE FUNCTION associar_cliente_endereco(
    p_nome_cliente TEXT,
    p_cod_endereco INT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_cod_cliente INT;
BEGIN
    -- Busca cliente pelo nome
    SELECT cod_cliente INTO v_cod_cliente
    FROM cliente
    WHERE nome ILIKE p_nome_cliente AND ativo = TRUE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Cliente "%" não encontrado ou inativo.', p_nome_cliente;
    END IF;

    -- Verifica se o endereço existe 
    PERFORM 1
    FROM endereco
    WHERE cod_endereco = p_cod_endereco AND deletado = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Endereço código % não encontrado ou está deletado.', p_cod_endereco;
    END IF;

    -- Verifica se já existe associação
    PERFORM 1
    FROM cliente_endereco
    WHERE cod_cliente = v_cod_cliente AND cod_endereco = p_cod_endereco;

    IF FOUND THEN
        RAISE NOTICE 'Associação já existe entre cliente e endereço.';
        RETURN;
    END IF;

    CALL inserir_dados(
        'cliente_endereco',
        'cod_cliente, cod_endereco',
        FORMAT('%s, %s', v_cod_cliente, p_cod_endereco)
    );

    RAISE NOTICE 'Cliente "%" associado ao endereço código % com sucesso.', p_nome_cliente, p_cod_endereco;
END;
$$;