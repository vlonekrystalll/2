# Генерируем случайный массив целых чисел
v = Int.(round.(randn(50000)*1000))

# Сортировка пузырьком
function bubble_sort!(a)
    n = length(a)
    for k in 1:n-1
        istranspose = false
        for i in 1:n-k
            if a[i] > a[i+1]
                a[i], a[i+1] = a[i+1], a[i]
                istranspose = true
            end
        end
        if !istranspose
            break
        end
    end
    return a
end
    
# Вычисление сортировки
function calc_sort!(A::AbstractVector{<:Integer})
    min_val, max_val = extrema(A)
    num_val = zeros(Int, max_val-min_val+1)
    for val in A
        num_val[val-min_val+1] += 1
    end
    k = 0
    for (i, num) in enumerate(num_val)
        A[k+1:k+num] .= min_val+i-1
        k += num
    end
    return A
end

# Сортировка расческой
function comb_sort!(a::AbstractVector; factor=1.2473309)
    a = copy(a)
    step = length(a)
    while step >= 1
        for i in 1:length(a)-step
            if a[i] > a[i+step]
                a[i], a[i+step] = a[i+step], a[i]
            end
        end
        step = Int(floor(step/factor))
    end
    a = bubble_sort!(a)
    return a
end

# Сортировка Шелла
function shell_sort!(a::AbstractVector)
    a = copy(a)
    n=length(a)
    step_series = (n÷2^i for i in 1:Int(floor(log2(n))))
    for step in step_series
        for i in firstindex(a):lastindex(a)-step
            j = i
            while j >= firstindex(a) && a[j] > a[j+step]
                a[j], a[j+step] = a[j+step], a[j]
                j -= step
            end
        end
    end
    return a
end

# Слияние массивов
function merge!(a1, a2, a3)::Nothing
    i1, i2, i3 = 1, 1, 1
    while i1 <= length(a1) && i2 <= length(a2)
        if a1[i1] < a2[i2]
            a3[i3] = a1[i1]
            i1 += 1
        else
            a3[i3] = a2[i2]
            i2 += 1
        end
        i3 += 1
    end
    
    if i1 > length(a1)
        a3[i3:end] .= @view(a2[i2:end])
    else
        a3[i3:end] .= @view(a1[i1:end])
    end
    nothing
end

# Сортировка слиянием
function merge_sort!(a)
    b = similar(a)
    N = length(a)
    n = 1
    while n < N
        K = div(N, 2n) 
        for k in 0:K-1
            merge!(@view(a[(1:n).+k * 2n]), @view(a[(n+1:2n).+k * 2n]), @view(b[(1:2n).+k * 2n]))
        end
        if N - K * 2n > n
            merge!(@view(a[(1:n).+K * 2n]), @view(a[K * 2n+n+1:end]), @view(b[K * 2n+1:end]))
        elseif 0 < N - K * 2n <= n
            b[K * 2n+1:end] .= @view(a[K * 2n+1:end])
        end
        a, b = b, a
        n  *= 2
    end
    if isodd(log2(n))
        b .= a
        a = b
    end
    return a
end

# Построение кучи
function heap!(array)
    N = length(array)
    for i in 1:N÷2
        if array[i] < array[2i]
            array[i], array[2i] = array[2i], array[i]
        end
        if 2i+1 <= N && array[i] < array[2i+1]
        array[i], array[2i+1] = array[2i+1], array[i]
        end
    end
    return array
end

# Просеивание вниз
function down_first!(heap::AbstractVector)::Nothing
    index = 1
    N = length(heap)
    while index < N÷2
        if heap[index] < heap[2index]
            heap[index], heap[2index] = heap[2index], heap[index]
        end
        if 2index+1 <= N && heap[index] < heap[2index+1]
            heap[index], heap[2index+1] = heap[2index+1],heap[index]
        end
        index *= 2
    end
end

# Сортировка кучей
function heap_sort!(heap::AbstractVector)
    heap = heap!(heap)
    N = length(heap)
    while N > 3
        heap[1], heap[N] = heap[N], heap[1]
        N -= 1
        down_first!(@view(heap[1:N]))
    end
    return heap
end

# Разделение массива на части
function part_sort!(A, b)
    N = length(A)
    K=0; L=0; M=N
    while L < M
        if A[L+1] == b
            L += 1
        elseif A[L+1] > b
            A[L+1], A[M] = A[M], A[L+1]
            M -= 1
        else # if A[L+1] < b
            L += 1; K += 1
            A[L], A[K] = A[K], A[L]
        end
    end
    return K, M+1
end

# Быстрая сортировка
function quick_sort!(A)
    if isempty(A)
        return A
    end
    N = length(A)
    K, M = part_sort!(A, A[rand(1:N)])
   
