# Aula 14 — Estruturas Probabilísticas: código

Um notebook por estrutura probabilística do Redis, todos sobre o mesmo registro de chamadas sintético, gerado no próprio notebook:

| Notebook | Estrutura | Pergunta |
|---|---|---|
| `codigo01-redis-bloom.ipynb` | filtro de Bloom (`BF.*`) | o número está na lista de bloqueio? |
| `codigo02-redis-cuco.ipynb` | filtro de cuco (`CF.*`) | idem, numa lista da qual números saem |
| `codigo03-redis-count-min.ipynb` | *count-min sketch* (`CMS.*`) | quantas chamadas originou cada número? |
| `codigo04-redis-top-k.ipynb` | *top-k* (`TOPK.*`) | quais números mais originaram chamadas? |
| `codigo05-redis-hyperloglog.ipynb` | HyperLogLog (`PF*`) | quantos números distintos originaram chamadas? |
| `codigo06-redis-t-digest.ipynb` | *t-digest* (`TDIGEST.*`) | qual o p99 da duração das chamadas? |

## Execução no Google Colab

Os notebooks rodam no Google Colab (ou em qualquer Jupyter). A primeira célula de código instala o cliente `redis` do Python; `numpy` já vem no Colab.

## Banco do Redis Cloud

Os notebooks usam um banco gratuito do Redis Cloud, que já traz os tipos probabilísticos.

1. Criar uma conta em https://cloud.redis.io/ e, no painel, criar um banco no plano gratuito (*Free*), em qualquer região.
2. Na página do banco, em *Connect*, copiar a URL de conexão no formato `redis://default:SENHA@HOST:PORTA` (a senha fica em *Security*, campo *Default user password*).
3. Em cada notebook, colar a URL no lugar do valor de exemplo de `REDIS_URL`, na célula de conexão.

A URL contém a senha do banco: não publique o notebook com ela preenchida. O plano gratuito tem limite de memória de alguns megabytes; cada notebook usa volumes pequenos e apaga ao final as chaves que criou (prefixo `aula14:`).
