-- ============================================
-- FUNÇÃO: Relatório de Pedidos Abertos do Cliente
-- Lista os pedidos não finalizados de um cliente informado
-- ============================================
CREATE OR REPLACE FUNCTION relatorio_pedidos_abertos_cliente(p_nome_cliente TEXT)
RETURNS TABLE (
    cod_pedido INT,
    data_hora_pedido TIMESTAMP,
    status TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cod_cliente INT;
    v_existe BOOLEAN;
BEGIN
    -- Valida se cliente existe e está ativo
	SELECT cod_cliente INTO v_cod_cliente FROM cliente WHERE nome ILIKE p_nome_cliente AND deletado = FALSE;

	IF NOT FOUND THEN
        RAISE EXCEPTION 'Cliente "%" não encontrado ou deletado.', p_nome_cliente;
    END IF;

	-- Valida se o cliente possui pedidos em aberto 
	SELECT EXISTS (
        SELECT 1 FROM pedido p
        WHERE cod_cliente = v_cod_cliente AND p.status NOT IN ('ENTREGUE', 'CANCELADO')
    ) INTO v_existe;

    IF NOT v_existe THEN
        RAISE EXCEPTION 'O cliente "%" não possui pedidos em aberto.', p_nome_cliente;
    END IF;

    RETURN QUERY
    SELECT 
        p.cod_pedido,
        p.data_hora_pedido,
        p.status::TEXT  
    FROM pedido p
    JOIN cliente c ON p.cod_cliente = c.cod_cliente
    WHERE c.nome ILIKE '%' || p_nome_cliente || '%'
      AND p.status NOT IN ('ENTREGUE', 'CANCELADO')
    ORDER BY p.data_hora_pedido DESC;
END;
$$;

-- ============================================
-- FUNÇÃO: Histórico de Pedidos do Cliente
-- Lista todos os pedidos de um cliente, com itens e produtos
-- ============================================
CREATE OR REPLACE FUNCTION historico_pedidos_cliente(p_nome_cliente TEXT)
RETURNS TABLE (
	cod_pedido INT,
	data_pedido TIMESTAMP,
	produto TEXT,
	quantidade INT,
	valor_unitario NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_cod_cliente INT;
    v_existe BOOLEAN;
BEGIN
	-- Valida se cliente existe e está ativo
	SELECT cod_cliente INTO v_cod_cliente FROM cliente WHERE nome ILIKE p_nome_cliente AND deletado = FALSE;

	IF NOT FOUND THEN
        RAISE EXCEPTION 'Cliente "%" não encontrado ou deletado.', p_nome_cliente;
    END IF;

	-- Valida se o cliente possui pedidos cadastrados
	SELECT EXISTS (
        SELECT 1 FROM pedido p
        WHERE cod_cliente = v_cod_cliente 
    ) INTO v_existe;

    IF NOT v_existe THEN
        RAISE EXCEPTION 'O cliente "%" não possui pedidos cadastrados.', p_nome_cliente;
    END IF;

	-- Valida se o cliente possui pedidos entregues
	SELECT EXISTS (
        SELECT 1 FROM pedido p
        WHERE cod_cliente = v_cod_cliente and p.status = 'ENTREGUE'
    ) INTO v_existe;

    IF NOT v_existe THEN
        RAISE EXCEPTION 'O cliente "%" não possui pedidos entregues.', p_nome_cliente;
    END IF;

	RETURN QUERY
		SELECT 
			p.cod_pedido, 
			p.data_hora_pedido,
			pr.nome::TEXT,
			ip.quantidade,
			pr.valor_unitario
		FROM pedido p
		JOIN cliente c ON p.cod_cliente = c.cod_cliente
		JOIN item_pedido ip ON p.cod_pedido = ip.cod_pedido
		JOIN produto pr ON ip.cod_produto = pr.cod_produto
		WHERE c.nome ILIKE p_nome_cliente AND p.status = 'ENTREGUE'
		ORDER BY p.data_hora_pedido DESC;
END;
$$;

-- ============================================
-- FUNÇÃO: Produtos Mais Solicitados pelo Cliente
-- Retorna ranking dos produtos mais pedidos por um cliente
-- ============================================
CREATE OR REPLACE FUNCTION produtos_mais_solicitados_cliente(p_nome_cliente TEXT)
RETURNS TABLE (
	produto TEXT,
	total_quantidade INT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_cod_cliente INT;
    v_existe BOOLEAN;
BEGIN
	-- Valida se cliente existe e está ativo
	SELECT cod_cliente INTO v_cod_cliente FROM cliente WHERE nome ILIKE p_nome_cliente AND deletado = FALSE;

	IF NOT FOUND THEN
        RAISE EXCEPTION 'Cliente "%" não encontrado ou deletado.', p_nome_cliente;
    END IF;

	-- Valida se o cliente possui pedidos cadastrados
	SELECT EXISTS (
        SELECT 1 FROM pedido p
        WHERE cod_cliente = v_cod_cliente 
    ) INTO v_existe;

    IF NOT v_existe THEN
        RAISE EXCEPTION 'O cliente "%" não possui pedidos cadastrados.', p_nome_cliente;
    END IF;

	RETURN QUERY
		SELECT 
			pr.nome::TEXT,
			SUM(ip.quantidade)::INT as total_quantidade
		FROM pedido p 
		JOIN cliente c ON p.cod_cliente = c.cod_cliente
		JOIN item_pedido ip ON p.cod_pedido = ip.cod_pedido
		JOIN produto pr ON ip.cod_produto = pr.cod_produto
		WHERE c.nome ILIKE p_nome_cliente
		GROUP BY pr.nome
		ORDER BY total_quantidade DESC;
END;
$$;

-- ============================================
-- FUNÇÃO: Pedidos Cancelados pelo Cliente
-- Lista os pedidos cancelados de um cliente
-- ============================================
CREATE OR REPLACE FUNCTION pedidos_cancelados_cliente(p_nome_cliente TEXT)
RETURNS TABLE (
	cod_pedido INT,
    data_pedido TIMESTAMP,
    motivo TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_cod_cliente INT;
    v_existe BOOLEAN;
BEGIN
	-- Valida se cliente existe e está ativo
	SELECT cod_cliente INTO v_cod_cliente FROM cliente WHERE nome ILIKE p_nome_cliente AND deletado = FALSE;

	IF NOT FOUND THEN
        RAISE EXCEPTION 'Cliente "%" não encontrado ou deletado.', p_nome_cliente;
    END IF;

	-- Valida se o cliente possui pedidos cadastrados
	SELECT EXISTS (
        SELECT 1 FROM pedido p
        WHERE cod_cliente = v_cod_cliente 
    ) INTO v_existe;

    IF NOT v_existe THEN
        RAISE EXCEPTION 'O cliente "%" não possui pedidos cadastrados.', p_nome_cliente;
    END IF;

	-- Valida se o cliente possui pedidos cancelados
	SELECT EXISTS (
        SELECT 1 FROM pedido p
        WHERE cod_cliente = v_cod_cliente AND p.status = 'CANCELADO'
    ) INTO v_existe;

    IF NOT v_existe THEN
        RAISE EXCEPTION 'O cliente "%" não possui pedidos cancelados.', p_nome_cliente;
    END IF;

	RETURN QUERY
		SELECT 
			p.cod_pedido,
			p.data_hora_pedido,
			COALESCE(p.observacao::TEXT, 'Motivo não informado')
		FROM pedido p
		JOIN cliente c ON p.cod_cliente = c.cod_cliente
		WHERE c.nome ILIKE p_nome_cliente
		AND p.status = 'CANCELADO'
		ORDER BY p.data_hora_pedido DESC;
END;
$$;

-- ============================================
-- FUNÇÃO: Pedidos Pendentes de Pagamento
-- Lista os pedidos em andamento que ainda não foram pagos
-- ============================================
CREATE OR REPLACE FUNCTION pedidos_pendentes_pagamento()
RETURNS TABLE (
    cod_pedido INT,
    cliente TEXT,
    data_pedido TIMESTAMP,
    valor_total NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.cod_pedido,
        c.nome::TEXT,
        p.data_hora_pedido,
        p.valor_total
    FROM pedido p
    JOIN cliente c ON p.cod_cliente = c.cod_cliente
    WHERE p.status = 'EM ANDAMENTO'
      AND p.pago = FALSE
    ORDER BY p.data_hora_pedido DESC;
END;
$$;
