# Ciência de Dados — Aula 11: Análise de Séries Temporais — Decomposição

---

## Objetivos de aprendizagem

Ao final desta nota, espera-se que o aluno seja capaz de:

- Formular os modelos aditivo e multiplicativo de decomposição e relacioná-los pelo logaritmo.
- Escolher entre os dois modelos a partir do comportamento da amplitude sazonal.
- Descrever o algoritmo da decomposição clássica por médias móveis.
- Interpretar a decomposição do Prophet — tendência por partes, sazonalidade por série de Fourier e efeito de feriados.
- Usar os resíduos para avaliar se a decomposição capturou a estrutura da série.

## Desenvolvimento teórico

### Modelos aditivo e multiplicativo

A **decomposição** de uma série temporal é a separação de $y_t$ em tendência $T_t$, sazonalidade $S_t$ e ruído $R_t$, de modo que cada componente possa ser analisado isoladamente. O ciclo, como visto na nota sobre componentes, fica incorporado à tendência. Os dois modelos clássicos diferem na forma como os componentes se combinam:

$$\text{aditivo: } y_t = T_t + S_t + R_t \qquad\qquad \text{multiplicativo: } y_t = T_t \times S_t \times R_t$$

No modelo **aditivo**, $S_t$ é expresso em unidades da série — "julho tem 64 mil passageiros acima da tendência" — e a amplitude sazonal é a mesma em qualquer nível. No **multiplicativo**, $S_t$ é um fator adimensional em torno de 1 — "julho tem 23% acima da tendência" — e a amplitude, em unidades da série, cresce proporcionalmente ao nível.

O logaritmo converte um modelo no outro:

$$\log y_t = \log T_t + \log S_t + \log R_t$$

Uma série multiplicativa, após a transformação logarítmica, é decomposta pelo modelo aditivo, e os componentes são recuperados pela exponencial. A transformação exige $y_t > 0$.

**Critério de escolha.** Se a amplitude das oscilações sazonais se mantém constante ao longo da série, o modelo é aditivo; se cresce com o nível, multiplicativo. O critério visual pode ser confirmado pelo desvio padrão em janelas, tratado na nota sobre médias móveis e estacionariedade da aula de modelos: desvio que cresce junto com a média indica sazonalidade multiplicativa.

### Decomposição clássica

A **decomposição clássica** (*classical decomposition*) estima os componentes em três passos, para uma série de período sazonal $s$:

```text
1. tendência:     T̂_t = média móvel centrada de ordem s (2×s se s é par)
2. sem tendência: D_t = y_t − T̂_t            (aditivo)
                  D_t = y_t / T̂_t            (multiplicativo)
3. sazonalidade:  Ŝ_j = média de D_t nos instantes t com a mesma posição j
                        no período (todos os janeiros, todas as segundas...),
                        normalizada para somar 0 (aditivo) ou ter média 1
                        (multiplicativo)
4. ruído:         R̂_t = y_t − T̂_t − Ŝ_t      (aditivo)
                  R̂_t = y_t / (T̂_t · Ŝ_t)    (multiplicativo)
```

A média móvel de ordem $s$ cobre exatamente um período e por isso cancela a sazonalidade: cada janela contém um janeiro, um fevereiro e assim por diante. Quando $s$ é par, a janela de $s$ termos não tem centro, e aplica-se uma segunda média de 2 termos (a média móvel $2 \times 12$ para dados mensais). A média móvel é desenvolvida na nota sobre médias móveis e estacionariedade da aula de modelos.

O método tem três limitações conhecidas (HYNDMAN; ATHANASOPOULOS, 2021): perde $s/2$ observações de tendência em cada extremidade da série; supõe que o padrão sazonal é idêntico em todos os anos; e é sensível a valores atípicos, que contaminam a média móvel e o índice sazonal. Métodos posteriores, como o STL (CLEVELAND et al., 1990), substituem a média móvel por regressão local e permitem que a sazonalidade varie lentamente.

### Decomposição pelo Prophet

O **Prophet** (TAYLOR; LETHAM, 2018) é uma biblioteca de previsão da Meta que trata a série como um problema de **ajuste de curvas**: o valor é função do tempo, não dos valores anteriores da série. O modelo aditivo é

$$y(t) = g(t) + s(t) + h(t) + \varepsilon_t$$

- $g(t)$, **tendência**: linear por partes, com inclinação que muda em **pontos de mudança** (*changepoints*). Por padrão, o Prophet distribui 25 candidatos a ponto de mudança nos primeiros 80% da série e aplica uma penalização que mantém a maioria das mudanças próximas de zero; o parâmetro `changepoint_prior_scale` controla essa penalização e, portanto, a flexibilidade da tendência.
- $s(t)$, **sazonalidade**: soma de senos e cossenos de período $P$ (série de Fourier),

$$s(t) = \sum_{n=1}^{N} \left( a_n \cos\frac{2\pi n t}{P} + b_n \sin\frac{2\pi n t}{P} \right)$$

  com $P = 365{,}25$ dias para a sazonalidade anual e $P = 7$ para a semanal. Os coeficientes $a_n, b_n$ são estimados por regressão; $N$ controla quão irregular o padrão sazonal pode ser.
- $h(t)$, **feriados e eventos**: efeito aditivo em datas informadas.
- $\varepsilon_t$: erro, suposto independente.

No modo **multiplicativo** (`seasonality_mode='multiplicative'`), a sazonalidade e os feriados escalam a tendência:

$$y(t) = g(t)\,\big(1 + s(t) + h(t)\big) + \varepsilon_t$$

Duas diferenças em relação à decomposição clássica decorrem desse formato. A tendência existe em toda a série, inclusive nas extremidades, e pode ser projetada para o futuro, porque é uma função do tempo. E a sazonalidade é uma curva suave de período fixo, não um conjunto de índices por posição no período. A limitação correspondente está no termo de erro: o Prophet não modela a dependência entre erros sucessivos, o que aparece na autocorrelação dos resíduos.

### Resíduos como diagnóstico

O **resíduo** da decomposição é o que resta após a remoção dos componentes estimados:

$$\hat{R}_t = y_t - \hat{y}_t$$

Se a decomposição capturou toda a estrutura da série, o resíduo é **ruído branco**: média zero, variância constante e nenhuma autocorrelação. Resíduo com padrão — oscilação sazonal remanescente, sequências longas acima ou abaixo de zero, variância que cresce com o tempo — indica componente mal especificado. A verificação formal usa a autocorrelação dos resíduos, desenvolvida na nota sobre autocorrelação.

## Exemplos

### Decomposição clássica da série de passageiros

Com `statsmodels`, a decomposição clássica é uma chamada:

```python
from statsmodels.tsa.seasonal import seasonal_decompose

decomp = seasonal_decompose(y, model="multiplicative", period=12)
decomp.plot()
```

Os índices sazonais obtidos para a série `AirPassengers` (medidos com `statsmodels` 0.14.4) são:

| | jan | fev | mar | abr | mai | jun | jul | ago | set | out | nov | dez |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Multiplicativo ($\times$) | 0,91 | 0,88 | 1,01 | 0,98 | 0,98 | 1,11 | 1,23 | 1,22 | 1,06 | 0,92 | 0,80 | 0,90 |
| Aditivo (mil pass.) | −24,7 | −36,2 | −2,2 | −8,0 | −4,5 | +35,4 | +63,8 | +62,8 | +16,5 | −20,6 | −53,6 | −28,6 |

O índice multiplicativo de julho, 1,23, significa 23% acima da tendência em qualquer ano. O aditivo, +63,8 mil, é a média de um efeito que, em 1949, era de cerca de 20 mil e, em 1960, de mais de 100 mil: o modelo aditivo usa o mesmo valor nos dois extremos e erra nos dois.

### Decomposição pelo Prophet

O notebook `codigo/analise-serie-temporal.ipynb` ajusta o Prophet à mesma série nos dois modos. Os dados mensais não têm sazonalidade semanal nem diária, que são desligadas:

```python
from prophet import Prophet

df_prophet = df.reset_index().rename(columns={"Month": "ds", "#Passengers": "y"})
modelo = Prophet(seasonality_mode="multiplicative", yearly_seasonality=True, weekly_seasonality=False, daily_seasonality=False)
modelo.fit(df_prophet)
ajuste = modelo.predict(df_prophet[["ds"]])
modelo.plot_components(ajuste)
```

A comparação entre o ajuste e os dados confirma o diagnóstico do gráfico: no modo aditivo, a amplitude sazonal é fixa, e o modelo exagera as oscilações dos primeiros anos e subestima as dos últimos; no multiplicativo, a amplitude acompanha a tendência e o ajuste segue picos e vales em todo o período.

### Consequências e limites

A decomposição é descritiva: separa componentes de uma série observada, mas não diz, sozinha, se o padrão vai continuar. A decomposição clássica não tem tendência nas extremidades e não projeta o futuro; o Prophet projeta, mas supõe que tendência e sazonalidade estimadas permanecem. Em ambos os casos, os resíduos são o teste de que a decomposição é adequada.

## Fontes e leituras

- CLEVELAND, R. B.; CLEVELAND, W. S.; McRAE, J. E.; TERPENNING, I. STL: a seasonal-trend decomposition procedure based on loess. **Journal of Official Statistics**, v. 6, n. 1, p. 3-73, 1990.
- HYNDMAN, R. J.; ATHANASOPOULOS, G. **Forecasting**: principles and practice. 3. ed. Melbourne: OTexts, 2021. Cap. 3. Disponível em: https://otexts.com/fpp3/. Acesso em: 24 out. 2026.
- TAYLOR, S. J.; LETHAM, B. Forecasting at scale. **The American Statistician**, v. 72, n. 1, p. 37-45, 2018.
- META. **Prophet**: forecasting at scale. Documentação. Disponível em: https://facebook.github.io/prophet/. Acesso em: 24 out. 2026.
