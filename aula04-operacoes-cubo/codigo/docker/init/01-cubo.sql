-- =====================================================================
-- Cubo de vendas da aula 04 — schema e massa de dados.
--
-- O entrypoint do Postgres executa este arquivo sozinho, uma única vez,
-- na primeira subida do container (quando o volume de dados está vazio).
--
-- Fonte do schema: ../operacoes-cubo.md (é ele o material da aula).
-- Diferença proposital: lá o fato_vendas tem 80 linhas escritas à mão,
-- cobrindo 4 dias. Aqui são 30 dias e 600 linhas, geradas por fórmula —
-- volume suficiente para os gráficos do Metabase ficarem legíveis.
-- Marcas, segmentos e a força relativa de cada combinação são as mesmas,
-- então as consultas do markdown contam a mesma história.
-- =====================================================================

-- A seção de Pivot do material usa crosstab(), que vive nesta extensão.
-- Criando aqui, o aluno não precisa lembrar do CREATE EXTENSION.
CREATE EXTENSION IF NOT EXISTS tablefunc;

/* =========================================================
   1) Schema estrela
========================================================= */
DROP TABLE IF EXISTS fato_vendas CASCADE;
DROP TABLE IF EXISTS dim_dias CASCADE;
DROP TABLE IF EXISTS dim_segmentos CASCADE;
DROP TABLE IF EXISTS dim_marcas CASCADE;

CREATE TABLE dim_marcas (
    id_marca INT PRIMARY KEY,
    marca VARCHAR NOT NULL
);

CREATE TABLE dim_segmentos (
    id_segmento INT PRIMARY KEY,
    segmento VARCHAR NOT NULL
);

CREATE TABLE dim_dias (
    id_dia INT PRIMARY KEY,
    dia INT NOT NULL
);

CREATE TABLE fato_vendas (
    id_marca INT NOT NULL,
    id_segmento INT NOT NULL,
    id_dia INT NOT NULL,
    quantidade INT NOT NULL,

    PRIMARY KEY (id_marca, id_segmento, id_dia),
    FOREIGN KEY (id_marca) REFERENCES dim_marcas(id_marca),
    FOREIGN KEY (id_segmento) REFERENCES dim_segmentos(id_segmento),
    FOREIGN KEY (id_dia) REFERENCES dim_dias(id_dia)
);

/* =========================================================
   2) Dimensões
========================================================= */
INSERT INTO dim_marcas (id_marca, marca) VALUES
    (1, 'Naique'),
    (2, 'Ardida'),
    (3, 'Pumita'),
    (4, 'Reeboca');

INSERT INTO dim_segmentos (id_segmento, segmento) VALUES
    (1, 'Premium'),
    (2, 'Corrida'),
    (3, 'Futebol'),
    (4, 'Casual'),
    (5, 'Treino');

-- 30 dias, para o mês inteiro aparecer nos gráficos.
INSERT INTO dim_dias (id_dia, dia)
SELECT g, g FROM generate_series(1, 30) AS g;

/* =========================================================
   3) Fato — 4 marcas x 5 segmentos x 30 dias = 600 células
========================================================= */
INSERT INTO fato_vendas (id_marca, id_segmento, id_dia, quantidade)
SELECT
    b.id_marca,
    b.id_segmento,
    d.id_dia,
    GREATEST(1,
        b.base
        -- pico de fim de semana: dias 6, 7, 13, 14, ... rendem +20%
        + b.base * (CASE WHEN d.dia % 7 IN (0, 6) THEN 20 ELSE 0 END) / 100
        -- variação determinística de -10% a +10%, para a série não ser reta
        + b.base * ((b.id_marca * 7 + b.id_segmento * 13 + d.dia * 29) % 21 - 10) / 100
    ) AS quantidade
FROM (
    -- Patamar médio de cada combinação, tirado das 80 linhas do material:
    -- Ardida domina Corrida e Futebol, Pumita vai bem em Futebol,
    -- Reeboca em Treino, e Casual é o segmento fraco de todas.
    VALUES
        (1, 1, 111), (1, 2, 201), (1, 3, 155), (1, 4,  97), (1, 5, 132),
        (2, 1,  87), (2, 2, 350), (2, 3, 297), (2, 4, 157), (2, 5, 212),
        (3, 1, 126), (3, 2, 182), (3, 3, 251), (3, 4,  99), (3, 5, 167),
        (4, 1, 147), (4, 2, 221), (4, 3, 182), (4, 4, 116), (4, 5, 202)
) AS b(id_marca, id_segmento, base)
CROSS JOIN dim_dias d;
