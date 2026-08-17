# Aula 02 — Banco de dados de documentos (MongoDB)
# Parte 1: consultas
#
# Rode o 00-insercao.py antes deste arquivo.
#
# Documentação:
#   https://www.mongodb.com/docs/manual/tutorial/query-documents/
#   https://www.mongodb.com/docs/manual/tutorial/query-arrays/
#   https://www.mongodb.com/docs/manual/tutorial/query-array-of-documents/

from pymongo import MongoClient

MONGO_URL = "mongodb://localhost:27017"

client = MongoClient(MONGO_URL)
db = client["aula02"]

# ---------------------------------------------------------------------------
# Consulta com duas condições: o filtro é um dicionário, e cada chave a mais
# é um AND implícito.
# ---------------------------------------------------------------------------
print("\n##### preço >= 7000 E tipo shorts #####")
match = {"preco": {"$gte": 7000}, "tipo": "shorts"}
# experimente também:
# match = {"tipo": "shorts", "tamanhos": "M"}
# match = {"outros.estilo": "passeio"}

for produto in db.produtos.find(match):
    print(produto)

# ---------------------------------------------------------------------------
# Um item só: find_one devolve o documento (ou None), não um cursor.
# ---------------------------------------------------------------------------
print("\n##### buscando por um item #####")
match = {"nome": "Shorts praia"}

print(db.produtos.find_one(match))

# ---------------------------------------------------------------------------
# Vários itens: find devolve um cursor, que você percorre.
# ---------------------------------------------------------------------------
print("\n##### buscando vários itens #####")
match = {"tipo": "shorts"}

for produto in db.produtos.find(match):
    print(produto)

# ---------------------------------------------------------------------------
# $in: o campo vale qualquer um dos valores da lista.
# ---------------------------------------------------------------------------
print("\n##### buscando vários conteúdos #####")
match = {"tipo": {"$in": ["shorts", "camiseta"]}}

for produto in db.produtos.find(match):
    print(produto)

# ---------------------------------------------------------------------------
# $or: para OR entre condições diferentes, já que chaves repetidas no
# dicionário seriam AND.
# ---------------------------------------------------------------------------
print("\n##### busca OR #####")
match = {"$or": [{"tipo": "shorts"}, {"preco": {"$gte": 10000}}]}

for produto in db.produtos.find(match):
    print(produto)

# ---------------------------------------------------------------------------
# Buscando dentro de arrays.
#
# Aqui está a diferença que mais confunde: comparar com a lista inteira exige
# os mesmos elementos, na mesma ordem e na mesma quantidade. Já comparar com
# um valor solto ({"cores": "azul"}) casa se o array contiver aquele valor.
# ---------------------------------------------------------------------------
print("\n##### busca em array em ordem direta e quantidade exata #####")
match = {"cores": ["azul"]}

for produto in db.produtos.find(match):
    print(produto)

print("\n##### busca em array com pelo menos estes itens #####")
match = {"cores": {"$all": ["branco", "verde"]}}

for produto in db.produtos.find(match):
    print(produto)

print("\n##### busca em array com exatamente 2 elementos #####")
match = {"cores": {"$size": 2}}

for produto in db.produtos.find(match):
    print(produto)

# ---------------------------------------------------------------------------
# Buscando em array de objetos.
#
# Mesma lógica: o objeto inteiro tem que ser idêntico, campo por campo. Para
# casar por um campo só, use $elemMatch — que garante que as condições valem
# para o MESMO elemento do array.
# ---------------------------------------------------------------------------
print("\n##### array de objetos — item exato #####")
match = {"estoque": {"tamanho": "30", "quantidade": 5}}

for produto in db.produtos.find(match):
    print(produto)

print("\n##### array de objetos — item inexato ($elemMatch) #####")
match = {"estoque": {"$elemMatch": {"tamanho": "30"}}}

for produto in db.produtos.find(match):
    print(produto)

# Sem $elemMatch, a notação de ponto testa o campo em QUALQUER elemento do
# array — as condições podem ser satisfeitas por elementos diferentes.
print("\n##### array de objetos — condição por notação de ponto #####")
match = {"estoque.quantidade": {"$gte": 5}}

for produto in db.produtos.find(match):
    print(produto)

print("\nRode agora o 02-aggregation-framework.py")
