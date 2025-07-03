-- ============================================
-- FUNÇÃO: Validar dados da tabela ENDERECO
-- Regras:
-- - CEP, se informado, deve ter 9 caracteres.
-- - Número, Rua e Bairro são obrigatórios.
-- ============================================
CREATE OR REPLACE FUNCTION validar_endereco()
RETURNS TRIGGER AS $$
BEGIN
    -- Valida CEP se informado
    IF NEW.cep IS NOT NULL AND LENGTH(NEW.cep) <> 9 THEN
        RAISE EXCEPTION 'O CEP deve conter exatamente 9 caracteres no formato 00000-000.';
    END IF;

    -- Valida número
    IF NEW.numero IS NULL OR LENGTH(TRIM(NEW.numero)) = 0 THEN
        RAISE EXCEPTION 'O campo "número" é obrigatório.';
    END IF;

    -- Valida rua
    IF NEW.rua IS NULL OR LENGTH(TRIM(NEW.rua)) = 0 THEN
        RAISE EXCEPTION 'O campo "rua" é obrigatório.';
    END IF;

    -- Valida bairro
    IF NEW.bairro IS NULL OR LENGTH(TRIM(NEW.bairro)) = 0 THEN
        RAISE EXCEPTION 'O campo "bairro" é obrigatório.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- TRIGGER: Chama a validação ao inserir ou atualizar endereco
-- ============================================
CREATE TRIGGER trg_validar_endereco
BEFORE INSERT OR UPDATE ON endereco
FOR EACH ROW EXECUTE FUNCTION validar_endereco();


