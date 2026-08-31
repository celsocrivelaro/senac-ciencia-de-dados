# Tabelas recursivas com CTE em PostgreSQL

Documentação do WITH: https://www.postgresql.org/docs/current/queries-with.html

Massa de dados para teste:

```sql

-- Objetivo: praticar WITH RECURSIVE para navegar e sumarizar hierarquias.

/* =========================================================
  0) Preparação do ambiente
========================================================= */
DROP TABLE IF EXISTS funcionarios CASCADE;

CREATE TABLE funcionarios (
  id           SERIAL PRIMARY KEY,
  nome         TEXT NOT NULL,
  cargo        TEXT NOT NULL,
  gerente_id   INTEGER REFERENCES funcionarios(id) ON DELETE SET NULL,
  departamento TEXT NOT NULL,
  salario      NUMERIC(10,2) NOT NULL,
  data_admissao DATE NOT NULL
);

-- Dados de exemplo (pequena empresa fictícia)
-- CEO (nível 0)
INSERT INTO funcionarios (id, nome, cargo, gerente_id, departamento, salario, data_admissao) VALUES
(1, 'Ana Souza',       'CEO',            NULL, 'Executivo', 30000.00, '2015-01-10');

-- Diretores (nível 1)
INSERT INTO funcionarios (id, nome, cargo, gerente_id, departamento, salario, data_admissao) VALUES
(2, 'Bruno Lima',      'Diretor',         1,  'Tecnologia', 20000.00, '2016-03-15'),
(3, 'Carla Mendes',    'Diretora',        1,  'Operações',  19500.00, '2016-05-10'),
(4, 'Diego Ribeiro',   'Diretor',         1,  'Vendas',     20500.00, '2017-01-20');

-- Gerentes (nível 2)
INSERT INTO funcionarios (id, nome, cargo, gerente_id, departamento, salario, data_admissao) VALUES
(5, 'Eva Fernandes',   'Gerente',         2,  'Dados',      14000.00, '2018-02-14'),
(6, 'Fábio Costa',     'Gerente',         2,  'Plataforma', 14500.00, '2018-04-01'),
(7, 'Guilherme Alves', 'Gerente',         3,  'Logística',  13800.00, '2018-07-09'),
(8, 'Helena Nunes',    'Gerente',         4,  'Enterprise', 14200.00, '2018-08-22');

-- Líderes / Sêniores (nível 3)
INSERT INTO funcionarios (id, nome, cargo, gerente_id, departamento, salario, data_admissao) VALUES
(9,  'Igor Martins',   'Líder Técnico',   5,  'Dados',      12000.00, '2019-01-05'),
(10, 'Júlia Rocha',    'Líder Técnico',   6,  'Plataforma', 12150.00, '2019-02-10'),
(11, 'Kaio Barros',    'Líder Operações', 7,  'Logística',  11800.00, '2019-03-18'),
(12, 'Luana Prado',    'Líder Vendas',    8,  'Enterprise', 11900.00, '2019-04-25');

-- Analistas / Engenheiros (nível 4)
INSERT INTO funcionarios (id, nome, cargo, gerente_id, departamento, salario, data_admissao) VALUES
(13, 'Marcos Silva',   'Engenheiro Dados', 9,  'Dados',       9500.00,  '2020-01-10'),
(14, 'Natália Pires',  'Analista Dados',   9,  'Dados',       9000.00,  '2020-03-12'),
(15, 'Otávio Cunha',   'Engenheiro DevOps',10, 'Plataforma',  9800.00,  '2020-05-03'),
(16, 'Priscila Reis',  'Engenheira SRE',   10, 'Plataforma',  10200.00, '2020-06-16'),
(17, 'Rafael Tavares', 'Analista Operaç.', 11, 'Logística',   8700.00,  '2020-08-21'),
(18, 'Sofia Teixeira', 'Analista Operaç.', 11, 'Logística',   8600.00,  '2020-09-30'),
(19, 'Tiago Campos',   'Executivo Contas', 12, 'Enterprise',  9300.00,  '2020-11-11'),
(20, 'Úrsula Diniz',   'Executiva Contas', 12, 'Enterprise',  9350.00,  '2020-12-05');

-- Estagiários (nível 5)
INSERT INTO funcionarios (id, nome, cargo, gerente_id, departamento, salario, data_admissao) VALUES
(21, 'Vitor Santos',   'Estagiário',       13, 'Dados',       3000.00, '2021-02-01'),
(22, 'Wesley Moura',   'Estagiário',       15, 'Plataforma',  3000.00, '2021-03-01'),
(23, 'Xênia Queiroz',  'Estagiária',       17, 'Logística',   3000.00, '2021-04-01'),
(24, 'Yara Oliveira',  'Estagiária',       19, 'Enterprise',  3000.00, '2021-05-01');
```

## Exercício 1: Caminho do CEO até cada funcionário

```sql
WITH RECURSIVE hierarquia AS (
  SELECT
    id,
    nome,
    gerente_id,
    nome::TEXT AS caminho,
    0 AS nivel
  FROM funcionarios
  WHERE gerente_id IS NULL  -- CEO(s)

  UNION ALL

  SELECT
    f.id,
    f.nome,
    f.gerente_id,
    h.caminho || ' > ' || f.nome AS caminho,
    h.nivel + 1 AS nivel
  FROM funcionarios f
  JOIN hierarquia h ON f.gerente_id = h.id
)

SELECT id, nome, caminho
FROM hierarquia
ORDER BY id;
```

## Exercício 2: Nível hierárquico por funcionário

Criando CTE que será usado para hierarquia:

```sql
WITH RECURSIVE hierarquia AS (
    SELECT
        f.id        AS funcionario_id,
        f.nome      AS funcionario_nome,
        f.gerente_id AS gerente_id,
        0           AS nivel
    FROM funcionarios f
    WHERE f.gerente_id IS NULL  -- CEO(s): a raiz da árvore, nível 0

    UNION ALL

    -- desce um nível: cada funcionário herda o nível do seu gerente + 1
    SELECT
        f.id,
        f.nome,
        f.gerente_id,
        h.nivel + 1
    FROM funcionarios f
    JOIN hierarquia h ON f.gerente_id = h.funcionario_id
)
```

Busca usando CTE

```sql
SELECT funcionario_id, funcionario_nome, nivel
FROM hierarquia
ORDER BY nivel, funcionario_id;
```

## Exercício 3: Subordinados diretos e indiretos e totais por gerente

CTE adicionais (precisa ser feito em cadeia)

```sql
WITH RECURSIVE hierarquia AS (
    SELECT
        f.id        AS funcionario_id,
        f.nome      AS funcionario_nome,
        f.gerente_id AS gerente_id,
        0           AS nivel
    FROM funcionarios f
    WHERE f.gerente_id IS NOT NULL

    UNION ALL

    SELECT
        h.funcionario_id,
        h.funcionario_nome,
        f.gerente_id,
        h.nivel + 1
    FROM hierarquia h
    JOIN funcionarios f ON f.id = h.gerente_id
    WHERE f.gerente_id IS NOT NULL
),  total_subordinados AS ( -- total: diretos + indiretos (toda a subárvore)
    SELECT
        gerente_id,
        COUNT(*) AS total
    FROM hierarquia
    GROUP BY gerente_id
) , subordinados_diretos AS ( -- apenas os subordinados diretos
    SELECT
        gerente_id,
        COUNT(*) AS diretos
    FROM funcionarios
    WHERE gerente_id IS NOT NULL
  GROUP BY gerente_id
)
```

Busca:

```sql
SELECT
    g.id   AS gerente_id,
    g.nome AS gerente_nome,
    g.cargo,
    g.departamento,

    COALESCE(sd.diretos, 0) AS subordinados_diretos,
    COALESCE(ts.total, 0) - COALESCE(sd.diretos, 0) AS subordinados_indiretos,
    COALESCE(ts.total, 0) AS total_subordinados

FROM funcionarios g
LEFT JOIN subordinados_diretos sd ON sd.gerente_id = g.id
LEFT JOIN total_subordinados ts   ON ts.gerente_id = g.id

-- Opcional: mostrar apenas quem tem subordinados
WHERE COALESCE(ts.total, 0) > 0

ORDER BY total_subordinados DESC, g.nome;
```

## Exercício 4: Soma de salários da árvore (gerente + todos subordinados)

```sql
WITH RECURSIVE arvore AS (
  SELECT id AS raiz, id AS emp
  FROM funcionarios
  UNION ALL
  SELECT a.raiz, f.id
  FROM arvore a
  JOIN funcionarios f ON f.gerente_id = a.emp
),
somas AS (
  SELECT a.raiz, SUM(f.salario) AS soma_salarios
  FROM arvore a
  JOIN funcionarios f ON f.id = a.emp
  GROUP BY a.raiz
)
SELECT f.id AS gerente_id, f.nome, somas.soma_salarios
FROM somas
JOIN funcionarios f ON f.id = somas.raiz
ORDER BY gerente_id;
```

## Exercício 5:  Folhas (sem subordinados)

```sql
SELECT f.id, f.nome, f.cargo
FROM funcionarios f
LEFT JOIN funcionarios s ON s.gerente_id = f.id
WHERE s.id IS NULL
ORDER BY f.id;
```

## Exercício 6: Pares (gerente, subordinado) até distância 2

```sql
WITH RECURSIVE pares AS (
  SELECT
    f.id AS gerente,
    f.id AS emp,
    0 AS dist
  FROM funcionarios f
  UNION ALL
  SELECT
    p.gerente,
    f.id AS emp,
    p.dist + 1 AS dist
  FROM pares p
  JOIN funcionarios f ON f.gerente_id = p.emp
  WHERE p.dist < 2
)
SELECT g.nome AS gerente, e.nome AS subordinado, dist
FROM pares
JOIN funcionarios g ON g.id = pares.gerente
JOIN funcionarios e ON e.id = pares.emp
WHERE pares.dist BETWEEN 1 AND 2
ORDER BY gerente, dist, subordinado;
```

## Exercício 7: Detecção de ciclo básico (se há loops)

A coluna `gerente_id` é uma FK para a própria tabela, e nada impede que os dados
formem um **ciclo**: A gerencia B, que gerencia C, que gerencia A. A hierarquia
deixa de ser uma árvore, e aí toda CTE recursiva dos exercícios anteriores passa
a girar para sempre — cada volta produz linhas novas e a recursão nunca esvazia.

Antes de começar, proteja a sessão com um limite de tempo:

```sql
SET statement_timeout = '5s';
```

### Passo 1: criar um ciclo de propósito

A massa original é acíclica, então não haveria nada a detectar. Vamos fechar um
laço entre Kaio Barros (11) e Rafael Tavares (17), que hoje são gerente e
subordinado — passando o 11 a ser subordinado do 17:

```sql
UPDATE funcionarios SET gerente_id = 17 WHERE id = 11;
```

Agora a consulta do Exercício 4, que era inofensiva, não termina mais: com o
`statement_timeout` acima ela morre em `ERROR: canceling statement due to
statement timeout`. Sem o timeout, ela consumiria memória e disco até o servidor
reclamar.

### Passo 2: detectar o ciclo

A ideia é a mesma do Exercício 1, que já acumulava o caminho percorrido — só que
guardando os ids visitados num **array** em vez de num texto, para poder
perguntar se o id atual já apareceu antes:

```sql
WITH RECURSIVE caminho AS (
  SELECT
    f.id        AS raiz,
    f.id        AS atual,
    ARRAY[f.id] AS visitados,
    false       AS ciclo
  FROM funcionarios f

  UNION ALL

  SELECT
    c.raiz,
    f.id,
    c.visitados || f.id,
    f.id = ANY(c.visitados)   -- este id já apareceu no caminho?
  FROM caminho c
  JOIN funcionarios f ON f.gerente_id = c.atual
  WHERE NOT c.ciclo           -- para de descer assim que o laço fecha
)

SELECT DISTINCT visitados AS ciclo_encontrado
FROM caminho
WHERE ciclo
ORDER BY 1;
```

Resultado:

```
 ciclo_encontrado
------------------
 {11,17,11}
 {17,11,17}
```

O mesmo laço aparece duas vezes porque a busca parte de **cada** funcionário: um
caminho o encontra começando pelo 11, outro começando pelo 17. O id repetido nas
pontas é justamente onde o ciclo se fecha.

Duas linhas fazem essa consulta terminar, e vale entender o papel de cada uma:

- `f.id = ANY(c.visitados)` **marca** a linha em que um id se repete;
- `WHERE NOT c.ciclo` **interrompe** a descida naquele caminho. Sem ele a
  consulta detectaria o ciclo e mesmo assim continuaria girando para sempre.

### Passo 3: desfazer o ciclo

```sql
UPDATE funcionarios SET gerente_id = 7 WHERE id = 11;
```

Rodando a consulta do Passo 2 de novo, o resultado volta a ser `0 rows` — que é
o que se espera de uma hierarquia saudável.

### Alternativa: a cláusula CYCLE (PostgreSQL 14+)

Desde a versão 14 o Postgres faz esse controle sozinho. A cláusula `CYCLE`
declara qual coluna identifica o nó, em qual coluna marcar a detecção e em qual
guardar a trilha — dispensando o array manual e o `WHERE NOT`:

```sql
WITH RECURSIVE caminho AS (
  SELECT f.id AS raiz, f.id AS atual
  FROM funcionarios f

  UNION ALL

  SELECT c.raiz, f.id
  FROM caminho c
  JOIN funcionarios f ON f.gerente_id = c.atual
) CYCLE atual SET eh_ciclo USING trilha

SELECT DISTINCT trilha
FROM caminho
WHERE eh_ciclo;
```

Com o ciclo do Passo 1 ativo, a trilha sai como `{(11),(17),(11)}` — mesma
informação, com os ids em linhas de um tipo composto. Faça o Passo 2 na mão
primeiro: é ele que mostra o que o `CYCLE` está fazendo por baixo.
