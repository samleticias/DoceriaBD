-- ============================================
-- FUNÇÃO: Relatório de Pedidos Disponíveis para Entrega
-- Retorna todos os pedidos com status 'SAIU PARA ENTREGA'
-- que ainda não foram entregues.
-- ============================================
CREATE OR REPLACE FUNCTION relatorio_pedidos_disponiveis_entrega()
RETURNS TABLE (
    cod_pedido INT,
    nome_cliente TEXT,
    endereco_entrega TEXT,
    hora_prevista_entrega TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.cod_pedido::INT,
        c.nome::TEXT,
        CONCAT(e.rua, ', ', e.numero, ' - ', e.bairro)::TEXT AS endereco_entrega,
        p.hora_prevista_entrega::TIMESTAMP
    FROM pedido p
    JOIN cliente c ON c.cod_cliente = p.cod_cliente
    JOIN endereco e ON e.cod_endereco = p.cod_endereco
    WHERE p.status = 'SAIU PARA ENTREGA';

    IF NOT FOUND THEN
        RAISE NOTICE 'Nenhum pedido disponível para entrega no momento.';
    END IF;

END;
$$;


-- ============================================
-- FUNÇÃO: Histórico de Entregas do Entregador
-- Lista todos os pedidos entregues por um entregador específico,
-- com horários de entrega e tempo de atraso (se houver).
-- ============================================
CREATE OR REPLACE FUNCTION relatorio_historico_entregas(p_nome_entregador TEXT)
RETURNS TABLE (
    cod_pedido INT,
    nome_cliente TEXT,
    data_pedido TIMESTAMP,
    hora_prevista TIMESTAMP,
    hora_entrega TIMESTAMP,
    atraso_minutos INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cod_entregador INT;
BEGIN
    -- Valida se o entregador existe e não está deletado
    SELECT cod_entregador INTO v_cod_entregador
    FROM entregador
    WHERE nome ILIKE p_nome_entregador AND deletado = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Entregador "%" não encontrado ou inativo.', p_nome_entregador;
    END IF;

    -- Consulta as entregas feitas por ele
    RETURN QUERY
    SELECT 
        p.cod_pedido::INT,
        c.nome::TEXT,
        p.data_hora_pedido::TIMESTAMP,
        p.hora_prevista_entrega::TIMESTAMP,
        p.hora_entrega_real::TIMESTAMP,
        -- Se atraso for negativo, considera 0
        GREATEST(EXTRACT(MINUTE FROM (p.hora_entrega_real - p.hora_prevista_entrega))::INT, 0) AS atraso_minutos
    FROM pedido p
    JOIN cliente c ON c.cod_cliente = p.cod_cliente
    WHERE p.cod_entregador = v_cod_entregador
      AND p.status = 'ENTREGUE'
    ORDER BY p.hora_entrega_real;

    IF NOT FOUND THEN
        RAISE NOTICE 'O entregador "%" não realizou entregas.', p_nome_entregador;
    END IF;

END;
$$;


-- ============================================
-- FUNÇÃO: Relatório de Pedidos Atrasados
-- Lista pedidos cujo prazo de entrega expirou 
-- e ainda não foram entregues ou cancelados.
-- ============================================
CREATE OR REPLACE FUNCTION relatorio_pedidos_atrasados()
RETURNS TABLE (
    cod_pedido INT,
    nome_cliente TEXT,
    data_hora_pedido TIMESTAMP,
    hora_prevista_entrega TIMESTAMP,
    status TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.cod_pedido::INT,
        c.nome::TEXT,
        p.data_hora_pedido::TIMESTAMP,
        p.hora_prevista_entrega::TIMESTAMP,
        p.status::TEXT
    FROM pedido p
    JOIN cliente c ON c.cod_cliente = p.cod_cliente
    WHERE p.hora_prevista_entrega < NOW()
      AND p.status NOT IN ('ENTREGUE', 'CANCELADO')
    ORDER BY p.hora_prevista_entrega;

    IF NOT FOUND THEN
        RAISE NOTICE 'Nenhum pedido atrasado ou com problemas foi encontrado.';
    END IF;

END;
$$;


-- ============================================
-- FUNÇÃO: Relatório de Desempenho de Entregas
-- Exibe quantidade de entregas e tempo médio 
-- de atraso (ou adiantamento) por entregador.
-- ============================================
CREATE OR REPLACE FUNCTION relatorio_desempenho_entregas()
RETURNS TABLE (
    nome_entregador TEXT,
    qtd_entregas INT,
    tempo_medio_entrega NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.nome::TEXT,
        COUNT(p.cod_pedido)::INT AS qtd_entregas,
        ROUND(AVG(EXTRACT(EPOCH FROM (p.hora_entrega_real - p.hora_prevista_entrega)) / 60), 2)::NUMERIC AS tempo_medio_minutos
    FROM pedido p
    JOIN entregador e ON e.cod_entregador = p.cod_entregador
    WHERE p.status = 'ENTREGUE'
    GROUP BY e.nome
    ORDER BY qtd_entregas DESC;

    IF NOT FOUND THEN
        RAISE NOTICE 'Nenhuma entrega realizada foi encontrada.';
    END IF;

END;
$$;

