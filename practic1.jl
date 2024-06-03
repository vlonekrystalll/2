#3
include("dual.jl")
function valdiff(f::Function, x::T) where T
    x_dual = Dual(x, one(T))
    y_dual = f(x_dual)
    return y_dual.real, y_dual.dual
end
    
#4
include("p.jl")
function valdiff(p, x, d) 
    d = Dual(p(x), derivative(p)(x))
    return (d.real, d.dual)
end

(p::Polynomial)(x::Dual{T}) where T = Dual(p(x.real), derivative(p)(x.real))