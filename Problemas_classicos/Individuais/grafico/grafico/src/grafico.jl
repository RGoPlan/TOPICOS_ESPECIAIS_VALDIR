using Pkg
Pkg.activate(".")

using LightGraphs
using GraphPlot

# Criar um grafo simples
g = SimpleGraph(3)
add_edge!(g, 1, 2)
add_edge!(g, 2, 3)

# Plotar o grafo
gplot(g, nodelabel=1:nv(g))
