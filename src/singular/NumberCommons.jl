#= @file NumberCommons.jl =#

#=====================================================#
# Properties: 
#=====================================================#

function get_raw_ptr(n::SingularCoeffsElems)
   return n_Test(n.ptr, get_raw_ptr(parent(n)))
end

function set_raw_ptr!(n::SingularCoeffsElems, p::libSingular.number)
   n.ptr = p;
   @assert (p == get_raw_ptr(n)); # Test...
end


#=====================================================#
# Type and parent object methods
#=====================================================#

base_ring(a::SingularCoeffs) = Union{}
base_ring(a::SingularCoeffsElems) = Union{} ## ???

function check_parent(a::SingularCoeffsElems, b::SingularCoeffsElems) 
   parent(a) != parent(b) && error("Operations on elements with different parents are not supported")
end


###############################################################################
#
#    Destructor
#
###############################################################################

function _SingularRingElem_clear_fn(n::SingularCoeffsElems)
   c = parent(n)
   cf = get_raw_ptr(c)

   p = get_raw_ptr(n)

   # ( (Int(p) & 255) != 0 )
   if libSingular.nCoeff_has_simple_Alloc(cf) || (p == number(0))
      return ;
   end

   @assert (p != number(0))
#   println("\nGC[ $n { $p, $cf } ]...\n")
   libSingular._n_Delete(p, cf);

#   set_raw_ptr!(n, libSingular.number(0)) # p? 
   n.ptr = libSingular.number(0); # no tests...
end



###############################################################################
#
#   Conversions and promotions
#
###############################################################################

function convert(::Type{BigInt}, _a::SingularCoeffsElems)
    a = _a; #    a = deepcopy(_a) ## !?
    aa =  number_ref(get_raw_ptr(a)); 
    r = libSingular.n_MPZ(aa, get_raw_ptr(parent(a)))
    set_raw_ptr!(a, aa[]) ## TODO: FIXME: unsafe!!!!?
    return r
end

function convert(::Type{Int}, _a::SingularCoeffsElems) 
    a = _a; #     a = deepcopy(_a) ## !?
    aa = number_ref(get_raw_ptr(a)) 
    r = libSingular.n_Int(aa, get_raw_ptr(parent(a)))
    set_raw_ptr!(a, aa[]) ## TODO: FIXME: unsafe!!!!?
    return r
end

function convert(::Type{UInt}, x::SingularCoeffsElems)
    return UInt(convert(Int, x))
end

#function convert(::Type{Float64}, n::SingularCoeffsElems) # rounds to zero
#   error("Sorry this functionality (converting into Float64) is not implemented yet :(")
#end


###############################################################################
#
#   Parent object call overloads
#
###############################################################################

Base.call(a::SingularCoeffs, b::AbstractString) = parseNumber(a, b)


###############################################################################
#
#   String I/O
#
###############################################################################

function string(n::SingularCoeffsElems)
   return string!(n) # deepcopy(n)) ## ?
end

function string!(n::SingularCoeffsElems)
   libSingular.StringSetS("")

   nn = number_ref(get_raw_ptr(n))	
   libSingular.n_Write( nn, get_raw_ptr(parent(n)), false )
   set_raw_ptr!(n, nn[]) ## TODO: FIXME: unsafe...

   m = libSingular.StringEndS()
   s = bytestring(m) 
   libSingular.omFree(Ptr{Void}(m))

   return s
end

#### TODO: needs considering?
needs_parentheses(x::SingularCoeffsElems)   = false # TODO: FIXME: is coeffs has parameters?

# {T<:SingularCoeffsElems}
# ERROR: LoadError: MethodError: `show_minus_one` has no method matching show_minus_one(::Type{Nemo.NumberElem{Nemo.Coeffs}})
show_minus_one{CF<:SingularCoeffsElems}(::Type{CF}) = false

is_negative(x::SingularCoeffsElems) = isnegative(x) 

# TODO: 
#show(io::IO, n::SingularCoeffsElems) = print(io, "SingularCoeffsElems(", string(n), ")")
show(io::IO, n::SingularCoeffsElems) = print(io, string(n))

###############################################################################
#
#   Basic manipulation
#
###############################################################################


function hash(a::SingularCoeffsElems)
   return hash(parent(a)) $ hash(string(a))  ## TODO: string may be a bit too inefficient wherever hash is used...?
end

deepcopy(a::SingularCoeffsElems) = elem_type(parent(a))(a)

#deepcopy(a::SingularRingElem) = NumberElem(a)
#deepcopy(a::SingularUniqueRingElem) = Number_Elem(a)
#deepcopy(a::SingularFieldElem) = NumberFElem(a)
#deepcopy(a::SingularUniqueFieldElem) = NumberF_Elem(a)
#deepcopy(a::Singular_QQElem) = Singular_QQElem(a)

###############################################################################
#
#   Canonicalisation
#
###############################################################################

##### FIXME: wrong? for printing & normalization of fractions?
canonical_unit(x::SingularCoeffsElems) = isnegative(x) ? mone(parent(x)) : one(parent(x)) ## ZZ

#### TODO: FIXME: wrong for Rings (e.g.ZZ)!!!! 
isunit(a::SingularCoeffsElems) = !iszero(a) # FIXME: NOTE: Coeff-Rings are now also supported!




###############################################################################
#
#   ? DEN ? NUM ? NORM ?
#
###############################################################################

### void   n_Normalize(number& n, const coeffs r) # use cxx""" """  and  pointers?
### number n_GetDenom(number& n, const coeffs r)
### number n_GetNumerator(number& n, const coeffs r)

for (fJ, fC) in ((:_num!, :_n_GetNumerator), (:_den!, :_n_GetDenom))
    @eval begin
        function ($fJ)(x :: SingularCoeffsElems)
	    r = number_ref(get_raw_ptr(x));
            ret = (libSingular.$fC)(r, get_raw_ptr(parent(x)))
            set_raw_ptr!(x, r[]) ## TODO: FIXME: unsafe!

	    return ret # NOTE: result in the same Coeff.domain! 
        end
    end
end

# , (:normalise, :n_Normalize)
function normalize!(x :: SingularCoeffsElems) #
   r = number_ref(get_raw_ptr(x));
   libSingular.n_Normalize(r, get_raw_ptr(parent(x)));
   set_raw_ptr!(x, r[]) # NOTE: unsafe!
   return x
end



###############################################################################
#
#   Binary operators and functions
#
###############################################################################

# Metaprogram to define functions +, -, *, gcd, lcm
                                 
for (fJ, fC) in ((:+, :n_Add), (:-, :n_Sub), (:*, :n_Mult),
                 (:gcd, :n_Gcd), (:lcm, :n_Lcm) )
    @eval begin
        function ($fJ)(x::SingularCoeffsElems, y::SingularCoeffsElems)
            check_parent(x, y)
            c = parent(x)
            p = (libSingular.$fC)(get_raw_ptr(x), get_raw_ptr(y), get_raw_ptr(c));
            return  c(p)
        end
        
        ($fJ)(x::SingularCoeffsElems, i::Integer) = ($fJ)(x, parent(x)(i)) 
        ($fJ)(i::Integer, x::SingularCoeffsElems) = ($fJ)(parent(x)(i), x)
    end
end

function divexact(x::SingularCoeffsElems, y::SingularCoeffsElems)
    iszero(y) && throw(ErrorException("DivideError() in divexact"))
    check_parent(x, y)
    C = parent(x)
    return C(libSingular.n_ExactDiv(get_raw_ptr(x), get_raw_ptr(y), get_raw_ptr(C)))
end

##### TODO: check for exact multiple before divexact & error?

# Metaprogram to define functions /, div, mod

# SingularRingElems
for (fJ, fC) in ((://, :n_Div), ## ?? /: floating point division?
    (:div, :n_ExactDiv), ##### FIXME / TODO : Euclid domain???
    (:_mod, :n_IntMod))
    @eval begin
        function ($fJ)(x::SingularCoeffsElems, y::SingularCoeffsElems)
            iszero(y) && throw(ErrorException("DivideError() in $fJ"))
            check_parent(x, y)
            c = parent(x)
            return  c((libSingular.$fC)(get_raw_ptr(x), get_raw_ptr(y), get_raw_ptr(c)))
        end
        ($fJ)(x::SingularCoeffsElems, i::Integer) = ($fJ)(x,  parent(x)(i)) 
        ($fJ)(i::Integer, x::SingularCoeffsElems) = ($fJ)(parent(x)(i), x)
    end
end

function mod(x::SingularCoeffsElems, y::SingularCoeffsElems) 
    iszero(y) && throw(ErrorException("DivideError() in % (mod)"))
    check_parent(x, y)
    m = _mod(x, y)
    if m >= 0
       return m
    end
    yy = abs(y)
    m += yy
    while m < 0
    	m += yy
    end
    return m  
end


mod{T <: Integer}(x::SingularCoeffsElems, i::T) = mod(x,  parent(x)(i)) 
mod{T <: Integer}(i::T, x::SingularCoeffsElems) = mod(parent(x)(i), x)


function mulmod{T <: SingularCoeffsElems}(a::T, b::T, d::T)
    check_parent(a, b)
    return mod(a * b, d)
end


function powmod{T <: SingularCoeffsElems}(a::T, b::Int, d::T)
   check_parent(a, d)
   if iszero(a)
      return zero(parent(a))
   elseif b == 0
      return one(parent(a))
   else
      if b < 0
         a = invmod(a, d)
         b = -b
      end
      bit = ~((~UInt(0)) >> 1)
      while (UInt(bit) & b) == 0
         bit >>= 1
      end
      z = a
      bit >>= 1
      while bit !=0
         z = mulmod(z, z, d)
         if (UInt(bit) & b) != 0
            z = mulmod(z, a, d)
         end
         bit >>= 1
      end
      return z
   end
end

function powmod{T <: SingularCoeffsElems}(a::T, p::SingularCoeffsElems, m::T)
    return powmod(a, Int(p), m)
end


function invmod{T <: SingularCoeffsElems}(a::T, d::T)
    check_parent(a, d)
    g, i  = gcdinv(a, d)
    (!isone(g)) && throw(ErrorException("DivideError() in % (invmod)"))
    return mod(i, d) # mod(inv(a), d) # TODO: better generic implementation???
end

#    (:%,   :n_IntMod))
function rem(x::SingularCoeffsElems, y::SingularCoeffsElems) 
	 # mod(x, y) ### ??? TODO: IntMod vs QuotRem??!
    iszero(y) && throw(ErrorException("DivideError() in % (rem)"))
    check_parent(x, y)
    return (x - div(x, y) * y)
end

rem{T <: Integer}(x::SingularCoeffsElems, i::T) = rem(x,  parent(x)(i)) 
rem{T <: Integer}(i::T, x::SingularCoeffsElems) = rem(parent(x)(i), x)

function remQR(x::SingularCoeffsElems, y::SingularCoeffsElems)
    iszero(y) && throw(ErrorException("DivideError() in % (remQR)"))
    check_parent(x, y)
    C = parent(x); cf = get_raw_ptr(C);

    q, m = libSingular.n_QuotRem(get_raw_ptr(x), get_raw_ptr(y), cf);

    libSingular._n_Delete(q, cf);
    return C(m)
end


function divQR(x::SingularCoeffsElems, y::SingularCoeffsElems)
    iszero(y) && throw(ErrorException("DivideError() in % (divQR)"))
    check_parent(x, y)

    C = parent(x); cf = get_raw_ptr(C)

    q, m = libSingular.n_QuotRem(get_raw_ptr(x), get_raw_ptr(y), cf);

    libSingular._n_Delete(m, cf);
    return C(q)
end


#=============================================================================
#   Unary operators and functions
==============================================================================#

function -(x::SingularCoeffsElems) 
    C = parent(x)
    ptr = libSingular.n_Neg( get_raw_ptr(x),  get_raw_ptr(C) )
    return C(ptr) 
#    return (zero(parent(x)) - x)   ### TODO: FIXME: deepcopy & n_InpNeg!?
end

function abs(x::SingularCoeffsElems)
    ispositive(x) && return x
    return (-x)
end

function sign(a::SingularCoeffsElems)
    ispositive(a) && return 1
    iszero(a) && return 0
    return -1
end

function inv(x::SingularCoeffsElems)
    iszero(x) && error("Division by zero!")
    C = parent(x)

    p = libSingular.n_Invers(get_raw_ptr(x), get_raw_ptr(C)) 

    if p != number(0); return C(p); end

    isring(C) && error("Sorry but input has no inverse in its ring!")

    error("Sorry: could not compute inverse for your input!")
end

###############################################################################
#
#   Extended GCD
#
###############################################################################

function gcdx(a::SingularCoeffsElems, b::SingularCoeffsElems)
    check_parent(a, b)
    C = parent(a)

    if iszero(b) # shortcut this to ensure consistent results with gcdx(a,b)
        return (a < 0) ? (-a, -one(C), zero(C)) : (a, one(C), zero(C))
    end

    g, s, t = libSingular.n_ExtGcd(get_raw_ptr(a), get_raw_ptr(b), get_raw_ptr(C));

    C(g), C(s), C(t)
end

function gcdinv(a::SingularCoeffsElems, b::SingularCoeffsElems)
    check_parent(a, b)
    c = parent(a)

    if iszero(b) # shortcut this to ensure consistent results with gcdx(a,b)
        return a < 0 ? (-a, -one(c)) : (a, one(c))
    end

    a < 0 && throw(ErrorException("DivideError(): a < 0 (gcdinv)"))
    b < a && throw(ErrorException("DivideError(): b < a (gcdinv)")) 

    cf = get_raw_ptr(c);

    g, s, t = libSingular.n_ExtGcd(get_raw_ptr(a), get_raw_ptr(b), cf);

    libSingular._n_Delete(t, cf)

    c(g), c(s)
end


###############################################################################
#
#   Comparison
#
###############################################################################

for (fJ, fC) in ((:isone, :n_IsOne), (:ismone, :n_IsMOne), 
                (:iszero, :n_IsZero), (:ispositive, :n_GreaterZero), 
		(:size,   :n_Size)) 
    @eval begin
        function ($fJ)(x :: SingularCoeffsElems)
            return (libSingular.$fC)(get_raw_ptr(x), get_raw_ptr(parent(x)))
        end
    end
end

isnegative(a::SingularCoeffsElems) = (!iszero(a)) && (!ispositive(a))

# see also https://github.com/JuliaLang/julia/blob/master/base/operators.jl

function cmp(x::SingularCoeffsElems, y::SingularCoeffsElems)
    check_parent(x, y)
    cf = get_raw_ptr(parent(x))
    xx = get_raw_ptr(x) 
    yy = get_raw_ptr(y)

    libSingular.n_Greater(xx, yy, cf)  && return 1
    libSingular.n_Equal(xx, yy, cf)  && return 0

    return -1
end

cmpabs(x::SingularCoeffsElems, y::SingularCoeffsElems) = cmp( abs(x), abs(y) )


function ==(x::SingularCoeffsElems, y::SingularCoeffsElems)
    check_parent(x, y)
    return libSingular.n_Equal(get_raw_ptr(x), get_raw_ptr(y), get_raw_ptr(parent(x)))
end

isequal(x::SingularCoeffsElems, y::SingularCoeffsElems) = (x == y)

# <(x,y) = isless(x,y)
function isless(x::SingularCoeffsElems, y::SingularCoeffsElems)
    check_parent(x, y)
    return libSingular.n_Greater(get_raw_ptr(y), get_raw_ptr(x), get_raw_ptr(parent(x)))
end


###############################################################################
#
#   Ad hoc comparison
#
###############################################################################

==(x::SingularCoeffsElems, y::Int) = (x ==  parent(x)(y))
==(x::Int, y::SingularCoeffsElems) = (parent(y)(x) == y)

isequal(x::SingularCoeffsElems, y::Int) = (x == y)
isequal(x::Int, y::SingularCoeffsElems) = (x == y)

isless(x::SingularCoeffsElems, y::Int) = isless(x, parent(x)(y))
isless(x::Int, y::SingularCoeffsElems) = isless(parent(y)(x), y)


###############################################################################
#
#   Number-theoretic/combinatorial
#
###############################################################################

#### Return true if x is divisible by y, otherwise return false. If y = 0 a ~DivideError() is raised.
function divisible(x::SingularCoeffsElems, y::SingularCoeffsElems)
   iszero(y) && throw(ErrorException("DivideError() in divisible"))  # throw(DivideError())
   
   # test whether 'x' is divisible by 'y';
   # in Z: TRUE iff 'y' divides 'x' (with remainder = zero)
   return libSingular.n_DivBy( get_raw_ptr(x), get_raw_ptr(y), get_raw_ptr(parent(x)) )
end

function divisible(x::SingularCoeffsElems, y::Int)
   (y==0) && throw(ErrorException("DivideError() in divisible")) # throw(DivideError())

   return divisible(x, parent(x)(y)) # for now
end


###############################################################################
#
#   Unsafe functions  for performance
#
###############################################################################

# void n_InpMult(number &a, number b, const coeffs r)
# void n_InpAdd(number &a, number b, const coeffs r)

## Internal:
## Unsafe: x *= y (x & y must be initialized!)
function muleq!(x :: SingularCoeffsElems, y :: SingularCoeffsElems)
#	if is(x, y) # IN-PLACE: x := x^2 
    @assert parent(x) == parent(y)#        check_parent(x, y)

    cf = get_raw_ptr(parent(x)); yy = get_raw_ptr(y)

    xx = number_ref(get_raw_ptr(x))
#    println("muleq! $x: [$xx] *= $y [$yy]: ")
    icxx""" n_InpMult($xx, $yy, $cf); """ # TODO: move to libSingular!
    set_raw_ptr!(x, xx[]); # NOTE: unsafe!!

#    println("muleq! ---> $x [$xx]")
end

## Unsafe: x += y (x & y must be initialized!)
function addeq!(x :: SingularCoeffsElems, y :: SingularCoeffsElems)
#	if is(x, y) # IN-PLACE: x = 2 * x
    @assert parent(x) == parent(y)#        check_parent(x, y)

    cf = get_raw_ptr(parent(x)); yy = get_raw_ptr(y)

    xx = number_ref(get_raw_ptr(x))
#    println("addeq! $x: [$xx] += $y [$yy]: ")
    icxx""" n_InpAdd($xx, $yy, $cf); """ # TODO: move to libSingular!
    set_raw_ptr!(x, xx[]); # NOTE: unsafe!

#    println("addeq! ---> $x [$xx]")
end

# c = T(); c = x * y ; M += c   
# NOTE: usually in a loop => on the next cycle c is initialized => free its data!
function mul!(c::SingularCoeffsElems, x::SingularCoeffsElems, y::SingularCoeffsElems)
    if is(c,x) 
        muleq!(c, y)
	return 
    end
    if is(c,y) 
        muleq!(c, x) # NOTE: Commutative multiplication!???
	return 
    end

    @assert !(is(c,x) || is(c,y))
    @assert parent(x) == parent(y)#    check_parent(x, y)
    
    C = parent(x); cf = get_raw_ptr(C);

    xx = get_raw_ptr(x); yy = get_raw_ptr(y);

#    println("mul! ($x [$xx]) * ($y [$yy]) --?-> c..")

    ptr = libSingular.n_Mult(xx, yy, cf);

    cc = get_raw_ptr(c);

    if cc != number(0)
#    	println("mul!: prev: $c ($cc)... living in ", get_raw_ptr(parent(c)))
        libSingular._n_Delete(cc, get_raw_ptr(parent(c)));
#    	println("mul!: prev - deleted...!!!")
    end
    
    set_raw_ptr!(c, ptr, C)

#    println("mul! ($x) * ($y) ---> $c")
end





#####################################################################! Julia/Cxx bugs:

#function >(x::Int, y::SingularCoeffsElems) 
#   return (sicmp(y,x) < 0)
#   return (iscmp(x,y) > 0) # BUG:
# /home/malex/JJ/usr/bin/julia-debug: symbol lookup error: /home/malex/.julia/v0.4/Cxx/src/../deps/usr/lib/libcxxffi-debug.so: undefined symbol: _ZNK5clang7CodeGen17CGBuilderInserterILb0EE12InsertHelperEPN4llvm11InstructionERKNS3_5TwineEPNS3_10BasicBlockENS3_14ilist_iteratorIS4_EE
#end

#function >(x::SingularCoeffsElems, y::Int)
#   return (iscmp(y,x) < 0) # OK
#   return (sicmp(x,y) > 0) # BUG:
# /home/malex/JJ/usr/bin/julia-debug: symbol lookup error: /home/malex/.julia/v0.4/Cxx/src/../deps/usr/lib/libcxxffi-debug.so: undefined symbol: _ZNK5clang7CodeGen17CGBuilderInserterILb0EE12InsertHelperEPN4llvm11InstructionERKNS3_5TwineEPNS3_10BasicBlockENS3_14ilist_iteratorIS4_EE
#end

#function >=(x::Int, y::SingularCoeffsElems) 
#   return (sicmp(y,x) <= 0)
#   return (iscmp(x,y) >= 0) # BUG:
#fq_poly.adhoc_exact_division... /home/malex/JJ/usr/bin/julia-debug: symbol lookup error: /home/malex/.julia/v0.4/Cxx/src/../deps/usr/lib/libcxxffi-debug.so: undefined symbol: _ZNK5clang7CodeGen17CGBuilderInserterILb0EE12InsertHelperEPN4llvm11InstructionERKNS3_5TwineEPNS3_10BasicBlockENS3_14ilist_iteratorIS4_EE
#end


#function >=(x::SingularCoeffsElems, y::Int) # x >= y !(x<y)
#    error("Sorry Julia bug!") # OK
#   return  !(x<y)            # BUG:
#   return (iscmp(y,x) <= 0)  # BUG:
#   return (sicmp(x,y) >= 0)  # BUG:
#### julia-debug: codegen.cpp:3005: llvm::Value* emit_assignment(llvm::Value*, jl_value_t*, jl_value_t*, bool, bool, jl_codectx_t*): 
#### Assert on `rval->getType() == jl_pvalue_llvmt || rval->getType() == NoopType' failed.
#end
