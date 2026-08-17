# Aula 02 — Banco de dados de documentos (MongoDB)
# Parte 2: aggregation framework
#
# Rode o 00-insercao.py antes deste arquivo.
#
# O aggregation framework é uma esteira de estágios: a saída de um estágio é a
# entrada do próximo. O equivalente mental no SQL é GROUP BY + HAVING + ORDER
# BY, só que você monta a ordem dos passos.
#
# Documentação:
#   https://www.mongodb.com/docs/manual/aggregation/
#   https://www.mongodb.com/docs/manual/reference/operator/aggregation/unwind/

from pymongo import MongoClient

MONGO_URL = "mongodb://localhost:27017"

client = MongoClient(MONGO_URL)
db = client["aula02"]

# ---------------------------------------------------------------------------
# $group com _id None: agrupa TUDO num único resultado.
# "$sum": 1 conta documentos — soma 1 por documento que passou pelo estágio.
# ---------------------------------------------------------------------------
print("\n##### agregando todos os produtos #####")
group = {
    "_id": None,
    "media_preco": {"$avg": {"$round": ["$preco", 0]}},
    "total_produtos": {"$sum": 1},
}

pipeline = [{"$group": group}]

for item in db.produtos.aggregate(pipeline):
    print(item)

# ---------------------------------------------------------------------------
# $group por campo: o _id passa a ser a chave do agrupamento. O "$" antes do
# nome do campo é o que diz "o valor deste campo", não a string literal.
# ---------------------------------------------------------------------------
print("\n##### Agrupando por produto #####")
group = {
    "_id": "$tipo",
    "media_preco": {"$avg": "$preco"},
    "total_produtos": {"$sum": 1},
}

pipeline = [{"$group": group}]

for item in db.produtos.aggregate(pipeline):
    print(item)

# ---------------------------------------------------------------------------
# $match ANTES do $group: filtra os documentos que entram no agrupamento.
# É o WHERE do SQL — e é onde você quer o filtro, por ser mais barato.
# ---------------------------------------------------------------------------
print("\n##### Agrupando por filtragem #####")
group = {
    "_id": "$tipo",
    "media_preco": {"$avg": "$preco"},
    "total_produtos": {"$sum": 1},
}

match = {"tipo": "shorts"}

pipeline = [{"$match": match}, {"$group": group}]

for item in db.produtos.aggregate(pipeline):
    print(item)

# ---------------------------------------------------------------------------
# $match DEPOIS do $group: filtra os grupos já formados, pelo valor calculado.
# É o HAVING do SQL. Repare que o campo "total_produtos" só existe porque o
# estágio anterior o criou.
# ---------------------------------------------------------------------------
print("\n##### Agrupando por filtragem de agrupamento #####")
group = {
    "_id": "$tipo",
    "media_preco": {"$avg": "$preco"},
    "total_produtos": {"$sum": 1},
}

match = {"total_produtos": {"$gt": 3}}

pipeline = [{"$group": group}, {"$match": match}]

for item in db.produtos.aggregate(pipeline):
    print(item)

# ---------------------------------------------------------------------------
# $unwind: transforma um documento com array de N itens em N documentos, cada
# um com um item. É o que permite agrupar pelo conteúdo de um array — e não
# tem equivalente direto no SQL.
# ---------------------------------------------------------------------------
print("\n##### unwind #####")
match = {"nome": "Shorts praia"}

print("antes  ->", db.produtos.find_one(match))

pipeline = [{"$match": match}, {"$unwind": "$cores"}]
for item in db.produtos.aggregate(pipeline):
    print("depois ->", item)

# ---------------------------------------------------------------------------
# $unwind + $group: agora "cores" é um valor solto em cada documento, então
# dá para contar quantos produtos existem por cor.
# ---------------------------------------------------------------------------
print("\n##### contagem de itens de arrays #####")
group = {"_id": "$cores", "total_cor": {"$sum": 1}}

pipeline = [{"$unwind": "$cores"}, {"$group": group}]
for item in db.produtos.aggregate(pipeline):
    print(item)

# ---------------------------------------------------------------------------
# $sort no fim: -1 é decrescente, 1 é crescente. Sem ele, a ordem dos grupos
# que o $group devolve não é garantida.
# ---------------------------------------------------------------------------
print("\n##### ordenando itens #####")
group = {"_id": "$cores", "total_cor": {"$sum": 1}}

pipeline = [{"$unwind": "$cores"}, {"$group": group}, {"$sort": {"total_cor": -1}}]
for item in db.produtos.aggregate(pipeline):
    print(item)
