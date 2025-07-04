CREATE OR REPLACE FUNCTION verificar_pedido()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar data e hora do pedido
    IF NEW.data_hora_pedido > NEW.hora_prevista_entrega THEN
        RAISE EXCEPTION 'A data/hora do pedido deve ser menor ou igual à hora prevista de entrega.';
    END IF;

    -- Impedir valor_total negativo
    IF NEW.valor_total < 0 THEN
        RAISE EXCEPTION 'O valor total do pedido não pode ser negativo. Valor informado: %', NEW.valor_total;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_verificar_pedido
BEFORE INSERT OR UPDATE ON pedido
FOR EACH ROW
EXECUTE FUNCTION verificar_pedido();