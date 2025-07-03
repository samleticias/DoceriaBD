-- ============================================
-- FUNÇÃO: Validar dados da tabela PRODUTO
-- Regras:
-- - Nome obrigatório e único
-- - Valor unitário obrigatório e maior que zero
-- ============================================
CREATE OR REPLACE FUNCTION validar_produto()
RETURNS TRIGGER AS $$
DECLARE
    v_contador INT;
BEGIN
    -- Valida nome
    IF NEW.nome IS NULL OR LENGTH(TRIM(NEW.nome)) = 0 THEN
        RAISE EXCEPTION 'O campo "nome" é obrigatório.';
    END IF;

    -- Verifica unicidade do nome (exceto no próprio registro em update)
    SELECT COUNT(*) INTO v_contador
    FROM produto
    WHERE nome = NEW.nome
      AND cod_produto <> COALESCE(OLD.cod_produto, 0);

    IF v_contador > 0 THEN
        RAISE EXCEPTION 'Já existe um produto cadastrado com esse nome.';
    END IF;

    -- Valida valor unitário
    IF NEW.valor_unitario IS NULL OR NEW.valor_unitario <= 0 THEN
        RAISE EXCEPTION 'O campo "valor_unitario" é obrigatório e deve ser maior que zero.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- ============================================
-- TRIGGER: Chama a validação ao inserir ou atualizar produto
-- ============================================
CREATE TRIGGER trg_validar_produto
BEFORE INSERT OR UPDATE ON produto
FOR EACH ROW EXECUTE FUNCTION validar_produto();
