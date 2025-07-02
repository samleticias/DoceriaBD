-- RESETAR TODAS AS TABELAS E IDS
TRUNCATE TABLE 
    item_compra, compra, item_pedido, pedido, 
    produto_ingrediente, produto, ingrediente, 
    fornecedor, tipo_pagamento, entregador, atendente, 
    cliente_endereco, endereco, cliente 
RESTART IDENTITY CASCADE;

-- ==================== POVOANDO TABELAS =====================

-- CLIENTES
CALL inserir_dados('cliente', 'nome, email, telefone',
    '''Ana Souza'', ''ana.souza@email.com'', ''11987654321'''
);
CALL inserir_dados('cliente', 'nome, email, telefone',
    '''Carlos Lima'', ''carlos.lima@email.com'', ''21912345678'''
);
CALL inserir_dados('cliente', 'nome, email, telefone',
    '''Fernanda Alves'', ''fernanda.alves@email.com'', ''31955554444'''
);


-- ENDEREÇOS
CALL inserir_dados('endereco', 'complemento, numero, bairro, rua, cep',
    '''Apto 101'', ''123'', ''Centro'', ''Rua das Flores'', ''01001-000'''
);
CALL inserir_dados('endereco', 'complemento, numero, bairro, rua, cep',
    '''Casa'', ''456'', ''Jardim América'', ''Av. Brasil'', ''02002-000'''
);
CALL inserir_dados('endereco', 'complemento, numero, bairro, rua, cep',
    '''Bloco B'', ''789'', ''Vila Nova'', ''Rua Verde'', ''03003-000'''
);


-- CLIENTE_ENDERECO
CALL inserir_dados('cliente_endereco', 'cod_cliente, cod_endereco', '1, 1');
CALL inserir_dados('cliente_endereco', 'cod_cliente, cod_endereco', '2, 2');
CALL inserir_dados('cliente_endereco', 'cod_cliente, cod_endereco', '3, 3');


-- ATENDENTES
CALL inserir_dados('atendente', 'nome, cpf, email',
    '''Julia Mendes'', ''12345678901'', ''julia@email.com'''
);
CALL inserir_dados('atendente', 'nome, cpf, email',
    '''Diego Costa'', ''98765432100'', ''diego@email.com'''
);


-- ENTREGADORES
CALL inserir_dados('entregador', 'nome, cpf, telefone',
    '''Marcos Dias'', ''23456789012'', ''11999998888'''
);
CALL inserir_dados('entregador', 'nome, cpf, telefone',
    '''Bianca Rocha'', ''34567890123'', ''21988887777'''
);


-- TIPO PAGAMENTO
CALL inserir_dados('tipo_pagamento', 'nome', '''Dinheiro''');
CALL inserir_dados('tipo_pagamento', 'nome', '''Cartão de Crédito''');
CALL inserir_dados('tipo_pagamento', 'nome', '''Pix''');


-- INGREDIENTES
CALL inserir_dados('ingrediente', 'nome, unidade_medida, qtd_estoque',
    '''Leite Condensado'', ''L'', 20.0');
CALL inserir_dados('ingrediente', 'nome, unidade_medida, qtd_estoque',
    '''Chocolate em Pó'', ''KG'', 15.0');
CALL inserir_dados('ingrediente', 'nome, unidade_medida, qtd_estoque',
    '''Coco Ralado'', ''KG'', 10.0');
CALL inserir_dados('ingrediente', 'nome, unidade_medida, qtd_estoque',
    '''Farinha de Trigo'', ''KG'', 30.0');
CALL inserir_dados('ingrediente', 'nome, unidade_medida, qtd_estoque',
    '''Cenoura'', ''KG'', 12.0');
CALL inserir_dados('ingrediente', 'nome, unidade_medida, qtd_estoque',
    '''Açúcar'', ''KG'', 25.0');
CALL inserir_dados('ingrediente', 'nome, unidade_medida, qtd_estoque',
    '''Ovos'', ''UNIDADE'', 200');
CALL inserir_dados('ingrediente', 'nome, unidade_medida, qtd_estoque',
    '''Fermento em Pó'', ''KG'', 5.0');
CALL inserir_dados('ingrediente', 'nome, unidade_medida, qtd_estoque',
    '''Manteiga'', ''KG'', 10.0');
CALL inserir_dados('ingrediente', 'nome, unidade_medida, qtd_estoque',
    '''Creme de Leite'', ''L'', 10.0');
CALL inserir_dados('ingrediente', 'nome, unidade_medida, qtd_estoque',
    '''Morango'', ''KG'', 8.0');
CALL inserir_dados('ingrediente', 'nome, unidade_medida, qtd_estoque',
    '''Polpa de Maracujá'', ''L'', 8.0');
CALL inserir_dados('ingrediente', 'nome, unidade_medida, qtd_estoque',
    '''Frutas Vermelhas'', ''KG'', 6.0');
CALL inserir_dados('ingrediente', 'nome, unidade_medida, qtd_estoque',
    '''Gelatina Incolor'', ''UNIDADE'', 50');

-- PRODUTOS
CALL inserir_dados('produto', 'nome, descricao, valor_unitario',
    '''Brigadeiro Gourmet'', ''Doce de chocolate coberto com granulado'', 3.50');
CALL inserir_dados('produto', 'nome, descricao, valor_unitario',
    '''Beijinho'', ''Doce de coco com leite condensado e coco ralado'', 3.50');
CALL inserir_dados('produto', 'nome, descricao, valor_unitario',
    '''Bolo de Cenoura com Cobertura'', ''Bolo de cenoura com cobertura de chocolate'', 25.00');
CALL inserir_dados('produto', 'nome, descricao, valor_unitario',
    '''Brownie de Chocolate Meio Amargo'', ''Brownie macio com chocolate meio amargo'', 7.00');
CALL inserir_dados('produto', 'nome, descricao, valor_unitario',
    '''Cheesecake de Frutas Vermelhas'', ''Cheesecake gelado com calda de frutas vermelhas'', 28.00');
CALL inserir_dados('produto', 'nome, descricao, valor_unitario',
    '''Torta de Limão'', ''Torta cremosa com merengue e raspas de limão'', 22.00');
CALL inserir_dados('produto', 'nome, descricao, valor_unitario',
    '''Pão de Mel'', ''Pão de mel recheado e coberto com chocolate'', 5.50');
CALL inserir_dados('produto', 'nome, descricao, valor_unitario',
    '''Cupcake de Morango'', ''Cupcake recheado e coberto com chantilly de morango'', 6.50');
CALL inserir_dados('produto', 'nome, descricao, valor_unitario',
    '''Mousse de Maracujá'', ''Mousse cremosa de maracujá'', 7.50');
CALL inserir_dados('produto', 'nome, descricao, valor_unitario',
    '''Pudim de Leite'', ''Pudim clássico com calda de caramelo'', 8.00');


-- FORNECEDORES
CALL inserir_dados('fornecedor', 'nome, email, telefone',
    '''Doces & Cia Distribuidora'', ''contato@docesecia.com'', ''11987651234''');
CALL inserir_dados('fornecedor', 'nome, email, telefone',
    '''Chocolataria Premium'', ''vendas@chocopremium.com'', ''11984561234''');
CALL inserir_dados('fornecedor', 'nome, email, telefone',
    '''FrutaMix Polpas'', ''contato@frutamix.com'', ''11983451234''');
CALL inserir_dados('fornecedor', 'nome, email, telefone',
    '''Padoca Ingredientes'', ''vendas@padocaingredientes.com'', ''11982341234''');
CALL inserir_dados('fornecedor', 'nome, email, telefone',
    '''Laticínios Bom Sabor'', ''atendimento@bomsabor.com'', ''11981231234''');

-- RECEITAS (PRODUTO_INGREDIENTE)
-- Beijinho
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '2, 1, 0.1');  -- Leite Condensado
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '2, 3, 0.08'); -- Coco Ralado
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '2, 6, 0.02'); -- Açúcar
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '2, 9, 0.01'); -- Manteiga

-- Bolo de Cenoura com Cobertura
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '3, 4, 0.3');  -- Farinha de Trigo
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '3, 5, 0.2');  -- Cenoura
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '3, 7, 3');    -- Ovos
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '3, 2, 0.1');  -- Chocolate em Pó
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '3, 8, 0.01'); -- Fermento em Pó
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '3, 6, 0.05'); -- Açúcar

-- Brownie de Chocolate Meio Amargo
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '4, 2, 0.2');  -- Chocolate em Pó
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '4, 6, 0.1');  -- Açúcar
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '4, 7, 3');    -- Ovos
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '4, 9, 0.1');  -- Manteiga

-- Cheesecake de Frutas Vermelhas
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '5, 6, 0.15'); -- Açúcar
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '5, 9, 0.2');  -- Manteiga
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '5, 10, 0.2'); -- Creme de Leite
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '5, 14, 0.2'); -- Frutas Vermelhas
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '5, 7, 3');    -- Ovos
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '5, 13, 1');   -- Gelatina Incolor

-- Torta de Limão
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '6, 6, 0.15'); -- Açúcar
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '6, 9, 0.1');  -- Manteiga
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '6, 10, 0.15');-- Creme de Leite
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '6, 7, 2');    -- Ovos
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '6, 13, 1');   -- Gelatina Incolor

-- Pão de Mel
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '7, 6, 0.1');  -- Açúcar
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '7, 2, 0.15'); -- Chocolate em Pó
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '7, 7, 2');    -- Ovos
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '7, 9, 0.05'); -- Manteiga
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '7, 8, 0.01'); -- Fermento em Pó

-- Cupcake de Morango
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '8, 6, 0.08'); -- Açúcar
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '8, 4, 0.15'); -- Farinha de Trigo
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '8, 7, 2');    -- Ovos
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '8, 9, 0.05'); -- Manteiga
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '8, 11, 0.2'); -- Morango

-- Mousse de Maracujá
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '9, 1, 0.1');  -- Leite Condensado
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '9, 10, 0.2'); -- Creme de Leite
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '9, 12, 0.2'); -- Polpa de Maracujá
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '9, 13, 1');   -- Gelatina Incolor

-- Pudim de Leite
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '10, 1, 0.4'); -- Leite Condensado
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '10, 6, 0.2'); -- Açúcar
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '10, 7, 4');   -- Ovos
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '10, 10, 0.2');-- Creme de Leite



