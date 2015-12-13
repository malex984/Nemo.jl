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
typealias SingularUniqueCoeffsElems Union{SingularUniqueRingElem,SingularUniqueFieldElem}

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

   d = zeros(T, lenz) # no need in intialization... :(

   for i = 1:min(lena, lenz)
      d[i] = coeff(a, i - 1)*coeff(b, 0)
   end

   if lenz > lena
      for j = 2:min(lenb, lenz - lena + 1)
          d[lena + j - 1] = coeff(a, lena - 1)*coeff(b, j - 1)
      end
   end

   print("d: "); println(d);

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

#end
