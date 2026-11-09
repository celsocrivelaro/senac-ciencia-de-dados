# Ciência de Dados — Aula 12: Modelos de Séries Temporais — Médias móveis e estacionariedade

---

## Objetivos de aprendizagem

Ao final desta nota, espera-se que o aluno seja capaz de:

- Calcular médias móveis simples e centradas e o desvio padrão móvel, e escolher a janela em função do período sazonal.
- Usar a média móvel como estimador de tendência e como previsão de referência, conhecendo suas limitações.
- Definir estacionariedade fraca e reconhecer as violações causadas por tendência, sazonalidade e variância crescente.
- Aplicar e interpretar o teste de Dickey-Fuller aumentado.
- Escolher a transformação — logaritmo, diferenciação, diferenciação sazonal — que torna uma série estacionária.

## Desenvolvimento teórico

### Média móvel

A **média móvel simples** de ordem $N$ (*moving average*, *rolling mean*) é a média das $N$ observações mais recentes:

$$\text{MM}_t = \frac{1}{N}\sum_{i=0}^{N-1} y_{t-i}$$

Calculada ao longo da série, ela produz uma curva suavizada. O tamanho da janela controla a suavização: $N$ grande filtra as oscilações e deixa a tendência; $N$ pequeno acompanha as oscilações de curto prazo. Com $N$ igual ao período sazonal $s$, cada janela contém exatamente um período completo e a sazonalidade se cancela — é o princípio da estimativa de tendência na decomposição clássica (nota sobre decomposição, na aula de análise de séries temporais). A atualização incremental, $\text{MM}_t = \text{MM}_{t-1} + (y_t - y_{t-N})/N$, custa $O(1)$ por instante.

A média móvel definida acima usa só o passado e, por isso, está **atrasada**: numa série com tendência, $\text{MM}_t$ estima o nível de cerca de $(N-1)/2$ instantes atrás. A **média móvel centrada** usa $k$ observações de cada lado,

$$\text{MMC}_t = \frac{1}{2k+1}\sum_{i=-k}^{k} y_{t+i}$$

e elimina o atraso, ao custo de não existir nas $k$ primeiras e nas $k$ últimas posições. Para janela par ($N = 12$), aplica-se uma segunda média de 2 termos sobre a primeira (média $2 \times 12$), o que equivale a uma média ponderada de 13 termos com peso $1/24$ nas extremidades e $1/12$ nos demais.

O **desvio padrão móvel** é o desvio calculado na mesma janela. Ele mostra se a variabilidade da série muda ao longo do tempo: desvio que cresce junto com o nível é sinal de sazonalidade multiplicativa e de que a série precisa de transformação logarítmica.

### Média móvel como previsão

A previsão mais simples baseada em média móvel repete a média das $N$ últimas observações para todo o horizonte:

$$\hat{y}_{T+h} = \frac{1}{N}\sum_{i=0}^{N-1} y_{T-i}, \qquad h = 1, 2, \dots$$

É uma previsão de referência (*baseline*), útil como patamar mínimo que qualquer modelo precisa superar. Tem duas limitações estruturais: a previsão é constante, e por isso não reproduz a sazonalidade; e, numa série com tendência, fica abaixo do nível futuro, porque olha só para o passado.

### Estacionariedade

Uma série é **estacionária no sentido fraco** (ou de segunda ordem) quando

1. $E[y_t] = \mu$ para todo $t$;
2. $\operatorname{Var}(y_t) = \sigma^2 < \infty$ para todo $t$;
3. $\operatorname{Cov}(y_t, y_{t-k}) = \gamma_k$ depende apenas de $k$, e não de $t$.

A **estacionariedade estrita** exige que toda a distribuição conjunta de $(y_{t_1}, \dots, y_{t_n})$ seja invariante a deslocamentos no tempo; na prática de séries temporais, "estacionária" designa a forma fraca.

A estacionariedade é o que torna a série **previsível a partir de si mesma**: se as propriedades estatísticas mudam com o tempo, o que foi estimado no passado não vale para o futuro. Os modelos AR, MA e ARMA, tratados na nota sobre a família ARIMA, pressupõem série estacionária.

Cada componente da série viola uma das condições:

| Componente | Condição violada |
|---|---|
| Tendência | média constante (1) |
| Sazonalidade | média constante (1): a média depende da posição no período |
| Amplitude que cresce com o nível | variância constante (2) |
| Mudança de regime na dependência | autocovariância só função de $k$ (3) |

### Verificação da estacionariedade

**Inspeção visual e estatísticas móveis.** Média móvel e desvio padrão móvel aproximadamente constantes indicam estacionariedade; uma versão mais grosseira compara média e desvio entre as duas metades da série.

**ACF.** Em série estacionária, a autocorrelação decai rapidamente para zero; decaimento lento indica não estacionariedade (nota sobre autocorrelação, na aula de análise de séries temporais).

**Teste de Dickey-Fuller aumentado.** Uma **raiz unitária** (*unit root*) é a forma de não estacionariedade em que cada choque tem efeito permanente sobre o nível. O caso mais simples é o passeio aleatório $y_t = y_{t-1} + \varepsilon_t$, cuja variância cresce linearmente com $t$. O teste de Dickey-Fuller aumentado (*Augmented Dickey-Fuller*, ADF) estima a regressão (DICKEY; FULLER, 1979; SAID; DICKEY, 1984)

$$\nabla y_t = \alpha + \beta t + \gamma\, y_{t-1} + \sum_{i=1}^{p} \delta_i \nabla y_{t-i} + \varepsilon_t$$

e testa $\gamma = 0$. Os termos $\nabla y_{t-i}$ absorvem a autocorrelação de curto prazo, e $p$ é escolhido por critério de informação. A constante $\alpha$ e a tendência $\beta t$ são opcionais; a implementação do `statsmodels` usa por padrão só a constante (`regression="c"`), e `regression="ct"` inclui a tendência.

- $H_0$: $\gamma = 0$, a série tem raiz unitária (não estacionária).
- $H_a$: $\gamma < 0$, a série é estacionária.

Rejeita-se $H_0$ quando o p-valor fica abaixo de α. A estatística não segue a distribuição t usual, e os valores críticos vêm de tabelas próprias, que a implementação já aplica. Dois cuidados de interpretação decorrem da formulação: p-valor alto não prova raiz unitária, apenas não permite rejeitá-la, com o poder do teste baixo em séries curtas; e o ADF testa raiz unitária, não toda forma de não estacionariedade — uma mudança de nível isolada, por exemplo, pode passar no teste. O teste KPSS (KWIATKOWSKI et al., 1992) inverte as hipóteses, com estacionariedade em $H_0$, e é usado como complemento.

### Transformações para estacionariedade

| Transformação | Definição | Efeito |
|---|---|---|
| Logaritmo | $\log y_t$ | estabiliza variância proporcional ao nível; converte crescimento exponencial em linear e sazonalidade multiplicativa em aditiva |
| Diferenciação | $\nabla y_t = y_t - y_{t-1}$ | remove tendência linear; aplicada duas vezes ($\nabla^2$), tendência quadrática |
| Diferenciação sazonal | $\nabla_s y_t = y_t - y_{t-s}$ | remove sazonalidade de período $s$ |

A ordem usual é: logaritmo, se a variância cresce com o nível; diferenciação sazonal, se há sazonalidade; diferenciação simples, se resta tendência. Cada diferenciação custa uma observação (ou $s$, na sazonal) e amplifica o ruído; diferenciar mais que o necessário introduz autocorrelação negativa artificial no lag 1. Média móvel e suavização exponencial **não** produzem estacionariedade: suavizam a série e evidenciam a tendência, mas não a removem.

## Exemplos

### Médias móveis na série de passageiros

O notebook `codigo/codigo01-medias-moveis.ipynb` calcula, sobre a série `AirPassengers`, médias móveis de 6 e 12 meses e o desvio padrão móvel de 6 meses:

```python
media_6 = df.rolling(6).mean()
media_12 = df.rolling(12).mean()
desvio_6 = df.rolling(6).std()
media_12_centrada = df.rolling(12, center=True).mean()
```

A média de 6 meses ainda ondula com as estações; a de 12 meses é uma curva quase lisa, a tendência. O desvio padrão móvel cresce de menos de 20 para mais de 90 mil passageiros ao longo da série: sazonalidade multiplicativa. A média móvel centrada de 12 meses coincide em quase todo o período com a tendência estimada pelo Prophet, mas perde 6 meses em cada extremidade e não pode ser projetada para o futuro.

Como previsão para 1961, a média dos 12 últimos meses dá 476 mil passageiros por mês para todos os meses; a média mensal prevista pelo Prophet é 517 mil. A média móvel subestima o pico de julho e agosto, superestima os meses de baixa e fica abaixo do nível, porque a série continua crescendo.

### Teste ADF

Com `statsmodels`:

```python
from statsmodels.tsa.stattools import adfuller

estatistica, p_valor, lags_usados, n_obs, criticos, aic = adfuller(serie, autolag="AIC")
```

Aplicado à série de passageiros em sucessivas transformações (medido com `statsmodels` 0.14.4):

| Série | Estatística ADF | p-valor | Decisão a 5% |
|---|---|---|---|
| Original | 0,815 | 0,992 | não rejeita $H_0$ |
| $\log y_t$ | −1,717 | 0,422 | não rejeita $H_0$ |
| $\nabla \log y_t$ | −2,717 | 0,071 | não rejeita $H_0$ |
| $\nabla_{12} \nabla \log y_t$ | −4,443 | 0,0002 | rejeita $H_0$: estacionária |

O logaritmo sozinho não basta, porque a tendência permanece. A diferença simples remove a tendência, mas a sazonalidade remanescente mantém o p-valor acima de 0,05. Só a combinação com a diferença sazonal produz série estacionária — a mesma conclusão que a ACF indicou na nota sobre autocorrelação.

### Série aproximadamente estacionária

O notebook `codigo/codigo02-modelos.ipynb` usa o total diário de nascimentos de meninas na Califórnia em 1959 ($T = 365$). As estatísticas por semestre são: média 39,8 e desvio 7,0 no primeiro; média 44,2 e desvio 7,0 no segundo. A variância é estável e não há sazonalidade visível, mas a média sobe cerca de 4 nascimentos por dia, com um salto por volta de setembro. O ADF rejeita a raiz unitária com folga (estatística −4,808, p-valor 0,0001), e a série é tratada como aproximadamente estacionária. A mudança de nível não é raiz unitária e, por isso, o teste não a detecta — ela volta a importar na escolha da tendência do modelo, na nota sobre modelagem e avaliação.

## Fontes e leituras

- DICKEY, D. A.; FULLER, W. A. Distribution of the estimators for autoregressive time series with a unit root. **Journal of the American Statistical Association**, v. 74, n. 366, p. 427-431, 1979.
- HYNDMAN, R. J.; ATHANASOPOULOS, G. **Forecasting**: principles and practice. 3. ed. Melbourne: OTexts, 2021. Cap. 3 e 9. Disponível em: https://otexts.com/fpp3/. Acesso em: 24 out. 2026.
- KWIATKOWSKI, D.; PHILLIPS, P. C. B.; SCHMIDT, P.; SHIN, Y. Testing the null hypothesis of stationarity against the alternative of a unit root. **Journal of Econometrics**, v. 54, n. 1-3, p. 159-178, 1992.
- SAID, S. E.; DICKEY, D. A. Testing for unit roots in autoregressive-moving average models of unknown order. **Biometrika**, v. 71, n. 3, p. 599-607, 1984.
