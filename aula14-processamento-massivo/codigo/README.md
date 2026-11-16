# Aula 14 — Processamento Massivo: código

| Notebook | Conteúdo |
|---|---|
| `codigo01-bloom-cuco-count-min-top-k.ipynb` | Filtro de Bloom, filtro de cuco, *count-min sketch* e *Space-Saving* implementados por extenso, comparados com `set` e `dict`. |
| `codigo02-hyperloglog-e-minhash.ipynb` | HyperLogLog e MinHash implementados por extenso: erro em função de $p$ e de $k$, fusão de *sketches*. |
| `codigo03-redis.ipynb` | As seis estruturas probabilísticas do Redis (`BF`, `CF`, `CMS`, `TOPK`, `PF`, `TDIGEST`) num banco gratuito do Redis Cloud, comparadas com a resposta exata. |
| `codigo04-mapreduce.ipynb` | MapReduce simulado em Python puro: *map*, embaralhamento, *reduce*, combinador, média por (soma, contagem) e contagem de distintos com HyperLogLog. |

## Execução

Os notebooks rodam no Jupyter do ambiente da disciplina. Dependências:

```bash
pip install numpy matplotlib redis python-dotenv
```

Os notebooks 01, 02 e 04 não dependem de serviço externo.

## Banco do Redis Cloud (notebook 03)

O notebook 03 usa um banco gratuito do Redis Cloud, que já traz os tipos probabilísticos.

1. Criar uma conta em https://cloud.redis.io/ e, no painel, criar um banco no plano gratuito (*Free*), em qualquer região.
2. Na página do banco, em *Connect*, copiar a URL de conexão no formato `redis://default:SENHA@HOST:PORTA` (a senha fica em *Security*, campo *Default user password*).
3. Nesta pasta, copiar o arquivo `.env.example` para `.env` e colar a URL na variável `REDIS_URL`.

O arquivo `.env` contém a senha do banco e não deve ser versionado. O plano gratuito tem limite de memória de alguns megabytes; o notebook usa volumes pequenos e apaga as chaves que cria (prefixo `aula14:`) ao final.
