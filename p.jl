include("struct_polynom.jl")

# Создание многочлена из массива
P(arr) = Polynomial{eltype(arr)}(arr)

# Определение базовых многочленов и функций
Base.zero(p::Polynomial{T}) where T = Polynomial{T}([zero(T)])          # Нулевой многочлен
Base.one(p::Polynomial{T}) where T = Polynomial{T}([one(T)])            # Единичный многочлен
ord(p::Polynomial) = length(p.c) - 1                                    # Порядок многочлена
Base.copy(p::Polynomial{T}) where T = Polynomial{T}(copy(p.c))          # Копирование многочлена
Base.iszero(p::Polynomial{T}) where T = p.c == [0]                      # Проверка на нулевой многочлен
Base.isone(p::Polynomial{T}) where T = p.c == [1]                       # Проверка на единичный многочлен

# Арифметические операции для многочленов
function Base.:+(p::Polynomial, q::Polynomial)
    lp, lq = length(p.c), length(q.c)
    coeff = if lp > lq
        copy(p.c)
    else
        copy(q.c)
    end
    if lp > lq
        coeff[end-lq+1:end] .+= q.c
    else
        coeff[end-lp+1:end] .+= p.c
    end
    return Polynomial{promote_type(eltype(p.c), eltype(q.c))}(coeff)
end

function Base.:+(p::Polynomial, q)
    n = copy(p.c)
    n[end] += q
    return Polynomial{promote_type(eltype(p.c), typeof(q))}(n)
end

function Base.:+(q::T, p::Polynomial{T}) where T
    return p + q
end

function Base.:-(p::Polynomial{T}) where T
    return Polynomial{T}(-p.c)
end

function Base.:-(p::Polynomial{T}, q::Polynomial{T}) where T
    return p + (-q)
end

function Base.:-(p::Polynomial{T}, q::T) where T
    return p + (-q)
end

function Base.:-(p::T, q::Polynomial{T}) where T
    return p + (-q)
end

function Base.:*(p::Polynomial, q::Polynomial)
    n = zeros(promote_type(eltype(p.c), eltype(q.c)), ord(p) + ord(q) + 1)
    for x in 1:length(p.c)
        for y in 1:length(q.c)
            n[x + y - 1] += p.c[x] * q.c[y]
        end
    end
    return Polynomial{promote_type(eltype(p.c), eltype(q.c))}(n)
end

function Base.:*(p::Polynomial, q)
    return Polynomial{promote_type(eltype(p.c), typeof(q))}(p.c * q)
end

function Base.:*(q, p::Polynomial)
    return p * q
end

function Base.:/(p::Polynomial, q)
    return Polynomial{promote_type(eltype(p.c), typeof(q))}(p.c / q)
end

function Base.:^(p::Polynomial{T}, x) where T
    ans = p
    if x > 0
        for i in 1:x-1
            ans *= p
        end
    else
        for i in 0:abs(x)-1
            ans /= p
        end
    end
    return ans
end

# Оценка значения многочлена в точке
function (q::Polynomial)(x)
    p = promote_type(eltype(q.c), typeof(x))(0)
    for i in 1:length(q.c)
        p = p * x + q.c[i]
    end
    return p
end

# Деление многочленов с остатком
function divrem(p::Polynomial{T}, q::Polynomial{T}) where T
    if iszero(q)
        throw(DivideError("division by zero polynomial"))
    end
    lp = ord(p)
    lq = ord(q)
    if lp < lq
        return (Polynomial{T}([zero(T)]), p)
    end

    quotient = zeros(T, lp - lq + 1)
    remainder = copy(p.c)
    for i in 0:(lp - lq)
        coeff = remainder[i + 1] / q.c[1]
        quotient[i + 1] = coeff
        for j in 1:length(q.c)
            remainder[i + j] -= coeff * q.c[j]
        end
    end
    while length(remainder) > 1 && iszero(remainder[1])
        popfirst!(remainder)
    end
    return (Polynomial{T}(quotient), Polynomial{T}(remainder))
end

Base.:/(p::Polynomial, q::Polynomial) = divrem(p, q)                      # Деление многочленов
Base.div(p::Polynomial, q::Polynomial) = divrem(p, q)[1]                  # Получение частного от деления многочленов
Base.rem(p::Polynomial, q::Polynomial) = ord(divrem(p, q)[2]) == -1 ? zero(p) : divrem(p, q)[2] # Остаток от деления многочленов

# Сравнение многочленов
Base.:<(p::Polynomial, q::Polynomial) = ord(p) < ord(q)                   # Сравнение многочленов по порядку
Base.:>(p::Polynomial, q::Polynomial) = ord(p) > ord(q)                   # Сравнение многочленов по порядку
Base.:<=(p::Polynomial, q::Polynomial) = ord(p) <= ord(q)                 # Сравнение многочленов по порядку
Base.:>=(p::Polynomial, q::Polynomial) = ord(p) >= ord(q)                 # Сравнение многочленов по порядку

# Вычисление значения и производной многочлена
function valder(p::Polynomial, x)
    T = promote_type(eltype(p.c), typeof(x))
    Q, Q′ = zero(T), zero(T)
    for i in eachindex(p.c)
        Q′, Q = Q′ * x + Q, Q * x + p.c[i]
    end
    return Q, Q′
end

function value(p::Polynomial, x)
    return valder(p, x)[1]
end

function der(p::Polynomial, x)
    return valder(p, x)[2]
end

# Вычисление производной многочлена
function derivative(p::Polynomial)
    n = [zero(eltype(p.c)) for _ in 1:(length(p.c)-1)]
    if ord(p) == 0
        return zero(p)
    end
    for i in 1:ord(p)
        n[i] = (length(p.c) - i) * p.c[length(p.c) - i + 1]
    end
    return Polynomial(n)
end

convert(p::Polynomial) = tuple(p.c...)                                    # Преобразование многочлена в кортеж

type(a, b) = promote_type(eltype(a), eltype(b))                           # Определение общего типа для двух значений
