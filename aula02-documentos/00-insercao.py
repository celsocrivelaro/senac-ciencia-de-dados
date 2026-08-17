# Aula 02 — Banco de dados de documentos (MongoDB)
# Parte 0: conexão e inserção dos documentos
#
# Rode este arquivo primeiro: ele cria a collection "produtos" no banco
# "aula02". Os arquivos 01 e 02 consultam o que for inserido aqui.
#
# Documentação: https://www.mongodb.com/docs/manual/tutorial/insert-documents/

from pymongo import MongoClient

# O MongoDB da VM escuta só em localhost, na porta padrão e sem autenticação
# (ver /etc/mongod.conf). É a mesma URL que o Compass sugere sozinho.
MONGO_URL = "mongodb://localhost:27017"

client = MongoClient(MONGO_URL)

# banco de dados
db = client["aula02"]

# Documento => "linha" de um banco relacional.
# Note o que um documento permite e uma tabela não: listas ("tamanhos",
# "cores"), objetos aninhados ("outros") e listas de objetos ("estoque").
# Note também que nem todo documento tem os mesmos campos — só os calçados
# têm "estoque".
produtos = [
    # Calçados
    {
        "nome": "Tênis de jovem",
        "genero": "masculino",
        "preco": 10000,
        "tipo": "calçado",
        "tamanhos": ["30", "32", "34", "36", "38", "40", "41", "44"],
        "cores": ["verde", "branco"],
        "outros": {"estilo": "passeio"},
        "estoque": [
            {"tamanho": "30", "quantidade": 5},
            {"tamanho": "36", "quantidade": 2},
        ],
    },
    {
        "nome": "Sapato masculino social",
        "genero": "feminino",
        "preco": 25000,
        "tipo": "calçado",
        "tamanhos": ["36", "38", "40", "41", "44"],
        "cores": ["preto"],
        "outros": {"estilo": "social"},
        "estoque": [
            {"tamanho": "44", "quantidade": 5},
            {"tamanho": "36", "quantidade": 10},
        ],
    },
    {
        "nome": "Sapato feminino festa",
        "genero": "feminino",
        "preco": 21000,
        "tipo": "calçado",
        "tamanhos": ["30", "32", "34", "36", "38", "40"],
        "cores": ["vermelho"],
        "outros": {"estilo": "festa"},
        "estoque": [
            {"tamanho": "40", "quantidade": 5},
            {"tamanho": "30", "quantidade": 2},
        ],
    },
    # Shorts
    {
        "nome": "Shorts praia",
        "genero": "masculino",
        "preco": 6700,
        "tipo": "shorts",
        "tamanhos": ["P", "M", "G", "GG"],
        "cores": ["laranja", "azul"],
        "outros": {"estilo": "praia"},
    },
    {
        "nome": "Shorts passeio",
        "genero": "masculino",
        "preco": 7200,
        "tipo": "shorts",
        "tamanhos": ["M", "G", "GG"],
        "cores": ["preto", "verde"],
        "outros": {"estilo": "passeio"},
    },
    {
        "nome": "Shorts feminino",
        "genero": "feminino",
        "preco": 7000,
        "tipo": "shorts",
        "tamanhos": ["PP", "P", "M", "G"],
        "cores": ["roxo"],
        "outros": {"estilo": "passeio"},
    },
    # Camisas
    {
        "nome": "Camisa manga curta masc.",
        "genero": "masculino",
        "preco": 6900,
        "tipo": "camisa",
        "tamanhos": ["P", "M", "G", "GG"],
        "cores": ["azul"],
        "outros": {"manga": "curta", "estilo": "sport chic"},
    },
    {
        "nome": "Camisa manga comprida masc.",
        "genero": "masculino",
        "preco": 9800,
        "tipo": "camisa",
        "tamanhos": ["P", "M", "G", "GG"],
        "cores": ["branco"],
        "outros": {"manga": "comprida", "estilo": "social"},
    },
    {
        "nome": "Camisa manga comprida fem.",
        "genero": "feminino",
        "preco": 10000,
        "tipo": "camisa",
        "tamanhos": ["P", "M", "G", "GG"],
        "cores": ["vermelho"],
        "outros": {"manga": "comprida", "estilo": "passeio"},
    },
    {
        "nome": "Camisa manga curta fem.",
        "genero": "feminino",
        "preco": 6500,
        "tipo": "camisa",
        "tamanhos": ["P", "M", "G", "GG"],
        "cores": ["amarelo"],
        "outros": {"manga": "curta", "estilo": "passeio"},
    },
]

# collection => "tabela" de um banco relacional.
# O delete_many({}) limpa tudo antes de inserir: assim você pode rodar este
# arquivo quantas vezes quiser sem duplicar produto.
db.produtos.delete_many({})
resultado = db.produtos.insert_many(produtos)

print(f"{len(resultado.inserted_ids)} produtos inseridos no banco 'aula02'.")
print("Rode agora o 01-consulta.py")
