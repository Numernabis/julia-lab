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

*(a::Gn{N}, b::Gn{N}) where {N} = Gn{N}(((a.x % N) * (b.x % N)) % N)
*(a::Gn{N}, b::T) where {N, T<:Integer} = a * Gn{N}(b)
*(a::T, b::Gn{N}) where {N, T<:Integer} = Gn{N}(a) * b

convert(::Type{Gn{N}}, z::Int64) where {N} = Gn{N}(z)
convert(::Type{Int64}, z::Gn{N}) where {N} = z.x

promote_rule(::Type{Gn{N}}, ::Type{T}) where {N, T<:Integer} = Int64
promote_rule(::Type{Gn{N}}, ::Type{Int64}) where {N} = Int64

function pow(a::Gn{N}, x::T) where{N, T<:Integer}
    z = 1
    while (x > 0)
        z = (z * a.x) % N
        x = x - 1
    end
    return Gn{N}(z)
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
    b = 1
    while (b != a.x + 1)
        if ((a.x * b) % N == 1)
            return Gn{N}(b)
        end
        b = b + 1
    end
end

function group_size(::Type{Gn{N}}) where {N}
    a = 0
    s = 0
    while a < N
        a = a + 1
        s = s + 1
        try
            Gn{N}(a)
        catch
            s = s - 1
        end
    end
    return s
end

println(promote_type(Gn{55}, Int64))

N = 55 #klucz publiczny
c = 17 #klucz publiczny
b = 4 #zakodowana wiadomość
r = period(Gn{N}(b))
println("r = ", r)

d = inverse_element(Gn{N}(c))
println("d = ", d)

a = ^(Gn{N}(b), d.x)
println("a = ", a)

test = ^(a, c).x
println("test = ", test)
