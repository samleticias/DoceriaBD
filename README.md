# DoceriaBD

## 🍰 Sistema de Gerenciamento para Doceria

**DoceriaBD** é um banco de dados relacional desenvolvido em **PostgreSQL** para gerenciar as operações de uma doceria, incluindo cadastro de clientes, pedidos, estoque de ingredientes, compras, entregas, pagamentos e receitas dos produtos.

## 📋 Funcionalidades Principais

- **Cadastro e gerenciamento de clientes e endereços**
- **Gerenciamento de atendentes, entregadores e funções específicas**
- **Registro de pedidos e itens com controle de status**
- **Controle detalhado de estoque de ingredientes**
- **Cadastro de fornecedores e controle de compras**
- **Cadastro de produtos com suas respectivas receitas (ingredientes utilizados)**
- **Funções auxiliares e de relacionamento**:
  - Vincular cliente a endereço
  - Montar receitas de produtos
  - Cancelar compras
  - Consultar itens de pedidos e compras
- **Controle lógico de deleção** para manter a integridade dos dados
- **Validações para garantir consistência e regras de negócio**

## 🛡️ Controle de Acesso (Permissões)

Foi implementado um sistema de controle de acesso baseado em **roles** no PostgreSQL. Cada perfil possui permissões específicas sobre as funções e dados acessados:

- `cliente`
- `atendente`
- `entregador`
- `comprador_estoque`
- `financeiro`

Para cada perfil:
- Foi criado um usuário de teste
- Foram atribuídas permissões apenas para funções e visualizações compatíveis com a função
- Exemplo: O usuário `cliente` só pode consultar seus pedidos e informações. Já o `financeiro` pode executar funções de pagamento e relatórios.

## 🗂 Estrutura do Banco de Dados

### 🔸 Tabelas principais

- `cliente`, `endereco`, `cliente_endereco`
- `atendente`, `entregador`
- `tipo_pagamento`
- `pedido`, `item_pedido`
- `produto`, `produto_ingrediente`
- `ingrediente`
- `fornecedor`, `compra`, `item_compra`

### 🔸 Tipos personalizados (ENUM)

- `status_pedido_enum`: status de pedidos (ex: aguardando, pago, entregue, cancelado)
- `unidade_medida_enum`: unidades dos ingredientes (ex: gramas, litros)
- `status_compra_enum`: status das compras (ex: solicitada, recebida, cancelada)

## 📊 Relatórios Disponíveis

- **`relatorio_estoque_baixo(p_limite NUMERIC)`**  
  Lista os ingredientes cujo estoque está abaixo do limite informado.

- **`resumo_pagamentos_recebidos()`**  
  Mostra a quantidade e valor total dos pedidos pagos, agrupados por tipo de pagamento.

- **`relatorio_consumo_ingredientes()`**  
  Retorna o consumo total de ingredientes com base nos pedidos finalizados e nas receitas dos produtos.

- **`relatorio_compras_por_fornecedor()`**  
  Relatório detalhado de compras agrupadas por fornecedor.

- **Relatórios adicionais para o perfil financeiro e funções de consulta específicas para os demais perfis.**

## 🧠 Views Auxiliares

Foram criadas **views** para facilitar a consulta de registros **ativos e inativos** em várias tabelas, como `cliente`, `produto`, `ingrediente`, etc.

## 🧰 Funcionalidades Técnicas Adicionais

- **Funções de inserção e relacionamento**:
  - `vincular_cliente_endereco()`
  - `vincular_ingrediente_produto()` (monta a receita de um produto)
- **Funções de consulta específicas**:
  - `consultar_itens_pedido()`
  - `consultar_itens_compra()`
- **Validações rigorosas** em funções de pedidos, pagamentos, compras e relatórios
- **Refatoração** para uso da procedure `inserir_dados`, substituindo comandos `INSERT` diretos, visando padronização

## 👩‍💻 Equipe de Desenvolvimento

Este projeto foi desenvolvido por:

- **[João Victor](https://github.com/victordev018)**  
- **[Sâmmya Leticia](https://github.com/samleticias)**
