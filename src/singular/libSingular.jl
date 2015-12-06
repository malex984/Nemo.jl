module libSingular

using Cxx

function __libSingular_init__()

   const local prefix = joinpath(Pkg.dir("Nemo"), "local")

#   print("prefix: ");    println(prefix);
#   return

   addHeaderDir(joinpath(prefix, "include"), kind = C_System)
   addHeaderDir(joinpath(prefix, "include", "singular"), kind = C_System)

#   println("cxx #includes1:")
#   return

   cxxinclude("Singular/libsingular.h", isAngled=false)
   cxxinclude("omalloc/omalloc.h", isAngled=false)
   cxxinclude("reporter/reporter.h", isAngled=false)
   cxxinclude("coeffs/coeffs.h", isAngled=false)

##   println("cxx #includes2:")
##   return

cxx"""
    #include "Singular/libsingular.h"
    #include "omalloc/omalloc.h"
    #include "reporter/reporter.h"
    #include "coeffs/coeffs.h"
"""

#   println("cxx fun wraps:")
#   return

cxx"""
    static void _omFree(void* p){ omFree(p); }
    static void _PrintLn(){ PrintLn(); } 
    static void _PrintS(const void *p)
    { PrintS((const char*)(p));}
    static int  _siRand(){ return siRand(); }
    static number _n_Power(number a, int b, const coeffs r)
    { number res; n_Power(a, b, &res, r); return res; }
    static void _n_Delete(number a,const coeffs r)
    {n_Delete(&a,r);}
"""
#   println("n_coeffType:")
#   return

cxx"""
// TODO: follow https://github.com/Keno/Cxx.jl#example-6-using-c-enums 
//   static n_coeffType get_Q() { return n_Q; };
//   static n_coeffType get_Z() { return n_Z; };
//   static n_coeffType get_Zp(){ return n_Zp; }; 
"""

   const local singular_binary_path=joinpath(prefix, "bin", "Singular")
   ENV["SINGULAR_EXECUTABLE"] = singular_binary_path
##   libSingular = Libdl.dlopen(joinpath(prefix, "lib", "libSingular"), Libdl.RTLD_GLOBAL)

#   println("siInit, with $singular_binary_path")
 
#  OK

   # Initialize Singular!
   siInit(singular_binary_path) 
#   return
end



function siInit(p)
   pp = pointer(p); print("pp: $pp::::::")

#   PrintLn();
#   PrintS(pp); PrintLn();
#   @cxx siInit(pp)

   println("siInit - done!!!")
   return
end


# @cxx PrintS(s)  # BUG: PrintS is a C function
# icxx" PrintS($s); "   # quick and dirty shortcut
# PrintS(m) = ccall( Libdl.dlsym(Nemo.libsingular, :PrintS), Void, (Ptr{Uint8},), m) # workaround for C function

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

function PrintResources(s)
   StringSetS(s)
   feStringAppendResources(0)
   m = StringEndS()
   PrintS(m)
   omFree(m)
end


typealias number libSingular.number
typealias number_ptr libSingular.number_ptr
typealias number_ref libSingular.number_ref



# Ring?   
# todo: add default constructor for QQ, Fp ?! 
# TODO: fix the following to work 
# 2 into separate low-level functions
# 3 back to types <: mathematical using those functions!

typealias n_coeffType Cxx.CppEnum{:n_coeffType}

## todo: avoid the above!
n_Zp() = @cxx get_Zp(); #  # get_Zp() = icxx" return n_Zp; "
n_Q()  = @cxx get_Q(); # Cxx.CppEnum{:n_coeffType}(2) # icxx" return n_Q; "
n_Z() = @cxx get_Z(); # Cxx.CppEnum{:n_coeffType}(9) # icxx" return n_Z; "

### FIXME : Cxx Type?
typealias coeffs Cxx.CppPtr{Cxx.CxxQualType{Cxx.CppBaseType{:n_Procs_s},(false,false,false)},(false,false,false)}
# Ptr{Void}

typealias number Cxx.CppPtr{Cxx.CxxQualType{Cxx.CppBaseType{:snumber},(false,false,false)},(false,false,false)}
# Ptr{Void}

typealias number_ptr Ptr{number} ### FIXME : Cxx Ptr & Ref ???

typealias number_ref Ref{number} ### TODO?

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


# BigInt ?!
# number n_InitMPZ(mpz_t n,     const coeffs r) # TODO: BigInt???
function n_InitMPZ(b :: BigInt, cf :: coeffs)
   return @cxx n_InitMPZ(b, cf)
end

## static FORCE_INLINE void number2mpz(number n, coeffs c, mpz_t m){ n_MPZ(m, n, c); }
## static FORCE_INLINE number mpz2number(mpz_t m, coeffs c){ return n_InitMPZ(m, c); }


function n_Int(n :: number, cf :: coeffs) 
   return @cxx n_Int(n, cf)
end

function n_Print(n :: number, cf :: coeffs) 
   @cxx n_Print(n, cf)
end


#function n_Delete(n_ptr :: number_ptr, cf :: coeffs)
#   @cxx n_Delete(n_ptr, cf)
#end

#function n_Delete(n :: number, cf :: coeffs)
##   m = number(n)
#  # @cxx n_Delete(n_ref, cf)
#  n = n_ref[]
#  icxx"n_Delete($n_ref, $cf);"
##   n = number(0)
#end

function _n_Delete(n :: number, cf :: coeffs)
   @cxx _n_Delete(n, cf)
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


## BOOLEAN nCoeff_is_Ring(const coeffs r)
## BOOLEAN nCoeff_is_Domain(const coeffs r)
## BOOLEAN nCoeff_has_simple_inverse(const coeffs r) nCoeff_has_simple_Alloc
for (f) in ((:nCoeff_is_Ring), (:nCoeff_is_Domain), (:nCoeff_has_simple_inverse), (:nCoeff_has_simple_Alloc))
    @eval begin
        function ($f)(cf :: coeffs)
            ret = @cxx ($f)(cf)
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

##### number n_ChineseRemainderSym(number *a, number *b, int rl, BOOLEAN sym,CFArray &inv_cache,const coeffs r)
## nMapFunc n_SetMap(const coeffs src, const coeffs dst)
## number n_Random(siRandProc p, number p1, number p2, const coeffs cf)

### void n_WriteFd(number a, FILE *f, const coeffs r)
### number n_ReadFd( s_buff f, const coeffs r)

## number n_convFactoryNSingN( const CanonicalForm n, const coeffs r);
## CanonicalForm n_convSingNFactoryN( number n, BOOLEAN setChar, const coeffs r );

## n_coeffType getCoeffType(const coeffs r)
function getCoeffType(r :: coeffs ) 
   return @cxx getCoeffType(r) 
end





### TODO: move above
# number  n_InpNeg(number n, const coeffs r) # to be used only as: n = n_InpNeg(n, cf);
n_InpNeg(x, cf :: coeffs) = return (x = @cxx n_InpNeg(x, cf))











end