
"""
function f print value of its argument 5 times,
yield() used to allow other tasks to work
"""
function f(x)
    for i = 1:5
        print("$(x) ")
        yield()
    end
end

@schedule f(1)
@schedule f(2)
@schedule f(3)

"""
producer reads current directory, looking for .csv files,
then it puts found file name to the Channel
"""
function producer(ch::Channel)
    println("+ producer starts")
    for f in filter(x -> endswith(x, "csv"), readdir())
        println("add file ", f)
        put!(ch, f)
        yield()

    end
    close(ch)
    println("+ producer ends")
end

A = []
"""
consumer takes name from Channel, calculates number of line in file,
prints information and adds calculated value to table A
"""
function consumer(ch::Channel, id::Int)
    println("* consumer$(id) starts")
    for file in ch
        n = length(readlines(file))
        push!(A, n)
        println("$(id) -> $(file) has $(n) lines")
        yield()
    end
    println("* consumer$(id) ends")
end

"""
producer & consumer problem solution
uses @sync block, with @async tasks
at the end sum of lines is printed
"""
println("--->")

@sync begin
    ch = Channel(32)
    @async consumer(ch, 1)
    @async consumer(ch, 2)
    @async producer(ch)
end

println("<---")
sum = 0
for i = 1:length(A)
    sum += A[i]
end
println(A)
A = []
println("sum of lines in .csv files is $(sum)")

function generate_julia(z; c=2, maxiter=200)
    for i=1:maxiter
        if abs(z) > 2
            return i-1
        end
        z = z^2 + c
    end
    maxiter
end

function calc_julia!(julia_set, xrange, yrange; maxiter=200, height=400, width_start=1, width_end=400)
    for x=width_start:width_end
        for y=1:height
            z = xrange[x] + 1im*yrange[y]
            julia_set[x, y] = generate_julia(z, c=-0.70176-0.3842im, maxiter=maxiter)
        end
    end
end

"""
version 1 - parallel for
usage of @parallel macro together with @async,
also @inbounds to be sure about matrix bounds
"""
function calc_julia_1!(julia_set, xrange, yrange; maxiter=200, height=400, width_start=1, width_end=400)
    @async @parallel for x=width_start:width_end
        for y=1:height
            z = xrange[x] + 1im*yrange[y]
            @inbounds julia_set[x, y] = generate_julia(z, c=-0.70176-0.3842im, maxiter=maxiter)
        end
    end
end

"""
version 2 - pmap
attempt to use pmap with @inline function calculating one slice of matrix
"""
function calc_julia_2!(julia_set, xrange, yrange; maxiter=200, height=400, width_start=1, width_end=400)
    @inline function calc_slice(x::Int64)
        for y=1:height
            z = xrange[x] + 1im*yrange[y]
            julia_set[x, y] = generate_julia(z, c=-0.70176-0.3842im, maxiter=maxiter)
        end
    end

    pmap(calc_slice, width_start:width_end)         
end

using Plots
Plots.gr()

function calc_julia_main(h, w, option)
    xmin, xmax = -2,2
    ymin, ymax = -1,1
    xrange = linspace(xmin, xmax, w)
    yrange = linspace(ymin, ymax, h)
    #println(xrange[100],yrange[101])
    julia_set = SharedArray{Int64}(w, h)
    
    if (option == 0)
        @time calc_julia!(julia_set, xrange, yrange, height=h, width_end=w)
    elseif (option == 1)
        @time calc_julia_1!(julia_set, xrange, yrange, height=h, width_end=w)
    elseif (option == 2)
        @time calc_julia_2!(julia_set, xrange, yrange, height=h, width_end=w)
    else
        #TODO: channel version
    end
    
    Plots.heatmap(xrange, yrange, julia_set)
    png("julia_$(option)")
end

calc_julia_main(2000, 2000, 0)
calc_julia_main(2000, 2000, 1)
calc_julia_main(2000, 2000, 2)
