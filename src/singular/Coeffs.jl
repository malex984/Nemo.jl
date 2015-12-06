typealias coeffs libSingular.coeffs

const CoeffID = ObjectIdDict()
#const SRingID = ObjectIdDict()

type Coeffs <: SingularField
   ptr :: libSingular.coeffs

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

function _Coeffs_clear_fn(cf::Coeffs)
   libSingular.nKillChar( get_raw_ptr(cf) )
end

get_raw_ptr( cf::Coeffs ) = cf.ptr

###############################################################################
#
#   Parameters and characteristic
#
###############################################################################


characteristic(c::Coeffs) = libSingular.n_GetChar( get_raw_ptr(c) )

# char const * * n_ParameterNames(const coeffs r)

npars(c::Coeffs) = libSingular.n_NumberOfParameters( get_raw_ptr(c) )

function par(i::Int, c::Coeffs) 
    ((i >= 1) && (i <= npars(c))) && return c(libSingular.n_Param(i, get_raw_ptr(c)))
    error("Wrong parameter index")
end 


###############################################################################
#
#   String I/O
#
###############################################################################

function string(c::Coeffs)
   cf = get_raw_ptr(c)
   m = libSingular.nCoeffString(cf)
   mm = libSingular.nCoeffName(cf)

   return "SingularCoeffs(" * bytestring(mm) * "|[" * bytestring(m) * "])"
end

isring(c::Coeffs) = libSingular.nCoeff_is_Ring(get_raw_ptr(c))
isdomain(c::Coeffs) = libSingular.nCoeff_is_Domain(get_raw_ptr(c))

show(io::IO, c::Coeffs) = print(io, string(c))

SingularQQ() = Coeffs(libSingular.n_Q(), Ptr{Void}(0)); # SingularRationalField()
SingularZZ() = Coeffs(libSingular.n_Z(), Ptr{Void}(0)); # SingularRing()



###############################################################################
#
#   Basic manipulation
#
###############################################################################

function hash(a::Coeffs)
#   h = 0x8a30b0d963237dd5 # TODO: change this const to something uniqe!
   return hash(string(a))  ## TODO: string may be a bit too inefficient wherever hash is used...?
end

zero(a::Coeffs) = a(0)
one(a::Coeffs) = a(1)
mone(a::Coeffs) = a(-1)



