module libSingular

# export n_coeffType, number, coeffs

using Cxx


# Ring?   
# todo: add default constructor for QQ, Fp ?! 
# TODO: fix the following to work 
# 2 into separate low-level functions
# 3 back to types <: mathematical using those functions!

typealias nMapFunc Cxx.CppFptr{Cxx.CppFunc{Cxx.CppPtr{Cxx.CxxQualType{Cxx.CppBaseType{:snumber},(false,false,false)},(false,false,false)},Tuple{Cxx.CppPtr{Cxx.CxxQualType{Cxx.CppBaseType{:snumber},(false,false,false)},(false,false,false)},Cxx.CppPtr{Cxx.CxxQualType{Cxx.CppBaseType{:n_Procs_s},(false,false,false)},(false,false,false)},Cxx.CppPtr{Cxx.CxxQualType{Cxx.CppBaseType{:n_Procs_s},(false,false,false)},(false,false,false)}}}}

typealias n_coeffType Cxx.CppEnum{:n_coeffType} # pcpp"n_coeffType" # 

typealias __mpz_struct pcpp"__mpz_struct"
#Cxx.CppPtr{Cxx.CxxQualType{Cxx.CppBaseType{:__mpz_struct},(false,false,false)},(false,false,false)}

typealias mpz_t pcpp"mpz_t"
#Cxx.CppPtr{Cxx.CxxQualType{Cxx.CppBaseType{:mpz_t},(false,false,false)},(false,false,false)}


## todo: avoid the above!
function n_Zp(); return(@cxx n_Zp); end # n_coeffType::
# /**< \F{p < 2^31} */

function n_Q(); return(@cxx n_Q); end  # 
# @cxx get_Q(); # Cxx.CppEnum{:n_coeffType}(2) /**< rational (GMP) numbers */

function n_R(); return(@cxx n_R); end # 
#,  /**< single prescision (6,6) real numbers */

#function n_GF(); return(@cxx n_GF); end # 
# , /**< \GF{p^n < 2^16} */

#n_algExt() = (@cxx n_algExt) # ,  /**< used for all algebraic extensions, i.e.,the top-most extension in an extension tower is algebraic */
#n_transExt() = (@cxx n_transExt) #,  /**< used for all transcendental extensions, i.e.,the top-most extension in an extension tower is transcendental */

function n_long_R(); return(@cxx n_long_R); end # , /**< real floating point (GMP) numbers */
function n_long_C(); return(@cxx n_long_C); end
# , /**< complex floating point (GMP) numbers */

#  n_Z, /**< only used if HAVE_RINGS is defined: ? */
function n_Z(); return(@cxx n_Z); end
 # @cxx get_Z(); # Cxx.CppEnum{:n_coeffType}(9)

#n_Zn() =  (@cxx n_Zn) # , /**< only used if HAVE_RINGS is defined: ? */
#n_Znm() =  (@cxx n_Znm) # , /**< only used if HAVE_RINGS is defined: ? */
#n_Z2m() =  (@cxx n_Z2m) # , /**< only used if HAVE_RINGS is defined: ? */

#function n_CF(); return(@cxx n_CF); end #  /**< ? */


function __libSingular_init__()

   const local prefix = joinpath(Pkg.dir("Nemo"), "local")

   addHeaderDir(joinpath(prefix, "include"), kind = C_System)
   addHeaderDir(joinpath(prefix, "include", "singular"), kind = C_System)

   cxxinclude(joinpath("Singular", "libsingular.h"), isAngled=false)
   cxxinclude(joinpath("omalloc", "omalloc.h"), isAngled=false)
   cxxinclude(joinpath("gmp.h"), isAngled=false)
   cxxinclude(joinpath("reporter", "reporter.h"), isAngled=false)
   cxxinclude(joinpath("coeffs", "coeffs.h"), isAngled=false)
   cxxinclude(joinpath("polys", "monomials", "ring.h"), isAngled=false)
   cxxinclude(joinpath("polys", "monomials", "p_polys.h"), isAngled=false)

cxx"""
    #include "Singular/libsingular.h"
    #include "omalloc/omalloc.h"
    #include "gmp.h"
    #include "reporter/reporter.h"
    #include "coeffs/coeffs.h"

    #include <polys/monomials/ring.h>
    #include <polys/monomials/p_polys.h>

    static void _omFree(void* p){ omFree(p); }
    static void _PrintLn(){ PrintLn(); } 
    static void _PrintS(const void *p)
    { PrintS((const char*)(p));}
    static long  _siRand(){ return siRand(); }
    static number _n_Power(number a, int b, const coeffs r)
    { number res; n_Power(a, b, &res, r); return res; }
    static number _n_Delete(number a,const coeffs r)
    {number t = a; n_Delete(&t,r); return (t);}


    static void _n_WriteLong(number* n, const coeffs cf)
    { n_WriteLong(*n, cf); } 

    static void _n_WriteShort(number* n, const coeffs cf)
    { n_WriteShort(*n, cf); } 

    static number _n_Normalize(number n, const coeffs cf)
    { n_Normalize(n, cf); return n; } 

    static number _n_GetDenom(number* n, const coeffs cf)
    { return n_GetDenom(*n, cf); } 

    static number _n_GetNumerator(number* n, const coeffs cf)
    { return n_GetNumerator(*n, cf); } 

    static void _n_Write(number* n, const coeffs cf, int d)
    { n_Write(*n, cf, d); }

    static number _n_Neg(number n, const coeffs cf)
    { number nn = n_Copy(n, cf); nn = n_InpNeg(nn, cf); return nn; }

// static FORCE_INLINE long n_Int(number &n,       const coeffs r)
    static long _n_Int(number *n, const coeffs cf)
    { return (n_Int(*n, cf)); }

// void n_MPZ(mpz_t result, number &n,       const coeffs r)
//    static void _n_MPZ(void *r, number *n, const coeffs cf)
//    { n_MPZ((mpz_t)r, *n, cf); }

    static ring test_create_ring2(const coeffs cf)
    { char* ns[] = {(char*)"x", (char*)"y"}; return rDefault( cf, 2, ns); }

    static poly test_create_poly(const long n, const ring r)
    {  return p_ISet(n, r); }

    static void omalloc_mem_info_and_stats()
    {
       printf("Singular::omalloc INFO & STATs: \n");
       fflush(stdout);
       omPrintStats(stdout);
       omPrintInfo(stdout);
       printf("\n"); 
       fflush(stdout);
    }

    static coeffs nGFInitChar(int ch, int d, const char* s)
    {
	GFInfo par;
	par.GFChar=ch;
	par.GFDegree=d;
	par.GFPar_name=s;
	return nInitChar(n_GF, (void*)&par);
    }

    static number nApplyMapFunc(nMapFunc f, number n, const coeffs src, const coeffs dst){ return f(n, src, dst); }

"""

   local const binSingular = joinpath(prefix, "bin", "Singular")
   ENV["SINGULAR_EXECUTABLE"] = binSingular

   # Initialize Singular!
   siInit(binSingular) 

   # unique coeffs:

   # Ring:
   global ptr_ZZ = (@cxx coeffs_BIGINT)

# nInitChar(n_Z(), Ptr{Void}(0)) 
   @assert (ptr_ZZ != C_NULL)

   # Fields:
   global ptr_QQ = nInitChar(n_Q(), C_NULL) # Ptr{Void}(0))
   @assert (ptr_QQ != C_NULL) 

   global ptr_RR = nInitChar(n_long_R(), C_NULL) # Ptr{Void}(0))
   @assert (ptr_RR != C_NULL)

   global ptr_CC = nInitChar(n_long_C(), C_NULL) # Ptr{Void}(0))
   @assert (ptr_CC != C_NULL)

   global ptr_Rr = nInitChar(n_R(), C_NULL) # Ptr{Void}(0)) # Numeric?!
   @assert (ptr_Rr != C_NULL) # coeffs(0))


   global setMap_QQ2ZZ = n_SetMap(ptr_QQ, ptr_ZZ)
   @assert (setMap_QQ2ZZ != C_NULL)

   global setMap_ZZ2QQ = n_SetMap(ptr_ZZ, ptr_QQ)
   @assert (setMap_ZZ2QQ != C_NULL)

end

function siInit(p)
   @cxx siInit(pointer(p))
end


# @cxx PrintS(s)  # BUG: PrintS is a C function
# icxx""" PrintS($s); """   # quick and dirty shortcut
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
   return Int(@cxx _siRand())
end

function omPrintInfoStats()
   @cxx omalloc_mem_info_and_stats();
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




### FIXME : Cxx Type?
typealias coeffs Cxx.CppPtr{Cxx.CxxQualType{Cxx.CppBaseType{:n_Procs_s},(false,false,false)},(false,false,false)}
# cpcpp"coeffs" 
# Ptr{Void}

global ptr_ZZ = C_NULL # coeffs(0)
global ptr_QQ = C_NULL
global ptr_RR = C_NULL
global ptr_CC = C_NULL
global ptr_Rr = C_NULL
global setMap_QQ2ZZ = C_NULL
global setMap_ZZ2QQ = C_NULL


typealias const_coeffs coeffs # pcpp"const coeffs"
# NOTE: no need in coeffs_ptr, right?

# essentially: Ptr{Void}
typealias number Cxx.CppPtr{Cxx.CxxQualType{Cxx.CppBaseType{:snumber},(false,false,false)},(false,false,false)}
# pcpp"number" #
typealias const_number number # pcpp"const number"

typealias number_ptr Ptr{number}
#pcpp"number*" # Ptr{number} ### ?: Cxx should auto-support Ptr & Ref... 
typealias number_ref Ref{number} ###   rcpp"number" # 


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
function nCoeffString(cf :: const_coeffs)
   return @cxx nCoeffString(cf)
end

# char * nCoeffName(const coeffs cf)
function nCoeffName(cf :: const_coeffs)
   return @cxx nCoeffName(cf)
end

function n_Init(i::Int, cf :: coeffs) 
   return @cxx n_Init(i, cf)
end

### immutable _

# BigInt ?!
# number n_InitMPZ(mpz_t n,     const coeffs r) # TODO: BigInt???

function n_InitMPZ(b :: BigInt, cf :: coeffs)
#    println(mpz_t)
#    println(__mpz_struct)

    bb = __mpz_struct(pointer_from_objref(b))

#    println()
#    println(bb)
#    println(typeof(bb))

    return @cxx n_InitMPZ( bb, cf )
###   return icxx""" return n_InitMPZ((mpz_t)$b, $cf); """ ## TODO!?
end

# void n_MPZ(mpz_t result, number &n,       const coeffs r)
function n_MPZ(a :: number_ref, cf :: coeffs)

    b = BigInt()
    bb = pointer_from_objref(b)

#  number n = $a; $a = n; 
    icxx""" n_MPZ((__mpz_struct *)$bb, $a, $cf); """

###    println("bb [", typeof(bb), "] : ", bb)

    return b # bb[] 
#     error("Sorry: n_MPZ - not yet ready");


end

## static FORCE_INLINE void number2mpz(number n, coeffs c, mpz_t m){ n_MPZ(m, n, c); }
## static FORCE_INLINE number mpz2number(mpz_t m, coeffs c){ return n_InitMPZ(m, c); }
# long n_Int(number &n,       const coeffs r)

function n_Int(n :: number_ref, cf :: coeffs) 

     r = icxx""" return n_Int($n, $cf); """

#    nn :: number = n[]
#    r = (@cxx _n_Int(&nn, cf))
#    n[] = nn;
    return r

    # Got bad type information while compiling Cxx.CppNNS{Tuple{:n__Int}} 
 # (got Base.RefValue{Cxx.CppPtr{Cxx.CxxQualType{Cxx.CppBaseType{:snumber},(false,false,false)},(false,false,false)}} for argument 1
end


function n_Copy(n :: number, cf :: coeffs) 
   return @cxx n_Copy(n, cf)
end

function n_Print(n :: number, cf :: coeffs) 
   @cxx n_Print(n, cf)
end


#function n_Delete(n_ptr :: number_ptr, cf :: coeffs)
#   @cxx n_Delete(n_ptr, cf)
#end

function n_Delete(n :: number_ref, cf :: coeffs)
##   m = number(n)
#  # @cxx n_Delete(n_ref, cf)
#  n = n_ref[]
  icxx""" number k = $n; n_Delete(&k, $cf); $n = k; """
##   n = number(0)
end

function _n_Delete(n :: number, cf :: coeffs)
   return (@cxx _n_Delete(n, cf))
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



# void n_Write(number& n,  const coeffs r, const BOOLEAN bShortOut = TRUE)
function n_Write( n::number_ref, cf :: coeffs, bShortOut::Bool = false )
   const d :: Int = (bShortOut? 1 : 0)

   icxx""" n_Write($n, $cf, $d); """ 

#   nn :: number = n[]
##   @cxx _n_Write(&nn, cf, d);
#   n[] = nn

end


#, (:n_Normalize)
        function n_Normalize(x :: number_ref, cf :: coeffs) 
	    icxx""" n_Normalize($x, $cf); """

#	    xx = x[] 
#            ret = @cxx _n_Normalize(xx, cf)
#	    x[] = ret
        end


# number n_GetNumerator(number& n, const coeffs r)
function _n_GetNumerator(x :: number_ref, cf :: coeffs)
    return icxx""" return n_GetNumerator($x, $cf); """
end

# number n_GetDenom(number& n, const coeffs r)
function _n_GetDenom(x :: number_ref, cf :: coeffs)
    return icxx""" return n_GetDenom($x, $cf); """
end


#### The following are not used ATM
# void   n_WriteShort(number& n,  const coeffs r)
# void   n_WriteLong(number& n,  const coeffs r)
#for (f) in ((:n_WriteLong), (:n_WriteShort))
#    @eval begin
#        function ($f)(x :: number_ref, cf :: coeffs) 
#            @cxx ($f)(x, cf)
#        end
#    end
#end


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

# Div(a,b) = QuotRem(a,b, &IntMod(a,b))
# static FORCE_INLINE number  n_QuotRem(number a, number b, number *q, const coeffs r)
# Div(a,b), IntMod(a,b)
function n_QuotRem(a::number, b::number, cf::coeffs)
    m = number_ref(number(0));
    q = number_ref(number(0));

    icxx""" number mm = $m; $q = n_QuotRem($a, $b, &mm, $cf); $m = mm; """

    q[], m[]
end


# void   n_Power(number a, int b, number *res, const coeffs r)
function n_Power(a::number, b::Int, cf::coeffs)
    return (@cxx _n_Power(a, b, cf));
end

function n_ExtGcd(a::number, b::number, cf:: coeffs)
   s = number_ref( number(0) )
   t = number_ref( number(0) )

## number n_ExtGcd(number a, number b, number *s, number *t, const coeffs r)
   g = number_ref( number(0) )

   icxx""" number ss, tt; $g = n_ExtGcd($a, $b, &ss, &tt, $cf); $s = ss; $t = tt; """

######   g = @cxx n_ExtGcd(a, b, &s, &t, cf)

   @assert (g[] != number(0)) | (s[] != number(0)) | (t[] != number(0))

   g[], s[], t[]
end

## number n_XExtGcd(number a, number b, number *s, number *t, number *u, number *v, const coeffs r)
function n_XExtGcd(a::number, b::number, cf:: coeffs)
   g = number(0)
   s = number(0)
   t = number(0)
   u = number(0)
   v = number(0) # TODO: with REF!

###   g = @cxx n_XExtGcd(a, b, &s, &t, &u, &v, cf); # ??
   icxx""" number ss, tt, uu, vv; $g = n_XExtGcd($a, $b, &ss, &tt, &uu, &vv, $cf); $s = ss; $t = tt; $u = uu; $v = vv; """
   g, s, t, u, v
end

## number n_QuotRem(number a, number b, number *q, const coeffs r)
function n_QuotRem(a::number, b::number, cf:: coeffs)
   q = number_ref( number(0) )
   r = number_ref( number(0) )

   icxx""" number qq; $r = n_QuotRem($a, $b, &qq, $cf); $q = qq; """

   @assert (q[] != number(0)) | (r[] != number(0))

   r[], q[]
end



# number n_ChineseRemainderSym(number *a, number *b, int rl, BOOLEAN sym,CFArray &inv_cache,const coeffs r)

## nMapFunc n_SetMap(const coeffs src, const coeffs dst)
n_SetMap(src :: coeffs, dst :: coeffs) = @cxx n_SetMap(src, dst)

###    static number nApplyMapFunc(nMapFunc f, number n, const coeffs src, const coeffs dst){ return f(n, src, dst); }
nApplyMapFunc(f :: nMapFunc, n :: number, src :: coeffs, dst :: coeffs) = @cxx nApplyMapFunc(f, n, src, dst)


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

## normal function : -copy...
function n_Neg(x :: number, cf :: coeffs) 
   return @cxx _n_Neg(x, cf)
end


typealias ring Cxx.CppPtr{Cxx.CxxQualType{Cxx.CppBaseType{:ip_sring},(false,false,false)},(false,false,false)}
# Ptr{Void}

typealias poly Ptr{Void}

end # libSingular module