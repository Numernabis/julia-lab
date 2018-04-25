## Laboratorium 3
### 1. Testowanie działania profilera

### 2. Optymalizacja wydajności biblioteki grafowej

Opis zastosowanych optymalizacji:
1. zmienne globalne `N, K` jako stałe,
2. reprezentacja macierzy sąsiedztwa grafu jako `BitArray`,
3. zmienne opisujące graf przekazywane jako argumenty do funkcji,
  `nodes` jako `Array{NodeType, 1}`, `graph` jako `Array{GraphVertex, 1}`,
4. dodanie informacji o typach zmiennych,
  `convert_node_to_str` z zastosowaniem _multiple dispatch_
5.

| Opt. No | Time              | Memory          |
|--------:|------------------:|----------------:|
|      0  | 12.871667 seconds | (121.82 M allocations: 6.527 GiB, 13.89% gc time) |
|      1  |  4.177649 seconds | (5.49 M allocations: 3.790 GiB, 16.52% gc time)   |
|      2  |  3.526876 seconds | (5.50 M allocations: 3.321 GiB, 18.64% gc time)   |
|      3  |  3.134581 seconds | (3.78 M allocations: 3.288 GiB, 19.86% gc time)   |
|      4  |  3.013134 seconds | (3.74 M allocations: 3.288 GiB, 21.22% gc time)   |
|      5  |  |  |
