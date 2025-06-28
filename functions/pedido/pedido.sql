-- FUNÇÃO: Criar pedido com nome do cliente
CREATE OR REPLACE FUNCTION criar_pedido(p_nome_cliente TEXT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_cod_cliente INT;
    v_cod_endereco INT;
BEGIN
    -- Buscar cliente ativo
    SELECT cod_cliente INTO v_cod_cliente
    FROM cliente
    WHERE nome ILIKE p_nome_cliente AND ativo = TRUE;

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
    INSERT INTO pedido (
        cod_cliente, cod_endereco, data_hora_pedido,
        hora_prevista_entrega,
        status, valor_total
    )
    VALUES (
        v_cod_cliente, v_cod_endereco, NOW(),
        NOW() + INTERVAL '40 minutes',
        'EM ANDAMENTO', 0
    );
    RAISE NOTICE 'Pedido criado com sucesso para cliente %', p_nome_cliente;
END;
$$;

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
    -- Buscar cliente pelo nome
    SELECT cod_cliente INTO v_cod_cliente
    FROM cliente
    WHERE nome ILIKE p_nome_cliente AND ativo = TRUE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Cliente "%" não encontrado ou inativo.', p_nome_cliente;
    END IF;

    -- Verificar se o endereço existe 
    PERFORM 1
    FROM endereco
    WHERE cod_endereco = p_cod_endereco AND deletado = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Endereço código % não encontrado ou está deletado.', p_cod_endereco;
    END IF;

    -- Verificar se já existe associação
    PERFORM 1
    FROM cliente_endereco
    WHERE cod_cliente = v_cod_cliente AND cod_endereco = p_cod_endereco;

    IF FOUND THEN
        RAISE NOTICE 'Associação já existe entre cliente e endereço.';
        RETURN;
    END IF;

    -- Realizar associação
    INSERT INTO cliente_endereco (cod_cliente, cod_endereco)
    VALUES (v_cod_cliente, p_cod_endereco);

    RAISE NOTICE 'Cliente "%" associado ao endereço código % com sucesso.', p_nome_cliente, p_cod_endereco;
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
        WHERE cod_ingrediente = v_cod_ingrediente;

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
BEGIN
    -- Para cada produto no pedido
    FOR v_cod_produto, v_qtd_produto IN
        SELECT cod_produto, quantidade
        FROM item_pedido
        WHERE cod_pedido = p_cod_pedido
    LOOP
        -- Desconta do estoque os ingredientes usados nesse produto
        UPDATE ingrediente i
        SET qtd_estoque = i.qtd_estoque - (pi.qtd_utilizada * v_qtd_produto)
        FROM produto_ingrediente pi
        WHERE pi.cod_produto = v_cod_produto
          AND pi.cod_ingrediente = i.cod_ingrediente;
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
    SELECT SUM(ip.quantidade * p.valor_unitario) INTO v_total
    FROM item_pedido ip
    JOIN produto p ON p.cod_produto = ip.cod_produto
    WHERE ip.cod_pedido = p_cod_pedido;

    RETURN v_total;
END;
$$;

-- Funções auxiliares para buscar código pelo nome
-- Atendente
CREATE OR REPLACE FUNCTION buscar_cod_atendente(p_nome TEXT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_cod INT;
BEGIN
    SELECT cod_atendente INTO v_cod
    FROM atendente
    WHERE nome ILIKE p_nome AND ativo = TRUE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Atendente % não encontrado ou inativo.', p_nome;
    END IF;

    RETURN v_cod;
END;
$$;

-- Entregador
CREATE OR REPLACE FUNCTION buscar_cod_entregador(p_nome TEXT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_cod INT;
BEGIN
    SELECT cod_entregador INTO v_cod
    FROM entregador
    WHERE nome ILIKE p_nome AND ativo = TRUE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Entregador % não encontrado ou inativo.', p_nome;
    END IF;

    RETURN v_cod;
END;
$$;

-- Produto
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

-- FUNÇÃO: Adicionar item ao pedido
CREATE OR REPLACE FUNCTION adicionar_item_pedido(
    p_cod_pedido INT,
    p_nome_produto TEXT,
    p_quantidade INT DEFAULT 1
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_cod_produto INT;
    v_existe BOOLEAN;
    v_status_pedido TEXT;
BEGIN
    SELECT status INTO v_status_pedido
    FROM pedido
    WHERE cod_pedido = p_cod_pedido;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Pedido % não encontrado.', p_cod_pedido;
    ELSIF v_status_pedido != 'EM ANDAMENTO' THEN
        RAISE EXCEPTION 'Pedido % não está em andamento.', p_cod_pedido;
    END IF;

    v_cod_produto := buscar_cod_produto(p_nome_produto);

    PERFORM verificar_estoque_ingredientes(p_cod_pedido, v_cod_produto, p_quantidade);

    SELECT TRUE INTO v_existe
    FROM item_pedido
    WHERE cod_pedido = p_cod_pedido AND cod_produto = v_cod_produto;

    IF v_existe THEN
        UPDATE item_pedido
        SET quantidade = quantidade + p_quantidade
        WHERE cod_pedido = p_cod_pedido AND cod_produto = v_cod_produto;
    ELSE
        INSERT INTO item_pedido (cod_pedido, cod_produto, quantidade)
        VALUES (p_cod_pedido, v_cod_produto, p_quantidade);
    END IF;

    RAISE NOTICE 'Item % adicionado ao pedido %.', p_nome_produto, p_cod_pedido;
END;
$$;

-- FUNÇÃO: Finalizar pedido
CREATE OR REPLACE FUNCTION finalizar_pedido(
    p_cod_pedido INT, 
    p_nome_atendente TEXT, 
    p_nome_entregador TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_total NUMERIC;
    v_cod_atendente INT;
    v_cod_entregador INT;
BEGIN
    PERFORM 1 FROM pedido WHERE cod_pedido = p_cod_pedido AND status = 'EM ANDAMENTO';
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Pedido % não está EM ANDAMENTO ou não existe.', p_cod_pedido;
    END IF;

    v_cod_atendente := buscar_cod_atendente(p_nome_atendente);
    v_cod_entregador := buscar_cod_entregador(p_nome_entregador);

    PERFORM descontar_estoque_ingredientes(p_cod_pedido);
    v_total := calcular_valor_total_pedido(p_cod_pedido);

    UPDATE pedido
    SET status = 'SAIU PARA ENTREGA',
        valor_total = v_total,
        cod_atendente = v_cod_atendente,
        cod_entregador = v_cod_entregador
    WHERE cod_pedido = p_cod_pedido;

    RAISE NOTICE 'Pedido % finalizado. Total: R$ %', p_cod_pedido, v_total;
END;
$$;

-- FUNÇÃO: Marcar pedido como ENTREGUE
CREATE OR REPLACE FUNCTION entregar_pedido(p_cod_pedido INT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_status TEXT;
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

    -- Atualizar status e hora da entrega
    UPDATE pedido
    SET status = 'ENTREGUE',
        hora_entrega_real = NOW()
    WHERE cod_pedido = p_cod_pedido;

    RAISE NOTICE 'Pedido % marcado como ENTREGUE.', p_cod_pedido;
END;
$$;

-- FUNÇÃO: Cancelar pedido
CREATE OR REPLACE FUNCTION cancelar_pedido(p_cod_pedido INT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_status TEXT;
    v_cod_produto INT;
    v_qtd_produto INT;
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
            UPDATE ingrediente i
            SET qtd_estoque = i.qtd_estoque + (pi.qtd_utilizada * v_qtd_produto)
            FROM produto_ingrediente pi
            WHERE pi.cod_produto = v_cod_produto
              AND pi.cod_ingrediente = i.cod_ingrediente;
        END LOOP;
    END IF;

    -- Cancelar pedido
    UPDATE pedido
    SET status = 'CANCELADO'
    WHERE cod_pedido = p_cod_pedido;

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
    WHERE c.nome ILIKE p_nome_cliente AND p.status != 'ENTREGUE';
END;
$$;