struct Polynomial{T}
    c::Vector{T}
    function Polynomial{T}(c::Vector{T}) where T
        while length(c) > 1 && iszero(c[begin])
            popfirst!(c)
        end
        new(c)
    end
end

# Красивый вывод многочленов

# Функция для получения подстрочного символа
function subscript(i::Integer)
    if i < 0
        error("$i is negative")
    end
    return join('₀' + d for d in reverse(digits(i)))
end

# Функция для получения надстрочного символа
function superscript(i::Integer)
    c = i < 0 ? [Char(0x207B)] : []
    for d in reverse(digits(abs(i)))
        push!(c, d == 0 ? Char(0x2070) :
                  d == 1 ? Char(0x00B9) :
                  d == 2 ? Char(0x00B2) :
                  d == 3 ? Char(0x00B3) :
                           Char(0x2070 + d))
    end
    return join(c)
end

# Функция для красивого вывода многочлена
function Base.display(p::Polynomial{T}) where T
    if T == Int || T == Float64
        s = ""
        n = length(p.c)
        
        if n > 1
            s = (p.c[1] == one(p.c[1]) ? "" : string(p.c[1])) * "x" * (n-1 == 1 ? "" : superscript(n-1))
            for i in 2:n-1
                if p.c[i] != zero(p.c[i])
                    s *= (p.c[i] > zero(p.c[i]) ? "+" : "-") *
                         (abs(p.c[i]) == one(p.c[i]) ? "" : string(abs(p.c[i]))) *
                         "x" * (n-i == 1 ? "" : superscript(n-i))
                end
            end
            if p.c[end] != zero(p.c[end])
                s *= (p.c[end] > zero(p.c[end]) ? "+" : "-") *
                     string(abs(p.c[end]))
            end
        else
            s = string(p.c[1])
        end

        println(s)
    else
        for i in 1:length(p.c)-1
            print("($(p.c[i]))x" * (length(p.c)-i == 1 ? "" : superscript(length(p.c)-i)) * " + ")
        end
        println("($(p.c[end]))")
    end
end












































