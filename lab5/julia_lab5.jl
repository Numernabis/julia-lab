
function harmonic_mean_impl(I...)
    N = length(I)
    n = :($N)
    ex = :(1 / I[$1])
    for i = 2:N
       ex = :($ex + (1 / I[$i]))
    end
    return :($n/$ex)
end

@generated function harmonic_mean(I...)
    return harmonic_mean_impl(I...)
end

harmonic_mean_impl(Int, Int)

harmonic_mean_impl(Int, Int, Int)

harmonic_mean(1, 2, 3)

harmonic_mean(1, 2, 3, 4)

autodiff(n::Number) = 0
autodiff(s::Symbol) = 1

function autodiff(ex::Expr, ::Type{Val{:+}})::Expr
    Expr(:call, :+, map(f -> autodiff(f), ex.args[2:end])...)
end
function autodiff(ex::Expr, ::Type{Val{:-}})::Expr
    Expr(:call, :-, map(f -> autodiff(f), ex.args[2:end])...)
end 

function autodiff(ex::Expr, ::Type{Val{:*}})::Expr
    sum = []
    args = ex.args[2:end]
    for (i, f) in enumerate(args)
        mul = [autodiff(f), args[1:end .!= i]...]
        push!(sum, Expr(:call, :*, mul...))
    end
    Expr(:call, :+, sum...)
    #:($df * $g + $f * $dg)
end      
function autodiff(ex::Expr, ::Type{Val{:/}})::Expr
    f = ex.args[2]
    g = ex.args[3]
    df = autodiff(f)
    dg = autodiff(g)
    :(($df * $g - $f * $dg) / ($g * $g))
end

function autodiff(ex::Expr)::Expr
    if ex.head != :call
        throw(DomainError())
    end
    op = Val{ex.args[1]}
    autodiff(ex, op)
end

ex = :(x*x*x + x*x - 4*x)

dex = autodiff(ex)

x = 2
eval(dex)

# based on: https://github.com/JuliaDiff/DualNumbers.jl
using DualNumbers
function autodiffFun(f)
   g(x) = dualpart(f(Dual(x, 1))) 
end

f(x) = x * x + x - 10
g = autodiffFun(f)
g(5)

f(x) = 4 * x * x + x / 4 - 2
g = autodiffFun(f)
g(1)
