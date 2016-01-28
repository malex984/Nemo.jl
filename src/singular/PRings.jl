# PRingElem <: SingularPolynomialElem 

const SRingID = ObjectIdDict()

# typealias PRing SingPolyRing

type PRing <: SingularPolynomialRing
   ptr :: libSingular.ring
   base_ring :: SingularCoeffs

   function PRing(cf::SingularCoeffs, _v::AbstractString{}, ordering::libSingular.rRingOrder_t = libSingular.ringorder_dp()) # ASCIIString) 
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

      (ptr == libSingular.ring(C_NULL)) && error("Singular polynomial ring construction failure")

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
      (r_Test(ptr) == libSingular.ring(C_NULL)) && error("Singular polynomial ring construction failure")      

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
end


get_raw_ptr(R :: SingularPolynomialRing) = r_Test(R.ptr)

function _PRing_clear_fn(r::SingularPolynomialRing)
   libSingular.rDelete(get_raw_ptr(r))
end

#### parent(R :: SingularPolynomialRing) = base_ring(R) # TODO: ??????!
base_ring(R :: SingularPolynomialRing) = R.base_ring # TODO: ? verify complience! ???

function +(A::SingularPolynomialRing, B::SingularPolynomialRing)
   base_ring(A) != base_ring(B) && error("Operations on Polynomial Rings with different base-rings are not supported")
   sum = libSingular.rSum(get_raw_ptr(A), get_raw_ptr(B))
   return PRing(base_ring(A), sum) 
end



#==============================================================================#

## Generic with context
type PRingElem <: SingularPolynomialElem
    ptr :: libSingular.poly
    ctx :: SingularPolynomialRing

    function PRingElem(c :: SingularPolynomialRing, p :: libSingular.poly)
    	const r = get_raw_ptr(c);
#	pp = libSingular.poly_ref(p)
#	libSingular.p_Normalize(pp, r)
	z = new(p, c); # pp[]
	finalizer(z, _SingularPolyRingElem_clear_fn); 
	return z
    end

end

    function PRingElem()
    	error("Type PRingElem requires context reference")
    end

    function PRingElem(c :: SingularPolynomialRing)
    	const r = get_raw_ptr(c);
	const p = libSingular.poly(C_NULL); # p_Init(r); ### NOTE: Allocation without initialization!
    	return PRingElem(c, p)
    end


    function PRingElem(c :: SingularPolynomialRing, x::Int64)
        if x == 0
       	    return PRingElem(c)
	end
    	const r = get_raw_ptr(c);
        const p :: libSingular.poly = libSingular.p_ISet(x, r)
    	return PRingElem(c, p)
    end

    # NOTE: overtakes input n
    function PRingElem(c :: SingularPolynomialRing, n::number) 
    	const r = get_raw_ptr(c);

        if libSingular.n_IsZero(n, libSingular.rGetCoeffs(r))
       	    return PRingElem(c)
	end

    	const p :: libSingular.poly = libSingular.p_NSet(n, r)
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
        const c = parent(x); 
    	const r = get_raw_ptr(c);
	const p :: libSingular.poly = libSingular.p_Copy(get_raw_ptr(x), r); 
    	return PRingElem(c, p)
    end

    PRingElem(c :: SingularPolynomialRing, z::Integer) = PRingElem(c, BigInt(z))
#    PRingElem(c :: SingularPolynomialRing, s::AbstractString) = parsePRingElem(c, s) # TODO: FIXME: go via Singular?!!


    function PRingElem(c :: SingularPolynomialRing, x::SingularCoeffsElems)
        if iszero(x)
       	    return PRingElem(c)
	end

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

ngens(r::SingularPolynomialRing) = Int(@cxx rVar( r_Test(get_raw_ptr(r)) ))
npars(r::SingularPolynomialRing) = Int(@cxx rPar( r_Test(get_raw_ptr(r)) ))

function geni(i::Integer, R::SingularPolynomialRing)
    const N = ngens(R);
    @assert ((i >= 1) && (i <= N))
    ((i < 1) || (i > N)) && error("Wrong generator/variable index");

    const r = get_raw_ptr(R);
    const p :: libSingular.poly = libSingular.rGetVar(Cint(i), r);
#    libSingular.p_SetExp!(p, i, 1, r);    
#    libSingular.p_Setm(p, r);
    return elem_type(R)(R, p) ## PRingElem?
end

gen(i::Integer, r::SingularPolynomialRing) = geni(i, r)
gen(r::SingularPolynomialRing) = geni(ngens(r), r)

function gens(R::SingularPolynomialRing)
    const N = ngens(R);

    @assert (N > 0)
#    (N == 0) && return Array(SingularPolynomialElem, 0);

    vars = Array(SingularPolynomialElem, N);

#    if (N == 1) 
#       vars[1] = gen(R);
#       return vars;
#    end
    
#    println(vars);

    for i = 1:N
    	vars[i] = geni(i, R);	
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
zero(R::SingularPolynomialRing) = elem_type(R)(R, libSingular.poly(C_NULL))
one(R::SingularPolynomialRing)  =  elem_type(R)(R, libSingular.p_One(get_raw_ptr(R)))
# mone(R::SingularPolynomialRing) =  elem_type(R)(R, -1)

function string(p::SingularPolynomialElem)
   const R = parent(p);   
   m = libSingular.p_String(get_raw_ptr(p), get_raw_ptr(R))
   s = bytestring(m) # * "" * " over " * string(R) * "]"
   libSingular.omFree(Ptr{Void}(m))

   return s # "[" *
end

function length(p::SingularPolynomialElem)
    return libSingular.pLength(get_raw_ptr(p));
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


function lead(x::SingularPolynomialElem)  # leading term
    @assert !iszero(x)

    const p = get_raw_ptr(x);
    const C = parent(x);
    const r = get_raw_ptr(C);

    const ptr = libSingular.pp_Head(p, r);

    return C(ptr) 
end

function degree(x::SingularPolynomialElem)
    const p = get_raw_ptr(x);
    const r = get_raw_ptr(parent(x));

    return libSingular.p_Deg(p, r);
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

function iszero(p :: SingularPolynomialElem)
    return (get_raw_ptr(p) == libSingular.poly(C_NULL))
end

function isone(x :: SingularPolynomialElem)
    const p = get_raw_ptr(x);
    const r = get_raw_ptr(parent(x));
    return libSingular.pp_IsOne(p, r);
end

function isgen(x :: SingularPolynomialElem)
    const p = get_raw_ptr(x);
    const r = get_raw_ptr(parent(x));
    return libSingular.pp_IsVar(p, r);
end

## Test whether the input polynomial is an invertible constant:
function isunit(x :: SingularPolynomialElem)
    const p = get_raw_ptr(x);
    const r = get_raw_ptr(parent(x));

    return (p != libSingular.poly(C_NULL)) && (libSingular.pNext!(p) == libSingular.poly(C_NULL)) && libSingular.pp_IsUnit(p, r);
end

function leadcoeff(x :: SingularPolynomialElem)
    @assert !iszero(x)

    const C = parent(x);

    const n  :: libSingular.number = libSingular.pGetCoeff(get_raw_ptr(x));
    const cf :: libSingular.coeffs = libSingular.rGetCoeffs(get_raw_ptr(C));

    return base_ring(C)( libSingular.n_Copy(n, cf) );
end


function ismone(x :: SingularPolynomialElem)
    const p = get_raw_ptr(x);
    const r = get_raw_ptr(parent(x));

    return libSingular.pp_IsMOne(p, r);
end


function ==(x::SingularPolynomialElem, y::SingularPolynomialElem)
    check_parent(x, y);
    return libSingular.pp_EqualPolys(get_raw_ptr(x), get_raw_ptr(y), get_raw_ptr(parent(x)))
end

isequal(x::SingularPolynomialElem, y::SingularPolynomialElem) = (x == y)

# <(x,y) = isless(x,y)
function isless(x::SingularPolynomialElem, y::SingularPolynomialElem)
    check_parent(x, y)
    throw(ErrorException("Sorry: cannot compare singular polynomials...?!" )); # TODO: FIXME: generic poly?
##    return libSingular.???(get_raw_ptr(y), get_raw_ptr(x), get_raw_ptr(parent(x)))
end

==(x::SingularPolynomialElem, y::Integer) = (x == parent(x)(y))
==(x::Integer, y::SingularPolynomialElem) = (parent(y)(x) == y)

isequal(x::SingularPolynomialElem, y::Integer) = (x == parent(x)(y))
isequal(x::Integer, y::SingularPolynomialElem) = (parent(y)(x) == y)

isless(x::SingularPolynomialElem, y::Integer) = isless(x, parent(x)(y));
isless(x::Integer, y::SingularPolynomialElem) = isless(parent(y)(x), y);

function gcd(x::SingularPolynomialElem, y::SingularPolynomialElem)
   check_parent(x, y)
   const R = parent(x)
   const r = get_raw_ptr(R)

   isring(base_ring(R)) && error("Sorry gcd is not supported over coeff.rings!")

   const p = libSingular.singclap_gcd(libSingular.poly_ref(libSingular.p_Copy(get_raw_ptr(x), r)),
                                 libSingular.poly_ref(libSingular.p_Copy(get_raw_ptr(y), r)), r);
   return R(p)
end
        
gcd(x::SingularPolynomialElem, i::Integer) = gcd(x, parent(x)(i)) 
gcd(i::Integer, x::SingularPolynomialElem) = gcd(parent(x)(i), x)

gcd(x::SingularPolynomialElem, i::SingularCoeffsElems) = gcd(x, parent(x)(i)) 
gcd(i::SingularCoeffsElems, x::SingularPolynomialElem) = gcd(parent(x)(i), x)

canonical_unit(x::SingularPolynomialElem) = canonical_unit( leadcoeff(x) )

function divexact(x::SingularPolynomialElem, y::SingularPolynomialElem)
    iszero(y) && throw(ErrorException("DivideError() in divexact"));
    check_parent(x, y);
    const R = parent(x); 
    const r = get_raw_ptr(R);    

    isring(base_ring(R)) && error("Sorry exact division is not supported over coeff.rings!")

    const p = libSingular.singclap_pdivide(get_raw_ptr(x), get_raw_ptr(y), r);
    return R(p)
end


function derivative(x::SingularPolynomialElem, i::Integer)
    const R = parent(x); 
    const r = get_raw_ptr(R);    
	 
    const N = ngens(R);
    @assert ((i >= 1) && (i <= N))
    ((i < 1) || (i > N)) && error("Wrong generator/variable index");

    const p = libSingular.pp_Diff(get_raw_ptr(x), Cint(i), r);
    return R(p)
end


function gcdx(x::SingularPolynomialElem, y::SingularPolynomialElem)
    check_parent(x, y)
    const R = parent(x); 
    const r = get_raw_ptr(R);

    isring(base_ring(R)) && error("Sorry extended gcd is not supported over coeff.rings!")

    g, s, t = libSingular.singclap_extgcd(get_raw_ptr(x), get_raw_ptr(y), r);
    return R(g), R(s), R(t)
end
        
function primpart(x :: SingularPolynomialElem)
    const R = parent(x); 
    const r = get_raw_ptr(R);    
    const p = get_raw_ptr(x);

    ## singclap_divide_content ( poly f, const ring r); ???
    pp = poly_ref(libSingular.p_Copy(p, r));
    libSingular.p_Content(pp, r);
    return R(pp[])
end

function content(x :: SingularPolynomialElem)
    return divexact(x, primpart(x) ) ## TODO: FIXME: VERY stupid thing to do in order to get the content... TODO: gcd over all terms?
end

function lcm(x::SingularPolynomialElem, y::SingularPolynomialElem)
    const g = gcd(x, y);
    return (divexact(x, g) * y);
end

#=============================================================================#
#   Unsafe functions  for performance
#=============================================================================#

## Internal:
## Unsafe: x *= y (x & y must be initialized!)
function muleq!(x :: SingularPolynomialElem, y :: SingularPolynomialElem)
    @assert parent(x) == parent(y) 

    const xx = get_raw_ptr(x);
    const yy = get_raw_ptr(y);

    r = get_raw_ptr(parent(x)); 

    if (xx == libSingular.poly(C_NULL))
        return;
    end

    if (yy == libSingular.poly(C_NULL))
        libSingular._p_Delete(xx, r);
	set_raw_ptr!(x, libSingular.poly(C_NULL)); # NOTE: unsafe!
	return       
    end

    if is(x, y) # IN-PLACE: x = x * x
        @assert xx == yy	
        const ptr = libSingular.p_Power(xx, 2, r);
        set_raw_ptr!(x, ptr); # NOTE: unsafe!
	return
    end

    @assert xx != yy
    const ptr = libSingular.p_Mult_q(xx, libSingular.p_Copy(yy, r), r);
    set_raw_ptr!(x, ptr); # NOTE: unsafe!
end

## Unsafe: x += y (x & y must be initialized!)
function addeq!(x :: SingularPolynomialElem, y :: SingularPolynomialElem)
    @assert parent(x) == parent(y) 

    const xx = get_raw_ptr(x);
    const yy = get_raw_ptr(y);

    r = get_raw_ptr(parent(x)); 
    
    if (yy == libSingular.poly(C_NULL))
       return;
    end

    if (xx == libSingular.poly(C_NULL))
    	const ptr = libSingular.p_Copy(yy, r);
	set_raw_ptr!(x, ptr); # NOTE: unsafe!
	return       
    end

    if is(x, y) # IN-PLACE: x = 2 * x
        @assert xx == yy

	const cf = libSingular.rGetCoeffs(r);
        const two = libSingular.n_Init(2, cf); # TODO: NOTE: store this globally?

	const ptr = libSingular.p_Mult_nn(xx, two, r);

	libSingular._n_Delete(two, cf);

	set_raw_ptr!(x, ptr); # NOTE: unsafe!
	return
    end

    @assert (xx != yy)
    const ptr = libSingular.p_Add_q(xx, libSingular.p_Copy(yy, r), r);
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

    const xx = get_raw_ptr(x);
    const yy = get_raw_ptr(y);
    const cc = get_raw_ptr(c);

    @assert (cc == libSingular.poly(C_NULL)) || ((cc != xx) && (cc != yy)) ## ???

    const R = parent(x); 
    const r = get_raw_ptr(R); 

    const ptr = libSingular.pp_Mult_qq(xx, yy, r);

    if cc != libSingular.poly(C_NULL)
        libSingular._p_Delete(cc, get_raw_ptr(parent(c)));
    end
    
    set_raw_ptr!(c, ptr, R)
end
