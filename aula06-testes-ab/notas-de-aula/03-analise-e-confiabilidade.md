# Ciência de Dados — Aula 06: Teste A/B — Análise do resultado e confiabilidade

## Introdução

A nota 01 especificou o experimento e a nota 02 o dimensionou: 8.150 usuários por grupo, coletados ao longo de quatorze dias. Esta nota trata do que se faz quando a coleta termina.

A análise em si é curta — um teste de hipótese sobre uma tabela 2×2, aplicando o ferramental da aula 05. O que a cerca não é: antes de olhar a métrica, verifica-se se o experimento funcionou; e depois de obter o p-valor, interpreta-se o resultado à luz do poder planejado. Um p-valor lido isoladamente é um número sem significado operacional.

## Objetivos de aprendizagem

- Aplicar o teste qui-quadrado a uma tabela 2×2 e interpretar o p-valor à luz do poder do teste.
- Identificar as falhas que tornam um teste A/B não confiável, ainda que o cálculo esteja correto.

## Desenvolvimento teórico

### Verificação prévia: divergência da razão de amostras

Antes de qualquer leitura da métrica principal, verifica-se se a divisão entre os grupos corresponde à planejada.

Define-se **divergência da razão de amostras** (*sample ratio mismatch*, SRM) como a diferença estatisticamente significativa entre a proporção observada de unidades em cada grupo e a proporção planejada.

Um experimento planejado como 50/50 não termina exatamente em 50/50 — há flutuação aleatória. A questão é se a divergência observada é compatível com essa flutuação. O teste é um qui-quadrado de aderência contra a proporção esperada:

```python
from scipy.stats import chisquare

observado = [8150, 7850]                 # unidades em A e em B
esperado = [sum(observado) / 2] * 2      # divisão 50/50 planejada

estatistica, p_valor = chisquare(f_obs=observado, f_exp=esperado)
print(f"qui-quadrado = {estatistica:.2f} | p-valor = {p_valor:.5f}")
```

O comportamento desse teste é contraintuitivo em volumes altos:

| Divisão observada | Proporção | qui-quadrado | p-valor | Diagnóstico |
|---|---|---|---|---|
| 8.150 × 8.150 | 50,0 / 50,0 | 0,00 | 1,00000 | divisão exata |
| 8.150 × 7.850 | 50,9 / 49,1 | 5,62 | 0,01771 | acima do limiar: não descarta |
| 8.300 × 7.700 | 51,9 / 48,1 | 22,50 | < 0,00001 | SRM — descartar |
| 8.400 × 7.600 | 52,5 / 47,5 | 40,00 | < 0,00001 | SRM — descartar |

O limiar usado para SRM é deliberadamente **mais estrito** que o α da métrica principal — tipicamente 0,001, e não 0,05. A verificação é feita em todo experimento, de modo que um limiar frouxo produziria alarmes falsos com frequência incômoda; e a consequência de um alarme é descartar o experimento inteiro, o que exige evidência forte.

Uma divisão de 51,9/48,1, que à inspeção visual parece aceitável, tem probabilidade inferior a 0,001% de ocorrer por acaso em um experimento de 16.000 unidades. Isso não é ruído: indica defeito na instrumentação — falha no sorteio, perda assimétrica de eventos, filtro aplicado a um grupo apenas, ou usuários redirecionados entre versões.

**Detectada SRM, o experimento é descartado.** A métrica principal não deve sequer ser consultada, porque a mesma falha que desbalanceou os grupos pode tê-los tornado não comparáveis (KOHAVI; TANG; XU, 2020).

### A tabela de contingência

Com o experimento validado, os dados de uma métrica binária são organizados em uma tabela 2×2, cruzando o grupo com o desfecho:

|  | Converteram | Não converteram | Total |
|---|---|---|---|
| **A (controle)** | 408 | 7.742 | 8.150 |
| **B (tratamento)** | 504 | 7.646 | 8.150 |

Taxas observadas: 5,01% em A e 6,18% em B.

### O teste qui-quadrado de independência

A hipótese nula é a de **independência** entre grupo e desfecho: pertencer a A ou a B não altera a probabilidade de converter. Sob H₀, calcula-se a frequência esperada de cada célula a partir dos totais marginais, e a estatística mede o afastamento entre observado e esperado:

$$\chi^2 = \sum_{i,j} \frac{(O_{ij} - E_{ij})^2}{E_{ij}}$$

```python
import numpy as np
from scipy.stats import chi2_contingency

# linhas: grupo A e grupo B | colunas: converteram e não converteram
observado = np.array([[408, 7742],
                      [504, 7646]])

qui2, p_valor, gl, esperado = chi2_contingency(observado, correction=False)

print(f"qui-quadrado = {qui2:.3f}")
print(f"p-valor      = {p_valor:.4f}")
print(f"graus de liberdade = {gl}")
print("frequências esperadas sob H0:")
print(esperado)
```

Resultado: χ² = 10,704, com 1 grau de liberdade, e p-valor = 0,0011.

### A correção de Yates

O parâmetro `correction` controla a **correção de continuidade de Yates**, aplicada por padrão em tabelas 2×2. Ela subtrai 0,5 de cada desvio absoluto antes de elevar ao quadrado, atenuando a estatística.

A justificativa é que o qui-quadrado é uma distribuição contínua aproximando contagens discretas. A correção torna o teste mais conservador — no caso condutor, χ² cai de 10,704 para 10,482, e o p-valor sobe de 0,0011 para 0,0012.

Com `correction=False`, o qui-quadrado em tabela 2×2 é **algebricamente equivalente ao teste z de duas proporções**. Essa equivalência é o motivo de o dimensionamento da nota 02 ter usado `NormalIndPower`: planeja-se com o teste z e analisa-se com o qui-quadrado, e os dois são o mesmo teste.

A escolha deve ser declarada e justificada. Em amostras da ordem de milhares, a diferença entre as duas versões é irrelevante para a decisão; em amostras pequenas, não é.

### Hipótese bilateral e unilateral

O qui-quadrado é construído sobre desvios **ao quadrado**. Ele detecta que observado e esperado divergem, sem informar em qual direção. Em uma tabela 2×2, isso o torna **bilateral por construção**.

Disso decorre uma restrição frequentemente violada: **não é possível testar uma hipótese direcional com `chi2_contingency`**. Uma hipótese da forma H₁: p_B > p_A exige o teste z unilateral de duas proporções, ou a divisão do p-valor bilateral por dois, acompanhada da verificação de que a diferença observada tem de fato o sinal esperado.

Declarar hipóteses unilaterais e aplicar o qui-quadrado é um erro de coerência entre o que se afirmou testar e o que se testou.

### Interpretação

Com p-valor = 0,0011 e α = 0,05, rejeita-se a hipótese nula. A diferença entre 5,01% e 6,18% não é compatível com a flutuação aleatória.

Três cuidados na leitura:

- **Rejeitar H₀ não mede o efeito.** O p-valor informa sobre a compatibilidade com o acaso, não sobre a magnitude. O efeito observado — 1,18 ponto percentual, ou +23,5% relativo — é que se compara ao MDE de 1 ponto percentual definido no planejamento. O ganho supera o limiar que justificava a mudança, ainda que por margem estreita.
- **Falhar em rejeitar H₀ não é evidência de igualdade.** A ausência de significância pode decorrer tanto da inexistência do efeito quanto da incapacidade do teste de detectá-lo.
- **O p-valor não é interpretável sem o poder.** Essa é a razão de o poder ser fixado antes da coleta, e não calculado depois.

### O caso da amostra insuficiente

Considere o mesmo experimento interrompido após meio dia, com 400 usuários por grupo:

|  | Converteram | Não converteram | Total |
|---|---|---|---|
| **A** | 20 | 380 | 400 |
| **B** | 25 | 375 | 400 |

Taxas de 5,00% e 6,25% — uma diferença **maior** que a do experimento completo. O resultado do teste: χ² = 0,589 e p-valor = 0,4429.

O p-valor é alto, e a conclusão correta é "falha em rejeitar H₀". A conclusão **incorreta**, e comum, é "não há diferença entre A e B".

O que ocorreu é que 400 observações por grupo conferem poder muito abaixo de 0,80 para um efeito dessa magnitude. O teste não tinha como detectar o efeito, ainda que ele existisse — e o planejamento da nota 02 já havia estabelecido que seriam necessários 8.150 por grupo. Esse resultado não informa nada sobre o produto; informa apenas que o experimento foi interrompido antes da hora.

### Da decisão estatística à decisão de produto

O teste produz uma decisão entre H₀ e H₁. A decisão de produto é outra, e considera o efeito observado, o custo da mudança e as métricas guarda-corpo:

| Situação | Decisão |
|---|---|
| Rejeita H₀, efeito ≥ MDE, guarda-corpo estável | Implementar |
| Rejeita H₀, efeito < MDE | Significativo e irrelevante: não implementar |
| Rejeita H₀, guarda-corpo degradada | Reavaliar: o ganho tem custo em outra dimensão |
| Falha em rejeitar, poder adequado | Efeito, se existe, é menor que o MDE: descartar a hipótese |
| Falha em rejeitar, poder inadequado | Resultado inconclusivo: nada se aprendeu |

### Outras fontes de resultado não confiável

- **Efeito de novidade e de primazia.** Usuários reagem à mudança enquanto ela é nova. Um ganho medido nos primeiros dias pode desaparecer quando o efeito de novidade se dissipa; inversamente, usuários habituados à versão antiga podem rejeitar a nova temporariamente. Ambos são argumentos para cobrir ciclos completos, e para observar a estabilidade do efeito ao longo do período.
- **Comparações múltiplas.** Testar k métricas a α = 0,05 eleva a probabilidade de ao menos um falso positivo a aproximadamente 1 − (1 − 0,05)^k. Para k = 10, isso é 40%. É a razão de existir uma métrica principal única, declarada antes da coleta.
- **Interrupção antecipada.** Tratada na nota 02: a inspeção repetida eleva o falso positivo real a 26,1% (MILLER, 2010).

### Documentação do experimento

O valor acumulado de um programa de experimentação está no registro histórico, não em cada teste isolado. O registro mínimo de um experimento contém: a hipótese, a métrica principal e as guarda-corpo, a unidade de aleatorização, o MDE, α, o poder, o n planejado, o período de coleta, o resultado do teste e a decisão tomada.

Experimentos que falharam em rejeitar H₀ são parte essencial desse acervo: eles delimitam o que não funciona, e evitam que a mesma hipótese seja retestada indefinidamente.

## Exemplos

### Análise completa do caso condutor

```python
import numpy as np
from scipy.stats import chisquare, chi2_contingency

# ── Etapa 1: verificação de SRM, antes de olhar a métrica ──────────────
unidades = [8150, 8150]
esperado_srm = [sum(unidades) / 2] * 2
_, p_srm = chisquare(f_obs=unidades, f_exp=esperado_srm)

if p_srm < 0.001:
    raise SystemExit(f"SRM detectada (p={p_srm:.5f}): experimento descartado")

# ── Etapa 2: teste sobre a métrica principal ───────────────────────────
observado = np.array([[408, 7742],    # A: converteram, não converteram
                      [504, 7646]])   # B: converteram, não converteram

qui2, p_valor, gl, esperado = chi2_contingency(observado, correction=False)

taxa_a = observado[0, 0] / observado[0].sum()
taxa_b = observado[1, 0] / observado[1].sum()

print(f"taxa A = {taxa_a:.2%} | taxa B = {taxa_b:.2%}")
print(f"efeito absoluto = {(taxa_b - taxa_a) * 100:.2f} p.p.")
print(f"efeito relativo = {(taxa_b / taxa_a - 1):.1%}")
print(f"qui-quadrado = {qui2:.3f} | p-valor = {p_valor:.4f} | gl = {gl}")

alpha = 0.05
mde_absoluto = 0.01

if p_valor < alpha and (taxa_b - taxa_a) >= mde_absoluto:
    print("Rejeita H0 e o efeito supera o MDE: implementar")
elif p_valor < alpha:
    print("Rejeita H0, mas o efeito é inferior ao MDE: não implementar")
else:
    print("Falha em rejeitar H0")
```

Saída esperada:

```
taxa A = 5.01% | taxa B = 6.18%
efeito absoluto = 1.18 p.p.
efeito relativo = 23.5%
qui-quadrado = 10.704 | p-valor = 0.0011 | gl = 1
Rejeita H0 e o efeito supera o MDE: implementar
```

A verificação de SRM precede o teste e interrompe a análise em caso de falha. Essa ordem é deliberada: consultar a métrica antes de validar o experimento cria o incentivo para racionalizar um resultado obtido de um teste quebrado.

## Fontes e leituras

- KOHAVI, R.; TANG, D.; XU, Y. **Trustworthy Online Controlled Experiments: A Practical Guide to A/B Testing**. Cambridge: Cambridge University Press, 2020.
- MILLER, E. **How Not to Run an A/B Test**. 2010. Disponível em: https://www.evanmiller.org/how-not-to-run-an-ab-test.html. Acesso em: 19 set. 2026.
- SULLIVAN, G. M.; FEINN, R. Using Effect Size — or Why the P Value Is Not Enough. **Journal of Graduate Medical Education**, v. 4, n. 3, p. 279–282, 2012. Disponível em: https://pmc.ncbi.nlm.nih.gov/articles/PMC3444174/. Acesso em: 19 set. 2026.
- SCIPY. **chi2_contingency**. Documentação do módulo `scipy.stats`. Disponível em: https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.chi2_contingency.html. Acesso em: 19 set. 2026.
