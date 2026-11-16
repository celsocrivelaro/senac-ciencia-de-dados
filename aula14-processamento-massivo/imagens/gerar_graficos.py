"""Gera os gráficos dos slides a partir das medições dos notebooks, guardadas em ../dados/."""
import csv
import os

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

pasta = os.path.dirname(os.path.abspath(__file__))
dados = os.path.join(pasta, "..", "dados")
plt.rcParams.update({"font.size": 13, "axes.titlesize": 14})

def ler(nome):
    with open(os.path.join(dados, nome), encoding="utf-8") as arquivo:
        return list(csv.DictReader(arquivo))

linhas = ler("bloom-falso-positivo.csv")
x = [int(l["bits_por_item"]) for l in linhas]
plt.figure(figsize=(8, 4.5))
plt.semilogy(x, [float(l["taxa_prevista_pct"]) for l in linhas], "o-", label="prevista: (1 - e^(-kn/m))^k")
plt.semilogy(x, [float(l["taxa_medida_pct"]) for l in linhas], "s--", label="medida (100.000 números)")
plt.xlabel("bits por item (m / n)")
plt.ylabel("falso positivo (%)")
plt.grid(True, which="both", alpha=0.3)
plt.legend()
plt.tight_layout()
plt.savefig(os.path.join(pasta, "a14-bloom-falso-positivo.png"), dpi=150)
plt.close()

linhas = ler("hll-erro-por-p.csv")
x = [int(l["p"]) for l in linhas]
plt.figure(figsize=(8, 4.5))
plt.plot(x, [float(l["previsto_pct"]) for l in linhas], "o-", label="previsto: 1,04 / sqrt(m)")
plt.plot(x, [float(l["desvio_medido_pct"]) for l in linhas], "s--", label="medido (10 repetições, n = 100.000)")
plt.xlabel("p   (m = 2^p registradores)")
plt.ylabel("erro padrão relativo (%)")
plt.grid(True, alpha=0.3)
plt.legend()
plt.tight_layout()
plt.savefig(os.path.join(pasta, "a14-hll-erro.png"), dpi=150)
plt.close()

linhas = ler("minhash-erro-por-k.csv")
x = [int(l["k"]) for l in linhas]
plt.figure(figsize=(8, 4.5))
plt.plot(x, [float(l["previsto"]) for l in linhas], "o-", label="previsto: sqrt(J(1-J)/k)")
plt.plot(x, [float(l["desvio_medido"]) for l in linhas], "s--", label="medido (10 sorteios, J = 0,25)")
plt.xscale("log")
plt.xlabel("k (funções de hash)")
plt.ylabel("erro padrão de J estimado")
plt.grid(True, which="both", alpha=0.3)
plt.legend()
plt.tight_layout()
plt.savefig(os.path.join(pasta, "a14-minhash-erro.png"), dpi=150)
plt.close()

linhas = ler("memoria-caso-condutor.csv")
nomes = [l["estrutura"] for l in linhas]
valores = [int(l["bytes"]) for l in linhas]
cores = ["#888888"] + ["#2e75b6"] * (len(linhas) - 1)
plt.figure(figsize=(9, 4.8))
plt.barh(nomes[::-1], valores[::-1], color=cores[::-1])
plt.xscale("log")
for i, v in enumerate(valores[::-1]):
    if v >= 1e9:
        rotulo = f"{v / 1e9:.0f} GB" if v >= 1e10 else f"{v / 1e9:.1f} GB"
    elif v >= 1e6:
        rotulo = f"{v / 1e6:.0f} MB"
    else:
        rotulo = f"{v / 1024:.1f} KB"
    plt.text(v * 1.4, i, rotulo.replace(".", ","), va="center")
plt.xlim(1e3, 1e12)
plt.xlabel("memória (bytes, escala log) — estimativa para 5·10^9 números")
plt.tight_layout()
plt.savefig(os.path.join(pasta, "a14-memoria.png"), dpi=150)
plt.close()
print("ok")
