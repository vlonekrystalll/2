# Функция для генерации всех размещений с повторениями из n элементов
function next_repit_placement!(p::Vector{T}, n::T) where T<:Integer
    # Находим последний элемент вектора, который меньше n
    i = findlast(x -> (x < n), p)

    # Если такого элемента нет, значит, все размещения сгенерированы
    isnothing(i) && return nothing

    # Увеличиваем значение последнего элемента на 1
    p[i] += 1
    # Сбрасываем все последующие элементы в 1
    p[i+1:end] .= 1

    return p
end

# Функция для генерации всех перестановок
function next_permute!(p::AbstractVector)
    n = length(p)
    k = 0 
    # Ищем самую правую пару, где p[i] < p[i+1]
    for i in reverse(1:n-1) 
        if p[i] < p[i+1]
            k=i; break
        end
    end
    # Если такой пары нет, значит, все перестановки сгенерированы
    k == firstindex(p)-1 && return nothing 

    # Находим наименьший элемент справа от p[k], больший чем p[k]
    i=k+1
    while i<n && p[i+1]>p[k] 
        i += 1
    end

    # Меняем местами p[k] и наименьший элемент справа от p[k], который больше p[k]
    p[k], p[i] = p[i], p[k]

    # Инвертируем порядок элементов справа от p[k]
    reverse!(@view p[k+1:end])
    return p
end

# Функция для генерации всех подмножеств
function next_indicator!(ind::AbstractVector{Bool})
    # Находим индекс последнего нуля в векторе
    i = findlast(x -> (x == 0), ind)
    # Если такого индекса нет, значит, все подмножества сгенерированы
    isnothing(i) && return nothing
    # Устанавливаем следующий бит в 1
    ind[i] = 1
    # Сбрасываем все последующие биты в 0
    ind[i+1:end] .= 0
    return ind
end

# Функция для генерации всех k-элементных подмножеств
function next_k_subset!(ind::AbstractVector{Bool}, k::Integer)
    # Находим индекс последнего нуля в векторе
    i = findlast(x -> (x == 0), ind)
    # Если такого индекса нет или k ноль, значит, все k-элементные подмножества сгенерированы
    isnothing(i) || k == 0 && return nothing
    # Устанавливаем следующий бит в 1
    ind[i] = 1
    # Сбрасываем все последующие биты в 0
    ind[i+1:end] .= 0
    # Устанавливаем k битов в 1 с начала вектора
    ind[1:k] .= 1
    return ind
end

# Функция для генерации всех разбиений натурального числа на положительные слагаемые
function next_split!(s::AbstractVector{Int}, k)
    # Если k равно 1, значит, разбиение закончено
    k == 1 && return nothing
    
    # Находим последний элемент s[i-1], который не равен s[i]
    i = k - 1
    while i > 1 && s[i-1] == s[i]
        i -= 1
    end

    # Увеличиваем s[i] на 1
    s[i] += 1

    # Перераспределяем оставшиеся единицы равномерно
    r = sum(@view(s[i+1:k]))
    k = i + r - 1 # - это с учетом s[i] += 1
    for j in (i + 1):k
        s[j] = 1
    end
    summa = 0
    index = 1
    while summa < n
        summa += s[index]
        index += 1
    end
    s[index:n] .= 0

    return s, k
end
