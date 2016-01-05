# PRingElem <: SingularPolynomialElem 

const SRingID = ObjectIdDict()

# typealias PRing SingPolyRing

type PRing <: SingularPolynomialRing
   ptr :: libSingular.ring
   base_ring :: SingularCoeffs

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

      d = SRingID[cf, vars] = SRingID[ptr] = new(ptr, cf)
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

      cf :: libSingular.coeffs = libSingular.rGetCoeffs(ptr)

      if isring(cf)
          d = SRingID[ptr] = new(ptr, Coeffs(cf))
          finalizer(d, _PRing_clear_fn)
          return d
      end

      d = SRingID[ptr] = new(ptr, CoeffsField(cf))
      finalizer(d, _PRing_clear_fn)
      return d
   end
end

function _PRing_clear_fn(r::PRing)
   @cxx rDelete(get_raw_ptr(r))
end

get_raw_ptr(R :: SingularPolynomialRing) = R.ptr

base_ring(R :: SingularPolynomialRing) = R.base_ring # TODO: ? verify complience! ???

#### parent(R :: SingularPolynomialRing) = base_ring(R) # TODO: ??????!

#==============================================================================#

## Generic with context
type PRingElem <: SingularPolynomialElem
    ptr :: libSingular.poly
    ctx :: SingularPolynomialRing

    function PRingElem(c :: SingularPolynomialRing, p :: libSingular.poly)
    	const r = get_raw_ptr(c);
	z = new(p_Test(p, r), c); 
	finalizer(z, _SingularPolyRingElem_clear_fn); 
	return z
    end

end

    function PRingElem()
    	error("Type PRingElem requires context reference")
    end

    function PRingElem(c :: SingularPolynomialRing)
    	const r = get_raw_ptr(c);
	const p = libSingular.p_Init(r); ### NOTE: Allocation without initialization!
    	return PRingElem(c, p)
#	z = new(p_Test(p, r), c); 
#	finalizer(z, _SingularPolyRingElem_clear_fn); 
#	return z
    end


    function PRingElem(c :: SingularPolynomialRing, x::Int64)
    	const r = get_raw_ptr(c);
        const p :: libSingular.poly = libSingular.p_ISet(x, r)
    	return PRingElem(c, p)
    end

    # NOTE: overtakes input n
    function PRingElem(c :: SingularPolynomialRing, n::number) 
    	const r = get_raw_ptr(c);
    	const p :: libSingular.poly = libSingular.p_NSet(n, r)
	return PRingElem(c, p)
    end 

    function PRingElem(c :: SingularPolynomialRing, b::BigInt) 
        cf = get_raw_ptr(base_ring(c))
        n = libSingular.n_InitMPZ(b, cf) # NOTE: will be overtaken!
	return PRingElem(c, n)
    end

    function PRingElem(x::PRingElem)
        const c = parent(x); 
    	const r = get_raw_ptr(c);
	const p :: libSingular.poly = libSingular.p_Copy(get_raw_ptr(x), r); 
    	return PRingElem(c, p)
    end

    PRingElem(c :: SingularPolynomialRing, z::Integer) = PRingElem(c, BigInt(z))
#    PRingElem(c :: SingularPolynomialRing, s::AbstractString) = parsePRingElem(c, s) # TODO: FIXME: go via Singular?!!


# For now - only one element type for any Singular Polynomial Ring...
elem_type{CF<:SingularPolynomialRing}(C::CF) = PRingElem

parent(p :: SingularPolynomialElem) = p.ctx

function check_parent(a::SingularPolynomialElem, b::SingularPolynomialElem)
   parent(a) != parent(b) && error("Operations on elements with different parents are not supported")
end

function get_raw_ptr(n :: SingularPolynomialElem)
   return p_Test(n.ptr, get_raw_ptr(parent(n)))
end

function set_raw_ptr!(n :: SingularPolynomialElem, p :: libSingular.poly)
   n.ptr = p;
   @assert (p == get_raw_ptr(n)); # Test...
end

function set_raw_ptr!(n :: SingularPolynomialElem, p :: libSingular.poly, C :: SingularPolynomialRing)
   n.ptr = p; n.ctx = C;
   @assert (p == get_raw_ptr(n)); # Test...
end

function _SingularPolyRingElem_clear_fn(p :: SingularPolynomialElem)
   libSingular._p_Delete(get_raw_ptr(p), get_raw_ptr(parent(p)))
   p.ptr = libSingular.poly(0); # no tests...
end

function hash(a::SingularPolynomialElem)
   return hash(parent(a)) $ hash(string(a))  ## TODO: string may be a bit too inefficient wherever hash is used...?
end

deepcopy(a::SingularPolynomialElem) = elem_type(parent(a))(a)

## PRingElem?
Base.call(A::SingularPolynomialRing) = elem_type(A)(A)
Base.call(A::SingularPolynomialRing, b::Int) = elem_type(A)(A, b)
Base.call(A::SingularPolynomialRing, b::Integer) = elem_type(A)(A, BigInt(b))
Base.call(A::SingularPolynomialRing, b::libSingular.poly) = elem_type(A)(A, b)

function Base.call(A::SingularPolynomialRing, b::SingularPolynomialElem)
   A != parent(b) && error("Operations on elements from different rings (mappings) are not supported yet!")
   return b ##   return deepcopy(b) # NOTE: fine no need in deepcopy!?? TODO?????
end


###############################################################################
#
#   Parameters and characteristic
#
###############################################################################

isring(c::SingularPolynomialRing) = true; ##libSingular.nCoeff_is_Ring(get_raw_ptr(c))
#isdomain(c::Singular?) = libSingular.nCoeff_is_Domain(get_raw_ptr(c))

characteristic(r::SingularPolynomialRing) = @cxx rChar(get_raw_ptr(r))

gen(r::SingularPolynomialRing) = geni( ngens(r), r) ## ??

ngens(r::SingularPolynomialRing) = @cxx rVar(get_raw_ptr(r))

function geni(i::Int, R::SingularPolynomialRing)
    const N = ngens(R);
    @assert ((i >= 1) && (i <= N))
    ((i < 1) || (i > N)) && error("Wrong generator/variable index");
    const r = get_raw_ptr(R);
    const p :: libSingular.poly = libSingular.p_ISet(1, r);
    libSingular.p_SetExp!(p, i, 1, r);    
    libSingular.p_Setm(p, r);
    return elem_type(R)(r, p) ## PRingElem?
end

###############################################################################
#
#   String I/O
#
###############################################################################

function string(r::SingularPolynomialRing)
   ptr = get_raw_ptr(r)
   m = @cxx rString(ptr)
   s = "SingularPolynomialRing (" * bytestring(m)  * ")" # * ", over " * string(parent(r)) ???
   libSingular.omFree(m)

   return s
end

show(io::IO, r::SingularPolynomialRing) = print(io, string(r))

###############################################################################
#
#   Basic manipulation
#
###############################################################################

function hash(a::SingularPolynomialRing)
#   h = 0x8a30b0d963237dd5 # TODO: change this const to something uniqe!
   return hash(string(a))  ## TODO: string may be a bit too inefficient wherever hash is used...?
end

## TODO: FIXME: avoid explicite constructor calls (PRingElem()) in the following: use elem_type?!
zero(R::SingularPolynomialRing) = elem_type(R)(R, libSingular.poly(0))
one(R::SingularPolynomialRing)  =  elem_type(R)(R, libSingular.p_One(get_raw_ptr(R)))
# mone(R::SingularPolynomialRing) =  elem_type(R)(R, -1)

function string(p::SingularPolynomialElem)
   const R = parent(p);   
   m = libSingular.p_String(get_raw_ptr(p), get_raw_ptr(R))
   s = "[" * bytestring(m)  * "" * " over " * string(R) * "]"
   libSingular.omFree(m)

   return s
end

show(io::IO, p::SingularPolynomialElem) = print(io, string(p))

        function +(x::SingularPolynomialElem, y::SingularPolynomialElem)
            check_parent(x, y)
            c = parent(x)
            p = libSingular.pp_Add_qq(get_raw_ptr(x), get_raw_ptr(y), get_raw_ptr(c));
            return c(p)
        end
        
        +(x::SingularPolynomialElem, i::Integer) = +(x, parent(x)(i)) 
        +(i::Integer, x::SingularPolynomialElem) = +(parent(x)(i), x)


        function *(x::SingularPolynomialElem, y::SingularPolynomialElem)
            check_parent(x, y)
            c = parent(x)
            p = libSingular.pp_Mult_qq(get_raw_ptr(x), get_raw_ptr(y), get_raw_ptr(c));
            return c(p)
        end
        
        *(x::SingularPolynomialElem, i::Integer) = *(x, parent(x)(i)) 
        *(i::Integer, x::SingularPolynomialElem) = *(parent(x)(i), x)
