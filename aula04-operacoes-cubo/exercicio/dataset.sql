DELETE FROM fato_vendas;
DELETE FROM dim_marca;
DELETE FROM dim_pais;
DELETE FROM dim_tempo;
DELETE FROM dim_segmento;

INSERT INTO dim_pais (id, pais) OVERRIDING SYSTEM VALUE VALUES
(1, 'Brasil'), (2, 'Europa'), (3, 'Estados Unidos'), (4, 'Japão');

INSERT INTO dim_marca (id, marca, id_pais) OVERRIDING SYSTEM VALUE  VALUES
(1, 'New Balance', 3),
(2, 'Nike', 3),
(3, 'Adidas', 2),
(4, 'Fila', 2),
(5, 'Rainha', 1),
(6, 'Mizuno', 4),
(7, 'Asics', 4),
(8, 'Olympikus', 1);

INSERT INTO dim_segmento (id, segmento) OVERRIDING SYSTEM VALUE VALUES
(1, 'Corrida'),
(2, 'Treino'),
(3, 'Futebol'),
(4, 'Casual'),
(5, 'Skate'),
(6, 'Basquete');

INSERT INTO dim_tempo (id, dia, dia_semana, mes, ano, no_semana_ano) OVERRIDING SYSTEM VALUE VALUES 
(1,  1, 'Quarta-feira', 11, 2023, 44),
(2,  2, 'Quinta-feira', 11, 2023, 44),
(3,  3, 'Sexta-feira', 11, 2023, 44),
(4,  4, 'Sábado', 11, 2023, 44),
(5,  5, 'Domingo', 11, 2023, 44),
(6,  6, 'Segunda-feira', 11, 2023, 45),
(7,  7, 'Terça-feira', 11, 2023, 45),
(8,  8, 'Quarta-feira', 11, 2023, 45),
(9,  9, 'Quinta-feira', 11, 2023, 45),
(10, 10, 'Sexta-feira', 11, 2023, 45),
(11, 11, 'Sábado', 11, 2023, 45),
(12, 12, 'Domingo', 11, 2023, 45),
(13, 13, 'Segunda-feira', 11, 2023, 46),
(14, 14, 'Terça-feira', 11, 2023, 46),
(15, 15, 'Quarta-feira', 11, 2023, 46),
(16, 16, 'Quinta-feira', 11, 2023, 46),
(17, 17, 'Sexta-feira', 11, 2023, 46),
(18, 18, 'Sábado', 11, 2023, 46),
(19, 19, 'Domingo', 11, 2023, 46),
(20, 20, 'Segunda-feira', 11, 2023, 47),
(21, 21, 'Terça-feira', 11, 2023, 47),
(22, 22, 'Quarta-feira', 11, 2023, 47),
(23, 23, 'Quinta-feira', 11, 2023, 47),
(24, 24, 'Sexta-feira', 11, 2023, 47),
(25, 25, 'Sábado', 11, 2023, 47),
(26, 26, 'Domingo', 11, 2023, 47),
(27, 27, 'Segunda-feira', 11, 2023, 48),
(28, 28, 'Terça-feira', 11, 2023, 48),
(29, 29, 'Quarta-feira', 11, 2023, 48),
(30, 30, 'Quinta-feira', 11, 2023, 48);

DELETE FROM fato_vendas;

-- Dia 01/11/2022
INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
(1, 4, 25, 1),
(2, 5, 34, 1),
(3, 1, 23, 1),
(4, 6, 54, 1),
(5, 3, 40, 1),
(6, 2, 29, 1),
(7, 1, 50, 1),
(8, 4, 37, 1),
(1, 1, 41, 1),
(2, 2, 36, 1),
(3, 3, 9, 1),
(4, 5, 7, 1),
(5, 6, 15, 1),
(6, 3, 10, 1),
(7, 3, 8, 1),
(8, 5, 11, 1);

-- Dia 02/11/2022
INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
(1, 3, 47, 2),
(2, 4, 26, 2),
(3, 5, 33, 2),
(4, 1, 60, 2),
(5, 2, 43, 2),
(6, 3, 35, 2),
(7, 6, 28, 2),
(8, 5, 22, 2),
(1, 2, 39, 2),
(2, 1, 48, 2),
(7, 4, 37, 2),
(8, 1, 45, 2),
(3, 2, 16, 2),
(4, 3, 14, 2),
(5, 4, 17, 2),
(6, 1, 9, 2),
(1, 1, 18, 2),
(2, 6, 11, 2);

-- Dia 03/11/2022
INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
(1, 5, 53, 3),
(2, 6, 46, 3),
(3, 3, 21, 3),
(4, 2, 32, 3),
(5, 1, 27, 3),
(6, 4, 38, 3),
(7, 5, 29, 3),
(8, 6, 44, 3),
(1, 2, 13, 3),
(2, 1, 16, 3),
(3, 1, 9, 3),
(4, 4, 14, 3),
(5, 2, 11, 3),
(6, 5, 8, 3),
(7, 2, 12, 3),
(8, 3, 10, 3);

-- Dia 04/11/2022
INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
(1, 2, 30, 4),
(2, 4, 20, 4),
(3, 1, 25, 4),
(4, 5, 15, 4),
(5, 6, 12, 4),
(6, 3, 35, 4),
(7, 1, 24, 4),
(8, 2, 30, 4),
(1, 6, 40, 4),
(2, 1, 15, 4),
(3, 2, 13, 4),
(4, 1, 19, 4),
(5, 5, 18, 4),
(6, 1, 14, 4),
(7, 3, 16, 4),
(8, 1, 11, 4);

-- Dia 05/11/2022
INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
(7, 5, 19, 5),
(8, 6, 27, 5),
(3, 5, 18, 5),
(2, 1, 30, 5),
(4, 2, 35, 5),
(1, 3, 20, 5),
(5, 4, 29, 5),
(6, 5, 24, 5),
(7, 1, 20, 5),
(8, 2, 17, 5),
(1, 1, 15, 5),
(2, 2, 16, 5),
(3, 2, 14, 5),
(4, 5, 12, 5),
(5, 1, 13, 5),
(6, 2, 11, 5);

-- Dia 06/11/2022 (14 registros únicos)
INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
(4, 3, 40, 6),
(3, 2, 25, 6),
(1, 5, 20, 6),
(7, 6, 35, 6),
(8, 1, 30, 6),
(5, 4, 23, 6),
(2, 3, 26, 6),
(3, 5, 25, 6),
(1, 2, 36, 6),
(4, 4, 19, 6),
(6, 1, 34, 6),
(7, 3, 21, 6),
(2, 6, 22, 6),
(5, 1, 38, 6);

-- Dia 07/11/2022 (8 registros únicos)
INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
(1, 2, 30, 7),
(2, 4, 20, 7),
(3, 1, 25, 7),
(4, 5, 15, 7),
(5, 6, 12, 7),
(6, 3, 35, 7),
(7, 1, 24, 7),
(8, 2, 30, 7);

-- Dia 08/11/2022 (9 registros únicos)
INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
(7, 5, 19, 8),
(8, 6, 27, 8),
(3, 5, 18, 8),
(2, 1, 30, 8),
(4, 2, 35, 8),
(1, 3, 20, 8),
(2, 4, 29, 8),
(7, 2, 24, 8),
(3, 6, 16, 8);

-- Dia 09/11/2022 (10 registros únicos)
INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
(4, 3, 40, 9),
(3, 2, 25, 9),
(1, 5, 20, 9),
(7, 6, 35, 9),
(8, 1, 30, 9),
(5, 4, 23, 9),
(2, 3, 26, 9),
(3, 5, 25, 9),
(1, 2, 36, 9),
(4, 4, 19, 9);

-- Dia 10/11/2022 (11 registros únicos)
INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
(6, 1, 34, 10),
(7, 3, 21, 10),
(2, 6, 22, 10),
(5, 1, 38, 10),
(8, 4, 16, 10),
(4, 6, 12, 10),
(7, 1, 24, 10),
(5, 2, 25, 10),
(6, 4, 16, 10),
(3, 6, 22, 10),
(1, 4, 31, 10);

-- Dia 11/11/2022 (sem duplicatas)
INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
(5, 4, 12, 11),
(6, 3, 28, 11),
(7, 1, 24, 11),
(8, 6, 29, 11),
(1, 5, 15, 11),
(3, 2, 21, 11),
(4, 4, 19, 11),
(2, 3, 18, 11),
(7, 2, 20, 11),
-- Substituições
(2, 1, 16, 11),
(4, 5, 9, 11),
(3, 5, 17, 11),
(8, 5, 10, 11),
(1, 2, 13, 11);

-- Dia 12/11/2022 (sem duplicatas)
INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
(2, 1, 35, 12),
(3, 4, 25, 12),
(4, 5, 20, 12),
(5, 3, 18, 12),
(6, 2, 22, 12),
(7, 5, 24, 12),
(8, 4, 29, 12),
(1, 3, 15, 12),
(4, 2, 17, 12),
(2, 6, 21, 12),
-- Substituições
(3, 1, 19, 12),
(1, 4, 13, 12),
(5, 1, 11, 12),
(6, 6, 14, 12),
(8, 1, 9, 12);

INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
-- Dia 13/11/2022 (12 registros)
(8, 2, 30, 13),
(7, 4, 25, 13),
(6, 5, 18, 13),
(5, 6, 17, 13),
(4, 3, 15, 13),
(3, 2, 22, 13),
(1, 4, 19, 13),
(2, 5, 20, 13),
(3, 6, 21, 13),
(4, 1, 30, 13),
(5, 2, 25, 13),
(6, 3, 18, 13),
(8, 1, 20, 13),
(1, 5, 16, 13),
(2, 3, 14, 13),
(3, 5, 17, 13),
(4, 2, 11, 13),
(5, 1, 9, 13),
(6, 4, 15, 13),
(7, 6, 19, 13),
(8, 5, 18, 13);

INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
-- Dia 14/11/2022 (24 registros, no duplicates)
(7, 2, 24, 14),
(6, 1, 22, 14),
(5, 4, 20, 14),
(4, 5, 25, 14),
(3, 6, 30, 14),
(2, 1, 28, 14),
(1, 2, 18, 14),
(8, 3, 19, 14),
(7, 5, 20, 14),  -- Changed 7,4 to 7,5
(6, 4, 25, 14),  -- Changed 6,5 to 6,4
(5, 5, 30, 14),  -- Changed 5,6 to 5,5
(4, 2, 28, 14),  -- Changed 4,1 to 4,2
(3, 3, 18, 14),  -- Changed 3,2 to 3,3
(2, 2, 19, 14),  -- Changed 2,3 to 2,2
(3, 1, 16, 14),  
(4, 6, 14, 14),  
(5, 1, 18, 14),  -- Changed 5,4 to 5,1
(6, 2, 10, 14),  -- Changed 6,5 to 6,2
(7, 6, 12, 14),  -- Changed 7,2 to 7,6
(8, 4, 19, 14),  -- Changed 8,3 to 8,4
(1, 3, 15, 14),  
(2, 5, 9, 14),   -- Changed 2,4 to 2,5
(5, 3, 17, 14),  
(6, 3, 11, 14);  -- Changed 6,6 to 6,3

INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
-- Dia 15/11/2022 (20 registros, no duplicates)
(1, 4, 35, 15),
(8, 5, 30, 15),
(7, 6, 25, 15),
(6, 1, 22, 15),
(5, 2, 20, 15),
(4, 3, 18, 15),
(3, 4, 16, 15),
(2, 5, 14, 15),
(7, 3, 13, 15),  -- Changed 7,4 to 7,3
(8, 4, 14, 15),  -- Changed 8,2 to 8,4
(1, 5, 16, 15),  -- Changed 1,4 to 1,5
(2, 6, 17, 15),
(3, 1, 18, 15),  -- Changed 3,5 to 3,1
(4, 6, 19, 15),  -- Changed 4,1 to 4,6
(5, 3, 12, 15),  -- Changed 5,6 to 5,3
(6, 2, 10, 15),  -- Changed 6,3 to 6,2
(7, 5, 11, 15),  -- Changed 7,1 to 7,5
(8, 1, 9, 15),   -- Changed 8,6 to 8,1
(2, 3, 20, 15),  -- Changed 2,1 to 2,3
(3, 5, 21, 15);  -- Changed 3,2 to 3,5

INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
-- Dia 16/11/2022 (15 registros, no duplicates)
(3, 1, 20, 16),
(7, 5, 25, 16),
(1, 4, 15, 16),
(5, 6, 18, 16),
(2, 3, 22, 16),
(8, 2, 16, 16),
(6, 5, 30, 16),
(4, 1, 14, 16),
(7, 6, 22, 16),  -- Changed 7,5 to 7,6
(8, 3, 15, 16),  -- Changed 8,4 to 8,3
(1, 5, 18, 16),  -- Changed 1,1 to 1,5
(2, 4, 19, 16),  -- Changed 2,2 to 2,4
(3, 2, 12, 16),  -- Changed 3,3 to 3,2
(4, 6, 14, 16),  -- Changed 4,5 to 4,6
(5, 3, 16, 16);  -- Changed 5,4 to 5,3

INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
-- Dia 17/11/2022 (20 registros, no duplicates)
(7, 3, 20, 17),
(6, 4, 21, 17),
(5, 2, 18, 17),
(1, 6, 30, 17),
(3, 5, 28, 17),
(2, 1, 14, 17),
(8, 6, 22, 17),
(4, 3, 24, 17),
(3, 6, 20, 17),  -- Changed 3,4 to 3,6
(7, 5, 19, 17),  -- Changed 7,2 to 7,5
(6, 5, 13, 17),  -- Changed 6,2 to 6,5
(7, 1, 15, 17),  -- Changed 7,6 to 7,1
(8, 4, 9, 17),   -- Changed 8,5 to 8,4
(1, 3, 18, 17),  -- Changed 1,2 to 1,3
(2, 5, 19, 17),  -- Changed 2,1 to 2,5
(3, 2, 12, 17),  -- Changed 3,4 to 3,2
(4, 5, 10, 17),  -- Changed 4,3 to 4,5
(5, 1, 11, 17),  -- Changed 5,5 to 5,1
(6, 3, 16, 17),  -- Changed 6,1 to 6,3
(7, 4, 17, 17);  -- Kept as is

INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
-- Dia 18/11/2022 (17 registros, no duplicates)
(1, 2, 16, 18),
(2, 4, 28, 18),
(8, 1, 22, 18),
(6, 3, 26, 18),
(7, 5, 30, 18),
(5, 6, 14, 18),
(3, 4, 18, 18),
(4, 2, 24, 18),
(1, 5, 20, 18),
(2, 5, 22, 18), -- Changed from (1, 2, 22, 18) to (2, 5, 22, 18)
(2, 3, 19, 18),
(3, 1, 24, 18), -- Changed from (3, 5, 24, 18) to (3, 1, 24, 18)
(4, 1, 21, 18),
(5, 4, 17, 18), -- Changed from (5, 6, 17, 18) to (5, 4, 17, 18)
(6, 4, 15, 18),
(7, 3, 23, 18),
(8, 2, 20, 18);

INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
-- Dia 19/11/2022 (26 registros, no duplicates)
(8, 3, 22, 19),
(7, 4, 26, 19),
(4, 6, 20, 19),
(3, 5, 16, 19),
(6, 1, 30, 19),
(5, 2, 24, 19),
(2, 5, 18, 19),
(1, 6, 20, 19),
(3, 4, 26, 19),
(4, 3, 22, 19),
(7, 2, 24, 19),
(8, 1, 30, 19),
(1, 1, 17, 19),  -- Changed from (3, 2, 17, 19) to (1, 1, 17, 19)
(4, 4, 18, 19),
(5, 5, 20, 19),  -- Changed from (5, 1, 20, 19) to (5, 5, 20, 19)
(6, 5, 19, 19),  -- Changed from (6, 3, 19, 19) to (6, 5, 19, 19)
(2, 2, 16, 19),  -- Changed from (7, 5, 16, 19) to (2, 2, 16, 19)
(8, 4, 25, 19),  -- Changed from (8, 6, 25, 19) to (8, 4, 25, 19)
(1, 3, 24, 19),  -- Changed from (1, 4, 24, 19) to (1, 3, 24, 19)
(1, 2, 21, 19),  -- Changed from (2, 5, 21, 19) to (1, 2, 21, 19)
(2, 3, 19, 19),  -- Changed from (5, 2, 19, 19) to (2, 3, 19, 19)
(2, 4, 22, 19),  -- Changed from (6, 1, 22, 19) to (2, 4, 22, 19)
(2, 6, 18, 19),  -- Changed from (7, 4, 18, 19) to (2, 6, 18, 19)
(3, 1, 23, 19),  -- Changed from (8, 3, 23, 19) to (3, 1, 23, 19)
(3, 3, 20, 19),  -- Changed from (3, 6, 20, 19) to (3, 3, 20, 19)
(5, 3, 15, 19);  -- Changed from (4, 5, 15, 19) to (5, 3, 15, 19)

INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
-- Dia 20/11/2022 (22 registros, no duplicates)
(5, 3, 18, 20),
(1, 4, 30, 20),
(2, 6, 16, 20),
(8, 5, 20, 20),
(7, 1, 22, 20),
(4, 2, 26, 20),
(3, 6, 24, 20),
(6, 3, 30, 20),
(1, 5, 14, 20),  -- Changed from (7, 5, 14, 20) to (1, 5, 14, 20)
(2, 2, 16, 20),  -- Changed from (8, 4, 16, 20) to (2, 2, 16, 20)
(1, 2, 28, 20),
(2, 3, 20, 20),  -- Changed from (5, 6, 20, 20) to (2, 3, 20, 20)
(3, 2, 24, 20),  -- Changed from (2, 4, 24, 20) to (3, 2, 24, 20)
(4, 5, 26, 20),  -- Changed from (6, 1, 26, 20) to (4, 5, 26, 20)
(3, 3, 16, 20),  -- Changed from (7, 6, 16, 20) to (3, 3, 16, 20)
(3, 5, 19, 20),  -- Changed from (8, 4, 19, 20) to (3, 5, 19, 20)
(4, 3, 17, 20),  -- Changed from (1, 3, 17, 20) to (4, 3, 17, 20)
(5, 4, 21, 20),  -- Changed from (2, 1, 21, 20) to (5, 4, 21, 20)
(6, 6, 18, 20),  -- Changed from (3, 4, 18, 20) to (6, 6, 18, 20)
(7, 2, 16, 20),  -- Changed from (4, 2, 16, 20) to (7, 2, 16, 20)
(8, 1, 22, 20),  -- Changed from (5, 3, 22, 20) to (8, 1, 22, 20)
(8, 3, 20, 20);  -- Changed from (6, 5, 20, 20) to (8, 3, 20, 20)

-- Re-generated INSERT INTO fato_vendas for 21/11/2022 with duplicates removed
INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
-- Dia 21/11/2022 (18 registros, no duplicates)
(4, 5, 16, 21),
(3, 6, 30, 21),
(2, 3, 24, 21),
(1, 4, 20, 21),
(8, 2, 26, 21),
(7, 3, 18, 21),
(6, 4, 22, 21),
(5, 1, 28, 21),
(7, 2, 17, 21),
(8, 1, 21, 21),
(2, 4, 24, 21),
(3, 1, 23, 21),
(1, 5, 16, 21), -- Changed from (4, 3, 16, 21) to (1, 5, 16, 21)
(5, 4, 25, 21),
(6, 6, 18, 21),
(7, 1, 22, 21),
(5, 5, 19, 21),
(6, 2, 20, 21);

-- Re-generated INSERT INTO fato_vendas for 22/11/2022 with duplicates removed
INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
-- Dia 22/11/2022 (18 registros, no duplicates)
(1, 2, 15, 22),
(4, 5, 20, 22),
(7, 3, 10, 22),
(3, 1, 12, 22),
(8, 4, 17, 22),
(2, 6, 21, 22),
(5, 2, 18, 22),
(6, 5, 11, 22),
(1, 3, 16, 22), -- Changed from (8, 5, 16, 22) to (1, 3, 16, 22)
(1, 6, 21, 22),
(2, 2, 22, 22),
(3, 3, 18, 22),
(4, 6, 19, 22),
(5, 1, 24, 22),
(6, 4, 17, 22),
(7, 2, 16, 22), -- Changed from (7, 5, 16, 22) to (7, 2, 16, 22)
(8, 1, 23, 22), -- Changed from (8, 6, 23, 22) to (8, 1, 23, 22)
(1, 5, 20, 22);

INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
-- Dia 23/11/2022 (23 registros, no duplicates)
(4, 2, 14, 23),
(3, 4, 19, 23),
(1, 5, 20, 23),
(7, 6, 21, 23),
(2, 3, 13, 23),
(8, 1, 17, 23),
(6, 4, 15, 23),
(5, 3, 12, 23),
(1, 6, 14, 23), -- Changed from (4, 1, 14, 23) to (1, 6, 14, 23)
(7, 5, 16, 23),
(2, 4, 18, 23), -- Changed from (4, 1, 18, 23) to (2, 4, 18, 23)
(5, 2, 16, 23),
(6, 3, 19, 23),
(7, 4, 25, 23),
(8, 5, 22, 23),
(1, 1, 21, 23),
(2, 6, 17, 23),
(3, 2, 20, 23),
(4, 3, 19, 23), -- Changed from (4, 4, 19, 23) to (4, 3, 19, 23)
(5, 6, 24, 23),
(6, 1, 18, 23),
(7, 3, 22, 23),
(8, 2, 17, 23);

-- Re-generated INSERT INTO fato_vendas for 24/11/2022 with duplicates removed
INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
-- Dia 24/11/2022 (23 registros, no duplicates)
(2, 5, 21, 24),
(3, 2, 10, 24),
(1, 6, 17, 24),
(6, 3, 14, 24),
(4, 4, 15, 24),
(8, 5, 20, 24),
(5, 6, 19, 24),
(7, 1, 13, 24),
(1, 5, 18, 24), -- Changed from (2, 4, 18, 24) to (1, 5, 18, 24)
(8, 1, 17, 24), -- Changed from (1, 4, 17, 24) to (8, 1, 17, 24)
(3, 5, 18, 24), -- Changed from (2, 5, 18, 24) to (3, 5, 18, 24)
(3, 6, 19, 24),
(4, 2, 16, 24),
(5, 3, 21, 24),
(6, 1, 20, 24),
(7, 5, 19, 24),
(8, 4, 18, 24),
(1, 3, 17, 24),
(2, 6, 16, 24),
(3, 1, 22, 24),
(4, 5, 19, 24),
(5, 4, 20, 24),
(6, 2, 15, 24);

-- Dia 25/11/2022 (20 registros, no duplicates)
INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
(7, 2, 15, 25),
(1, 4, 14, 25),
(6, 5, 17, 25),
(3, 6, 21, 25),
(2, 1, 19, 25),
(8, 3, 13, 25),
(4, 6, 10, 25),
(5, 1, 20, 25),
(7, 4, 12, 25),
(3, 5, 16, 25),
(6, 2, 18, 25),
(1, 3, 11, 25),
(8, 4, 17, 25), -- Modified from (7, 1, 17, 25) to (8, 4, 17, 25)
(4, 5, 16, 25), -- Modified from (8, 3, 16, 25) to (4, 5, 16, 25)
(1, 5, 21, 25),
(2, 4, 20, 25),
(3, 2, 22, 25),
(4, 1, 18, 25), -- Modified from (4, 6, 18, 25) to (4, 1, 18, 25)
(5, 3, 19, 25), -- Modified from (5, 1, 19, 25) to (5, 3, 19, 25)
(6, 1, 17, 25); -- Modified from (6, 5, 17, 25) to (6, 1, 17, 25)

-- Dia 26/11/2022 (26 registros, no duplicates)
INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
(4, 2, 19, 26),
(8, 6, 17, 26),
(2, 5, 15, 26),
(1, 1, 20, 26),
(3, 4, 21, 26),
(5, 3, 16, 26),
(7, 5, 14, 26),
(6, 6, 13, 26),
(4, 1, 10, 26),
(7, 6, 18, 26), -- Modified from (3, 5, 18, 26) to (7, 6, 18, 26)
(2, 3, 12, 26),
(1, 2, 11, 26),
(8, 4, 16, 26),
(5, 2, 15, 26),
(6, 2, 16, 26), -- Modified from (8, 2, 16, 26) to (6, 2, 16, 26)
(1, 6, 15, 26),
(2, 2, 17, 26), -- Modified from (2, 3, 17, 26) to (2, 2, 17, 26)
(3, 1, 18, 26), -- Modified from (3, 4, 18, 26) to (3, 1, 18, 26)
(4, 5, 19, 26), -- Modified from (4, 1, 19, 26) to (4, 5, 19, 26)
(5, 1, 20, 26), -- Modified from (5, 2, 20, 26) to (5, 1, 20, 26)
(6, 3, 21, 26), -- Modified from (6, 6, 21, 26) to (6, 3, 21, 26)
(7, 4, 22, 26),
(8, 5, 19, 26), -- Modified from (8, 1, 19, 26) to (8, 5, 19, 26)
(2, 4, 16, 26), -- Modified from (2, 1, 16, 26) to (2, 4, 16, 26)
(3, 3, 18, 26), -- Modified from (3, 5, 18, 26) to (3, 3, 18, 26)
(4, 3, 21, 26); -- Modified from (4, 4, 21, 26) to (4, 3, 21, 26)

INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
-- Dia 27/11/2022 (17 registros, removed duplicates and replaced)
(6, 1, 14, 27),
(5, 4, 21, 27),
(4, 3, 19, 27),
(3, 2, 15, 27),
(2, 6, 13, 27),
(1, 5, 16, 27),
(8, 2, 20, 27),
(7, 3, 17, 27),
-- replaced duplicates with new combinations
(6, 5, 17, 27),  -- replaced 6,3
(7, 4, 16, 27),  -- replaced 7,2
(8, 6, 18, 27),
(1, 2, 21, 27),
(2, 5, 19, 27),
(3, 3, 16, 27),
(4, 2, 15, 27),
(5, 6, 20, 27),
(6, 4, 22, 27);

-- Dia 28/11/2022 (No duplicates, replacements are made)
INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
(2, 1, 15, 28),
(3, 3, 21, 28),
(1, 6, 12, 28),
(4, 5, 17, 28),
(6, 4, 19, 28),
(5, 2, 20, 28),
(8, 1, 14, 28),
(7, 6, 18, 28),
(2, 4, 16, 28),
-- Replacements below
(7, 5, 19, 28), -- replaced 7, 6
(8, 2, 21, 28), -- replaced 8, 5
(1, 2, 17, 28), -- replaced 1, 1
(2, 5, 19, 28), -- replaced 2, 2
(3, 4, 20, 28), -- replaced 3, 6
(4, 1, 15, 28), -- replaced 4, 3
(5, 6, 18, 28), -- replaced 5, 4
(6, 3, 16, 28), -- replaced 6, 5
(7, 2, 22, 28), -- replaced 7, 3
(8, 3, 17, 28); -- replaced 8, 4

-- Dia 29/11/2022 (No duplicates, replacements are made)
INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
(2, 4, 12, 29),
(7, 5, 16, 29),
(1, 3, 20, 29),
(3, 1, 15, 29),
(8, 6, 19, 29),
(4, 2, 14, 29),
(6, 3, 17, 29),
(5, 1, 18, 29),
(2, 6, 13, 29),
(7, 2, 21, 29),
-- Replacements below
(1, 5, 16, 29), -- replaced 1, 3
(2, 1, 15, 29), -- replaced 2, 6
(3, 5, 18, 29), -- replaced 3, 1
(4, 6, 19, 29), -- replaced 4, 4
(5, 3, 22, 29), -- replaced 5, 5
(6, 1, 21, 29), -- replaced 6, 2
(7, 4, 17, 29), -- replaced 7, 5
(8, 2, 20, 29), -- replaced 8, 1
(1, 2, 18, 29), -- replaced 1, 4
(2, 3, 19, 29); -- replaced 2, 3

-- Dia 30/11/2022 (No duplicates, replacements are made)
INSERT INTO fato_vendas (id_marca, id_segmento, quantidade, id_tempo) VALUES
(6, 4, 18, 30),
(1, 2, 15, 30),
(7, 1, 13, 30),
(4, 5, 16, 30),
(5, 3, 20, 30),
(8, 4, 14, 30),
(2, 5, 12, 30),
(3, 6, 19, 30),
(7, 3, 21, 30),
(1, 4, 17, 30),
(4, 1, 15, 30),
(6, 2, 16, 30),
-- Replacements below
(8, 2, 17, 30),  -- replaced 4, 5
(5, 6, 20, 30),  -- replaced 5, 1
(6, 5, 19, 30),  -- replaced 6, 6
(7, 5, 15, 30),  -- replaced 7, 4
(8, 1, 18, 30),  -- replaced 8, 3
(1, 3, 21, 30),  -- replaced 1, 6
(2, 4, 20, 30),  -- replaced 2, 5
(3, 5, 17, 30),  -- replaced 3, 4
(4, 6, 16, 30),  -- replaced 4, 3
(5, 4, 15, 30),  -- replaced 5, 2
(6, 3, 22, 30),  -- replaced 6, 1
(7, 2, 18, 30);  -- replaced 7, 6