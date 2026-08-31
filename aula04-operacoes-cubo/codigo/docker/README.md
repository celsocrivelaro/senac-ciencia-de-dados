# Cubo da aula 04 em Postgres + Metabase

Sobe o cubo de vendas da aula num Postgres e o deixa pronto para explorar no
Metabase — sem instalar nada além do Docker.

## Como rodar

```sh
docker compose up
```

A primeira subida demora: o Metabase baixa uns 500 MB e leva mais um ou dois
minutos para migrar o banco interno. Espere a mensagem:

```
======================================================
 Metabase pronto em http://localhost:4445
 Login: estudante@sp.senac.br
 Senha: senac2026
======================================================
```

Aí abra **http://localhost:4445** e entre com esse login. O cubo já aparece
cadastrado como **"Cubo da aula"** — não é preciso passar pelo assistente de
tela nem cadastrar conexão nenhuma.

Para parar:

```sh
docker compose down        # para os containers, preserva os dados
docker compose down -v     # apaga tudo e recomeça do zero na próxima subida
```

## Endereços e credenciais

| | |
|---|---|
| Metabase | http://localhost:4445 — `estudante@sp.senac.br` / `senac2026` |
| Postgres | `localhost:5433` — banco `cubo`, usuário `aluno`, senha `estudante` |

As portas são **5433 e 4445**, e não as 5432 e 4444 de sempre, para não colidir
com o Postgres e o Metabase que a VM da disciplina já roda. Se você subir este
compose dentro da VM, os dois convivem.

## Rodando SQL direto

Pelo psql de dentro do container:

```sh
docker compose exec postgres psql -U aluno -d cubo
```

Ou apontando o DBeaver / SQLTools para `localhost:5433`. As consultas de
[../operacoes-cubo.md](../operacoes-cubo.md) rodam sem alteração — inclusive a
de `crosstab`, porque a extensão `tablefunc` já vem criada.

## O cubo

Schema estrela, o mesmo do material:

| tabela | conteúdo |
|---|---|
| `dim_marcas` | 4 marcas — Naique, Ardida, Pumita, Reeboca |
| `dim_segmentos` | 5 segmentos — Premium, Corrida, Futebol, Casual, Treino |
| `dim_dias` | 30 dias |
| `fato_vendas` | 600 células (4 × 5 × 30) |

**A massa é maior que a do material.** Em `../operacoes-cubo.md` o
`fato_vendas` tem 80 linhas escritas à mão, cobrindo 4 dias — bom para ler, mas
pouco para um gráfico. Aqui são 30 dias, gerados por fórmula em
[init/01-cubo.sql](init/01-cubo.sql). Marcas, segmentos e a força relativa de
cada combinação são as mesmas, então as consultas do material contam a mesma
história: a Ardida domina Corrida e Futebol, a Pumita vai bem em Futebol, e
Casual é o segmento fraco de todas.

## O que sugerimos explorar no Metabase

1. **Browse data → Cubo da aula → Fato Vendas** e veja o cubo cru.
2. Um **Summarize** por `Sum of Quantidade`, agrupando por marca. Depois troque
   o agrupamento para segmento, e depois para dia — é drill-down e roll-up sem
   escrever SQL.
3. Agrupe por **duas** dimensões ao mesmo tempo (marca e segmento) e mude a
   visualização para tabela pivô. É o mesmo resultado da query de `crosstab` do
   material, montado a cliques.
4. Um **filtro** por marca é o SLICE; filtrar marca *e* dia é o DICE.

## Arquivos

| | |
|---|---|
| `docker-compose.yml` | os três serviços |
| `init/01-cubo.sql` | schema e massa; o Postgres executa na primeira subida |
| `metabase-setup.sh` | cria o admin e cadastra o Postgres, pela API do Metabase |

O `metabase-setup` é um container que roda uma vez e sai — é normal vê-lo como
`Exited (0)` no `docker compose ps`. Ele é idempotente: se já rodou antes, não
duplica nada.

## Se algo der errado

**O Metabase não sobe.** Ele pede uns 2 GB de RAM livres. Veja o motivo com
`docker compose logs metabase`.

**"port is already allocated".** Alguma coisa já usa a 5433 ou a 4445. Troque o
lado esquerdo do `ports:` no `docker-compose.yml`.

**Mudei o `init/01-cubo.sql` e nada mudou.** O Postgres só executa o init
quando o volume de dados está vazio. Force com `docker compose down -v`.

**Quero trocar a senha do Metabase.** Vale saber que ele recusa senha "comum" e
exige ao menos um dígito: `senac` e `senac-cubo` são rejeitadas com HTTP 400.
