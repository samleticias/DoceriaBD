# DoceriaBD

## 🍰 Sistema de Gerenciamento para Doceria

DoceriaBD é um banco de dados relacional desenvolvido em **PostgreSQL** para gerenciar operações de uma doceria, incluindo clientes, pedidos, estoque de ingredientes, compras, entregas, pagamentos, e controle de receitas dos produtos.

## 📋 Funcionalidades Principais

- **Cadastro e gerenciamento de clientes e endereços**
- **Gerenciamento de atendentes e entregadores**
- **Registro de pedidos e itens do pedido com controle de status**
- **Controle detalhado de ingredientes e estoque**
- **Cadastro de fornecedores e controle de compras de ingredientes**
- **Cadastro de produtos com receitas (ingredientes usados)**
- **Funções para relatórios, como:**
  - Resumo de pagamentos recebidos por tipo de pagamento
  - Relatório de estoque baixo com limite parametrizado
  - Relatórios de consumo de ingredientes baseados em pedidos finalizados
- Controle lógico de deleção para manter integridade dos dados

## 🗂 Estrutura do Banco de Dados

- **Tabelas principais:**
  - `cliente`, `endereco`, `cliente_endereco`
  - `atendente`, `entregador`
  - `tipo_pagamento`
  - `pedido`, `item_pedido`
  - `produto`, `produto_ingrediente`
  - `ingrediente`
  - `fornecedor`, `compra`, `item_compra`

- **Tipos personalizados ENUM:**
  - `status_pedido_enum` para status dos pedidos
  - `unidade_medida_enum` para unidades dos ingredientes
  - `status_compra_enum` para status das compras

## 🚀 Como usar

1. Clone o repositório:

   ```bash
     git clone https://github.com/samleticias/DoceriaBD.git
     cd DoceriaBD
   ```
   
2. Execute o script SQL para criar as tabelas, tipos e funções:

   ```bash
     psql -U seu_usuario -d seu_banco -f doceria_schema.sql
   ```

3. Utilize as funções PL/pgSQL para gerar relatórios e gerenciar dados conforme a necessidade.

## 📊 Relatórios Disponíveis

- **`relatorio_estoque_baixo(p_limite NUMERIC)`**  
  Lista ingredientes com estoque abaixo do limite informado.

- **`resumo_pagamentos_recebidos()`**  
  Retorna a quantidade e o valor total dos pedidos pagos, agrupados por tipo de pagamento.

- **`relatorio_consumo_ingredientes()`** 
  Mostrará o consumo total de ingredientes com base nos pedidos finalizados e nas receitas dos produtos.

- **Outros relatórios personalizados**  
  Funções adicionais serão criadas para atender necessidades específicas da gestão da doceria, como desempenho de vendas, pedidos em andamento, entre outros.

## 👩‍💻 Equipe de Desenvolvimento

Este projeto foi desenvolvido por:

- **[João Victor](https://github.com/victordev018)**  
- **[Sâmmya Leticia](https://github.com/samleticias)**  
