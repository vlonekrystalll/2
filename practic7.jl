# Включаем необходимые функции и типы из внешнего файла "utils.jl"
include("utils.jl")

# Определяем абстрактный тип для комбинаторных объектов
abstract type AbstractCombinObject end

# Реализуем функцию итерации для объектов типа AbstractCombinObject
Base.iterate(obj::AbstractCombinObject) = (get(obj), nothing)
Base.iterate(obj::AbstractCombinObject, state) = 
    if isnothing(next!(obj)) # Если следующий элемент не существует
        nothing
    else
        (get(obj), nothing)
    end
    
# Определяем структуру для размещений с повторениями
struct RepitPlacement{N,K} <: AbstractCombinObject
    value::Vector{Int}
    RepitPlacement{N,K}() where {N, K} = new(ones(Int, K))
end

# Реализуем функцию для получения значения размещения
Base.get(p::RepitPlacement) = p.value
# Реализуем функцию для генерации следующего размещения
next!(p::RepitPlacement{N,K}) where {N, K} = next_repit_placement!(p.value, N)

# Создаем объект размещений с повторениями
rp = RepitPlacement{2,3}()

# Переопределяем функцию печати для объектов размещений с повторениями
function Base.println(R::RepitPlacement{N,K}) where {N,K}
    for a in R
        println(a)
    end
end

# Определяем структуру для перестановок
struct Permute{N} <: AbstractCombinObject
    value::Vector{Int}
    Permute{N}() where N = new(collect(1:N))
end

# Реализуем функцию для получения значения перестановки
Base.get(obj::Permute) = obj.value
# Реализуем функцию для генерации следующей перестановки
next!(permute::Permute) = next_permute!(permute.value)

# Создаем объект перестановок
permute = Permute{3}()
# Переопределяем функцию печати для объектов перестановок
function Base.println(R::Permute{N}) where {N}
    for a in R
        println(a)
    end
end

# Определяем структуру для всех подмножеств
struct Subsets{N} <: AbstractCombinObject
    indicator::Vector{Bool}
    Subsets{N}() where N = new(zeros(Bool, N))
end

# Реализуем функцию для получения значения подмножества
Base.get(sub::Subsets) = sub.indicator
# Реализуем функцию для генерации следующего подмножества
next!(sub::Subsets) = next_indicator!(sub.indicator)

# Создаем объект всех подмножеств
subsets = Subsets{3}()
# Переопределяем функцию печати для объектов всех подмножеств
function Base.println(R::Subsets{N}) where {N}
    for a in R
        println(a)
    end
end

# Определяем структуру для k-элементных подмножеств
struct KSubsets{M,K} <: AbstractCombinObject
    indicator::Vector{Bool}
    KSubsets{M, K}() where{M, K} = new([zeros(Bool, length(M)-K); ones(Bool, K)])
end

# Реализуем функцию для получения значения k-элементного подмножества
Base.get(sub::KSubsets) = sub.indicator
# Реализуем функцию для генерации следующего k-элементного подмножества
next!(sub::KSubsets{M, K}) where{M, K} = next_indicator!(sub.indicator)

# Переопределяем функцию печати для объектов k-элементных подмножеств
function Base.println(R::KSubsets{M, K}) where {M,K}
    for sub in R
        sub |> println
    end
end

# Определяем структуру для разбиений
struct NSplit{N} <: AbstractCombinObject
    value::Vector{Int64}
    num_terms::Int # число слагаемых (это число мы обозначали - k)
    NSplit{N}() where N = new(collect(1:N), N)
end

# Реализуем функцию для получения значения разбиения
Base.get(nsplit::NSplit) = nsplit.value[begin:nsplit.num_terms]
# Реализуем функцию для генерации следующего разбиения
function next!(nsplit::NSplit)
    nsplit.value, nsplit.num_terms = next_split!(nsplit.value, nsplit.num_terms)
    get(nsplit)
end

# Для тестирования алгоритмов обхода графа в ширину и глубину,
# определим два графа в виде словарей, где ключами являются вершины,
# а значениями - списки смежных вершин
graph = Dict(
    1 => [2, 3],
    2 => [1, 4, 5],
    3 => [1, 6, 7],
    4 => [2],
    5 => [2],
    6 => [3],
    7 => [3]
)

# Функция для обхода графа в глубину (DFS)
function dfs(graph::Dict{I, Vector{I}}, vstart::I) where I <: Integer
    stack = [vstart] # Инициализируем стек стартовой вершиной
    mark = zeros(Bool, length(graph)) # Массив для отслеживания посещенных вершин
    mark[vstart] = true # Отмечаем стартовую вершину как посещенную
    while !isempty(stack) # Пока стек не пуст
        v = pop!(stack) # Извлекаем вершину из стека
        println("Visited: $v") # Печатаем посещенную вер
    end
end