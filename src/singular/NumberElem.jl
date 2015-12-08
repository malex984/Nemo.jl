type NumberElem <: SingularFieldElem
    ptr :: libSingular.number
    ctx :: Coeffs

    # void nNew(number * a) # ?

    # Integer?
    function NumberElem(c::Coeffs, x::Int = 0)
        p = libSingular.n_Init(x, get_raw_ptr(c))

        z = new(p, c)
        finalizer(z, _SingularFieldElem_clear_fn)
        return z
    end

    function NumberElem(x::SingularFieldElem)
        c = parent(x) 
	p = libSingular.n_Copy(get_raw_ptr(x), get_raw_ptr(c)) 

        z = new(p, c)
        finalizer(z, _SingularFieldElem_clear_fn)
        return z
    end

    function NumberElem(c::Coeffs, p::libSingular.number)
        z = new(p, c)
        finalizer(z, _SingularFieldElem_clear_fn)
        return z
    end

    function NumberElem(c::Coeffs, b::BigInt)
        c = parent(x)
        p = libSingular.n_InitMPZ(b, get_raw_ptr(c))

        z = new(p, c)
        finalizer(z, _SingularFieldElem_clear_fn)
        return z
    end

### TODO: BigInt # mpz_t n
end

# {T <: SingularFieldElem}
get_raw_ptr( n::NumberElem ) = n.ptr

parent( n::NumberElem ) = n.ctx


##### TODO: FIXME!
function set_raw_ptr!(n::NumberElem, p::libSingular.number)
   n.ptr = p
end

function set_raw_ptr!(n::NumberElem, p::libSingular.number, C::Coeffs)
   n.ptr = p
   n.ctx = C
end

## TODO: remove this once destructors work properly!
leftovers = ObjectIdDict() # dupes_counter = 0

function _SingularFieldElem_clear_fn(n::SingularFieldElem)
   c = parent(n)
   cf = get_raw_ptr(c)

   p = get_raw_ptr(n)
#   p = &n

   set_raw_ptr!(n, libSingular.number(0))#   n.ptr = number(0)

   if libSingular.nCoeff_has_simple_Alloc(cf) # || ( (Int(p) & 255) != 0 )
      return ;
   end


#   n_Delete(Ptr{number}(pointer(n)), cf)
#   print("\n_SingularFieldElem_clear_fn(n)...")

#   ref = number_ref(p)
   libSingular._n_Delete(p, cf)
 
#   if !haskey(leftovers, c) 
#       leftovers[c] = Dict([ p => 1 ])
#   else
#       nn = leftovers[c]
#
#       if !haskey(nn, p)
#           nn[p] = 1
#       else ### :(
#       	   nn[p] = nn[p] + 1;
#       end
#   end

###   @cxx _n_Delete(p, cf)
###    n_Delete(p, cf)

#   println("DONE!")
#   n.ptr = p ## not necessary?
end


###############################################################################
#
#   Type and parent object methods
#
###############################################################################

elem_type(::Coeffs) = NumberElem ## TODO: FIXME!

base_ring(a::Coeffs) = None
base_ring(a::SingularFieldElem) = None

function check_parent(a::SingularFieldElem, b::SingularFieldElem) 
   parent(a) != parent(b) && error("Operations on elements from distinct fields are not supported")
end

###############################################################################
#
#   Conversions and promotions
#
###############################################################################

#### For the following we miss a context
#convert(::Type{NumberElem}, a::Int) = #NumberElem (a)
#convert(::Type{NumberElem}, a::Integer) = #NumberElem (a)

# convert(::Type{Rational{BigInt}}, a::fmpq) = Rational(a)
#function convert(::Type{BigInt}, a::NumberElem)
#   r = BigInt()
#   ccall((:NumberElem_get_mpz, :libflint), Void, (Ptr{BigInt}, Ptr{NumberElem}), &r, &a)
#   return r
#end

#function convert(::Type{Int}, a::NumberElem) 
#   return ccall((:NumberElem_get_si, :libflint), Int, (Ptr{NumberElem},), &a)
#end

#function convert(::Type{UInt}, x::NumberElem)
#   return ccall((:NumberElem_get_ui, :libflint), UInt, (Ptr{NumberElem}, ), &x)
#end

#function convert(::Type{Float64}, n::NumberElem)
#    # rounds to zero
#end

Base.promote_rule{S <: SingularFieldElem, T <: Integer}(::Type{S}, ::Type{T}) = NumberElem #TODO: ?!


###############################################################################
#
#   Parent object call overloads
#
###############################################################################


### TODO: different coeffs.domains!!!

Base.call(a::Coeffs) = NumberElem(a)
Base.call(a::Coeffs, b::Int) = NumberElem(a, b)
Base.call(a::Coeffs, b::Integer) = NumberElem(a, BigInt(b))
## Base.call(a::Coeffs, b::String) = NumberElem(a, b)
# Base.call(a::Coeffs, b::number) = NumberElem(a, b)

function Base.call(a::Coeffs, b::SingularFieldElem)
   a != parent(b) && error("Operations on elements from different field (mappings) are not supported yet!")
   return b 
##   return deepcopy(b) # NOTE: fine no need in deepcopy!?? TODO?????
end


###############################################################################
#
#   Constructors
#
###############################################################################

#NumberElem(c::Coeffs, s::String) = parseint(c, s)
NumberElem(c::Coeffs, z::Integer) = c(BigInt(z))


###############################################################################
#
#   String I/O
#
###############################################################################

function string(n::SingularFieldElem)
   libSingular.StringSetS("")
   libSingular.n_Write( get_raw_ptr(n), get_raw_ptr(parent(n)) )
   m = libSingular.StringEndS()
   s = bytestring(m)
   libSingular.omFree(m)

   return s
end

#### TODO: needs considering?
needs_parentheses(x::SingularFieldElem)   = false # TODO: is coeffs has parameters?
show_minus_one{T <: SingularFieldElem}(::Type{T}) = false
is_negative(x::SingularFieldElem) = isnegative(x) 


#show(io::IO, n::SingularFieldElem) = print(io, "SingularFieldElem(", string(n), ")")
show(io::IO, n::SingularFieldElem) = print(io, string(n))



###############################################################################
#
#   Basic manipulation
#
###############################################################################


function hash(a::SingularFieldElem)
   return hash(parent(a)) $ hash(string(a))  ## TODO: string may be a bit too inefficient wherever hash is used...?
end

deepcopy(a::SingularFieldElem) = NumberElem(a) ### TODO: FIXME?

#### #wrong for ZZ???
isunit(a::SingularFieldElem) = !iszero(a) # FIXME: NOTE:Coeff.  Rings are not supported at the moment



###############################################################################
#
#   Canonicalisation
#
###############################################################################

##### FIXME: wrong? for printing & normalization of fractions?
canonical_unit(x::SingularFieldElem) = isnegative(x) ? mone(parent(x)) : one(parent(x)) ## ZZ
## 



###############################################################################
#
#   Unsafe functions  for performance
#
###############################################################################

### void n_InpMult(number &a, number b, const coeffs r)
### void n_InpAdd(number &a, number b, const coeffs r)


##### TODO!!!!!!!!!!!!!!!!!!!!!! #####
##### TODO!!!!!!!!!!!!!!!!!!!!!! #####
##### TODO!!!!!!!!!!!!!!!!!!!!!! #####
##### TODO!!!!!!!!!!!!!!!!!!!!!! #####
##### TODO!!!!!!!!!!!!!!!!!!!!!! #####
##### TODO!!!!!!!!!!!!!!!!!!!!!! #####

function muleq!(x :: SingularFieldElem, y :: SingularFieldElem)
            check_parent(x, y)
            cf = get_raw_ptr(parent(x))
            xx = number_ref(get_raw_ptr(x))
            yy = get_raw_ptr(y)

#	    @cxx (libSingular.$fC)(xx, yy, cf) 
	    icxx" n_InpMult($xx, $yy, $cf);"

	    set_raw_ptr!(x, xx[])#            x.ptr = ptr
end

function addeq!(x :: SingularFieldElem, y :: SingularFieldElem)
            check_parent(x, y)
            cf = get_raw_ptr(parent(x))
            xx = number_ref(get_raw_ptr(x))
            yy = get_raw_ptr(y)

#  @cxx (libSingular.$fC)(xx, yy, cf) ### TODO: check me! reference!? ##????
	    icxx" n_InpAdd($xx, $yy, $cf);"

#	    @cxx _n_Delete(xx, cf)
# @cxx (libSingular.$fC)(xx, yy, cf) ### TODO: check me! reference!? ##????

	    set_raw_ptr!(x, xx[])#            x.ptr = ptr
end

#    c = x * y
### mul!(x, x, x) ???
function mul!(c::SingularFieldElem, x::SingularFieldElem, y::SingularFieldElem)
    check_parent(x, y)
    
    C = parent(x)
    ptr   = @cxx n_Mult(get_raw_ptr(x), get_raw_ptr(y), get_raw_ptr(C))
    
    #    old   = c.ptrw#    oldcf = get_raw_ptr(parent(c)) 
    _SingularFieldElem_clear_fn(c) ## BAD IDEA?

    set_raw_ptr!(c, ptr, C) #    c.ctx = C#    c.ptr = ptr

##    @cxx n_Delete(&old, oldcf)
##    muleq!(c, y)
end

###############################################################################
#
#   ? DEN ? NUM ? NORM ?
#
###############################################################################

### void   n_Normalize(number& n, const coeffs r) # use cxx""" """  and  pointers?
### number n_GetDenom(number& n, const coeffs r)
### number n_GetNumerator(number& n, const coeffs r)

for (fJ, fC) in ((:num, :n_GetNumerator), (:den, :n_GetDenom), (:normalise, :n_Normalize))
    @eval begin
        function ($fJ)(x :: SingularFieldElem)
            cf = get_raw_ptr(parent(x))
            p = get_raw_ptr(x)
	    r = number_ref(p)
	### TODO: FIXME:!!!!
            ret = @cxx (libSingular.$fC)(r, cf) 
            set_raw_ptr!(x, r[])
	    return ret
        end
    end
end

###############################################################################
#
#   Binary operators and functions
#
###############################################################################

# Metaprogram to define functions +, -, *, gcd, lcm
                                 
for (fJ, fC) in ((:+, :n_Add), (:-,:n_Sub), (:*, :n_Mult),
                 (:gcd, :n_Gcd), (:lcm, :n_Lcm) )
    @eval begin
        function ($fJ)(x::SingularFieldElem, y::SingularFieldElem)
            check_parent(x, y)
            c = parent(x)
            p = (libSingular.$fC)(get_raw_ptr(x), get_raw_ptr(y), get_raw_ptr(c));
            return  NumberElem(c, p)
        end
        
        ($fJ)(x::SingularFieldElem, i::Integer) = ($fJ)(x, parent(x)(i)) 
        ($fJ)(i::Integer, x::SingularFieldElem) = ($fJ)(parent(x)(i), x)
    end
end

##function divexact(x::SingularFieldElem, y::SingularFieldElem)
##    iszero(y) && throw(DivideError())
##    check_parent(x, y)
##    c = parent(x)
##    return c(n_ExactDiv(get_raw_ptr(x), get_raw_ptr(y), get_raw_ptr(c)))
##end

##### TODO: check for exact multiple before divexact & error?

# Metaprogram to define functions /, div, mod

if false ### --here??
for (fJ, fC) in ((://, :n_Div), ### ????? /: floating point division?
    (:div, :n_DivExact), ##### FIXME / TODO : Euclid domain???
    (:mod, :n_Mod))
    @eval begin
        function ($fJ)(x::SingularFieldElem, y::SingularFieldElem)
            iszero(y) == 0 && throw(DivideError())
            check_parent(x, y)
            c = parent(x)
            return  c((libSingular.$fC)(get_raw_ptr(x), get_raw_ptr(y), get_raw_ptr(c)))
        end
        ($fJ)(x::SingularFieldElem, i::Integer) = ($fJ)(x,  parent(x)(i)) 
        ($fJ)(i::Integer, x::SingularFieldElem) = ($fJ)(parent(x)(i), x)
    end
end
end


#####################################################################
#####################################################################!
#####################################################################



###############################################################################
#
#   Powering
#
###############################################################################

function ^(x::SingularFieldElem, y::Int)
    if y < 0; throw(DomainError()); end
    if isone(x); return x; end
    if ismone(x); return isodd(y) ? x : -x; end
    if y > typemax(Uint); throw(DomainError()); end
    c = parent(x)
    if y == 0; return one(c); end
    if y == 1; return x; end
    p = libSingular.n_Power(get_raw_ptr(x), y, get_raw_ptr(c))
    return NumberElem(c, p)
end


###############################################################################
#
#   Unary operators and functions
#
###############################################################################

function -(x::SingularFieldElem)
    return (zero(parent(x)) - x)   ### TODO: FIXME: deepcopy & n_InpNeg!
end

function abs(x::SingularFieldElem)
    ispositive(x) && return x
    return (-x)
end

function sign(a::SingularFieldElem)
    ispositive(a) && return 1
    iszero(a) && return 0
    return -1
end

function inv(x::SingularFieldElem)
    C = parent(x)
     #### TODO FIXME: isring(C)?
    return C(libSingular.n_Invers(get_raw_ptr(x), get_raw_ptr(C)))
end

###############################################################################
#
#   Division with remainder
#
###############################################################################

#function divrem(x::SingularFieldElem, y::SingularFieldElem)
#    iszero(y) && throw(DivideError())
#    div(x, y), mod(x, y) ### TODO: @cxx ??? mod (non-negative) vs rem (C semantics)??? s
#end

#function crt(r1::SingularFieldElem, m1::SingularFieldElem, r2::SingularFieldElem, m2::SingularFieldElem, signed=false)
#   z = fmpz()
#   ccall((:fmpz_CRT, :libflint), Void,
#          (Ptr{fmpz}, Ptr{fmpz}, Ptr{fmpz}, Ptr{fmpz}, Ptr{fmpz}, Cint),
#          &z, &r1, &m1, &r2, &m2, signed)
#   return z
#end

#function crt(r1::SingularFieldElem, m1::SingularFieldElem, r2::Int, m2::Int, signed=false)
#   z = fmpz()
#   r2 < 0 && throw(DomainError())
#   m2 < 0 && throw(DomainError())
#   ccall((:fmpz_CRT_ui, :libflint), Void,
#          (Ptr{fmpz}, Ptr{fmpz}, Ptr{fmpz}, Int, Int, Cint),
#          &z, &r1, &m1, r2, m2, signed)
#   return z
#end

###############################################################################
#
#   Extended GCD
#
###############################################################################

##function gcdx(a::SingularFieldElem, b::SingularFieldElem)
#    if b == 0 # shortcut this to ensure consistent results with gcdx(a,b)
#        return a < 0 ? (-a, -one(FlintZZ), zero(FlintZZ)) : (a, one(FlintZZ), zero(FlintZZ))
#    end
#    g = fmpz()
#    s = fmpz()
#    t = fmpz()
#    ccall((:fmpz_xgcd, :libflint), Void,
#        (Ptr{fmpz}, Ptr{fmpz}, Ptr{fmpz}, Ptr{fmpz}, Ptr{fmpz}),
#        &g, &s, &t, &a, &b)
#    g, s, t
##end

##function gcdinv(a::SingularFieldElem, b::SingularFieldElem)
#   a < 0 && throw(DomainError())
#   b < a && throw(DomainError())
#   g = fmpz()
#   s = fmpz()
#   ccall((:fmpz_gcdinv, :libflint), Void,
#        (Ptr{fmpz}, Ptr{fmpz}, Ptr{fmpz}, Ptr{fmpz}),
#        &g, &s, &a, &b)
#   return g, s
##end


###############################################################################
#
#   Comparison
#
###############################################################################

for (fJ, fC) in ((:isone, :n_IsOne), (:ismone, :n_IsMOne), 
                (:iszero, :n_IsZero), (:ispositive, :n_GreaterZero), 
		(:size,   :n_Size)) 
    @eval begin
        function ($fJ)(x :: SingularFieldElem)
            return (libSingular.$fC)(get_raw_ptr(x), get_raw_ptr(parent(x)))
        end
    end
end

##!

isnegative(a::SingularFieldElem) = (!iszero(a)) && (!ispositive(a))

function sscmp(x::SingularFieldElem, y::SingularFieldElem)
    check_parent(x, y)
    cf = get_raw_ptr(parent(x))
    xx = get_raw_ptr(x) 
    yy = get_raw_ptr(y)

    libSingular.n_Greater(xx, yy, cf)  && return 1
    libSingular.n_Equal(xx, yy, cf)  && return 0

    return -1
end

==(x::SingularFieldElem, y::SingularFieldElem) = sscmp(x,y) == 0

<=(x::SingularFieldElem, y::SingularFieldElem) = sscmp(x,y) <= 0

>=(x::SingularFieldElem, y::SingularFieldElem) = sscmp(x,y) >= 0

<(x::SingularFieldElem, y::SingularFieldElem) = sscmp(x,y) < 0

>(x::SingularFieldElem, y::SingularFieldElem) = sscmp(x,y) > 0

###############################################################################
#
#   Ad hoc comparison
#
###############################################################################

sicmp(x::SingularFieldElem, y::Int) = sscmp(x, parent(x)(y))
iscmp(x::Int, y::SingularFieldElem) = sscmp(parent(y)(x), y)

==(x::SingularFieldElem, y::Int) = sicmp(x,y) == 0
==(x::Int, y::SingularFieldElem) = iscmp(x,y) == 0

<=(x::SingularFieldElem, y::Int) = sicmp(x,y) <= 0
<=(x::Int, y::SingularFieldElem) = iscmp(x,y) <= 0

<(x::SingularFieldElem, y::Int) = sicmp(x,y) < 0
<(x::Int, y::SingularFieldElem) = iscmp(x,y) < 0

#####################################################################! OK untill here!

function >=(x::SingularFieldElem, y::Int) 
#   return  (sicmp(x,y) >= 0)
#### julia-debug: codegen.cpp:3005: llvm::Value* emit_assignment(llvm::Value*, jl_value_t*, jl_value_t*, bool, bool, jl_codectx_t*): 
#### Assert on `rval->getType() == jl_pvalue_llvmt || rval->getType() == NoopType' failed.
end


function >(x::Int, y::SingularFieldElem) 
#   return (iscmp(x,y) > 0)
### /home/malex/JJ/usr/bin/julia-debug: symbol lookup error: /home/malex/.julia/v0.4/Cxx/src/../deps/usr/lib/libcxxffi-debug.so: undefined symbol: _ZNK5clang7CodeGen17CGBuilderInserterILb0EE12InsertHelperEPN4llvm11InstructionERKNS3_5TwineEPNS3_10BasicBlockENS3_14ilist_iteratorIS4_EE
end

function >(x::SingularFieldElem, y::Int)
#   return (sicmp(x,y) > 0)
### /home/malex/JJ/usr/bin/julia-debug: symbol lookup error: /home/malex/.julia/v0.4/Cxx/src/../deps/usr/lib/libcxxffi-debug.so: undefined symbol: _ZNK5clang7CodeGen17CGBuilderInserterILb0EE12InsertHelperEPN4llvm11InstructionERKNS3_5TwineEPNS3_10BasicBlockENS3_14ilist_iteratorIS4_EE
end

function >=(x::Int, y::SingularFieldElem) 
#   return (iscmp(x,y) >= 0)
###fq_poly.adhoc_exact_division...
### /home/malex/JJ/usr/bin/julia-debug: symbol lookup error: /home/malex/.julia/v0.4/Cxx/src/../deps/usr/lib/libcxxffi-debug.so: undefined symbol: _ZNK5clang7CodeGen17CGBuilderInserterILb0EE12InsertHelperEPN4llvm11InstructionERKNS3_5TwineEPNS3_10BasicBlockENS3_14ilist_iteratorIS4_EE
end


###############################################################################
#
#   Number-theoretic/combinatorial
#
###############################################################################

##function divisible(x::SingularFieldElem, y::SingularFieldElem)
##   y == 0 && throw(DivideError())
###   Bool(ccall((:fmpz_divisible, :libflint), Cint, 
###              (Ptr{fmpz}, Ptr{fmpz}), &x, &y))
##end

##function divisible(x::SingularFieldElem, y::Int)
##   y == 0 && throw(DivideError())
###   Bool(ccall((:fmpz_divisible_si, :libflint), Cint, 
###              (Ptr{fmpz}, Int), &x, y))
##end


###############################################################################
#
#   String parser
#
###############################################################################

####function parseint(c::Coeffs, s::String)
#    s = bytestring(s)
#    sgn = s[1] == '-' ? -1 : 1
#    i = 1 + (sgn == -1)
## TODO!
#    err == 0 || error("Invalid big integer: $(repr(s))")
#    return sgn < 0 ? -z : z
#end

#####################################################################! finish?
