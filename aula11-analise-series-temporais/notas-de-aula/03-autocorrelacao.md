# Ciência de Dados — Aula 11: Análise de Séries Temporais — Autocorrelação

---

## Objetivos de aprendizagem

Ao final desta nota, espera-se que o aluno seja capaz de:

- Definir autocorrelação e autocorrelação parcial, e calcular o estimador $r_k$.
- Ler um correlograma, incluindo o intervalo de confiança de Bartlett, e reconhecer as assinaturas de tendência, sazonalidade e ruído branco.
- Aplicar logaritmo, diferenciação e diferenciação sazonal para revelar a estrutura escondida pela tendência.
- Usar a ACF dos resíduos para avaliar uma decomposição.

## Desenvolvimento teórico

### Autocorrelação

A **autocorrelação de defasagem $k$** (*lag* $k$) é a correlação entre a série e ela mesma deslocada $k$ instantes:

$$\rho_k = \frac{\operatorname{Cov}(y_t,\, y_{t-k})}{\operatorname{Var}(y_t)}$$

A definição supõe que covariância e variância não dependem de $t$, condição formalizada como estacionariedade na nota sobre médias móveis e estacionariedade da aula de modelos. Para uma série observada $y_1, \dots, y_T$ com média $\bar{y}$, o estimador usual é

$$r_k = \frac{\sum_{t=k+1}^{T} (y_t - \bar{y})(y_{t-k} - \bar{y})}{\sum_{t=1}^{T} (y_t - \bar{y})^2}$$

Como a correlação de Pearson, $r_k \in [-1, 1]$. Valor próximo de $+1$ indica que valores altos são seguidos, $k$ instantes depois, por valores altos; próximo de $-1$, por valores baixos; próximo de 0, que o valor de $k$ instantes atrás não ajuda a prever linearmente o valor atual. Com dados mensais, $r_1$ compara cada mês com o anterior e $r_{12}$ compara cada mês com o mesmo mês do ano anterior. O cálculo de $r_0, \dots, r_K$ custa $O(TK)$ pela fórmula direta, ou $O(T \log T)$ por transformada rápida de Fourier.

A **função de autocorrelação** (*autocorrelation function*, ACF) é a sequência $r_k$ em função de $k$, e o gráfico dela é o **correlograma**. O valor em $k = 0$ é sempre 1 e não carrega informação.

### Ruído branco e intervalo de confiança

O **ruído branco** (*white noise*) é a série $\varepsilon_t$ de média zero, variância constante $\sigma^2$ e $\operatorname{Cov}(\varepsilon_t, \varepsilon_{t-k}) = 0$ para todo $k \neq 0$. É a série sem nenhuma estrutura linear a explorar, e é o que se espera dos resíduos de um modelo que capturou toda a dependência temporal.

Mesmo num ruído branco, os $r_k$ amostrais não são exatamente zero. Para decidir se uma autocorrelação é significativa, o correlograma traz uma faixa de confiança de 95%. Sob a hipótese de que $\rho_j = 0$ para $j \geq k$, a variância de $r_k$ é aproximada pela fórmula de Bartlett (BARTLETT, 1946):

$$\operatorname{Var}(r_k) \approx \frac{1}{T}\left(1 + 2\sum_{j=1}^{k-1} r_j^2\right), \qquad \text{faixa: } \pm 1{,}96\sqrt{\operatorname{Var}(r_k)}$$

A faixa se alarga à medida que $k$ cresce, porque acumula as autocorrelações dos lags anteriores. Para ruído branco, todos os $r_j$ são próximos de zero e a faixa se reduz a $\pm 1{,}96/\sqrt{T}$.

Barras fora da faixa indicam autocorrelação estatisticamente significativa naquele lag. Como cada lag é um teste ao nível de 5%, cerca de 1 barra em 20 sai da faixa por acaso numa série sem estrutura — o problema das comparações múltiplas. Uma barra isolada, num lag sem significado para o domínio, não deve ser interpretada como padrão.

O mesmo número de observações limita o lag até o qual a ACF é confiável: $r_k$ é calculado com $T - k$ pares, e para $k$ próximo de $T$ restam poucos pares. A recomendação de Box e Jenkins é calcular a ACF até no máximo $T/4$ (BOX et al., 2015).

### Assinaturas no correlograma

| ACF observada | Interpretação usual |
|---|---|
| Valores altos com **decaimento lento** | Tendência; série não estacionária |
| **Picos** em $k = s, 2s, 3s, \dots$ | Sazonalidade de período $s$ |
| Queda **rápida** para dentro da faixa | Série estacionária, dependência de curto prazo |
| Sinais **alternados** (+, −, +, −) | Comportamento oscilatório |
| Praticamente tudo **dentro** da faixa | Ruído branco |

A tendência produz decaimento lento porque, numa série que cresce, qualquer observação é próxima das vizinhas simplesmente por estar no mesmo patamar. Esse efeito domina o correlograma e esconde os demais padrões, o que motiva remover a tendência antes de analisar a autocorrelação.

### Remoção da tendência e da sazonalidade

Três transformações, desenvolvidas como ferramentas de modelagem na nota sobre médias móveis e estacionariedade, servem aqui como instrumentos de diagnóstico:

- **logaritmo**, $\log y_t$: estabiliza a variância que cresce com o nível e converte sazonalidade multiplicativa em aditiva;
- **diferenciação**, $\nabla y_t = y_t - y_{t-1}$: substitui o nível pela variação entre instantes consecutivos, e remove tendência linear;
- **diferenciação sazonal**, $\nabla_s y_t = y_t - y_{t-s}$: substitui o valor pela variação em relação ao mesmo instante do período anterior, e remove a sazonalidade.

### Autocorrelação parcial

A **autocorrelação parcial de defasagem $k$**, $\phi_{kk}$, é a correlação entre $y_t$ e $y_{t-k}$ **após remover o efeito linear de $y_{t-1}, \dots, y_{t-k+1}$**. Equivalentemente, é o último coeficiente da regressão de $y_t$ sobre seus $k$ valores anteriores:

$$y_t = \phi_{k1} y_{t-1} + \phi_{k2} y_{t-2} + \cdots + \phi_{kk} y_{t-k} + e_t$$

A diferença em relação à ACF é a dependência indireta. Se $y_t$ depende só de $y_{t-1}$, e $y_{t-1}$ depende de $y_{t-2}$, então $y_t$ e $y_{t-2}$ são correlacionados "por tabela": a ACF no lag 2 é alta, mas a PACF no lag 2 é próxima de zero, porque o efeito de $y_{t-2}$ passa inteiramente por $y_{t-1}$.

Os $\phi_{kk}$ são obtidos dos $r_k$ pela recursão de Durbin-Levinson (DURBIN, 1960), sem resolver uma regressão por lag:

```text
φ_11 = r_1
para k = 2 .. K:
    φ_kk = (r_k − Σ_{j=1}^{k−1} φ_{k−1,j} · r_{k−j}) / (1 − Σ_{j=1}^{k−1} φ_{k−1,j} · r_j)
    φ_kj = φ_{k−1,j} − φ_kk · φ_{k−1,k−j}     para j = 1 .. k−1
```

Cada passo custa $O(k)$, e o total até o lag $K$ custa $O(K^2)$. A faixa de 95% da PACF é $\pm 1{,}96/\sqrt{T}$. O uso da PACF para escolher a ordem de um modelo autorregressivo é tratado na nota sobre a família ARIMA da aula de modelos.

## Exemplos

O notebook `codigo/analise-serie-temporal.ipynb` implementa a ACF, a PACF e as faixas de confiança diretamente com NumPy, pelas fórmulas acima, e as aplica à série de passageiros aéreos ($T = 144$). Os valores citados a seguir são os impressos pelo notebook.

### Série original

A ACF tem $r_1 = 0{,}95$, $r_6 = 0{,}68$, $r_{12} = 0{,}76$, $r_{18} = 0{,}47$ e $r_{24} = 0{,}53$. Dois padrões se sobrepõem:

- **decaimento lento**: mesmo após dois anos, a autocorrelação está em torno de 0,5. É a assinatura da tendência; a série não é estacionária;
- **ondulação de período 12**: a curva desce até os lags 6 a 8, volta a subir no 12, desce no 18 e sobe no 24. O lag 6 compara meses opostos do ciclo anual (julho com janeiro), e por isso é mais baixo que o 12.

### Após logaritmo e diferenciação

```python
serie_log_diff = np.log(df["#Passengers"]).diff().dropna()
```

O decaimento lento desaparece, e os picos sazonais passam a dominar: $r_{12} = 0{,}84$ e $r_{24} = 0{,}74$. Os lags 4 e 8 ficam negativos ($-0{,}32$ e $-0{,}34$), refletindo a forma do ciclo dentro do ano, em que meses de alta são seguidos por meses de queda.

### Após diferenciação sazonal

```python
serie_estacionaria = np.log(df["#Passengers"]).diff().diff(12).dropna()
```

Quase todas as barras da ACF ficam dentro da faixa. Restam os lags 1 e 12, ambos negativos (cerca de $-0{,}34$ e $-0{,}39$). Esse padrão — cortes isolados em 1 e em $s$ — é o do modelo que Box e Jenkins propuseram para esta série, o *airline model*, apresentado na nota sobre a família ARIMA.

| Etapa | ACF | Conclusão |
|---|---|---|
| Série original | Alta, decaimento lento, ondulação de período 12 | Tendência e sazonalidade anual |
| Log + diferença | Picos em 12 e 24 | Tendência removida; sazonalidade evidente |
| Log + diferença + diferença sazonal | Quase tudo na faixa; lags 1 e 12 negativos | Série aproximadamente estacionária |

### Resíduos da decomposição

A ACF dos resíduos da decomposição multiplicativa feita pelo Prophet (nota sobre decomposição) mostra que tendência e sazonalidade foram capturadas: não há decaimento lento, e $r_{12} = 0{,}20$ fica dentro da faixa. Os primeiros lags, porém, continuam significativos: $r_1 = 0{,}59$ e $r_2 = 0{,}37$. Quando a série fica acima do ajuste num mês, tende a ficar acima no mês seguinte.

A causa está no formato do modelo: o Prophet descreve $y$ como função do tempo e não usa o valor do mês anterior para explicar o atual. Desvios de curto prazo que persistem por alguns meses ficam, por isso, nos resíduos. Os modelos autorregressivos da aula de modelos tratam exatamente essa dependência.

### Consequências e limites

A ACF mede apenas dependência **linear**: uma série com $r_k \approx 0$ em todos os lags pode ainda ter dependência não linear. Além disso, a ACF de uma série com tendência é dominada por ela, e só é interpretável depois da transformação adequada. A leitura do correlograma é sempre feita em conjunto com o gráfico da série e com a decomposição.

## Fontes e leituras

- BARTLETT, M. S. On the theoretical specification and sampling properties of autocorrelated time-series. **Supplement to the Journal of the Royal Statistical Society**, v. 8, n. 1, p. 27-41, 1946.
- BOX, G. E. P.; JENKINS, G. M.; REINSEL, G. C.; LJUNG, G. M. **Time series analysis**: forecasting and control. 5. ed. Hoboken: Wiley, 2015.
- DURBIN, J. The fitting of time-series models. **Revue de l'Institut International de Statistique**, v. 28, n. 3, p. 233-244, 1960.
- HYNDMAN, R. J.; ATHANASOPOULOS, G. **Forecasting**: principles and practice. 3. ed. Melbourne: OTexts, 2021. Cap. 2 e 9. Disponível em: https://otexts.com/fpp3/. Acesso em: 24 out. 2026.
