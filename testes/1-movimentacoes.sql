-- TESTES: executar e validar fluxos principais de Pedido e Compra

-- ==============================
-- MÓDULO A: FLUXO DE PEDIDO
-- ==============================

-- 1. Criar pedido para cliente "Thiago Elias"
SELECT criar_pedido('Thiago elias');

-- Verificar criação
SELECT * FROM listar_pedidos_abertos('thiago elias');

-- 2. Adicionar itens
-- Produto: Brigadeiro Gourmet, quantidade 5
SELECT adicionar_item_pedido(1, 'Mousse de maracujá', 5);

-- Adicionar novamente o produto anterior (erro produto já adicionado no pedido)
SELECT adicionar_item_pedido(1, 'Mousse de maracujá', 1);

-- Produto: Bolo de Cenoura, quantidade 1
SELECT adicionar_item_pedido(1, 'Bolo de Cenoura com Cobertura', 1);

-- 3. Consultar itens do pedido
SELECT * FROM consultar_itens_pedido(1);

-- 4. Editar quantidade
-- Ajustar Mousse de maracujá para 4 unidades
SELECT editar_quantidade_item_pedido(1, 'Mousse de maracujá', 4);

-- Verificar
SELECT * FROM consultar_itens_pedido(1);

-- 5. Remover item
SELECT remover_item_pedido(1, 'Bolo de Cenoura com Cobertura');

-- Verificar
SELECT * FROM consultar_itens_pedido(1);

-- 6. Teste de exceção: estoque insuficiente
-- Estoque de Chocolate em Pó é 15kg, quantidade necessária de Brownie pede 0.2*quantidade
-- tentar quantidade alta para gerar exceção
DO $$ BEGIN
  BEGIN
    PERFORM adicionar_item_pedido(1, 'Brownie de Chocolate Meio Amargo', 1000);
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Esperado: %', SQLERRM;
  END;
END; $$;

-- 7. Pagar pedido
SELECT pagar_pedido(1, 'Dinheiro');

-- Verificar
SELECT * FROM consultar_pedido_por_id(1);

-- verificando os ingredientes que formam o Brigadeiro Gourmet (receita)
SELECT * FROM consultar_receita_produto('Mousse de maracujá');

-- Verificar estoque antes da finalização
SELECT * FROM relatorio_estoque_atual();

-- 8. Finalizar pedido pelo atendente Joao Victor
SELECT finalizar_pedido(1, 'Joao Victor');

-- Verificar estoque ajustado em ingrediente
SELECT * FROM relatorio_estoque_atual();
SELECT * FROM consultar_pedido_por_id(1);

-- 9. Entregar pedido com o entregador enzo melo
SELECT entregar_pedido(1, 'enzo melo');
SELECT * FROM consultar_pedido_por_id(1);

-- 10. Testes de exceção finalização antes de pagamento

-- cria pedido para o rogerio (ok)
SELECT criar_pedido('rogerio');

-- tenta pagar pedido sem adicionar itens (erro)
SELECT pagar_pedido(2, 'pix');

-- adiciona itens no pedido (ok)
SELECT adicionar_item_pedido(2, 'beijinho', 3);
SELECT adicionar_item_pedido(2, 'pão de mel', 2);
SELECT adicionar_item_pedido(2, 'pudim de leite', 1);

-- verifiacando itens no pedido (ok)
SELECT * FROM consultar_itens_pedido(2);

-- tenta pagar novamente o pedido (ok, agora possui itens)
SELECT pagar_pedido(2, 'pix');

-- tenta entregar pedido (erro, pedido não foi marcado como finalizado)
SELECT entregar_pedido(2, 'sammya leticia');

-- marca pedido como finalizado
SELECT finalizar_pedido(2, 'Joao Victor');

-- tenta entregar pedido (ok, pedido já foi marcado como finalizado)
SELECT entregar_pedido(2, 'sammya leticia');

-- cria um novo pedido para o marcelino (ok)
SELECT criar_pedido('marcelino');

-- cancela pedido (ok)
SELECT cancelar_pedido(3, 'Os preços da concorrente estão melhores');

-- tenta fazer operações com o pedido do marcelino (erro, pedido foi cancelado)
SELECT adicionar_item_pedido(3, 'beijinho', 1);		-- falha
SELECT pagar_pedido(3, 'dinheiro');   				-- falha
SELECT finalizar_pedido(3, 'Joao Victor'); 			-- falha


-- ==============================
-- MÓDULO B: FLUXO DE COMPRA
-- ==============================

-- 1. Criar compra para fornecedor "Doces & Cia Distribuidora"
SELECT criar_compra('Doces & Cia Distribuidora');

-- 2. Adicionar itens de compra
SELECT adicionar_item_compra(1, 'Leite Condensado', 5.0, 10);
SELECT adicionar_item_compra(1, 'Chocolate em Pó', 8.0, 5);

-- Teste duplicata
SELECT adicionar_item_compra(1, 'Leite Condensado', 5.0, 5);

-- 3. Consultar itens de compra
SELECT * FROM consultar_itens_compra(1);

-- 4. Editar quantidade de item de compra
SELECT editar_quantidade_item_compra(1, 'Chocolate em Pó', 10);
SELECT * FROM consultar_itens_compra(1);

-- 5. Remover item de compra
SELECT remover_item_compra(1, 'Leite Condensado');
SELECT * FROM consultar_itens_compra(1);

-- 6. Finalizar compra 1 e verificar estoque
-- estoque antes da finalização
SELECT * FROM relatorio_estoque_atual();
-- finaliza compra
SELECT finalizar_compra(1);
-- dados da compra
SELECT * FROM consultar_compra_por_id(1);
-- estoque após a finalização
SELECT * FROM relatorio_estoque_atual();

-- 7. Teste de exceção: finalizar sem itens
SELECT criar_compra('Chocolataria Premium');
DO $$ BEGIN
  BEGIN
    PERFORM finalizar_compra(2);
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Esperado erro: %', SQLERRM;
  END;
END; $$;


-- ==============================
-- MÓDULO C: CADASTROS E RECEITAS
-- ==============================

-- 1. Teste de criação de produto duplicado (erro esperado)
DO $$ BEGIN
  BEGIN
  CALL inserir_dados(
	'produto',
	'nome, descricao, valor_unitario',
	' ''Brigadeiro Gourmet'', ''Teste duplicado'', 4.0 '
  );
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Esperado erro: %', SQLERRM;
  END;
END; $$;

-- 2. Criação de novo produto válido
CALL inserir_dados(
	'produto',
	'nome, descricao, valor_unitario',
	' ''Pavê de Chocolate'', ''Camadas de biscoito e chocolate'', 12.50 '
);

-- 3. Adicionar ingrediente válido na nova receita
SELECT adicionar_ingrediente_produto('Pavê de Chocolate', 'Creme de Leite', 0.2);
SELECT adicionar_ingrediente_produto('Pavê de Chocolate', 'Chocolate em Pó', 0.15);

-- 4. Teste de adicionar ingrediente duplicado na receita (erro)
DO $$ BEGIN
  BEGIN
    PERFORM adicionar_ingrediente_produto('Pavê de Chocolate', 'Creme de Leite', 0.1);
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Esperado erro: %', SQLERRM;
  END;
END; $$;


-- 5. Consultar receita completa
SELECT * FROM consultar_receita_produto('Pavê de Chocolate');


