BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "categorias" (
	"id_categoria"	INTEGER,
	"nome"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id_categoria")
);
CREATE TABLE IF NOT EXISTS "garcons" (
	"id_garcom"	INTEGER,
	"nome"	TEXT NOT NULL,
	"ativo"	INTEGER NOT NULL DEFAULT 1 CHECK("ativo" IN (0, 1)),
	PRIMARY KEY("id_garcom")
);
CREATE TABLE IF NOT EXISTS "itens_pedido" (
	"id_item"	INTEGER,
	"id_pedido"	INTEGER NOT NULL,
	"id_produto"	INTEGER NOT NULL,
	"quantidade"	INTEGER NOT NULL CHECK("quantidade" > 0),
	"preco_unitario_centavos"	INTEGER NOT NULL CHECK("preco_unitario_centavos" > 0),
	"observacao"	TEXT,
	PRIMARY KEY("id_item"),
	FOREIGN KEY("id_pedido") REFERENCES "pedidos"("id_pedido") ON DELETE RESTRICT,
	FOREIGN KEY("id_produto") REFERENCES "produtos"("id_produto") ON DELETE RESTRICT
);
CREATE TABLE IF NOT EXISTS "mesas" (
	"id_mesa"	INTEGER,
	"numero"	INTEGER NOT NULL CHECK("numero" > 0) UNIQUE,
	"capacidade"	INTEGER NOT NULL CHECK("capacidade" > 0),
	PRIMARY KEY("id_mesa")
);
CREATE TABLE IF NOT EXISTS "pagamentos" (
	"id_pagamento"	INTEGER,
	"id_pedido"	INTEGER NOT NULL,
	"data_hora"	TEXT NOT NULL DEFAULT (strftime('%Y-%m-%d %H:%M:%S', 'now', 'localtime')),
	"forma"	TEXT NOT NULL CHECK("forma" IN ('PIX', 'DINHEIRO', 'CARTAO')),
	"valor_centavos"	INTEGER NOT NULL CHECK("valor_centavos" > 0),
	PRIMARY KEY("id_pagamento"),
	FOREIGN KEY("id_pedido") REFERENCES "pedidos"("id_pedido") ON DELETE RESTRICT
);
CREATE TABLE IF NOT EXISTS "pedidos" (
	"id_pedido"	INTEGER,
	"id_mesa"	INTEGER NOT NULL,
	"id_garcom"	INTEGER NOT NULL,
	"data_hora"	TEXT NOT NULL DEFAULT (strftime('%Y-%m-%d %H:%M:%S', 'now', 'localtime')),
	"status"	TEXT NOT NULL DEFAULT 'ABERTO' CHECK("status" IN ('ABERTO', 'FINALIZADO', 'CANCELADO')),
	"observacao"	TEXT,
	PRIMARY KEY("id_pedido"),
	FOREIGN KEY("id_garcom") REFERENCES "garcons"("id_garcom") ON DELETE RESTRICT,
	FOREIGN KEY("id_mesa") REFERENCES "mesas"("id_mesa") ON DELETE RESTRICT
);
CREATE TABLE IF NOT EXISTS "produtos" (
	"id_produto"	INTEGER,
	"id_categoria"	INTEGER NOT NULL,
	"nome"	TEXT NOT NULL,
	"preco_centavos"	INTEGER NOT NULL CHECK("preco_centavos" > 0),
	"ativo"	INTEGER NOT NULL DEFAULT 1 CHECK("ativo" IN (0, 1)),
	PRIMARY KEY("id_produto"),
	FOREIGN KEY("id_categoria") REFERENCES "categorias"("id_categoria") ON DELETE RESTRICT
);
INSERT INTO "categorias" ("id_categoria","nome") VALUES (1,'Bebidas');
INSERT INTO "categorias" ("id_categoria","nome") VALUES (2,'Entradas');
INSERT INTO "categorias" ("id_categoria","nome") VALUES (3,'Prato principal');
INSERT INTO "categorias" ("id_categoria","nome") VALUES (4,'Sobremesa');
INSERT INTO "garcons" ("id_garcom","nome","ativo") VALUES (1,'Ana',1);
INSERT INTO "garcons" ("id_garcom","nome","ativo") VALUES (2,'Maria',1);
INSERT INTO "garcons" ("id_garcom","nome","ativo") VALUES (3,'José',1);
INSERT INTO "garcons" ("id_garcom","nome","ativo") VALUES (4,'Rai',1);
INSERT INTO "garcons" ("id_garcom","nome","ativo") VALUES (5,'Durval',1);
INSERT INTO "garcons" ("id_garcom","nome","ativo") VALUES (6,'Cleber',1);
INSERT INTO "mesas" ("id_mesa","numero","capacidade") VALUES (1,1,4);
INSERT INTO "mesas" ("id_mesa","numero","capacidade") VALUES (2,2,4);
INSERT INTO "mesas" ("id_mesa","numero","capacidade") VALUES (3,3,4);
INSERT INTO "mesas" ("id_mesa","numero","capacidade") VALUES (4,4,4);
INSERT INTO "mesas" ("id_mesa","numero","capacidade") VALUES (5,5,2);
INSERT INTO "mesas" ("id_mesa","numero","capacidade") VALUES (6,6,2);
INSERT INTO "mesas" ("id_mesa","numero","capacidade") VALUES (7,7,2);
INSERT INTO "mesas" ("id_mesa","numero","capacidade") VALUES (8,8,2);
INSERT INTO "mesas" ("id_mesa","numero","capacidade") VALUES (9,9,6);
INSERT INTO "mesas" ("id_mesa","numero","capacidade") VALUES (10,10,6);
INSERT INTO "produtos" ("id_produto","id_categoria","nome","preco_centavos","ativo") VALUES (1,1,'Suco de Laranja',1200,1);
INSERT INTO "produtos" ("id_produto","id_categoria","nome","preco_centavos","ativo") VALUES (2,1,'Refrigerante',1000,1);
INSERT INTO "produtos" ("id_produto","id_categoria","nome","preco_centavos","ativo") VALUES (3,1,'Taça de Vinho',1800,1);
INSERT INTO "produtos" ("id_produto","id_categoria","nome","preco_centavos","ativo") VALUES (4,1,'Água',600,1);
INSERT INTO "produtos" ("id_produto","id_categoria","nome","preco_centavos","ativo") VALUES (5,2,'Patê de frango',1800,1);
INSERT INTO "produtos" ("id_produto","id_categoria","nome","preco_centavos","ativo") VALUES (6,2,'Sopa de cebola',1400,1);
INSERT INTO "produtos" ("id_produto","id_categoria","nome","preco_centavos","ativo") VALUES (7,2,'Pastel de carne',1600,1);
INSERT INTO "produtos" ("id_produto","id_categoria","nome","preco_centavos","ativo") VALUES (8,3,'Frango Marinado',3500,1);
INSERT INTO "produtos" ("id_produto","id_categoria","nome","preco_centavos","ativo") VALUES (9,3,'Carne de sol com Nata',4200,1);
INSERT INTO "produtos" ("id_produto","id_categoria","nome","preco_centavos","ativo") VALUES (10,3,'Tilápia com purê de Banana',5300,1);
INSERT INTO "produtos" ("id_produto","id_categoria","nome","preco_centavos","ativo") VALUES (11,4,'Pavê de coco com tapioca',2100,1);
INSERT INTO "produtos" ("id_produto","id_categoria","nome","preco_centavos","ativo") VALUES (12,4,'Cartola trufado',2600,1);
INSERT INTO "produtos" ("id_produto","id_categoria","nome","preco_centavos","ativo") VALUES (13,4,'Sorvete de manga em calda',1600,1);
CREATE VIEW vw_resumo_pedidos AS

SELECT

    p.id_pedido,

    p.id_mesa,

    p.id_garcom,

    p.data_hora,

    p.status,



    COALESCE((

        SELECT SUM(i.quantidade * i.preco_unitario_centavos)

        FROM itens_pedido i

        WHERE i.id_pedido = p.id_pedido

    ), 0) AS total_centavos,



    COALESCE((

        SELECT SUM(pg.valor_centavos)

        FROM pagamentos pg

        WHERE pg.id_pedido = p.id_pedido

    ), 0) AS pago_centavos,



    COALESCE((

        SELECT SUM(i.quantidade * i.preco_unitario_centavos)

        FROM itens_pedido i

        WHERE i.id_pedido = p.id_pedido

    ), 0) -

    COALESCE((

        SELECT SUM(pg.valor_centavos)

        FROM pagamentos pg

        WHERE pg.id_pedido = p.id_pedido

    ), 0) AS saldo_centavos



FROM pedidos p;
CREATE INDEX IF NOT EXISTS "idx_itens_pedido" ON "itens_pedido" (
	"id_pedido"
);
CREATE INDEX IF NOT EXISTS "idx_itens_produto" ON "itens_pedido" (
	"id_produto"
);
CREATE INDEX IF NOT EXISTS "idx_pagamentos_pedido" ON "pagamentos" (
	"id_pedido"
);
CREATE INDEX IF NOT EXISTS "idx_pedidos_garcom" ON "pedidos" (
	"id_garcom"
);
CREATE INDEX IF NOT EXISTS "idx_pedidos_mesa" ON "pedidos" (
	"id_mesa"
);
CREATE INDEX IF NOT EXISTS "idx_produtos_categoria" ON "produtos" (
	"id_categoria"
);
CREATE TRIGGER impedir_alteracao_item_encerrado

BEFORE UPDATE ON itens_pedido

FOR EACH ROW

WHEN (

    SELECT status

    FROM pedidos

    WHERE id_pedido = OLD.id_pedido

) <> 'ABERTO'

BEGIN

    SELECT RAISE(

        ABORT,

        'Erro: nao e permitido alterar itens de pedidos encerrados.'

    );

END;
CREATE TRIGGER impedir_exclusao_item_encerrado

BEFORE DELETE ON itens_pedido

FOR EACH ROW

WHEN (

    SELECT status

    FROM pedidos

    WHERE id_pedido = OLD.id_pedido

) <> 'ABERTO'

BEGIN

    SELECT RAISE(

        ABORT,

        'Erro: nao e permitido excluir itens de pedidos encerrados.'

    );

END;
CREATE TRIGGER impedir_insercao_item_encerrado

BEFORE INSERT ON itens_pedido

FOR EACH ROW

WHEN (

    SELECT status

    FROM pedidos

    WHERE id_pedido = NEW.id_pedido

) <> 'ABERTO'

BEGIN

    SELECT RAISE(

        ABORT,

        'Erro: nao e permitido adicionar itens a pedidos encerrados.'

    );

END;
CREATE TRIGGER impedir_pagamento_pedido_encerrado

BEFORE INSERT ON pagamentos

FOR EACH ROW

WHEN (

    SELECT status

    FROM pedidos

    WHERE id_pedido = NEW.id_pedido

) <> 'ABERTO'

BEGIN

    SELECT RAISE(

        ABORT,

        'Erro: somente pedidos abertos podem receber pagamentos.'

    );

END;
CREATE TRIGGER validar_finalizacao_pedido

BEFORE UPDATE OF status ON pedidos

FOR EACH ROW

WHEN NEW.status = 'FINALIZADO'

BEGIN



    -- O pedido precisa ter pelo menos um item.

    SELECT CASE

        WHEN NOT EXISTS (

            SELECT 1

            FROM itens_pedido

            WHERE id_pedido = NEW.id_pedido

        )

        THEN RAISE(

            ABORT,

            'Erro: o pedido precisa ter pelo menos um item.'

        )

    END;



    -- Os pagamentos devem cobrir o total do pedido.

    SELECT CASE

        WHEN COALESCE((

            SELECT SUM(quantidade * preco_unitario_centavos)

            FROM itens_pedido

            WHERE id_pedido = NEW.id_pedido

        ), 0) >

        COALESCE((

            SELECT SUM(valor_centavos)

            FROM pagamentos

            WHERE id_pedido = NEW.id_pedido

        ), 0)

        THEN RAISE(

            ABORT,

            'Erro: pagamento insuficiente para finalizar o pedido.'

        )

    END;



END;
CREATE TRIGGER validar_pagamento_insert

BEFORE INSERT ON pagamentos

FOR EACH ROW

WHEN (

    SELECT status

    FROM pedidos

    WHERE id_pedido = NEW.id_pedido

) = 'ABERTO'

BEGIN



    SELECT CASE

        WHEN NEW.valor_centavos + COALESCE((

            SELECT SUM(valor_centavos)

            FROM pagamentos

            WHERE id_pedido = NEW.id_pedido

        ), 0) >

        COALESCE((

            SELECT SUM(quantidade * preco_unitario_centavos)

            FROM itens_pedido

            WHERE id_pedido = NEW.id_pedido

        ), 0)

        THEN RAISE(

            ABORT,

            'Erro: o pagamento ultrapassa o total do pedido.'

        )

    END;



END;
COMMIT;
