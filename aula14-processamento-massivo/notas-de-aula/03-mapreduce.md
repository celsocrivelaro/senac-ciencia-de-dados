# Ciência de Dados — Aula 14: Processamento Massivo — MapReduce

---

## Objetivos de aprendizagem

Ao final desta nota, espera-se que o aluno seja capaz de:

- Descrever o modelo de programação MapReduce — funções *map* e *reduce*, embaralhamento (*shuffle*) e combinador (*combiner*) — e a divisão de responsabilidades entre o programador e o sistema de execução.
- Escrever em pseudocódigo as funções *map* e *reduce* de problemas clássicos: contagem de palavras, agregação por chave, índice invertido.
- Identificar quando o combinador é correto e reescrever a média como par (soma, contagem).
- Explicar o papel do sistema de arquivos distribuído, da localidade dos dados e da reexecução de tarefas na escala e na tolerância a falhas do MapReduce.
- Reconhecer os limites do modelo e o que o Spark muda em relação a ele.
- Explicar por que as estruturas probabilísticas fundíveis servem como combinador e como redutor, e escrever a contagem de distintos por chave com HyperLogLog em MapReduce.

## Desenvolvimento teórico

As notas sobre estruturas probabilísticas trataram da primeira saída para o volume que não cabe numa máquina: reduzir a memória aceitando uma resposta aproximada. Esta nota trata da segunda: **distribuir o processamento** por várias máquinas, mantendo a resposta exata, e da combinação das duas saídas.

### O modelo de programação

Define-se **MapReduce** como um modelo de programação para processamento de grandes volumes de dados num agrupamento de máquinas (*cluster*), no qual o programador escreve duas funções e um sistema de execução cuida de toda a distribuição — particionamento da entrada, agendamento das tarefas, comunicação entre máquinas e recuperação de falhas (DEAN; GHEMAWAT, 2004). Os dados são tratados como pares (chave, valor):

$$\textit{map}: (k_1, v_1) \rightarrow \text{lista}(k_2, v_2)$$

$$\textit{reduce}: (k_2, \text{lista}(v_2)) \rightarrow \text{lista}(v_3)$$

- A função ***map*** é aplicada a cada registro da entrada, de forma **independente**: o resultado de um registro não depende de nenhum outro. Ela emite zero ou mais pares intermediários.
- A função ***reduce*** é aplicada a cada **chave intermediária**, recebendo todos os valores emitidos para essa chave, de qualquer mapeador.

Entre as duas fases, o sistema executa o **embaralhamento** (*shuffle*): agrupa os pares intermediários por chave, ordena-os e entrega cada grupo ao redutor responsável. O redutor de uma chave é escolhido por uma **função de particionamento**, em geral $\text{hash}(k_2) \bmod R$, com $R$ o número de redutores; todas as ocorrências de uma chave vão para o mesmo redutor.

```text
 entrada       fase map          embaralhamento             fase reduce
 (blocos)    (M mapeadores)    (partição por chave)        (R redutores)

+--------+    +---------+
| bloco1 | -> | map  1  | --+--> (a,1)(b,1) ---+
+--------+    +---------+   |                  |      +----------+
                            |   hash(k) mod R  +----> | reduce 1 | -> a: 3
+--------+    +---------+   |                  |      | (chave a)|
| bloco2 | -> | map  2  | --+--> (a,1)(c,1) ---+      +----------+
+--------+    +---------+   |                  |      +----------+
                            |                  +----> | reduce 2 | -> b: 2
+--------+    +---------+   |                         | (b e c)  | -> c: 1
| bloco3 | -> | map  3  | --+--> (a,1)(b,1) ---------> +----------+
+--------+    +---------+
```

O modelo é inspirado nas funções de ordem superior `map` e `reduce` (*fold*) das linguagens funcionais, e a exigência de independência entre as aplicações é a mesma: como nenhuma aplicação de *map* depende de outra, todas podem rodar em paralelo, em qualquer ordem e em qualquer máquina.

### Exemplos clássicos

**Contagem de palavras.** A entrada é uma coleção de documentos; a saída, o número de ocorrências de cada palavra.

```text
map(nome_documento, texto):
    para cada palavra em texto:
        emitir(palavra, 1)

reduce(palavra, contagens):
    total = 0
    para cada c em contagens:
        total = total + c
    emitir(palavra, total)
```

**Chamadas por número de origem.** No caso condutor desta aula, o registro de chamadas de uma operadora, com uma linha por chamada (origem, destino, instante, duração):

```text
map(deslocamento, linha):
    origem, destino, instante, duracao = separar(linha)
    emitir(origem, 1)

reduce(origem, uns):
    emitir(origem, soma(uns))
```

É o equivalente distribuído de

```sql
SELECT origem, COUNT(*) FROM chamadas GROUP BY origem;
```

e a correspondência é geral: a chave intermediária é a coluna do `GROUP BY`, a função *map* faz a projeção e o filtro (`SELECT`, `WHERE`), e a função *reduce* faz a agregação. Motores SQL distribuídos compilam consultas para etapas desse tipo.

**Índice invertido.** A entrada é uma coleção de documentos; a saída associa cada palavra à lista dos documentos que a contêm — a estrutura central de um motor de busca.

```text
map(id_documento, texto):
    para cada palavra distinta em texto:
        emitir(palavra, id_documento)

reduce(palavra, ids):
    emitir(palavra, ordenar(ids))
```

**Junção.** A junção de duas tabelas pela mesma chave se faz emitindo, nos dois lados, a chave de junção com uma marca de origem; o redutor de cada chave recebe as linhas das duas tabelas e produz as combinações. A fase de embaralhamento faz o papel do *hash join* distribuído.

### O combinador

O embaralhamento move os pares intermediários pela rede, e é a etapa mais cara do processamento. Na contagem de palavras, um mapeador que processa um bloco de 128 MB emite um par (palavra, 1) para cada ocorrência — centenas de milhares de pares `("de", 1)`, todos com destino ao mesmo redutor.

O **combinador** (*combiner*) é uma redução parcial executada na própria máquina do mapeador, sobre os pares que ele emitiu, antes do embaralhamento. Na contagem de palavras, o combinador soma as ocorrências locais e o mapeador passa a enviar um único par `("de", 48213)`. O volume que cruza a rede deixa de ser proporcional ao número de ocorrências e passa a ser proporcional ao número de chaves distintas por mapeador.

O combinador só é correto quando a operação de redução é **associativa e comutativa**: o sistema não garante quantas vezes o combinador roda (zero, uma ou várias vezes), nem sobre quais subconjuntos dos valores. Seja $\oplus$ a operação; o resultado precisa ser o mesmo para qualquer agrupamento e qualquer ordem: $(a \oplus b) \oplus c = a \oplus (b \oplus c)$ e $a \oplus b = b \oplus a$.

| Agregação | Combinador direto | Correção |
|---|---|---|
| soma, contagem | correto | — |
| máximo, mínimo | correto | — |
| média | **incorreto**: a média das médias parciais não é a média total, quando os grupos têm tamanhos diferentes | combinar o par (soma, contagem) e dividir só no redutor final |
| mediana, quantis | **incorreto**, e sem par equivalente exato | resumo fundível aproximado (*t-digest*) |
| contagem de distintos | **incorreto**: contagens de distintos não se somam | conjunto de distintos (caro) ou resumo fundível aproximado (HyperLogLog) |

Exemplo da média: dois mapeadores com as durações $\{10, 20\}$ e $\{60\}$ têm médias 15 e 60, cuja média é 37,5; a média verdadeira é $90/3 = 30$. Com o par (soma, contagem), os mapeadores enviam $(30, 2)$ e $(60, 1)$, o redutor soma para $(90, 3)$ e divide: 30.

### O sistema de execução

O modelo de programação só esconde a distribuição porque o sistema de execução resolve três problemas (DEAN; GHEMAWAT, 2004).

**Sistema de arquivos distribuído.** A entrada e a saída ficam num sistema de arquivos distribuído — o GFS no Google (GHEMAWAT; GOBIOFF; LEUNG, 2003), o HDFS no Hadoop —, que divide os arquivos em blocos grandes (64 MB no GFS original, 128 MB no padrão atual do HDFS) e guarda cada bloco replicado, tipicamente em três máquinas. Um nó mestre mantém só os metadados: quais blocos compõem cada arquivo e onde estão as réplicas.

**Localidade dos dados.** O agendador sabe onde está cada bloco e atribui a tarefa de *map* de um bloco, preferencialmente, a uma das máquinas que já têm uma réplica dele. A leitura da entrada é local e não usa a rede: leva-se a computação ao dado, e não o dado à computação. Numa entrada de 1 TB, essa decisão evita transferir o terabyte pela rede do agrupamento; o que cruza a rede é só o resultado do embaralhamento, já reduzido pelo combinador.

**Tolerância a falhas.** Num agrupamento de milhares de máquinas comuns, a falha de uma máquina durante um processamento longo é a regra, e não a exceção. O mestre monitora os trabalhadores; quando um falha, as tarefas dele são **reexecutadas** em outra máquina. A reexecução só é correta porque as funções *map* e *reduce* são **determinísticas e sem efeito colateral**: executar a mesma tarefa duas vezes produz o mesmo resultado, e a saída de uma tarefa só se torna visível quando ela termina. As saídas intermediárias dos mapeadores ficam no disco local; as dos redutores, no sistema de arquivos distribuído.

**Tarefas lentas.** O tempo total de uma etapa é o da tarefa mais lenta. Uma máquina com disco defeituoso ou sobrecarregada (um ***straggler***) atrasa a etapa inteira. Perto do fim de cada etapa, o sistema lança **execução especulativa**: cópias das tarefas ainda em andamento rodam em outras máquinas, e vale o resultado da que terminar primeiro.

### Limites do modelo e o Spark

O MapReduce grava em disco o resultado de cada etapa: a saída dos mapeadores no disco local, a dos redutores no sistema de arquivos distribuído, com replicação. Para um processamento de uma etapa, como a contagem de palavras, o custo é aceitável. Algoritmos **iterativos** — os de aprendizado de máquina, que repetem a mesma passada sobre os dados até convergir, e os de grafos, como o PageRank — encadeiam dezenas de etapas e pagam a escrita e a leitura do disco em cada uma. Consultas interativas sobre o mesmo conjunto de dados pagam a leitura de novo em cada consulta.

O **Spark** (ZAHARIA et al., 2012) generaliza o modelo com os ***resilient distributed datasets*** (RDDs): coleções distribuídas e imutáveis que podem ser mantidas em memória entre etapas. A tolerância a falhas deixa de depender da gravação em disco: cada RDD registra a sequência de transformações que o produziu (sua **linhagem**, *lineage*), e uma partição perdida é recalculada a partir dela. O programa deixa de ser um par *map*–*reduce* e passa a ser um grafo de transformações (`map`, `filter`, `join`, `reduceByKey`, `groupByKey`), que o Spark executa em estágios separados pelos embaralhamentos. O vocabulário do MapReduce permanece: `reduceByKey` é a redução por chave com combinador embutido, e por isso exige operação associativa e comutativa; `groupByKey` é a redução sem combinador, que embaralha todos os valores.

A sequência histórica resume a evolução: o MapReduce no Google (2004); o Hadoop, implementação de código aberto do MapReduce e do sistema de arquivos distribuído; o Spark, com processamento em memória; e os motores SQL distribuídos — Hive sobre o Hadoop, Spark SQL, BigQuery —, em que o usuário escreve SQL e o motor compila a consulta para estágios de mapeamento, embaralhamento e redução.

### Estruturas probabilísticas dentro do MapReduce

As duas saídas para o volume se combinam. Define-se **resumo fundível** (*mergeable summary*) como um resumo de dados $S$ para o qual existe uma operação de fusão tal que a fusão de $S(A)$ e $S(B)$ tem a mesma garantia de erro que $S(A \cup B)$, calculado diretamente sobre a união (AGARWAL et al., 2013). As estruturas da aula são fundíveis:

| Estrutura | Fusão |
|---|---|
| Filtro de Bloom | OU bit a bit, com os mesmos $m$, $k$ e funções de *hash* |
| *Count-min* | soma célula a célula, com as mesmas dimensões e funções de *hash* |
| HyperLogLog | máximo registrador a registrador, exata |
| MinHash | mínimo posição a posição, exata |
| *t-digest* | concatenação dos centróides e nova compressão |

Uma operação de fusão com essas propriedades é associativa e comutativa — exatamente a condição do combinador. Um resumo fundível serve, portanto, como **combinador e como redutor**, e resolve as linhas incorretas do quadro do combinador: a contagem de distintos e os quantis.

**Contagem de distintos por chave.** No caso condutor: quantos números distintos ligaram para cada DDD de destino. A versão exata emite (DDD, número de origem) e o redutor monta um conjunto por DDD; o embaralhamento transporta todos os números, e o redutor de um DDD grande guarda milhões de números em memória. Com HyperLogLog:

```text
map(deslocamento, linha):
    origem, destino, instante, duracao = separar(linha)
    ddd = ddd_de(destino)
    s = novo_hll(p = 14)
    adicionar(s, origem)
    emitir(ddd, s)

combinar(ddd, sketches):            # mesma função do reduce
    s = novo_hll(p = 14)
    para cada t em sketches:
        s = fundir(s, t)            # máximo por registrador
    emitir(ddd, s)

reduce(ddd, sketches):
    s = novo_hll(p = 14)
    para cada t em sketches:
        s = fundir(s, t)
    emitir(ddd, estimar(s))
```

Com o combinador, cada mapeador envia no máximo um *sketch* de 12 KB por DDD, qualquer que seja o número de chamadas no seu bloco; com 67 DDDs no Brasil e $M$ mapeadores, o embaralhamento transporta no máximo $67 \cdot M$ *sketches*. O erro da estimativa final é o de um único HyperLogLog com $p = 14$, 0,81%, porque a fusão é exata. A forma ingênua de emitir um *sketch* por linha é corrigida pelo combinador; na prática, o mapeador mantém um *sketch* por DDD em memória ao longo do bloco e emite todos no fim.

É assim que funcionam `APPROX_COUNT_DISTINCT` no BigQuery e `approx_count_distinct` no Spark: cada trabalhador mantém *sketches* HyperLogLog++ por grupo, os *sketches* cruzam a rede no embaralhamento e são fundidos no estágio final. A mesma estrutura atende aos percentis distribuídos com *t-digest*: cada servidor resume a sua parte, e o p99 global sai da fusão dos resumos, e não da média dos p99 locais.

## Exemplos

O notebook `codigo/codigo04-mapreduce.ipynb` simula o MapReduce em Python puro, sem Hadoop nem Spark, com as fases escritas por extenso sobre um registro de chamadas sintético dividido em blocos:

```python
def fase_map(bloco):
    pares = []
    for linha in bloco:
        origem, destino, instante, duracao = linha
        pares.append((origem, 1))
    return pares

def embaralhar(lista_de_pares, R):
    particoes = []
    for r in range(R):
        particoes.append({})
    for pares in lista_de_pares:
        for chave, valor in pares:
            r = hash(chave) % R
            if chave not in particoes[r]:
                particoes[r][chave] = []
            particoes[r][chave].append(valor)
    return particoes

def fase_reduce(particao):
    resultado = {}
    for chave, valores in particao.items():
        total = 0
        for v in valores:
            total = total + v
        resultado[chave] = total
    return resultado
```

O notebook mede o número de pares que atravessam o embaralhamento com e sem combinador, demonstra o erro da média combinada diretamente e a correção pelo par (soma, contagem), e implementa a contagem de distintos por DDD com HyperLogLog como combinador e redutor, comparada com a contagem exata.

## Fontes e leituras

- AGARWAL, P. K.; CORMODE, G.; HUANG, Z.; PHILLIPS, J. M.; WEI, Z.; YI, K. Mergeable summaries. *ACM Transactions on Database Systems*, v. 38, n. 4, art. 26, 2013.
- DEAN, J.; GHEMAWAT, S. MapReduce: simplified data processing on large clusters. In: *6th Symposium on Operating Systems Design and Implementation (OSDI)*. San Francisco: USENIX, 2004. p. 137–150.
- GHEMAWAT, S.; GOBIOFF, H.; LEUNG, S.-T. The Google file system. In: *19th ACM Symposium on Operating Systems Principles (SOSP)*, 2003. p. 29–43.
- LESKOVEC, J.; RAJARAMAN, A.; ULLMAN, J. D. *Mining of Massive Datasets*. 3. ed. Cambridge: Cambridge University Press, 2020. Cap. 2: MapReduce and the new software stack.
- ZAHARIA, M. et al. Resilient distributed datasets: a fault-tolerant abstraction for in-memory cluster computing. In: *9th USENIX Symposium on Networked Systems Design and Implementation (NSDI)*, 2012. p. 15–28.
- APACHE SOFTWARE FOUNDATION. Apache Hadoop: MapReduce Tutorial. Disponível em: https://hadoop.apache.org/docs/stable/hadoop-mapreduce-client/hadoop-mapreduce-client-core/MapReduceTutorial.html. Acesso em: 14 nov. 2026.
- Material complementar: os artigos originais do MapReduce, do GFS e do Spark estão na pasta `material-complementar/` da aula.
