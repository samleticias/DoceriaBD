-- Procedure genérica para atualizar dados de qualquer tabela
CREATE OR REPLACE PROCEDURE atualizar_dados(
    p_tabela TEXT,
    p_coluna_alvo TEXT,
    p_novo_valor TEXT,
    p_condicao TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql TEXT;
BEGIN
    -- Montar comando de atualização
    v_sql := FORMAT(
        'UPDATE %I SET %I = %s WHERE %s',
        p_tabela,
        p_coluna_alvo,
        p_novo_valor,
        p_condicao
    );

    -- Executar atualização
    EXECUTE v_sql;

    RAISE NOTICE 'Atualização realizada com sucesso na tabela "%".', p_tabela;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Erro ao atualizar dados na tabela "%": %', p_tabela, SQLERRM;
END;
$$;
