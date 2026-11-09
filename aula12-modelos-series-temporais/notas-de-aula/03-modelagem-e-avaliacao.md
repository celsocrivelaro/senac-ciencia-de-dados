# Ciência de Dados — Aula 12: Modelos de Séries Temporais — Modelagem e avaliação

---

## Objetivos de aprendizagem

Ao final desta nota, espera-se que o aluno seja capaz de:

- Configurar os componentes do Prophet — tendência, sazonalidades, feriados — a partir da análise da série.
- Separar treino e teste respeitando a ordem temporal e descrever a validação com origem móvel.
- Calcular RMSE e MAE e compará-los com previsões de referência.
- Descrever como modelos de aprendizado de máquina e redes recorrentes são aplicados a séries temporais.
- Escolher uma família de modelos a partir das características da série.

## Desenvolvimento teórico

### Prophet como modelo de previsão

O Prophet e sua decomposição $y(t) = g(t) + s(t) + h(t) + \varepsilon_t$ foram apresentados na nota sobre decomposição, na aula de análise de séries temporais. Como modelo de previsão, ele difere da família ARIMA em dois pontos: não exige estacionariedade, porque modela a tendência explicitamente como função do tempo; e não usa os valores anteriores da série, o que o deixa insensível à dependência de curto prazo entre observações vizinhas.

No ARIMA, a estrutura do modelo é dada pelas ordens $(p, d, q)$. No Prophet, é dada pelos componentes ativados e pela flexibilidade de cada um:

| Parâmetro | Valores | Efeito |
|---|---|---|
| `growth` | `'linear'` (padrão), `'flat'`, `'logistic'` | tendência linear por partes, constante, ou com saturação (exige capacidade `cap`) |
| `changepoint_prior_scale` | padrão 0,05 | flexibilidade da tendência: maior permite mais mudanças de inclinação e arrisca sobreajuste |
| `yearly_seasonality`, `weekly_seasonality`, `daily_seasonality` | `True`, `False`, ou a ordem de Fourier | liga ou desliga cada sazonalidade |
| `seasonality_mode` | `'additive'`, `'multiplicative'` | modo da sazonalidade |
| `holidays`, `add_country_holidays` | tabela de datas, código do país | efeito de feriados e eventos |
| `interval_width` | padrão 0,8 | cobertura do intervalo de incerteza |

Uma sazonalidade só pode ser estimada se a série cobre vários períodos dela: com um único ano de dados, a sazonalidade anual não é identificável, porque cada posição do ciclo aparece uma vez só. Pela mesma razão, a sazonalidade diária não existe em dados com um valor por dia.

### Separação temporal entre treino e teste

A avaliação de um modelo de previsão mede o erro em dados que ele não viu. Em séries temporais, a separação **respeita a ordem**: o treino é o início da série e o teste é o fim. A divisão aleatória, usual em aprendizado supervisionado, coloca observações futuras no treino e faz o modelo "ver" o período que deveria prever; como observações vizinhas são correlacionadas, o erro medido fica artificialmente baixo.

```text
 treino                                         teste
 |=============================================|-----------|  --> t
 y_1                                         y_n  y_{n+1}  y_T
```

Uma única separação dá uma única estimativa de erro, sensível ao período escolhido para teste. A **validação com origem móvel** (*rolling origin*, *time series cross-validation*) repete o procedimento com o ponto de corte avançando, e calcula a média dos erros:

```text
 corte 1:  |=========|---|
 corte 2:  |============|---|
 corte 3:  |===============|---|
 corte 4:  |==================|---|
```

O Prophet implementa o procedimento em `prophet.diagnostics.cross_validation`.

### Métricas de erro

Para previsões $\hat{y}_t$ de valores observados $y_t$ no período de teste, com $n$ observações:

$$\text{RMSE} = \sqrt{\frac{1}{n}\sum_t (y_t - \hat{y}_t)^2} \qquad\qquad \text{MAE} = \frac{1}{n}\sum_t |y_t - \hat{y}_t|$$

Ambas estão na unidade da série. O RMSE penaliza mais os erros grandes, por elevar ao quadrado; o MAE trata todos os erros na mesma proporção. Métricas percentuais, como o MAPE, permitem comparar séries de escalas diferentes, mas não são definidas quando a série tem valores nulos.

### Previsões de referência

Um valor de RMSE isolado não indica se o modelo é bom. A comparação é feita com **previsões de referência** (*baselines*), métodos sem parâmetros a estimar:

| Método | Previsão para $T + h$ | Adequado a |
|---|---|---|
| Média | média do treino | série estacionária sem padrão |
| Ingênuo (*naive*) | último valor observado, $y_T$ | passeio aleatório |
| Ingênuo sazonal | valor do mesmo instante no período anterior, $y_{T+h-s}$ | série com sazonalidade forte |
| Média móvel | média das $N$ últimas observações | série estacionária com ruído |

Um modelo só se justifica se supera a referência adequada à série. A regra vale também na direção oposta: quando a melhor referência já é difícil de bater, a série tem pouco padrão a ser aprendido.

### Aprendizado de máquina

Modelos de aprendizado supervisionado — regressão linear, árvores de decisão e seus conjuntos, como florestas aleatórias e *gradient boosting* — são aplicados a séries temporais pela conversão em tabela: cada linha é um instante $t$, o alvo é $y_t$, e os atributos são as defasagens $y_{t-1}, \dots, y_{t-k}$, estatísticas móveis e atributos de calendário (mês, dia da semana, feriado).

```text
  t  | y_{t-3} | y_{t-2} | y_{t-1} | mês | dia_semana || alvo y_t
 ----+---------+---------+---------+-----+------------++---------
  4  |   y_1   |   y_2   |   y_3   |  1  |     4      ||   y_4
  5  |   y_2   |   y_3   |   y_4   |  1  |     5      ||   y_5
 ... |   ...   |   ...   |   ...   | ... |    ...     ||   ...
```

A conversão permite incorporar variáveis externas e relações não lineares. Duas restrições decorrem dela: a validação continua temporal, como acima; e a previsão de vários passos à frente exige usar as próprias previsões como defasagens dos passos seguintes, o que acumula erro. Árvores não extrapolam além dos valores vistos no treino, e por isso não projetam tendência: costuma-se modelar a série diferenciada.

### Redes neurais recorrentes

Uma **rede neural recorrente** (*recurrent neural network*, RNN) processa a sequência um instante por vez, mantendo um estado interno $h_t = f(h_{t-1}, y_t)$ que resume o passado. Em sequências longas, o gradiente propagado no tempo tende a desaparecer, e a rede perde a dependência de longo prazo. A **LSTM** (*long short-term memory*) (HOCHREITER; SCHMIDHUBER, 1997) acrescenta uma célula de memória controlada por portas — de entrada, de esquecimento e de saída — que decidem o que o estado retém, o que mitiga o problema. Arquiteturas baseadas em *Transformers* substituem a recorrência por atenção sobre toda a janela de entrada.

Esses modelos capturam padrões não lineares e aprendem conjuntamente muitas séries relacionadas, mas exigem volume de dados muito maior que os modelos clássicos e são mais caros de ajustar e de interpretar. Em séries individuais e curtas, como as desta aula, os modelos estatísticos costumam ter desempenho igual ou superior (MAKRIDAKIS; SPILIOTIS; ASSIMAKOPOULOS, 2018).

### Escolha do modelo

| Característica da série | Família indicada |
|---|---|
| Estacionária, dependência de curto prazo | AR, MA, ARMA |
| Tendência | ARIMA, Holt, Prophet com tendência linear |
| Tendência e sazonalidade | SARIMA, Holt-Winters, Prophet |
| Sem tendência nem sazonalidade, previsão de curto prazo | suavização exponencial simples, média |
| Vários períodos sazonais, feriados, dados faltantes | Prophet |
| Relações não lineares, variáveis externas, grande volume | *gradient boosting*, LSTM, *Transformers* |

A tabela orienta a escolha dos candidatos; a decisão é tomada pela avaliação em dados de teste, contra as referências.

## Exemplos

### Nascimentos diários: o modelo que perde para a média

O notebook `codigo/codigo02-modelos.ipynb` modela a série de nascimentos diários de 1959, aproximadamente estacionária (nota sobre médias móveis e estacionariedade). A ACF é fraca ($r_1 = 0{,}22$) e destaca o lag 7 ($r_7 = 0{,}20$), sinal de padrão semanal. O modelo usa por isso a sazonalidade semanal e desliga a anual (há um ano só) e a diária (um valor por dia). Os primeiros 292 dias formam o treino; os últimos 73, de 20 de outubro a 31 de dezembro, o teste.

```python
modelo = Prophet(yearly_seasonality=False, weekly_seasonality=True, daily_seasonality=False)
modelo.fit(treino)
previsao = modelo.predict(teste[["ds"]])
```

| Modelo | RMSE (nascimentos/dia) |
|---|---|
| Referência: média do treino | 6,56 |
| Prophet, tendência linear | 9,52 |
| Prophet, tendência constante (`growth='flat'`) | 6,81 |

O Prophet com a configuração padrão erra mais que a média. O gráfico de componentes mostra a causa: a tendência linear interpretou a mudança de nível de setembro como crescimento e o projetou sobre o período de teste, em que a série volta a oscilar em torno de um nível. Com tendência constante, coerente com a análise de estacionariedade, o erro cai para perto da referência, sem superá-la. O componente semanal estimado é pequeno — cerca de 3 nascimentos a menos aos domingos e 2 a 3 a mais às terças e quartas — e não compensa o ruído de uma série com $r_1 = 0{,}22$. A série tem pouco padrão a ser aprendido, e a média é uma previsão difícil de superar.

### Passageiros aéreos: modelos contra referências

Na série de passageiros, com treino de 1949 a 1958 e teste em 1959 e 1960 (24 meses), os modelos da nota sobre a família ARIMA e as referências produzem (medido com `statsmodels` 0.14.4):

| Modelo | RMSE (mil passageiros) |
|---|---|
| Referência: média dos 12 últimos meses do treino | 103,2 |
| Referência: ingênuo sazonal (repete 1958) | 77,0 |
| SARIMA(0, 1, 1)(0, 1, 1)$_{12}$ sobre $\log y_t$ | 43,2 |
| Holt-Winters, tendência aditiva e sazonalidade multiplicativa | 32,5 |

Ao contrário dos nascimentos, a série tem tendência e sazonalidade marcadas, e os dois modelos reduzem o erro da melhor referência à metade ou menos. A vantagem do Holt-Winters sobre o SARIMA neste corte não basta para ordenar os dois modelos: um único período de teste é uma única amostra do erro, e a comparação entre modelos próximos exige a validação com origem móvel.

### Consequências e limites

As duas séries mostram as três etapas que antecedem qualquer escolha de modelo: analisar a série (estacionariedade, decomposição, ACF), configurar o modelo de acordo com essa análise em vez de confiar nos valores padrão, e comparar sempre com uma referência simples. Nenhum modelo extrai padrão de uma série que não o tem, e a avaliação em um único período de teste é uma estimativa ruidosa do desempenho futuro.

## Fontes e leituras

- HOCHREITER, S.; SCHMIDHUBER, J. Long short-term memory. **Neural Computation**, v. 9, n. 8, p. 1735-1780, 1997.
- HYNDMAN, R. J.; ATHANASOPOULOS, G. **Forecasting**: principles and practice. 3. ed. Melbourne: OTexts, 2021. Cap. 5 e 12. Disponível em: https://otexts.com/fpp3/. Acesso em: 24 out. 2026.
- MAKRIDAKIS, S.; SPILIOTIS, E.; ASSIMAKOPOULOS, V. Statistical and machine learning forecasting methods: concerns and ways forward. **PLOS ONE**, v. 13, n. 3, e0194889, 2018.
- TAYLOR, S. J.; LETHAM, B. Forecasting at scale. **The American Statistician**, v. 72, n. 1, p. 37-45, 2018.
- META. **Prophet**: forecasting at scale. Documentação. Disponível em: https://facebook.github.io/prophet/. Acesso em: 24 out. 2026.
