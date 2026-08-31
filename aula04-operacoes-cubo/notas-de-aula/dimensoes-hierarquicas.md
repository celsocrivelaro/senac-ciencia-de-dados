# Tabelas Dimensão Hierárquicas

## **1. Hierarquias em Dimensões**

- Uma **hierarquia** organiza atributos de uma dimensão em níveis de granularidade que podem ser navegados.
- Permite **análises em diferentes profundidades**:
    - **Drill-down**: detalhar (ex.: ver vendas por **dia** em vez de **mês**).
    - **Roll-up**: resumir (ex.: consolidar vendas de **dia** para **mês**, depois para **ano**).
- Estruturar hierarquias garante **consistência** entre agregações (totais e subtotais coerentes).

### **Exemplos clássicos:**

- **Tempo**: Ano → Trimestre → Mês → Dia
- **Produto**: Categoria → Subcategoria → Produto
- **Geografia**: País → Estado → Cidade → Bairro

---

## **2. Tipos de Hierarquias**

### **🔹 Hierarquia Equilibrada (Balanced)**

- Todos os caminhos têm o mesmo número de níveis.
- Ex.: **Ano → Trimestre → Mês → Dia**
- Útil para calendários e períodos contábeis.
- Facilita cálculos automáticos e comparações entre períodos.

---

### **🔹 Hierarquia Não Equilibrada (Unbalanced)**

- Nem todos os caminhos têm a mesma profundidade.
- Ex.: **Categoria → Subcategoria → Produto**, onde alguns produtos podem estar ligados diretamente a uma categoria, sem subcategoria.
- Mais comum em classificações de produtos ou estruturas flexíveis.
- Exige atenção para não gerar buracos ou duplicidades na agregação.

---

### **🔹 Hierarquia Recursiva**

- Estrutura em que uma entidade referencia a si mesma.
- Ex.: **Organograma** (Diretor → Gerente → Analista → Estagiário).
- Também usada em estruturas de contas contábeis, cadeias de fornecedores ou árvores de decisão.
- Permite análises por **nível de profundidade** ou **subárvore específica**.

---

## **3. Vantagens do Uso de Hierarquias**

- **Agilidade Analítica**
    
    Usuários podem “navegar” nos dados sem necessidade de escrever consultas SQL complexas.
    
- **Visão Multinível**
    
    A mesma métrica (ex.: vendas) pode ser vista no nível **macro** (ano, país) ou **micro** (dia, cidade, produto).
    
- **Consistência nos Cálculos**
    
    O cubo garante que somatórios em diferentes níveis sejam coerentes.
    
- **Tomada de Decisão Mais Informada**
    
    Gestores podem investigar rapidamente **onde** e **quando** ocorreram variações nos indicadores.
    
- **Interatividade em Ferramentas de BI**
    
    Operações como **slice**, **dice**, **drill-down** e **roll-up** ficam intuitivas para o usuário final.
    

---

## **4. Exemplos Práticos de Uso**

### **Exemplo 1 – Dimensão Tempo**

- Hierarquia: **Ano → Trimestre → Mês → Semana → Dia**
- Perguntas respondidas:
    - Qual foi o faturamento **anual** nos últimos 5 anos?
    - Como evoluiu o faturamento **mês a mês** em 2025?
    - Quais foram os **dias com maior venda** em março de 2025?

---

### **Exemplo 2 – Dimensão Produto**

- Hierarquia: **Categoria → Subcategoria → Produto**
- Perguntas respondidas:
    - Quais categorias representam maior volume de vendas?
    - Dentro da categoria **Eletrônicos**, qual subcategoria mais cresce?
    - Qual o produto mais vendido em 2025?

---

### **Exemplo 3 – Dimensão Geográfica**

- Hierarquia: **País → Estado → Cidade → Bairro**
- Perguntas respondidas:
    - Quais países geram mais receita?
    - Como as vendas se distribuem entre estados dentro do Brasil?
    - Qual bairro de São Paulo tem maior concentração de clientes ativos?

---

### **Exemplo 4 – Hierarquia Recursiva (Organização)**

- Estrutura: **CEO → Diretor → Gerente → Analista → Estagiário**
- Perguntas respondidas:
    - Qual é a performance de cada nível hierárquico?
    - Como está o desempenho agregado da equipe de um determinado gerente?
    - Onde existem gargalos ou sobrecargas de trabalho na estrutura?

---

## **5. Como a Hierarquia Vira Tabela**

As seções anteriores tratam a hierarquia como um conceito. Aqui ela vira schema.

### **Hierarquia achatada na dimensão**

A forma mais comum: **um nível por coluna**, todos na mesma tabela de dimensão.
A tabela de fatos guarda uma única FK, apontando para a linha mais detalhada.

Dimensão Tempo:

| **Data_ID** | **Dia** | **Semana** | **Mês** | **Trimestre** | **Ano** |
| --- | --- | --- | --- | --- | --- |
| 1 | 1 | 44 | 11 | 4 | 2024 |
| 2 | 2 | 44 | 11 | 4 | 2024 |
| ... | ... | ... | ... | ... | ... |

Dimensão Geografia:

| **Geo_ID** | **País** | **Estado** | **Cidade** | **Bairro** |
| --- | --- | --- | --- | --- |
| 1 | Brasil | São Paulo | São Paulo | Pinheiros |
| 2 | Brasil | Rio de Janeiro | Rio de Janeiro | Copacabana |
| ... | ... | ... | ... | ... |

E o fato referenciando as duas por FK:

| **Venda_ID** | **Produto_ID** | **Data_ID** | **Geo_ID** | **Valor_Venda** |
| --- | --- | --- | --- | --- |
| 1 | 101 | 1 | 1 | 200.00 |
| 2 | 102 | 2 | 2 | 150.00 |
| ... | ... | ... | ... | ... |

Por que essa forma é a preferida:

- **Roll-up é só trocar a coluna do `GROUP BY`** — de `Dia` para `Mês`, de
  `Cidade` para `Estado`. Nenhum join novo.
- **Desempenho**: um join só entre fato e dimensão, qualquer que seja o nível.
- **Custo**: os níveis superiores ficam repetidos em muitas linhas (todo dia de
  novembro de 2024 repete `Mês = 11`, `Ano = 2024`). Em dimensões, essa
  redundância é aceitável — dimensões são pequenas comparadas ao fato.

### **Variante normalizada (snowflake)**

Cada nível em sua própria tabela, encadeadas por FK — por exemplo `dim_marca`
apontando para `dim_pais`, em vez de guardar o país como coluna.

O trade-off inverte: elimina a redundância, mas **cada nível a mais custa um join
a mais**. Um roll-up de "País > Marca" nesse formato precisa percorrer
`fato_vendas → dim_marca → dim_pais`.

Vale conhecer as duas formas: **é o formato snowflake que o exercício desta aula
usa**, com `dim_pais` separada de `dim_marca`.

---

## **6. Conclusão**

As **dimensões hierárquicas** são fundamentais em BI porque permitem **navegação, análise detalhada e consolidação coerente de dados**.

Elas refletem a forma como a organização realmente pensa seus indicadores (tempo, produto, geografia, organização) e transformam o cubo em uma ferramenta intuitiva e poderosa para a **tomada de decisão estratégica**.