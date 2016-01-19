# PRingElem <: SingularPolynomialElem 

const SRingID = ObjectIdDict()

# typealias PRing SingPolyRing

type PRing <: SingularPolynomialRing
   ptr :: libSingular.ring
   base_ring :: SingularCoeffs

   function PRing(cf::SingularCoeffs, _v::AbstractString{}) # ASCIIString) 
      vv = split(_v, ',')
      vars = Array(AbstractString, length(vv));
      vvv = Array(Ptr{Cuchar}, length(vv))
      for i = 1:length(vv)
      	  const v = strip(vv[i]);

	  @assert (length(v) > 0)
	  const c = v[1];
	  @assert isalpha(c) || (c == '@') || (c == '_')
	  for j = 1:(i - 1)
	      @assert v != vars[j] # all distinct!
	  end
	  vars[i] = v * "\0";

	  vvv[i] = pointer(vars[i]);
      end

##      println(vars)
      ordering = libSingular.ringorder_dp(); # lp?
      try
          return SRingID[cf, vars, ordering]
      catch
      end

      ord_size :: Cint = 2;

      ord  = pointer_to_array( 
      	   Ptr{libSingular.rRingOrder_t}(libSingular.omAlloc0(Csize_t(ord_size * sizeof(libSingular.rRingOrder_t)))), 
      	       (ord_size,), false );
      blk0 = pointer_to_array( Ptr{Cint}(libSingular.omAlloc0(Csize_t(ord_size * sizeof(Cint)))), (ord_size,), false );
      blk1 = pointer_to_array( Ptr{Cint}(libSingular.omAlloc0(Csize_t(ord_size * sizeof(Cint)))), (ord_size,), false );

      ord[1] = ordering; blk0[1] = 1; blk1[1] = length(vvv); # 1st block spanns all variables...

      ## the last block: everything is 0 
#      ord[ord_size] = libSingular.ringorder_no();
#      blk0[ord_size] = blk1[ord_size] = 0; 
      

      ptr = r_Test(libSingular.rDefault(get_raw_ptr(cf), vvv, ord, blk0, blk1));
      #@cxx test_create_ring2(get_raw_ptr(cf))

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
      (r_Test(ptr) == libSingular.ring(0)) && error("Singular polynomial ring construction failure")      

      try
         R = SRingID[ptr] # TODO: use rVarStr etc...!?
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


get_raw_ptr(R :: SingularPolynomialRing) = R.ptr

function _PRing_clear_fn(r::SingularPolynomialRing)
   libSingular.rDelete(get_raw_ptr(r))
end

#### parent(R :: SingularPolynomialRing) = base_ring(R) # TODO: ??????!
base_ring(R :: SingularPolynomialRing) = R.base_ring # TODO: ? verify complience! ???

function +(A::SingularPolynomialRing, B::SingularPolynomialRing)
   base_ring(A) != base_ring(B) && error("Operations on Polynomial Rings with different base-rings are not supported")
   sum = libSingular.rSum(get_raw_ptr(A), get_raw_ptr(B))
   return PRing(sum) 
end



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


    function PRingElem(c :: SingularPolynomialRing, x::SingularCoeffsElems)
        const CF = parent(x);
    	( base_ring(c) != CF ) && error("Number from Incompatible Coeffs [$CF] and given Polynomial Ring [$c]")
    	const n :: libSingular.number = libSingular.n_Copy(get_raw_ptr(x), get_raw_ptr(CF));
	const p :: libSingular.poly   = libSingular.p_NSet(n, get_raw_ptr(c));  # NOTE: overtakes n!
    	return PRingElem(c, p)
    end

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
Base.call(A::SingularPolynomialRing, b::SingularCoeffsElems) = elem_type(A)(A, b)

function Base.call(A::SingularPolynomialRing, b::SingularPolynomialElem)
   A != parent(b) && error("Operations on elements from different rings (mappings) are not supported yet!")
   return b ##   return deepcopy(b) # NOTE: fine no need in deepcopy!?? TODO?????
end

Base.promote_rule{S <: SingularPolynomialRing, T <: Integer}(::Type{S}, ::Type{T}) = S
Base.promote_rule{S <: SingularPolynomialRing, T <: Integer}(::Type{T}, ::Type{S}) = S

Base.promote_rule{S <: SingularPolynomialRing, T <: SingularCoeffsElems}(::Type{S}, ::Type{T}) = S
Base.promote_rule{S <: SingularPolynomialRing, T <: SingularCoeffsElems}(::Type{T}, ::Type{S}) = S


###############################################################################
#
#   Parameters and characteristic
#
###############################################################################

isring(c::SingularPolynomialRing) = true; ##libSingular.nCoeff_is_Ring(get_raw_ptr(c))
#isdomain(c::Singular?) = libSingular.nCoeff_is_Domain(get_raw_ptr(c))

characteristic(r::SingularPolynomialRing) = @cxx rChar(get_raw_ptr(r))

ngens(r::SingularPolynomialRing) = Int(@cxx rVar(get_raw_ptr(r)))
npars(r::SingularPolynomialRing) = Int(@cxx rPar(get_raw_ptr(r)))

function geni(i::Int, R::SingularPolynomialRing)
    const N = ngens(R);
    @assert ((i >= 1) && (i <= N))
    ((i < 1) || (i > N)) && error("Wrong generator/variable index");

    const r = get_raw_ptr(R);
    const p :: libSingular.poly = libSingular.rGetVar(Cint(i), r);
#    libSingular.p_SetExp!(p, i, 1, r);    
#    libSingular.p_Setm(p, r);
    return elem_type(R)(R, p) ## PRingElem?
end

gen(r::SingularPolynomialRing) = geni( ngens(r), r) ## ??

function gens(R::SingularPolynomialRing)
    const N = ngens(R);
    
    vars = Array(SingularPolynomialElem, N);

    for i = 1:N
    	vars[i] = geni(i, R);	
    end

    return vars
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
   libSingular.omFree(Ptr{Void}(m))

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
   libSingular.omFree(Ptr{Void}(m))

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

        function -(x::SingularPolynomialElem, y::SingularPolynomialElem)
            check_parent(x, y)
            c = parent(x)
            p = libSingular.pp_Sub_qq(get_raw_ptr(x), get_raw_ptr(y), get_raw_ptr(c));
            return c(p)
        end
        
        -(x::SingularPolynomialElem, i::Integer) = -(x, parent(x)(i)) 
        -(i::Integer, x::SingularPolynomialElem) = -(parent(x)(i), x)


function -(x::SingularPolynomialElem) 
    C = parent(x)
    ptr = libSingular.pp_Neg( get_raw_ptr(x), get_raw_ptr(C) )
    return C(ptr) 
end


        function *(x::SingularPolynomialElem, y::SingularPolynomialElem)
            check_parent(x, y)
            c = parent(x)
            p = libSingular.pp_Mult_qq(get_raw_ptr(x), get_raw_ptr(y), get_raw_ptr(c));
            return c(p)
        end
        
        *(x::SingularPolynomialElem, i::Integer) = *(x, parent(x)(i)) 
        *(i::Integer, x::SingularPolynomialElem) = *(parent(x)(i), x)




###############################################################################
#
#   Powering
#
###############################################################################

function ^(x::SingularPolynomialElem, y::Cint)
    if y < 0;  throw(ErrorException("DivideError(): Negative power: " * string(y) * "!")); end
    if isone(x); return x; end
    if ismone(x); return isodd(y) ? x : -x; end
##    if y > typemax(UInt); throw(ErrorException("DivideError(): Power is too big: " * string(y) * ", sorry!" )); end
    c = parent(x)
    if y == 0; return one(c); end
    if y == 1; return x; end
    p = libSingular.pp_Power(get_raw_ptr(x), y, get_raw_ptr(c))
    return c(p)
end


        function isone(x :: SingularPolynomialElem)
            return libSingular.pp_IsOne(get_raw_ptr(x), get_raw_ptr(parent(x)))
        end
        function ismone(x :: SingularPolynomialElem)
            return libSingular.pp_IsMOne(get_raw_ptr(x), get_raw_ptr(parent(x)))
        end
