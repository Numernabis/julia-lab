module Graphs

using StatsBase

export GraphVertex, NodeType, Person, Address,
       generate_random_graph, get_random_person, get_random_address, generate_random_nodes,
       convert_to_graph,
       bfs, check_euler, partition,
       graph_to_str, node_to_str,
       test_graph

#= Single graph vertex type.
Holds node value and information about adjacent vertices =#
mutable struct GraphVertex
  value::Any
  neighbors::Vector
end

# Types of valid graph node's values.
abstract type NodeType end

mutable struct Person{T<:AbstractString} <: NodeType
  name::T
end

mutable struct Address{T<:Integer} <: NodeType
  streetNumber::T
end

#= Generates random directed graph of size N with K edges
and returns its adjacency matrix.=#
function generate_random_graph(N::Int64, K::Int64)
    A = BitArray(N, N)
    A .= false

    for i in sample(1:N*N, K, replace=false)
      row, col = ind2sub(size(A), i)
      A[row,col] = true
      A[col,row] = true
    end
    A
end

# Generates random person object (with random name).
function get_random_person()
  Person(randstring())
end

# Generates random address object (with random streetNumber).
function get_random_address()
  Address(rand(1:100))
end

# Generates N random nodes (of random NodeType).
function generate_random_nodes(N::Int64)
  nodes = Array{NodeType, 1}(N)
  for i = 1:N
    if (rand() > 0.5)
      nodes[i] = get_random_person()
    else
      nodes[i] = get_random_address()
    end
  end
  nodes
end

#= Converts given adjacency matrix (NxN)
  into list of graph vertices (of type GraphVertex and length N). =#
function convert_to_graph(A::BitArray, nodes::Array{NodeType, 1})
    B::Int64 = length(nodes)
    graph::Array{GraphVertex, 1} = map(n -> GraphVertex(n, GraphVertex[]), nodes)

  for i = 1:B, j = 1:B
      if A[i,j]
        push!(graph[i].neighbors, graph[j])
      end
  end
  graph
end

#= Groups graph nodes into connected parts. E.g. if entire graph is connected,
  result list will contain only one part with all nodes. =#
function partition(graph::Array{GraphVertex,1})
  parts = []
  remaining = Set(graph)
  visited = bfs(remaining=remaining)
  push!(parts, Set(visited))

  while !isempty(remaining)
    new_visited = bfs(visited=visited, remaining=remaining)
    push!(parts, Set(new_visited))
  end
  parts
end

#= Performs BFS traversal on the graph and returns list of visited nodes.
  Optionally, BFS can initialized with set of skipped and remaining nodes.
  Start nodes is taken from the set of remaining elements. =#
function bfs(;visited::Set=Set(), remaining::Set=Set(graph))
  first = next(remaining, start(remaining))[1]
  q = [first]
  push!(visited, first)
  delete!(remaining, first)
  local_visited = Set([first])

  while !isempty(q)
    v = pop!(q)

    for n in v.neighbors
      if !(n in visited)
        push!(q, n)
        push!(visited, n)
        push!(local_visited, n)
        delete!(remaining, n)
      end
    end
  end
  local_visited
end

#= Checks if there's Euler cycle in the graph by investigating
   connectivity condition and evaluating if every vertex has even degree =#
function check_euler(graph::Array{GraphVertex,1})
  if length(partition(graph)) == 1
    return all(map(v -> iseven(length(v.neighbors)), graph))
  end
    "Graph is not connected"
end

# Optimization: separate methods for various types
function convert_node_to_str(graph_buff::IOBuffer, node::Person)
    println(graph_buff, "****\nPerson: ", node.name)
end
function convert_node_to_str(graph_buff::IOBuffer, node::Address)
    println(graph_buff, "****\nStreet nr: ", node.streetNumber)
end

#= Returns text representation of the graph consisiting of each node's value
   text and number of its neighbors. =#
function graph_to_str(graph::Array{GraphVertex,1})
    graph_buff = IOBuffer()
    for v in graph
        convert_node_to_str(graph_buff, v.value)
        println(graph_buff, "Neighbors: ", length(v.neighbors))
    end
    String(take!(graph_buff))
end

#= Tests graph functions by creating 100 graphs, checking Euler cycle
  and creating text representation. =#
  function test_graph()
    # Number of graph nodes.
    N::Int64 = 800
    # Number of graph edges.
    K::Int64 = 10000

    for i=1:100
      # graph
      A::BitArray = generate_random_graph(N, K)
      nodes::Array{NodeType, 1} = generate_random_nodes(N)
      graph::Array{GraphVertex, 1} = convert_to_graph(A, nodes)

      str = graph_to_str(graph)
      # println(str)
      println(check_euler(graph))
    end
  end

  end
