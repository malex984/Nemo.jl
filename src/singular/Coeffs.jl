typealias coeffs libSingular.coeffs; typealias n_coeffType libSingular.n_coeffType;

const CoeffID = ObjectIdDict() # All Coeffs are to be unique!
const Coeff_ID = ObjectIdDict() # All Coeffs are to be unique!

# TODO Coeffs: Integer which is a Ring...?
type Coeffs <: SingularRing
   ptr :: libSingular.coeffs

   function Coeffs(nt::libSingular.n_coeffType) 
      par = Ptr{Void}(0)
      try
         return CoeffID[nt, par]
      catch
      end

      ptr = libSingular.nInitChar(nt, par) # unique!
      (ptr == libSingular.coeffs(0)) && error("Singular coeffs.domain construction failure")
      try
         cf = CoeffID[ptr]
	 libSingular.nKillChar(ptr)
	 return cf
      catch
         d = CoeffID[nt, par] = CoeffID[ptr] = new(ptr)
         finalizer(d, _Coeffs_clear_fn)
         return d
      end
   end

   function Coeffs(nt::libSingular.n_coeffType, par::Ptr{Void}) 
      try
         return CoeffID[nt, par]
      catch
      end

      ptr = libSingular.nInitChar(nt, par)
      (ptr == libSingular.coeffs(0)) && error("Singular coeffs.domain construction failure")
      try
         cf = CoeffID[ptr]
	 libSingular.nKillChar(ptr)
	 return cf
      catch
         d = CoeffID[nt, par] = CoeffID[ptr] = new(ptr)
         finalizer(d, _Coeffs_clear_fn)
         return d
      end
   end

   function Coeffs(ptr::libSingular.coeffs) 
      (ptr == libSingular.coeffs(0)) && error("Singular Coeffs construction failure: wrong raw pointer")
      try
         cf = CoeffID[ptr]
	 return cf
      catch
         d = CoeffID[ptr] = new(ptr)
         finalizer(d, _Coeffs_clear_fn)
         return d
      end
   end
end


type CoeffsField <: SingularField
   ptr :: libSingular.coeffs

   function CoeffsField(nt::libSingular.n_coeffType) 
      try
         return Coeff_ID[nt, par]
      catch
      end

      ptr = libSingular.nInitChar(nt, Ptr{Void}(0)) # unique!
      (ptr == libSingular.coeffs(0)) && error("Singular coeffs.domain construction failure")
      try
         cf = Coeff_ID[ptr]
	 libSingular.nKillChar(ptr)
	 return cf
      catch
         d = Coeff_ID[nt, par] = Coeff_ID[ptr] = new(ptr)
         finalizer(d, _Coeffs_clear_fn)
         return d
      end
   end

   function CoeffsField(nt::libSingular.n_coeffType, par::Ptr{Void}) 
      try
         return Coeff_ID[nt, par]
      catch
      end

      ptr = libSingular.nInitChar(nt, par)
      (ptr == libSingular.coeffs(0)) && error("Singular coeffs.domain construction failure")
      try
         cf = Coeff_ID[ptr]
	 libSingular.nKillChar(ptr)
	 return cf
      catch
         d = Coeff_ID[nt, par] = Coeff_ID[ptr] = new(ptr)
         finalizer(d, _Coeffs_clear_fn)
         return d
      end
   end

   function CoeffsField(ptr::libSingular.coeffs) 
      (ptr == libSingular.coeffs(0)) && error("Singular Coeffs construction failure: wrong raw pointer")
      try
         cf = Coeff_ID[ptr]
	 return cf
      catch
         d = Coeff_ID[ptr] = new(ptr)
         finalizer(d, _Coeffs_clear_fn)
         return d
      end
   end
end

function _Coeffs_clear_fn(cf::SingularCoeffs)
   libSingular.nKillChar( get_raw_ptr(cf) )
end

get_raw_ptr(cf::SingularCoeffs) = cf.ptr
function get_raw_ptr(cf::SingularCoeffs)
   ptr = cf.ptr;
   @assert (ptr != libSingular.coeffs(0))
   return ptr
end


###############################################################################
#
#   Parameters and characteristic
#
###############################################################################


characteristic(c::SingularCoeffs) = libSingular.n_GetChar( get_raw_ptr(c) )

# char const * * n_ParameterNames(const coeffs r)

ngens(c::SingularCoeffs) = libSingular.n_NumberOfParameters( get_raw_ptr(c) )

function gen(i::Int, c::SingularCoeffs) 
    ((i >= 1) && (i <= ngens(c))) && return c(libSingular.n_Param(i, get_raw_ptr(c)))
    error("Wrong parameter index")
end 


###############################################################################
#
#   String I/O
#
###############################################################################
function _string(c::SingularCoeffs)
   cf = get_raw_ptr(c)
   m = libSingular.nCoeffString(cf)
   mm = libSingular.nCoeffName(cf)

   return bytestring(mm) * "|[" * bytestring(m) * "]"

   ### TODO: omFree m/mm???
end

function string(c::SingularRing)
   return "SingularRing(" * _string(c) * ")"
end

function string(c::SingularField)
   return "SingularField(" * _string(c) * ")"
end

function string(c::SingularUniqueRing)
   return "SingularUniqueRing(" * _string(c) * ")"
end

function string(c::SingularUniqueField)
   return "SingularUniqueField(" * _string(c) * ")"
end

# r->is_field==0
isring(c::SingularCoeffs) = libSingular.nCoeff_is_Ring(get_raw_ptr(c))

# returns TRUE, if r is a field or r has no zero divisors (i.e is a domain)
# r->is_domain
isdomain(c::SingularCoeffs) = libSingular.nCoeff_is_Domain(get_raw_ptr(c))

show(io::IO, c::SingularCoeffs) = print(io, string(c))

###############################################################################
#
#   Basic manipulation
#
###############################################################################

function hash(a::SingularCoeffs)
#   h = 0x8a30b0d963237dd5 # TODO: change this const to something uniqe!
   return hash(string(a))  ## TODO: string may be a bit too inefficient wherever hash is used...?
end

zero(a::SingularCoeffs) = a(Int(0))
one(a::SingularCoeffs) = a(Int(1))
mone(a::SingularCoeffs) = a(Int(-1))


###############################################################################
#
#   Shortcuts to basic singular coeffs
#
###############################################################################

# SingularRing:

# unique => Number_Elem is possible!
immutable Singular_ZZ <: SingularUniqueRing
end

function get_raw_ptr(::Singular_ZZ)
   ptr = libSingular.ptr_ZZ
   @assert ptr != libSingular.coeffs(0)
   return ptr
end

global uq_default_choice = true # e.g. for testing both non-unique and unique reps. of rings/fields 

function toggle_uq_default_choice() 
    uq_default_choice = !uq_default_choice
end

# ~BigInt?
SingularZZ() = ( uq_default_choice ? Singular_ZZ() : Coeffs(libSingular.n_Z()) )

# SingularField:

# unique => NumberF_Elem is possible!

immutable Singular_QQ <: SingularUniqueField
end

immutable Singular_RR <: SingularUniqueField
end

immutable Singular_CC <: SingularUniqueField
end

immutable Singular_Rr <: SingularUniqueField
end

function get_raw_ptr(::Singular_QQ)
   ptr = libSingular.ptr_QQ
   @assert ptr != libSingular.coeffs(0)
   return ptr
end

get_raw_ptr(::Singular_RR) = libSingular.ptr_RR
get_raw_ptr(::Singular_CC) = libSingular.ptr_CC
get_raw_ptr(::Singular_Rr) = libSingular.ptr_Rr

# Rational{BigInt}
# false
SingularQQ() = ( uq_default_choice ? Singular_QQ() : CoeffsField(libSingular.n_Q()) ) 

# BigFloats
SingularRR() = ( uq_default_choice ? Singular_RR() : CoeffsField(libSingular.n_long_R()) )
SingularCC() = ( uq_default_choice ? Singular_CC() : CoeffsField(libSingular.n_long_C()) )
SingularRr() = ( uq_default_choice ? Singular_Rr() : CoeffsField(libSingular.n_R()) ) # single prescision (6,6) real numbers

# non-unique => NumberFElem
SingularFp(p::Int) = CoeffsField(libSingular.n_Zp(), Ptr{Void}(p));

SingularZp(p::Int) = Coeffs(libSingular.n_Zp(), Ptr{Void}(p));

function SingularGF(ch::Int, d::Int, s::AbstractString) 
   ptr = @cxx nGFInitChar(ch, d, pointer(s))
   @assert ptr != libSingular.coeffs(0)
   return CoeffsField(ptr);
end


###############################################################################
#
#   Uniqueness for basic singular coeffs
#
###############################################################################

# Note: dynamic checks in run-time ... 

#### with parameters...
#n_Zp() => false   /**< \F{p < 2^31} */

#n_GF() => false   /**< \GF{p^n < 2^16} */
#n_algExt() => false /**< used for all algebraic extensions, i.e.,the top-most extension in an extension tower is algebraic */
#n_transExt()=>false /**< used for all transcendental extensions, i.e.,the top-most extension in an extension tower is transcendental
#n_Zn() => false 
#n_Znm() => false
#n_Z2m() => false

#n_CF() => false????? Custom Coeffs?

#### no parameters:
#n_Q()  => true    /**< rational (GMP) numbers */
#n_R() => true     /**< single prescision (6,6) real numbers */
#n_long_R() => true  /**< real floating point (GMP) numbers */
#n_long_C() => true  /**< complex floating point (GMP) numbers */
#n_Z() => true 

#isparameterlessdomain(t::libSingular.n_coeffType) = 
#     (t in (libSingular.n_Z(), libSingular.n_Q(), libSingular.n_R(), libSingular.n_long_R(), libSingular.n_long_C())) 

# isunique(cf::SingularCoeffs) = isparameterlessdomain(libSingular.getCoeffType(get_raw_ptr(cf)))


isunique(::SingularUniqueRing) = true
isunique(::SingularUniqueField) = true
isunique(cf::SingularCoeffs) = false
