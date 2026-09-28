## **1. O que é um teste A/B?**

- **Definição**: Técnica de experimentação usada para comparar duas (ou mais) versões de algo (ex.: página da web, campanha de e-mail, aplicativo) para medir qual gera melhores resultados.
- **Objetivo**: Tomar decisões baseadas em dados em vez de opiniões.
- **Funcionamento**:
    - Dividimos a audiência em **grupos aleatórios**:
        - Grupo **A** → versão de controle (atual).
        - Grupo **B** → versão de tratamento (alterada).
    - Medimos a diferença de desempenho em relação a uma **métrica de interesse** (ex.: taxa de cliques, conversão, tempo de uso).

---

## **2. Onde usamos testes A/B?**

- **Produtos digitais**:
    - Layouts de sites e apps.
    - Textos de botões (“Compre agora” vs. “Saiba mais”).
    - Fluxos de cadastro ou checkout.
- **Marketing**:
    - Assunto de e-mails.
    - Estratégias de remarketing.
    - Peças publicitárias diferentes.
- **Engenharia de produto**:
    - Algoritmos de recomendação.
    - Novos recursos liberados gradualmente.

## **3. Exemplos de Testes A/B**

### **1. Exemplo em Produto Digital – Página de Cadastro**

- **Hipótese**: “Reduzir o número de campos no formulário de cadastro aumentará a taxa de conclusão.”
- **Versão A (Controle)**: Formulário com 8 campos obrigatórios.
- **Versão B (Tratamento)**: Formulário com 4 campos obrigatórios (informações adicionais pedidas depois).
- **Métrica principal**: Taxa de conclusão do cadastro.
- **Resultado esperado**: Se B for significativamente melhor, implementar o formulário simplificado.

---

### **2. Exemplo em Marketing – Campanha de E-mail**

- **Hipótese**: “Um assunto de e-mail mais direto aumentará a taxa de abertura.”
- **Versão A**: Assunto: “Não perca nossa promoção especial desta semana!”
- **Versão B**: Assunto: “30% de desconto só até sexta-feira”
- **Métrica principal**: Taxa de abertura de e-mail.
- **Resultado esperado**: Escolher o assunto com maior abertura e aplicá-lo em campanhas futuras.

---

### **3. Exemplo em Design de Interface – Botão de Call-to-Action**

- **Hipótese**: “Alterar a cor e o texto do botão aumentará os cliques.”
- **Versão A (Controle)**: Botão azul com texto “Saiba mais”.
- **Versão B (Tratamento)**: Botão verde com texto “Comece agora”.
- **Métrica principal**: CTR (Click-Through Rate).
- **Resultado esperado**: Se B tiver aumento significativo de CTR, implementar como padrão.

---

### **4. Exemplo em Algoritmos – Recomendação de Produtos**

- **Hipótese**: “Um novo algoritmo de recomendação aumentará a receita média por usuário.”
- **Versão A**: Algoritmo atual de recomendação.
- **Versão B**: Algoritmo experimental com personalização mais sofisticada.
- **Métrica principal**: Receita média por usuário (ARPU).
- **Resultado esperado**: Se B gerar aumento relevante e consistente, migrar gradualmente toda a base para o novo algoritmo.

---

### **5. Exemplo em Retenção – Notificações Push**

- **Hipótese**: “Enviar notificações mais curtas e personalizadas aumentará a taxa de retorno diário.”
- **Versão A**: Notificação genérica (“Volte e veja as novidades de hoje!”).
- **Versão B**: Notificação personalizada (“João, temos 3 novos artigos sobre tecnologia para você!”).
- **Métrica principal**: DAU (Daily Active Users).
- **Resultado esperado**: Se B aumentar o DAU, manter estratégia personalizada.

---

### **6. Conclusão**

- Cada teste deve partir de uma **hipótese clara** e uma **métrica bem definida**.
- O ganho vem não apenas em validar mudanças, mas em **acumular aprendizado** sobre usuários e negócios.
- Bons testes A/B devem ser documentados para formar um **histórico de conhecimento**.

---

## **4. Como projetar um teste A/B?**

### **a) Definição do objetivo**

- **Pergunta clara**: “Essa mudança aumenta a taxa de conversão?”
- **Hipótese**: “Mudar a cor do botão de azul para verde aumentará os cliques em 5%.”

### **b) Escolha da métrica principal**

- Deve estar diretamente ligada ao objetivo do negócio.
- Exemplo: cliques no botão, vendas, retenção, tempo médio de sessão.

### **c) Aleatorização e segmentação**

- Divisão **aleatória** dos usuários entre A e B.
- Importante manter **grupos homogêneos** e evitar viés (ex.: não colocar só usuários novos em B).

### **d) Tamanho da amostra**

- Usar **cálculo de poder estatístico** para garantir:
    - Número suficiente de usuários para detectar diferenças reais.
    - Evitar testes muito pequenos (pode dar “falsos positivos/negativos”).

### **e) Duração do teste**

- Deve cobrir ciclos completos de uso (ex.: pelo menos 1 semana se há sazonalidade diária).
- Não encerrar antes do tempo, mesmo que os resultados pareçam “claros” cedo demais.

### **f) Análise estatística**

- Usar testes de hipóteses (ex.: teste t, qui-quadrado) ou intervalos de confiança.
- Definir **nível de significância (α)**, geralmente 5%.
- Verificar também **tamanho do efeito** (não apenas se é “estatisticamente significativo”).

### **g) Interpretação e decisão**

- Se B foi significativamente melhor → considerar implementar.
- Se não houve diferença → manter A ou testar outra hipótese.
- Documentar resultados para aprendizado organizacional.