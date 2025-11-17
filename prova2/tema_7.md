# 📊 Consumo de Energia Residencial (UCI Household Electric Power Consumption)

## 📘 Descrição Detalhada do Dataset
Electricité de France coletou os dados via medidores instalados, disponibilizados pela UCI.

### 🔍 Quem extraiu os dados e como foram coletados?
Electricité de France coletou os dados via medidores instalados, disponibilizados pela UCI.

## 📁 Tipo de Dados Coletados
Potência ativa, reativa, tensão, corrente.

## 🕒 Período da Série Temporal
📆 **Início:** 2006-12-16  
📆 **Fim:** 2010-11-26

## 🔢 Tamanho Aproximado
➡️ **2.075.259 amostras**

## 🔗 Links Oficiais
- 👉 **Página oficial:** https://archive.ics.uci.edu/dataset/235/individual+household+electric+power+consumption  
- 📥 **Download direto:** https://archive.ics.uci.edu/static/public/235/individual+household+electric+power+consumption.zip

---

# ⚙️ Análises Avançadas com Algoritmos Massivos (Redis)

Além da análise de séries temporais tradicional (ARIMA, Prophet, LSTM), este trabalho também exigirá o uso de **estruturas de dados massivas otimizadas**, utilizando o **Redis**. Abaixo estão as análises adicionais que deverão ser desenvolvidas:

### 🔸 Bloom Filter — Detecção de ocorrências raras
Use um Bloom Filter para identificar rapidamente se um valor (ex.: um nível anômalo de consumo) já ocorreu na série.

### 🔸 HyperLogLog — Estimativa de cardinalidade
Use HyperLogLog para estimar o número de padrões únicos em janelas temporais.

### 🔸 MinHash — Similaridade entre janelas temporais
Compare períodos distintos da série para medir similaridade de comportamento.

### 🔸 Count-Min Sketch — Frequência aproximada de eventos
Identifique rapidamente valores mais frequentes (picos, platôs ou níveis) com espaço reduzido.

Cada algoritmo deverá ser implementado no Redis e conectado ao pipeline de análise temporal.

