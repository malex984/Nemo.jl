###############################################################################
#
#   Types.jl : Parent and object types for Singular types
#
###############################################################################

# export SingularField, SingularFieldElem, Coeffs, NumberElem, SingularQQ, SingularZZ
# export elem_type, base_ring, check_parent, show
# export characteristic 

using Cxx

###############################################################################
#
#   SingularFields
#
###############################################################################

abstract SingularField <: Field{Singular}
abstract SingularFieldElem <: FieldElem ### {Singular}?

# typealias SingularRing 
abstract SingularRingElem <: RingElem ### {Singular}?

#type SingularPolynomialRing <: Ring{Singular} # SingularRing
#end

#type SingularPolynomial <: PolyElem
#end

include("libSingular.jl")

using .libSingular

__singular_init__() = libSingular.__libSingular_init__()

using Cxx

include("Coeffs.jl")
include("NumberElem.jl")

