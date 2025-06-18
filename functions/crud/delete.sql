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


