## Laboratorium 3
### 1. Testowanie działania profilera

Użycie profilera:
```julia
main() # istotne jest, by przed profilowaniem skompilować badaną funkcję
Profile.clear() # wyczyszczenie danych z poprzedniego profilowania
Profile.init(n = 10^7, delay = 0.1) # ustawienie własnych wartości n i delay
@profile main() # profilowanie danej funkcji (main)

Profile.print() # w formie tekstowej, drzewiastej
Profile.print(format=:flat) # w formie tekstowej, tabelarycznej
using ProfileView
ProfileView.view() # w formie graficznej
```

### 2. Optymalizacja wydajności biblioteki grafowej

Opis zastosowanych optymalizacji:
1. zmienne globalne `N, K` jako stałe :point_right: [changes](https://github.com/Numernabis/julia-lab/commit/97064fbe3f02ffda3fc416a4b1213052b28d936d#diff-9e885630cf41c4ce47581e7aa4fb1f77)
2. reprezentacja macierzy sąsiedztwa grafu jako `BitArray` :point_right: [changes](https://github.com/Numernabis/julia-lab/commit/c7f84905bbdbfb8d9e9f5a841c67a15ef6a13d76#diff-9e885630cf41c4ce47581e7aa4fb1f77)
3. zmienne opisujące graf przekazywane jako argumenty do funkcji,  
  `nodes` jako `Array{NodeType, 1}`, `graph` jako `Array{GraphVertex, 1}` :point_right: [changes](https://github.com/Numernabis/julia-lab/commit/a2da0d7bc8422913d3ffe56a2193c0c7d55eb2ba#diff-9e885630cf41c4ce47581e7aa4fb1f77)
4. dodanie informacji o typach zmiennych,
  `convert_node_to_str` z zastosowaniem _multiple dispatch_ :point_right: [changes](https://github.com/Numernabis/julia-lab/commit/40c0cb5bd7787a9249d5d642570891f6daadc38b#diff-9e885630cf41c4ce47581e7aa4fb1f77)
5. buforowane wyjście w funkcji `graph_to_str` (użycie `graph_buff::IOBuffer`) :point_right: [changes](https://github.com/Numernabis/julia-lab/commit/eea4549ffc4c0d3364f7feb68c12f762d3055b5d#diff-9e885630cf41c4ce47581e7aa4fb1f77)

| Opt. No | Time              | Memory          |
|--------:|------------------:|----------------:|
|      0  | 12.871667 seconds | (121.82 M allocations: 6.527 GiB, 13.89% gc time) |
|      1  |  4.177649 seconds | (5.49 M allocations: 3.790 GiB, 16.52% gc time)   |
|      2  |  3.526876 seconds | (5.50 M allocations: 3.321 GiB, 18.64% gc time)   |
|      3  |  3.134581 seconds | (3.78 M allocations: 3.288 GiB, 19.86% gc time)   |
|      4  |  3.013134 seconds | (3.74 M allocations: 3.288 GiB, 21.22% gc time)   |
|      5  |  0.887800 seconds | (2.97 M allocations: 165.057 MiB, 3.50% gc time)  |
