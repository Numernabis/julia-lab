#=
przykład:
G₇ = _ 1 2 3 4 5 6
4 * 5 = 20 % 7 = 6
(a * b) * c = a * (b * c)
el. neutralny -> 1

G₅ = _ 1 2 3 4
G₉ = _ 1 2 _ 4 5 _ 7 8
=#
import Base.*
import Base.convert
import Base.promote_rule

struct Gn{N} <: Integer
    x::Int64
    function Gn{N}(x) where N
        r = x % N
        if gcd(r, N) != 1
            throw(DomainError)
        end
        new(r)
    end
end

*(a::Gn{N}, b::Gn{N}) where {N} = Gn{N}((a.x * b.x) % N)
*(a::Gn{N}, b::T) where {N, T<:Integer} = a * Gn{N}(b)
*(a::T, b::Gn{N}) where {N, T<:Integer} = Gn{N}(a) * b

convert(::Type{Gn{N}}, z::Int64) where {N} = Gn{N}(z)
convert(::Type{Int64}, z::Gn{N}) where {N} = z.x

promote_rule(::Type{Gn{N}}, ::Type{T}) where {N, T<:Integer} = T

function pow(a::Gn{N}, x::T) where{N, T<:Integer}
    z::Gn{N} = 1
    for i = 1:x
        z = z * a
    end
    return z
end

function period(a::Gn{N}) where {N}
    r = 1
    while (pow(a, r) != 1)
        r = r + 1
    end
    if r <= N return r
    else throw(DomainError)
    end
end

function inverse_element(a::Gn{N}) where {N}
    for b = 1:N
        try
            if a * b == 1
                return Gn{N}(b)
            end
        catch
            continue
        end
    end
end

function group_size(::Type{Gn{N}}) where {N}
    a = 0
    s = 0
    while a < N
        a = a + 1
        try
            Gn{N}(a)
            s = s + 1
        catch

        end
    end
    return s
end

N = 55 #klucz publiczny
c = Gn{N}(17) #klucz publiczny
b = Gn{N}(4) #zakodowana wiadomość
r = period(b)
println("r = ", r)

d = inverse_element(c)
println("d = ", d)

a = pow(b, d)
println("a = ", a)

test = pow(a, c).x
println("test = ", test)
