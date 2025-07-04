-- Trigger para impedir inserção de produto_ingrediente (componente da receita) com quantidade menor ou igual a zero
CREATE OR REPLACE FUNCTION verificar_produto_ingrediente()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN
	IF NEW.qtd_utilizada <= 0 THEN
		RAISE EXCEPTION 'A quantidade utilizada do ingrediente deve ser maior que zero. Valor informado: %', NEW.qtd_utilizada;
	END IF;
	
	RETURN NEW;
END;
$$;

CREATE TRIGGER trg_verificar_produto_ingrediente
BEFORE INSERT OR UPDATE ON produto_ingrediente
FOR EACH ROW
EXECUTE FUNCTION verificar_produto_ingrediente();