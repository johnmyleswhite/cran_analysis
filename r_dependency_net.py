#!/usr/bin/env python
# encoding: utf-8
"""
r_dependency_net.py

Purpose:  Analyze the dependency network of R libraries

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
import matplotli.pylab as plt


def main():
    # Load network data and remove header
    dep_net=nx.read_edgelist("data/graph.csv",delimiter=",",create_using=nx.DiGraph(),nodetype=str)
    dep_net.remove_edge("Package","Dependency") # Remove header, not an edge
    main_component=nx.connected_component_subgraphs(dep_net.to_undirected())[0].nodes()
    dep_net=nx.subgraph(dep_net,main_component)
    
    in_degree=dep_net.in_degree()
    
    # Convert to AGraph and add attributes
    dep_ag=nx.to_agraph(dep_net)
    dep_ag.graph_attr['rankdir']='TB'
    

    # Write dot file
    dep_ag.draw("dep_tree.pdf",prog="dot")
    

if __name__ == '__main__':
    main()

