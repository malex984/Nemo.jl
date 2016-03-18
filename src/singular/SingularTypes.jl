###############################################################################
#
#   Types.jl : Parent and object types for Singular types
#
###############################################################################

# export SingularField, SingularFieldElem, Coeffs, NumberElem, \
# SingularQQ, SingularZZ
export elem_type, parent_type, base_ring, check_parent, show
export characteristic
export mullow, den, num
export mul!, addeq!
export get_raw_ptr, parent
export PRingElem, PRing, PModuleElem, SingularIdeal, SingularModule, Singular_ZZElem

using Cxx

###############################################################################
#
#   Singular low-level wrappers for Singular structures and classes
#
###############################################################################

include("libSingular.jl")

using .libSingular

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


#### T :: Type of base_elem, e.g. ZZ for QQ
#   abstract PolyElem{T} <: RingElem
#   abstract ResidueElem{T} <: RingElem # Zp?
#   abstract FractionElem{T} <: FieldElem
#   abstract IntegerRingElem <: RingElem
#   abstract NumberFieldElem <: FieldElem # Alg Ext!
#   abstract FiniteFieldElem <: FieldElem


abstract SingularPolyElem{T} <:  PolyElem{T}

# RING
abstract SingularResidueElem{T} <: ResidueElem{T}

# FIELD
abstract SingularNumberFieldElem <: NumberFieldElem
abstract SingularFiniteFieldElem <: FiniteFieldElem

# Unique: RING & FIELD
abstract SingularIntegerRingElem <: IntegerRingElem # ZZ
abstract SingularFractionElem{T} <: FractionElem{T} # QQ, T = ZZ!? 

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

typealias SingularCoeffs Union{SingularRing, SingularField}

#####  All the basic coeffs on the Julia side: 
#####    forcefully merge diverging type branches to share the low-level implementation


# SingularPolyElem{T}, SingularResidueElem{T}
# SingularNumberFieldElem, SingularFiniteFieldElem
# SingularIntegerRingElem, SingularFractionElem{T}


typealias SingularRingElems Union{SingularRingElem, SingularUniqueRingElem, SingularIntegerRingElem}

typealias SingularFieldElems Union{SingularFieldElem, SingularUniqueFieldElem, SingularNumberFieldElem, SingularFiniteFieldElem, SingularFractionElem }

typealias SingularUniqueCoeffsElems Union{SingularUniqueRingElem, SingularUniqueFieldElem, SingularIntegerRingElem, SingularFractionElem}

# *Any* smart wrapper of a Singular number in order to share the wrappers as much as possible :
typealias SingularCoeffsElems Union{SingularRingElems,SingularFieldElems}

#### Singular_ZZElem, Singular_QQElem 

include("Coeffs.jl")
include("NumberElem.jl")
include("NumberCommons.jl") # Everything defined for any SingularCoeffsElems


Base.promote_rule{T <: SingularCoeffsElems}(::Type{Mat{T}}, ::Type{T}) = Mat{T}

#### ??????
Base.promote_rule{T <: RingElem, S <: SingularCoeffsElems}(::Type{Mat{T}}, ::Type{S}) = Mat{T}

### TODO: the following will require retesting Fraction Field functionality as currently Singular_QQ 
### and its elems are not FractionField/Elem!!! Q: how to reuse the implementation???

FractionField(::Singular_ZZ) = Singular_QQ() ## TODO: TEST ME!!!!


convert(::Type{Singular_QQElem}, a::Integer) = Singular_QQElem(a)
convert(::Type{Singular_QQElem}, a::Singular_ZZElem) = Singular_QQElem(a)

Base.promote_rule{T <: Integer}(::Type{Singular_ZZElem}, ::Type{T}) = Singular_ZZElem

Base.promote_rule{T <: Integer}(::Type{Singular_QQElem}, ::Type{T}) = Singular_QQElem
Base.promote_rule(::Type{Singular_QQElem}, ::Type{Singular_ZZElem}) = Singular_QQElem

convert{T<:Integer}(C::Type{Rational{T}}, a::Singular_ZZElem) = C(T(a), T(1))
convert{T<:Integer}(C::Type{Rational{T}}, a::Singular_QQElem) = C(T(num(a)), T(den(a)))


+(a::Singular_QQElem, z::Singular_ZZElem) = a + parent(a)(z)
+(z::Singular_ZZElem, a::Singular_QQElem) = parent(a)(z) + a 

-(a::Singular_QQElem, z::Singular_ZZElem) = a - parent(a)(z)
-(z::Singular_ZZElem, a::Singular_QQElem) = parent(a)(z) - a

*(a::Singular_QQElem, z::Singular_ZZElem) = a * parent(a)(z)
*(z::Singular_ZZElem, a::Singular_QQElem) = parent(a)(z) * a

//(a::Singular_QQElem, z::Singular_ZZElem) = a // parent(a)(z)
//(z::Singular_ZZElem, a::Singular_QQElem) = parent(a)(z) // a


//{T<:Integer}(z::Singular_ZZElem, a::T) = Singular_QQElem(z) // a
//{T<:Integer}(z::T, a::Singular_ZZElem) = z // Singular_QQElem(a)

isless(a::Singular_QQElem, z::Singular_ZZElem) = isless( a, parent(a)(z) )
isless(z::Singular_ZZElem, a::Singular_QQElem) = isless( parent(a)(z), a )

==(a::Singular_QQElem, z::Singular_ZZElem) = ( a == parent(a)(z) )
==(z::Singular_ZZElem, a::Singular_QQElem) = ( parent(a)(z) == a )

divexact(a :: Singular_QQElem, b :: Singular_QQElem) = ( a // b )

divexact(a :: Singular_QQElem, z :: Singular_ZZElem) = divexact( a, parent(a)(z) )
divexact(z :: Singular_ZZElem, a :: Singular_QQElem) = divexact( parent(a)(z), a )




function ResidueRing(R::Singular_ZZ, el::Integer)
   el == 0 && throw(DivideError())
   
   return ResidueRing{Singular_ZZElem}(R(el))
end

##### TODO: FIXME: common den -> ZZ & add that den.!
## add den & num : QQ -> ZZ! mappings!?

mod(a::Singular_QQElem, z::Integer) = mod(a, Singular_ZZElem(z))
div(a::Singular_QQElem, b::Singular_QQElem) = error("Error: no 'div' for Singular Rationals")


function gcd(a::Singular_QQElem, b::Singular_QQElem)
    aa = den(a)
    bb = den(b)
    return Singular_QQElem(gcd(bb* num(a), aa*num(b)), aa * bb)
end

function mod(a::Singular_QQElem, z::Singular_ZZElem)
    aa = den(a)
    return Singular_QQElem(mod(num(a), aa*z), aa)
end




###############################################################################
#
#   SingularPolynomial (Rings)
#
###############################################################################

# NOTE: only one sort of polynomials in Nemo, right?
abstract SingularPolynomialRing <: Ring{Singular}
abstract SingularPolynomialElem <: RingElem

# typealias SingularRing 
include("PRings.jl") # include("PRingElem.jl?")

characteristic(::Field) = 0
characteristic(::Ring) = 0

include("Interpreter.jl")

function __singular_init__() 
   libSingular.__libSingular_init__();
   SingularKernel.__init_singular_interpreter__();
end
