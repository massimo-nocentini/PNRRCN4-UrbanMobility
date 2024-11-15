
import sys
from networkx import erdos_renyi_graph

# getting values
nodes = int(sys.argv[1])
p = float(sys.argv[2])

G = erdos_renyi_graph (nodes, p, None, True)

for u, v in G.edges():
    print (str(u) + "\t" + str(v))
