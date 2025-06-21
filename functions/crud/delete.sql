-- FUNÇÃO PARA DELETAR LÓGICO DE UM CLIENTE (PELO NOME)
CREATE OR REPLACE FUNCTION deletar_cliente(p_nome_cliente VARCHAR)
RETURNS VOID 
LANGUAGE plpgsql
AS $$
DECLARE
    v_cod_cliente INTEGER;
BEGIN
    -- Buscar o cliente ativo pelo nome
    SELECT cod_cliente 
    INTO v_cod_cliente 
    FROM cliente 
    WHERE nome ILIKE p_nome_cliente AND ativo = TRUE;

    -- Se não encontrar, lança exceção
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Cliente "%" não encontrado ou já inativo.', p_nome_cliente;
    END IF;

    -- Atualizar campo ativo para false
    UPDATE cliente
    SET ativo = FALSE
    WHERE cod_cliente = v_cod_cliente;

    -- Feedback de sucesso
    RAISE NOTICE 'Cliente "%" desativado com sucesso.', p_nome_cliente;

END;
$$;

-- FUNÇÃO PARA DELETAR LÓGICO DE UM ATENDENTE (PELO NOME)
CREATE OR REPLACE FUNCTION deletar_atendente(p_nome_atendente VARCHAR)
RETURNS VOID 
LANGUAGE plpgsql
AS $$
DECLARE
    v_cod_atendente INTEGER;
BEGIN
    SELECT cod_atendente 
    INTO v_cod_atendente 
    FROM atendente 
    WHERE nome ILIKE p_nome_atendente AND ativo = TRUE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Atendente "%" não encontrado ou já inativo.', p_nome_atendente;
    END IF;

    UPDATE atendente
    SET ativo = FALSE
    WHERE cod_atendente = v_cod_atendente;

    RAISE NOTICE 'Atendente "%" desativado com sucesso.', p_nome_atendente;

END;
$$;

-- FUNÇÃO PARA DELETAR LÓGICO DE UM ENTREGADOR (PELO NOME)
CREATE OR REPLACE FUNCTION deletar_entregador(p_nome_entregador VARCHAR)
RETURNS VOID 
LANGUAGE plpgsql
AS $$
DECLARE
    v_cod_entregador INTEGER;
BEGIN
    SELECT cod_entregador 
    INTO v_cod_entregador 
    FROM entregador 
    WHERE nome ILIKE p_nome_entregador AND ativo = TRUE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Entregador "%" não encontrado ou já inativo.', p_nome_entregador;
    END IF;

    UPDATE entregador
    SET ativo = FALSE
    WHERE cod_entregador = v_cod_entregador;

    RAISE NOTICE 'Entregador "%" desativado com sucesso.', p_nome_entregador;

END;
$$;

-- FUNÇÃO PARA DELETAR LÓGICO DE UM FORNECEDOR (PELO NOME)
CREATE OR REPLACE FUNCTION deletar_fornecedor(p_nome_fornecedor VARCHAR)
RETURNS VOID 
LANGUAGE plpgsql
AS $$
DECLARE
    v_cod_fornecedor INTEGER;
BEGIN
    SELECT cod_fornecedor 
    INTO v_cod_fornecedor 
    FROM fornecedor 
    WHERE nome ILIKE p_nome_fornecedor AND ativo = TRUE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Fornecedor "%" não encontrado ou já inativo.', p_nome_fornecedor;
    END IF;

    UPDATE fornecedor
    SET ativo = FALSE
    WHERE cod_fornecedor = v_cod_fornecedor;

    RAISE NOTICE 'Fornecedor "%" desativado com sucesso.', p_nome_fornecedor;

END;
$$;

-- FUNÇÃO PARA DELETAR LÓGICO DE UM PRODUTO (PELO NOME)
CREATE OR REPLACE FUNCTION deletar_produto(p_nome_produto VARCHAR)
RETURNS VOID 
LANGUAGE plpgsql
AS $$
DECLARE
    v_cod_produto INTEGER;
BEGIN
    SELECT cod_produto 
    INTO v_cod_produto 
    FROM produto 
    WHERE nome ILIKE p_nome_produto AND deletado = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Produto "%" não encontrado ou já inativo.', p_nome_produto;
    END IF;

    UPDATE produto
    SET deletado = TRUE
    WHERE cod_produto = v_cod_produto;

    RAISE NOTICE 'Produto "%" removido com sucesso.', p_nome_produto;
END;
$$;

-- FUNÇÃO PARA DELETAR LÓGICO DE UM INGREDIENTE (PELO NOME)
CREATE OR REPLACE FUNCTION deletar_ingrediente(p_nome_ingrediente VARCHAR)
RETURNS VOID 
LANGUAGE plpgsql
AS $$
DECLARE
    v_cod_ingrediente INTEGER;
BEGIN
    SELECT cod_ingrediente 
    INTO v_cod_ingrediente 
    FROM ingrediente 
    WHERE nome ILIKE p_nome_ingrediente AND deletado = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Ingrediente "%" não encontrado ou já inativo.', p_nome_ingrediente;
    END IF;

    UPDATE ingrediente
    SET deletado = TRUE
    WHERE cod_ingrediente = v_cod_ingrediente;

    RAISE NOTICE 'Ingrediente "%" removido com sucesso.', p_nome_ingrediente;
END;
$$;

-- FUNÇÃO PARA DELETAR LÓGICO DE UM TIPO DE PAGAMENTO (PELO NOME)
CREATE OR REPLACE FUNCTION deletar_tipo_pagamento(p_nome_tipo_pagamento VARCHAR)
RETURNS VOID 
LANGUAGE plpgsql
AS $$
DECLARE
    v_cod_tipo_pagamento INTEGER;
BEGIN
    SELECT cod_tipo_pagamento 
    INTO v_cod_tipo_pagamento 
    FROM tipo_pagamento 
    WHERE nome ILIKE p_nome_tipo_pagamento AND deletado = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tipo de pagamento "%" não encontrado ou já inativo.', p_nome_tipo_pagamento;
    END IF;

    UPDATE tipo_pagamento
    SET deletado = TRUE
    WHERE cod_tipo_pagamento = v_cod_tipo_pagamento;

    RAISE NOTICE 'Tipo de pagamento "%" removido com sucesso.', p_nome_tipo_pagamento;
END;
$$;

-- FUNÇÃO PARA DELETAR LÓGICO DE UM ENDEREÇO (PELOS CAMPOS DO ENDEREÇO)
CREATE OR REPLACE FUNCTION deletar_endereco(
    p_rua VARCHAR,
    p_numero VARCHAR,
    p_bairro VARCHAR,
    p_cep VARCHAR,
    p_complemento VARCHAR
)
RETURNS VOID 
LANGUAGE plpgsql
AS $$
DECLARE
    v_cod_endereco INTEGER;
BEGIN
    SELECT cod_endereco
    INTO v_cod_endereco
    FROM endereco
    WHERE rua ILIKE p_rua
      AND numero = p_numero
      AND bairro ILIKE p_bairro
      AND cep = p_cep
      AND complemento ILIKE p_complemento
      AND deletado = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Endereço não encontrado ou já deletado.';
    END IF;

    UPDATE endereco
    SET deletado = TRUE
    WHERE cod_endereco = v_cod_endereco;

    RAISE NOTICE 'Endereço removido com sucesso.';
END;
$$;
