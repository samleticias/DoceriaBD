-- ============================================
-- FUNÇÃO: Validar dados da tabela INGREDIENTE
-- Regras:
-- - Nome obrigatório e único
-- - Unidade de medida obrigatória e válida
-- - Quantidade em estoque >= 0
-- - Impede alteração direta do campo 'deletado'
-- ============================================
CREATE OR REPLACE FUNCTION validar_ingrediente()
RETURNS TRIGGER AS $$
DECLARE
    v_contador INT;
BEGIN
    -- Valida nome
    IF NEW.nome IS NULL OR LENGTH(TRIM(NEW.nome)) = 0 THEN
        RAISE EXCEPTION 'O campo "nome" é obrigatório.';
    END IF;

    -- Verifica unicidade do nome
    SELECT COUNT(*) INTO v_contador
    FROM ingrediente
    WHERE nome = NEW.nome
      AND cod_ingrediente <> COALESCE(OLD.cod_ingrediente, 0);

    IF v_contador > 0 THEN
        RAISE EXCEPTION 'Já existe um ingrediente cadastrado com esse nome.';
    END IF;

    -- Valida unidade de medida
    IF NEW.unidade_medida IS NULL THEN
        RAISE EXCEPTION 'O campo "unidade_medida" é obrigatório.';
    END IF;

    -- Valida quantidade em estoque
    IF NEW.qtd_estoque IS NULL OR NEW.qtd_estoque < 0 THEN
        RAISE EXCEPTION 'O campo "qtd_estoque" deve ser maior ou igual a zero.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- ============================================
-- TRIGGER: Chama a validação ao inserir ou atualizar ingrediente
-- ============================================
CREATE TRIGGER trg_validar_ingrediente
BEFORE INSERT OR UPDATE ON ingrediente
FOR EACH ROW EXECUTE FUNCTION validar_ingrediente();

