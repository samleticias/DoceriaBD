-- FUNÇÃO PARA DELETAR LÓGICO DE UM CLIENTE (PELO NOME)
CREATE OR REPLACE PROCEDURE deletar_logico(
    p_tabela TEXT,
    p_condicao TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql TEXT;
BEGIN
    -- Montar comando de deleção lógica
    v_sql := FORMAT(
        'UPDATE %I SET deletado = TRUE WHERE %s',
        p_tabela,
        p_condicao
    );

    -- Executar deleção lógica
    EXECUTE v_sql;

    RAISE NOTICE 'Deleção lógica realizada com sucesso na tabela "%".', p_tabela;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Erro ao realizar deleção lógica na tabela "%": %', p_tabela, SQLERRM;
END;
$$;
