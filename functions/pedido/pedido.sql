-- FUNÇÃO: Criar pedido com nome do cliente
CREATE OR REPLACE FUNCTION criar_pedido(p_nome_cliente TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_cod_cliente INT;
    v_cod_endereco INT;
BEGIN
    -- Buscar cliente não deletado
    SELECT cod_cliente INTO v_cod_cliente
    FROM cliente
    WHERE nome ILIKE p_nome_cliente AND deletado = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Cliente não encontrado ou inativo.';
    END IF;

    -- Buscar endereço mais recente 
    SELECT ce.cod_endereco INTO v_cod_endereco
    FROM cliente_endereco ce
    WHERE ce.cod_cliente = v_cod_cliente
    ORDER BY ce.cod_endereco DESC LIMIT 1;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Endereço do cliente não encontrado.';
    END IF;

    -- Inserir pedido
    CALL inserir_dados(
        'pedido',
        'cod_cliente, cod_endereco, data_hora_pedido, hora_prevista_entrega, status, valor_total',
        FORMAT('%s, %s, NOW(), NOW() + INTERVAL ''40 minutes'', %L, %s',
            v_cod_cliente,
            v_cod_endereco,
            'EM ANDAMENTO',
            0
        )
    );

    RAISE NOTICE 'Pedido criado com sucesso para cliente %', p_nome_cliente;
END;
$$;

-- Função para verificar se há estoque suficiente dos ingredientes necessários
-- para adicionar uma quantidade de um produto a um pedido específico.
CREATE OR REPLACE FUNCTION verificar_estoque_ingredientes(
    p_cod_pedido INT,
    p_cod_produto INT,
    p_quantidade INT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_cod_ingrediente INT;
    v_qtd_utilizada NUMERIC;
    v_qtd_total_pedido NUMERIC;
    v_qtd_necessaria NUMERIC;
    v_estoque NUMERIC;
    v_nome_ingrediente TEXT;
BEGIN
    -- Para cada ingrediente do produto
    FOR v_cod_ingrediente, v_qtd_utilizada IN
        SELECT cod_ingrediente, qtd_utilizada
        FROM produto_ingrediente
        WHERE cod_produto = p_cod_produto
    LOOP
        -- Verifica se o ingrediente não está deletado
        PERFORM 1
        FROM ingrediente
        WHERE cod_ingrediente = v_cod_ingrediente AND deletado = FALSE;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Ingrediente código % não encontrado ou deletado.', v_cod_ingrediente;
        END IF;

        -- Calcula quanto desse ingrediente já está sendo utilizado no pedido atual
        SELECT COALESCE(SUM(ip.quantidade * pi.qtd_utilizada), 0)
        INTO v_qtd_total_pedido
        FROM item_pedido ip
        JOIN produto_ingrediente pi 
            ON pi.cod_produto = ip.cod_produto 
            AND pi.cod_ingrediente = v_cod_ingrediente
        WHERE ip.cod_pedido = p_cod_pedido;

        -- Soma a quantidade necessária adicional
        v_qtd_necessaria := v_qtd_total_pedido + (v_qtd_utilizada * p_quantidade);

        -- Busca estoque atual do ingrediente
        SELECT qtd_estoque, nome INTO v_estoque, v_nome_ingrediente
        FROM ingrediente
        WHERE cod_ingrediente = v_cod_ingrediente AND deletado = FALSE;

        -- Verifica se há estoque suficiente
        IF v_estoque < v_qtd_necessaria THEN
            RAISE EXCEPTION 
                'Estoque insuficiente do ingrediente "%". Necessário total no pedido: %, Disponível: %.',
                v_nome_ingrediente, v_qtd_necessaria, v_estoque;
        END IF;
    END LOOP;
END;
$$;

-- Função para descontar do estoque os ingredientes de todos os itens de um pedido
CREATE OR REPLACE FUNCTION descontar_estoque_ingredientes(p_cod_pedido INT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_cod_produto INT;
    v_qtd_produto INT;
    v_cod_ingrediente INT;
    v_qtd_utilizada NUMERIC;
    v_novo_estoque NUMERIC;
BEGIN
    -- Para cada produto no pedido
    FOR v_cod_produto, v_qtd_produto IN
        SELECT cod_produto, quantidade
        FROM item_pedido
        WHERE cod_pedido = p_cod_pedido
    LOOP
        -- Para cada ingrediente do produto
        FOR v_cod_ingrediente, v_qtd_utilizada IN
            SELECT cod_ingrediente, qtd_utilizada
            FROM produto_ingrediente
            WHERE cod_produto = v_cod_produto
        LOOP
            -- Calcular novo estoque
            SELECT qtd_estoque - (v_qtd_utilizada * v_qtd_produto)
            INTO v_novo_estoque
            FROM ingrediente
            WHERE cod_ingrediente = v_cod_ingrediente
              AND deletado = FALSE;

            -- Atualizar usando procedure genérica
            CALL atualizar_dados(
                'ingrediente',
                'qtd_estoque',
                v_novo_estoque::TEXT,
                FORMAT('cod_ingrediente = %s AND deletado = FALSE', v_cod_ingrediente)
            );
        END LOOP;
    END LOOP;
END;
$$;

-- Função que calcula o valor total do pedido
CREATE OR REPLACE FUNCTION calcular_valor_total_pedido(p_cod_pedido INT)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    -- Soma o total multiplicando quantidade x valor unitário dos produtos do pedido
    SELECT COALESCE(SUM(ip.quantidade * p.valor_unitario), 0) INTO v_total 
    FROM item_pedido ip
    JOIN produto p ON p.cod_produto = ip.cod_produto
    WHERE ip.cod_pedido = p_cod_pedido;

    RETURN v_total;
END;
$$;

-- FUNÇÃO: Adicionar item ao pedido
CREATE OR REPLACE FUNCTION adicionar_item_pedido(
    p_cod_pedido INT,
    p_nome_produto TEXT,
    p_quantidade INT DEFAULT 1
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_cod_produto INT;
    v_existe BOOLEAN := FALSE;
    v_status_pedido TEXT;
    v_nova_quantidade INT;
    v_novo_valor_total NUMERIC;
BEGIN
    -- Verifica se a quantidade do item é maior que zero
    IF p_quantidade <= 0 THEN   
        RAISE EXCEPTION 'A quantidade do item deve ser maior que zero.';
    END IF;

    -- Verifica status do pedido
    SELECT status INTO v_status_pedido
    FROM pedido
    WHERE cod_pedido = p_cod_pedido;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Pedido % não encontrado.', p_cod_pedido;
    ELSIF v_status_pedido != 'EM ANDAMENTO' THEN
        RAISE EXCEPTION 'Pedido % não está em andamento.', p_cod_pedido;
    END IF;

    -- Buscar o código do produto pelo nome
    v_cod_produto := buscar_cod_produto(p_nome_produto);

    -- Verifica se há ingredientes suficientes
    PERFORM verificar_estoque_ingredientes(p_cod_pedido, v_cod_produto, p_quantidade);

    -- Verifica se o item já existe
    SELECT TRUE INTO v_existe
    FROM item_pedido
    WHERE cod_pedido = p_cod_pedido AND cod_produto = v_cod_produto;

    IF v_existe THEN
		-- o que realmente deve acontecer
		RAISE EXCEPTION 'Item "%" já existia no pedido %.', p_nome_produto, p_cod_pedido;
  		RETURN;
    ELSE
        -- Insere novo item usando procedure genérica
        CALL inserir_dados(
            'item_pedido',
            'cod_pedido, cod_produto, quantidade',
            FORMAT('%s, %s, %s', p_cod_pedido, v_cod_produto, p_quantidade)
        );
    END IF;

    -- Recalcula valor total do pedido
	PERFORM atualizar_valor_total_pedido(p_cod_pedido);

    RAISE NOTICE 'Item % adicionado ao pedido %.', p_nome_produto, p_cod_pedido;
END;
$$;

-- -- FUNÇÃO: Finalizar pedido
CREATE OR REPLACE FUNCTION finalizar_pedido(
    p_cod_pedido INT, 
    p_nome_atendente TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_total NUMERIC;
    v_cod_atendente INT;
    v_status TEXT;
BEGIN
    -- Verifica se o pedido existe e obtém o status atual
    SELECT status INTO v_status
    FROM pedido
    WHERE cod_pedido = p_cod_pedido;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Pedido % não encontrado.', p_cod_pedido;
    END IF;

    -- Validações de status
    IF v_status = 'SAIU PARA ENTREGA' THEN
        RAISE EXCEPTION 'Pedido % já foi finalizado e saiu para entrega.', p_cod_pedido;
    ELSIF v_status = 'ENTREGUE' THEN
        RAISE EXCEPTION 'Pedido % já foi entregue. Não pode ser finalizado novamente.', p_cod_pedido;
    ELSIF v_status = 'CANCELADO' THEN
        RAISE EXCEPTION 'Pedido % foi cancelado e não pode ser finalizado.', p_cod_pedido;
    ELSIF v_status != 'EM PREPARO' THEN
        RAISE EXCEPTION 'Pedido % está em andamento e deve ser pago antes de finalizar. Status: "%".', p_cod_pedido, v_status;
    END IF;

    -- Busca os códigos do atendente envolvido
    v_cod_atendente := buscar_cod_atendente(p_nome_atendente);

    -- Debita ingredientes do estoque
    PERFORM descontar_estoque_ingredientes(p_cod_pedido);

    -- Calcula o valor total do pedido
    v_total := calcular_valor_total_pedido(p_cod_pedido);

    -- Atualiza status
    CALL atualizar_dados(
        'pedido',
        'status',
        '''SAIU PARA ENTREGA''',
        FORMAT('cod_pedido = %s', p_cod_pedido)
    );

    -- Atualiza valor total
    CALL atualizar_dados(
        'pedido',
        'valor_total',
        v_total::TEXT,
        FORMAT('cod_pedido = %s', p_cod_pedido)
    );

    -- Atualiza atendente
    CALL atualizar_dados(
        'pedido',
        'cod_atendente',
        v_cod_atendente::TEXT,
        FORMAT('cod_pedido = %s', p_cod_pedido)
    );

    RAISE NOTICE 'Pedido % finalizado com sucesso. Total: R$ %', p_cod_pedido, v_total;
END;
$$;

-- FUNÇÃO: Realizar pagamento do pedido
CREATE OR REPLACE FUNCTION pagar_pedido(
    p_cod_pedido INT,
    p_nome_tipo_pagamento TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_cod_tipo_pagamento INT;
    v_status_pedido TEXT;
    v_pago BOOLEAN;
    v_qtd_itens INT;
BEGIN
    -- Verificar se o pedido existe e obter status e se já está pago
    SELECT status, pago INTO v_status_pedido, v_pago
    FROM pedido
    WHERE cod_pedido = p_cod_pedido;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Pedido % não encontrado.', p_cod_pedido;
    END IF;

    -- Verificar se o pedido já foi pago
    IF v_pago THEN
        RAISE EXCEPTION 'Pedido % já foi pago.', p_cod_pedido;
    END IF;

    -- Verificar se o pedido já foi cancelado
    IF v_status_pedido = 'CANCELADO' THEN
        RAISE EXCEPTION 'Pedido % já foi cancelado e não pode ser pago.', p_cod_pedido;
    END IF;

    -- Verificar se o pedido já foi entregue
    IF v_status_pedido = 'ENTREGUE' THEN
        RAISE EXCEPTION 'Pedido % já foi entregue e não pode ser pago.', p_cod_pedido;
    END IF;

    -- Verificar se o status permite pagamento
    IF v_status_pedido != 'EM ANDAMENTO' THEN
        RAISE EXCEPTION 'Pedido % não pode ser pago no status atual: "%".', p_cod_pedido, v_status_pedido;
    END IF;

    -- Verificar se o pedido possui itens
    SELECT COUNT(*) INTO v_qtd_itens
    FROM item_pedido
    WHERE cod_pedido = p_cod_pedido;

    IF v_qtd_itens = 0 THEN
        RAISE EXCEPTION 'Pedido % não possui itens e não pode ser pago.', p_cod_pedido;
    END IF;

    -- Buscar código do tipo de pagamento
    SELECT cod_tipo_pagamento INTO v_cod_tipo_pagamento
    FROM tipo_pagamento
    WHERE nome ILIKE p_nome_tipo_pagamento;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tipo de pagamento "%" não encontrado.', p_nome_tipo_pagamento;
    END IF;

    -- Atualizar campos usando as procedures
    CALL atualizar_dados(
        'pedido',
        'pago',
        'TRUE',
        FORMAT('cod_pedido = %s', p_cod_pedido)
    );

    CALL atualizar_dados(
        'pedido',
        'cod_tipo_pagamento',
        v_cod_tipo_pagamento::TEXT,
        FORMAT('cod_pedido = %s', p_cod_pedido)
    );

    CALL atualizar_dados(
        'pedido',
        'status',
        '''EM PREPARO''',
        FORMAT('cod_pedido = %s', p_cod_pedido)
    );

    RAISE NOTICE 'Pagamento registrado com sucesso para o pedido % usando "%".', p_cod_pedido, p_nome_tipo_pagamento;
END;
$$;

-- FUNÇÃO: Marcar pedido como ENTREGUE
CREATE OR REPLACE FUNCTION entregar_pedido(
	p_cod_pedido INT,
	p_nome_entregador TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_status TEXT;
	v_cod_entregador INT;
BEGIN
    -- Buscar status atual do pedido
    SELECT status INTO v_status
    FROM pedido
    WHERE cod_pedido = p_cod_pedido;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Pedido % não existe.', p_cod_pedido;
    ELSIF v_status = 'CANCELADO' THEN
        RAISE EXCEPTION 'Pedido % já foi CANCELADO e não pode ser entregue.', p_cod_pedido;
    ELSIF v_status = 'ENTREGUE' THEN
        RAISE EXCEPTION 'Pedido % já foi ENTREGUE.', p_cod_pedido;
    ELSIF v_status != 'SAIU PARA ENTREGA' THEN
        RAISE EXCEPTION 'Pedido % não está pronto para entrega (status atual: %).', p_cod_pedido, v_status;
    END IF;

	-- busca pelo código do entregador envolvido
	v_cod_entregador := buscar_cod_entregador(p_nome_entregador);

    -- Atualizar status
    CALL atualizar_dados(
        'pedido',
        'status',
        '''ENTREGUE''',
        FORMAT('cod_pedido = %s', p_cod_pedido)
    );

    -- Atualizar hora da entrega real 
    CALL atualizar_dados(
        'pedido',
        'hora_entrega_real',
        '''' || NOW() || '''',
        FORMAT('cod_pedido = %s', p_cod_pedido)
    );

	-- Atualiza entregador
    CALL atualizar_dados(
        'pedido',
        'cod_entregador',
        v_cod_entregador::TEXT,
        FORMAT('cod_pedido = %s', p_cod_pedido)
    );

    RAISE NOTICE 'Pedido % marcado como ENTREGUE.', p_cod_pedido;
END;
$$;

-- FUNÇÃO: Cancelar pedido
CREATE OR REPLACE FUNCTION cancelar_pedido(
	p_cod_pedido INT,
	p_motivo_cancelamento VARCHAR(255) DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_status TEXT;
    v_cod_produto INT;
    v_qtd_produto INT;
    v_cod_ingrediente INT;
    v_qtd_utilizada NUMERIC;
    v_estoque_atual NUMERIC;
    v_novo_estoque NUMERIC;
BEGIN
    -- Buscar status atual do pedido
    SELECT status INTO v_status
    FROM pedido
    WHERE cod_pedido = p_cod_pedido;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Pedido % não existe.', p_cod_pedido;
    ELSIF v_status = 'ENTREGUE' THEN
        RAISE EXCEPTION 'Pedido % já foi ENTREGUE e não pode ser cancelado.', p_cod_pedido;
    ELSIF v_status = 'CANCELADO' THEN
        RAISE EXCEPTION 'Pedido % já foi CANCELADO.', p_cod_pedido;
    END IF;

    -- Se o pedido já teve ingredientes debitados, devolve ao estoque
    IF v_status IN ('EM PREPARO', 'SAIU PARA ENTREGA') THEN
        FOR v_cod_produto, v_qtd_produto IN
            SELECT cod_produto, quantidade
            FROM item_pedido
            WHERE cod_pedido = p_cod_pedido
        LOOP
            FOR v_cod_ingrediente, v_qtd_utilizada IN
                SELECT cod_ingrediente, qtd_utilizada
                FROM produto_ingrediente
                WHERE cod_produto = v_cod_produto
            LOOP
                SELECT qtd_estoque INTO v_estoque_atual
                FROM ingrediente
                WHERE cod_ingrediente = v_cod_ingrediente;

                v_novo_estoque := v_estoque_atual + (v_qtd_utilizada * v_qtd_produto);

                CALL atualizar_dados(
                    'ingrediente',
                    'qtd_estoque',
                    v_novo_estoque::TEXT,
                    FORMAT('cod_ingrediente = %s', v_cod_ingrediente)
                );
            END LOOP;
        END LOOP;
    END IF;

    -- Cancelar pedido (atualizar status)
    CALL atualizar_dados(
        'pedido',
        'status',
        '''CANCELADO''',
        FORMAT('cod_pedido = %s', p_cod_pedido)
    );

	-- Atualizar observação se motivo foi passado
    IF p_motivo_cancelamento IS NOT NULL THEN
        CALL atualizar_dados(
            'pedido',
            'observacao',
            FORMAT('''%s''', p_motivo_cancelamento),
            FORMAT('cod_pedido = %s', p_cod_pedido)
        );
    END IF;

    RAISE NOTICE 'Pedido % cancelado. Ingredientes devolvidos ao estoque.', p_cod_pedido;
END;
$$;

-- FUNÇÃO: Listar pedidos em aberto (por nome do cliente)
CREATE OR REPLACE FUNCTION listar_pedidos_abertos(p_nome_cliente TEXT)
RETURNS TABLE (
    cod_pedido INT,
    nome_cliente TEXT,
    status TEXT,
    data TIMESTAMP,
    valor_total NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.cod_pedido, 
        c.nome::TEXT, 
        p.status::TEXT,  -- CAST explicito do enum para text
        p.data_hora_pedido, 
        p.valor_total
    FROM pedido p
    JOIN cliente c ON p.cod_cliente = c.cod_cliente
    WHERE c.nome ILIKE p_nome_cliente AND (p.status != 'ENTREGUE' AND p.status != 'CANCELADO');
END;
$$;

-- FUNÇÃO: Recalcula o valor total de um pedido e atualiza na tabela pedido
CREATE OR REPLACE FUNCTION atualizar_valor_total_pedido(p_cod_pedido INT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_valor_total NUMERIC := 0;
BEGIN
    -- Calcular o valor total somando valor_unitario * quantidade de todos os itens do pedido
    SELECT COALESCE(SUM(p.valor_unitario * ip.quantidade), 0)
    INTO v_valor_total
    FROM item_pedido ip
    JOIN produto p ON p.cod_produto = ip.cod_produto
    WHERE ip.cod_pedido = p_cod_pedido;

    -- Atualiza o valor_total na tabela pedido
    CALL atualizar_dados(
        'pedido',
        'valor_total',
        v_valor_total::TEXT,
        FORMAT('cod_pedido = %s', p_cod_pedido)
    );

    RAISE NOTICE 'Valor total do pedido % atualizado para R$ %.2f.', p_cod_pedido, v_valor_total;
END;
$$;

-- FUNÇÃO: Remover item de um pedido
CREATE OR REPLACE FUNCTION remover_item_pedido(
	p_cod_pedido INT,
    p_nome_produto TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
	v_cod_produto INT;
BEGIN
	-- Verificar se o pedido existe e está EM ANDAMENTO
	PERFORM 1 
	FROM pedido
	WHERE cod_pedido = p_cod_pedido and status = 'EM ANDAMENTO';
	
	IF NOT FOUND THEN
		RAISE EXCEPTION 'Pedido de código % não encontrado ou não está EM ANDAMENTO.', p_cod_pedido;
	END IF;
	
	-- Buscar produto não deletado
	SELECT cod_produto INTO v_cod_produto 
	FROM produto
	WHERE nome ILIKE p_nome_produto AND deletado = FALSE;
	
	IF NOT FOUND THEN
        RAISE EXCEPTION 'Produto "%" não encontrado ou deletado.', p_nome_produto;
    END IF;
	
	-- Verificar se o item existe no pedido
    PERFORM 1
    FROM item_pedido
    WHERE cod_pedido = p_cod_pedido
      AND cod_produto = v_cod_produto;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Item "%" não encontrado no pedido %.', p_nome_produto, p_cod_pedido;
    END IF;
	
	 -- Deletar item do pedido
    DELETE FROM item_pedido
    WHERE cod_pedido = p_cod_pedido
    AND cod_produto= v_cod_produto;

    -- Atualizar valor total do pedido
	PERFORM atualizar_valor_total_pedido(p_cod_pedido);
	
	RAISE NOTICE 'Item "%" removido do pedido %.', p_nome_produto, p_cod_pedido;
END;
$$;

-- FUNÇÃO: Editar a quantidade de um item em um pedido
CREATE OR REPLACE FUNCTION editar_quantidade_item_pedido(
    p_cod_pedido INT,
    p_nome_produto TEXT,
    p_nova_quantidade INT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_cod_produto INT;
BEGIN
    -- Verificar se o pedido existe e está EM ANDAMENTO
    PERFORM 1
    FROM pedido
    WHERE cod_pedido = p_cod_pedido AND status = 'EM ANDAMENTO';

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Pedido de código % não encontrado ou não está EM ANDAMENTO.', p_cod_pedido;
    END IF;

    -- Buscar produto não deletado
    SELECT cod_produto INTO v_cod_produto
    FROM produto
    WHERE nome ILIKE p_nome_produto AND deletado = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Produto "%" não encontrado ou deletado.', p_nome_produto;
    END IF;

    -- Verificar se o item existe no pedido
    PERFORM 1
    FROM item_pedido 
    WHERE cod_pedido = p_cod_pedido
      AND cod_produto = v_cod_produto;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Item "%" não encontrado no pedido %.', p_nome_produto, p_cod_pedido;
    END IF;

    -- Atualizar quantidade usando procedure genérica
    CALL atualizar_dados(
        'item_pedido',
        'quantidade',
        p_nova_quantidade::TEXT,
        FORMAT('cod_pedido = %s AND cod_produto = %s', p_cod_pedido, v_cod_produto)
    );

	-- Atualizar valor total do pedido
	PERFORM atualizar_valor_total_pedido(p_cod_pedido);

    RAISE NOTICE 'Quantidade do item "%" no pedido % atualizada para %.', p_nome_produto, p_cod_pedido, p_nova_quantidade;
END;
$$;

-- ============================================
-- FUNÇÃO: Consultar itens de um pedido
-- ============================================
CREATE OR REPLACE FUNCTION consultar_itens_pedido(p_cod_pedido INT)
RETURNS TABLE (
    produto TEXT,
    quantidade INT,
    valor_unitario NUMERIC(10, 2),
    subtotal NUMERIC(10, 2)
)
SECURITY DEFINER
AS $$
BEGIN
    -- Verificar se o pedido existe
    PERFORM 1 FROM pedido WHERE cod_pedido = p_cod_pedido;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Pedido código % não encontrado.', p_cod_pedido;
    END IF;

    -- Verificar se possui itens
    PERFORM 1 FROM item_pedido WHERE cod_pedido = p_cod_pedido;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'O pedido % não possui itens.', p_cod_pedido;
    END IF;

    RETURN QUERY
    SELECT 
        p.nome::TEXT,
        ip.quantidade::INT,
        p.valor_unitario::NUMERIC,
        (ip.quantidade * p.valor_unitario)::NUMERIC
    FROM item_pedido ip
    JOIN produto p ON p.cod_produto = ip.cod_produto
    WHERE ip.cod_pedido = p_cod_pedido;

END;
$$ LANGUAGE plpgsql;
