module SingularKernel

import Base: Array, call, checkbounds, convert, cmp, contains, deepcopy,
             den, div, divrem, gcd, gcdx, getindex, hash, inv, invmod, isequal, 
             isless, lcm, length, mod, ndigits, num, one, parent, print,
             promote_rule, Rational, rem, setindex!, show, sign, size, string,  zero,
             +, -, *, ==, ^, &, |, $, <<, >>, ~, <=, >=, <, >, //, /, !=

import Nemo: Ring, RingElem, divexact, characteristic, degree, gen, transpose ## , deepcopy #
##using Nemo: Ring, RingElem, divexact, characteristic, degree, gen, transpose ## , deepcopy #
import Nemo: PRingElem, PRing, PModuleElem, SingularIdeal, SingularModule, Singular_ZZElem, get_raw_ptr
using Nemo
## using Nemo: PRingElem, PRing, PModuleElem, SingularIdeal, SingularModule, Singular_ZZElem, get_raw_ptr

using ..libSingular

using Cxx

function __init_singular_interpreter__()
#   cV = (@cxx currentVoice); # PVoice?
   const i = (icxx""" return (feInitStdin(NULL)); """);

#   println(typeof(i));
#   println(i);

   icxx""" setPtr(currentVoice, $i); """

#   cV = (@cxx currentVoice); # PVoice?
#   @show cV

   ## Cxx.CppFptr{Cxx.CppFunc{Void,Tuple{Ptr{UInt8}}}}
   global const WerrorS_callback = (@cxx WerrorS_callback);
#   @show  WerrorS_callback

   if (WerrorS_callback == typeof(WerrorS_callback)(C_NULL))
      const _nemoWerrorS = cfunction(nemoWerrorS, Void, (Ptr{Cuchar},));
      icxx""" setPtr(WerrorS_callback, $_nemoWerrorS); """
   end


   nPos = Cint(0);
   while true

      const p = getArith1( nPos );

      (p == C_NULL) && break;

      const cmd  = Cint(@cxx p -> cmd);

      (cmd == Cint(0)) && break;

      const pp   = Cint(@cxx p -> p);

      const res  = Cint(@cxx p -> res);
      const arg  = Cint(@cxx p -> arg);
      const opt  = Cint(@cxx p -> valid_for);

      const scmd = __iiTwoOps(cmd);
      const sarg = __Tok2Cmdname(arg);
      const sres = __Tok2Cmdname(res);

      if ( (pp != Cint(2))||(scmd == "\$INVALID\$")||(sarg == "\$INVALID\$")||(sres == "\$INVALID\$") )
          nPos = nPos + Cint(1);
          continue;
      end 

      if ( (scmd == sarg) && (scmd == sres) )
          nPos = nPos + Cint(1);
          continue;
      end 

      println();
      println("\#$nPos: { ($cmd) '", scmd, 
             "', arg: ($arg) '", sarg, 
	     "', res: ($res) '", sres, 
	     "' }, valid_for: ", bin(opt, 5) );
    
# TODO: CHANGE CURRENT RING???! 
     const sarg = LEFTV(arg);

     try  ##      SingularKernel.
      eval(:(
         function $(symbol(scmd))( ___arg :: $(sarg) ) # Julia types  <-1:1-> Singular Interpreter Types
	      const __arg = ToLeftv( ___arg ); ## Leftv{}
	      const _arg = get_raw_ptr(__arg); ## leftv

	      const R = get_raw_context(__arg);
	      const orig_ring = rChangeCurrRing(R);

#	      ($arg != ANY_TYPE()) && @assert Cint(@cxx _arg -> Typ()) == $arg

	      d = Ref{Ptr{Void}}(C_NULL); t = Ref{Cint}(Cint(0)); e = Ref{Cint}(Cint(0));
	      
	      const cmd = $(cmd);

#	      @assert (@cxx errorreported) == 0
	      icxx""" sleftv r;r.Init(); $e = ((int)iiExprArith1(&r,$_arg,$cmd)); $d=r.data;$t=r.rtyp; """ ;

	      const f = string($(scmd)) * "( " * string($(sarg)) * " )";

	      println("Singular interpreter kenel procedure '$f' returns: ", e[], ", errorreported: ", (@cxx errorreported));

	      if (e[] > 0)
                  icxx""" errorreported = 0; /* reset error handling */ """ ;
		  error("Error during Singular Kernel Call via Interpreter: '$f'");
	      end

	      if ($res == NONE()) 
                  rChangeCurrRing(orig_ring);
                  return Void() ### TODO: should not be run-time check! 
              end

#	      ($res != ANY_TYPE()) && @assert $t == $res;

	      ret = FromLeftv( t[], d[], currRing() );
              rChangeCurrRing(orig_ring);
	      return ret;
           end; 
         ) );

     catch
     end

      nPos = nPos + Cint(1);
   end
end

function MAX_TOK()
    return Cint( icxx""" return (int)(MAX_TOK); """ );
end

function NONE()
    return Cint( icxx""" return (int)(NONE); """ );
end

function ANY_TYPE()
    return Cint( icxx""" return (int)(ANY_TYPE); """ );
end

#function IDHDL()
#    return Cint( icxx""" return (int)(IDHDL); """ );
#end

function INT_CMD()
   return Cint( @cxx INT_CMD ); 
end

function STRING_CMD()
   return Cint( @cxx STRING_CMD ); 
end

function getArith2( i :: Cint ) 
    return (icxx""" return getArith2($i); """);
end
function getArith1( i :: Cint ) 
    # // static inline sValCmd1* getArith1( int i )
    return (icxx""" return getArith1($i); """);
end
function getArith3( i :: Cint ) 
    return (icxx""" return getArith3($i); """);
end
function getArithM( i :: Cint ) 
    return (icxx""" return getArithM($i); """);
end


function nemoWerrorS(msg :: Ptr{Cuchar})
     # // void WerrorS_dummy(const char *)
     println("J: ERROR on the SINGULAR side: ", msg);

     BT();
     return Void()
end


# // const char *Tok2Cmdname( int tok);
Tok2Cmdname( tok::Cint ) = bytestring( @cxx Tok2Cmdname(tok) ) 

# // const char *  iiTwoOps(int t);
iiTwoOps( tok::Cint ) = bytestring( @cxx iiTwoOps(tok) ) 

# tokval -> toktype
iiTokType( op :: Cint ) = Cint( @cxx iiTokType(op) )


__Tok2Cmdname( tok::Cint ) = bytestring( @cxx __Tok2Cmdname(tok) ) 
__iiTwoOps( tok::Cint ) = bytestring( @cxx __iiTwoOps(tok) ) 


# // int iiArithFindCmd(const char *szName)
iiArithFindCmd( szName :: Ptr{Cuchar} ) = Cint( @cxx iiArithFindCmd(szName) ) 

# // char *iiArithGetCmd( int nPos )
iiArithGetCmd( nPos :: Cint ) = @cxx iiArithGetCmd(nPos) 

function IsCmd(n)
    const p = pointer(n);
    tok = Ref{Cint}(0);

# // int IsCmd(const char *n, int & tok)      
    ret = Cint( icxx""" return IsCmd($p, $tok); """ );

    return ret, tok[]
end  

function Toktype( tt :: Cint )

    (tt == (@cxx CMD_1)) && return "CMD_1";
    (tt == (@cxx CMD_2)) && return "CMD_2";
    (tt == (@cxx CMD_3)) && return "CMD_3";
    (tt == (@cxx CMD_12)) && return "CMD_12";
    (tt == (@cxx CMD_123)) && return "CMD_123";
    (tt == (@cxx CMD_23)) && return "CMD_23";
    (tt == (@cxx CMD_M)) && return "CMD_M";
    (tt == (@cxx SYSVAR)) && return "SYSVAR";
    (tt == (@cxx ROOT_DECL)) && return "ROOT_DECL";
    (tt == (@cxx ROOT_DECL_LIST)) && return "ROOT_DECL_LIST";
    (tt == (@cxx RING_DECL)) && return "RING_DECL";
    (tt == NONE()) && return "NONE";

    if (tt > Cint(' ')) && (tt < Cint(127))
       return "[" * string(Char(Int(tt))) * "]";
    end

   return "'" * iiTwoOps(tt) * "'";
end 




########################################################################################

type Leftv{id}
  ptr :: leftv
  ctx :: ring # necessary for unboxing Singular -> Julia (like parent/context for Singular low level data)

  function Leftv(p::leftv, R::ring)
#     (Cint(id) != ANY_TYPE()) && @assert Cint(id) == Cint(@cxx p -> rtyp)
     z = new(p, R); finalizer(z, _Leftv_clear_fn); return z;
  end

end  

function get_raw_ptr{id}(l::Leftv{id}) # Singular's leftv
   const p = l.ptr;
#   (Cint(id) != ANY_TYPE()) && @assert Cint(id) == Cint(@cxx p -> rtyp)
   return p
end

function get_raw_context{id}(l::Leftv{id})  # Ring Context Parent
   const p = l.ctx;
   return p
end

#function parent{id}(l::Leftv{id})
#   const ctx = get_raw_context(l);
#   return SRingID[ctx]; ### Import???
#end

function isRingDependend(typ::Cint)
   const ret = (@cxx RingDependend(typ));
   return (ret != 0)
end

function isRingDependend{id}(l::Leftv{id})
   const p = get_raw_ptr(l); 
   const ret = (@cxx p -> RingDependend());
   return (ret != 0)
end

function Print{id}(l::Leftv{id}, store::leftv = leftv(C_NULL), spaces::Cint = 0)
###    /// Called by type_cmd (e.g. "r;") or as default in jPRINT
###    void Print(leftv store=NULL,int spaces=0); 
   const p = get_raw_ptr(l);

   if isRingDependend(l)
      const r = get_raw_context(l);
      if r != ring(C_NULL)

         const orig_ring = rChangeCurrRing(r);
         (@cxx p -> Print(store, spaces));
         rChangeCurrRing(orig_ring);

         return Void();
      end
   end	 
   (@cxx p -> Print(store, spaces));
end

function ToString{id}(l::Leftv{id}, d::Ptr{Void} = C_NULL, typed::Cint = 0, dim::Cint = 1)
###    char * String(void *d=NULL, BOOLEAN typed = FALSE, int dim = 1);
   const p = get_raw_ptr(l); 

   if isRingDependend(l)
      const r = get_raw_context(l);
      if r != ring(C_NULL)

         const orig_ring = rChangeCurrRing(r);
         const m = (@cxx p -> String(d, typed, dim));
         rChangeCurrRing(orig_ring);
	 
         const s = bytestring( m ); omFree(Ptr{Void}(m));
   	 return s
      end
   end	 

   const m = (@cxx p -> String(d, typed, dim));
   const s = bytestring( m ); omFree(Ptr{Void}(m));
   return s
end

function string{id}(l::Leftv{id})
   s = "Singular Object: " * ToString(l);

   if isRingDependend(l)
      const r = get_raw_context(l);
      if r != ring(C_NULL)
         s *= " with parent ring: " * string(r);
      end
   end
   return s
end

#### hash !!!! 

show{id}(io::IO, l::Leftv{id}) = print(io, string(l))

function deepcopy{id}(l::Leftv{id})
   const p = get_raw_ptr(l); 
   const ctx = get_raw_context(l); # Ring Context Parent 

   const res = Leftv(id, ctx);
   const pp = get_raw_ptr(res); 

   if isRingDependend(l) && (ctx != ring(C_NULL))
      const orig_ring = rChangeCurrRing(ctx); 
      (@cxx p -> Copy(pp));
      rChangeCurrRing(orig_ring);
   else
      (@cxx p -> Copy(pp));
   end

   return(res);

end

function CleanUp{id}(l::Leftv{id})
   const p = get_raw_ptr(l);
   const ctx = get_raw_context(l);  # Ring Context Parent

   (@cxx p -> CleanUp(ctx)); # clean up the internally referenced data only!
end

function _Leftv_clear_fn{id}(l::Leftv{id})
   CleanUp(l);

   const p = get_raw_ptr(l);

   l.ptr = leftv(C_NULL);
   l.ctx = ring(C_NULL);

   icxx""" omFreeBin((ADDRESS)$p, sleftv_bin); """
end

#  function Leftv(id::Cint, R::ring)
#     const p = (icxx""" return ((leftv)omAllocBin(sleftv_bin)); """); @cxx p -> Init();
#     (icxx""" $p -> rtyp = (int)$id; """);
#     return Leftv{id}(p, R);
#  end

  function Leftv(id::Cint, d::Ptr{Void}, R::ring = ring(C_NULL))
     const p = (icxx""" return ((leftv)omAllocBin(sleftv_bin)); """); @cxx p -> Init();
     (icxx""" $p -> rtyp = (int)$id;  $p -> data = $d; """);
     z = Leftv{id}(p, R)
     return z; 
  end

function remove_raw_data{id}(l::Leftv{id})
   const p = get_raw_ptr(l)
   const data = Ptr{Void}(@cxx p -> data); 
   (icxx""" $p -> data = NULL; """);
   return data;
end

function get_raw_data{id}(l::Leftv{id})
   const p = get_raw_ptr(l);
   const data = Ptr{Void}(@cxx p -> data);
   return data;
end

function get_raw_id{id}(l::Leftv{id}) 
   const p = get_raw_ptr(l);
   const t = Cint(@cxx p -> rtyp); 
#   (Cint(id) != ANY_TYPE()) && @assert t == Cint(id);
   return t
   return Cint(id) ## TODO: for release version !
end

function get_data{id}(l::Leftv{id})
   const p = get_raw_ptr(l)
   return Ptr{Void}(@cxx p -> Data() );
end

function get_id{id}(l::Leftv{id}) 
   const p = get_raw_ptr(l);
   const t = Cint(@cxx p -> Typ() ); 
   return t
end


function ToLeftv{id}( a::Leftv{id} )
   return deepcopy(a); #### !!!! 
end

#=
static inline void * s_internalCopy(const int t,  void *d)
{
  switch (t)
  {
    case DEF_CMD:
    case NONE:
    case 0: /* type in error case */
      break; /* error recovery: do nothing */
    //case COMMAND:

#ifdef SINGULAR_4_1    
    case CRING_CMD:
      {        
        coeffs cf=(coeffs)d;
        cf->ref++;
        return (void*)d;
      }
    case CNUMBER_CMD:
      return (void*)n2Copy((number2)d);
    case CMATRIX_CMD: // like BIGINTMAT
#endif
    case BIGINTMAT_CMD:
      return (void*)bimCopy((bigintmat *)d);
    case STRING_CMD:
        return (void *)omStrDup((char *)d);
    case POLY_CMD:
    case VECTOR_CMD:
      return  (void *)pCopy((poly)d);
    case INT_CMD:
      return  d;
    case BIGINT_CMD:
      return  (void *)n_Copy((number)d, coeffs_BIGINT);
    case RING_CMD:
    case QRING_CMD:
      {
        ring r=(ring)d;
        if (r!=NULL) r->ref++;
        //Print("+  ring %d, ref %d\n",r,r->ref);
        return d;
      }
    case LINK_CMD:
      return (void *)slCopy((si_link) d);

    case INTVEC_CMD:
    case INTMAT_CMD:
      return (void *)ivCopy((intvec *)d);

    case MATRIX_CMD:
      return (void *)mp_Copy((matrix)d, currRing);
    case RESOLUTION_CMD:
      return (void*)syCopy((syStrategy)d);

    case IDEAL_CMD:
    case MODUL_CMD:
      return  (void *)idCopy((ideal)d);

    case PACKAGE_CMD:
      return  (void *)paCopy((package) d);
    case PROC_CMD:
      return  (void *)piCopy((procinfov) d);
    case NUMBER_CMD:
      return  (void *)nCopy((number)d);
    case MAP_CMD:
      return  (void *)maCopy((map)d, currRing);
    case LIST_CMD:
      return  (void *)lCopy((lists)d);

    default:
    {
      if (t>MAX_TOK)
      {
        blackbox *b=getBlackboxStuff(t);
        if (b!=NULL) return b->blackbox_Copy(b,d);
        return NULL;
      }
      else
      Warn("s_internalCopy: cannot copy type %s(%d)", Tok2Cmdname(t),t);
    }
  }
  return NULL;
}
=#

function ToLeftv( a::Int )
   const id = INT_CMD();
   const data = Ptr{Void}(a); # deepcopy?!
   return Leftv(id, data, ring(C_NULL));
end

function ToLeftv( a::AbstractString )
   const id = STRING_CMD();
   const data = Ptr{Void}( omStrDup( Ptr{Cuchar}(pointer(a)) ) ); # copy!
   return Leftv(id, data);
end


function ToLeftv( a::intvec )
   (@cxx a -> ivTEST());
   const id = (@cxx INTVEC_CMD);
   const aa = (@cxx ivCopy(a));
   (@cxx aa -> ivTEST());
   const data = Ptr{Void}(aa); # copy!
   return Leftv(id, data);
end

function ToLeftv( a::si_link )
   const id = (@cxx LINK_CMD);
   const aa = (@cxx slCopy(a)); # copy!
   const data = Ptr{Void}(aa); 
   return Leftv(id, data);
end

function ToLeftv( a::bigintmat )
   const id = (@cxx BIGINTMAT_CMD);
   const aa = (@cxx bimCopy(a)); # copy!
   const data = Ptr{Void}(aa); 
   return Leftv(id, data);
end


function ToLeftv( a::syStrategy )
   const id = (@cxx RESOLUTION_CMD);
   const aa = (@cxx syCopy(a)); # shallow copy!
   const data = Ptr{Void}(aa); 
   return Leftv(id, data);
end

function ToLeftv( a::procinfov ) # syStrategy )
   const id = (@cxx PROC_CMD);
   const aa = (@cxx piCopy(a)); # shallow copy!
   const data = Ptr{Void}(aa); 
   return Leftv(id, data);
end

function ToLeftv( a::Singular_ZZElem )
   const id = (@cxx BIGINT_CMD);
   const c = coeffs_BIGINT(); ###### TODO: NOTE: depends on the use of coeffs_BIGINT() for ptr_ZZ!!!!
   const aa = n_Copy(get_raw_ptr(a), c); # copy!
   const data = Ptr{Void}(aa); 
   return Leftv(id, data); # no ring!
end

function ToLeftv( a::PRing )
   const id = (@cxx RING_CMD);
   const g = get_raw_ptr(a);
   if (g != ring(C_NULL))
      icxx""" ring gg = (ring)$g; gg->ref++; """; ## shallow copy...
   end
   const data = Ptr{Void}(g);
   return Leftv(id, data); # NOTE: no additional ring!
end

function ToLeftv( a::PRingElem )
   const id = (@cxx POLY_CMD);
   const rr = get_raw_ptr(parent(a));
   const p = get_raw_ptr(a);
   const data = Ptr{Void}(p_Copy(p, rr));
   return Leftv(id, data, rr);
end

function ToLeftv( a::PModuleElem )
   const id = (@cxx VECTOR_CMD);
   const rr = get_raw_ptr(parent(a));
   const p = get_raw_ptr(a);
   const data = Ptr{Void}(p_Copy(p, rr));
   return Leftv(id, data, rr);
end

function ToLeftv( a::SingularIdeal )
   const id = (@cxx IDEAL_CMD);
   const rr = get_raw_ptr(parent(a));
   const p = get_raw_ptr(a);
   const data = Ptr{Void}(id_Copy(p, rr));
   return Leftv(id, data, rr);
end

function ToLeftv( a::SingularModule )
   const id = (@cxx MODUL_CMD);
   const rr = get_raw_ptr(parent(a));
   const p = get_raw_ptr(a);
   const data = Ptr{Void}(id_Copy(p, rr));
   return Leftv(id, data, rr);
end

#### coeffs -> PRing( SingularCoeffs(coeffs), "@", :lex ) ?! check currRing! ## get_raw_ptr,ring = get_raw_ptr(parent)??

function FromLeftv( cmd::Cint, data::Ptr{Void}, R::ring )
    if (cmd == STRING_CMD())
         const s = bytestring( Ptr{Cuchar}(data) ); omFree(Ptr{Void}(data));
	 return(s);
    end	 
    (cmd == INT_CMD()) && return Int( data );
    (cmd == @cxx INTVEC_CMD) && return intvec(data) ;

    (cmd == @cxx LINK_CMD) && return si_link(data) ;
    (cmd == @cxx PROC_CMD) && return procinfov(data) ;

    (cmd == @cxx BIGINT_CMD) && return Singular_ZZElem(number(data));
    (cmd == @cxx BIGINTMAT_CMD) && return bigintmat(data) ;

    (cmd == @cxx RESOLUTION_CMD) && return syStrategy(data) ;

    (cmd == @cxx RING_CMD) && return PRing(ring(data));

#    if R != ring(C_NULL)
       (cmd == @cxx POLY_CMD) && return PRingElem(PRing(R), (icxx""" return ((poly)($data)); """) );   
       (cmd == @cxx VECTOR_CMD) && return PModuleElem(PRing(R), (icxx""" return ((poly)($data)); """) );

       (cmd == @cxx IDEAL_CMD) && return SingularIdeal(PRing(R), (icxx""" return ((ideal)($data)); """) );
       (cmd == @cxx MODUL_CMD) && return SingularModule(PRing(R), (icxx""" return ((ideal)($data)); """) );
#    end

    return Leftv(cmd, data, R);
end

#=
#### top(leftv) <-> bottom(Val{cmd}) ### ::Type{Val{Cint()}} # eval!
function FromLeftv( INT?CMD() )
   const data = get_raw_data(l);
   return Int( data )
end
=#

function LEFTV(arg :: Cint)
    (arg == ANY_TYPE()) && return :Any; ##    DEF_CMD,?

    (arg == STRING_CMD()) && return :AbstractString; # Ptr{Cuchar}; # symbol() ;
    (arg == INT_CMD()) && return :Int ;

    (arg == @cxx INTVEC_CMD) && return :intvec ;
    (arg == @cxx LINK_CMD) && return :si_link ;
    (arg == @cxx PROC_CMD) && return :procinfov ;

    (arg == @cxx BIGINTMAT_CMD) && return :bigintmat ;
    (arg == @cxx BIGINT_CMD) && return :Singular_ZZElem;

    (arg == @cxx RING_CMD) && return :PRing;

    (arg == @cxx IDEAL_CMD) && return :SingularIdeal ;
    (arg == @cxx MODUL_CMD) && return :SingularModule ;

    (arg == @cxx POLY_CMD) && return :PRingElem ;
    (arg == @cxx VECTOR_CMD) && return :PModuleElem ;

    (arg == @cxx RESOLUTION_CMD) && return :syStrategy ;

    return :(Leftv{$arg})
######################################################

#    (arg == @cxx QRING_CMD) && return :SingularPolynomialRing; ### not yet...
    (arg == @cxx LIST_CMD) && return :lists ;

    (arg == @cxx PACKAGE_CMD) && return :idhdl ;
    (arg == IDHDL()) && return :idhdl;

    (arg == @cxx INTMAT_CMD) && return :intmat ;

### Ring dependent:
#    (arg == @cxx NUMBER_CMD) && return :SingularCoeffsElems ; ### ????

# TODO:
#    (arg == @cxx MAP_CMD) && return :SingularMap ;
#    (arg == @cxx MATRIX_CMD) && return :SingularMatrix ;
    return :leftv;

#######################################################################################
#=
/* valid when ring defined ! */
/* types, part 2 */  
IDEAL_CMD, MAP_CMD, MATRIX_CMD, MODUL_CMD, NUMBER_CMD, POLY_CMD, RESOLUTION_CMD, VECTOR_CMD
/* end types */
/* ring dependent cmd, with argumnts indep. of a ring*/
BETTI_CMD, E_CMD, FETCH_CMD, FREEMODULE_CMD, KEEPRING_CMD, IMAP_CMD, KOSZUL_CMD, MAXID_CMD, MONOM_CMD, PAR_CMD, PREIMAGE_CMD, VAR_CMD
/*system variables in ring block*/
VALTVARS, VMAXDEG, VMAXMULT, VNOETHER, VMINPOLY
/* end of ring definitions */
=#
#######################################################################################
end


end; ## module SingularKernel 



