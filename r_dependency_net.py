#!/usr/bin/env python
# encoding: utf-8
"""
r_dependency_net.py

Purpose:  Analyze the dependency network of R libraries
            and output as GraphML file with centrality 
            node attributes.
            
            Also do some basic visualization.

Author:   Drew Conway
Email:    drew.conway@nyu.edu
Date:     2010-08-26

Copyright (c) 2010, under the Simplified BSD License.  
For more information on FreeBSD see: http://www.opensource.org/licenses/bsd-license.php
All rights reserved.
"""

import sys
import os
import networkx as nx
import pygraphviz as pgv
import matplotlib.pylab as plt
from datetime import datetime
import time

def multiple_measures(g,function_list):
    """Applies a list of NX centrality measures to a graph object,
    then adds data to each node in g as attibutes."""
    measures=map(lambda f: f(g), function_list)
    measures_dict=dict(zip(function_list,measures))
    # Add measures of node v to graph g as NX node attributes
    for v in g.nodes_iter():
        v_measures=dict([(str(a).split(" ")[1],b[v]) for (a,b) in measures_dict.items()])
        g.add_node(v,v_measures)

def time_from_today(d, format="%Y-%m-%d"):
    """Measures the time between now and a given date string in miliseconds"""
    diff=datetime.today()-datetime.strptime(d.strip('"'),format)
    return diff.days
    
def normalize_weights(g):
    """Takes weighted graph and normalizes weights to integers starting at 1"""
    weights=[]
    # Create map from current edge weights to normalized
    for e in g.edges_iter(data=True):
        w=e[2]["weight"]
        if weights.count(w)<1:
            weights.append(w)
    weights.sort()
    weight_map=dict(zip(weights,range(1,len(weights)+1)))
    # Normalize edges
    for e in g.edges_iter(data=True):
        g.add_edge(e[0],e[1],weight=weight_map[e[2]["weight"]])

def main():
    """
    Pre-processing: 
        load data, compute centrality measures, write files with node data
    """
    print(nx.__version__)
    # Load network data, create storage dict, and extract main component
    depends=nx.read_edgelist("data/depends.csv",delimiter=",",create_using=nx.DiGraph(),nodetype=str,data=(("weight",time_from_today),))
    depends.name="depends"
    suggests=nx.read_edgelist("data/suggests.csv",delimiter=",",create_using=nx.DiGraph(),nodetype=str,data=(("weight",time_from_today),))
    suggests.name="suggests"
    imports=nx.read_edgelist("data/imports.csv",delimiter=",",create_using=nx.DiGraph(),nodetype=str,data=(("weight",time_from_today),))
    imports.name="imports"
    nets_dict={"depends":depends,"suggests":suggests,"imports":imports}
    for k in nets_dict.keys():
        main_component=nx.connected_component_subgraphs(nets_dict[k].to_undirected())[0].nodes()
        nets_dict[k]=nx.subgraph(nets_dict[k],main_component)
    
    # Run multiple measures on graphs and normalize weights
    measure_list=[nx.in_degree_centrality,nx.betweenness_centrality,nx.pagerank]
    for g in nets_dict.values():
        multiple_measures(g,measure_list)
        normalize_weights(g)
        
    # Output networks in GraphML format (to store node attributes)
    for i in nets_dict.items():
        # print(i[1].edges(data=True))
        nx.write_graphml(i[1],"data/"+i[0]+"_data.graphml")
        print("")
    print("All files written with data")
    
    """Visualization:
        Various attempts to visualize data....starting with 'imports' first, as it is the smallest graph
    """
    
    

if __name__ == '__main__':
    main()

