# Функция для решения СЛАУ методом обратной подстановки Гаусса для вектора правой части b
function reverse_gauss(A::AbstractMatrix{T}, b::AbstractVector{T}) where T
    x = similar(b)  # Создаем вектор для хранения решения
    N = size(A, 1)  # Получаем размерность матрицы A
    @inbounds for k in 0:N-1
        # На каждом шаге k решаем уравнение для x[N-k]
        @views x[N-k] = (b[N-k] - sum(A[N-k,N-k+1:end] .* x[N-k+1:end])) / A[N-k,N-k]
    end
    return x
end

# Функция для решения СЛАУ методом обратной подстановки Гаусса для матрицы правой части b
function reverse_gauss(A::AbstractMatrix{T}, b::AbstractMatrix{T}) where T
    x = similar(b)  # Создаем матрицу для хранения решения
    N = size(A, 1)  # Получаем размерность матрицы A
    @inbounds for k in 0:N-1
        # На каждом шаге k решаем уравнения для x[N-k,:]
        @views x[N-k] = (b[N-k] - sum(A[N-k,N-k+1:end] .* x[N-k+1:end])) / A[N-k,N-k]
    end
    return x
end

# Функция для решения СЛАУ методом обратной подстановки Гаусса для вектора правой части b
# с использованием внутренней функции sumprod для ускорения вычислений
function reverse_gauss_columns(A::AbstractMatrix{T}, b::AbstractVector{T}) where T
    x = similar(b)  # Создаем вектор для хранения решения
    N = size(A, 1)  # Получаем размерность матрицы A
    for k in 0:N-1
        # На каждом шаге k решаем уравнение для x[N-k]
        x[N-k] = (b[N-k] - sumprod(@view(A[N-k,N-k+1:end]), @view(x[N-k+1:end]))) / A[N-k,N-k]
    end
    return x
end
     
# Функция для решения СЛАУ методом обратной подстановки Гаусса для матрицы правой части b
# с использованием внутренней функции sumprod для ускорения вычислений
function reverse_gauss(A::AbstractMatrix{T}, b::AbstractMatrix{T}) where T
    x = similar(b)  # Создаем матрицу для хранения решения
    N = size(A, 1)  # Получаем размерность матрицы A
    for k in 0:N-1
        # На каждом шаге k решаем уравнения для x[N-k,:]
        x[N-k] = (b[N-k] - sumprod(@view(A[N-k,N-k+1:end]), @view(x[N-k+1:end]))) / A[N-k,N-k]
    end
    return x
end

# Вспомогательная функция для вычисления скалярного произведения векторов
@inline function sumprod(vec1::AbstractVector{T}, vec2::AbstractVector{T})::T where T
    s = zero(T)  # Начальное значение суммы
    @inbounds for i in eachindex(vec1)
        s = fma(vec1[i], vec2[i], s)  # Вычисление скалярного произведения
    end
    return s
end

# Функция для приведения матрицы к ступенчатому виду
function transform_to_steps(A::AbstractMatrix; epsilon = 1e-5, for_det = false)
    A = copy(A)  # Создаем копию матрицы, чтобы не изменять исходную
    c = 1  # Переменная для хранения знака перестановок строк
    @inbounds for k ∈ 1:size(A, 1)
        try
            absval, Δk = findmax(abs, @view(A[k:end,k]))  # Находим максимальный элемент в столбце
            (absval <= epsilon) && throw("Вырожденая матрица")  # Проверяем на вырожденность
            if Δk > 1
                c = -c
                swap!(@view(A[k,k:end]), @view(A[k+Δk-1,k:end]))  # Перестановка строк для получения максимального элемента на диагонали
            end
            for i in k+1:size(A,1)
                t = A[i,k]/A[k,k]  # Вычисляем множитель для устранения элементов под диагональю
                @. @views A[i,k:end] = A[i,k:end] .- t .* A[k,k:end]  # Вычитаем соответствующие строки
            end
        catch
            continue
        end
    end
    if for_det return A, c end  # Возвращаем преобразованную матрицу и знак перестановок для вычисления определителя
    return A  # Возвращаем преобразованную матрицу
end
    
# Функция для решения СЛАУ методом Гаусса
function gauss(A::AbstractMatrix, b)
    A = transform_to_steps(A)  # Приводим матрицу к ступенчатому виду
    return reverse_gauss_columns(A,b)  # Решаем систему уравнений обратной подстановкой
end

# Функция для вычисления определителя матрицы
function det_(A::AbstractMatrix)
    M, z = transform_to_steps(A, for_det = true)  # Приводим матрицу к ступенчатому виду с сохранением знака перестановок
    return z * prod([M[i, i] for i in 1:size(M)[]])
end