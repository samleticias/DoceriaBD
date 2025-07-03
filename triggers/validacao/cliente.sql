-- ============================================
-- FUNÇÃO: Validar dados da tabela CLIENTE (atualizada)
-- Regras:
-- - Telefone deve ter 11 dígitos se informado.
-- - Email não pode ser string vazia se informado.
-- - Email deve ser único (considerando clientes não deletados).
-- ============================================
CREATE OR REPLACE FUNCTION validar_cliente()
RETURNS TRIGGER AS $$
DECLARE
    v_existente INT;
BEGIN
    -- Valida telefone se informado
    IF NEW.telefone IS NOT NULL AND LENGTH(NEW.telefone) <> 11 THEN
        RAISE EXCEPTION 'O telefone deve conter exatamente 11 dígitos.';
    END IF;

    -- Valida email se informado
    IF NEW.email IS NOT NULL AND LENGTH(TRIM(NEW.email)) = 0 THEN
        RAISE EXCEPTION 'O email não pode ser vazio.';
    END IF;

    -- Verifica se já existe cliente com o mesmo email (não deletado)
    IF NEW.email IS NOT NULL THEN
        SELECT COUNT(*) INTO v_existente
        FROM cliente
        WHERE email = NEW.email
          AND deletado = FALSE
          AND (TG_OP = 'INSERT' OR cod_cliente <> OLD.cod_cliente);

        IF v_existente > 0 THEN
            RAISE EXCEPTION 'O email "%" já está cadastrado para outro cliente.', NEW.email;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- ============================================
-- TRIGGER: Chama a validação ao inserir ou atualizar cliente
-- ============================================
CREATE TRIGGER trg_validar_cliente
BEFORE INSERT OR UPDATE ON cliente
FOR EACH ROW
EXECUTE FUNCTION validar_cliente();