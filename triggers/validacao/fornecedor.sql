-- ============================================
-- FUNÇÃO: Validar dados da tabela FORNECEDOR
-- Regras:
-- - Nome obrigatório
-- - Email obrigatório, formato válido e único
-- - Telefone obrigatório, 11 dígitos
-- ============================================
CREATE OR REPLACE FUNCTION validar_fornecedor()
RETURNS TRIGGER AS $$
DECLARE
    v_contador INT;
BEGIN
    -- Valida nome
    IF NEW.nome IS NULL OR LENGTH(TRIM(NEW.nome)) = 0 THEN
        RAISE EXCEPTION 'O campo "nome" é obrigatório.';
    END IF;

    -- Valida email
    IF NEW.email IS NULL OR LENGTH(TRIM(NEW.email)) = 0 THEN
        RAISE EXCEPTION 'O campo "email" é obrigatório.';
    END IF;

    -- Verifica unicidade do email
    SELECT COUNT(*) INTO v_contador
    FROM fornecedor
    WHERE email = NEW.email
      AND cod_fornecedor <> COALESCE(OLD.cod_fornecedor, 0);

    IF v_contador > 0 THEN
        RAISE EXCEPTION 'Já existe um fornecedor cadastrado com esse email.';
    END IF;

    -- Valida telefone
    IF NEW.telefone IS NULL OR LENGTH(TRIM(NEW.telefone)) <> 11 THEN
        RAISE EXCEPTION 'O campo "telefone" é obrigatório e deve conter exatamente 11 dígitos.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- ============================================
-- TRIGGER: Chama a validação ao inserir ou atualizar fornecedor
-- ============================================
CREATE TRIGGER trg_validar_fornecedor
BEFORE INSERT OR UPDATE ON fornecedor
FOR EACH ROW EXECUTE FUNCTION validar_fornecedor();

