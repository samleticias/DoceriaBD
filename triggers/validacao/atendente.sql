-- ============================================
-- FUNÇÃO: Validar dados da tabela ATENDENTE
-- Regras:
-- - Nome obrigatório
-- - CPF obrigatório, 11 dígitos e único
-- - Email, se informado, deve ser único
-- ============================================
CREATE OR REPLACE FUNCTION validar_atendente()
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
    FROM atendente
    WHERE cpf = NEW.cpf
      AND cod_atendente <> COALESCE(OLD.cod_atendente, 0);
    
    IF v_contador > 0 THEN
        RAISE EXCEPTION 'Já existe um atendente cadastrado com esse CPF.';
    END IF;

    -- Verifica unicidade do email (se informado)
    IF NEW.email IS NOT NULL THEN
        SELECT COUNT(*) INTO v_contador
        FROM atendente
        WHERE email = NEW.email
          AND cod_atendente <> COALESCE(OLD.cod_atendente, 0);
        
        IF v_contador > 0 THEN
            RAISE EXCEPTION 'Já existe um atendente cadastrado com esse email.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- TRIGGER: Chama a validação ao inserir ou atualizar atendente
-- ============================================
CREATE TRIGGER trg_validar_atendente
BEFORE INSERT OR UPDATE ON atendente
FOR EACH ROW EXECUTE FUNCTION validar_atendente();
