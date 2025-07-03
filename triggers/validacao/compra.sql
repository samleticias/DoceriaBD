-- Trigger que impede inserir ou atualizar uma compra com data futura
CREATE OR REPLACE FUNCTION validar_data_compra()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.data_compra > NOW() THEN
        RAISE EXCEPTION 'A data da compra (%), não pode estar no futuro.', NEW.data_compra;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_data_compra
BEFORE INSERT OR UPDATE ON COMPRA
FOR EACH ROW
EXECUTE FUNCTION validar_data_compra();