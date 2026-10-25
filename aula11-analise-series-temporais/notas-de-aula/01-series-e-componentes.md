# Ciência de Dados — Aula 11: Análise de Séries Temporais — Séries temporais e seus componentes

---

## Objetivos de aprendizagem

Ao final desta nota, espera-se que o aluno seja capaz de:

- Definir série temporal e distinguir o dado temporal de uma amostra de observações independentes.
- Enumerar os objetivos de uma análise de série temporal: descrição, explicação e predição.
- Identificar, no gráfico de uma série, tendência, sazonalidade, ciclo e ruído, e diferenciar sazonalidade de ciclo pelo período.

## Desenvolvimento teórico

### Série temporal

Uma **série temporal** (*time series*) é uma sequência de observações $y_1, y_2, \dots, y_T$ de uma variável, indexada pelo tempo. Quando os instantes de observação são igualmente espaçados — a cada hora, dia, mês —, a série é **regular** e o índice $t$ basta para localizar cada valor. Quando as observações ocorrem em instantes arbitrários, como transações ou acessos a um serviço, a série é **irregular** e cada valor carrega seu carimbo de tempo; é comum agregá-la em intervalos fixos (contagem por minuto, soma por dia) para tratá-la como regular.

O que distingue a série temporal de uma amostra comum é a **dependência entre observações**. Os testes de hipótese e a regressão da parte de inferência da disciplina pressupõem observações independentes, cuja ordem é irrelevante. Numa série temporal a ordem é parte do dado: $y_t$ em geral se parece com $y_{t-1}$, e permutar as observações destrói justamente a informação que a série carrega. Toda a análise desta aula consiste em descrever essa dependência.

Do ponto de vista de armazenamento, o dado temporal tem quatro propriedades que orientam os sistemas especializados (bancos de séries temporais) e também a análise:

1. as observações são **imutáveis** e apenas acrescentadas ao fim;
2. chegam, em regra, **em ordem temporal**;
3. o **tempo é o eixo primário** de consulta e de agregação;
4. o intervalo entre observações pode ser **regular** (métricas amostradas) ou **irregular** (eventos).

A **frequência** de coleta define a escala em que os padrões aparecem. Uma série de consumo de energia horária revela o ciclo diário; a mesma série agregada por mês o esconde e revela o ciclo anual.

### Objetivos da análise

A análise de uma série temporal serve a três propósitos, em ordem crescente de exigência sobre o modelo:

| Objetivo | Pergunta que responde | Exemplo |
|---|---|---|
| **Descrição** | Que padrões a série tem, e qual o efeito de um evento único? | Queda de vendas durante uma greve de transporte |
| **Explicação** | Que variáveis causam as variações da série? | Efeito da temperatura sobre o consumo de energia |
| **Predição** | Que valores a série assumirá no futuro? | Demanda de passageiros do próximo ano |

A descrição é pré-requisito das outras duas. Prever sem saber se a série tem tendência ou sazonalidade leva a escolher o modelo errado, como mostra a nota sobre modelagem e avaliação na aula de modelos de séries temporais.

### Componentes de uma série temporal

A análise clássica trata a série como a combinação de quatro componentes:

- **Tendência** ($T_t$): movimento de longo prazo do nível da série — crescente, decrescente ou estável. Não precisa ser linear; basta que varie lentamente em relação aos demais componentes.
- **Sazonalidade** ($S_t$): padrão que se repete com **período fixo e conhecido** $s$, ligado ao calendário — $s = 24$ em dados horários com ciclo diário, $s = 7$ em dados diários com ciclo semanal, $s = 12$ em dados mensais com ciclo anual.
- **Ciclo** ($C_t$): flutuação de subida e descida **sem período fixo**, em geral mais longa que a sazonalidade. O exemplo típico são os ciclos econômicos de expansão e recessão, cuja duração varia de alguns anos a uma década.
- **Ruído** ($R_t$): variação residual, sem padrão, que resta após a remoção dos demais componentes.

A distinção entre sazonalidade e ciclo está no período: fixo e determinado pelo calendário na primeira, variável no segundo. Um pico de vendas que ocorre todo dezembro é sazonal; um período de vendas altas que dura entre três e cinco anos é cíclico. Como o período do ciclo é desconhecido, os métodos de decomposição não conseguem isolá-lo da tendência, e o tratam como parte dela: o componente estimado passa a se chamar **tendência-ciclo** (HYNDMAN; ATHANASOPOULOS, 2021).

```text
 y_t
  |                                        /\        /\
  |                          /\           /  \      /  \     tendência
  |             /\          /  \    /\   /    \    /    \    crescente +
  |   /\       /  \   /\   /    \  /  \_/      \__/      \   sazonalidade
  |  /  \  /\_/    \_/  \_/      \/                         de período s
  | /    \/
  +--------------------------------------------------------------> t
     |<-- s -->|<-- s -->|
```

## Exemplos

### Séries por domínio

| Domínio | Série | Componentes predominantes |
|---|---|---|
| Finanças | Preço diário de ações, taxa de câmbio | Tendência e ruído elevado; quase nenhuma sazonalidade |
| Comércio | Vendas diárias de um produto | Tendência, sazonalidade semanal e anual, picos em datas comerciais |
| Clima | Temperatura diária | Sazonalidade anual forte; tendência de longo prazo pequena |
| Saúde | Casos semanais de gripe | Sazonalidade anual com amplitude variável entre surtos |
| Energia | Consumo horário | Sazonalidade diária, semanal e anual sobrepostas |
| Demografia | Taxa anual de nascimento | Tendência de longo prazo; sem sazonalidade na escala anual |

### Passageiros aéreos, 1949–1960

A série `AirPassengers`, analisada por Box e Jenkins (BOX et al., 2015) e usada no notebook `codigo/analise-serie-temporal.ipynb`, registra o total mensal de passageiros de linhas aéreas internacionais, em milhares, de janeiro de 1949 a dezembro de 1960 ($T = 144$). O gráfico da série mostra três propriedades:

- **tendência crescente**: a média anual sobe de 127 mil passageiros por mês em 1949 para 476 mil em 1960;
- **sazonalidade anual**: picos em julho e agosto, vales em novembro e fevereiro, todos os anos;
- **amplitude crescente**: o desvio padrão dentro de cada ano sobe de 13,7 em 1949 para 77,7 em 1960, quase na mesma proporção da média.

A terceira propriedade é a que decide o modelo de decomposição, tratado na nota seguinte.

### Consequências e limites

A decomposição em quatro componentes é um modelo, não uma propriedade da série. Séries financeiras de alta frequência, por exemplo, quase não têm tendência nem sazonalidade identificáveis, e o que nelas parece padrão costuma ser ruído. A inspeção do gráfico é sempre o primeiro passo, mas a confirmação de que um padrão existe exige as ferramentas quantitativas das notas sobre decomposição e autocorrelação.

## Fontes e leituras

- BOX, G. E. P.; JENKINS, G. M.; REINSEL, G. C.; LJUNG, G. M. **Time series analysis**: forecasting and control. 5. ed. Hoboken: Wiley, 2015.
- HYNDMAN, R. J.; ATHANASOPOULOS, G. **Forecasting**: principles and practice. 3. ed. Melbourne: OTexts, 2021. Cap. 2 e 3. Disponível em: https://otexts.com/fpp3/. Acesso em: 24 out. 2026.
