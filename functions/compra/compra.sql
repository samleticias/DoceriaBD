-- FUNÇÃO: Criar compra com o nome do fornecedor
CREATE OR REPLACE FUNCTION criar_compra(p_nome_fornecedor TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_cod_fornecedor INT;
    v_cod_compra INT;
BEGIN
    -- Buscar fornecedor não deletado
    SELECT cod_fornecedor INTO v_cod_fornecedor
    FROM fornecedor
    WHERE nome ILIKE p_nome_fornecedor AND deletado = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Fornecedor "%" não encontrado ou inativo.', p_nome_fornecedor;
    END IF;

    -- Criar compra em andamento usando procedure genérica
    CALL inserir_dados(
        'compra',
        'cod_fornecedor, data_compra, valor_total, status',
        FORMAT('%s, NOW(), %s, %L',
            v_cod_fornecedor,
            0,
            'EM ANDAMENTO'
        )
    );

    RAISE NOTICE 'Compra criada com sucesso para o fornecedor "%".', p_nome_fornecedor;
END;
$$;

-- FUNÇÃO: Recalcula o valor total de uma compra e atualiza na tabela compra
CREATE OR REPLACE FUNCTION atualizar_valor_total_compra(p_cod_compra INT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_valor_total NUMERIC := 0;
BEGIN
    -- Calcular o valor total somando valor_unitario * quantidade de todos os itens da compra
    SELECT COALESCE(SUM(valor_unitario * quantidade), 0)
    INTO v_valor_total
    FROM item_compra
    WHERE cod_compra = p_cod_compra;

    -- Atualizar valor_total na tabela compra
    CALL atualizar_dados(
        'compra',
        'valor_total',
        v_valor_total::TEXT,
        FORMAT('cod_compra = %s', p_cod_compra)
    );

    RAISE NOTICE 'Valor total da compra % atualizado para R$ %.2f.', p_cod_compra, v_valor_total;
END;
$$;


-- FUNÇÃO: Adicionar novo item em um pedido
CREATE OR REPLACE FUNCTION adicionar_item_compra(
    p_cod_compra INT,
    p_nome_ingrediente TEXT,
    p_valor_unitario NUMERIC,
    p_quantidade INT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_cod_ingrediente INT;
    v_item_existe BOOLEAN := FALSE;
BEGIN
    -- Verificar se a compra existe e está EM ANDAMENTO
    PERFORM 1
    FROM compra
    WHERE cod_compra = p_cod_compra AND status = 'EM ANDAMENTO';

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Compra código % não encontrada ou não está EM ANDAMENTO.', p_cod_compra;
    END IF;

    IF p_quantidade <= 0 THEN
        RAISE EXCEPTION 'A quantidade do item deve ser maior que zero.';
    END IF;

    IF p_valor_unitario <= 0 THEN
        RAISE EXCEPTION 'O valor unitário deve ser maior que zero.';
    END IF;

    -- Buscar ingrediente não deletado
    SELECT cod_ingrediente INTO v_cod_ingrediente
    FROM ingrediente
    WHERE nome ILIKE p_nome_ingrediente AND deletado = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Ingrediente "%" não encontrado ou deletado.', p_nome_ingrediente;
    END IF;

    -- Verificar se o item já existe na compra
    SELECT TRUE INTO v_item_existe
    FROM item_compra
    WHERE cod_compra = p_cod_compra
      AND cod_ingrediente = v_cod_ingrediente;

    -- Se já existe, atualiza a quantidade e valor unitário
    IF v_item_existe THEN
        RAISE EXCEPTION 'Item "%" já existia na compra %.', p_nome_ingrediente, p_cod_compra;
    ELSE
        -- Insere novo item usando procedure genérica
        CALL inserir_dados(
            'item_compra',
            'cod_compra, cod_ingrediente, valor_unitario, quantidade',
            FORMAT('%s, %s, %s, %s', p_cod_compra, v_cod_ingrediente, p_valor_unitario, p_quantidade)
        );

        RAISE NOTICE 'Item "%" adicionado à compra %.', p_nome_ingrediente, p_cod_compra;
    END IF;

	-- Recalcula valor total da compra
	PERFORM atualizar_valor_total_compra(p_cod_compra);

END;
$$;


-- FUNÇÃO: Remover item de uma compra
CREATE OR REPLACE FUNCTION remover_item_compra(
    p_cod_compra INT,
    p_nome_ingrediente TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_cod_ingrediente INT;
BEGIN
    -- Verificar se a compra existe e está EM ANDAMENTO
    PERFORM 1
    FROM compra
    WHERE cod_compra = p_cod_compra AND status = 'EM ANDAMENTO';

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Compra código % não encontrada ou não está EM ANDAMENTO.', p_cod_compra;
    END IF;

    -- Buscar ingrediente não deletado
    SELECT cod_ingrediente INTO v_cod_ingrediente
    FROM ingrediente
    WHERE nome ILIKE p_nome_ingrediente AND deletado = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Ingrediente "%" não encontrado ou deletado.', p_nome_ingrediente;
    END IF;

    -- Verificar se o item existe na compra
    PERFORM 1
    FROM item_compra
    WHERE cod_compra = p_cod_compra
      AND cod_ingrediente = v_cod_ingrediente;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Item "%" não encontrado na compra %.', p_nome_ingrediente, p_cod_compra;
    END IF;

    -- Deletar item
    DELETE FROM item_compra
    WHERE cod_compra = p_cod_compra
      AND cod_ingrediente = v_cod_ingrediente;

	-- Atualizar valor total da compra
	PERFORM atualizar_valor_total_compra(p_cod_compra);

    RAISE NOTICE 'Item "%" removido da compra %.', p_nome_ingrediente, p_cod_compra;
END;
$$;

-- FUNÇÃO: Editar a quantidade de um item em uma compra
CREATE OR REPLACE FUNCTION editar_quantidade_item_compra(
    p_cod_compra INT,
    p_nome_ingrediente TEXT,
    p_nova_quantidade INT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_cod_ingrediente INT;
BEGIN
    -- Verificar se a compra existe e está EM ANDAMENTO
    PERFORM 1
    FROM compra
    WHERE cod_compra = p_cod_compra AND status = 'EM ANDAMENTO';

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Compra código % não encontrada ou não está EM ANDAMENTO.', p_cod_compra;
    END IF;

    -- Buscar ingrediente não deletado
    SELECT cod_ingrediente INTO v_cod_ingrediente
    FROM ingrediente
    WHERE nome ILIKE p_nome_ingrediente AND deletado = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Ingrediente "%" não encontrado ou deletado.', p_nome_ingrediente;
    END IF;

    -- Verificar se o item existe na compra
    PERFORM 1
    FROM item_compra
    WHERE cod_compra = p_cod_compra
      AND cod_ingrediente = v_cod_ingrediente;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Item "%" não encontrado na compra %.', p_nome_ingrediente, p_cod_compra;
    END IF;

    -- Atualizar quantidade usando procedure genérica
    CALL atualizar_dados(
        'item_compra',
        'quantidade',
        p_nova_quantidade::TEXT,
        FORMAT('cod_compra = %s AND cod_ingrediente = %s', p_cod_compra, v_cod_ingrediente)
    );

	-- Atualizar valor total da compra
	PERFORM atualizar_valor_total_compra(p_cod_compra);

    RAISE NOTICE 'Quantidade do item "%" na compra % atualizada para %.', p_nome_ingrediente, p_cod_compra, p_nova_quantidade;
END;
$$;


-- FUNÇÃO: Listar compras em aberto de um determinado fornecedor
CREATE OR REPLACE FUNCTION listar_compras_em_aberto(p_nome_fornecedor TEXT)
RETURNS TABLE (
    cod_compra INT,
    data_compra TIMESTAMP,
    valor_total NUMERIC,
    status TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN

    -- verifica se o fornecedor existe e não está deletado
    IF NOT EXISTS (
        SELECT 1 FROM fornecedor
        WHERE nome ILIKE p_nome_fornecedor
          AND deletado = FALSE
    ) THEN
        RAISE EXCEPTION 'Fornecedor "%" não encontrado ou está deletado.', p_nome_fornecedor;
    END IF;

    -- Retornar todas as compras em andamento de um fornecedor específico
    RETURN QUERY
    SELECT c.cod_compra, c.data_compra, c.valor_total, c.status::TEXT
    FROM compra c
    JOIN fornecedor f ON c.cod_fornecedor = f.cod_fornecedor
    WHERE f.nome ILIKE p_nome_fornecedor
      AND f.deletado = FALSE
      AND c.status = 'EM ANDAMENTO';
END;
$$;

-- FUNÇÃO: Finalizar compra
CREATE OR REPLACE FUNCTION finalizar_compra(p_cod_compra INT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_valor_total NUMERIC := 0;
BEGIN
    -- Verificar se a compra existe e está EM ANDAMENTO
    PERFORM 1
    FROM compra
    WHERE cod_compra = p_cod_compra AND status = 'EM ANDAMENTO';

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Compra código % não encontrada ou não está EM ANDAMENTO.', p_cod_compra;
    END IF;

    -- Verificar se existem itens na compra
    PERFORM 1
    FROM item_compra
    WHERE cod_compra = p_cod_compra;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Não é possível finalizar a compra %, pois não há itens cadastrados.', p_cod_compra;
    END IF;

    -- Atualizar estoque de cada ingrediente da compra
    UPDATE ingrediente i
    SET qtd_estoque = i.qtd_estoque + ic.quantidade
    FROM item_compra ic
    WHERE ic.cod_ingrediente = i.cod_ingrediente
      AND ic.cod_compra = p_cod_compra
      AND i.deletado = FALSE;

    -- Calcular valor total da compra
    SELECT SUM(valor_unitario * quantidade) INTO v_valor_total
    FROM item_compra
    WHERE cod_compra = p_cod_compra;

    -- Atualizar valor total
    CALL atualizar_dados(
        'compra',
        'valor_total',
        v_valor_total::TEXT,
        FORMAT('cod_compra = %s', p_cod_compra)
    );

    -- Atualizar status para FINALIZADA
    CALL atualizar_dados(
        'compra',
        'status',
        '''FINALIZADA''',
        FORMAT('cod_compra = %s', p_cod_compra)
    );

    RAISE NOTICE 'Compra % finalizada! Valor total: R$ %.2f.', p_cod_compra, v_valor_total;
END;
$$;

-- ============================================
-- FUNÇÃO: Consultar itens de uma compra
-- ============================================
CREATE OR REPLACE FUNCTION consultar_itens_compra(p_cod_compra INT)
RETURNS TABLE (
    ingrediente TEXT,
    quantidade INT,
    valor_unitario NUMERIC(10, 2),
    subtotal NUMERIC(10, 2)
)
AS $$
BEGIN
    -- Verificar se a compra existe
    PERFORM 1 FROM compra WHERE cod_compra = p_cod_compra;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Compra código % não encontrada.', p_cod_compra;
    END IF;

    -- Verificar se possui itens
    PERFORM 1 FROM item_compra WHERE cod_compra = p_cod_compra;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'A compra % não possui itens.', p_cod_compra;
    END IF;

    RETURN QUERY
    SELECT 
        i.nome::TEXT,
        ic.quantidade::INT,
        ic.valor_unitario::NUMERIC,
        (ic.quantidade * ic.valor_unitario)::NUMERIC
    FROM item_compra ic
    JOIN ingrediente i ON i.cod_ingrediente = ic.cod_ingrediente
    WHERE ic.cod_compra = p_cod_compra;

END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FUNÇÃO: Cancelar compra
-- Atualiza status para CANCELADA se a compra estiver EM ANDAMENTO
-- ============================================
CREATE OR REPLACE FUNCTION cancelar_compra(p_cod_compra INT)
RETURNS VOID
AS $$
DECLARE
    v_status STATUS_COMPRA_ENUM;
BEGIN
    -- Verifica se a compra existe
    SELECT status INTO v_status
    FROM compra
    WHERE cod_compra = p_cod_compra;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Compra código % não encontrada.', p_cod_compra;
    END IF;

    -- Só permite cancelar se estiver EM ANDAMENTO
    IF v_status != 'EM ANDAMENTO' THEN
        RAISE EXCEPTION 'Apenas compras EM ANDAMENTO podem ser canceladas. Situação atual: %.', v_status;
    END IF;

    -- Atualiza status para CANCELADA
    UPDATE compra
    SET status = 'CANCELADA'
    WHERE cod_compra = p_cod_compra;

    RAISE NOTICE 'Compra % cancelada com sucesso.', p_cod_compra;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION consultar_compra_por_id(p_cod_compra INT)
RETURNS TABLE (
    cod_compra INT,
    data_compra TIMESTAMP,
    status TEXT,
    valor_total NUMERIC,
    nome_fornecedor TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validação se a compra existe
    IF NOT EXISTS (
        SELECT 1 FROM compra c WHERE c.cod_compra = p_cod_compra
    ) THEN
        RAISE EXCEPTION 'Compra de código % não encontrada.', p_cod_compra;
    END IF;

    -- Consulta e retorno dos dados da compra
    RETURN QUERY
    SELECT 
        c.cod_compra,
        c.data_compra,
        c.status::TEXT,
        c.valor_total,
        f.nome::TEXT AS nome_fornecedor
    FROM compra c
    JOIN fornecedor f ON c.cod_fornecedor = f.cod_fornecedor
    WHERE c.cod_compra = p_cod_compra;

END;
$$;


