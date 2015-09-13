################################################################################
#
#   Fields.jl : generic fields
#
################################################################################

include("generic/Fraction.jl")

include("flint/fmpq.jl")

include("flint/fq.jl")

include("flint/fq_nmod.jl")

include("antic/nf_elem.jl")

include("pari/pari_nf.jl")

//{T <: FieldElem}(a::T, b::T) = divexact(a, b)

function gcd{T <: FieldElem}(x::T, y::T)
   check_parent(x, y)
   return iszero(x) && iszero(y) ? zero(parent(y)) : one(parent(y))
end



