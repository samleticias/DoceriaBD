-- Inserts adaptados para usar a procedure genérica inserir_dados

-- CLIENTE
CALL inserir_dados('cliente', 'nome, email, telefone, deletado', 
    '''Ana Souza'', ''ana.souza@email.com'', ''11987654321'', false');
CALL inserir_dados('cliente', 'nome, email, telefone, deletado', 
    '''Carlos Lima'', ''carlos.lima@email.com'', ''21912345678'', false');
CALL inserir_dados('cliente', 'nome, email, telefone, deletado', 
    '''Fernanda Alves'', ''fernanda.alves@email.com'', ''31955554444'', false');
CALL inserir_dados('cliente', 'nome, email, telefone, deletado', 
    '''Mariana Castro'', ''mariana.castro@email.com'', ''11999993333'', false');
CALL inserir_dados('cliente', 'nome, email, telefone, deletado', 
    '''João Pedro'', ''joao.pedro@email.com'', ''21911223344'', false');

-- ENDERECO
CALL inserir_dados('endereco', 'complemento, numero, bairro, rua, cep, deletado', 
    '''Apto 101'', ''123'', ''Centro'', ''Rua das Flores'', ''01001-000'', false');
CALL inserir_dados('endereco', 'complemento, numero, bairro, rua, cep, deletado', 
    '''Casa'', ''456'', ''Jardim América'', ''Av. Brasil'', ''02002-000'', false');
CALL inserir_dados('endereco', 'complemento, numero, bairro, rua, cep, deletado', 
    '''Fundos'', ''789'', ''Vila Nova'', ''Rua Verde'', ''03003-000'', false');
CALL inserir_dados('endereco', 'complemento, numero, bairro, rua, cep, deletado', 
    '''Bloco B'', ''101'', ''Liberdade'', ''Rua da Paz'', ''04004-000'', false');
CALL inserir_dados('endereco', 'complemento, numero, bairro, rua, cep, deletado', 
    '''Apto 305'', ''88'', ''Santa Cecília'', ''Av. Paulista'', ''05005-000'', false');

-- CLIENTE_ENDERECO
CALL inserir_dados('cliente_endereco', 'cod_cliente, cod_endereco', '1, 1');
CALL inserir_dados('cliente_endereco', 'cod_cliente, cod_endereco', '2, 2');
CALL inserir_dados('cliente_endereco', 'cod_cliente, cod_endereco', '3, 3');
CALL inserir_dados('cliente_endereco', 'cod_cliente, cod_endereco', '4, 4');
CALL inserir_dados('cliente_endereco', 'cod_cliente, cod_endereco', '5, 5');

-- ATENDENTE
CALL inserir_dados('atendente', 'nome, cpf, email, deletado', 
    '''Julia Mendes'', ''12345678901'', ''julia.mendes@email.com'', false');
CALL inserir_dados('atendente', 'nome, cpf, email, deletado', 
    '''Rafael Torres'', ''23456789012'', ''rafael.torres@email.com'', false');
CALL inserir_dados('atendente', 'nome, cpf, email, deletado', 
    '''Camila Silva'', ''34567890123'', ''camila.silva@email.com'', false');
CALL inserir_dados('atendente', 'nome, cpf, email, deletado', 
    '''Diego Costa'', ''45678901234'', ''diego.costa@email.com'', false');
CALL inserir_dados('atendente', 'nome, cpf, email, deletado', 
    '''Paula Ramos'', ''56789012345'', ''paula.ramos@email.com'', false');

-- ENTREGADOR
CALL inserir_dados('entregador', 'nome, cpf, telefone, deletado', 
    '''Marcos Dias'', ''34567890123'', ''11999998888'', false');
CALL inserir_dados('entregador', 'nome, cpf, telefone, deletado', 
    '''Bianca Rocha'', ''45678901234'', ''21988887777'', false');
CALL inserir_dados('entregador', 'nome, cpf, telefone, deletado', 
    '''Pedro Martins'', ''56789012345'', ''31977776666'', false');
CALL inserir_dados('entregador', 'nome, cpf, telefone, deletado', 
    '''Laura Almeida'', ''67890123456'', ''11966665555'', false');
CALL inserir_dados('entregador', 'nome, cpf, telefone, deletado', 
    '''Ricardo Santos'', ''78901234567'', ''21955554444'', false');

-- TIPO_PAGAMENTO
CALL inserir_dados('tipo_pagamento', 'nome, deletado', '''Dinheiro'', false');
CALL inserir_dados('tipo_pagamento', 'nome, deletado', '''Cartão de Crédito'', false');
CALL inserir_dados('tipo_pagamento', 'nome, deletado', '''Cartão de Débito'', false');
CALL inserir_dados('tipo_pagamento', 'nome, deletado', '''Pix'', false');
CALL inserir_dados('tipo_pagamento', 'nome, deletado', '''Vale Refeição'', false');

-- PRODUTO
CALL inserir_dados('produto', 'nome, descricao, valor_unitario, deletado', 
    '''Brigadeiro'', ''Doce de chocolate tradicional'', 2.5, false');
CALL inserir_dados('produto', 'nome, descricao, valor_unitario, deletado', 
    '''Beijinho'', ''Doce de coco com leite condensado'', 2.5, false');
CALL inserir_dados('produto', 'nome, descricao, valor_unitario, deletado', 
    '''Bolo de Cenoura'', ''Bolo com cobertura de chocolate'', 15.0, false');
CALL inserir_dados('produto', 'nome, descricao, valor_unitario, deletado', 
    '''Brownie'', ''Brownie com pedaços de chocolate'', 6.0, false');
CALL inserir_dados('produto', 'nome, descricao, valor_unitario, deletado', 
    '''Torta de Limão'', ''Torta gelada com cobertura de limão'', 18.0, false');

-- INGREDIENTE
CALL inserir_dados('ingrediente', 'nome, unidade_medida, qtd_estoque, deletado', '''Leite Condensado'', ''L'', 10.0, false');
CALL inserir_dados('ingrediente', 'nome, unidade_medida, qtd_estoque, deletado', '''Chocolate'', ''KG'', 5.0, false');
CALL inserir_dados('ingrediente', 'nome, unidade_medida, qtd_estoque, deletado', '''Coco Ralado'', ''KG'', 3.0, false');
CALL inserir_dados('ingrediente', 'nome, unidade_medida, qtd_estoque, deletado', '''Cenoura'', ''KG'', 2.0, false');
CALL inserir_dados('ingrediente', 'nome, unidade_medida, qtd_estoque, deletado', '''Farinha de Trigo'', ''KG'', 20.0, false');

-- PRODUTO_INGREDIENTE
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '1, 1, 0.2');
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '1, 2, 0.1');
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '2, 1, 0.2');
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '2, 3, 0.1');
CALL inserir_dados('produto_ingrediente', 'cod_produto, cod_ingrediente, qtd_utilizada', '3, 4, 0.3');