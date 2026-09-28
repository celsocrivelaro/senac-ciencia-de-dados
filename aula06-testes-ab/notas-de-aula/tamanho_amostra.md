Planejar **tamanho de amostra** (sample size) em teste A/B é decidir **quantos usuários por grupo** você precisa para detectar um efeito real com risco de erro controlado. Aqui vai um guia direto ao ponto, com receitas e exemplo numérico.

Para definir um tamanho de uma amostra, precisamos de fazer uma “Análise de Potência Estatística” ou “Análise de Poder”

Este é um método utilizado para determinar o tamanho da amostra necessário em um estudo para detectar um efeito de um determinado tamanho, com um determinado nível de confiança. A análise de poder é uma ferramenta importante em pesquisa estatística para ajudar a evitar o erro Tipo II, que ocorre quando um teste falha em rejeitar uma hipótese nula que é realmente falsa.

Aqui estão os principais componentes que você precisa para realizar uma análise de poder:

1. **Alfa (α)**: Este é o nível de significância que você está disposto a aceitar, geralmente 0,05.
2. **MDE** (mínimo efeito detectável): o menor ganho que vale a pena detectar.
    1. Pode ser **absoluto** (ex.: +0,5 p.p. na conversão) ou **relativo** (ex.: +5%).
3. **Beta (β)**: Este é o erro Tipo II que você está disposto a aceitar. A potência do teste é 1 - β. 
    1. probabilidade de detectar o MDE se ele for real;
    

## **Como definir o MDE**

### **1. O que é o MDE?**

- É a **menor diferença entre controle e tratamento que faz sentido para o negócio detectar**.
- Se a mudança real for menor que o MDE, o teste pode não ter poder estatístico suficiente para detectá-la.
- Se for maior, o teste provavelmente conseguirá captar.

Exemplo: Se a taxa de conversão atual é **5%**, você pode definir que só vale a pena rodar um teste se a mudança esperada for pelo menos **+0,5 p.p. (para 5,5%)**, ou seja, **MDE = 0,5 p.p. = 10% relativo**.

---

### **2. Critérios para escolher o MDE**

### **a) Relevância de negócio**

- Pergunte: *“Qual é o menor aumento que realmente vale a pena implementar?”*
- Se um aumento pequeno não muda receita, custo ou métricas-chave, não faz sentido medir.
- Exemplo: Em um e-commerce com margem apertada, talvez apenas um aumento de 2–3% em conversão seja relevante.

### **b) Viabilidade estatística**

- Quanto menor o MDE, **maior a amostra** necessária.
- Se o tráfego é limitado, pode ser impossível medir efeitos muito pequenos.
- Exemplo: Para detectar +0,1 p.p. num site pequeno, talvez precisasse de meses de dados → inviável.

### **c) Benchmark histórico**

- Olhe resultados de testes passados: os ganhos típicos foram de 1%, 5% ou 10%?
- Use esses valores como referência para um MDE realista.

### **d) Impacto financeiro**

- Converta em dinheiro:
    - *“Se a taxa de conversão subir 0,5 p.p., isso gera +R$ X por mês?”*
    - Se sim, vale a pena definir esse valor como MDE.

---

### **3. Estratégias práticas para definir**

1. **Top-down (negócio)**: Comece pelo impacto mínimo que justifica a mudança → converta em MDE.
2. **Bottom-up (estatístico)**: Veja qual MDE é detectável com seu tráfego disponível → cheque se ainda faz sentido de negócio.
3. Ajuste se necessário:
    - Se o MDE de negócio for muito pequeno e inviável estatisticamente → teste outra métrica mais upstream (ex.: clique em vez de compra).
    - Se o MDE estatístico for muito grande → aceite que só verá efeitos mais fortes ou junte mais tráfego.

---

### **4. Exemplo prático**

- Baseline: 5% conversão.
- Tráfego disponível: 20.000 usuários/dia.
- Horizonte: 1 semana (140.000 usuários).
- Com esse tráfego, você pode detectar diferenças de **≈0,5 p.p. (MDE = 10% relativo)**.
- Então, se o negócio considera +0,5 p.p. relevante, ótimo → teste é viável.
- Se só +0,1 p.p. já seria relevante → não é viável neste tráfego.

## Poder do teste

O Beta (β) é a probabilidade de cometer um erro do Tipo II em um teste estatístico. Um erro do Tipo II ocorre quando você falha em rejeitar a hipótese nula quando ela é, de fato, falsa. Em outras palavras, um erro do Tipo II acontece quando você não detecta um efeito que realmente existe.

O poder estatístico do teste é definido como 1−*β*, e representa a probabilidade de rejeitar corretamente a hipótese nula quando ela é falsa. Assim, quanto menor o valor de *β*, maior o poder estatístico do teste.

Em termos práticos, *β* está relacionado à "sensibilidade" do seu teste. Um *β* alto (portanto, um poder estatístico baixo) sugere que seu teste não é muito sensível para detectar diferenças além do acaso, enquanto um *β* baixo (e um poder estatístico alto) indica maior sensibilidade.

Aqui estão alguns pontos importantes sobre o *β*:

1. **Valores Comuns**: Valores comuns para *β* em pesquisa são 0,2 ou 0,1, o que resulta em um poder estatístico de 0,8 ou 0,9, respectivamente.
2. **Dependência de Parâmetros**: O valor de *β* depende do tamanho do efeito que você espera encontrar, do tamanho da amostra e do nível de significância (*α*).
3. **Trade-off**: Existe um trade-off entre *α* e *β*. Se você diminuir *α* para tornar o teste mais rigoroso, *β* aumentará, reduzindo o poder estatístico do teste. Vice-versa também é verdadeiro.
4. **Cálculo**: Assim como o cálculo do tamanho da amostra, o cálculo de *β* é específico para o tipo de teste estatístico que você está usando (t-teste, ANOVA, regressão, etc.).

O que teremos:

1. **Desvio Padrão da População**: Isso é necessário para estimativas em torno da média.
2. **Tamanho da Amostra (n)**: Este é o número de observações no estudo.

**Exemplo em Python usando `statsmodels`:**

```python
from statsmodels.stats.power import TTestIndPower

# Parâmetros
effect_size = 0.8  # tamanho do efeito esperado
alpha = 0.05  # nível de significância
power = 0.8  # poder do teste

# Inicializa análise de poder
analysis = TTestIndPower()

# Calcula o tamanho da amostra
sample_size = analysis.solve_power(effect_size=effect_size, alpha=alpha, power=power)

print(f"Tamanho da amostra necessário: {round(sample_size)}")
```

Fontes:

https://github.com/renatofillinich/ab_test_guide_in_python/blob/master/AB testing with Python.ipynb