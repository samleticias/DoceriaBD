-- TESTE: testar permissões de acesso por role/usuário


-- 1. TESTES COM ROLE CLIENTE
-- --------------------------------
SET ROLE maria_cliente;

-- Ações permitidas (devem funcionar)
SELECT criar_pedido('Thiago elias');
SELECT * FROM listar_pedidos_abertos('Thiago elias');
SELECT adicionar_item_pedido('x', 'Brigadeiro Gourmet', 1);
SELECT pagar_pedido('x', 'Pix');
SELECT * FROM consultar_itens_pedido('x');
SELECT * FROM vw_produtos_ativos;

-- Ações proibidas (devem falhar)
SELECT * FROM pedido;
SELECT * FROM relatorio_estoque_atual();

-- Reset role
RESET ROLE;

-- 3. TESTES COM ROLE ATENDENTE
-- --------------------------------
SET ROLE paulo_atendente;

-- Ações permitidas
SELECT finalizar_pedido('x', 'Joao Victor');
SELECT * FROM relatorio_pedidos_abertos_cliente('Thiago elias');
SELECT * FROM vw_produtos_ativos;

-- Ações proibidas
DO $$ BEGIN
  BEGIN
    PERFORM relatorio_compras_por_fornecedor();
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Expected DENIED: %', SQLERRM;
  END;
END; $$;

-- reset role
RESET ROLE;

-- 4. TESTES COM ROLE ENTREGADOR
-- --------------------------------
SET ROLE bruno_entregador;

-- Ações permitidas
SELECT * FROM relatorio_pedidos_disponiveis_entrega();
SELECT * FROM relatorio_historico_entregas('Enzo Melo');

-- Ações proibidas
DO $$ BEGIN
  BEGIN
    PERFORM relatorio_fluxo_caixa();
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Expected DENIED: %', SQLERRM;
  END;
END; $$;

RESET ROLE;

-- 5. TESTES COM ROLE COMPRADOR_ESTOQUE
-- --------------------------------
SET ROLE comprador_estoque;

-- Ações permitidas
SELECT criar_compra('Doces & Cia Distribuidora');
SELECT * FROM listar_compras_em_aberto('doces & cia distribuidora');
SELECT adicionar_item_compra('x', 'Leite Condensado', 5.0, 1);
SELECT finalizar_compra('x');

-- Ações proibidas
DO $$ BEGIN
  BEGIN
    PERFORM consultar_receita_produto('beijinho');
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Expected DENIED: %', SQLERRM;
  END;
END; $$;

RESET ROLE;

-- 6. TESTES COM ROLE FINANCEIRO
-- --------------------------------
SET ROLE financeiro;

-- Ações permitidas
SELECT * FROM relatorio_fluxo_caixa();
SELECT * FROM relatorio_formas_pagamento();

-- Ações proibidas
DO $$ BEGIN
  BEGIN
    PERFORM relatorio_desempenho_funcionarios();
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Expected DENIED: %', SQLERRM;
  END;
END; $$;

RESET ROLE;

