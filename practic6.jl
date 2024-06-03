# Подключаем необходимые пакеты
using LinearAlgebra  # Для работы с линейной алгеброй
using StaticArrays  # Для работы с статическими массивами
using Plots  # Для визуализации данных

# Определяем структуру для двумерного вектора
struct Vector2D{T<:Real} <: FieldVector{2, T} 
    x::T  # Координата по оси X
    y::T  # Координата по оси Y
end

# Для удобства определяем размерность структуры Vector2D
Base.size(::Type{Vector2D}) = (2,)

# Определяем доступ к элементам вектора по индексу
Base.getindex(v::Vector2D, i::Int) = i == 1 ? v.x : v.y
Base.setindex!(v::Vector2D, val, i::Int) = i == 1 ? (v.x = val) : (v.y = val)

# Определяем структуру для отрезка на плоскости
struct Segment2D{T<:Real}
    A::Vector2D{T}  # Начальная точка отрезка
    B::Vector2D{T}  # Конечная точка отрезка
end

# Функция для вычисления косого произведения двух векторов
xdot(a::Vector2D, b::Vector2D{T}) where T = a.x * b.y - a.y * b.x

# Функция для вычисления косинуса угла между двумя векторами
Base.cos(a::Vector2D{T}, b::Vector2D{T}) where T = dot(a, b) / norm(a) / norm(b)

# Функция для вычисления синуса угла между двумя векторами
Base.sin(a::Vector2D{T}, b::Vector2D{T}) where T = xdot(a, b) / norm(a) / norm(b)

# Функция для вычисления угла между двумя векторами
Base.angle(a::Vector2D{T}, b::Vector2D{T}) where T = atan(sin(a, b), cos(a, b))

# Функция для определения знака синуса угла между двумя векторами
Base.sign(a::Vector2D{T}, b::Vector2D{T}) where T = sign(sin(a, b))

# Функция для определения, принадлежит ли точка отрезку
function isinner(P::Vector2D, s::Segment2D)::Bool
    (s.A.x <= P.x <= s.B.x || s.A.x >= P.x >= s.B.x) &&
    (s.A.y <= P.y <= s.B.y || s.A.y >= P.y >= s.B.y)
end

# Функция для определения, лежат ли две точки по одну сторону от прямой
function is_one(P::Vector2D{T}, Q::Vector2D{T}, s::Segment2D{T}) where T 
    l = s.B - s.A
    return sin(l, P - s.A) * sin(l, Q - s.A) > 0    
end

# Функция для определения, лежит ли точка внутри многоугольника
function isinside(point::Vector2D{T}, polygon::AbstractArray{Vector2D{T}})::Bool where T
    @assert length(polygon) > 2  # Проверяем, что количество вершин многоугольника больше 2

    sum = zero(Float64)

    for i in firstindex(polygon):lastindex(polygon)
        sum += angle(polygon[i] - point, polygon[i % lastindex(polygon) + 1] - point)
    end
    
    return abs(sum) > π
end

# Функция для определения, является ли многоугольник выпуклым
function isconvex(polygon::AbstractArray{Vector2D{T}})::Bool where T
    @assert length(polygon) > 2  # Проверяем, что количество вершин многоугольника больше 2

    for i in firstindex(polygon):lastindex(polygon)
        if angle(polygon[i > firstindex(polygon) ? i - 1 : lastindex(polygon)] - polygon[i], 
                 polygon[i % lastindex(polygon) + 1] - polygon[i]) <= 0
            return false
        end
    end
    
    return true
end

# Алгоритм Джарвиса для построения выпуклой оболочки
function jarvis!(points::AbstractArray{Vector2D{T}})::AbstractArray{Vector2D{T}} where T
    points = copy(points)  # Копируем массив точек
    function next!(convex_shell2::AbstractVector{Int64}, points2::AbstractVector{Vector2D{T}}, ort_base::Vector2D{T})::Int64 where T
        cos_max = typemin(T)
        i_base = convex_shell2[end]
        resize!(convex_shell2, length(convex_shell2) + 1)
        for i in eachindex(points2)
            if points2[i] == points2[i_base]
                continue
            end
            ort_i = points2[i] - points2[i_base]
            cos_i = dot(ort_base, ort_i) / (norm(ort_base) * norm(ort_i))
            if cos_i > cos_max
                cos_max = cos_i
                convex_shell2[end] = i
            elseif cos_i == cos_max && dot(ort_i, ort_i) > dot(ort_base, ort_base)
                convex_shell2[end] = i
            end
        end
        return convex_shell2[end]
    end

    @assert length(points) > 1  # Проверяем, что количество точек больше 1
    ydata = [points[i].y for i in firstindex(points):lastindex(points)]
    i_start = findmin(ydata)
    convex_shell = [i_start[2]]
    ort_base = Vector2D(oneunit(T), zero(T))

    while next!(convex_shell, points, ort_base) != i_start[2]
        ort_base = points[convex_shell[end]] - points[convex_shell[end-1]]
    end

    pop!(convex_shell)

    return
