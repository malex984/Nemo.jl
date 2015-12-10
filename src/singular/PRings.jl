## typealias coeffs libSingular.coeffs

# PRingElem <: SingularPolynomialElem 

const SRingID = ObjectIdDict()

# typealias PRing SingPolyRing

type PRing <: SingularPolynomialRing
   ptr :: libSingular.ring  ### base_ring :: Ring    ### S::Symbol

   function PRing(cf::SingularCoeffs, vars::AbstractString{}) 
      try
          return SRingID[cf, vars]
      catch
      end

      # TODO: FIXME: switch from this POC to a proper generic construction
      ptr = @cxx test_create_ring2(get_raw_ptr(cf))

      (ptr == libSingular.ring(0)) && error("Singular polynomial ring construction failure")

      try
         R = SRingID[ptr]
	 @cxx rDelete(ptr) # libSingular.rDelete
	 return R
      catch
      end

      d = SRingID[cf, vars] = SRingID[ptr] = new(ptr)
      finalizer(d, _PRing_clear_fn)
      return d
   end

   function PRing(ptr::libSingular.ring) 
      (ptr == libSingular.ring(0)) && error("Singular polynomial ring construction failure")
      try
         R = SRingID[ptr]
	 return R
      catch
      end

      d = SRingID[ptr] = new(ptr)
      finalizer(d, _PRing_clear_fn)
      return d
   end
end

function _PRing_clear_fn(r::PRing)
   @cxx rDelete(get_raw_ptr(r))
end

get_raw_ptr(r::SingularPolynomialRing) = r.ptr

###############################################################################
#
#   Parameters and characteristic
#
###############################################################################


characteristic(r::Ring) = @cxx rChar(get_raw_ptr(c))

nvars(r::PRing) = @cxx rVar(get_raw_ptr(c))

function var(i::Int, r::PRing)
     ptr = @cxx test_create_poly(get_raw_ptr(cf))

#    ((i >= 1) && (i <= nvars(r))) && return p_Var(i, get_raw_ptr(c)))
#    error("Wrong indeterminate index (sorry not yet im)")

     return ptr # TODO: FIXME: return smart polynomial element...
end

###############################################################################
#
#   String I/O
#
###############################################################################

function string(r::PRing)
   ptr = get_raw_ptr(r)
   m = @cxx rString(ptr)
   s = "SingularPolynomialRing (" * bytestring(m)  * ")" # * ", over " * string(parent(r)) ???
   libSingular.omFree(m)

   return s
end

#isring(c::Singular?) = libSingular.nCoeff_is_Ring(get_raw_ptr(c))
#isdomain(c::Singular?) = libSingular.nCoeff_is_Domain(get_raw_ptr(c))

show(io::IO, r::PRing) = print(io, string(r))

#SingularQQ() = Coeffs(libSingular.n_Q(), Ptr{Void}(0)); # SingularRationalField()
#SingularZZ() = Coeffs(libSingular.n_Z(), Ptr{Void}(0)); # SingularRing()



###############################################################################
#
#   Basic manipulation
#
###############################################################################

function hash(a::PRing)
#   h = 0x8a30b0d963237dd5 # TODO: change this const to something uniqe!
   return hash(string(a))  ## TODO: string may be a bit too inefficient wherever hash is used...?
end

#zero(a::Singular?) = a(0)
#one(a::Singular?) = a(1)
#mone(a::Singular?) = a(-1)



