# Ciência de Dados — Aula 12: Modelos de Séries Temporais — A família ARIMA e a suavização exponencial

---

## Objetivos de aprendizagem

Ao final desta nota, espera-se que o aluno seja capaz de:

- Formular os modelos AR($p$), MA($q$) e ARMA($p, q$) e distinguir a média móvel do modelo da média móvel de suavização.
- Escrever o ARIMA($p, d, q$) e o SARIMA($p, d, q$)($P, D, Q$)$_s$ com o operador de defasagem.
- Identificar ordens candidatas pelos padrões da ACF e da PACF e validar o modelo pelo teste de Ljung-Box nos resíduos.
- Formular a suavização exponencial simples e suas extensões de Holt e de Holt-Winters.

## Desenvolvimento teórico

Os modelos desta nota descrevem $y_t$ em função do **passado da própria série** — valores e erros anteriores —, ao contrário do Prophet, que descreve $y_t$ em função do tempo. Em todos, $\varepsilon_t$ é ruído branco de variância $\sigma^2$ (nota sobre autocorrelação, na aula de análise de séries temporais).

### Operador de defasagem

O **operador de defasagem** $B$ (*backshift*) desloca a série um instante para trás: $B y_t = y_{t-1}$ e $B^k y_t = y_{t-k}$. Com ele, a diferenciação se escreve $\nabla y_t = (1 - B) y_t$, a diferenciação de ordem $d$ é $(1 - B)^d y_t$ e a diferenciação sazonal é $\nabla_s y_t = (1 - B^s) y_t$. A notação permite tratar os modelos como polinômios em $B$.

### Modelo autorregressivo — AR($p$)

No modelo **autorregressivo de ordem $p$**, o valor atual é combinação linear dos $p$ valores anteriores, mais um erro:

$$y_t = c + \phi_1 y_{t-1} + \phi_2 y_{t-2} + \cdots + \phi_p y_{t-p} + \varepsilon_t \quad\Longleftrightarrow\quad \phi(B)\, y_t = c + \varepsilon_t$$

com $\phi(B) = 1 - \phi_1 B - \cdots - \phi_p B^p$. É uma regressão linear de $y_t$ sobre suas próprias defasagens. O modelo é estacionário quando as raízes de $\phi(B) = 0$ estão fora do círculo unitário; no AR(1), isso equivale a $|\phi_1| < 1$. Com $\phi_1 = 1$ e $c = 0$, o AR(1) é o passeio aleatório, o caso de raiz unitária testado pelo ADF (nota sobre médias móveis e estacionariedade).

### Modelo de médias móveis — MA($q$)

No modelo de **médias móveis de ordem $q$** (*moving average*), o valor atual é combinação linear dos $q$ erros anteriores:

$$y_t = \mu + \varepsilon_t + \theta_1 \varepsilon_{t-1} + \cdots + \theta_q \varepsilon_{t-q} \quad\Longleftrightarrow\quad y_t = \mu + \theta(B)\, \varepsilon_t$$

com $\theta(B) = 1 + \theta_1 B + \cdots + \theta_q B^q$. Apesar do nome, o MA($q$) não é a média móvel de suavização da nota anterior: aquela é uma média das **observações**, usada para suavizar a série; esta é uma combinação dos **choques** aleatórios passados, usada para modelar como um choque se propaga. Num MA($q$), um choque afeta exatamente as $q$ observações seguintes e depois desaparece: $\rho_k = 0$ para $k > q$. Todo MA($q$) finito é estacionário.

### ARMA($p, q$)

O **ARMA($p, q$)** combina as duas partes:

$$y_t = c + \sum_{i=1}^{p} \phi_i y_{t-i} + \varepsilon_t + \sum_{j=1}^{q} \theta_j \varepsilon_{t-j} \quad\Longleftrightarrow\quad \phi(B)\, y_t = c + \theta(B)\, \varepsilon_t$$

A combinação permite representar com poucos parâmetros uma dependência que exigiria um AR ou um MA de ordem alta. O ARMA pressupõe série estacionária.

### ARIMA($p, d, q$)

O **ARIMA($p, d, q$)** (*autoregressive integrated moving average*) é o ARMA aplicado à série diferenciada $d$ vezes:

$$\phi(B)\,(1 - B)^d\, y_t = c + \theta(B)\, \varepsilon_t$$

- $p$: ordem da parte autorregressiva;
- $d$: número de diferenciações necessárias para a estacionariedade;
- $q$: ordem da parte de médias móveis.

"Integrado" refere-se à operação inversa da diferenciação: a previsão é feita para a série diferenciada e somada de volta para recuperar o nível. Casos particulares conhecidos: ARIMA(0, 1, 0) é o passeio aleatório, cuja previsão é o último valor observado; ARIMA(0, 1, 1) equivale à suavização exponencial simples.

### SARIMA($p, d, q$)($P, D, Q$)$_s$

O **SARIMA** acrescenta uma parte sazonal com a mesma estrutura, aplicada nas defasagens múltiplas do período $s$:

$$\phi(B)\, \Phi(B^s)\, (1 - B)^d\, (1 - B^s)^D\, y_t = c + \theta(B)\, \Theta(B^s)\, \varepsilon_t$$

$\Phi(B^s)$ e $\Theta(B^s)$ são polinômios de ordens $P$ e $Q$ em $B^s$, e $D$ é o número de diferenciações sazonais. Para dados mensais com sazonalidade anual, $s = 12$: $\Phi(B^{12}) = 1 - \Phi_1 B^{12}$ relaciona cada mês ao mesmo mês do ano anterior.

### Identificação, estimação e diagnóstico

A metodologia de Box e Jenkins (BOX et al., 2015) organiza o ajuste em três etapas, repetidas até o diagnóstico ser satisfatório:

```text
 +----------------+     +-----------------+     +-------------------+
 | identificação  | --> |   estimação     | --> |    diagnóstico    |
 | d, D: ADF/ACF  |     | φ, θ, Φ, Θ: MV  |     | resíduos: ACF e   |
 | p, q: ACF/PACF |     | comparação: AIC |     | Ljung-Box         |
 +----------------+     +-----------------+     +---------+---------+
         ^                                                |
         +------------- resíduos com estrutura -----------+
```

**Identificação.** As diferenciações $d$ e $D$ são escolhidas como na nota sobre estacionariedade. As ordens $p$ e $q$ vêm dos padrões teóricos da ACF e da PACF da série já estacionária:

| Modelo | ACF | PACF |
|---|---|---|
| AR($p$) | decai gradualmente | corta após o lag $p$ |
| MA($q$) | corta após o lag $q$ | decai gradualmente |
| ARMA($p, q$) | decai gradualmente | decai gradualmente |

"Corta" significa que os valores ficam dentro da faixa de confiança a partir daquele lag. Para a parte sazonal, os mesmos padrões são lidos nos lags $s, 2s, \dots$. Na prática, a identificação produz alguns candidatos, e não um modelo único.

**Estimação.** Os coeficientes são estimados por máxima verossimilhança. Entre candidatos, escolhe-se o de menor **AIC** (critério de informação de Akaike), $\text{AIC} = -2 \log L + 2k$, onde $L$ é a verossimilhança e $k$ o número de parâmetros: o termo $2k$ penaliza a complexidade.

**Diagnóstico.** Os resíduos de um modelo adequado são ruído branco. Além da inspeção da ACF dos resíduos, o **teste de Ljung-Box** (LJUNG; BOX, 1978) avalia conjuntamente os $K$ primeiros lags:

$$Q = T(T+2) \sum_{k=1}^{K} \frac{r_k^2}{T-k}$$

Sob $H_0$ (resíduos sem autocorrelação), $Q$ segue aproximadamente uma $\chi^2$ com $K - (p + q + P + Q)$ graus de liberdade. p-valor alto é compatível com ruído branco; p-valor baixo indica estrutura não capturada e devolve o processo à identificação.

### Suavização exponencial

A **suavização exponencial simples** (*simple exponential smoothing*) prevê o próximo valor como média ponderada de todas as observações, com pesos que decaem geometricamente com a idade:

$$\hat{y}_{t+1} = \alpha\, y_t + (1 - \alpha)\, \hat{y}_t = \sum_{j=0}^{t-1} \alpha (1-\alpha)^j\, y_{t-j} + (1-\alpha)^t \hat{y}_1, \qquad 0 < \alpha \le 1$$

Com $\alpha$ próximo de 1, a previsão segue as observações recentes; próximo de 0, é mais suave e lenta. A atualização custa $O(1)$ por instante, e $\alpha$ é estimado minimizando o erro de previsão um passo à frente. A previsão é constante para todo o horizonte, o que a restringe a séries sem tendência nem sazonalidade.

O **método de Holt** acrescenta uma equação de tendência $b_t$ ao nível $\ell_t$; o de **Holt-Winters** (WINTERS, 1960) acrescenta ainda um componente sazonal $s_t$. Na forma aditiva:

$$
\begin{aligned}
\ell_t &= \alpha\,(y_t - s_{t-s}) + (1-\alpha)(\ell_{t-1} + b_{t-1}) \\
b_t &= \beta\,(\ell_t - \ell_{t-1}) + (1-\beta)\, b_{t-1} \\
s_t &= \gamma\,(y_t - \ell_{t-1} - b_{t-1}) + (1-\gamma)\, s_{t-s} \\
\hat{y}_{t+h} &= \ell_t + h\, b_t + s_{t+h-s}
\end{aligned}
$$

(para $h \le s$). Cada equação é uma suavização exponencial de um componente, com seu próprio parâmetro. Na forma multiplicativa, a sazonalidade divide a observação em vez de ser subtraída, para séries cuja amplitude sazonal cresce com o nível.

## Exemplos

### O *airline model*

Para a série de passageiros, a nota sobre autocorrelação mostrou que $\nabla_{12} \nabla \log y_t$ é estacionária e tem ACF com cortes isolados nos lags 1 e 12, ambos negativos. Um corte no lag 1 indica MA(1); um corte no lag 12, MA(1) sazonal. O modelo resultante é o SARIMA(0, 1, 1)(0, 1, 1)$_{12}$ sobre $\log y_t$, proposto por Box e Jenkins para esta série e conhecido como *airline model*:

$$(1 - B)(1 - B^{12}) \log y_t = (1 + \theta_1 B)(1 + \Theta_1 B^{12})\, \varepsilon_t$$

Com `statsmodels`, ajustado aos dados de 1949 a 1958:

```python
from statsmodels.tsa.statespace.sarimax import SARIMAX
from statsmodels.stats.diagnostic import acorr_ljungbox

modelo = SARIMAX(np.log(treino), order=(0, 1, 1), seasonal_order=(0, 1, 1, 12)).fit(disp=False, method="powell")
acorr_ljungbox(modelo.resid[13:], lags=[12])
```

O otimizador padrão (L-BFGS) emite aviso de não convergência nesta série; com `method="powell"` o ajuste converge, nos mesmos coeficientes. Os coeficientes estimados são $\hat{\theta}_1 = -0{,}342$ e $\hat{\Theta}_1 = -0{,}540$; ajustados à série completa, de 1949 a 1960, são $-0{,}402$ e $-0{,}557$. O teste de Ljung-Box com 12 lags nos resíduos dá p-valor 0,912 (medido com `statsmodels` 0.14.4): não há evidência de autocorrelação remanescente. Os 13 primeiros resíduos são descartados porque correspondem às observações consumidas pelas duas diferenciações. A avaliação da previsão desse modelo em dados de teste está na nota sobre modelagem e avaliação.

### Consequências e limites

A família ARIMA modela dependência **linear** e supõe que a estrutura identificada no passado permanece. A identificação por ACF e PACF é clara em exemplos de livro e ambígua em muitas séries reais, o que torna a escolha de ordens um processo iterativo, apoiado em AIC e no diagnóstico dos resíduos. A suavização exponencial é mais simples de ajustar e, com tendência e sazonalidade (Holt-Winters), tem desempenho comparável em muitas séries; os modelos ETS (*error, trend, seasonal*) dão a ela a mesma base probabilística do ARIMA (HYNDMAN; ATHANASOPOULOS, 2021).

## Fontes e leituras

- BOX, G. E. P.; JENKINS, G. M.; REINSEL, G. C.; LJUNG, G. M. **Time series analysis**: forecasting and control. 5. ed. Hoboken: Wiley, 2015.
- HYNDMAN, R. J.; ATHANASOPOULOS, G. **Forecasting**: principles and practice. 3. ed. Melbourne: OTexts, 2021. Cap. 8 e 9. Disponível em: https://otexts.com/fpp3/. Acesso em: 24 out. 2026.
- LJUNG, G. M.; BOX, G. E. P. On a measure of lack of fit in time series models. **Biometrika**, v. 65, n. 2, p. 297-303, 1978.
- WINTERS, P. R. Forecasting sales by exponentially weighted moving averages. **Management Science**, v. 6, n. 3, p. 324-342, 1960.
