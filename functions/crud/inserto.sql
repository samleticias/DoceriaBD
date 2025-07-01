-- PROCEDURE GENÉRICA PARA INSERIR DADOS EM QUALQUER TABELA
CREATE OR REPLACE PROCEDURE inserir_dados(
    p_tabela TEXT,
    p_colunas TEXT,
    p_valores TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql TEXT;
BEGIN
    -- Montar comando de inserção
    v_sql := FORMAT('INSERT INTO %I (%s) VALUES (%s)', p_tabela, p_colunas, p_valores);

    -- Executar inserção
    EXECUTE v_sql;

    RAISE NOTICE 'Dados inseridos com sucesso na tabela "%".', p_tabela;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Erro ao inserir dados na tabela "%": %', p_tabela, SQLERRM;
END;
$$;