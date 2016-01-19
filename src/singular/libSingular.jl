module libSingular
export n_coeffType, number, coeffs, n_Test, p_Test, r_Test
using Cxx
function __libSingular_init__()
   const local prefix = joinpath(Pkg.dir("Nemo"), "local")

   addHeaderDir(joinpath(prefix, "include"), kind = C_System)
   addHeaderDir(joinpath(prefix, "include", "singular"), kind = C_System)

   cxxinclude(joinpath("Singular", "libsingular.h"), isAngled=false)
   cxxinclude(joinpath("omalloc", "omalloc.h"), isAngled=false)
   cxxinclude(joinpath("gmp.h"), isAngled=false)
   cxxinclude(joinpath("debugbreak.h"), isAngled=false)
   cxxinclude(joinpath("reporter", "reporter.h"), isAngled=false)
   cxxinclude(joinpath("coeffs", "coeffs.h"), isAngled=false)
   cxxinclude(joinpath("polys", "monomials", "ring.h"), isAngled=false)
   cxxinclude(joinpath("polys", "monomials", "p_polys.h"), isAngled=false)
## NOTE: make sure the line number is correct in case of any changes above here!!!!
cxx"""#line 20 "libSingular.jl"
    #include "Singular/libsingular.h"
    #include "omalloc/omalloc.h"
    #include "gmp.h"
    #include "reporter/reporter.h"
    #include "coeffs/coeffs.h"

    #include <polys/monomials/ring.h>
    #include <polys/monomials/p_polys.h>

    #include "debugbreak.h"
    #include <cassert>

    static void _omFree(void* p){ omFree(p); }
    static void _PrintLn(){ PrintLn(); } 
    static void _PrintS(const void *p)
    { PrintS((const char*)(p));}
    static long  _siRand(){ return siRand(); }
    static number _n_Power(number a, int b, const coeffs r)
    { number res; n_Power(a, b, &res, r); return res; }

    static void _n_Delete(number a,const coeffs r)
    { number t = a; if(t != NULL) n_Delete(&t,r); /*return (t);*/ }

    static void _n_WriteLong(number* n, const coeffs cf)
    { n_WriteLong(*n, cf); } 

    static void _n_WriteShort(number* n, const coeffs cf)
    { n_WriteShort(*n, cf); } 

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

//    static ring test_create_ring2(const coeffs cf)
//    { char* ns[] = {(char*)"x", (char*)"y"}; return rDefault( cf, 2, ns); }

//    static poly test_create_poly(const long n, const ring r)
//    { return p_ISet(n, r); }

   static coeffs rGetCoeffs(const ring r)
   { return r->cf; }

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

    static bool _n_Test(number a,const coeffs cf)
    { 
      if(a == NULL) return (true); // ?
      return n_Test(a, cf);
    }

    static bool __p_Test(poly a, const ring r)
    { 
#ifdef PDEBUG
       if(a == NULL) return (true);
       return (_p_Test(a, r, PDEBUG));
#else
       return (true);	
#endif
    }


    static bool _r_Test(const ring r)
    { 
#ifdef RDEBUG
       return (rTest(r));
#else
       return (true);	
#endif
    }

    static void _p_Delete(poly a,const ring r)
    { poly t = a; if(t != NULL) p_Delete(&t,r); /*return (t);*/ }

    static void _break(){ assume(false); assert(false); debug_break(); }

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

typealias nMapFunc Cxx.CppFptr{Cxx.CppFunc{Cxx.CppPtr{Cxx.CxxQualType{Cxx.CppBaseType{:snumber},(false,false,false)},(false,false,false)},Tuple{Cxx.CppPtr{Cxx.CxxQualType{Cxx.CppBaseType{:snumber},(false,false,false)},(false,false,false)},Cxx.CppPtr{Cxx.CxxQualType{Cxx.CppBaseType{:n_Procs_s},(false,false,false)},(false,false,false)},Cxx.CppPtr{Cxx.CxxQualType{Cxx.CppBaseType{:n_Procs_s},(false,false,false)},(false,false,false)}}}}

typealias n_coeffType Cxx.CppEnum{:n_coeffType} # vcpp"n_coeffType" ## ? 

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
function omFree(m :: Ptr{Void})
   icxx"""omFree($m); """ #  @cxx _omFree(m)
end 
function omAlloc(size :: Csize_t)
   return icxx""" return (void*)omAlloc($size); """ 	 
end

function omAlloc0(size :: Csize_t)
   return icxx""" return (void*)omAlloc0($size); """ 	 
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
   omFree(Ptr{Void}(m))
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

function n_Init(i::Int64, cf :: coeffs) 
   return @cxx n_Init(i, cf)
end

### immutable _

# BigInt ?!
# number n_InitMPZ(mpz_t n,     const coeffs r) # TODO: BigInt???
function n_InitMPZ(b :: BigInt, cf :: coeffs)
    bb = __mpz_struct(pointer_from_objref(b))
    r = @cxx n_InitMPZ(bb, cf)
#    println("n_InitMPZ($b, $cf), bb: $bb --> $r");
    return n_Test(r, cf)
end

# void n_MPZ(mpz_t result, number &n,       const coeffs r)
function n_MPZ(a :: number_ref, cf :: coeffs)
    n_Test(a[], cf);
    b = BigInt();
    bb = pointer_from_objref(b);
    icxx""" n_MPZ((__mpz_struct *)$bb, $a, $cf); """
    return b
end

## static FORCE_INLINE void number2mpz(number n, coeffs c, mpz_t m){ n_MPZ(m, n, c); }
## static FORCE_INLINE number mpz2number(mpz_t m, coeffs c){ return n_InitMPZ(m, c); }
# long n_Int(number &n,       const coeffs r)

function n_Int(n :: number_ref, cf :: coeffs)
    n_Test(n[], cf);
    r = (icxx""" return n_Int($n, $cf); """)
    n_Test(n[], cf);
    return r
end

function _n_Test(n :: number, cf :: coeffs) 
   return (@cxx _n_Test(n, cf)) # NOTE: returns bool!
end

n_Test(n :: number, cf :: coeffs) = n_TestDebug(n, cf)

function BT()
	 return ## TODO: FIXME: useless as it is now! :(

         bt = backtrace();#      	 println( bt )
	 Base.show_backtrace(STDERR, bt); 

# io = IOBuffer();# seekstart(io); s = readall(io);# s = sprint(io->Base.show_backtrace(io, bt));# println( s ) 

	 i = 0 
	 for frame in bt
             i = i + 1
             li = Profile.lookup( UInt( frame ) )
 
             file  = li.file
             line  = li.line
             func  = li.func
             fromC = li.fromC # .ip?

	     println( "#", i, ": ", frame, " : ",  file, " : ", line, " : ",  func, " : ", fromC )
         end
end

function n_TestDebug(n :: number, cf :: coeffs) 
   if n != number(0)
      if !_n_Test(n, cf)
         BT()

#	 @cxx _break()
#         @assert (_n_Test(n, cf) == true)
#         throw(ErrorException("n_Test: Wrong Singular number"))
       end
   end
   return n
end

function n_Copy(n :: number, cf :: coeffs) 
   return n_Test((@cxx n_Copy(n_Test(n, cf), cf)), cf)
end

function n_Print(n :: number, cf :: coeffs) 
   @cxx n_Print(n_Test(n, cf), cf)
end

function n_Delete(n :: number_ref, cf :: coeffs)
  icxx""" number k = $n; n_Delete(&k, $cf); $n = k; """
end

function _n_Delete(n :: number, cf :: coeffs) 
#   println("_n_Delete($n / $cf): "  )
   (@cxx _n_Delete(n_Test(n, cf), cf))
#   println("_n_Delete().... done!"  )
#   return n
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
            ret = @cxx ($f)(n_Test(x, cf), n_Test(y, cf), cf)
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
            ret = @cxx ($f)(n_Test(x, cf), cf)
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
n_Size(x :: number, cf :: coeffs) = @cxx n_Size(n_Test(x, cf), cf)

# int n_ParDeg(number n, const coeffs r)
n_ParDeg(x :: number, cf :: coeffs) = @cxx n_ParDeg(n_Test(x, cf), cf)

# int n_NumberOfParameters(const coeffs r)
n_NumberOfParameters(cf :: coeffs) = (@cxx n_NumberOfParameters(cf))
 
# number n_Param(const int iParameter, const coeffs r)
n_Param(i::Int, cf :: coeffs) = n_Test((@cxx n_Param(i, cf)), cf)

# void n_Write(number& n,  const coeffs r, const BOOLEAN bShortOut = TRUE)
function n_Write( n::number_ref, cf :: coeffs, bShortOut::Bool = false )
   const d :: Int = (bShortOut? 1 : 0);

   n_Test(n[], cf);
   icxx""" n_Write($n, $cf, $d); """ 
   n_Test(n[], cf);
end


function n_Normalize(x :: number_ref, cf :: coeffs) 
    n_Test(x[], cf)
    icxx""" n_Normalize($x, $cf); """
    n_Test(x[], cf)
end


# number n_GetNumerator(number& n, const coeffs r)
function _n_GetNumerator(x :: number_ref, cf :: coeffs)
    n_Test(x[], cf)
    r = (icxx""" return n_GetNumerator($x, $cf); """)
    n_Test(x[], cf)
    return n_Test(r, cf)
end

# number n_GetDenom(number& n, const coeffs r)
function _n_GetDenom(x :: number_ref, cf :: coeffs)
    n_Test(x[], cf)
    r = (icxx""" return n_GetDenom($x, $cf); """)
    n_Test(x[], cf)
    return n_Test(r, cf)
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
            return n_Test((@cxx ($f)(n_Test(x,cf), cf)), cf)
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
	    n_Test(x,cf)
	    n_Test(y,cf)
	    r = (@cxx ($f)(x, y, cf));
##	    println("..", ($f), "..($x, $y, $cf) => $r")
            return n_Test(r, cf)
        end
    end
end

# Div(a,b) = QuotRem(a,b, &IntMod(a,b))
# static FORCE_INLINE number  n_QuotRem(number a, number b, number *q, const coeffs r)
# Div(a,b), IntMod(a,b)
function n_QuotRem(a::number, b::number, cf::coeffs)
    n_Test(a, cf);
    n_Test(b, cf);
    m = number_ref(number(0));
    q = number_ref(number(0));

    icxx""" number mm = $m; $q = n_QuotRem($a, $b, &mm, $cf); $m = mm; """

    n_Test(q[],cf), n_Test(m[],cf)
end


function n_Power(a::number, b::Int, cf::coeffs)
    # void   n_Power(number a, int b, number *res, const coeffs r)
    return n_Test((@cxx _n_Power(n_Test(a,cf), b, cf)), cf);
end

function n_ExtGcd(a::number, b::number, cf:: coeffs)
   n_Test(a, cf);
   n_Test(b, cf);

   s = number_ref( number(0) )
   t = number_ref( number(0) )

## number n_ExtGcd(number a, number b, number *s, number *t, const coeffs r)
   g = number_ref( number(0) )

   icxx""" number ss, tt; $g = n_ExtGcd($a, $b, &ss, &tt, $cf); $s = ss; $t = tt; """

######   g = @cxx n_ExtGcd(a, b, &s, &t, cf)

   @assert (g[] != number(0)) || (s[] != number(0)) || (t[] != number(0))

   n_Test(g[],cf), n_Test(s[],cf), n_Test(t[],cf)
end

## number n_XExtGcd(number a, number b, number *s, number *t, number *u, number *v, const coeffs r)
function n_XExtGcd(a::number, b::number, cf:: coeffs)
   n_Test(a, cf);
   n_Test(b, cf);

   g = number(0)
   s = number(0)
   t = number(0)
   u = number(0)
   v = number(0) # TODO: with REF!

###   g = @cxx n_XExtGcd(a, b, &s, &t, &u, &v, cf); # ??
   icxx""" number ss, tt, uu, vv; $g = n_XExtGcd($a, $b, &ss, &tt, &uu, &vv, $cf); $s = ss; $t = tt; $u = uu; $v = vv; """

#   g, s, t, u, v
   n_Test(g,cf), n_Test(s,cf), n_Test(t,cf), n_Test(u,cf), n_Test(v,cf)
end

## number n_QuotRem(number a, number b, number *q, const coeffs r)
function n_QuotRem(a::number, b::number, cf:: coeffs)
   n_Test(a, cf);
   n_Test(b, cf);

   q = number_ref( number(0) )
   r = number_ref( number(0) )

   icxx""" number qq; $r = n_QuotRem($a, $b, &qq, $cf); $q = qq; """

   @assert (q[] != number(0)) || (r[] != number(0))

#   r[], q[]
   n_Test(r[],cf), n_Test(q[],cf)   
end



# number n_ChineseRemainderSym(number *a, number *b, int rl, BOOLEAN sym,CFArray &inv_cache,const coeffs r)

## nMapFunc n_SetMap(const coeffs src, const coeffs dst)
n_SetMap(src :: coeffs, dst :: coeffs) = @cxx n_SetMap(src, dst)

###    static number nApplyMapFunc(nMapFunc f, number n, const coeffs src, const coeffs dst){ return f(n, src, dst); }
nApplyMapFunc(f :: nMapFunc, n :: number, src :: coeffs, dst :: coeffs)=n_Test((@cxx nApplyMapFunc(f, n_Test(n,src), src, dst)),dst)


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
   return n_Test((@cxx _n_Neg(n_Test(x,cf), cf)), cf)
end


#===========================================================================================#
# Singular Multivariate Polynomial Rings (with a unit) over Coeffs (Rings or Fields)
#===========================================================================================#

typealias rRingOrder_t Cxx.CppEnum{:rRingOrder_t} # vcpp"rRingOrder_t" ## ?

function ringorder_lp(); return(@cxx ringorder_lp); end
function ringorder_dp(); return(@cxx ringorder_dp); end

function ringorder_no(); return(@cxx ringorder_no); end # = 0 # the last block ord!

#  ringorder_no = 0,
#  ringorder_a,
#  ringorder_a64, ///< for int64 weights
#  ringorder_c,
#  ringorder_C,
#  ringorder_M,
#  ringorder_S, ///< S?
#  ringorder_s, ///< s?
#  ringorder_lp,
#  ringorder_dp,
#  ringorder_rp,
#  ringorder_Dp,
#  ringorder_wp,
#  ringorder_Wp,
#  ringorder_ls,
#  ringorder_ds,
#  ringorder_Ds,
#  ringorder_ws,
#  ringorder_Ws,
#  ringorder_am,
#  ringorder_L,
#  // the following are only used internally:
#  ringorder_aa, ///< for idElimination, like a, except pFDeg, pWeigths ignore it
#  ringorder_rs, ///< opposite of ls
#  ringorder_IS, ///< Induced (Schreyer) ordering


typealias ring Cxx.CppPtr{Cxx.CxxQualType{Cxx.CppBaseType{:ip_sring},(false,false,false)},(false,false,false)}
typealias ring_ref Ref{ring} ###   rcpp"ring" #  ??

typealias poly Cxx.CppPtr{Cxx.CxxQualType{Cxx.CppBaseType{:spolyrec},(false,false,false)},(false,false,false)}
###pcpp"poly" #Ptr{Void} ### TODO!!!
typealias poly_ref Ref{poly} ###   rcpp"poly" #  ??


function rGetCoeffs(r :: ring) 
   #   static coeffs rGetCoeffs(const ring r)
   return @cxx rGetCoeffs(r)
end

function rDelete(r :: ring)
   # void rDelete(ring r); // To be used instead of rKill!
   @cxx rDelete(r)
end

function rCopy(r :: ring)
   # ring   rCopy(ring r);
   return @cxx rCopy(r)
end

function rCopy0(r :: ring, copy_Qideal::Bool = true, copy_Ordering::Bool = true )
   bQ :: Int = (copy_Qideal? 1 : 0)
   bO :: Int = (copy_Ordering? 1 : 0)
   # rCopy0(const ring r, BOOLEAN copy_qideal = TRUE, BOOLEAN copy_ordering = TRUE);
   return @cxx rCopy0(r, bQ, bO)
end

function rWrite(r :: ring, details::Bool = false)
   d :: Int = (details? 1 : 0)
   # void   rWrite(ring r, BOOLEAN details = FALSE);
   @cxx rWrite(r, d)
end

function rDefault{T}(cf :: coeffs, vars::Array{T,1})
   # ring   rDefault(const coeffs cf, int N, char **n);
   return @cxx rDefault(cf, length(vars), Ptr{Ptr{Cuchar}}(pointer(vars)))
end

function rDefault{T}(cf :: coeffs, vars::Array{T,1}, ord::Array{rRingOrder_t, 1}, blk0::Array{Cint, 1}, blk1::Array{Cint, 1}, wvhdl::Ptr{Ptr{Cint}} = Ptr{Ptr{Cint}}(C_NULL))
   @assert length(ord) == length(blk0)
   @assert length(ord) == length(blk1)

   # last order block: all zeroes:
   @assert ord[length(ord)] == ringorder_no() 
   @assert blk0[length(ord)] == 0
   @assert blk1[length(ord)] == 0

   #ring   rDefault(const coeffs cf, int N, char **n,
   #####                  int ord_size, int *ord, int *block0, int *block1, int **wvhdl=NULL);

   return @cxx rDefault(cf, length(vars), Ptr{Ptr{Cuchar}}(pointer(vars)), length(ord), Ptr{Cint}(pointer(ord)), pointer(blk0), pointer(blk1), wvhdl)
end



#const char * rSimpleOrdStr(int ord);
#int rOrderName(char * ordername);
#char * rOrdStr(ring r);
#char * rVarStr(ring r);
#char * rCharStr(ring r);
#char * rString(ring r);
#int    rChar(ring r);
#char * rParStr(ring r);

function rSum(A :: ring, B :: ring)
    S = ring_ref(ring(C_NULL));    
    #   int    rSum(ring A, ring B, ring &sum);
    ret :: Cint = icxx""" return rSum($A,$B,$S); """
    @assert (ret == 1)
    return r_Test(S[])
end

# static inline char* rRingVar(short i, const ring r)
# static inline char const ** rParameter(const ring r) 

# static inline number n_Param(const short iParameter, const ring r)

#/// returns TRUE, if r1 equals r2 FALSE, otherwise Equality is
#/// determined componentwise, if qr == 1, then qrideal equality is
#/// tested, as well
#BOOLEAN rEqual(ring r1, ring r2, BOOLEAN qr = TRUE);

#/// returns TRUE, if r1 and r2 represents the monomials in the same way
#/// FALSE, otherwise
#/// this is an analogue to rEqual but not so strict
#BOOLEAN rSamePolyRep(ring r1, ring r2);

function  rGetVar(varIndex :: Cint, r :: ring)
   # // return the varIndex-th ring variable as a poly; varIndex starts at index 1
   # poly rGetVar(const int varIndex, const ring r)
   return @cxx rGetVar(varIndex, r)
end

function _r_Test(r :: ring)
   return (@cxx _r_Test(r)) # NOTE: returns bool!
end

r_Test(r :: ring) = r_TestDebug(r) # or just return p!

function r_TestDebug(r :: ring)
      if !_r_Test(r)
         BT()
#	 @cxx _break()
#         @assert (_p_Test(p, r) == true)
#         throw(ErrorException("r_Test: Wrong Singular ring"))
       end
   return r
end


function _p_Test(p :: poly, r :: ring)
   return (@cxx __p_Test(p, r)) # NOTE: returns bool!
end

p_Test(p :: poly, r :: ring) = p_TestDebug(p, r) # or just return p!

function p_TestDebug(p :: poly, r :: ring)
   if p != poly(0)
      if !_p_Test(p, r)
         BT()
#	 @cxx _break()
#         @assert (_p_Test(p, r) == true)
#         throw(ErrorException("p_Test: Wrong Singular poly"))
       end
   end
   return p
end


function _p_Delete(p :: poly, r :: ring)
   (@cxx _p_Delete(p_Test(p, r), r))
end

function p_Init(r :: ring)
   return @cxx p_Init(r)
end

function p_One(r :: ring)
   # poly p_One(const ring r)
   return @cxx p_One(r)
end

function p_ISet(i :: Int64, r :: ring)
   # poly p_ISet(long i, const ring r);
   return @cxx p_ISet(i, r)
end

function p_NSet(n :: number, r :: ring)
   # poly p_NSet(number n, const ring r); // returns the poly representing the number n, NOTE: destroys n
   return @cxx p_NSet(n, r)
end

# static inline poly p_Copy(poly p, const ring r)
function p_Copy(p :: poly, r :: ring)
   return @cxx p_Copy(p, r)
end

function pLength(p :: poly)
   # static inline int pLength(poly a)
   return @cxx pLength(p)
end

function p_Deg(p :: poly, r :: ring)
   # long p_Deg(poly a, const ring r)
   return @cxx p_Deg(p, r)
end

function p_Head(p :: poly, r :: ring)
    #static inline poly p_Head(poly p, const ring r)
   return @cxx p_Head(p, r)
end


function pGetCoeff!(p :: poly)
   #static inline number& pGetCoeff(poly p)
   return icxx""" return pGetCoeff($p); """ # NOTE: supposed to return a reference to the actual coeff!
end

function pSetCoeff!(p :: poly, n :: number) 
   ##define pSetCoeff0(p,n)     (p)->coef=(n) # NOTE: no cleanup!
   icxx""" return pSetCoeff0($p, $n); """
end

function pNext!(p :: poly)
   # #define pNext(p)            ((p)->next)
   return icxx""" return pNext($p); """ # NOTE: supposed to return the next to leading term!
end


function p_GetExp(p :: poly, v :: Int, r :: ring)
   #/// get v^th exponent for a monomial
   #static inline long p_GetExp(const poly p, const int v, const ring r)
   return @cxx p_GetExp(p, v, r)
end

function p_SetExp!(p :: poly, v :: Int, e :: Int64, r :: ring)
   # /// set v^th exponent for a monomial
   #static inline long p_SetExp(poly p, const int v, const long e, const ring r)
   return @cxx p_SetExp(p, v, e, r)
end

function pp_Mult_nn(p :: poly, n :: number, r :: ring)
   #// returns p*n, does not destroy p
   #static inline poly pp_Mult_nn(poly p, number n, const ring r)
   return @cxx pp_Mult_nn(p, n, r)
end

function p_Add_q(p :: poly, q :: poly, r :: ring)
   #// returns p+q, destroys p and q
   #static inline poly p_Add_q(poly p, poly q, const ring r)
   return @cxx p_Add_q(p, q, r)
end


function pp_Add_qq(p :: poly, q :: poly, r :: ring)
   return @cxx p_Add_q(p_Copy(p,r), p_Copy(q, r), r)
end

function p_Neg(p :: poly, r :: ring)
   # // returns -p, destroys p
   # static inline poly p_Neg(poly p, const ring r)   
   return (@cxx p_Neg(p, r))
end


function pp_Neg(p :: poly, r :: ring)
   return p_Neg(p_Copy(p, r), r)
end

function pp_Sub_qq(p :: poly, q :: poly, r :: ring)
   return (@cxx p_Add_q(p_Copy(p,r), pp_Neg(q, r), r))
end


function p_Mult_q(p :: poly, q :: poly, r :: ring)
   #// returns p*q, destroys p and q
   #static inline poly p_Mult_q(poly p, poly q, const ring r)
   return @cxx p_Mult_q(p, q, r)
end

function pp_Mult_qq(p :: poly, q :: poly, r :: ring)
   #// returns p*q, does neither destroy p nor q
   #static inline poly pp_Mult_qq(poly p, poly q, const ring r)
   return @cxx pp_Mult_qq(p, q, r)
end

function p_String(p :: poly, r :: ring)
   #static inline char*     p_String(poly p, ring p_ring)
   return @cxx p_String(p, r)
end

function p_Setm(p :: poly, r :: ring)
   #static inline void p_Setm(poly p, const ring r) 
   # NOTE: changes input term p!
   @cxx p_Setm(p, r)
   return p
end

function pp_Power(a::poly, b::Cint, r::ring)
    # returns the i-th power of p. NOTE: p will be destroyed
    # poly      p_Power(poly p, int i, const ring r);
    return (@cxx p_Power(p_Copy(a, r), b, r))
end

        function pp_IsOne(x :: poly, r :: ring)
	    ## static inline BOOLEAN p_IsOne(const poly p, const ring R)
            const ret = ( @cxx p_IsOne(x, r) );
            return (ret > 0)
        end

        function pp_IsConstant(x :: poly, r :: ring)
	    # static inline BOOLEAN p_IsConstant(const poly p, const ring r)
            const ret = ( @cxx p_IsConstant(x, r) );
            return (ret > 0)
        end


        function pp_IsMOne(x :: poly, r :: ring)
	    # (p_IsConstant(p, R) && n_IsMOne(p_GetCoeff(p, R), R->cf))
            return pp_IsConstant(x, r) && n_IsMOne(pGetCoeff!(x), rGetCoeffs(r))
        end


end # libSingular module