
function typeGraph(x)
    if x != Any
        typeGraph(supertype(x))
        print(" ➤ ")
    end
    print(x)
end
