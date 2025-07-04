-- View de tipos de pagamento ativos
CREATE OR REPLACE VIEW vw_tipos_pagamento_ativos AS
SELECT cod_tipo_pagamento, nome
FROM tipo_pagamento
WHERE deletado = FALSE;

-- View de tipos de pagamento inativos
CREATE OR REPLACE VIEW vw_tipos_pagamento_inativos AS
SELECT cod_tipo_pagamento, nome
FROM tipo_pagamento
WHERE deletado = TRUE;
