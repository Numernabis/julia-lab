// JULIA LAB4
// completed

Pkg.status("DifferentialEquations")
Pkg.status("DataFrames")

using DifferentialEquations
using Gadfly
using DataFrames

function LotkaVolterra(du, u, p, t)
    du[1] = p[1] * u[1] - p[2] * u[1] * u[2]
    du[2] = -p[3] * u[2] + p[4] * u[1] * u[2]
end

function solveLV(a, b, c, d, ux, uy, id)
    timespan = (0.0, 100.0)
    u0 = [ux, uy]
    p = [a, b, c, d]
    
    problem = ODEProblem(LotkaVolterra, u0, timespan, p)
    solution = solve(problem, RK4(), dt = 0.01)

    dataframe = DataFrame(time = solution.t, 
        prey = map(x -> x[1], solution.u), 
        pred = map(x -> x[2], solution.u), 
        experiment = "exp$(id)")
    
    file = "results$(id).csv"
    header = isfile(file) ? false : true

    open(file, "a+") do stream
        printtable(stream, dataframe, header = header)
    end
end

solveLV(0.55, 0.028, 0.8, 0.024, 50.0, 50.0, 1)

param = zeros(4, 4)

function experiment_series(num = 4)
    res = DataFrame()
    for i = 1:num
        a = round(rand() / 10 + 0.5, 2)
        b = round(rand() / 100 + 0.03, 3)
        c = round(rand(), 1)
        d = round(rand() / 100 + 0.02, 3)
        param[i, :] = [a, b, c, d]
        #---------------------------------
        solveLV(a, b, c, d, 50.0, 50.0, i)
        #---------------------------------
        df = readtable("results$(i).csv")
        res = vcat(res, df)

        expdf = res[res[:experiment] .== "exp$(i)", :]
        pred = expdf[:pred]
        prey = expdf[:prey]

        toPrint = DataFrame()
        toPrint[:stat] = [:Minimum, :Maximum, :Average]
        toPrint[:pred] = [minimum(pred), maximum(pred), mean(pred)]
        toPrint[:prey] = [minimum(prey), maximum(prey), mean(prey)]

        print("Experiment $(i), parameters: $(param[i,:])\n")
        show(toPrint)
        print("\n\n")
    end

    res[:diff] = res[:pred] - res[:prey]

    return res
end

res = experiment_series(4)

param

# inna metoda wyświetlenia statystyk dla poszczególnych kolumn DataFrame'a
describe(res[res[:experiment] .== "exp1", :])

set_default_plot_size(30cm, 10cm)

plot(res[res[:experiment] .== "exp2", :], Coord.Cartesian(ymax=120),
    layer(x = "time", y = "pred", Geom.line, Theme(default_color=colorant"orange")),
    layer(x = "time", y = "prey", Geom.line, Theme(default_color=colorant"green")), 
    layer(x = "time", y = "diff", Geom.line, Theme(default_color=colorant"pink")),
    Guide.manual_color_key(
        "exp2 - $(param[2, :])", 
        ["Predator", "Prey", "Difference"], 
        ["orange", "green", "pink"]),
    Guide.ylabel(nothing), 
    Guide.xlabel("time")
)

set_default_plot_size(28cm, 24cm)
plot(res, Geom.subplot_grid(
        layer(ygroup="experiment", x="time", y="prey", Geom.line, Theme(default_color=colorant"orange")),
        layer(ygroup="experiment", x="time", y="pred", Geom.line, Theme(default_color=colorant"green")), 
        layer(ygroup="experiment", x="time", y="diff", Geom.line, Theme(default_color=colorant"pink")),
        free_y_axis=true
    ),
    Guide.manual_color_key(
        "Legend",
        ["Predator", "Prey", "Difference"], 
        ["orange", "green", "pink"])
)

set_default_plot_size(28cm, 18cm)
plot(res, ygroup="experiment", x="time", y="prey", 
    Geom.subplot_grid(Geom.line, free_y_axis=true), Theme(default_color=colorant"green"))

function drawPhase(res)
    layers = Vector{Gadfly.Layer}()
    colors = [colorant"magenta", colorant"green", colorant"yellow", colorant"blue", colorant"black"]
    exps = unique(res[:experiment])
    
    for i in 1:length(exps)
        exp_i = res[res[:experiment] .== exps[i], :]
        usedColor = color(colors[i % length(colors)])
        push!(layers, layer(exp_i, x  = "prey", y = "pred", Geom.point, Theme(default_color = usedColor))...)
    end
    
    set_default_plot_size(24cm, 16cm)
    plot(layers, 
        Guide.XLabel("Prey"), 
        Guide.YLabel("Predator"), 
        Guide.Title("Population"), 
        Guide.manual_color_key(
            "Parameters", 
            ["exp1 - $(param[1,:])", "exp2 - $(param[2,:])", 
                "exp3 - $(param[3,:])", "exp4 - $(param[4,:])"],
            ["magenta", "green", "yellow", "blue"])
    )
end

drawPhase(res)
