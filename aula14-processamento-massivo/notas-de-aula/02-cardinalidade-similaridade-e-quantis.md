# Ciência de Dados — Aula 14: Processamento Massivo — Cardinalidade, similaridade e quantis

---

## Objetivos de aprendizagem

Ao final desta nota, espera-se que o aluno seja capaz de:

- Para o HyperLogLog, o MinHash e o *t-digest*, enunciar a pergunta respondida, o problema que motivou a estrutura, quem a usa e o que ela não consegue fazer.
- Explicar a intuição probabilística do HyperLogLog e o papel dos registradores e da média harmônica na estimativa.
- Calcular o erro padrão do HyperLogLog em função do número de registradores e conciliar os números de memória e de erro citados por fontes diferentes.
- Definir a similaridade de Jaccard, demonstrar que a probabilidade de duas assinaturas MinHash coincidirem é igual a ela e calcular o erro do estimador em função do número de assinaturas.
- Explicar por que quantis não se fundem por média e como o *t-digest* concentra a precisão nas caudas.
- Escolher, entre as sete estruturas da aula, a adequada a uma pergunta e a uma decisão, justificando pela direção e pela grandeza do erro.

## Desenvolvimento teórico

A nota sobre pertinência e frequência apresentou o problema — a resposta exata exige memória proporcional ao número de distintos — e as estruturas que respondem se um item está no conjunto e quantas vezes apareceu. Esta nota trata de três perguntas que envolvem o conjunto inteiro: quantos distintos ele tem, quão parecido ele é com outro conjunto e como se distribuem os valores numéricos associados aos seus itens. O caso condutor é o mesmo: listas de números de telefone na ordem de $5 \cdot 10^9$ e o registro de chamadas de uma operadora.

### HyperLogLog

**Pergunta.** Quantos itens distintos há no conjunto — a **cardinalidade**? Em Python, a resposta exata é `len(set(itens))`; o **HyperLogLog** dá a mesma resposta, aproximada, sem guardar os itens.

**Por que existe.** Contar distintos exige lembrar quais itens já foram vistos, e lembrar custa memória proporcional à cardinalidade. Além disso, contagens de distintos **não se somam**: se duas listas têm $4 \cdot 10^9$ e $3 \cdot 10^9$ números distintos, a união tem entre $4 \cdot 10^9$ e $7 \cdot 10^9$, conforme a sobreposição — a soma só é correta para listas disjuntas. Flajolet et al. (2007) propuseram o HyperLogLog como estimador de cardinalidade com memória constante e fusão exata, sucessor de uma linha de algoritmos de contagem probabilística iniciada por Flajolet e Martin nos anos 1980. A variante **HyperLogLog++** (HEULE; NUNKESSER; HALL, 2013), desenvolvida no Google, usa *hash* de 64 bits e corrige o viés do estimador em cardinalidades pequenas.

**Quem usa.**

- BigQuery: a função `APPROX_COUNT_DISTINCT` e a família `HLL_COUNT.*`, que expõe os *sketches* para fusão posterior, implementam o HyperLogLog++.
- Spark: `approx_count_distinct`, também baseada no HyperLogLog++.
- Redis: tipo nativo, com os comandos `PFADD`, `PFCOUNT` e `PFMERGE` (o prefixo homenageia Philippe Flajolet).
- PostgreSQL: extensões que acrescentam o tipo `hll`.
- Casos de uso recorrentes: usuários ativos distintos por dia e por mês (DAU e MAU), visitantes distintos por página, distintos por IP ou por campanha, alcance de campanha de *marketing*, valores distintos de uma coluna para o otimizador de consultas, e toda deduplicação em que só interessa *quantos* são os distintos.

**Intuição probabilística.** Seja $h$ uma função de *hash* que produz bits uniformes e independentes. Metade dos valores de $h(x)$ começa com 1, um quarto com 01, um oitavo com 001: a probabilidade de um valor começar com exatamente $r - 1$ zeros seguidos de um 1 é $2^{-r}$. Num conjunto com $n$ distintos — e só os distintos importam, porque itens repetidos produzem o mesmo *hash* —, o maior prefixo de zeros observado é, em média, da ordem de $\log_2 n$. Observar um valor com $r - 1$ zeros à esquerda sugere, portanto, cerca de $2^r$ distintos.

Uma observação isolada tem variância enorme: um único *hash* que começa com 20 zeros, ocorrido por acaso, faz a estimativa saltar para um milhão. A solução do HyperLogLog é dividir o conjunto em muitos subconjuntos, estimar cada um e combinar as estimativas.

**Mecanismo.**

1. Os primeiros $p$ bits de $h(x)$ escolhem um de $m = 2^p$ **registradores** $M[0], \dots, M[m-1]$, todos inicialmente 0.
2. Nos bits restantes, calcula-se o **posto** $\rho$: a posição do primeiro bit 1, ou seja, o número de zeros à esquerda mais 1.
3. O registrador guarda o maior posto já visto: $M[j] \leftarrow \max(M[j], \rho)$.

```text
p = 4  ->  m = 16 registradores

h(x) = 1011 | 0001 0110 ...
       ----   ----
       j=11   três zeros, depois 1  ->  rho = 4

M[11] = max(M[11], 4)

registradores:  j:  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15
                M:  3  1  4  2  2  5  1  3  2  2  1  4  3  2  6  2
```

A estimativa combina os registradores pela **média harmônica**:

$$E = \alpha_m \, m^2 \left( \sum_{j=0}^{m-1} 2^{-M[j]} \right)^{-1}$$

com $\alpha_m \approx 0{,}7213 / (1 + 1{,}079/m)$, constante que corrige o viés do estimador. Cada registrador estima $2^{M[j]}$ distintos para o seu subconjunto, e $m \cdot$ (média harmônica das estimativas) estima o total. A média harmônica é escolhida porque é dominada pelos valores pequenos e amortece os registradores com valor extremo — exatamente o defeito da observação isolada. Inserção e fusão custam $O(1)$ por registrador.

**Erro.** O erro padrão relativo do estimador é

$$\sigma \approx \frac{1{,}04}{\sqrt{m}}$$

e não depende da cardinalidade: o mesmo *sketch* conta mil ou um bilhão de distintos com o mesmo erro relativo. O erro é **simétrico** — a estimativa pode ficar acima ou abaixo do valor real — e aproximadamente normal: cerca de 68% das estimativas ficam a menos de $\sigma$ do valor real, 95% a menos de $2\sigma$ e 99,7% a menos de $3\sigma$.

As fontes desta aula citam três números diferentes para o HyperLogLog, todos obtidos pela mesma fórmula:

| Fonte | Registradores $m$ | Bits por registrador | Memória | Erro padrão $1{,}04/\sqrt{m}$ |
|---|---|---|---|---|
| Artigo original (FLAJOLET et al., 2007) | 2.048 | 5 | 1,28 KB | 2,3% |
| Redis | 16.384 | 6 | 12 KB | 0,81% |
| Zhiyanov (2026) | 16.384 | 8 | 16 KB | 0,81% |

O artigo original anuncia cardinalidades acima de $10^9$ com erro de cerca de 2% em 1,5 KB, e é esse o número que circula em apresentações; as implementações atuais usam $p = 14$. O tamanho do registrador muda a memória, e não o erro: 5 bits bastam para postos até 31, suficientes para *hash* de 32 bits; com *hash* de 64 bits, o posto pode passar de 31 e o Redis usa 6 bits; um byte por registrador simplifica o código ao custo de um terço a mais de memória.

No caso condutor, $5 \cdot 10^9$ números distintos são contados em 12 KB com erro padrão de 0,81% — cerca de $4 \cdot 10^7$ números —, contra mais de 40 GB do conjunto exato.

**Fusão.** Dois *sketches* com o mesmo $m$ e a mesma função de *hash* se fundem pelo máximo, registrador a registrador:

$$M_{A \cup B}[j] = \max(M_A[j], M_B[j])$$

A fusão é **exata**: o *sketch* resultante é idêntico ao que seria obtido inserindo os itens de $A \cup B$ diretamente, porque o máximo de cada registrador sobre a união é o máximo dos máximos. Essa é a propriedade que a contagem exata de distintos não tem, e que torna o HyperLogLog útil em consultas como "visitantes distintos da semana" a partir dos *sketches* diários.

**Limites.**

- Não responde pertinência, não remove e não lista itens.
- Em cardinalidades pequenas, muito abaixo de $m$, a maioria dos registradores é 0 e o estimador tem viés; o artigo original troca de fórmula abaixo de $\frac{5}{2}m$ e usa a **contagem linear** $m \ln(m/V)$, com $V$ o número de registradores zerados, o que produz um salto no erro na fronteira. O HyperLogLog++ usa tabelas de correção de viés e uma representação esparsa para cardinalidades pequenas; o estimador de Ertl (2017) trabalha com o histograma dos valores dos registradores e dispensa a troca de fórmula.
- A interseção pode ser estimada por inclusão e exclusão, $|A \cap B| = |A| + |B| - |A \cup B|$, mas o erro absoluto é o das três estimativas e fica grande quando a interseção é pequena em relação aos conjuntos.

**No Redis.**

```text
PFADD   numeros:sp "+5511912345678" "+5511900000001"
PFADD   numeros:rj "+5521988887777" "+5511912345678"
PFCOUNT numeros:sp
PFMERGE numeros:brasil numeros:sp numeros:rj
PFCOUNT numeros:brasil
```

O HyperLogLog é tipo nativo do Redis, sem parâmetro de criação: todo *sketch* tem $m = 16.384$ registradores. `PFADD` devolve 1 quando algum registrador mudou.

**No caso condutor.** Números distintos ativos por estado, com um *sketch* por estado, e do país inteiro pela fusão dos *sketches* estaduais; distintos do mês pela fusão dos *sketches* diários. A soma das contagens estaduais superestimaria o total, porque números com chamadas em mais de um estado seriam contados várias vezes.

### MinHash

**Pergunta.** Quão parecidos são dois conjuntos? A medida usual é a **similaridade de Jaccard**:

$$J(A, B) = \frac{|A \cap B|}{|A \cup B|}$$

que vale 1 para conjuntos iguais, 0 para conjuntos disjuntos e não depende do tamanho absoluto dos conjuntos.

**Igualdade e similaridade.** A pergunta "as duas listas de telefones são iguais?" admite duas leituras. A **igualdade exata** se verifica com um *hash* de cada conjunto — por exemplo, o *hash* da lista ordenada, ou a soma dos *hashes* dos itens módulo $2^{64}$, que independe da ordem —, de tamanho constante; mas a resposta é binária, e dois números diferentes em $5 \cdot 10^9$ já tornam as listas "diferentes". A pergunta útil, na prática, é a de **similaridade**: que fração das listas é comum. O cálculo exato de $J$ exige os dois conjuntos inteiros na mesma máquina.

**Por que existe.** Broder (1997) propôs o **MinHash** para detectar documentos quase duplicados no índice do AltaVista: cada documento era representado pelo conjunto das suas sequências de palavras consecutivas (*shingles*), e comparar milhões de documentos par a par, pelos conjuntos inteiros, era inviável.

**Quem usa.** Deduplicação de documentos e de páginas *web*, deduplicação de registros em cadastros, sistemas de recomendação (usuários com conjuntos parecidos de itens consumidos), agrupamento (*clustering*) de documentos e de usuários, detecção de plágio. Combinado com o ***locality-sensitive hashing*** (LSH), encontra os pares parecidos numa coleção sem comparar todos contra todos (LESKOVEC; RAJARAMAN; ULLMAN, 2020, cap. 3). O Spark oferece `MinHashLSH` na biblioteca de aprendizado de máquina.

**Mecanismo.** Para uma função de *hash* $h$, a **assinatura MinHash** de um conjunto é o menor valor de $h$ sobre os seus itens:

$$\text{mh}_h(A) = \min_{x \in A} h(x)$$

A propriedade central é

$$\Pr\left[\text{mh}_h(A) = \text{mh}_h(B)\right] = J(A, B)$$

**Demonstração.** Considera-se o item $x^*$ de menor *hash* em $A \cup B$. Como $h$ se comporta como uma permutação aleatória dos itens, cada item da união tem a mesma probabilidade de ser $x^*$. As assinaturas de $A$ e de $B$ coincidem se e somente se $x^*$ pertence aos dois conjuntos: se $x^* \in A \cap B$, ele é o mínimo de ambos; se pertence a só um deles, o outro tem mínimo diferente. Logo a probabilidade é $|A \cap B| / |A \cup B|$. $\square$

Uma assinatura só dá uma variável de Bernoulli com probabilidade $J$. Com $k$ funções de *hash* independentes, o conjunto é representado por um vetor de $k$ assinaturas, e a fração de posições coincidentes estima $J$:

$$\hat{J} = \frac{1}{k} \sum_{i=1}^{k} \mathbb{1}\left[\text{mh}_{h_i}(A) = \text{mh}_{h_i}(B)\right]$$

```text
k = 6 funções de hash

             h1    h2    h3    h4    h5    h6
assin(A):    12    97     4    33    51     8
assin(B):    12    40     4    33    77     8
             ==          ==    ==          ==

coincidências: 4 de 6  ->  J estimado = 0,67
```

**Erro.** $\hat{J}$ é a média de $k$ variáveis de Bernoulli com probabilidade $J$, sem viés, com erro padrão

$$\sigma_{\hat{J}} = \sqrt{\frac{J(1 - J)}{k}} \le \frac{1}{2\sqrt{k}}$$

Com $k = 200$, o erro padrão é de no máximo 3,5 pontos percentuais, e o vetor de assinaturas ocupa $200 \times 8$ B = 1,6 KB por conjunto, qualquer que seja o tamanho do conjunto (estimativa). O erro é **absoluto** e simétrico: estimar $J = 0{,}9$ com erro de 0,035 é preciso; estimar $J = 0{,}01$ com o mesmo erro, não.

**Fusão.** A assinatura da união é o mínimo, posição a posição, das assinaturas: $\text{mh}_h(A \cup B) = \min(\text{mh}_h(A), \text{mh}_h(B))$. Como no HyperLogLog, a fusão é exata.

**LSH sobre MinHash.** Para encontrar pares com $J$ alto numa coleção de $N$ conjuntos, sem as $N^2/2$ comparações, o vetor de $k = b \cdot r$ assinaturas é dividido em $b$ faixas de $r$ assinaturas. Dois conjuntos viram **candidatos** se coincidem em todas as $r$ assinaturas de pelo menos uma faixa, e só os candidatos são comparados. A probabilidade de um par com similaridade $s$ virar candidato é

$$P(s) = 1 - (1 - s^r)^b$$

uma curva em S cujo limiar fica perto de $(1/b)^{1/r}$. Com $k = 100$ assinaturas em $b = 20$ faixas de $r = 5$, o limiar fica perto de $0{,}55$: pares com $s = 0{,}8$ viram candidatos com probabilidade 0,9996, e pares com $s = 0{,}3$, com probabilidade 0,047 (LESKOVEC; RAJARAMAN; ULLMAN, 2020, cap. 3).

**Limites.** O MinHash estima a similaridade, e não a interseção nem a diferença; não lista os itens em comum nem os exclusivos; o erro absoluto torna imprecisa a estimativa de similaridades pequenas. O Redis não oferece o MinHash como tipo de dado, e o exemplo da aula usa a implementação em Python.

**No caso condutor.** Duas empresas querem saber quanto suas bases de clientes se sobrepõem sem trocar as bases, que são dado pessoal; duas operadoras querem comparar suas listas de bloqueio. Cada lado calcula o vetor de 200 assinaturas com as mesmas funções de *hash* e troca 1,6 KB, em vez de listas de bilhões de números.

### *t-digest*

**Pergunta.** Qual o valor de um quantil — a mediana, o percentil 99 (p99) — num fluxo de valores numéricos? E, no sentido inverso, que fração dos valores está abaixo de um limiar (a **função de distribuição acumulada**, ou CDF)?

**Por que existe.** O quantil exato exige guardar e ordenar todos os valores: o p99 de $10^6$ valores de 64 bits exige 8 MB. Além disso, quantis **não se fundem por média**: o p99 da união de dois servidores não é a média dos p99 de cada um, nem pode ser calculado a partir deles. Em sistemas distribuídos, em que cada servidor resume a sua parte, essa é a restrição decisiva. Dunning e Ertl (2019) propuseram o ***t-digest*** como resumo de tamanho fixo, fundível e mais preciso nas caudas da distribuição.

**Quem usa.** Percentis de latência em sistemas de monitoramento, acordos de nível de serviço (*SLA*) e objetivos de nível de serviço (*SLO*) expressos em p95 e p99, tempos de espera em filas, distribuição de valores financeiros, limiares de anomalia em dados de sensores, detecção de anomalia por mudança na distribuição. A agregação `percentiles` do Elasticsearch usa o *t-digest*; o Redis oferece o tipo com os comandos `TDIGEST.*`.

**Mecanismo.** O *t-digest* é uma lista ordenada de **centróides**, cada um com uma média e um peso (o número de valores que ele resume). O quantil $q$ é obtido percorrendo os centróides em ordem, acumulando os pesos até a posição $q \cdot N$ e interpolando entre as médias dos centróides vizinhos.

O tamanho máximo de cada centróide é controlado por uma **função de escala**. A usada pelo artigo de referência é

$$k(q) = \frac{\delta}{2\pi} \arcsin(2q - 1)$$

que mapeia o quantil $q \in [0, 1]$ no intervalo $[-\delta/4, \delta/4]$; cada centróide pode cobrir no máximo uma unidade de $k$: $k(q_2) - k(q_1) \le 1$. A derivada do arco-seno é pequena no meio e cresce sem limite nas extremidades, e por isso a mesma unidade de $k$ corresponde a uma faixa larga de quantis perto da mediana e a uma faixa estreita perto de 0 e de 1. Os centróides são grandes no meio da distribuição e pequenos nas caudas.

```text
distribuição dos valores
                         ___
                      __/   \__
                   __/         \__
              ____/               \____
quantil:  0     0,25     0,5     0,75     1

centróides (largura = número de valores resumidos):
  |.|..|....|..........|..........|....|..|.|
  pequenos      grandes no meio       pequenos
  nas caudas                          nas caudas
```

Com $10^6$ valores e $\delta = 100$, um centróide perto da mediana resume cerca de 27.000 valores, perto do p99 cerca de 5.000 e nas extremidades cerca de 500 (ZHIYANOV, 2026).

**Consequência.** O erro, medido em **posto** — a diferença entre o quantil pedido e o quantil verdadeiro do valor devolvido —, é menor nas caudas. É o oposto do que fazem as estimativas por amostragem ou por histograma de faixas fixas, que distribuem a precisão uniformemente, e é a propriedade adequada a latência, em que interessam p99 e p999, e não a mediana. O mínimo e o máximo são guardados exatamente.

**Dimensionamento.** O parâmetro de compressão $\delta$ limita o número de centróides a cerca de $\delta$; com $\delta = 100$, a estrutura ocupa cerca de 8 KB. O artigo de referência estima o p99 de $10^6$ valores entre os percentis 98,97 e 99,03 — erro de posto de 0,03% — com 8 KB, contra 8 MB do cálculo exato (ZHIYANOV, 2026). Aumentar $\delta$ reduz o erro e aumenta a memória linearmente.

**Fusão.** Dois *t-digests* se fundem concatenando as listas de centróides, ordenando por média e comprimindo de novo sob a mesma função de escala. A fusão não é exata como a do HyperLogLog, mas preserva a garantia de erro de forma aproximada, o que basta para agregar servidores e janelas de tempo.

**Limites.** Não remove valores, não lista os valores individuais e não tem garantia de erro unilateral; o erro depende da distribuição dos dados e da ordem de chegada.

**Ligação com séries temporais.** O percentil por janela de tempo, impraticável em SQL exato sobre bilhões de linhas, é um *t-digest* por janela; a reamostragem (*downsampling*) de percentis, que não pode ser feita tirando a média dos percentis de cada minuto, é feita fundindo os *t-digests* de cada minuto.

**No Redis.**

```text
TDIGEST.CREATE   duracao COMPRESSION 100
TDIGEST.ADD      duracao 35.2 128.0 61.7 4.1
TDIGEST.QUANTILE duracao 0.5 0.99
TDIGEST.CDF      duracao 300
TDIGEST.MIN      duracao
TDIGEST.MAX      duracao
TDIGEST.MERGE    duracao_total 2 duracao_sp duracao_rj
```

**No caso condutor.** O p99 da duração das chamadas por hora, por central de comutação, e o do país pela fusão dos *t-digests* das centrais; a fração de chamadas com menos de 5 segundos, sinal típico de discagem automática, pela CDF.

### Quadro de escolha

O quadro reúne as sete estruturas da aula — as quatro da nota sobre pertinência e frequência e as três desta nota.

| Estrutura | Pergunta | Erro | Memória no caso condutor | Remoção | Fusão | Redis |
|---|---|---|---|---|---|---|
| Filtro de Bloom | o item está no conjunto? | só falso positivo, taxa $p$ | 6 GB para $5 \cdot 10^9$ a 1% | não | OU bit a bit | `BF.*` |
| Filtro de cuco | idem, com remoção | só falso positivo, $\approx 2b/2^f$ | 7,9 GB para $5 \cdot 10^9$ a 0,2% | sim | não usual | `CF.*` |
| *Count-min* | quantas vezes o item apareceu? | só superestimação, até $\varepsilon N$ com prob. $1 - \delta$ | 54 MB para $\varepsilon = 10^{-6}$ | não | soma célula a célula | `CMS.*` |
| *Top-k* | quais os $k$ mais frequentes? | contagem aproximada; garante os acima de $N/k$ (*Space-Saving*) | proporcional a $k$ | não | aproximada | `TOPK.*` |
| HyperLogLog | quantos distintos? | simétrico, $1{,}04/\sqrt{m}$ | 12 KB, 0,81% | não | máximo por registrador, exata | `PF*` |
| MinHash | quão parecidos são dois conjuntos? | simétrico, $\le 1/(2\sqrt{k})$ absoluto | 1,6 KB por conjunto, $k = 200$ | não | mínimo por posição, exata | — |
| *t-digest* | qual o quantil $q$? | em posto, menor nas caudas | 8 KB, $\delta = 100$ | não | concatenação e compressão | `TDIGEST.*` |

O critério de escolha é a **decisão que a resposta alimenta**, e não só a pergunta:

- se a resposta "não está" precisa ser certa e um falso positivo custa apenas uma verificação na fonte exata, o filtro de Bloom serve;
- se o conjunto muda e itens saem dele, o filtro de cuco substitui o de Bloom;
- se a decisão é tomada sobre itens frequentes — bloquear, alertar, priorizar —, o *count-min* serve, e a superestimação deve levar a verificação, e não a ação irreversível;
- se é preciso listar os frequentes sem conhecê-los, o *top-k*;
- se a decisão depende de uma contagem agregada, como dimensionamento de rede ou planejamento de campanha, um erro de 1% na contagem de distintos não muda a decisão, e o HyperLogLog serve;
- se os dados de cada lado não podem ser trocados, ou são grandes demais para trocar, o MinHash compara conjuntos por assinaturas;
- se a decisão é sobre caudas de distribuição, como um acordo de nível de serviço em p99, o *t-digest*.

## Exemplos

### HyperLogLog em Python, por extenso

```python
import hashlib

p = 14
m = 2 ** p
registradores = [0] * m

def inserir(item):
    h = int.from_bytes(hashlib.blake2b(item.encode(), digest_size=8).digest(), "big")
    j = h >> (64 - p)                         # p primeiros bits: registrador
    resto = h & ((1 << (64 - p)) - 1)         # 64 - p bits restantes
    rho = (64 - p) - resto.bit_length() + 1   # zeros à esquerda + 1
    if rho > registradores[j]:
        registradores[j] = rho

def estimar():
    alfa = 0.7213 / (1 + 1.079 / m)
    soma = 0.0
    for valor in registradores:
        soma = soma + 2.0 ** (-valor)
    return alfa * m * m / soma
```

O notebook `codigo/codigo02-hyperloglog-e-minhash.ipynb` completa o exemplo com a correção por contagem linear, mede o erro em função de $p$ contra `len(set(...))`, verifica a fusão e implementa o MinHash com o erro em função de $k$. O *t-digest* é demonstrado no Redis, em `codigo/codigo03-redis.ipynb`, contra `numpy.percentile`.

## Fontes e leituras

- AGARWAL, P. K. et al. Mergeable summaries. *ACM Transactions on Database Systems*, v. 38, n. 4, art. 26, 2013.
- BRODER, A. Z. On the resemblance and containment of documents. In: *Compression and Complexity of Sequences*. Salerno: IEEE, 1997. p. 21–29.
- DUNNING, T.; ERTL, O. Computing extremely accurate quantiles using t-digests. arXiv:1902.04023, 2019.
- ERTL, O. New cardinality estimation algorithms for HyperLogLog sketches. arXiv:1702.01284, 2017.
- FLAJOLET, P.; FUSY, É.; GANDOUET, O.; MEUNIER, F. HyperLogLog: the analysis of a near-optimal cardinality estimation algorithm. In: *Conference on Analysis of Algorithms (AofA)*. Discrete Mathematics and Theoretical Computer Science Proceedings, 2007. p. 127–146.
- HEULE, S.; NUNKESSER, M.; HALL, A. HyperLogLog in practice: algorithmic engineering of a state of the art cardinality estimation algorithm. In: *Proceedings of the 16th International Conference on Extending Database Technology (EDBT)*, 2013. p. 683–692.
- LESKOVEC, J.; RAJARAMAN, A.; ULLMAN, J. D. *Mining of Massive Datasets*. 3. ed. Cambridge: Cambridge University Press, 2020. Cap. 3: Finding similar items.
- REDIS. HyperLogLog. Disponível em: https://redis.io/docs/latest/develop/data-types/probabilistic/hyperloglogs/. Acesso em: 14 nov. 2026.
- REDIS. t-digest. Disponível em: https://redis.io/docs/latest/develop/data-types/probabilistic/t-digest/. Acesso em: 14 nov. 2026.
- ZHIYANOV, A. Probabilistic data structures in Go. 13 nov. 2026. Disponível em: https://antonz.org/probabilistic-data-structures/. Acesso em: 14 nov. 2026.
- Material complementar: os artigos originais de cada estrutura estão na pasta `material-complementar/` da aula.
