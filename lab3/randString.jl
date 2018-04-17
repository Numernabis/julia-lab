function n_strings(n)
    for i = 1:n
        s = Base.Random.randstring(Base.Random.GLOBAL_RNG, 17)
    end
end

function fun1()
    n_strings(100000)
end

function fun2()
    n_strings(10000)
end

function main()
    j = 0
    while (j < 500)
        fun1()
        fun2()
        j += 1
    end
end
