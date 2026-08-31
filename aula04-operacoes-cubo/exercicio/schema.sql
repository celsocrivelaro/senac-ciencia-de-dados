DROP TABLE IF EXISTS fato_vendas CASCADE;
DROP TABLE IF EXISTS dim_pais CASCADE;
DROP TABLE IF EXISTS dim_marca CASCADE;
DROP TABLE IF EXISTS dim_tempo CASCADE;
DROP TABLE IF EXISTS dim_segmento CASCADE;

CREATE TABLE dim_tempo (
	id INT NOT NULL GENERATED ALWAYS AS IDENTITY,
    dia INT NOT NULL,
    mes INT NOT NULL,
    ano int NOT NULL,
    dia_semana VARCHAR NOT NULL,
    no_semana_ano int NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE dim_segmento (
	id INT NOT NULL GENERATED ALWAYS AS IDENTITY,
    segmento VARCHAR NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE dim_pais (
	id INT NOT NULL GENERATED ALWAYS AS IDENTITY,
    pais VARCHAR NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE dim_marca (
	id INT NOT NULL GENERATED ALWAYS AS IDENTITY,
    marca VARCHAR NOT NULL,
		id_pais INT NOT NULL,
    PRIMARY KEY (id),
		CONSTRAINT fk_pais FOREIGN KEY(id_pais) REFERENCES dim_pais(id)
);

CREATE TABLE fato_vendas (
    id_marca INT NOT NULL,
    id_segmento INT NOT NULL,
    quantidade INT NOT NULL,
    id_tempo INT NOT NULL,
    PRIMARY KEY (id_marca, id_segmento, id_tempo),
		CONSTRAINT fk_marca FOREIGN KEY(id_marca) REFERENCES dim_marca(id),
    CONSTRAINT fk_segmento FOREIGN KEY(id_segmento) REFERENCES dim_segmento(id),
		CONSTRAINT fk_tempo FOREIGN KEY(id_tempo) REFERENCES dim_tempo(id)
);
