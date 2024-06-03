# Определение структуры Residue для представления элементов класса вычетов по модулю M.
struct Residue{T, M} <: Number
    value::T  # Значение вычета
    # Конструктор, который создает вычет, взяв остаток от деления value на M.
    Residue{T, M}(value) where {T, M} = new(rem(value, M))
end

# Удобная функция для создания объекта Residue.
R(v, m) = Residue{typeof(v), typeof(m)}(v)

# Перегрузка оператора zero для вычетов.
Base.zero(::Residue{T, M}) where {T, M} = Residue{T, M}(zero(T))

# Перегрузка оператора one для вычетов.
Base.one(::Residue{T, M}) where {T, M} = Residue{T, M}(one(T))

# Перегрузка оператора iszero для вычетов.
Base.iszero(a::Residue{T, M}) where {T, M} = a.value == zero(T)

# Перегрузка оператора isone для вычетов.
Base.isone(a::Residue{T, M}) where {T, M} = a.value == one(T)

# Перегрузка оператора сложения для вычетов.
Base.+(a::Residue{T, M}, b::Residue{T, M}) where {T, M} = Residue{T, M}(a.value + b.value)

# Перегрузка оператора вычитания для вычетов.
Base.-(a::Residue{T, M}, b::Residue{T, M}) where {T, M} = Residue{T, M}(a.value - b.value)

# Перегрузка унарного минуса для вычетов.
Base.-(a::Residue{T, M}) where {T, M} = Residue{T, M}(-a.value)

# Перегрузка оператора умножения для вычетов.
Base.*(a::Residue{T, M}, b::Residue{T, M}) where {T, M} = Residue{T, M}(a.value * b.value)

# Перегрузка оператора деления для вычетов.
Base.//(a::Residue{T, M}, b::Residue{T, M}) where {T, M} = Residue{T, M}(a.value ÷ b.value)

# Перегрузка операторов сравнения для вычетов.
Base.>(a::Residue{T, M}, b::Residue{T, M}) where {T, M} = a.value > b.value
Base.<(a::Residue{T, M}, b::Residue{T, M}) where {T, M} = a.value < b.value
Base.>=(a::Residue{T, M}, b::Residue{T, M}) where {T, M} = a.value >= b.value
Base.<=(a::Residue{T, M}, b::Residue{T, M}) where {T, M} = a.value <= b.value
Base.==(a::Residue{T, M}, b::Residue{T, M}) where {T, M} = a.value == b.value
Base.!=(a::Residue{T, M}, b::Residue{T, M}) where {T, M} = a.value != b.value

# Перегрузка оператора копирования для вычетов.
Base.copy(a::Residue{T, M}) where {T, M} = Residue{T, M}(copy(a.value))

# Функция для нахождения наибольшего общего делителя (НОД) двух чисел.
function gcd_(a::T, b::T) where T 
    while !iszero(b) 
        a, b = b, rem(a, b) 
    end
    if a < zero(a)
        a = -a
    end
    return a
end

# Функция для решения диофантовых уравнений.
function diaphant_solve(a::T, b::T, c::T) where T 
    m = gcd(a, b)
    if c % m != 0
        return nothing 
    end
    a, b, c = a ÷ m, b ÷ m, c ÷ m
    m, a1, b1 = gcdx_(a, b)
    return a1 * c, b1 * c 
end

# Функция для нахождения обратного элемента для вычета.
function inverse(a::Residue{T, M}) where {T, M} 
    if gcd_(a.value, M) != 1 
        return nothing 
    end 
    return Residue{T, M}(gcd_(a.value, M)) 
end 

# Функция для нахождения простых чисел до заданного целого числа n.
function eratosphenes_sieve(n::Integer)
    prime_indexes::Vector{Bool} = ones(Bool, n)
    prime_indexes[begin] = false
    i = 2
    prime_indexes[i^2:i:n] .= false 
    i = 3
    while i <= n
        prime_indexes[i^2:2i:n] .= false
        i += 1
        while i <= n && prime_indexes[i] == false
            i += 1
        end
    end
    return findall(prime_indexes)
end

# Функция для проверки, является ли заданное целое число простым.
function isprime(n::IntType) where IntType <: Integer 
    for d in 2:IntType(ceil(sqrt(abs(n))))
        if n % d == 0
            return false
        end
    end
    return true
end

# Функция, возвращающая вычеты, взаимно простые с заданным модулем M.
function multy(a::Residue{T, M}) where {T, M}
    ans = []
    for i in 1:M
        if gcd(i, M) == 1
            push!(ans, Residue{T, M}(i))
        end
    end
    return ans
end

# Функция для факторизации заданного числа.
function factorize(n::T) where T <: Integer
    list = NamedTuple{(:div, :deg), Tuple{T, T}}[]
    # Поиск простых чисел, на которые n делится.
    for p in eratosphenes_sieve(Int(ceil(n/2)))
       
