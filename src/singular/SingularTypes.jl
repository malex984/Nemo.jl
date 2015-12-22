###############################################################################
#
#   Types.jl : Parent and object types for Singular types
#
###############################################################################

# export SingularField, SingularFieldElem, Coeffs, NumberElem, \
# SingularQQ, SingularZZ
# export elem_type, base_ring, check_parent, show
# export characteristic 
export mullow

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

#### T :: Type of base_elem, e.g. ZZ for QQ
#   abstract PolyElem{T} <: RingElem
#   abstract ResidueElem{T} <: RingElem
#   abstract FractionElem{T} <: FieldElem

#   abstract IntegerRingElem <: RingElem
#   abstract FiniteFieldElem <: FieldElem
#   abstract NumberFieldElem <: FieldElem



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

function mullow{T <: SingularCoeffsElems}(a::PolyElem{T}, b::PolyElem{T}, n::Int)
   check_parent(a, b)
   lena = length(a)
   lenb = length(b)

   if lena == 0 || lenb == 0
      return zero(parent(a))
   end

   if n < 0
      n = 0
   end

   lenz = min(lena + lenb - 1, n)

   d = zeros(T, lenz) # TODO: no real need in this intialization... :(

   for i = 1:min(lena, lenz)
      d[i] = coeff(a, i - 1)*coeff(b, 0)
   end

   if lenz > lena
      for j = 2:min(lenb, lenz - lena + 1)
          d[lena + j - 1] = coeff(a, lena - 1)*coeff(b, j - 1)
      end
   end

   println("MULLOW!!!!"); # println(d);

#   t = T(0)

   for i = 1:lena - 1
      if lenz > i
         for j = 2:min(lenb, lenz - i + 1)

#            mul!(t, coeff(a, i - 1), b.coeffs[j]) # TODO: FIXME: should be improved!?
#            addeq!(d[i + j - 1], t)#?

	     d[i + j - 1] += ( coeff(a, i - 1) * b.coeffs[j] )
         end
      end
   end
     
   z = parent(a)(d)
   
   set_length!(z, normalise(z, lenz))

   return z
end


function pow_multinomial{T <: SingularCoeffsElems}(a::PolyElem{T}, e::Int)
   e < 0 && throw(DomainError())
   lena = length(a)
   lenz = (lena - 1) * e + 1
   res = Array(T, lenz)
   for k = 1:lenz
      res[k] = base_ring(a)()
   end
   d = base_ring(a)()
   first = coeff(a, 0)
   res[1] = first ^ e
   for k = 1 : lenz - 1
      u = -k
      for i = 1 : min(k, lena - 1)
         t = coeff(a, i) * res[(k - i) + 1]
         u += e + 1
         addeq!(res[k + 1], t * u) ## !!!
      end
      addeq!(d, first) ## !!!
      res[k + 1] = divexact(res[k + 1], d) ## ?????!
   end
   z = parent(a)(res)
   set_length!(z, normalise(z, lenz))
   return z
end


function ^{T <: SingularCoeffsElems}(a::PolyElem{T}, b::Int)
   b < 0 && throw(DomainError())
   # special case powers of x for constructing polynomials efficiently
   if isgen(a)
      d = Array(T, b + 1)
      d[b + 1] = coeff(a, 1)
      for i = 1:b
         d[i] = coeff(a, 0)
      end
      z = parent(a)(d)
      set_length!(z, b + 1)
      return z
   elseif length(a) == 0
      return zero(parent(a))
   elseif length(a) == 1
      return parent(a)(coeff(a, 0)^b)
   elseif b == 0
      return one(parent(a))
   else
      if T <: SingularFieldElem
         zn = 0
         while iszero(coeff(a, zn))
            zn += 1
         end
         if length(a) - zn < 8 && b > 4
             f = shift_right(a, zn)
             return shift_left(pow_multinomial(f, b), zn*b)  ### BUG ???
         end
      end
      bit = ~((~UInt(0)) >> 1)
      while (UInt(bit) & b) == 0
         bit >>= 1
      end
      z = a
      bit >>= 1
      while bit != 0
         z = z*z
         if (UInt(bit) & b) != 0
            z *= a
         end
         bit >>= 1
      end
      return z
   end
end

#WARNING: New definition #is ambiguous with: 

# promote_rule(Type{Nemo.Mat{#T<:Nemo.RingElem}}, Type{#T<:Nemo.RingElem})
#      at /home/malex/.julia/v0.4/Nemo/src/generic/Matrix.jl:2357
# promote_rule(Type{Nemo.Mat{#T<:Nemo.RingElem}}, Type{#S<:Union{Nemo.SingularRingElem, Nemo.SingularFieldElem}})
#      at /home/malex/.julia/v0.4/Nemo/src/singular/SingularTypes.jl:225.
#To fix, define before the new definition:

# promote_rule(Type{Nemo.Mat{_<:Union{Nemo.SingularRingElem, Nemo.SingularFieldElem}}}, Type{_<:Union{Nemo.SingularRingElem, Nemo.SingularFieldElem}})

Base.promote_rule{T <: SingularCoeffsElems}(::Type{Nemo.Mat{T}}, ::Type{T}) = Mat{T}
Base.promote_rule{T <: RingElem, S <: SingularCoeffsElems}(::Type{Mat{T}}, ::Type{S}) = Mat{T}

### TODO: the following will require retesting Fraction Field functionality as currently Singular_QQ and its elems are not FractionField/Elem!!! Q: how to reuse the implementation???


FractionField(::Singular_ZZ) = Singular_QQ() ## TODO: TEST ME!!!!


call(a::Singular_QQ) = Singular_QQElem(0)
call(a::Singular_QQ, b::Integer) = Singular_QQElem(b)

call(a::Singular_QQ, b::Int, c::Int) = Singular_QQElem(b, c)

call(a::Singular_QQ, b::Integer, c::Integer) = Singular_QQElem(b, c)

call(a::Singular_QQ, b::Singular_ZZElem, c::Integer) = Singular_QQElem(b, Singular_ZZElem(c))
call(a::Singular_QQ, b::Integer, c::Singular_ZZElem) = Singular_QQElem(Singular_ZZElem(b), c)

call(::Singular_QQ, b::Singular_ZZElem, c::Singular_ZZElem) = Singular_QQElem(b, c)
call(::Singular_QQ, b::Singular_QQElem) = b

# Base.call(C::Singular_QQ, a, b) =  Singular_QQElem(a, b)
call(C::Singular_QQ, a::Singular_ZZElem) = C(a, Singular_ZZElem(1))
call{T}(C::Singular_QQ, a::FractionElem{T}) = C(num(a), den(a))

convert(::Type{Singular_QQElem}, a::Integer) = Singular_QQElem(a)
convert(::Type{Singular_QQElem}, a::Singular_ZZElem) = Singular_QQElem(a)

Base.promote_rule{T <: Integer}(::Type{Singular_ZZElem}, ::Type{T}) = Singular_ZZElem

Base.promote_rule{T <: Integer}(::Type{Singular_QQElem}, ::Type{T}) = Singular_QQElem
Base.promote_rule(::Type{Singular_QQElem}, ::Type{Singular_ZZElem}) = Singular_QQElem



call{T<:Integer}(::Singular_QQ, b::Rational{T}) = Singular_QQElem(num(b), den(b)) 
convert{T<:Integer}(C::Type{Rational{T}}, a::Singular_ZZElem) = C(T(Int(a)), T(Int(1)))
convert{T<:Integer}(C::Type{Rational{T}}, a::Singular_QQElem) = C(T(Int(num(a))), T(Int(den(a))))

##call{T<:Integer}(::Singular_QQ, b::Rational{T}) = Singular_QQElem(num(b), den(b)) 




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

divexact(a :: Singular_QQElem,  b ::Singular_QQElem) = ( a // b )

divexact(a::Singular_QQElem, z::Singular_ZZElem) = divexact( a, parent(a)(z) )
divexact(z::Singular_ZZElem, a::Singular_QQElem) = divexact( parent(a)(z), a )


mod(a::Singular_QQElem, z::Singular_ZZElem) = mod( a, parent(a)(z) )
mod(z::Singular_ZZElem, a::Singular_QQElem) = mod( parent(a)(z), a )


function ResidueRing(R::Singular_ZZ, el::Integer)
   el == 0 && throw(DivideError())
   
   return ResidueRing{Singular_ZZElem}(R(el))
end

##### TODO: FIXME: 
## gcd(a::Singular_QQElem, b::Singular_QQElem) = 1?
## div(a::Singular_QQElem, b::Singular_QQElem) = a // b?
## mod(a::Singular_QQElem, b::Singular_QQElem) = 0?


#end
