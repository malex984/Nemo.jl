module libSingular
export n_coeffType, number, coeffs, n_Test, p_Test, r_Test
using Cxx
function __libSingular_init__()
   const local prefix = joinpath(Pkg.dir("Nemo"), "local");
   addHeaderDir(joinpath(prefix, "include"), kind = C_System)
   addHeaderDir(joinpath(prefix, "include", "singular"), kind = C_System)
   cxxinclude(joinpath("Singular", "libsingular.h"), isAngled=false)
   cxxinclude(joinpath("omalloc", "omalloc.h"), isAngled=false)
   cxxinclude(joinpath("gmp.h"), isAngled=false)
   cxxinclude(joinpath("debugbreak.h"), isAngled=false)
   cxxinclude(joinpath("misc", "intvec.h"), isAngled=false);
   cxxinclude(joinpath("reporter", "reporter.h"), isAngled=false)
   cxxinclude(joinpath("coeffs", "coeffs.h"), isAngled=false); cxxinclude(joinpath("polys", "clapsing.h"), isAngled=false);
   cxxinclude(joinpath("polys", "monomials", "ring.h"), isAngled=false)
   cxxinclude(joinpath("polys", "monomials", "p_polys.h"), isAngled=false)
   cxxinclude(joinpath("polys", "simpleideals.h"), isAngled=false)
   cxxinclude(joinpath("kernel", "GBEngine", "kstd1.h"), isAngled=false)
   cxxinclude(joinpath("kernel", "ideals.h"), isAngled=false)



## NOTE: make sure the line number is correct in case of any changes above here!!!!
cxx"""#line 25 "libSingular.jl"
    #include "Singular/libsingular.h"
    #include "omalloc/omalloc.h"
    #include "gmp.h"
    #include "misc/intvec.h"
    #include "reporter/reporter.h"
    #include "coeffs/coeffs.h"

    #include "polys/monomials/ring.h"
    #include "polys/monomials/p_polys.h"
    #include "polys/clapsing.h"
    #include "polys/simpleideals.h"

    #include "kernel/GBEngine/kstd1.h"
    #include "kernel/ideals.h"

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

    static coeffs rGetCoeffs(const ring r)
    { return r->cf; }

    static int pp_IsVar(const poly p, const ring r)
    { 
      if (pNext(p) != NULL) 
        return -1;

      if( !n_IsOne(p_GetCoeff(p, r), r->cf) )
        return -1;
      
      int ret = -1;

      for(int i = r->N; i > 0; i--)
      {
        const int e = p_GetExp(p,i,r);
	assume( e >= 0 );

        if(e == 0) 
           continue;

	if(e > 1) 
          return -1;

//	assume( e == 1 );
	if (ret > 0) 
          return -1;

	ret = i;
      }
      return ret;
    }

    static void _break(){ assume(false); assert(false); debug_break(); }


   ideal _kStd(ideal I, const ring R)
   {
     ideal id = NULL;

     assume(I != NULL);

     if(!idIs0(I)) 
     {
       const ring origin = currRing; 
       intvec* nullVector = NULL; 
       tHomog h = testHomog; 

       if (origin != R)
       	  rChangeCurrRing(R);

       id = kStd(I, R->qideal, h, &nullVector);
       
       if (origin != currRing && origin != NULL)
       	  rChangeCurrRing(origin);

       if(nullVector != NULL) 
          delete nullVector;

     } else id = idInit(0, I->rank);

     return (id); 
   }

   ideal _id_Syzygies(ideal I, const ring R)
   {
     ideal id = NULL;

     assume(I != NULL);

       const tHomog h=testHomog; 
       const ring origin = currRing; 
       intvec* nullVector = NULL; 

       if (origin != R)
       	  rChangeCurrRing(R);

       // compute the syzygies of h1 in R/quot,
       // weights of components are in w
       // if setRegularity, return the regularity in deg
       // do not change h1,  w 
       // ideal   idSyzygies (ideal h1, tHomog h,intvec **w, BOOLEAN setSyzComp=TRUE, BOOLEAN setRegularity=FALSE, int *deg = NULL);

       id = idSyzygies(I, h, &nullVector); 
       
       if (origin != currRing && origin != NULL)
       	  rChangeCurrRing(origin);

       if(nullVector != NULL) 
          delete nullVector;

       return (id); 
   }

"""

   local const binSingular = joinpath(prefix, "bin", "Singular")
   ENV["SINGULAR_EXECUTABLE"] = binSingular

   # Initialize Singular!
   siInit(binSingular) 

   # unique coeffs:

   # Ring:
   global ptr_ZZ = (@cxx coeffs_BIGINT) ## nInitChar(n_Z(), Ptr{Void}(0))  ### (@cxx coeffs_BIGINT) # NOTE: wrong n_IsUnit!??
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

   global const dictOrdSymbols = Dict{Symbol, libSingular.rRingOrder_t}(
   	  :lex => ringorder_lp(), :revlex => ringorder_rp(), 
   	  :neglex => ringorder_ls(), :negrevlex => ringorder_rs(), 
	  :degrevlex => ringorder_dp(), :deglex => ringorder_Dp(),
	  :negdegrevlex => ringorder_ds(), :negdeglex => ringorder_Ds(),
	  :comp1max => ringorder_c(), :comp1min => ringorder_C() );
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
## static FORCE_INLINE BOOLEAN n_IsUnit(number n, const coeffs r)

for (f) in ((:n_IsOne), (:n_IsMOne), (:n_IsZero), (:n_GreaterZero), (:n_IsUnit))
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

#### http://www.singular.uni-kl.de/Manual/latest/sing_31.htm#SEC43

function ringorder_no(); return(@cxx ringorder_no); end # = 0 # the last block ord!

function ringorder_lp(); return(@cxx ringorder_lp); end # lexicographical ordering
function ringorder_rp(); return(@cxx ringorder_rp); end # reverse lexicographical ordering
function ringorder_dp(); return(@cxx ringorder_dp); end # degree reverse lexicographical ordering
function ringorder_Dp(); return(@cxx ringorder_Dp); end # degree lexicographical ordering

function ringorder_ls(); return(@cxx ringorder_ls); end # negative lexicographical ordering
function ringorder_rs(); return(@cxx ringorder_rs); end # negative reverse lexicographical ordering
function ringorder_ds(); return(@cxx ringorder_ds); end # negative degree reverse lexicographical ordering
function ringorder_Ds(); return(@cxx ringorder_Ds); end # negative degree lexicographical ordering

function ringorder_c(); return(@cxx ringorder_c); end # gen(1) = max gen(i)
function ringorder_C(); return(@cxx ringorder_C); end # gen(1) = min gen(i)

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

## NOTE & TODO?: ideal is easy to wrapp a-la Nemo (or GMP) structs!
typealias ideal Cxx.CppPtr{Cxx.CxxQualType{Cxx.CppBaseType{:sip_sideal},(false,false,false)},(false,false,false)}

function rGetCoeffs(r :: ring) 
   #   static coeffs rGetCoeffs(const ring r)
   return (@cxx rGetCoeffs( r_Test(r) ))
end

function rDelete(r :: ring)
   # void rDelete(ring r); // To be used instead of rKill!
   @cxx rDelete( r_Test(r) )
end

function rCopy(r :: ring)
   # ring   rCopy(ring r);
   return r_Test( @cxx rCopy( r_Test(r) ) )
end

function rCopy0(r :: ring, copy_Qideal::Bool = true, copy_Ordering::Bool = true )
   bQ :: Int = (copy_Qideal? 1 : 0)
   bO :: Int = (copy_Ordering? 1 : 0)
   # rCopy0(const ring r, BOOLEAN copy_qideal = TRUE, BOOLEAN copy_ordering = TRUE);
   return r_Test( (@cxx rCopy0( r_Test(r), bQ, bO)) )
end

function rWrite(r :: ring, details::Bool = false)
   d :: Int = (details? 1 : 0)
   # void   rWrite(ring r, BOOLEAN details = FALSE);
   @cxx rWrite( r_Test(r), d)
end

function rDefault{T}(cf :: coeffs, vars::Array{T,1})
   # ring   rDefault(const coeffs cf, int N, char **n);
   return r_Test( ( @cxx rDefault(cf, length(vars), Ptr{Ptr{Cuchar}}(pointer(vars))) ) )
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

   return r_Test( (@cxx rDefault(cf, length(vars), Ptr{Ptr{Cuchar}}(pointer(vars)), length(ord), Ptr{Cint}(pointer(ord)), pointer(blk0), pointer(blk1), wvhdl) ) )
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
    r_Test(A)
    r_Test(B)
    println(A)
    println(B)
    const ret = icxx""" return rSum($A,$B,$S); """
    @assert (ret == 1)
    println(S)
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
   return p_Test( (@cxx rGetVar(varIndex, r)), r)
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

function rRing_has_Comp(r :: ring)
   ## #define rRing_has_Comp(r)   (r->pCompIndex >= 0)
   const ret = icxx""" return rRing_has_Comp($r); """
   return Bool(ret)
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
   return p_Test( (@cxx p_One(r)), r)
end

function p_ISet(i :: Int64, r :: ring)
   # poly p_ISet(long i, const ring r);
   return p_Test( (@cxx p_ISet(i, r)), r)
end

function p_NSet(n :: number, r :: ring)
   # poly p_NSet(number n, const ring r); // returns the poly representing the number n, NOTE: destroys n
   return p_Test( (@cxx p_NSet(n, r)), r)
end

# static inline poly p_Copy(poly p, const ring r)
function p_Copy(p :: poly, r :: ring)
   return p_Test( (@cxx p_Copy(p_Test(p,r), r)), r)
end

function pLength(p :: poly)
   # static inline int pLength(poly a)
   return @cxx pLength(p)
end

function p_Deg(p :: poly, r :: ring)
   # long p_Deg(poly a, const ring r)
   return (@cxx p_Deg(p_Test(p,r), r))
end

function pp_Head(p :: poly, r :: ring)
    #static inline poly p_Head(poly p, const ring r)
   return p_Test( (@cxx p_Head( p_Test(p,r), r)), r)
end

function pGetCoeff!(p :: poly)
   #static inline number& pGetCoeff(poly p)
   return icxx""" return pGetCoeff($p); """ # NOTE: supposed to return a reference to the actual coeff!
end

function pGetCoeff(p :: poly)
   return icxx""" number n = pGetCoeff($p); return n; """
end


function pSetCoeff!(p :: poly, n :: number) 
   ##define pSetCoeff0(p,n)     (p)->coef=(n) # NOTE: no cleanup!
   icxx""" pSetCoeff0($p, $n); """
end

function pNext(p :: poly)
   # #define pNext(p)            ((p)->next)
   return icxx""" return (poly)pNext($p); """ # NOTE: supposed to return the next to leading term!
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


function p_SetCompP!(p :: poly, c :: Cint, r :: ring)
   ## // sets component of poly p to i
   ## static inline   void p_SetCompP(poly p, int i, ring r)
   @cxx p_SetCompP(p_Test(p, r), c, r);
   @assert p == p_Test(p, r)
end

function p_SetComp!(p :: poly, c :: Culong, r :: ring)
   #static inline  unsigned long p_SetComp(poly p, unsigned long c, ring r)
   return (@cxx p_SetComp(p, c, r)); # returns c!
end

function p_Mult_nn(p :: poly, n :: number, r :: ring)
   #// returns p*n, destroys p
   #static inline poly p_Mult_nn(poly p, number n, const ring r)
   return p_Test((@cxx p_Mult_nn(p, n, r)), r)
end

function pp_Mult_nn(p :: poly, n :: number, r :: ring)
   #// returns p*n, does not destroy p
   #static inline poly pp_Mult_nn(poly p, number n, const ring r)
   return p_Test((@cxx pp_Mult_nn(p, n, r)), r)
end

function p_Add_q(p :: poly, q :: poly, r :: ring)
   #// returns p+q, destroys p and q
   #static inline poly p_Add_q(poly p, poly q, const ring r)
   return p_Test((@cxx p_Add_q(p, q, r)), r)
end


function pp_Add_qq(p :: poly, q :: poly, r :: ring)
   return (@cxx p_Add_q(p_Copy(p,r), p_Copy(q, r), r))
end

function p_Neg(p :: poly, r :: ring)
   # // returns -p, destroys p
   # static inline poly p_Neg(poly p, const ring r)   
   return p_Test( (@cxx p_Neg(p, r)), r)
end


function pp_Neg(p :: poly, r :: ring)
   return p_Neg(p_Copy(p, r), r)
end

function pp_Sub_qq(p :: poly, q :: poly, r :: ring)
   return p_Test( (@cxx p_Add_q(p_Copy(p,r), pp_Neg(q, r), r)), r)
end


function p_Mult_q(p :: poly, q :: poly, r :: ring)
   #// returns p*q, destroys p and q
   #static inline poly p_Mult_q(poly p, poly q, const ring r)
   return p_Test( (@cxx p_Mult_q( p_Test(p,r), p_Test(q,r), r)), r)
end

function pp_Mult_qq(p :: poly, q :: poly, r :: ring)
   #// returns p*q, does neither destroy p nor q
   #static inline poly pp_Mult_qq(poly p, poly q, const ring r)
   return p_Test( (@cxx pp_Mult_qq( p_Test(p,r), p_Test(q,r), r)), r)
end

function p_String(p :: poly, r :: ring)
   #static inline char*     p_String(poly p, ring p_ring)
   return (@cxx p_String(p_Test(p,r), r))
end

function p_Setm!(p :: poly, r :: ring)
   #static inline void p_Setm(poly p, const ring r) 
   # NOTE: changes input term p!
   @cxx p_Setm(p, r)
   return p_Test(p, r)
end

function p_SetmComp!(p :: poly, r :: ring)
   # == p_Setm?
   # NOTE: changes input term p!
   icxx""" p_SetmComp($p, $r); """
   return p_Test(p, r)
end

function p_Power(a::poly, b::Cint, r::ring)
    # returns the i-th power of p. NOTE: p will be destroyed
    # poly      p_Power(poly p, int i, const ring r);
    return p_Test((@cxx p_Power(p_Test(a,r), b, r)),r)
end

function pp_Power(a::poly, b::Cint, r::ring)
    return p_Power(p_Copy(a, r), b, r)
end

        function pp_IsOne(x :: poly, r :: ring)
	    ## static inline BOOLEAN p_IsOne(const poly p, const ring R)
            const ret = ( @cxx p_IsOne(p_Test(x,r), r) );
            return (ret > 0)
        end


        function pp_IsUnit(x :: poly, r :: ring) # LT is an invertible constant?
	    # static inline BOOLEAN p_IsUnit(const poly p, const ring r)
            const ret = ( @cxx p_IsUnit(p_Test(x,r), r) );
            return (ret > 0)
        end


        function pp_IsConstant(x :: poly, r :: ring)
	    # static inline BOOLEAN p_IsConstant(const poly p, const ring r)
            const ret = ( @cxx p_IsConstant(p_Test(x,r), r) );
            return (ret > 0)
        end

        function pp_IsVar(x :: poly, r :: ring)
	    #    static int pp_IsVar(const poly p, const ring r)
            const ret = ( @cxx pp_IsVar(p_Test(x,r), r) ); # either ret = -1 or x == var(ret)!
            return (ret != -1)
        end


        function pp_IsMOne(x :: poly, r :: ring)
	    # (p_IsConstant(p, R) && n_IsMOne(p_GetCoeff(p, R), R->cf))
            return pp_IsConstant(p_Test(x,r), r) && n_IsMOne(pGetCoeff(x), rGetCoeffs(r))
        end


        function pp_EqualPolys(p1 :: poly, p2 :: poly, r :: ring)
	    # BOOLEAN p_EqualPolys(poly p1, poly p2, const ring r);
            const ret = ( @cxx p_EqualPolys( p_Test(p1,r), p_Test(p2, r), r) );
            return (ret > 0)
        end



function singclap_gcd(p :: poly_ref, q :: poly_ref, r :: ring)
   p_Test(p[], r)
   p_Test(q[], r)
   # returns gcd(p, q), destroys p and q
   # poly singclap_gcd ( poly f, poly g, const ring r );
   return p_Test( (icxx""" return (poly)singclap_gcd($p, $q, $r); """), r)
end


### NOTE: the following only works over several Factory-supported fields!!
function singclap_pdivide(p :: poly, q :: poly, r :: ring) ## p / q, no destruction!
   # poly singclap_pdivide ( poly f, poly g, const ring r );
   return p_Test((@cxx singclap_pdivide(p_Test(p,r), p_Test(q,r), r)),r)
end

function singclap_extgcd(f :: poly, g :: poly, r :: ring)
   p_Test(f , r);
   p_Test(g , r);
   res = poly_ref(poly(C_NULL)); a = poly_ref(poly(C_NULL)); b = poly_ref(poly(C_NULL));

   # BOOLEAN singclap_extgcd ( poly f, poly g, poly &res, poly &pa, poly &pb , const ring r);
   const ret = icxx""" return singclap_extgcd($f, $g, $res, $a, $b, $r); """
   @assert (ret == 0)
   
   return p_Test(res[],r), p_Test(a[],r), p_Test(b[],r)
end


function pp_Diff(a :: poly, k :: Cint, r :: ring)
    
    ## returns the partial differentiate of a by the k-th variable, does not destroy the input
    #  poly p_Diff(poly a, int k, const ring r)
    return p_Test((@cxx p_Diff(p_Test(a, r), k, r)), r)
end


function p_Content(x :: poly_ref, r :: ring)
    p_Test(x[], cf)
    ## void p_Content(poly ph, const ring r), changes the input polynomial!
    icxx"""poly x = $x; p_Content(x, $r); """
    p_Test(x[], cf)
end

function p_Normalize(x :: poly_ref, cf :: ring)
    p_Test(x[], cf)
    #void p_Normalize(poly p,const ring r)
    icxx""" p_Normalize($x, $cf); """
    p_Test(x[], cf)
end



# void singclap_divide_content ( poly f, const ring r);
# poly singclap_resultant ( poly f, poly g , poly x, const ring r);


function p_MaxComp( a :: poly, r :: ring)
   # // returns maximal column number in the modul element a (or 0)
   # static inline long p_MaxComp(poly a, ring r[, ring tailRing])
   return (@cxx p_MaxComp(p_Test(a, r), r));
end


function ncols(I::ideal) 
  @assert I != ideal(C_NULL)
  return icxx""" return (int)IDELEMS($I); """ # # MATCOLS
end

function getrank(I::ideal)
  @assert I != ideal(C_NULL)
  return icxx""" return (long)($I)->rank; """
end

function setrank!(I::ideal, r :: Clong)
  @assert I != ideal(C_NULL)
  icxx""" ($I)->rank = r; """
end


## length(I::ideal) = ncols(I)

function nrows(I::ideal) 
  @assert I != ideal(C_NULL)
  return icxx""" return (int)MATROWS($I); """
end

function id_Print(I::ideal, R::ring)
   @assert I != ideal(C_NULL)
   icxx""" id_Print($I, $R, $R); """
end

function getindex(I::ideal, i::Cint, j::Cint) 
  @assert I != ideal(C_NULL)
  return icxx""" return (poly)MATELEM($I,$i,$j); """
end

function getindex(I::ideal, j::Cint) 
  @assert I != ideal(C_NULL)
  return icxx""" return (poly)($I->m[$j]); """
end

function setindex!(I::ideal, x::poly, j::Cint) 
  @assert I != ideal(C_NULL)
  icxx""" $I->m[$j] = $x; """
end

function setindex!(I::ideal, x::poly, i::Cint, j::Cint) 
  @assert I != ideal(C_NULL)
  icxx""" MATELEM($I,$i,$j) = $x; """
end

function _id_Test(I :: ideal, R :: ring) 
   ##    static void _id_Test(ideal I, const ring R) { id_Test(I, R); }
   icxx""" id_Test($I, $R); """
end

function id_Test(I :: ideal, R :: ring)
   @assert I != ideal(C_NULL)
   _id_Test(I, R);
   return (I);
end

function _id_Delete(I :: ideal, R :: ring)
  @assert I != ideal(C_NULL)
#   if I != ideal(C_NULL)
     I = id_Test(I, R);
     ###    id_Delete(&a, r);
     icxx""" ideal I = $I; id_Delete(&I, $R); """
#   end
end

function id_Copy(I :: ideal, R :: ring)
  @assert I != ideal(C_NULL)
   ## ideal id_Copy (ideal h1,const ring r);
   return (@cxx id_Copy(I, R));
end


function idInit(size::Cint, rank::Cint = 1)
   ## ideal idInit (int size, int rank=1); /// creates an ideal / module
   return (@cxx idInit(size, rank));
end

function idIs0(I :: ideal)
   @assert I != ideal(C_NULL)
   ## BOOLEAN idIs0 (ideal h);
   const ret = ( @cxx idIs0(I) );
   return (ret > 0)
end

function id_RankFreeModule(I :: ideal, R :: ring)
   @assert I != ideal(C_NULL)
   ## static inline long id_RankFreeModule(ideal m, ring r)
   return @cxx id_RankFreeModule(id_Test(I, R), R)
end

function idElem(I :: ideal)
   @assert I != ideal(C_NULL)
   ## int     idElem(const ideal F); /// number of non-zero polys in F
   return (@cxx idElem(I));
end

function id_Normalize(I :: ideal, R :: ring)
   @assert I != ideal(C_NULL)
   ## void    id_Normalize(ideal id, const ring r); /// normialize all polys in id
   @cxx id_Normalize(id_Test(I, R), R)
   I = id_Test(I, R); # Just self test
end

function idSkipZeroes(I :: ideal)
   @assert I != ideal(C_NULL)
   ## void idSkipZeroes (ideal ide); /// gives an ideal the minimal possible size
   @cxx idSkipZeroes(I);
end



function id_FreeModule(k:: Cint, R :: ring)
   @assert I != ideal(C_NULL)
   ## ideal id_FreeModule (int i, const ring r);
   return id_Test( (@cxx id_FreeModule(k, R)), R ); 
end

function id_MaxIdeal(k:: Cint, R :: ring)
   ## ideal id_MaxIdeal(int deg, const ring r);
   return id_Test( (@cxx id_MaxIdeal(k, R)), R );
end

function id_Transp(I :: ideal, R :: ring)
   @assert I != ideal(C_NULL)
   ## ideal id_Transp(ideal a, const ring rRing); /// transpose a module
   return id_Test( (@cxx id_Transp(id_Test(I, R), R)), R);
end

function id_SimpleAdd(I :: ideal, J :: ideal, R :: ring)
   @assert I != ideal(C_NULL)
   @assert J != ideal(C_NULL)
   ## ideal id_SimpleAdd (ideal h1,ideal h2, const ring r);   /*adds two ideals without simplifying the result*/
   return id_Test( (@cxx id_SimpleAdd(id_Test(I,R), id_Test(J,R), R)), R );
end

function id_Add(I :: ideal, J :: ideal, R :: ring)
   @assert I != ideal(C_NULL)
   @assert J != ideal(C_NULL)
   ## ideal id_Add (ideal h1,ideal h2,const ring r);   /*adds the quotient ideal*/  /* h1 + h2 */
   return id_Test( (@cxx id_Add(id_Test(I,R), id_Test(J,R), R)), R );
end

function id_Mult(I :: ideal, J :: ideal, R :: ring)
   @assert I != ideal(C_NULL)
   @assert J != ideal(C_NULL)
   ## ideal id_Mult (ideal h1,ideal  h2, const ring r);
   return id_Test( (@cxx id_Mult(id_Test(I,R), id_Test(J,R), R)), R );
end


function id_Power(I :: ideal, e :: Cint, R :: ring)
   @assert I != ideal(C_NULL)
   ## ideal id_Power(ideal given,int exp, const ring r);
   return id_Test( (@cxx id_Power(id_Test(I,R), e, R)), R );
end


function kStd(I :: ideal, R :: ring)
   @assert I != ideal(C_NULL)
   return id_Test((@cxx _kStd( id_Test(I,R), R)), R);
end

function _id_Syzygies(I :: ideal, R :: ring)
   @assert I != ideal(C_NULL)
   return id_Test((@cxx _id_Syzygies( id_Test(I,R), R)), R);
end

function id_Head(I :: ideal, R :: ring)
   @assert I != ideal(C_NULL)
   # /// returns the ideals of initial terms
   # ideal id_Head(ideal h,const ring r)

   return id_Test((@cxx id_Head(id_Test(I,R), R)), R);
end


## BOOLEAN idTestHomModule(ideal m, ideal Q, intvec *w);
## id_HomModule, id_IsZeroDim
# ideal idMinBase (ideal h1);
# ideal   idModulo (ideal h1,ideal h2, tHomog h=testHomog, intvec ** w=NULL);
# matrix  idDiff(matrix i, int k);
# matrix  idDiffOp(ideal I, ideal J,BOOLEAN multiply=TRUE);


# ideal   idSect (ideal h1,ideal h2);
# ideal   idMultSect(resolvente arg, int length);

## ideal   idSyzygies (ideal h1, tHomog h,intvec **w, BOOLEAN setSyzComp=TRUE, BOOLEAN setRegularity=FALSE, int *deg = NULL);
## ideal   idLiftStd  (ideal h1, matrix *m, tHomog h=testHomog, ideal *syz=NULL);

# ideal   idElimination (ideal h1, poly delVar, intvec *hilb=NULL);
# ideal   idQuot (ideal h1,ideal h2, BOOLEAN h1IsStb=FALSE, BOOLEAN resultIsIdeal=FALSE);
# ideal   idLift (ideal mod, ideal sumod,ideal * rest=NULL, BOOLEAN goodShape=FALSE, BOOLEAN isSB=TRUE,BOOLEAN divide=FALSE, matrix *unit=NULL);
# void idLiftW(ideal P,ideal Q,int n,matrix &T, ideal &R, short *w= NULL );
# intvec * idMWLift(ideal mod,intvec * weights);
# ideal   idMinors(matrix a, int ar, ideal R = NULL);
# ideal idMinEmbedding(ideal arg,BOOLEAN inPlace=FALSE, intvec **w=NULL);
# BOOLEAN idIsSubModule(ideal id1,ideal id2);
# ideal   idSeries(int n,ideal M,matrix U=NULL,intvec *w=NULL);

# poly id_GCD(poly f, poly g, const ring r);
# ideal id_Farey(ideal x, number N, const ring r);


## ideal kMin_std(ideal F, ideal Q, tHomog h,intvec ** w, ideal &M, intvec *hilb=NULL, int syzComp=0,int reduced=0);
## ideal stdred(ideal F, ideal Q, tHomog h,intvec ** w);


## ideal kNF(ideal F, ideal Q, ideal p,int syzComp=0, int lazyReduce=0);
## poly k_NF (ideal F, ideal Q, poly p,int syzComp, int lazyReduce, const ring _currRing);


end # libSingular module