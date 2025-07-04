-- ============================================
-- FUNÇÃO: Validar dados da tabela ENTREGADOR
-- Regras:
-- - Nome obrigatório
-- - CPF obrigatório, 11 dígitos e único
-- - Telefone obrigatório e 11 dígitos
-- ============================================
CREATE OR REPLACE FUNCTION validar_entregador()
RETURNS TRIGGER AS $$
DECLARE
    v_contador INT;
BEGIN
    -- Valida nome
    IF NEW.nome IS NULL OR LENGTH(TRIM(NEW.nome)) = 0 THEN
        RAISE EXCEPTION 'O campo "nome" é obrigatório.';
    END IF;

    -- Valida CPF
    IF NEW.cpf IS NULL OR LENGTH(TRIM(NEW.cpf)) <> 11 THEN
        RAISE EXCEPTION 'O campo "CPF" é obrigatório e deve conter exatamente 11 dígitos.';
    END IF;

    -- Verifica unicidade do CPF
    SELECT COUNT(*) INTO v_contador
    FROM entregador
    WHERE cpf = NEW.cpf
      AND cod_entregador <> COALESCE(OLD.cod_entregador, 0);

    IF v_contador > 0 THEN
        RAISE EXCEPTION 'Já existe um entregador cadastrado com esse CPF.';
    END IF;

    -- Valida telefone
    IF NEW.telefone IS NULL OR LENGTH(TRIM(NEW.telefone)) <> 11 THEN
        RAISE EXCEPTION 'O campo "telefone" é obrigatório e deve conter exatamente 11 dígitos.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- ============================================
-- TRIGGER: Chama a validação ao inserir ou atualizar entregador
-- ============================================
CREATE TRIGGER trg_validar_entregador
BEFORE INSERT OR UPDATE ON entregador
FOR EACH ROW EXECUTE FUNCTION validar_entregador();
