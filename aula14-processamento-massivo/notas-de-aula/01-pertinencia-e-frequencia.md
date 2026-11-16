# Ciência de Dados — Aula 14: Processamento Massivo — Estruturas probabilísticas de pertinência e frequência

---

## Objetivos de aprendizagem

Ao final desta nota, espera-se que o aluno seja capaz de:

- Explicar por que a resposta exata a perguntas de pertinência, contagem e frequência sobre um conjunto muito grande exige memória proporcional ao número de itens distintos.
- Definir estrutura de dados probabilística e identificar, em cada estrutura, a troca entre memória, erro e operações perdidas.
- Para o filtro de Bloom, o filtro de cuco, o *count-min sketch* e o *top-k sketch*, enunciar a pergunta respondida, o problema que motivou a estrutura, quem a usa e o que ela não consegue fazer.
- Descrever o mecanismo de cada uma dessas estruturas e dimensioná-la pelas fórmulas de erro e de memória.
- Distinguir o erro unilateral do filtro de Bloom (só falso positivo) e do *count-min* (só superestimação) e relacioná-lo à decisão que a resposta alimenta.
- Usar os comandos do Redis correspondentes (`BF.*`, `CF.*`, `CMS.*`, `TOPK.*`) escolhendo os parâmetros de criação a partir do erro tolerado.

## Desenvolvimento teórico

### O problema: resposta exata contra memória

O caso que atravessa esta aula é o de listas de números de telefone em escala nacional e mundial. Um número no padrão E.123 tem no máximo 15 dígitos e, portanto, cabe num inteiro de 64 bits ($10^{15} < 2^{50}$). Uma lista mundial tem a ordem de $5 \cdot 10^9$ números, e o registro de chamadas de uma grande operadora — número de origem, número de destino, instante, duração — tem a ordem de $10^9$ linhas por dia (estimativa). Sobre esses dados, quatro perguntas se repetem:

| Pergunta | Estrutura exata | Memória exata para $5 \cdot 10^9$ números |
|---|---|---|
| O telefone está na lista? | conjunto (*set*) | $5 \cdot 10^9 \times 8$ B = 40 GB só de chaves |
| Qual o tamanho do conjunto? | conjunto e sua cardinalidade | idem |
| As listas de duas empresas são iguais? | os dois conjuntos, interseção e união | o dobro |
| Quantas vezes um telefone apareceu? | mapa de contadores | 40 GB + 4 a 8 B por chave |

Os valores da tabela são estimativa de ordem de grandeza e ignoram a sobrecarga da tabela *hash* — em Python, um `set` de inteiros ocupa várias vezes o tamanho das chaves. O artigo de Zhiyanov (2026) mede cerca de 64 MB para um conjunto de $10^6$ chaves de 8 bytes, o que extrapola para centenas de gigabytes na escala do caso. A resposta exata, nessa escala, deixa de caber na memória de uma máquina, e a memória é o recurso que limita a resposta antes do tempo de processamento.

O modelo formal desse cenário é o de **fluxo de dados** (*data stream*): os itens $x_1, x_2, \dots, x_N$ chegam um de cada vez, em ordem arbitrária, cada um é visto uma única vez e o algoritmo mantém um estado de memória **sublinear** em $N$ e no número de distintos $n$ — idealmente $O(\text{polylog}\, N)$ ou constante (LESKOVEC; RAJARAMAN; ULLMAN, 2020, cap. 4). Para as perguntas da tabela, há resultados de limite inferior: responder exatamente quantos distintos há num fluxo exige $\Omega(n)$ bits. A saída é relaxar a exigência de exatidão.

Define-se **estrutura de dados probabilística** (ou ***sketch***) como a estrutura que responde a uma pergunta sobre um conjunto com **erro limitado e conhecido**, usando memória que depende do erro tolerado, e não do número de itens. Três elementos são comuns a todas as estruturas desta aula:

1. **funções de *hash* como fonte de aleatoriedade**: uma boa função de *hash* distribui as chaves de modo aproximadamente uniforme e independente, e é essa uniformidade que permite calcular a probabilidade de erro;
2. **a troca memória × erro × operações**: cada estrutura ganha memória ao perder exatidão e, em geral, também alguma operação — remoção, enumeração dos itens, contagem exata;
3. **parâmetros derivados do erro**: o dimensionamento parte do erro aceitável e devolve a memória, e não o contrário.

Esta nota trata das perguntas de **pertinência** (filtro de Bloom e filtro de cuco) e de **frequência** (*count-min sketch* e *top-k sketch*). A cardinalidade, a similaridade e os quantis são tratados na nota sobre cardinalidade, similaridade e quantis.

### Filtro de Bloom

**Pergunta.** O item pertence ao conjunto? O **filtro de Bloom** (*Bloom filter*) responde com uma de duas respostas: "certamente não" ou "provavelmente sim".

**Por que existe.** Bloom (1970) propôs a estrutura para um problema de hifenização: a maior parte das palavras era hifenizada por regra, e só uma minoria exigia consulta a um dicionário em disco. Um teste em memória que descartasse com certeza as palavras fora do dicionário evitava a maioria dos acessos ao disco, e um pequeno número de acessos desnecessários era tolerável. O padrão se repete em todo uso atual: o filtro existe para **evitar uma operação cara** — leitura em disco, chamada de rede, consulta a um serviço — quando o item não está lá.

**Quem usa.**

- Bancos de dados baseados em árvore LSM (*log-structured merge tree*) — Cassandra, HBase, RocksDB — guardam os dados em arquivos imutáveis ordenados e mantêm um filtro de Bloom por arquivo; a leitura de uma chave consulta o filtro de cada arquivo e só lê do disco os arquivos que podem conter a chave.
- O PostgreSQL distribui a extensão `bloom`, um método de acesso de índice baseado no filtro, útil para consultas de igualdade sobre combinações arbitrárias de muitas colunas.
- O Redis oferece o filtro como tipo de dado (comandos `BF.*`).
- Casos de uso recorrentes: deduplicação de URLs em ETL e em *crawlers* (a URL já foi visitada?), pré-filtro de *cache*, detecção de reenvio (*replay*) de *tokens* e *nonces*, deduplicação de eventos de IoT.

**Mecanismo.** O filtro é um vetor de $m$ bits, todos inicialmente 0, e $k$ funções de *hash* $h_1, \dots, h_k$, cada uma com imagem em $\{0, \dots, m-1\}$.

- **Inserção** de $x$: ligam-se os bits $h_1(x), \dots, h_k(x)$.
- **Consulta** de $x$: se algum dos bits $h_i(x)$ for 0, o item certamente nunca foi inserido, porque a inserção o teria ligado; se todos forem 1, o item provavelmente foi inserido — os bits podem ter sido ligados por outros itens.

```text
m = 16 bits, k = 3

inserir "A": h1=1  h2=6  h3=11
inserir "B": h1=4  h2=6  h3=14

posição: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
bits:    0 1 0 0 1 0 1 0 0 0 0  1  0  0  1  0
           A     B   AB         A        B

consultar "C": h1=1  h2=4  h3=14  -> 1,1,1 -> "provavelmente sim"
               (falso positivo: os bits foram ligados por A e B)
consultar "D": h1=2  h2=6  h3=11  -> 0,... -> "certamente não"
```

As duas operações custam $O(k)$ e independem do número de itens inseridos. Na prática, as $k$ funções são derivadas de duas por **hash duplo**, $h_i(x) = h_a(x) + i \cdot h_b(x) \bmod m$, sem perda mensurável de qualidade.

**Dimensionamento.** Com $n$ itens inseridos, a probabilidade de um bit específico continuar 0 é $(1 - 1/m)^{kn} \approx e^{-kn/m}$. Um falso positivo exige os $k$ bits da consulta ligados:

$$p \approx \left(1 - e^{-kn/m}\right)^k$$

Para $m$ e $n$ dados, $p$ é mínimo em $k = (m/n) \ln 2$, valor em que metade dos bits fica ligada. Substituindo, obtém-se o tamanho necessário para uma taxa de falso positivo $p$:

$$m = -\frac{n \ln p}{(\ln 2)^2}, \qquad \frac{m}{n} \approx 1{,}44 \log_2(1/p) \text{ bits por item}$$

| Taxa de falso positivo $p$ | Bits por item $m/n$ | $k$ ótimo |
|---|---|---|
| 10% | 4,8 | 3 |
| 1% | 9,6 | 7 |
| 0,1% | 14,4 | 10 |
| 0,01% | 19,2 | 13 |

Cada redução de dez vezes em $p$ custa cerca de 4,8 bits por item, e o tamanho do item não entra na conta: uma URL de 200 bytes e um inteiro de 8 bytes ocupam o mesmo espaço no filtro. No caso condutor, $5 \cdot 10^9$ números a 1% ocupam $9{,}6 \times 5 \cdot 10^9 / 8 \approx 6$ GB, contra mais de 40 GB do conjunto (estimativa). O artigo de referência mede 1,24 MB para $10^6$ itens a 1%, contra cerca de 64 MB do conjunto (ZHIYANOV, 2026).

**Erro unilateral.** O filtro não tem falso negativo: um item inserido sempre responde "provavelmente sim". O erro está todo do lado do falso positivo. A distinção tem a mesma estrutura dos erros tipo I e tipo II do teste de hipótese: o filtro é um teste com probabilidade de erro tipo II igual a zero e probabilidade de erro tipo I igual a $p$, escolhida no dimensionamento. Por isso o uso correto é aquele em que a resposta "certamente não" economiza a operação cara e a resposta "provavelmente sim" leva à verificação na fonte exata.

**Limites.**

- **Sem remoção**: desligar os bits de um item apagaria bits compartilhados com outros itens e criaria falsos negativos. O **filtro de Bloom com contadores** (*counting Bloom filter*) troca cada bit por um contador de 4 bits e permite a remoção, ao custo de quatro vezes a memória.
- **Sem enumeração**: não há como listar os itens inseridos nem contá-los com exatidão.
- **Capacidade fixa**: com mais itens que os $n$ dimensionados, a fração de bits ligados cresce e $p$ sobe rapidamente; o filtro precisa ser recriado maior, ou empilhado em camadas (o Redis cria subfiltros automaticamente quando a capacidade se esgota, se configurado para isso).
- **Localidade de memória**: os $k$ bits caem em posições arbitrárias do vetor e cada consulta toca até $k$ linhas de *cache*. O **filtro de Bloom bloqueado** (PUTZE; SANDERS; SINGLER, 2009) divide o vetor em blocos do tamanho de uma linha de *cache* (512 bits), usa parte do *hash* para escolher o bloco e o restante para os $k$ bits dentro dele, e paga cerca de 3% a mais de memória a 1% de falso positivo (ZHIYANOV, 2026) em troca de um único acesso à memória por operação.

**No Redis.**

```text
BF.RESERVE bloqueio 0.01 10000000      # taxa de erro 1%, capacidade 10^7
BF.ADD     bloqueio "+5511912345678"   # 1 = inserido
BF.MADD    bloqueio "+5511900000001" "+5521988887777"
BF.EXISTS  bloqueio "+5511912345678"   # 1 = provavelmente presente
BF.EXISTS  bloqueio "+5531977776666"   # 0 = certamente ausente
```

O `BF.RESERVE` recebe exatamente os dois parâmetros do dimensionamento — $p$ e $n$ — e calcula $m$ e $k$. A saída real desses comandos está no notebook `codigo/codigo03-redis.ipynb`.

**No caso condutor.** Antes de completar uma chamada de telemarketing, a central consulta a lista nacional de números que não aceitam esse tipo de ligação. Um filtro de Bloom dessa lista, em memória na central, responde "certamente não está" para a maioria das chamadas, que seguem sem consulta ao cadastro; só as respostas "provavelmente sim" consultam o cadastro, e o falso positivo custa uma consulta desnecessária, e não uma chamada indevida.

### Filtro de cuco

**Pergunta.** A mesma do filtro de Bloom — o item pertence ao conjunto? —, com uma operação a mais: **remover** um item.

**Por que existe.** O filtro de Bloom não remove, porque um bit é compartilhado por vários itens, e o filtro com contadores remove ao custo de quatro vezes a memória. Listas que mudam com frequência obrigavam a escolher entre reconstruir o filtro periodicamente e pagar a memória dos contadores. Fan et al. (2014) propuseram o **filtro de cuco** (*cuckoo filter*) como substituto com remoção e mostraram que, para taxas de falso positivo abaixo de cerca de 3%, ele ocupa menos memória por item que o filtro de Bloom.

**Quem usa.** Listas dinâmicas de bloqueio de IPs e de usuários, filtros de *cache* adaptativos, controle de *spam* e de abuso com exclusões frequentes. O Redis oferece o filtro como tipo de dado (comandos `CF.*`).

**Mecanismo.** O filtro é uma tabela de baldes, cada balde com $b$ posições (tipicamente $b = 4$). Cada posição guarda uma **impressão digital** (*fingerprint*) de $f$ bits do item — alguns bits do seu *hash* —, e não o item. Cada item tem dois baldes candidatos:

$$i_1 = h(x), \qquad i_2 = i_1 \oplus h(\text{fp}(x))$$

O segundo balde é calculável a partir do primeiro e da impressão digital, sem o item original, e a operação é simétrica: $i_1 = i_2 \oplus h(\text{fp}(x))$. Essa variante é o ***hashing* cuco de chave parcial** (*partial-key cuckoo hashing*).

- **Inserção**: se um dos dois baldes tem posição livre, a impressão digital ocupa a posição. Se os dois estão cheios, uma impressão digital já presente é desalojada e levada para o balde alternativo *dela* — o comportamento que dá nome à estrutura, pelo cuco que põe o ovo no ninho de outra ave e expulsa os ovos dela. O desalojamento se repete em cadeia até encontrar posição livre ou atingir um limite de deslocamentos, quando a inserção falha.
- **Consulta**: procura-se a impressão digital nos dois baldes.
- **Remoção**: apaga-se uma cópia da impressão digital de um dos dois baldes.

```text
b = 4 posições por balde, impressão digital de 8 bits (em hexadecimal)

inserir x: fp(x)=3a, i1=2, i2=2 xor h(3a)=5

balde 2: [ 7f | c1 | 09 | e4 ]   cheio
balde 5: [ 52 | 18 | -- | -- ]   posição livre
            -> 3a entra no balde 5: [ 52 | 18 | 3a | -- ]

consultar x: procura 3a nos baldes 2 e 5  -> encontrado
remover x:   apaga 3a do balde 5
```

**Dimensionamento.** Uma consulta compara a impressão digital com até $2b$ impressões digitais armazenadas; a chance de coincidência acidental com alguma delas dá a taxa de falso positivo:

$$p \approx \frac{2b}{2^f}$$

Com $b = 4$ e $f = 12$ bits, $p \approx 8/4096 \approx 0{,}2\%$. A tabela suporta ocupação de cerca de 95% com $b = 4$ (FAN et al., 2014), e o custo por item é $f/\alpha$, com $\alpha$ a ocupação: $12 / 0{,}95 \approx 12{,}6$ bits por item. O filtro de Bloom para os mesmos 0,2% precisa de $-\ln(0{,}002)/(\ln 2)^2 \approx 12{,}9$ bits por item. A vantagem do cuco cresce à medida que $p$ diminui, porque cada bit a mais na impressão digital divide $p$ por dois, enquanto o Bloom paga 1,44 bit para o mesmo efeito.

**Erro unilateral.** O mesmo do filtro de Bloom: falso positivo possível, falso negativo impossível — com a condição de que só se removam itens efetivamente inseridos.

**Limites.**

- Remover um item que nunca foi inserido pode apagar a impressão digital igual de outro item e criar um falso negativo. A aplicação precisa saber, por outra fonte, que o item está no conjunto antes de removê-lo.
- A inserção pode falhar com a tabela próxima da ocupação máxima; o filtro precisa ser dimensionado com folga ou expandido.
- O mesmo item inserido mais de $2b$ vezes não cabe, porque todas as cópias da sua impressão digital disputam os mesmos dois baldes.
- Para taxas de falso positivo altas (acima de cerca de 3%), o filtro de Bloom ocupa menos memória.

**No Redis.**

```text
CF.RESERVE bloqueio_dinamico 5000000
CF.ADD     bloqueio_dinamico "+5511912345678"   # 1 = inserido
CF.EXISTS  bloqueio_dinamico "+5511912345678"   # 1
CF.DEL     bloqueio_dinamico "+5511912345678"   # 1 = removido
CF.EXISTS  bloqueio_dinamico "+5511912345678"   # 0
```

**No caso condutor.** A lista de bloqueio de telemarketing não é estática: o assinante pode pedir para entrar e para sair dela. Com o filtro de Bloom, cada saída obriga a reconstruir o filtro a partir do cadastro; com o filtro de cuco, a saída é um `CF.DEL` — e o cadastro, que é a fonte exata, garante que só se remove quem estava na lista.

### *Count-min sketch*

**Pergunta.** Quantas vezes o item apareceu no fluxo? A resposta do ***count-min sketch*** nunca é menor que a contagem real e, com probabilidade controlada, não é muito maior.

**Por que existe.** Um mapa de contadores (`dict` em Python, `collections.Counter`) responde exatamente, mas cresce com o número de chaves distintas. Cormode e Muthukrishnan (2005) propuseram uma estrutura de tamanho fixo, determinado só pelo erro tolerado, para contar frequências em fluxos com número de chaves grande demais para um mapa — tráfego de rede por endereço, consultas por termo, acessos por URL.

**Quem usa.** Monitoramento de rede (bytes ou pacotes por endereço de origem), limitação de taxa (*rate limiting*: bloquear um IP depois de $X$ requisições), alertas por contagem (alertar depois de $Y$ erros de uma rota), decisão de admissão em *cache* por frequência de acesso (a política TinyLFU usa uma variante do *count-min* para decidir se um item novo merece entrar no *cache*). Outros casos recorrentes: termos mais buscados, contagem aproximada de vendas por SKU, monitoramento de chamadas por rota de API. O Redis oferece o tipo com os comandos `CMS.*`.

**Mecanismo.** O *sketch* é uma matriz de $d$ linhas por $w$ colunas de contadores, todos inicialmente 0, com uma função de *hash* $h_j$ por linha.

- **Inserção** de $x$ com incremento $c$: para cada linha $j$, soma-se $c$ ao contador $C[j, h_j(x)]$.
- **Estimativa** da frequência de $x$: $\hat{f}(x) = \min_j C[j, h_j(x)]$.

```text
d = 3 linhas, w = 8 colunas

inserir A (3 vezes) e B (2 vezes); A e B colidem na linha 1

          0   1   2   3   4   5   6   7
linha 0:  0   3   0   0   0   2   0   0     h0(A)=1  h0(B)=5
linha 1:  0   0   0   5   0   0   0   0     h1(A)=3  h1(B)=3  colisão
linha 2:  0   0   2   0   0   0   3   0     h2(A)=6  h2(B)=2

estimativa de A = min(3, 5, 3) = 3   (exata)
estimativa de B = min(2, 5, 2) = 2   (exata)
```

Cada contador só recebe incrementos — o do item consultado e os dos itens que colidem com ele naquela linha. Por isso cada contador é um limite superior da frequência real, e o mínimo das $d$ linhas é o limite superior mais apertado disponível. Inserção e consulta custam $O(d)$.

**Dimensionamento.** Sejam $f(x)$ a contagem real, $N$ o total de incrementos e $\varepsilon, \delta$ os parâmetros de erro. Com

$$w = \left\lceil \frac{e}{\varepsilon} \right\rceil, \qquad d = \left\lceil \ln \frac{1}{\delta} \right\rceil$$

vale (CORMODE; MUTHUKRISHNAN, 2005):

$$f(x) \le \hat{f}(x) \quad \text{sempre}, \qquad \Pr\left[\hat{f}(x) > f(x) + \varepsilon N\right] \le \delta$$

O argumento: numa linha, o excesso esperado sobre $f(x)$ é a soma das frequências dos outros itens que caem na mesma coluna, no máximo $N/w = \varepsilon N / e$; pela desigualdade de Markov, a probabilidade de o excesso passar de $\varepsilon N$ é no máximo $1/e$. Como as $d$ linhas usam funções de *hash* independentes, a probabilidade de **todas** excederem é no máximo $e^{-d} = \delta$.

Exemplo: $\varepsilon = 0{,}001$ e $\delta = 0{,}01$ dão $w = 2719$ e $d = 5$, ou seja, 13.595 contadores; com contadores de 32 bits, cerca de 54 KB. Com $N = 10^6$, o erro é de no máximo 1.000 com probabilidade de pelo menos 99%. O tamanho não depende do número de chaves distintas nem do tamanho das chaves.

**Consequência.** O erro é proporcional ao **total** $N$, e não à frequência do item. Para um item com $f(x) = 50{.}000$ num fluxo de $N = 10^6$, o erro de até 1.000 é de 2%; para um item com $f(x) = 10$, o mesmo erro absoluto é de 10.000%. O *count-min* serve para **identificar e medir o que é frequente**, e não para medir o que é raro. Essa propriedade se ajusta bem às distribuições assimétricas (lei de Zipf) das contagens reais, em que poucos itens concentram a maior parte das ocorrências.

**Limites.**

- Sem decremento, na versão básica: subtrair de um contador compartilhado pode levar a estimativa abaixo da contagem real e quebra a garantia $f(x) \le \hat{f}(x)$.
- Sem enumeração das chaves: o *sketch* responde à frequência de um item fornecido, mas não guarda os itens e não lista os mais frequentes — essa é a pergunta do *top-k*.
- Erro relativo grande para itens raros, como descrito acima.
- A **atualização conservadora** (*conservative update*) incrementa apenas os contadores que estão abaixo da nova estimativa; a garantia formal é a mesma, e o erro observado cai à metade nas medições de Zhiyanov (2026), mas a estrutura deixa de admitir incrementos negativos.

**No Redis.**

```text
CMS.INITBYPROB chamadas 0.001 0.01     # epsilon = 0,001, delta = 0,01
CMS.INCRBY     chamadas "+5511912345678" 1 "+5521988887777" 1
CMS.QUERY      chamadas "+5511912345678"
CMS.MERGE      chamadas_total 2 chamadas_sp chamadas_rj
```

`CMS.INITBYPROB` recebe $\varepsilon$ e $\delta$ e deriva as dimensões, com uma variante das fórmulas acima: $w = \lceil 2/\varepsilon \rceil$ e $d = \lceil \log_2(1/\delta) \rceil$ — o mesmo argumento, com a desigualdade de Markov aplicada para probabilidade $1/2$ por linha, em vez de $1/e$. Para $\varepsilon = 0{,}001$ e $\delta = 0{,}01$, o Redis cria $w = 2000$ e $d = 7$, e não $2719 \times 5$. `CMS.INITBYDIM` recebe $w$ e $d$ diretamente. `CMS.MERGE` soma, célula a célula, *sketches* de mesmas dimensões — por exemplo, os de duas centrais de comutação — e o resultado tem a mesma garantia que o *sketch* calculado sobre a união dos fluxos.

**No caso condutor.** Robôs de discagem originam milhares de chamadas por hora a partir de poucos números. Um *count-min* por hora sobre o número de origem identifica os números acima de um limiar sem manter um contador por número. Com $N = 4 \cdot 10^7$ chamadas na hora e $\varepsilon = 10^{-6}$, o erro é de no máximo 40 chamadas com 99% de probabilidade, em $w = 2{,}72 \cdot 10^6$ e $d = 5$, cerca de 54 MB; um limiar de 500 chamadas por hora fica muito acima do erro. A superestimação pode marcar como robô um número legítimo que colida com números muito ativos, e por isso a sinalização leva à verificação, e não ao bloqueio automático.

### *Top-k sketch*

**Pergunta.** Quais são os $k$ itens mais frequentes do fluxo (os ***heavy hitters***), e com que contagem aproximada?

**Por que existe.** O *count-min* estima a frequência de um item conhecido, mas não guarda as chaves e não consegue listá-las. Encontrar os mais frequentes exigiria consultar o *sketch* para todas as chaves possíveis. O ***top-k sketch*** guarda as chaves candidatas, com memória que depende só de $k$.

**Quem usa.** Buscas em alta (*trending searches*), produtos, URLs e *hashtags* do momento, IPs mais ativos num ataque de negação de serviço, itens mais vendidos no período. O Redis oferece o tipo com os comandos `TOPK.*`.

**Mecanismo: *Space-Saving*.** O algoritmo de Metwally, Agrawal e El Abbadi (2005) mantém exatamente $k$ pares (item, contador).

- Item já monitorado: incrementa-se o contador.
- Item novo, com menos de $k$ pares: entra com contador 1.
- Item novo, com os $k$ pares ocupados: o item de **menor** contador é substituído pelo novo, que herda esse contador mais 1.

A herança do contador é o que dá a garantia: com $N$ itens processados, o menor contador nunca passa de $N/k$, todo item com frequência real maior que $N/k$ está garantidamente entre os monitorados, e o contador de cada monitorado superestima sua frequência em no máximo o contador herdado. Com um *heap* de mínimo, a substituição custa $O(\log k)$.

**Mecanismo: *HeavyKeeper*.** Gong et al. (2018) combinam uma matriz parecida com a do *count-min* com um *heap* dos $k$ maiores. Cada balde guarda uma impressão digital e um contador. Ao inserir $x$, em cada linha:

- balde vazio ou já ocupado por $x$: incrementa-se o contador;
- balde ocupado por outro item com contador $c$: o contador é decrementado com probabilidade $b^{c}$, com $b < 1$ (base de decaimento); quando chega a 0, $x$ toma o balde com contador 1.

O decaimento probabilístico protege os itens frequentes, cujo contador alto torna o decremento improvável, e expulsa rapidamente os itens raros. A estimativa de $x$ é o maior contador entre os baldes com sua impressão digital, e o *heap* mantém os $k$ itens de maior estimativa.

**Condição de uso.** As duas variantes funcionam bem em distribuições assimétricas, em que os mais frequentes se destacam do restante. Numa distribuição uniforme, não há *heavy hitters* a encontrar, e a lista devolvida é pouco mais que os últimos itens vistos.

**No Redis.**

```text
TOPK.RESERVE originadores 1000 8000 7 0.925   # k, largura, profundidade, decaimento
TOPK.ADD     originadores "+5511912345678" "+5521988887777"
TOPK.LIST    originadores WITHCOUNT
TOPK.COUNT   originadores "+5511912345678"
```

Os parâmetros de `TOPK.RESERVE` são os do *HeavyKeeper*: $k$, a largura e a profundidade da matriz de baldes e a base de decaimento $b$. `TOPK.ADD` devolve, para cada item inserido, o item expulso da lista dos $k$ maiores, quando há.

**No caso condutor.** Os mil números que mais originaram chamadas na última hora, para o painel da equipe de fraude. O *count-min* do tópico anterior responde se um número conhecido passou do limiar; o *top-k* responde quais são os números, sem conhecê-los de antemão.

## Exemplos

### Filtro de Bloom em Python, por extenso

```python
import hashlib
import math

n = 100_000          # capacidade
p = 0.01             # taxa de falso positivo desejada
m = math.ceil(-n * math.log(p) / (math.log(2) ** 2))
k = round(m / n * math.log(2))
bits = bytearray(m)  # um byte por bit, para deixar o mecanismo visível

def posicoes(item):
    resumo = hashlib.blake2b(item.encode(), digest_size=16).digest()
    ha = int.from_bytes(resumo[:8], "big")
    hb = int.from_bytes(resumo[8:], "big")
    lista = []
    for i in range(k):
        lista.append((ha + i * hb) % m)   # hash duplo
    return lista

def inserir(item):
    for pos in posicoes(item):
        bits[pos] = 1

def consultar(item):
    for pos in posicoes(item):
        if bits[pos] == 0:
            return False      # certamente ausente
    return True               # provavelmente presente
```

Com $n = 10^5$ e $p = 0{,}01$, o código calcula $m = 958.506$ bits e $k = 7$. A implementação completa, com a medição da taxa de falso positivo contra um `set` e a comparação de memória, está em `codigo/codigo01-bloom-cuco-count-min-top-k.ipynb`, que também implementa o filtro de cuco, o *count-min* e o *Space-Saving*.

### Dimensionamento comparado

Para $10^7$ números de telefone:

| Estrutura | Parâmetros | Memória (estimativa) |
|---|---|---|
| `set` de inteiros de 64 bits | — | 80 MB de chaves, várias vezes mais com a tabela *hash* |
| Filtro de Bloom | $p = 1\%$ | $9{,}6 \times 10^7 / 8 \approx 12$ MB |
| Filtro de Bloom | $p = 0{,}1\%$ | $\approx 18$ MB |
| Filtro de cuco | $b = 4$, $f = 12$, $p \approx 0{,}2\%$ | $12{,}6 \times 10^7 / 8 \approx 16$ MB |
| *Count-min* | $\varepsilon = 10^{-6}$, $\delta = 0{,}01$, contadores de 32 bits | $\approx 54$ MB, independente de $n$ |

## Fontes e leituras

- BLOOM, B. H. Space/time trade-offs in hash coding with allowable errors. *Communications of the ACM*, v. 13, n. 7, p. 422–426, 1970.
- CORMODE, G.; MUTHUKRISHNAN, S. An improved data stream summary: the count-min sketch and its applications. *Journal of Algorithms*, v. 55, n. 1, p. 58–75, 2005.
- FAN, B.; ANDERSEN, D. G.; KAMINSKY, M.; MITZENMACHER, M. D. Cuckoo filter: practically better than Bloom. In: *Proceedings of the 10th ACM International Conference on Emerging Networking Experiments and Technologies (CoNEXT)*, 2014. p. 75–88.
- GONG, J. et al. HeavyKeeper: an accurate algorithm for finding top-k elephant flows. In: *USENIX Annual Technical Conference (ATC)*, 2018. p. 909–921.
- LESKOVEC, J.; RAJARAMAN, A.; ULLMAN, J. D. *Mining of Massive Datasets*. 3. ed. Cambridge: Cambridge University Press, 2020. Cap. 4: Mining data streams.
- METWALLY, A.; AGRAWAL, D.; EL ABBADI, A. Efficient computation of frequent and top-k elements in data streams. In: *International Conference on Database Theory (ICDT)*, 2005. p. 398–412.
- PUTZE, F.; SANDERS, P.; SINGLER, J. Cache-, hash-, and space-efficient Bloom filters. *ACM Journal of Experimental Algorithmics*, v. 14, 2009.
- REDIS. Probabilistic data types. Disponível em: https://redis.io/docs/latest/develop/data-types/probabilistic/. Acesso em: 14 nov. 2026.
- ZHIYANOV, A. Probabilistic data structures in Go. 13 nov. 2026. Disponível em: https://antonz.org/probabilistic-data-structures/. Acesso em: 14 nov. 2026.
- GEEKSFORGEEKS. Bloom Filters – Introduction and Implementation. Disponível em: https://www.geeksforgeeks.org/bloom-filters-introduction-and-python-implementation/. Acesso em: 14 nov. 2026.
- Material complementar: os artigos originais de cada estrutura estão na pasta `material-complementar/` da aula.
