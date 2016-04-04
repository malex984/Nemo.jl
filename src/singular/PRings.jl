##### Singular Polynomial Rings and Free modules over them + sparse polynomials and vectors

const SRingID = ObjectIdDict()
type PRing <: SingularPolynomialRing
   ptr :: libSingular.ring
   base_ring :: SingularCoeffs

   function PRing(cf::SingularCoeffs, _v::AbstractString{}, ordering::libSingular.rRingOrder_t = libSingular.ringorder_dp()) # ASCIIString) 
      vv = split(_v, ',')
      vars = Array(AbstractString, length(vv));
      vvv = Array(Ptr{Cuchar}, length(vv))
      for i = 1:length(vv)
      	  v = strip(vv[i]);

	  @assert (length(v) > 0)
	  c = v[1];
	  @assert isalpha(c) || (c == '@') || (c == '_')
	  for j = 1:(i - 1)
	      @assert v != vars[j] # all distinct!
	  end
	  vars[i] = v * "\0";

	  vvv[i] = libSingular.omStrDup(pointer(vars[i]));
      end

##      println(vars)
      # lp?
      try
          return SRingID[cf, vars, ordering]
      catch
      end

      ord_size :: Cint = 3;

      ord  = pointer_to_array( 
      	   Ptr{libSingular.rRingOrder_t}(libSingular.omAlloc0(Csize_t(ord_size * sizeof(libSingular.rRingOrder_t)))), 
      	       (ord_size,), false );
      blk0 = pointer_to_array( Ptr{Cint}(libSingular.omAlloc0(Csize_t(ord_size * sizeof(Cint)))), (ord_size,), false );
      blk1 = pointer_to_array( Ptr{Cint}(libSingular.omAlloc0(Csize_t(ord_size * sizeof(Cint)))), (ord_size,), false );

      ord[1] = ordering; blk0[1] = 1; blk1[1] = length(vvv); # 1st block spanns all variables...

      ord[2] = libSingular.ringorder_C(); ## Singular Default module ordering block (last one)

      ## the last block: everything is 0 
      ord[ord_size] = libSingular.ringorder_no();
#      blk0[ord_size] = blk1[ord_size] = 0; 
      

      ptr = r_Test(libSingular.rDefault(get_raw_ptr(cf), vvv, ord, blk0, blk1));

      (ptr == C_NULL) && error("Singular polynomial ring construction failure")

      try
         R = SRingID[ptr]
	 libSingular.rDelete(ptr)
	 return R
      catch
      end

      d = SRingID[cf, vars, ordering] = SRingID[ptr] = new(ptr, cf)
      finalizer(d, _PRing_clear_fn)
      return d
   end

   function PRing(cf::SingularCoeffs, ptr::libSingular.ring) 
      (r_Test(ptr) == C_NULL) && error("Singular polynomial ring construction failure")      

      try
         R = SRingID[ptr] # TODO: use rVarStr etc...!?
	 return R
      catch
      end

      if isring(cf)
          d = SRingID[ptr] = new(ptr, cf)
          finalizer(d, _PRing_clear_fn)
          return d
      end

      d = SRingID[ptr] = new(ptr, cf)
      finalizer(d, _PRing_clear_fn)
      return d
   end


   function PRing(ptr::libSingular.ring) 
      (r_Test(ptr) == C_NULL) && error("Singular polynomial ring construction failure")
      try
         R = SRingID[ptr]; #### TODO: FIXME: Ring has to be known to Nemo!!!!!!!!!!!!!!!!!!!!!! :((((((((((
         return(R); 
      catch
      end

      cf = rGetCoeffs(ptr);
      C = GetSingularCoeffs(cf);  ### TODO!!!
      return PRing(C, ptr);
   end
end

const SModuleID = ObjectIdDict()

type PModules  <: SingularPolynomialRing
   ptr :: libSingular.ring
   base_ring :: SingularPolynomialRing

   function PModules(r :: SingularPolynomialRing)
      try
         F = SModuleID[r];
	 return F
      catch
      end

      ### ASSERT r has module-component block! 
      z = new(get_raw_ptr(r), r);
      SModuleID[r] = z;
      return z
   end
end

isequal{CF<:SingularPolynomialRing}(A::CF, B::CF) = (get_raw_ptr(A) == get_raw_ptr(B))
=={CF<:SingularPolynomialRing}(A::CF, B::CF)= isequal(A, B)

get_raw_ptr(R :: SingularPolynomialRing) = r_Test(R.ptr)

function _PRing_clear_fn(r::SingularPolynomialRing)
   libSingular.rDelete(get_raw_ptr(r))
end

#### parent(R :: SingularPolynomialRing) = base_ring(R) # TODO: ??????!
base_ring(R :: SingularPolynomialRing) = R.base_ring # TODO: ? verify complience! ???

function +(A::PRing, B::PRing)
   base_ring(A) != base_ring(B) && error("Operations on Polynomial Rings with different base-rings are not supported")
   sum = libSingular.rSum(get_raw_ptr(A), get_raw_ptr(B))
   return PRing(base_ring(A), sum) 
end



#==============================================================================#
 
## Generic with context
type PRingElem <: SingularPolynomialElem
    ptr :: libSingular.poly
    ctx :: SingularPolynomialRing

    function PRingElem(c :: SingularPolynomialRing, p :: libSingular.poly, bMakeCopy :: Bool = false)
#	pp = libSingular.poly_ref(p)
#	libSingular.p_Normalize(pp, r)
        if(bMakeCopy) 
	   p = libSingular.p_Copy(p, get_raw_ptr(c));
        end
	z = new(p, c); # pp[]
	finalizer(z, _SingularPolyRingElem_clear_fn); 
	return z
    end

end

# PRingElem <: SingularPolynomialElem 
# PVectorElem , parent: PRingFreeModule (of any rank) -> gen(, i) ->>> [....1....]

type PModuleElem <: SingularPolynomialElem
    ptr :: libSingular.poly
    ctx :: PModules

    function PModuleElem(c :: PModules, p :: libSingular.poly, bMakeCopy :: Bool = false)
        if(bMakeCopy) 
	   p = libSingular.p_Copy(p, get_raw_ptr(c));
        end
	z = new(p, c); # pp[]
	finalizer(z, _SingularPolyRingElem_clear_fn); 
	return z
    end
end

    function PRingElem()
    	error("Type PRingElem requires context reference")
    end

    function PModuleElem()
    	error("Type PModuleElem requires context reference")
    end

    function PModuleElem(c :: SingularPolynomialRing, p :: libSingular.poly)
#    	r = get_raw_ptr(c);
#	pp = libSingular.poly_ref(p)
#	libSingular.p_Normalize(pp, r)
	return PModuleElem( PModules(c), p)
    end


    function PRingElem(c :: SingularPolynomialRing)
    	r = get_raw_ptr(c);
	p = libSingular.poly(C_NULL); # p_Init(r); ### NOTE: Allocation without initialization!
    	return PRingElem(c, p)
    end

    function PModuleElem(c :: SingularPolynomialRing)
    	r = get_raw_ptr(c);
	p = libSingular.poly(C_NULL); # p_Init(r); ### NOTE: Allocation without initialization!
    	return PModuleElem(c, p)
    end

    function PRingElem(c :: SingularPolynomialRing, x::Int64)
        if x == 0
       	    return PRingElem(c)
	end
    	r = get_raw_ptr(c);
        p :: libSingular.poly = libSingular.p_ISet(x, r)
    	return PRingElem(c, p)
    end

    # NOTE: overtakes input n
    function PRingElem(c :: SingularPolynomialRing, n::number) 
    	r = get_raw_ptr(c);

        if libSingular.n_IsZero(n, libSingular.rGetCoeffs(r))
       	    return PRingElem(c)
	end

    	p :: libSingular.poly = libSingular.p_NSet(n, r)
	return PRingElem(c, p)
    end 

    function PRingElem(c :: SingularPolynomialRing, b::BigInt) 
        if b == 0
       	    return PRingElem(c)
	end

        cf = get_raw_ptr(base_ring(c))
        n = libSingular.n_InitMPZ(b, cf) # NOTE: will be overtaken!
	return PRingElem(c, n)
    end

    function PRingElem(x::PRingElem)
    	return PRingElem(parent(x), get_raw_ptr(x), true)
    end

    PRingElem(c :: SingularPolynomialRing, z::Integer) = PRingElem(c, BigInt(z))
#    PRingElem(c :: SingularPolynomialRing, s::AbstractString) = parsePRingElem(c, s) # TODO: FIXME: go via Singular?!!


    function PRingElem(c :: SingularPolynomialRing, x::SingularCoeffsElems)
        if iszero(x)
       	    return PRingElem(c)
	end

        CF = parent(x);
    	( base_ring(c) != CF ) && error("Number from Incompatible Coeffs [$CF] and given Polynomial Ring [$c]")
    	n :: libSingular.number = libSingular.n_Copy(get_raw_ptr(x), get_raw_ptr(CF));
	p :: libSingular.poly   = libSingular.p_NSet(n, get_raw_ptr(c));  # NOTE: overtakes n!
    	return PRingElem(c, p)
    end



    function PModuleElem(c :: SingularPolynomialRing, x::Int64)
        if x == 0
       	    return PModuleElem(c)
	end
    	r = get_raw_ptr(c);
        p :: libSingular.poly = libSingular.p_ISet(x, r)
    	return PModuleElem(c, p)
    end

    # NOTE: overtakes input n
    function PModuleElem(c :: SingularPolynomialRing, n::number) 
    	r = get_raw_ptr(c);

        if libSingular.n_IsZero(n, libSingular.rGetCoeffs(r))
       	    return PModuleElem(c)
	end

    	p :: libSingular.poly = libSingular.p_NSet(n, r)
	return PModuleElem(c, p)
    end 

    function PModuleElem(c :: SingularPolynomialRing, b::BigInt) 
        if b == 0
       	    return PModuleElem(c)
	end

        cf = get_raw_ptr(base_ring(c))
        n = libSingular.n_InitMPZ(b, cf) # NOTE: will be overtaken!
	return PModuleElem(c, n)
    end

    function PModuleElem(x::PModuleElem)
    	return PModuleElem(parent(x), get_raw_ptr(x), true)
#       c = parent(x); 
#    	r = get_raw_ptr(c);
#	p :: libSingular.poly = libSingular.p_Copy(get_raw_ptr(x), r); 
#    	return PModuleElem(c, p)
    end

    PModuleElem(c :: SingularPolynomialRing, z::Integer) = PModuleElem(c, BigInt(z))
#    PModuleElem(c :: SingularPolynomialRing, s::AbstractString) = parsePModuleElem(c, s) # TODO: FIXME: go via Singular?!!


    function PModuleElem(c :: SingularPolynomialRing, x::SingularCoeffsElems)
        if iszero(x)
       	    return PModuleElem(c)
	end

        CF = parent(x);
    	( base_ring(c) != CF ) && error("Number from Incompatible Coeffs [$CF] and given Polynomial Ring [$c]")
    	n :: libSingular.number = libSingular.n_Copy(get_raw_ptr(x), get_raw_ptr(CF));
	p :: libSingular.poly   = libSingular.p_NSet(n, get_raw_ptr(c));  # NOTE: overtakes n!
    	return PModuleElem(c, p)
    end

# For now - only one element type for any Singular Polynomial Ring...
elem_type(::PRing) = PRingElem
elem_type(::PModules) = PModuleElem

parent_type(::Type{PRingElem}) =  PRing
parent_type(::Type{PModuleElem}) = PModules

parent(p :: SingularPolynomialElem) = p.ctx

function check_parent(a::SingularPolynomialElem, b::SingularPolynomialElem)
   parent(a) != parent(b) && error("Operations on elements with different parents are not supported")
end

function get_raw_ptr(n :: SingularPolynomialElem)
   return p_Test(n.ptr, get_raw_ptr(parent(n)))
end

function set_raw_ptr!(n :: SingularPolynomialElem, p :: libSingular.poly)
#   pp = libSingular.poly_ref(p);
#   libSingular.p_Normalize(pp, get_raw_ptr(parent(n)));
   n.ptr = p; # pp[];
   @assert (p == get_raw_ptr(n)); # Test...
end

function set_raw_ptr!(n :: SingularPolynomialElem, p :: libSingular.poly, C :: SingularPolynomialRing)
#   pp = libSingular.poly_ref(p);
#   libSingular.p_Normalize(pp, get_raw_ptr(C));
   n.ptr = p; # pp[];
   n.ctx = C;
   @assert (p == get_raw_ptr(n)); # Test...
end

function _SingularPolyRingElem_clear_fn(p :: SingularPolynomialElem)
   libSingular._p_Delete(get_raw_ptr(p), get_raw_ptr(parent(p)))
   p.ptr = libSingular.poly(C_NULL); # no tests...
end

# hash(A::SingularPolynomialRing, h::UInt64) = hash(get_raw_ptr(A)) $ h

function hash(a::SingularPolynomialRing, h::UInt64)
#   h = 0x8a30b0d963237dd5 # TODO: change this const to something uniqe!
   return hash(get_raw_ptr(a)) $ h  ## TODO: string may be a bit too inefficient wherever hash is used...?
end


function hash(a::SingularPolynomialElem, h::UInt64)
   return hash(parent(a)) $ hash(string(a)) $ h ## TODO: string may be a bit too inefficient wherever hash is used...?
end

deepcopy(a::SingularPolynomialElem) = elem_type(parent(a))(a)

## PRingElem?
Base.call(A::SingularPolynomialRing) = elem_type(A)(A)
Base.call(A::SingularPolynomialRing, b::Int) = elem_type(A)(A, b)
Base.call(A::SingularPolynomialRing, b::Integer) = elem_type(A)(A, BigInt(b))
Base.call(A::SingularPolynomialRing, b::libSingular.poly) = elem_type(A)(A, b)
Base.call(A::SingularPolynomialRing, b::libSingular.poly, f::Bool) = elem_type(A)(A, b, f)
Base.call(A::SingularPolynomialRing, b::SingularCoeffsElems) = elem_type(A)(A, b)

function Base.call(A::SingularPolynomialRing, b::SingularPolynomialElem)
   A != parent(b) && error("Operations on elements from different rings (mappings) are not supported yet!")
   return b ##   return deepcopy(b) # NOTE: fine no need in deepcopy!?? TODO?????
end

Base.promote_rule{S <: SingularPolynomialElem, T <: Integer}(::Type{S}, ::Type{T}) = S
Base.promote_rule{S <: SingularPolynomialElem, T <: Integer}(::Type{T}, ::Type{S}) = S

Base.promote_rule{S <: SingularPolynomialElem, T <: SingularCoeffsElems}(::Type{S}, ::Type{T}) = S
Base.promote_rule{S <: SingularPolynomialElem, T <: SingularCoeffsElems}(::Type{T}, ::Type{S}) = S


###############################################################################
#
#   Parameters and characteristic
#
###############################################################################

isring(c::SingularPolynomialRing) = true; ##libSingular.nCoeff_is_Ring(get_raw_ptr(c))
#isdomain(c::Singular?) = libSingular.nCoeff_is_Domain(get_raw_ptr(c))

characteristic(r::SingularPolynomialRing) = @cxx rChar( r_Test(get_raw_ptr(r)) )
# characteristic(R::SingularPolynomialRing) = characteristic( base_ring(R) );

ngens(r::SingularPolynomialRing) = Int(@cxx rVar( r_Test(get_raw_ptr(r)) ))
npars(r::SingularPolynomialRing) = Int(@cxx rPar( r_Test(get_raw_ptr(r)) ))

function geni(R::PRing, i::Integer)
    N = ngens(R);
    @assert ((i >= 1) && (i <= N))
    ((i < 1) || (i > N)) && error("Wrong generator/variable index");

    r = get_raw_ptr(R);
    p :: libSingular.poly = libSingular.rGetVar(Cint(i), r);
#    libSingular.p_SetExp!(p, i, 1, r);    
#    libSingular.p_Setm(p, r);
    return elem_type(R)(R, p) ## PRingElem?
end

function geni(R::PModules, i::Integer)
    @assert (i >= 1)
    (i < 1) && error("Wrong generator/variable index (<1?)");

    r = get_raw_ptr(R);
    p :: libSingular.poly = libSingular.p_One(r);

    libSingular.p_SetComp!(p, Culong(i), r);
    libSingular.p_SetmComp!(p, r);

    return elem_type(R)(R, p) ## PRingElem?
end

gen(r::SingularPolynomialRing, i::Integer) = geni(r, i)
gen(r::PRing) = geni(r, ngens(r))  ### TODO: FIX: usage in tests...

function gens(R::PRing)
    N = ngens(R);

    @assert (N > 0)
#    (N == 0) && return Array(SingularPolynomialElem, 0);

    vars = Array(SingularPolynomialElem, N);

#    if (N == 1) 
#       vars[1] = gen(R);
#       return vars;
#    end
    
#    println(vars);

    for i = 1:N
    	vars[i] = geni(R, i);	
#	println("i: $i, var(i): ", vars[i])
    end

#    println(vars);
    return vars;
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
   libSingular.omFree(Ptr{Void}(m))

   return s
end

function string(F::PModules)
   return "Singular Free Module over " * string(base_ring(F)) 
end

show(io::IO, r::SingularPolynomialRing) = print(io, string(r))

###############################################################################
#
#   Basic manipulation
#
###############################################################################

## TODO: FIXME: avoid explicite constructor calls (PRingElem()) in the following: use elem_type?!
zero(R::PRing) = elem_type(R)(R, libSingular.poly(C_NULL))
one(R::PRing)  =  elem_type(R)(R, libSingular.p_One(get_raw_ptr(R)))
# mone(R::PRing) =  elem_type(R)(R, -1)

function string(p::SingularPolynomialElem)
   R = parent(p);   
   m = libSingular.p_String(get_raw_ptr(p), get_raw_ptr(R))
   s = bytestring(m) # * "" * " over " * string(R) * "]"
   libSingular.omFree(Ptr{Void}(m))

   return s # "[" *
end

show(io::IO, p::SingularPolynomialElem) = print(io, string(p))

function length(p::SingularPolynomialElem)
    return libSingular.pLength(get_raw_ptr(p));
end

        function +{R<:SingularPolynomialElem}(x::R, y::R)
            check_parent(x, y)
            c = parent(x)
            p = libSingular.pp_Add_qq(get_raw_ptr(x), get_raw_ptr(y), get_raw_ptr(c));
            return c(p)
        end
        
+(x::PRingElem, i::SingularCoeffsElems) = +(x, parent(x)(i)) 
+(i::SingularCoeffsElems, x::PRingElem) = +(parent(x)(i), x)

        function -{R<:SingularPolynomialElem}(x::R, y::R)
            check_parent(x, y)
            c = parent(x)
            p = libSingular.pp_Sub_qq(get_raw_ptr(x), get_raw_ptr(y), get_raw_ptr(c));
            return c(p)
        end
        
-(x::PRingElem, i::SingularCoeffsElems) = -(x, parent(x)(i)) 
-(i::SingularCoeffsElems, x::PRingElem) = -(parent(x)(i), x)


function -(x::SingularPolynomialElem) 
    C = parent(x)
    ptr = libSingular.pp_Neg( get_raw_ptr(x), get_raw_ptr(C) )
    return C(ptr) 
end


function lead(x::SingularPolynomialElem)  # leading term
    @assert !iszero(x)

    p = get_raw_ptr(x);
    C = parent(x);
    r = get_raw_ptr(C);

    ptr = libSingular.pp_Head(p, r);

    return C(ptr) 
end

function degree(x::SingularPolynomialElem)
    p = get_raw_ptr(x);
    r = get_raw_ptr(parent(x));

    return libSingular.p_Deg(p, r);
end

function *(x::PRingElem, y::PRingElem)
            check_parent(x, y);

            c = parent(x);
            p = libSingular.pp_Mult_qq(get_raw_ptr(x), get_raw_ptr(y), get_raw_ptr(c));
            return c(p);
end

*(x::PRingElem, i::SingularCoeffsElems) = *(x, parent(x)(i)) 
*(i::SingularCoeffsElems, x::PRingElem) = *(parent(x)(i), x)

function *(x::PRingElem, y::PModuleElem)
            c = parent(y);
	    r = get_raw_ptr(c);

	    (r != get_raw_ptr(parent(x))) && error("Operations on elements over different rings are not supported")

            p = libSingular.pp_Mult_qq(get_raw_ptr(x), get_raw_ptr(y), r);
            return c(p);
end
       
*(x::PModuleElem, i::SingularCoeffsElems) = *(base_ring(parent(x))(i), x) 
*(i::SingularCoeffsElems, x::PModuleElem) = *(base_ring(parent(x))(i), x)





###############################################################################
#
#   Powering
#
###############################################################################

function ^(x::PRingElem, y::Cint)
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

function iszero(p :: SingularPolynomialElem)
    return (get_raw_ptr(p) == C_NULL)
end

function isone(x :: PRingElem)
    p = get_raw_ptr(x);
    r = get_raw_ptr(parent(x));
    return libSingular.pp_IsOne(p, r);
end

function isgen(x :: SingularPolynomialElem)
    p = get_raw_ptr(x);
    r = get_raw_ptr(parent(x));
    return libSingular.pp_IsVar(p, r);
end

## Test whether the input polynomial is an invertible constant:
function isunit(x :: SingularPolynomialElem)
    p = get_raw_ptr(x);
    r = get_raw_ptr(parent(x));

    return (p != C_NULL) && (libSingular.pNext!(p) == C_NULL) && libSingular.pp_IsUnit(p, r);
end

function leadcoeff(x :: SingularPolynomialElem)
    @assert !iszero(x)

    C = parent(x);

    n  :: libSingular.number = libSingular.pGetCoeff(get_raw_ptr(x));
    cf :: libSingular.coeffs = libSingular.rGetCoeffs(get_raw_ptr(C));

    return base_ring(C)( libSingular.n_Copy(n, cf) );
end


function ismone(x :: SingularPolynomialElem)
    p = get_raw_ptr(x);
    r = get_raw_ptr(parent(x));

    return libSingular.pp_IsMOne(p, r);
end

function ==(x::SingularPolynomialElem, y::SingularPolynomialElem)
    check_parent(x, y);
    return libSingular.pp_EqualPolys(get_raw_ptr(x), get_raw_ptr(y), get_raw_ptr(parent(x)))
end

isequal(x::SingularPolynomialElem, y::SingularPolynomialElem) = (x == y)

==(x::SingularPolynomialElem, y::Integer) = (x == parent(x)(y))
==(x::Integer, y::SingularPolynomialElem) = (parent(y)(x) == y)

isequal(x::SingularPolynomialElem, y::Integer) = (x == parent(x)(y))
isequal(x::Integer, y::SingularPolynomialElem) = (parent(y)(x) == y)

#=
# <(x,y) = isless(x,y)
function isless(x::SingularPolynomialElem, y::SingularPolynomialElem)
    check_parent(x, y)
    throw(ErrorException("Sorry: cannot compare singular polynomials...?!" )); # TODO: FIXME: generic poly?
##    return libSingular.???(get_raw_ptr(y), get_raw_ptr(x), get_raw_ptr(parent(x)))
end
=#

#isless(x::SingularPolynomialElem, y::Integer) = isless(x, parent(x)(y));
#isless(x::Integer, y::SingularPolynomialElem) = isless(parent(y)(x), y);

function gcd(x::SingularPolynomialElem, y::SingularPolynomialElem)
   check_parent(x, y)
   R = parent(x)
   r = get_raw_ptr(R)

   isring(base_ring(R)) && error("Sorry gcd is not supported over coeff.rings!")

   p = libSingular.singclap_gcd(libSingular.poly_ref(libSingular.p_Copy(get_raw_ptr(x), r)),
                                 libSingular.poly_ref(libSingular.p_Copy(get_raw_ptr(y), r)), r);
   return R(p)
end
        
gcd(x::SingularPolynomialElem, i::Integer) = gcd(x, parent(x)(i)) 
gcd(i::Integer, x::SingularPolynomialElem) = gcd(parent(x)(i), x)

gcd(x::SingularPolynomialElem, i::SingularCoeffsElems) = gcd(x, parent(x)(i)) 
gcd(i::SingularCoeffsElems, x::SingularPolynomialElem) = gcd(parent(x)(i), x)

canonical_unit(x::SingularPolynomialElem) = canonical_unit( leadcoeff(x) ) ## TODO: FIX: check the definition!?

function divexact(x::SingularPolynomialElem, y::SingularPolynomialElem)
    iszero(y) && throw(ErrorException("DivideError() in divexact"));
    check_parent(x, y);
    R = parent(x); 
    r = get_raw_ptr(R);    

    isring(base_ring(R)) && error("Sorry exact division is not supported over coeff.rings!")

    p = libSingular.singclap_pdivide(get_raw_ptr(x), get_raw_ptr(y), r);
    return R(p)
end


function derivative(x::SingularPolynomialElem, i::Integer)
    R = parent(x); 
    r = get_raw_ptr(R);    
	 
    N = ngens(R);
    @assert ((i >= 1) && (i <= N))
    ((i < 1) || (i > N)) && error("Wrong generator/variable index");

    p = libSingular.pp_Diff(get_raw_ptr(x), Cint(i), r);
    return R(p)
end


function gcdx(x::SingularPolynomialElem, y::SingularPolynomialElem)
    check_parent(x, y)
    R = parent(x); 
    r = get_raw_ptr(R);

    isring(base_ring(R)) && error("Sorry extended gcd is not supported over coeff.rings!")

    g, s, t = libSingular.singclap_extgcd(get_raw_ptr(x), get_raw_ptr(y), r);
    return R(g), R(s), R(t)
end
        
function primpart(x :: SingularPolynomialElem)
    R = parent(x); 
    r = get_raw_ptr(R);    
    p = get_raw_ptr(x);

    ## singclap_divide_content ( poly f, const ring r); ???
    pp = poly_ref(libSingular.p_Copy(p, r));
    libSingular.p_Content(pp, r);
    return R(pp[])
end

function content(x :: SingularPolynomialElem)
    return divexact(x, primpart(x) ) ## TODO: FIXME: VERY stupid thing to do in order to get the content... TODO: gcd over all terms?
end

function lcm(x::SingularPolynomialElem, y::SingularPolynomialElem)
    g = gcd(x, y);
    return (divexact(x, g) * y);
end

#=============================================================================#
#   Unsafe functions  for performance
#=============================================================================#

## Internal:
## Unsafe: x *= y (x & y must be initialized!)
function muleq!(x :: SingularPolynomialElem, y :: SingularPolynomialElem)
    @assert parent(x) == parent(y) 

    xx = get_raw_ptr(x);
    yy = get_raw_ptr(y);

    r = get_raw_ptr(parent(x)); 

    if (xx == C_NULL)
        return;
    end

    if (yy == C_NULL)
        libSingular._p_Delete(xx, r);
	set_raw_ptr!(x, libSingular.poly(C_NULL)); # NOTE: unsafe!
	return       
    end

    if is(x, y) # IN-PLACE: x = x * x
        @assert xx == yy	
        ptr = libSingular.p_Power(xx, 2, r);
        set_raw_ptr!(x, ptr); # NOTE: unsafe!
	return
    end

    @assert xx != yy
    ptr = libSingular.p_Mult_q(xx, libSingular.p_Copy(yy, r), r);
    set_raw_ptr!(x, ptr); # NOTE: unsafe!
end

## Unsafe: x += y (x & y must be initialized!)
function addeq!(x :: SingularPolynomialElem, y :: SingularPolynomialElem)
    @assert parent(x) == parent(y) 

    xx = get_raw_ptr(x);
    yy = get_raw_ptr(y);

    r = get_raw_ptr(parent(x)); 
    
    if (yy == C_NULL)
       return;
    end

    if (xx == C_NULL)
    	ptr = libSingular.p_Copy(yy, r);
	set_raw_ptr!(x, ptr); # NOTE: unsafe!
	return       
    end

    if is(x, y) # IN-PLACE: x = 2 * x
        @assert xx == yy

	cf = libSingular.rGetCoeffs(r);
        two = libSingular.n_Init(2, cf); # TODO: NOTE: store this globally?

	ptr = libSingular.p_Mult_nn(xx, two, r);

	libSingular._n_Delete(two, cf);

	set_raw_ptr!(x, ptr); # NOTE: unsafe!
	return
    end

    @assert (xx != yy)
    ptr = libSingular.p_Add_q(xx, libSingular.p_Copy(yy, r), r);
    set_raw_ptr!(x, ptr); # NOTE: unsafe!

end

# c = T(); c = x * y ; M += c   
# NOTE: usually in a loop => on the next cycle c is initialized => free its data!
function mul!(c::SingularPolynomialElem, x::SingularPolynomialElem, y::SingularPolynomialElem)
    if is(c,x) 
        muleq!(c, y)
	return 
    end

    if is(c,y) 
        muleq!(c, x) # NOTE: Commutative multiplication!??? TODO: FIXME: MAY BE WRONG FOR SINGULAR's Non-commutative algebras!
	return 
    end

    @assert parent(x) == parent(y) 

    xx = get_raw_ptr(x);
    yy = get_raw_ptr(y);
    cc = get_raw_ptr(c);

    @assert (cc == C_NULL) || ((cc != xx) && (cc != yy)) ## ???

    R = parent(x); 
    r = get_raw_ptr(R); 

    ptr = libSingular.pp_Mult_qq(xx, yy, r);

    if cc != C_NULL
        libSingular._p_Delete(cc, get_raw_ptr(parent(c)));
    end
    
    set_raw_ptr!(c, ptr, R)
end


## TODO!!!: Ideal, Module, parent: highlevel space of all ideals/free modules over ring

## TODO!!: wrap Nemo ring as Singular Coeffs (cfunction register struct..) ??

## TODO!!: more Singular Fq = GF(p,d) / Zn /Fp _polys

abstract SingularElememntArray

type SingularIdeal <: SingularElememntArray
   ptr :: libSingular.ideal
   ctx :: PRing   
   
   function SingularIdeal(P::PRing, I::libSingular.ideal, bMakeCopy :: Bool = false)
      if bMakeCopy
          I = libSingular.id_Copy(I, get_raw_ptr(P));
      end
      z = new(I, P);
      finalizer(z, _SingularElememntArray_clear_fn)
      return z
   end

   function SingularIdeal( FF :: Array{PRingElem, 1} )
      n = length(FF);

      (n == 0) && error("Cannot create a Singular Ideal without generators (no context is given)!")

      R = parent(FF[1]);
      r = get_raw_ptr(R);

      for i = 1:n
      	  @assert (parent(FF[i]) == R)
	  
	  if libSingular.rRing_has_Comp(r)
	     @assert (libSingular.p_MaxComp(get_raw_ptr(FF[i]), r) == 0);
          end
      end

      J = libSingular.idInit(n);
      I = SingularIdeal(R, J);

      for i = 1:n
         setindex!(I, FF[i], i); # copy!
      end
      
      libSingular.id_Test(J, r);

      return I;
   end


   function SingularIdeal( v :: PRingElem, w... )
      R = parent(v);
      r = get_raw_ptr(R);

      if libSingular.rRing_has_Comp(r)
         @assert (libSingular.p_MaxComp(get_raw_ptr(v), r) == 0);
      end

      n = length(w);

      for i = 1:n
#      	  @assert (typeof(w[i]) == typeof(v)) # ?
      	  @assert (parent(w[i]) == R)
          if libSingular.rRing_has_Comp(r)
             @assert (libSingular.p_MaxComp(get_raw_ptr(w[i]), r) == 0);
          end
      end
      
      J = libSingular.idInit(1 + n);
      I = SingularModule(R, J); # No Copy!

      setindex!(I, v, 1); # Copy!

      for i = 1:n
         setindex!(I, w[i], 1 + i); # Copy!
      end

      libSingular.id_Test(J, r);

      return I;
   end   
end

type SingularModule  <: SingularElememntArray
   ptr :: libSingular.ideal
   ctx :: PModules

   function SingularModule( R :: PModules, I :: libSingular.ideal, bMakeCopy :: Bool = false )
      @assert libSingular.rRing_has_Comp(get_raw_ptr(R));
      if bMakeCopy
          I = libSingular.id_Copy(I, get_raw_ptr(P));
      end
      z = new(I, R);
      finalizer(z, _SingularElememntArray_clear_fn)
      return z
   end

   function SingularModule( FF :: Array{PModuleElem, 1} )
      n = length(FF);

      (n == 0) && error("Cannot create a Singular Module without generators (no context is given)!")

      R = parent(FF[1]);
      r = get_raw_ptr(R);

      @assert libSingular.rRing_has_Comp(r);

      rank = Clong( libSingular.p_MaxComp(get_raw_ptr(FF[1]), r) );

      for i = 2:n
      	  @assert (parent(FF[i]) == R)
          rank = max(rank, libSingular.p_MaxComp(get_raw_ptr(FF[i]), r));
      end
      
      J = libSingular.idInit(n, rank);
      I = SingularModule(R, J); # No Copy!

      for i = 1:n
         setindex!(I, FF[i], i); # Copy!
      end

      @assert (rank == libSingular.id_RankFreeModule(libSingular.id_Test(J, r), r));

      return I;
   end

   function SingularModule( v :: PModuleElem, w... )
      R = parent(v);
      r = get_raw_ptr(R);

      @assert libSingular.rRing_has_Comp(r);

      rank = Clong( libSingular.p_MaxComp(get_raw_ptr(v), r) );

      n = length(w);

      for i = 1:n
#      	  @assert (typeof(w[i]) == typeof(v)) # ?
      	  @assert (parent(w[i]) == R)
          rank = max(rank, libSingular.p_MaxComp(get_raw_ptr(w[i]), r));
      end
      
      J = libSingular.idInit(1 + n, rank);
      I = SingularModule(R, J); # No Copy!

      setindex!(I, v, 1); # Copy!

      for i = 1:n
         setindex!(I, w[i], 1 + i); # Copy!
      end

      @assert (rank == libSingular.id_RankFreeModule(libSingular.id_Test(J, r), r));

      return I;
   end
end

function _SingularElememntArray_clear_fn(ID::SingularElememntArray)
   libSingular._id_Delete(get_raw_ptr(ID), get_raw_ptr(parent(ID)))
end

   function SingularModule( R :: PRing, I :: libSingular.ideal )
      return SingularModule( PModules(R), I)
   end


parent(I :: SingularElememntArray) = I.ctx

function get_raw_ptr(I :: SingularElememntArray)
   return libSingular.id_Test(I.ptr, get_raw_ptr(parent(I)))
end

ncols(I:: SingularElememntArray) = libSingular.ncols(get_raw_ptr(I))
nrows(I:: SingularElememntArray) = libSingular.nrows(get_raw_ptr(I))

rank(I::SingularElememntArray) = libSingular.getrank(get_raw_ptr(I))
setrank!(I::SingularElememntArray, r :: Integer) = libSingular.setrank!(get_raw_ptr(I), Culong(r))

length(I:: SingularElememntArray) = ncols(I)


function getindex(I::SingularElememntArray, i::Integer)
  @assert (i > 0) && (i <= length(I))
  P = parent(I);
  r = get_raw_ptr(P)
  ptr = getindex(get_raw_ptr(I), Cint(i-1));
  
  return elem_type(P)(P, p_Test(ptr,r), true);
end

function setindex!(I::SingularElememntArray, x::libSingular.poly, i::Integer)
  @assert (i > 0) && (i <= length(I))
  setindex!(get_raw_ptr(I), x, Cint(i-1));
end


function setindex!(I::SingularIdeal, x::PRingElem, i::Cint)
  @assert (i > 0) && (i <= length(I))

  R = parent(I);
  (R != parent(x)) && error("Operations on elements over different rings are not supported")

  xx = libSingular.p_Copy( get_raw_ptr(x), get_raw_ptr(R) );
  
  setindex!(I, xx, i);
end

function setindex!(I::SingularModule, x::PModuleElem, i::Cint)
  @assert (i > 0) && (i <= length(I))

  R = parent(I);
  (R != parent(x)) && error("Operations on elements over different rings are not supported")

  xx = libSingular.p_Copy( get_raw_ptr(x), get_raw_ptr(R) );
  
  setindex!(I, xx, i);
end

function deepcopy{T <: SingularElememntArray}(a::T) 
   P = parent(a);
   return T(P,  libSingular.id_Copy( get_raw_ptr(a), get_raw_ptr(P) ) )
end


function iszero(p :: SingularElememntArray) # generated by zeroes or no gens?
    return libSingular.idIs0(get_raw_ptr(p)) # , get_raw_ptr(parent(p))
end


function string(I::SingularIdeal)
   R = parent(I);
   rr = get_raw_ptr(R);
   n = length(I);

   s = "Singular Ideal over " * string(R)

   (n == 0) && return ("Empty/Zero " * s);
   
   s *= (" with " * string(n));

   iszero(I) && return (s * " zero generators");

   J = get_raw_ptr(I);

   a = Array(AbstractString, n);

##   libSingular.id_Print(J, rr);

   for i = 1:n 

      p = libSingular.p_Test( libSingular.getindex(J, Cint(i-1)), rr);
      if p == C_NULL 
         a[i] = "0";
      else
#         a[i] = string(p)
#        a[i] = string(getindex(I, i)) # Copy! :(
#         continue;

         m = libSingular.p_String(p, rr); # NOTE: changes/normalizes coefss of p !
#         a[i] *= bytestring(m);
         a[i]= bytestring(m);
         libSingular.omFree(Ptr{Void}(m));
      end
   end

   
   return s * " generators < " * join(a, " , ") * " >";
end



function string(I::SingularModule)
   M = parent(I);
   R = base_ring(M);
   rr = get_raw_ptr(R);

   rk = rank(I)
   n = length(I);
   
   s = "Singular Free Module of rank " * string(rk) * " over " * string(R)

   (n == 0) && return "Empty/Zero " * s
   
   s *= " with " * string(n);

   iszero(I) && return s * " zero generators"

   J = get_raw_ptr(I);

##   libSingular.id_Print(J, rr);

   a = Array(AbstractString, n)
   for i = 1:n 

      p = libSingular.p_Test( libSingular.getindex(J, Cint(i-1)), rr);
#     p = libSingular.getindex(J, Cint(i)); # J[i];

      if p == C_NULL 
         a[i] = "0";
      else
#         a[i] = string(p) # Copy: getindex(I, i) :(
#        a[i] = string(getindex(I, i)) # Copy! :(
#         continue;

         m = libSingular.p_String(p, rr);
         a[i] = bytestring(m);
         libSingular.omFree(Ptr{Void}(m));
      end
   end
  
   return (s * " generators < " * join(a, " , ") * " >");
end

show(io::IO, p::SingularElememntArray) = print(io, string(p))


function std{T <: SingularElememntArray}(a::T) 
   P = parent(a);
   return T(P,  libSingular.idSkipZeroes(libSingular.kStd( get_raw_ptr(a), get_raw_ptr(P) )) )
end

function syz{T <: SingularElememntArray}(a::T) 
   P = parent(a);
   return SingularModule(P, libSingular.idSkipZeroes(libSingular._id_Syzygies( get_raw_ptr(a), get_raw_ptr(P) )) )
end 

maxideal(R::SingularPolynomialRing, d::Integer) = SingularIdeal(R, libSingular.idSkipZeroes(libSingular.id_MaxIdeal(Cint(d), get_raw_ptr(R))));

freemodule(R::SingularPolynomialRing, r::Integer) = SingularModule(PModules(R), libSingular.idSkipZeroes(libSingular.id_FreeModule(Cint(r), get_raw_ptr(R))));
