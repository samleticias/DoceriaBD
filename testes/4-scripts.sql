-- Criar cliente com procedure genérica
CALL inserir_dados('cliente', 'nome, email, telefone', '''Ricardo'', ''ricardo@gmail.com'', ''31955554644''');
CALL inserir_dados('cliente', 'nome, email, telefone', '''Igor'', ''igor@gmail.com'', ''31955554622''');

-- Buscando clientes ativos por meio de um view
select * from vw_clientes_ativos;

-- Atualizar nome do cliente
CALL atualizar_dados('cliente', 'nome', '''Ricardo Ramos''', 'nome = ''Ricardo''');

-- Atualizar email do cliente
CALL atualizar_dados('cliente', 'email', '''igornasc@gmail.com''', 'nome = ''Igor'' ');

-- Deve dá erro no trigger para verificação de email duplicado
CALL atualizar_dados('cliente', 'email', '''marcelino@email.com''', 'nome = ''Ricardo Ramos'' ');

-- Deve dá erro no trigger para verificação de quantidade de dígitos do telefone
CALL inserir_dados('cliente', 'nome, email, telefone', '''Aline'', ''aline@gmail.com'', ''319554644'' ');

-- Deletar lógico para cliente
call deletar_logico('cliente', 'nome = ''Ricardo Ramos''');
call deletar_logico('cliente', 'nome = ''Igor'' ');

-- Buscar clientes desativados por meio de uma view
select * from vw_clientes_inativos;

