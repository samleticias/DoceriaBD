-- Inserts para a tabela CLIENTE
INSERT INTO CLIENTE (NOME, EMAIL, TELEFONE, ATIVO) VALUES
('Ana Souza', 'ana.souza@email.com', '11987654321', TRUE),
('Carlos Lima', 'carlos.lima@email.com', '21912345678', TRUE),
('Fernanda Alves', 'fernanda.alves@email.com', '31955554444', TRUE),
('Mariana Castro', 'mariana.castro@email.com', '11999993333', TRUE),
('João Pedro', 'joao.pedro@email.com', '21911223344', TRUE);

-- Inserts para a tabela ENDERECO
INSERT INTO ENDERECO (COMPLEMENTO, NUMERO, BAIRRO, RUA, CEP, DELETADO) VALUES
('Apto 101', '123', 'Centro', 'Rua das Flores', '01001-000', FALSE),
('Casa', '456', 'Jardim América', 'Av. Brasil', '02002-000', FALSE),
('Fundos', '789', 'Vila Nova', 'Rua Verde', '03003-000', FALSE),
('Bloco B', '101', 'Liberdade', 'Rua da Paz', '04004-000', FALSE),
('Apto 305', '88', 'Santa Cecília', 'Av. Paulista', '05005-000', FALSE);

-- Inserts para a tabela CLIENTE_ENDERECO
INSERT INTO CLIENTE_ENDERECO (COD_CLIENTE, COD_ENDERECO) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

-- Inserts para a tabela ATENDENTE
INSERT INTO ATENDENTE (NOME, CPF, EMAIL, ATIVO) VALUES
('Julia Mendes', '12345678901', 'julia.mendes@email.com', TRUE),
('Rafael Torres', '23456789012', 'rafael.torres@email.com', TRUE),
('Camila Silva', '34567890123', 'camila.silva@email.com', TRUE),
('Diego Costa', '45678901234', 'diego.costa@email.com', TRUE),
('Paula Ramos', '56789012345', 'paula.ramos@email.com', TRUE);

-- Inserts para a tabela ENTREGADOR
INSERT INTO ENTREGADOR (NOME, CPF, TELEFONE, ATIVO) VALUES
('Marcos Dias', '34567890123', '11999998888', TRUE),
('Bianca Rocha', '45678901234', '21988887777', TRUE),
('Pedro Martins', '56789012345', '31977776666', TRUE),
('Laura Almeida', '67890123456', '11966665555', TRUE),
('Ricardo Santos', '78901234567', '21955554444', TRUE);

-- Inserts para a tabela TIPO_PAGAMENTO
INSERT INTO TIPO_PAGAMENTO (NOME, DELETADO) VALUES
('Dinheiro', FALSE),
('Cartão de Crédito', FALSE),
('Cartão de Débito', FALSE),
('Pix', FALSE),
('Vale Refeição', FALSE);

-- Inserts para a tabela PRODUTO
INSERT INTO PRODUTO (NOME, DESCRICAO, VALOR_UNITARIO, DELETADO) VALUES
('Brigadeiro', 'Doce de chocolate tradicional', 2.50, FALSE),
('Beijinho', 'Doce de coco com leite condensado', 2.50, FALSE),
('Bolo de Cenoura', 'Bolo com cobertura de chocolate', 15.00, FALSE),
('Brownie', 'Brownie com pedaços de chocolate', 6.00, FALSE),
('Torta de Limão', 'Torta gelada com cobertura de limão', 18.00, FALSE);

-- Inserts para a tabela INGREDIENTE
INSERT INTO INGREDIENTE (NOME, UNIDADE_MEDIDA, QTD_ESTOQUE, DELETADO) VALUES
('Leite Condensado', 'L', 10.0, FALSE),
('Chocolate', 'KG', 5.0, FALSE),
('Coco Ralado', 'KG', 3.0, FALSE),
('Cenoura', 'KG', 2.0, FALSE),
('Farinha de Trigo', 'KG', 20.0, FALSE);

-- Inserts para a tabela PRODUTO_INGREDIENTE
INSERT INTO PRODUTO_INGREDIENTE (COD_PRODUTO, COD_INGREDIENTE, QTD_UTILIZADA) VALUES
(1, 1, 0.2),
(1, 2, 0.1),
(2, 1, 0.2),
(2, 3, 0.1),
(3, 4, 0.3);

-- Inserts para a tabela FORNECEDOR
INSERT INTO FORNECEDOR (NOME, EMAIL, TELEFONE, ATIVO) VALUES
('Doces & Cia', 'contato@docesecia.com', '1133445566', TRUE),
('Ingredientes LTDA', 'vendas@ingredientes.com', '1144556677', TRUE),
('Delícias da Vovó', 'vovo@delicias.com', '1122334455', TRUE),
('Sabor Real', 'sabor@real.com', '1155667788', TRUE),
('Distribuidora Bom Gosto', 'contato@bomgosto.com', '1199988776', TRUE);