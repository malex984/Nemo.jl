###############################################################################
#
#   Types.jl : Parent and object types for Singular
#
###############################################################################
export SingularField, SingularFieldElem, Coeffs, Number, SingularQQ, SingularZZ
export elem_type, base_ring, check_parent, show
export characteristic 


using Cxx


const prefix = joinpath(Pkg.dir("Nemo"), "local")
const singular_binary_path = joinpath(prefix, "bin", "Singular")

libSingular = Libdl.dlopen(joinpath(prefix, "lib", "libSingular"), Libdl.RTLD_GLOBAL)


ENV["SINGULAR_EXECUTABLE"] = singular_binary_path

addHeaderDir(joinpath(prefix, "include"), kind = C_System)
addHeaderDir(joinpath(prefix, "include", "singular"), kind = C_System)

cxxinclude("Singular/libsingular.h", isAngled=false)
cxxinclude("coeffs/coeffs.h", isAngled=false)

cxx"""
    #include "Singular/libsingular.h"

    #include "omalloc/omalloc.h"
    #include "reporter/reporter.h"

    #include "coeffs/coeffs.h"

    static void _omFree(void* p){ omFree(p); }
    static void _PrintLn(){ PrintLn(); } 
    static void _PrintS(const void *p){ PrintS((const char*)(p)); } 
    static int  _siRand(){ return siRand(); }
    static number _n_Power(number a, int b, const coeffs r)
    {
      number res; n_Power(a, b, &res, r);
      return res;
    }
"""

# @cxx PrintS(s)  # BUG: PrintS is a C function
# icxx" PrintS($s); "   # quick and dirty shortcut
# PrintS(m) = ccall( Libdl.dlsym(Nemo.libSingular, :PrintS), Void, (Ptr{Uint8},), m) # workaround for C function
function PrintS(m)
   @cxx _PrintS(m)
end 
function PrintLn()
   @cxx _PrintLn()
end 
function omFree(m)
   @cxx _omFree(m)
end 
function siRand()
   return @cxx siRand()
end


function StringSetS(m) 
   @cxx StringSetS(pointer(m))
end

function StringEndS() 
   return @cxx StringEndS()
end

function feStringAppendResources(i :: Int = -1)
   @cxx feStringAppendResources(i)
end

function siInit(p) 
   @cxx siInit(pointer(p))
end


siInit(singular_binary_path) # Initialize Singular!

function PrintResources(s)
   StringSetS(s)
   feStringAppendResources(0)
   m = StringEndS()
   PrintS(m)
   omFree(m)
end



###############################################################################
#
#   SingularFields
#
###############################################################################

abstract SingularField <: Field{Singular}
abstract SingularFieldElem <: FieldElem ### {Singular}?

const CoeffID = ObjectIdDict() # Dict{Ptr{Void}, SingularField}()

# Ring?   
# todo: add default constructor for QQ, Fp ?! 
# TODO: fix the following to work 
# 2 into separate low-level functions
# 3 back to types <: mathematical using those functions!

typealias n_coeffType Cxx.CppEnum{:n_coeffType}

cxx"""
static n_coeffType get_Q() { return n_Q; };
static n_coeffType get_Z() { return n_Z; };
static n_coeffType get_Zp(){ return n_Zp; }; // n_coeffType.
"""
## todo: avoid the above!
const n_Zp = @cxx get_Zp() #  # get_Zp() = icxx" return n_Zp; "
const n_Q  = @cxx get_Q() # Cxx.CppEnum{:n_coeffType}(2) # icxx" return n_Q; "
const n_Z  = @cxx get_Z() # Cxx.CppEnum{:n_coeffType}(9) # icxx" return n_Z; "

typealias coeffs Cxx.CppPtr{Cxx.CxxQualType{Cxx.CppBaseType{:n_Procs_s},(false,false,false)},(false,false,false)}
# Ptr{Void}

typealias number Cxx.CppPtr{Cxx.CxxQualType{Cxx.CppBaseType{:snumber},(false,false,false)},(false,false,false)}
# Ptr{Void}

typealias number_ptr Ptr{number}

# include("cxx_singular_lowlevel.jl") # TODO: move most wrappers there from around here!

function nInitChar(n :: n_coeffType, p :: Ptr{Void})
   return @cxx nInitChar( n, p )
end

function nKillChar(cf::coeffs)
   @cxx nKillChar(cf)
end

function n_GetChar(cf::coeffs)
   @cxx n_GetChar(cf)
end

function n_CoeffWrite(cf :: coeffs, details::Bool = true)
   d :: Int = (details? 1 : 0)
   @cxx n_CoeffWrite(cf, d)
end

# char * nCoeffString(const coeffs cf)
function nCoeffString(cf :: coeffs)
   return @cxx nCoeffString(cf)
end

# char * nCoeffName(const coeffs cf)
function nCoeffName(cf :: coeffs)
   return @cxx nCoeffName(cf)
end

function n_Init(i::Int, cf :: coeffs) 
   return @cxx n_Init(i, cf)
end

# number n_InitMPZ(mpz_t n,     const coeffs r) # TODO: BigInt???

## static FORCE_INLINE void number2mpz(number n, coeffs c, mpz_t m){ n_MPZ(m, n, c); }
## static FORCE_INLINE number mpz2number(mpz_t m, coeffs c){ return n_InitMPZ(m, c); }


function n_Int(n :: number, cf :: coeffs) 
   return @cxx n_Int(n, cf)
end

function n_Print(n :: number, cf :: coeffs) 
   @cxx n_Print(n, cf)
end

function n_Delete(n_ptr, cf :: coeffs)
   @cxx n_Delete(n_ptr, cf)
end

###############################################################################
#
#   Binary operators and functions
#
###############################################################################

#### Metaprogram to define functions :
# BOOLEAN n_DivBy(number a, number b, const coeffs r)
# BOOLEAN n_Greater(number a, number b, const coeffs r)
# BOOLEAN n_Equal(number a, number b, const coeffs r)

for (f) in ((:n_DivBy), (:n_Greater), (:n_Equal))
    @eval begin
        function ($f)(x :: number, y :: number, cf :: coeffs)
            ret = @cxx ($f)(x, y, cf)
            return (ret > 0)
        end
    end
end


#### Metaprogram to define functions :
# BOOLEAN n_IsOne(number n,  const coeffs r)
# BOOLEAN n_IsMOne(number n, const coeffs r)
# BOOLEAN n_GreaterZero(number n, const coeffs r)
# BOOLEAN n_IsZero(number n, const coeffs r)

for (f) in ((:n_IsOne), (:n_IsMOne), (:n_IsZero), (:n_GreaterZero))
    @eval begin
        function ($f)(x :: number, cf :: coeffs)
            ret = @cxx ($f)(x, cf)
            return (ret > 0)
        end
    end
end

# int    n_Size(number n,    const coeffs r)
n_Size(x :: number, cf :: coeffs) = @cxx n_Size(x, cf)

# int n_ParDeg(number n, const coeffs r)
n_ParDeg(x :: number, cf :: coeffs) = @cxx n_ParDeg(x, cf)

# int n_NumberOfParameters(const coeffs r)
n_NumberOfParameters(cf :: coeffs) = @cxx n_NumberOfParameters(cf)
 
# number n_Param(const int iParameter, const coeffs r)
n_Param(i::Int, cf :: coeffs) = @cxx n_Param(i, cf)



# n_Write(number& n,  const coeffs r, const BOOLEAN bShortOut = TRUE)
function n_Write(n, cf :: coeffs, bShortOut::Bool = true)
   d :: Int = (bShortOut? 1 : 0) 
   @cxx n_Write(n, cf, d)
end


#### Metaprogram to define functions :
# number  n_Invers(number a, const coeffs r)
# number  n_EucNorm(number a, const coeffs r)
# number  n_Ann(number a, const coeffs r)
# number  n_RePart(number i, const coeffs cf)
# number  n_ImPart(number i, const coeffs cf)

for (f) in ((:n_Invers), (:n_EucNorm), (:n_Ann), (:n_RePart), (:n_ImPart))
    @eval begin
        function ($f)(x :: number, cf :: coeffs) 
            return @cxx ($f)(x, cf)
        end
    end
end

#### Metaprogram to define functions :
# number n_Add(number a, number b, const coeffs r)
# number n_Sub(number a, number b, const coeffs r)
# number n_Div(number a, number b, const coeffs r)
# number n_Mult(number a, number b, const coeffs r)
# number n_ExactDiv(number a, number b, const coeffs r)
# number n_IntMod(number a, number b, const coeffs r)
# number n_Gcd(number a, number b, const coeffs r)
# number n_SubringGcd(number a, number b, const coeffs r)
# number n_Lcm(number a, number b, const coeffs r)
# number n_Farey(number a, number b, const coeffs r)
### number n_NormalizeHelper(number a, number b, const coeffs r)

for (f) in ((:n_Add), (:n_Sub), (:n_Div), (:n_Mult), (:n_ExactDiv),
            (:n_IntMod), (:n_Gcd), (:n_SubringGcd), (:n_Lcm), 
            (:n_Farey), (:n_NormalizeHelper))
    @eval begin
        function ($f)(x :: number, y :: number, cf :: coeffs)
            return @cxx ($f)(x, y, cf)
        end
    end
end

# void   n_Power(number a, int b, number *res, const coeffs r)
function n_Power(a::number, b::Int, cf::coeffs)
    return @cxx _n_Power(a, b, cf)
end

## number n_ExtGcd(number a, number b, number *s, number *t, const coeffs r)
## number n_XExtGcd(number a, number b, number *s, number *t, number *u, number *v, const coeffs r)
## number n_QuotRem(number a, number b, number *q, const coeffs r)
## number n_ChineseRemainderSym(number *a, number *b, int rl, BOOLEAN sym,CFArray &inv_cache,const coeffs r)

## BOOLEAN nCoeff_is_Ring(const coeffs r)
## BOOLEAN nCoeff_is_Domain(const coeffs r)

## nMapFunc n_SetMap(const coeffs src, const coeffs dst)
## number n_Random(siRandProc p, number p1, number p2, const coeffs cf)
## void n_WriteFd(number a, FILE *f, const coeffs r)
## number n_ReadFd( s_buff f, const coeffs r)
## number n_convFactoryNSingN( const CanonicalForm n, const coeffs r);
## CanonicalForm n_convSingNFactoryN( number n, BOOLEAN setChar, const coeffs r );

## n_coeffType getCoeffType(const coeffs r)
function getCoeffType(r :: coeffs ) 
   return @cxx getCoeffType(r) 
end

type Coeffs <: SingularField
   ptr :: coeffs

   function Coeffs(nt::n_coeffType, par::Ptr{Void}) 
      try
         return CoeffID[nt, par]
      catch
      end

      ptr = nInitChar(nt, par)
      (ptr == coeffs(0)) && error("Singular coeffs.domain construction failure")
      try
         cf = CoeffID[ptr]
	 nKillChar(ptr)
	 return cf
      catch
         d = CoeffID[nt, par] = CoeffID[ptr] = new(ptr)
         finalizer(d, _Coeffs_clear_fn)
         return d
      end
   end

   function Coeffs(ptr::coeffs) 
      (ptr == coeffs(0)) && error("Singular Coeffs construction failure: wrong raw pointer")
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

get_raw_ptr( cf::Coeffs ) = cf.ptr

function _Coeffs_clear_fn(cf::Coeffs)
   nKillChar( get_raw_ptr(cf) )
end

characteristic(c::Coeffs) = n_GetChar( get_raw_ptr(c) )

# char const * * n_ParameterNames(const coeffs r)

npars(c::Coeffs) = n_NumberOfParameters( get_raw_ptr(c) )

function par(i::Int, c::Coeffs) 
    ((i >= 1) && (i <= npars(c))) && return Number(c, n_Param(i, get_raw_ptr(c)))
    error("Wrong parameter index")
end 


type Number <: SingularFieldElem
    ptr :: number
    ctx :: Coeffs

    # void nNew(number * a) # ?

    # Integer?
    function Number(c::Coeffs, x::Int = 0)
        p = n_Init(x, get_raw_ptr(c))

        z = new(p, c)
        finalizer(z, _Number_clear_fn)
        return z
    end

    function Number(x::Number)
        c = parent(x) 
	p = n_Copy(get_raw_ptr(x), get_raw_ptr(c)) 

        z = new(p, c)
        finalizer(z, _Number_clear_fn)
        return z
    end

    function Number(c::Coeffs, p::number)
        z = new(p, c)
        finalizer(z, _Number_clear_fn)
        return z
    end
end

get_raw_ptr( n::Number ) = n.ptr
parent( n::Number ) = n.ctx

function _Number_clear_fn(n::Number)
   cf = get_raw_ptr(parent(n))
#   p = &n
#   n_Delete(Ptr{number}(pointer(n)), cf)
   @cxx n_Delete(&(n.ptr), cf)

#   n.ptr = p ## not necessary?
end

###############################################################################
#
#   Constructors
#
###############################################################################

# Number(c::Coeffs, s::String) = parseint(c, s)

#Number(c::Coeffs, z::Integer) = Number(BigInt(z))
#Number(c::Coeffs, z::Float16) = Number(Float64(z))
#Number(z::BigFloat) = Number(BigInt(z))





###############################################################################
#
#   String I/O
#
###############################################################################

function string(c::Coeffs)
   cf = get_raw_ptr(c)
   m = nCoeffString(cf)
   mm = nCoeffName(cf)

   return "Singular.Coeffs( " * bytestring(mm) * "|[" * bytestring(m) * "] )"
end

function string(n::Number)
   StringSetS("")
   n_Write( get_raw_ptr(n), get_raw_ptr(parent(n)) )
   m = StringEndS()
   s = bytestring(m)
   omFree(m)

   return "Singular.Number( " * s * ") "
end

needs_parentheses(x::Number) = true # TODO: is coeffs has parameters?
is_negative(x::Number) = isnegative(x) 
show_minus_one(::Type{Number}) = false

show(io::IO, c::Coeffs) = print(io, string(c))
show(io::IO, n::Number) = print(io, string(n))


const SingularQQ = Coeffs(n_Q, Ptr{Void}(0)) # SingularRationalField()
const SingularZZ = Coeffs(n_Z, Ptr{Void}(0)) # SingularRing()

# include("coeff.jl")
# include("poly.jl")


###############################################################################
#
#   Type and parent object methods
#
###############################################################################

elem_type(::Coeffs) = Number
elem_type(::Number) = Number

base_ring(a::Coeffs) = None
base_ring(a::Number) = None

function check_parent(a::Number, b::Number) 
   parent(a) != parent(b) && error("Operations on elements from distinct fields are not supported")
end

###############################################################################
#
#   Parent object call overloads
#
###############################################################################

Base.call(a::Coeffs) = Number(a)
Base.call(a::Coeffs, b::Int) = Number(a, b)
# Base.call(a::Coeffs, b::Integer) = Number(a, b)
## Base.call(a::Coeffs, b::String) = Number(a, b)

function Base.call(a::Coeffs, b::Number)
   a != parent(b) && error("Cperations on elements from different field are not supported")
   return b
end


###############################################################################
#
#   Conversions and promotions
#
###############################################################################

#### For the following we miss a context
#convert(::Type{Number}, a::Int) = Number(a)
#convert(::Type{Number}, a::Integer) = Number(a)

# convert(::Type{Rational{BigInt}}, a::fmpq) = Rational(a)
#function convert(::Type{BigInt}, a::Number)
#   r = BigInt()
#   ccall((:Number_get_mpz, :libflint), Void, (Ptr{BigInt}, Ptr{Number}), &r, &a)
#   return r
#end

#function convert(::Type{Int}, a::Number) 
#   return ccall((:Number_get_si, :libflint), Int, (Ptr{Number},), &a)
#end

#function convert(::Type{UInt}, x::Number)
#   return ccall((:Number_get_ui, :libflint), UInt, (Ptr{Number}, ), &x)
#end

#function convert(::Type{Float64}, n::Number)
#    # rounds to zero
#end

#convert(::Type{Float32}, n::Number) = Float32(Float64(n))
#convert(::Type{Float16}, n::Number) = Float16(Float64(n))
#convert(::Type{BigFloat}, n::Number) = BigFloat(BigInt(n))

Base.promote_rule{T <: Integer}(::Type{Number}, ::Type{T}) = Number


###############################################################################
#
#   Basic manipulation
#
###############################################################################

function hash(a::Number)
   return hash(parent(a)) $ hash(string(a))  ## TODO: string may be a bit too inefficient wherever hash is used...?
end

function hash(a::Coeffs)
   h = 0x8a30b0d963237dd5 # TODO: change this const to something uniqe!
   return hash(string(a))  ## TODO: string may be a bit too inefficient wherever hash is used...?
end

deepcopy(a::Number) = Number(a)
zero(a::Coeffs) = Number(a, 0)
one(a::Coeffs) = Number(a, 1)

isunit(a::Number) = !iszero(a)  # NOTE:Coeff.  Rings are not supported at the moment

###############################################################################
#
#   Canonicalisation
#
###############################################################################

canonical_unit(x::Number) = isnegative(x) ? Number(parent(x), -1) : Number(parent(x), 1)


###############################################################################
#
#   Unsafe operators
#
###############################################################################

### void n_InpMult(number &a, number b, const coeffs r)
### void n_InpAdd(number &a, number b, const coeffs r)

for (fJ, fC) in ((:muleq!, :n_InpMult), (:addeq!, :n_InpAdd))
    @eval begin
        function ($fJ)(x :: Number, y :: Number)
            check_parent(x, y)
            cf = get_raw_ptr(parent(x))
            @cxx ($fC)(x.ptr, y.ptr, cf) ### FIXME!!!!
        end
    end
end

###############################################################################
#
#   ? DEN ? NUM ? NORM ?
#
###############################################################################

# number  n_InpNeg(number n, const coeffs r) # to be used only as: n = n_InpNeg(n, cf);
n_InpNeg(x, cf :: coeffs) = return (x = @cxx n_InpNeg(x, cf))

### void   n_Normalize(number& n, const coeffs r) # use cxx""" """  and  pointers?
### number n_GetDenom(number& n, const coeffs r)
### number n_GetNumerator(number& n, const coeffs r)

for (fJ, fC) in ((:numerator, :n_GetNumerator), (:denominator, :n_GetDenom), (:normalize, :n_Normalize))
    @eval begin
        function ($fJ)(x :: Number)
            cf = get_raw_ptr(parent(x))
            return @cxx ($fC)(x.ptr, cf) ### FIXME? 
        end
    end
end

num(x::Number) = numerator(x)
den(x::Number) = denominator(x)

###############################################################################
#
#   Binary operators and functions
#
###############################################################################

# Metaprogram to define functions +, -, *, gcd, lcm
                                 
for (fJ, fC) in ((:+, :n_Add), (:-,:n_Sub), (:*, :n_Mult),
                 (:gcd, :n_Gcd), (:lcm, :n_Lcm) )
    @eval begin
        function ($fJ)(x::Number, y::Number)
            check_parent(x, y)
            c = parent(x)
            return  Number(c, ($fC)(get_raw_ptr(x), get_raw_ptr(y), get_raw_ptr(c)))
        end
        
        ($fJ)(x::Number, i::Int) = ($fJ)(x, parent(x)(i)) 
        ($fJ)(i::Int, x::Number) = ($fJ)(parent(x)(i), x)
    end
end

function divexact(x::Number, y::Number)
    iszero(y) && throw(DivideError())
    check_parent(x, y)
    c = parent(x)
    return Number(c, n_ExactDiv(get_raw_ptr(x), get_raw_ptr(y), get_raw_ptr(c))) 
end


# Metaprogram to define functions /, div, mod

for (fJ, fC) in ((:/, :n_Div), (:div, :n_DivExact), (:mod, :n_Mod))
    @eval begin
        function ($fJ)(x::Number, y::Number)
            iszero(y) == 0 && throw(DivideError())
            check_parent(x, y)
            c = parent(x)
            return  Number(c, ($fC)(get_raw_ptr(x), get_raw_ptr(y), get_raw_ptr(c)))
        end
        ($fJ)(x::Number, i::Int) = ($fJ)(x,  parent(x)(i)) 
        ($fJ)(i::Int, x::Number) = ($fJ)(parent(x)(i), x)
    end
end

###############################################################################
#
#   Powering
#
###############################################################################

function ^(x::Number, y::Int)
    if y < 0; throw(DomainError()); end
    if isone(x); return x; end
    if ismone(x); return isodd(y) ? x : -x; end
    if y > typemax(Uint); throw(DomainError()); end
    c = parent(x)
    if y == 0; return one(c); end
    if y == 1; return x; end
    return Number(c, n_Power(get_raw_ptr(x), y, get_raw_ptr(c)))
end


###############################################################################
#
#   Unary operators and functions
#
###############################################################################

function -(x::Number)
    return (parent(x)(0) - x)
end

function abs(x::Number)
    ispositive(x) && return x
    return (-x)
end

###############################################################################
#
#   Division with remainder
#
###############################################################################

#function divrem(x::Number, y::Number)
#    iszero(y) && throw(DivideError())
#    z1 = fmpz()
#    z2 = fmpz()
#    ccall((:fmpz_tdiv_qr, :libflint), Void, 
#          (Ptr{fmpz}, Ptr{fmpz}, Ptr{fmpz}, Ptr{fmpz}), &z1, &z2, &x, &y)
#    z1, z2
#end

function crt(r1::Number, m1::Number, r2::Number, m2::Number, signed=false)
#   z = fmpz()
#   ccall((:fmpz_CRT, :libflint), Void,
#          (Ptr{fmpz}, Ptr{fmpz}, Ptr{fmpz}, Ptr{fmpz}, Ptr{fmpz}, Cint),
#          &z, &r1, &m1, &r2, &m2, signed)
#   return z
end

#function crt(r1::Number, m1::Number, r2::Int, m2::Int, signed=false)
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

#function gcdx(a::Number, b::Number)
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
#end

#function gcdinv(a::Number, b::Number)
#   a < 0 && throw(DomainError())
#   b < a && throw(DomainError())
#   g = fmpz()
#   s = fmpz()
#   ccall((:fmpz_gcdinv, :libflint), Void,
#        (Ptr{fmpz}, Ptr{fmpz}, Ptr{fmpz}, Ptr{fmpz}),
#        &g, &s, &a, &b)
#   return g, s
#end

###############################################################################
#
#   Comparison
#
###############################################################################

for (fJ, fC) in ((:isone, :n_IsOne), (:ismone, :n_IsMOne), (:iszero, :n_IsZero), (:ispositive, :n_GreaterZero), (:size, :n_Size)) 
    @eval begin
        function ($fJ)(x :: Number)
            return ($fC)(get_raw_ptr(x), get_raw_ptr(parent(x)))
        end
    end
end

isnegative(a::Number) = (!iszero(a)) && (!ispositive(a))

function sign(a::Number)
    ispositive(a) && return 1
    iszero(a) && return 0
    return -1
end

function cmp(x::Number, y::Number)
    check_parent(x, y)
    cf = get_raw_ptr(parent(x))
    xx = get_raw_ptr(x) 
    yy = get_raw_ptr(y)

    n_Greater(xx, yy, cf)  && return 1
    n_Equal(xx, yy, cf)  && return 0

    return -1
end

==(x::Number, y::Number) = cmp(x,y) == 0

<=(x::Number, y::Number) = cmp(x,y) <= 0

>=(x::Number, y::Number) = cmp(x,y) >= 0

<(x::Number, y::Number) = cmp(x,y) < 0

>(x::Number, y::Number) = cmp(x,y) > 0

###############################################################################
#
#   Ad hoc comparison
#
###############################################################################

cmp(x::Number, y::Int) = cmp(x, Number(parent(x), y))

==(x::Number, y::Int) = cmp(x,y) == 0

<=(x::Number, y::Int) = cmp(x,y) <= 0

>=(x::Number, y::Int) = cmp(x,y) >= 0

<(x::Number, y::Int) = cmp(x,y) < 0

>(x::Number, y::Int) = cmp(x,y) > 0

cmp(x::Int, y::Number) = cmp(Number(parent(y), x), y)

==(x::Int, y::Number) = cmp(y,x) == 0

<=(x::Int, y::Number) = cmp(y,x) >= 0

>=(x::Int, y::Number) = cmp(y,x) <= 0

<(x::Int, y::Number) = cmp(y,x) > 0

>(x::Int, y::Number) = cmp(y,x) < 0


###############################################################################
#
#   Number theoretic/combinatorial
#
###############################################################################

function divisible(x::Number, y::Number)
   y == 0 && throw(DivideError())
#   Bool(ccall((:fmpz_divisible, :libflint), Cint, 
#              (Ptr{fmpz}, Ptr{fmpz}), &x, &y))
end

function divisible(x::Number, y::Int)
   y == 0 && throw(DivideError())
#   Bool(ccall((:fmpz_divisible_si, :libflint), Cint, 
#              (Ptr{fmpz}, Int), &x, y))
end


###############################################################################
#
#   Number bases/digits
#
###############################################################################

#bin(n::Number) = base(n, 2)
#oct(n::Number) = base(n, 8)
#dec(n::Number) = base(n, 10)
#hex(n::Number) = base(n, 16)

#function base(n::Number, b::Integer)
#    2 <= b <= 62 || error("invalid base: $b")
#    p = ccall((:fmpz_get_str,:libflint), Ptr{Uint8}, 
#              (Ptr{Uint8}, Cint, Ptr{fmpz}), C_NULL, b, &n)
#    len = Int(ccall(:strlen, Csize_t, (Ptr{Uint8},), p))
#    ASCIIString(pointer_to_array(p, len, true))
#end

###############################################################################
#
#   String parser
#
###############################################################################

#function parseint(c::Coeffs, s::String)
#    s = bytestring(s)
#    sgn = s[1] == '-' ? -1 : 1
#    i = 1 + (sgn == -1)
##    z = Number()
## TODO!
##    err = ccall((:Number_set_str, :libflint),
##               Int32, (Ptr{Number}, Ptr{Uint8}, Int32),
##               &z, bytestring(SubString(s, i)), base)
#    err == 0 || error("Invalid big integer: $(repr(s))")
#    return sgn < 0 ? -z : z
#end



###############################################################################
#
#   Serialisation
#
###############################################################################

#function serialize(s, c::Coeffs)
#    Base.serialize_type(s, Coeffs)
#    serialize(s, "(" * string(c) * ")")
#end

#function serialize(s, n::Number)
#    Base.serialize(s, parent(n))
#
#    Base.serialize_type(s, Number)
#    serialize(s, "(" * string(n) * ")")
#end

# deserialize(s, ::Type{Number}) = Base.parseint_nocheck(FlintZZ, deserialize(s), 62)
