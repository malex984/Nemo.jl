###############################################################################
#
#   Types.jl : Parent and object types for Singular types
#
###############################################################################

# export SingularField, SingularFieldElem, Coeffs, NumberElem, \
# SingularQQ, SingularZZ
# export elem_type, base_ring, check_parent, show
# export characteristic 

using Cxx

###############################################################################
#
#   Singular low-level wrappers for coeffs
#
###############################################################################

include("libSingular.jl")

using .libSingular

__singular_init__() = libSingular.__libSingular_init__()

using Cxx

###############################################################################
#
#   SingularCoeffs (Fields)
#
###############################################################################

### See ../../src/AbstractTypes.jl:
#   abstract Ring{T} <: Group{T}
#   abstract Field{T} <: Ring{T}

#   abstract RingElem <: GroupElem
#   abstract FieldElem <: RingElem

#   abstract PolyElem{T} <: RingElem
#   abstract ResidueElem{T} <: RingElem
#   abstract FractionElem{T} <: FieldElem

#   abstract IntegerRingElem <: RingElem
#   abstract FiniteFieldElem <: FieldElem
#   abstract NumberFieldElem <: FieldElem

abstract SingularRing <: Ring{Singular}
abstract SingularRingElem <: RingElem

#####  TODO: ATM SingularField & SingularFieldElem are not recognised by Nemo as Filed/FieldElem!!!
#abstract SingularField <: SingularRing
#abstract SingularFieldElem <: SingularRingElem

#####  Previously it was as follows:
abstract SingularField <: Field{Singular}
abstract SingularFieldElem <: FieldElem


include("Coeffs.jl")
include("NumberElem.jl")

###############################################################################
#
#   SingularPolynomial (Rings)
#
###############################################################################

abstract SingularPolynomialRing <: Ring{Singular}
abstract SingularPolynomialElem <: RingElem

# typealias SingularRing 

include("PRings.jl")

# include("PRingElem.jl?")

#type SingularPolynomial <: PolyElem
#end
