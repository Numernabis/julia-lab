function quicksort(a,l,r)
    i, j = l, r
    while i < r
        pivot = a[(l + r) >>> 1]
        #pos = Int((l + r) / 2)
        #pivot = a[pos]
        while i <= j
            while a[i] < pivot
                i = i + 1
            end
            while a[j] > pivot
                j = j - 1
            end
            if i <= j
                a[i], a[j] = a[j], a[i] #swap
                i, j = i + 1, j - 1
            end
        end
        if l < j
            quicksort(a,l,j)
        end
        l, j = i, r
    end
    return a
end

tab = [54,21,15,12,6,16,26,1,7,3,74]
quicksort(tab, 1, length(tab))
