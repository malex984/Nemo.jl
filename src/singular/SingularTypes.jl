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

abstract SingularUniqueRing <: SingularRing
abstract SingularUniqueRingElem <: SingularRingElem


#####  TODO: ATM SingularField & SingularFieldElem are not recognised by Nemo as Filed/FieldElem:
#abstract SingularField <: SingularRing
#abstract SingularFieldElem <: SingularRingElem

#####  Now it is as follows:
abstract SingularField <: Field{Singular}
abstract SingularFieldElem <: FieldElem

abstract SingularUniqueField <: SingularField
abstract SingularUniqueFieldElem <: SingularFieldElem

#####  All the basic coeffs on the Julia side: forcefully merge diverging type branches to share the low-level implementation
typealias SingularCoeffs Union{SingularRing,SingularField}
typealias SingularCoeffsElems Union{SingularRingElem,SingularFieldElem}

include("Coeffs.jl")
include("NumberElem.jl")

###############################################################################
#
#   SingularPolynomial (Rings)
#
###############################################################################

# NOTE: only one sort of polynomials in Nemo, right?
abstract SingularPolynomialRing <: Ring{Singular}
abstract SingularPolynomialElem <: RingElem

# typealias SingularRing 

include("PRings.jl")

# include("PRingElem.jl?")

#type SingularPolynomial <: PolyElem
#end
