module SingularKernel

import Base: Array, call, checkbounds, convert, cmp, contains, deepcopy,
             den, div, divrem, gcd, gcdx, getindex, hash, inv, invmod, isequal, 
             isless, lcm, length, mod, ndigits, num, one, parent, print,
             promote_rule, Rational, rem, setindex!, show, sign, size, string,  zero,
             +, -, *, ==, ^, &, |, $, <<, >>, ~, <=, >=, <, >, //, /, !=

import Nemo: Ring, RingElem, divexact, characteristic, degree, gen, transpose ## , deepcopy #
import Nemo: PRingElem, PRing, PModuleElem, SingularIdeal, SingularModule, Singular_ZZElem, SingularCoeffsElems, get_raw_ptr

using Nemo
using ..libSingular
using Cxx

function __init_singular_interpreter__()
#   cV = (@cxx currentVoice); # Voice?
   i = (@cxx feInitStdin( Voice(C_NULL) ) );

#   println(typeof(i));
#   println(i);

   icxx""" setPtr(currentVoice, $i); """

#   cV = (@cxx currentVoice); # PVoice?
#   @show cV

   ## Cxx.CppFptr{Cxx.CppFunc{Void,Tuple{Ptr{UInt8}}}}
   global const WerrorS_callback = (@cxx WerrorS_callback);
#   @show  WerrorS_callback

   if (WerrorS_callback == typeof(WerrorS_callback)(C_NULL))
##      _nemoWerrorS = cfunction(nemoWerrorS, Void, (Ptr{Cuchar},));
      (icxx""" setPtr( WerrorS_callback, $(cfunction(nemoWerrorS, Void, (Ptr{Cuchar},))) ); """); # _nemoWerrorS
   end


   nPos = Cint(0);
   while true

      p = getArith1( nPos );

      (p == C_NULL) && break;

      cmd  = Cint(@cxx p -> cmd);

      (cmd == Cint(0)) && break;

      pp   = Cint(@cxx p -> p);

      res  = Cint(@cxx p -> res);
      arg  = Cint(@cxx p -> arg);
      opt  = Cint(@cxx p -> valid_for);

      scmd = __iiTwoOps(cmd);
      sarg = __Tok2Cmdname(arg);
      sres = __Tok2Cmdname(res);

      if ( (pp != Cint(2))||(scmd == "\$INVALID\$")||(sarg == "\$INVALID\$")||(sres == "\$INVALID\$") )
          nPos = nPos + Cint(1);
          continue;
      end 

      if ( (scmd == sarg) && (scmd == sres) )
          nPos = nPos + Cint(1);
          continue;
      end

     println("\#$nPos:  $scmd:$cmd( $sarg:$arg ) -> $sres:$res, valid_for: ", bin(opt, 5) );
    
     sarg = LEFTV(arg);

     try  ##      SingularKernel.
      eval(:(
         function $(symbol(scmd))( ___arg :: $(sarg) ) # Julia types  <-1:1-> Singular Interpreter Types
	      @assert Cshort(@cxx errorreported) == Cshort(0)

	      __arg = ToLeftv( ___arg ); ## Leftv{}
	      _arg = get_raw_ptr(__arg); ## leftv

	      R = get_raw_context(__arg);
	      orig_ring = rChangeCurrRing(R); 

#	      ($arg != ANY_TYPE()) && @assert Cint(@cxx _arg -> Typ()) == $arg

	      d = Ref{Ptr{Void}}(C_NULL); t = Ref{Cint}(Cint(0)); e = Ref{Cint}(Cint(0));
	      
	      cmd = $(cmd);

              StartPrintCapture();
	      icxx""" sleftv r;r.Init(); $e = ((int)iiExprArith1(&r,$_arg,$cmd)); $d=r.data;$t=r.rtyp; """ ;
              EndPrintCapture();

	      f = string($(scmd)) * "( " * string($(sarg)) * " )";

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



   nPos = Cint(0);
   while true

      p = getArith2( nPos );

      (p == C_NULL) && break;

      cmd  = Cint(@cxx p -> cmd);

      (cmd == Cint(0)) && break;

      pp   = Cint(@cxx p -> p);

      res  = Cint(@cxx p -> res);
      arg1  = Cint(@cxx p -> arg1);
      arg2  = Cint(@cxx p -> arg2);
      opt  = Cint(@cxx p -> valid_for);

      scmd = __iiTwoOps(cmd);
      sarg1 = __Tok2Cmdname(arg1);
      sarg2 = __Tok2Cmdname(arg2);
      sres = __Tok2Cmdname(res);

      if ( (pp != Cint(2))||(scmd == "\$INVALID\$")||(sarg1 == "\$INVALID\$")||(sarg2 == "\$INVALID\$")||(sres == "\$INVALID\$") )
          nPos = nPos + Cint(1);
          continue;
      end 

     println("\#$nPos:  $scmd:$cmd( $sarg1:$arg1, $sarg2:$arg2 ) -> $sres:$res, valid_for: ", bin(opt, 5) );

     sarg1 = LEFTV(arg1);
     sarg2 = LEFTV(arg2);

     try  ##      SingularKernel.
      eval(:(
         function $(symbol(scmd))( ___arg1 :: $(sarg1), ___arg2 :: $(sarg2) ) # Julia types  <-1:1-> Singular Interpreter Types
	      @assert Cshort(@cxx errorreported) == Cshort(0)

	      __arg1 = ToLeftv( ___arg1 ); ## Leftv{}
	      _arg1 = get_raw_ptr(__arg1); ## leftv

	      __arg2 = ToLeftv( ___arg2 ); ## Leftv{}
	      _arg2 = get_raw_ptr(__arg2); ## leftv

	      f = string($(scmd)) * "( " * string($(sarg1)) * ", " * string($(sarg2)) * " )";

	      R1 = get_raw_context(__arg1);
	      R2 = get_raw_context(__arg2);

	      if R1 != C_NULL && R2 != C_NULL && ( R1 != R2 )
		  error("Error at Singular Kernel Call via Interpreter: '$f': different context rings!");
	      end

	      orig_ring = rChangeCurrRing(R1);
	      rChangeCurrRing(R2);

#	      ($arg1 != ANY_TYPE()) && @assert Cint(@cxx _arg1 -> Typ()) == $arg1

	      d = Ref{Ptr{Void}}(C_NULL); t = Ref{Cint}(Cint(0)); e = Ref{Cint}(Cint(0));
	      
	      cmd = $(cmd);

              StartPrintCapture();
	      icxx""" sleftv r;r.Init(); $e = ((int)iiExprArith2(&r,$_arg1,$cmd,$_arg2)); $d=r.data;$t=r.rtyp; """ ;
              EndPrintCapture();

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





   nPos = Cint(0);
   while true

      p = getArith3( nPos );

      (p == C_NULL) && break;

      cmd  = Cint(@cxx p -> cmd);

      (cmd == Cint(0)) && break;

      pp   = Cint(@cxx p -> p);

      res  = Cint(@cxx p -> res);
      arg1  = Cint(@cxx p -> arg1);
      arg2  = Cint(@cxx p -> arg2);
      arg3  = Cint(@cxx p -> arg3);
      opt  = Cint(@cxx p -> valid_for);

      scmd = __iiTwoOps(cmd);
      sarg1 = __Tok2Cmdname(arg1);
      sarg2 = __Tok2Cmdname(arg2);
      sarg3 = __Tok2Cmdname(arg3);
      sres = __Tok2Cmdname(res);

      if ( (pp != Cint(2))||(scmd == "\$INVALID\$")||(sarg1 == "\$INVALID\$")||(sarg2 == "\$INVALID\$")||(sarg3 == "\$INVALID\$")||(sres == "\$INVALID\$") )
          nPos = nPos + Cint(1);
          continue;
      end 

     println("\#$nPos:  $scmd:$cmd( $sarg1:$arg1, $sarg2:$arg2, $sarg3:$arg3 ) -> $sres:$res, valid_for: ", bin(opt, 5) );

     sarg1 = LEFTV(arg1);
     sarg2 = LEFTV(arg2);
     sarg3 = LEFTV(arg3);

     try  ##      SingularKernel.
      eval(:(
         function $(symbol(scmd))( ___arg1 :: $(sarg1), ___arg2 :: $(sarg2), ___arg3 :: $(sarg3) )
	      @assert Cshort(@cxx errorreported) == Cshort(0)

	      __arg1 = ToLeftv( ___arg1 ); ## Leftv{}
	      _arg1 = get_raw_ptr(__arg1); ## leftv

	      __arg2 = ToLeftv( ___arg2 ); ## Leftv{}
	      _arg2 = get_raw_ptr(__arg2); ## leftv

	      __arg3 = ToLeftv( ___arg3 ); ## Leftv{}
	      _arg3 = get_raw_ptr(__arg3); ## leftv

	      f = string($(scmd)) * "( " * string($(sarg1)) * ", " * string($(sarg2)) * ", " * string($(sarg3)) * " )";

	      R1 = get_raw_context(__arg1);
	      R2 = get_raw_context(__arg2);
	      R3 = get_raw_context(__arg3);

	      if R1 != C_NULL && R2 != C_NULL && ( R1 != R2 )
		  error("Error at Singular Kernel Call via Interpreter: '$f': different context rings!");
	      end

	      if R1 != C_NULL && R3 != C_NULL && ( R1 != R3 )
		  error("Error at Singular Kernel Call via Interpreter: '$f': different context rings!");
	      end

	      if R2 != C_NULL && R3 != C_NULL && ( R2 != R3 )
		  error("Error at Singular Kernel Call via Interpreter: '$f': different context rings!");
	      end

	      orig_ring = rChangeCurrRing(R1);
	      rChangeCurrRing(R2);
	      rChangeCurrRing(R3);

#	      ($arg1 != ANY_TYPE()) && @assert Cint(@cxx _arg1 -> Typ()) == $arg1

	      d = Ref{Ptr{Void}}(C_NULL); t = Ref{Cint}(Cint(0)); e = Ref{Cint}(Cint(0));
	      
	      cmd = $(cmd);

              StartPrintCapture();

	      icxx""" sleftv r;r.Init(); $e = ((int)iiExprArith3(&r,$cmd,$_arg1,$_arg2,$_arg3)); $d=r.data;$t=r.rtyp; """ ;

	      EndPrintCapture();
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




   nPos = Cint(0);
   while true

      p = getArithM( nPos );

      (p == C_NULL) && break;

      cmd  = Cint(@cxx p -> cmd);

      (cmd == Cint(0)) && break;

      pp   = Cint(@cxx p -> p);

      res  = Cint(@cxx p -> res);
      narg  = Cint(@cxx p -> number_of_args);
      opt  = Cint(@cxx p -> valid_for);

      scmd = __iiTwoOps(cmd);
##      sarg = __Tok2Cmdname(arg);
      sres = __Tok2Cmdname(res);

      if ( (pp != Cint(2))||(scmd == "\$INVALID\$")||(1 <= narg && narg <= 3 )||(sres == "\$INVALID\$") )
          nPos = nPos + Cint(1);
          continue;
      end 

#      if ( scmd == "breakpoint" || scmd == "reduce" )
      if ( (scmd == "string") && (scmd == sres) )
          scmd = "_" *  scmd;
#          nPos = nPos + Cint(1);
#          continue;
      end


     println("\#$nPos:  $scmd:$cmd( ,,,$narg?,,, ) -> $sres:$res, valid_for: ", bin(opt, 5) );
    
#     sarg = LEFTV(arg);

     try  ##      SingularKernel.
      eval(:(
         function $(symbol(scmd))( ___args... )
	      @assert Cshort(@cxx errorreported) == Cshort(0)

              if $narg >= 0
	          @assert (length(___args) == $narg);
              else
                  @assert (length(___args) >= (-$narg - 1));   # -1 => any, -2 => at least one...
	      end

	      f = string($(scmd)) * "( ,,,?" * string($(narg)) * "?,,, )";

	      _args = leftv(C_NULL);
	      _tail = leftv(C_NULL);

	      orig_ring = currRing();

	      R = ring(C_NULL);

	      for arg in ___args
   	          __arg = ToLeftv( arg ); ## Leftv{}
	      	  r = get_raw_context(__arg);
		  
		  if( r != C_NULL )
		      if R == C_NULL
		          R = r;
		      end
		      
		      (R != r) && error("Error at Singular Kernel Call via Interpreter: '$f': different context rings!");
		  end
		        
		  
  		  if _args == C_NULL
		     _args = get_raw_ptr(__arg); ## leftv
		     _tail = _args;
		  else
 		     @assert _tail != C_NULL
		     _arg = remove_raw_data(__arg);
		     (icxx""" ((leftv)$_tail) -> next = (leftv)($_arg); """);
		     _tail = _arg;
		  end

		  
	      end

	      rChangeCurrRing(R);

#	      ($arg != ANY_TYPE()) && @assert Cint(@cxx _arg -> Typ()) == $arg

	      d = Ref{Ptr{Void}}(C_NULL); t = Ref{Cint}(Cint(0)); e = Ref{Cint}(Cint(0));
	      
	      cmd = $(cmd);

              StartPrintCapture(); 

	      icxx""" sleftv r;r.Init(); $e = ((int)iiExprArithM(&r,(leftv)$_args,$cmd)); $d=r.data;$t=r.rtyp; """ ;

              EndPrintCapture();

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

   visitPackages(1);

end

global const LANGUAGES = ("LANG_NONE", "LANG_TOP", "LANG_SINGULAR", "LANG_C", "LANG_MAX: UNKNOWN"); # TODO: static / global constant

function StartPrintCapture()
    @cxx SPrintStart();
end

function EndPrintCapture()
    println( bytestring( @cxx SPrintEnd() ) );
end


function RUNEXAMPLE(s::AbstractString)
   @assert !isempty(s)

   StartPrintCapture();
   (@cxx singular_example(pointer(s)));    # // void  singular_example(char *str);
   EndPrintCapture();
end


function PRINTHELP(s::AbstractString)
   StartPrintCapture();

# // fehelp.h: void feHelp(char* str = NULL);
   if isempty(s)
      (@cxx feHelp(Ptr{Cuchar}(C_NULL)));
   else
      (@cxx feHelp(pointer(s)));
   end

   EndPrintCapture();
end

PRINTHELP() = PRINTHELP("")

function CALLPROC(h::idhdl, ___args...)

   @assert Cshort(@cxx errorreported) == Cshort(0)
   @assert h != C_NULL

   t = IDTYP(h);
   @assert t == PROC_CMD()


   p = IDPROC(h);
   pkg = (@cxx p -> pack);

   _args = leftv(C_NULL);
   _tail = leftv(C_NULL);

   orig_ring = currRing();

   R = ring(C_NULL);

   for arg in ___args

	          __arg = ToLeftv( arg ); ## Leftv{}
	      	  r = get_raw_context(__arg);
		  
		  if( r != C_NULL )
		      if R == C_NULL
		          R = r;
		      end
		      
		      (R != r) && error("Error at Singular Kernel Call via Interpreter: '$f': different context rings!");
		  end
		        
		  
  		  if _args == C_NULL
		     _args = get_raw_ptr(__arg); ## leftv
		     _tail = _args;
		  else
 		     @assert _tail != C_NULL
		     _arg = remove_raw_data(__arg);
		     (icxx""" ((leftv)$_tail) -> next = (leftv)($_arg); """);
		     _tail = _arg;
		  end
   end

   rChangeCurrRing(R);
   tmpHdl = rSetFakeRingHdl();

   (icxx""" iiRETURNEXPR.Init(); """);


   StartPrintCapture(); #    EndPrintCapture();
   ### BOOLEAN iiMake_proc(idhdl pn, package pack, sleftv* sl);
   error_code = Cint(icxx""" return ((int)iiMake_proc($h, $pkg, (leftv)$_args)); """);
   EndPrintCapture();

   println("Singular interpreter returned: $error_code, errorreported: ", (@cxx errorreported));

   if (error_code > 0) 
      icxx""" errorreported = 0; /* reset error handling */ """
      rKillFakeRingHdl(tmpHdl);
      rChangeCurrRing(orig_ring);
      error("Sorry: error while calling procedure $n(...)!");
   end

   res = (icxx""" return(&iiRETURNEXPR); """) 

   @assert (res != C_NULL)

   n = (@cxx res -> listLength())
   
   ret = Void()

   if n > 0
      t = Cint(@cxx res -> Typ())
      d = Ptr{Void}(@cxx res -> Data())

      println("Return[1] Type: ", Tok2Cmdname(t))
      println("Return[1] Data: ", d)

      if n == 1
         ret = FromLeftv( t, d, currRing() )
      else
         ret = Array(Any, n)
	 i = 1

	 ret[i] = FromLeftv( t, d, currRing() )
	 n = (@cxx res -> Next())

	 res = n
	 i = i + 1

 	 while ((i <= n) && (res != C_NULL))
            
            local t = Cint(@cxx res -> Typ())
            local d = Ptr{Void}(@cxx res -> Data())

	    println("Return[$i] Type: ", Tok2Cmdname(t))
	    println("Return[$i] Data: ", d )

    	    ret[i] = FromLeftv( t, d, currRing() )
	    n = (@cxx res -> Next())
            (icxx""" $res->next=NULL; omFreeBin($res, sleftv_bin); """)
	    res = n
	    i = i + 1
	 end

	 @assert (res == C_NULL) && (i > n)
      end
   end

   rKillFakeRingHdl(tmpHdl); rChangeCurrRing(orig_ring)
   return(ret)

end

function CALLPROC(n::AbstractString, ___args...)
   h = ggetid(n); # Singular Proc from standard.lib

   if (h == C_NULL)
      error("Singular's procedure '$n' does not exist!");   
   end

   t = IDTYP(h);

   println("Singular's name '$n' of type ", Tok2Cmdname(t));

   @assert t == PROC_CMD()

   return CALLPROC(h, ___args...);
end


function EVALUATE(s::AbstractString)
    @assert Cshort(@cxx errorreported) == Cshort(0)

    s *= ";RETURN();";

    println("Evaluating singular code: ", s);

    tmpHdl = rSetFakeRingHdl(); 


   ### TODO: Ask Hans about myynest!
   icxx""" myynest = 1; /* <=0: interactive at eof / >=1: non-interactive */ """;

#=
enum   feBufferTypes {
  BT_none  = 0,  // entry level
  BT_break = 1,  // while, for
  BT_proc,       // proc
  BT_example,    // example
  BT_file,       // <"file"
  BT_execute,    // execute
  BT_if,         // if
  BT_else        // else
};
=#
   StartPrintCapture(); 

   ## BT_proc: BOOLEAN err = iiAllStart(NULL, s, BT_proc, 0);
   error_code = Cint( icxx""" return ((int)iiAllStart(NULL, (char*)$(pointer(s)), BT_execute, 0)); """ )

   EndPrintCapture();

   rKillFakeRingHdl(tmpHdl);   

   println("Singular interpreter returned: $error_code, errorreported: ", (@cxx errorreported));

   if (error_code > 0) 
      icxx""" errorreported = 0; /* reset error handling */ """
      return(false);
   end

   return(true);
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

function IDHDL()
    return Cint( icxx""" return (int)(IDHDL); """ );
end

function INT_CMD()
   return Cint( @cxx INT_CMD ); 
end

function STRING_CMD()
   return Cint( @cxx STRING_CMD ); 
end

function INTVEC_CMD()
   t = (@cxx INTVEC_CMD);
   return Cint(icxx""" return ((int)($t)); """);
end

function NUMBER_CMD()
   t = (@cxx NUMBER_CMD);
   return Cint(icxx""" return ((int)($t)); """);
end

function LINK_CMD()
   t = (@cxx LINK_CMD); 
   return Cint(icxx""" return ((int)($t)); """);
end

function BIGINTMAT_CMD()
   t = (@cxx BIGINTMAT_CMD);
   return Cint(icxx""" return ((int)($t)); """);
end

function BIGINT_CMD()
   t = (@cxx BIGINT_CMD);
   return Cint(icxx""" return ((int)($t)); """);
end

function IDEAL_CMD()
   t = (@cxx IDEAL_CMD);
   return Cint(icxx""" return ((int)($t)); """);
end

function INTMAT_CMD()
   t = (@cxx INTMAT_CMD);
   return Cint(icxx""" return ((int)($t)); """);
end

function LIST_CMD()
   t = (@cxx LIST_CMD);
   return Cint(icxx""" return ((int)($t)); """);
end

function MODUL_CMD()
   t = (@cxx MODUL_CMD);
   return Cint(icxx""" return ((int)($t)); """);
end

function POLY_CMD()
   t = (@cxx POLY_CMD);
   return Cint(icxx""" return ((int)($t)); """);
end

function PROC_CMD()
   t = (@cxx PROC_CMD);
   return Cint(icxx""" return ((int)($t)); """);
end

function PACKAGE_CMD()
   t = (@cxx PACKAGE_CMD);
   return Cint(icxx""" return ((int)($t)); """);
end

function QRING_CMD()
   t = (@cxx QRING_CMD);
   return Cint(icxx""" return ((int)($t)); """);
end

function RESOLUTION_CMD()
   t = (@cxx RESOLUTION_CMD);
   return Cint(icxx""" return ((int)($t)); """);
end

function RING_CMD()
   t = (@cxx RING_CMD);
   return Cint(icxx""" return ((int)($t)); """);
end

function VECTOR_CMD()
   t = (@cxx VECTOR_CMD);
   return Cint(icxx""" return ((int)($t)); """);
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
    p = pointer(n);
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
   p = l.ptr;
#   (Cint(id) != ANY_TYPE()) && @assert Cint(id) == Cint(@cxx p -> rtyp)
   return p
end

function get_raw_context{id}(l::Leftv{id})  # Ring Context Parent
   p = l.ctx;
   return p
end

#function parent{id}(l::Leftv{id})
#   ctx = get_raw_context(l);
#   return SRingID[ctx]; ### Import???
#end

function isRingDependend(typ::Cint)
   ret = (@cxx RingDependend(typ));
   return (ret != 0)
end

function isRingDependend{id}(l::Leftv{id})
   p = get_raw_ptr(l); 
   ret = (@cxx p -> RingDependend());
   return (ret != 0)
end

function Print{id}(l::Leftv{id}, store::leftv = leftv(C_NULL), spaces::Cint = 0)
###    /// Called by type_cmd (e.g. "r;") or as default in jPRINT
###    void Print(leftv store=NULL,int spaces=0); 
   p = get_raw_ptr(l);

   if isRingDependend(l)
      r = get_raw_context(l);
      if r != C_NULL

         orig_ring = rChangeCurrRing(r);
         (@cxx p -> Print(store, spaces));
         rChangeCurrRing(orig_ring);

         return Void();
      end
   end	 
   (@cxx p -> Print(store, spaces));
end

function ToString{id}(l::Leftv{id}, d::Ptr{Void} = C_NULL, typed::Cint = 0, dim::Cint = 1)
###    char * String(void *d=NULL, BOOLEAN typed = FALSE, int dim = 1);
   p = get_raw_ptr(l); 

   if isRingDependend(l)
      r = get_raw_context(l);
      if r != C_NULL

         orig_ring = rChangeCurrRing(r);
         m = (@cxx p -> String(d, typed, dim));
         rChangeCurrRing(orig_ring);
	 
         s = bytestring( m ); omFree(Ptr{Void}(m));
   	 return s
      end
   end	 

   m = (@cxx p -> String(d, typed, dim));
   s = bytestring( m ); omFree(Ptr{Void}(m));
   return s
end

function string{id}(l::Leftv{id})
   s = "Singular Object: " * ToString(l);

   if isRingDependend(l)
      r = get_raw_context(l);
      if r != C_NULL
         s *= " with parent ring: " * string(r);
      end
   end
   return s
end

#### hash !!!! 

show{id}(io::IO, l::Leftv{id}) = print(io, string(l))

function deepcopy{id}(l::Leftv{id})
   p = get_raw_ptr(l); 
   ctx = get_raw_context(l); # Ring Context Parent 

   res = Leftv{id}(id, ctx);
   pp = get_raw_ptr(res); 

   if isRingDependend(l) && (ctx != C_NULL)
      orig_ring = rChangeCurrRing(ctx); 
      (@cxx p -> Copy(pp));
      rChangeCurrRing(orig_ring);
   else
      (@cxx p -> Copy(pp));
   end

   return(res);

end

function CleanUp{id}(l::Leftv{id})
   p = get_raw_ptr(l);
   ctx = get_raw_context(l);  # Ring Context Parent

   (@cxx p -> CleanUp(ctx)); # clean up the internally referenced data only!
end

function _Leftv_clear_fn{id}(l::Leftv{id})
   CleanUp(l);

   p = get_raw_ptr(l);

   l.ptr = leftv(C_NULL);
   l.ctx = ring(C_NULL);

   icxx""" omFreeBin((ADDRESS)$p, sleftv_bin); """
end

#  function Leftv(id::Cint, R::ring)
#     p = (icxx""" return ((leftv)omAllocBin(sleftv_bin)); """); @cxx p -> Init();
#     (icxx""" $p -> rtyp = (int)$id; """);
#     return Leftv{id}(p, R);
#  end

function remove_raw_data{id}(l::Leftv{id})
   p = get_raw_ptr(l)
   data = Ptr{Void}(@cxx p -> data); 
   (icxx""" $p -> data = NULL; """);
   return data;
end

function get_raw_data{id}(l::Leftv{id})
   p = get_raw_ptr(l);
   data = Ptr{Void}(@cxx p -> data);
   return data;
end

function get_raw_id{id}(l::Leftv{id}) 
   p = get_raw_ptr(l);
   t = Cint(@cxx p -> rtyp); 
#   (Cint(id) != ANY_TYPE()) && @assert t == Cint(id);
   return t
   return Cint(id) ## TODO: for release version !
end

function get_data{id}(l::Leftv{id})
   p = get_raw_ptr(l)
   return Ptr{Void}(@cxx p -> Data() );
end

function get_id{id}(l::Leftv{id}) 
   p = get_raw_ptr(l);
   t = Cint(@cxx p -> Typ() ); 
   return t
end


  function ToLeftv(id::Cint, d::Ptr{Void}, R::ring = ring(C_NULL))
     p = (icxx""" return ((leftv)omAllocBin(sleftv_bin)); """); @cxx p -> Init();
     (icxx""" $p -> rtyp = (int)$id;  $p -> data = $d; """);
     z = Leftv{id}(p, R)
     return z; 
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
   id = INT_CMD();
#   data = Ptr{Void}(a); # deepcopy?!
   return ToLeftv(id, (icxx""" return ((void*)($a)); """));
end

function ToLeftv( a::AbstractString )
   id = STRING_CMD();
   data = omStrDup( Ptr{Cuchar}(pointer(a)) ); # copy!
   return ToLeftv(id, (icxx""" return ((void*)($data)); """));
end

function ToLeftv( a::intvec )
   (@cxx a -> ivTEST());
   id = INTVEC_CMD();
   aa = (@cxx ivCopy(a));
   (@cxx aa -> ivTEST());
#   data = Ptr{Void}(aa); # copy!
   return ToLeftv(id, (icxx""" return ((void*)($aa)); """));
end


# TODO: avoid copying via IDHDL containers with fake symbol names 
### ASK Hans?!

function ToLeftv( a::si_link )
   id = LINK_CMD();
   aa = (@cxx slCopy(a)); # copy!
#   data = Ptr{Void}(aa); 
   return ToLeftv(id, (icxx""" return ((void*)($aa)); """));
end

function ToLeftv( a::bigintmat )
   id = BIGINTMAT_CMD(); 
   aa = (@cxx bimCopy(a)); # copy!
#   data = Ptr{Void}(aa); 
   return ToLeftv(id, (icxx""" return ((void*)($aa)); """));
end

function ToLeftv( a::syStrategy )
   id = RESOLUTION_CMD();
   aa = (@cxx syCopy(a)); # shallow copy!
#   data = Ptr{Void}(aa); 
   return ToLeftv(id, (icxx""" return ((void*)($aa)); """));
end

function ToLeftv( a::procinfov ) # syStrategy )
   id = PROC_CMD();
   aa = (@cxx piCopy(a)); # shallow copy!
#   data = Ptr{Void}(aa); 
   return ToLeftv(id, (icxx""" return ((void*)($aa)); """));
end

function ToLeftv( a::BigInt )
   id = BIGINT_CMD();
   aa = n_InitMPZ(a, coeffs_BIGINT());
   return ToLeftv(id, (icxx""" return ((void*)($aa)); """)); # no ring!
end

function ToLeftv( a::PRing )
   id = RING_CMD();
   g = get_raw_ptr(a);
   if (g != C_NULL)
      icxx""" ring gg = (ring)$g; gg->ref++; """; ## shallow copy...
   end
   return ToLeftv(id, (icxx""" return ((void*)($g)); """)); # NOTE: no additional ring!
end

function ToLeftv( a::PRingElem )
   id = POLY_CMD();
   rr = get_raw_ptr(parent(a));
   p = get_raw_ptr(a);
   data = p_Copy(p, rr);
   return ToLeftv(id, (icxx""" return ((void*)($data)); """), rr);
end

function ToLeftv( a::PModuleElem )
   id = VECTOR_CMD();
   rr = get_raw_ptr(parent(a));
   p = get_raw_ptr(a);
   data = p_Copy(p, rr);
   return ToLeftv(id, (icxx""" return ((void*)($data)); """), rr);
end

function ToLeftv( a::SingularIdeal )
   t = IDEAL_CMD(); # (@cxx ); # Cxx.CppEnum{:yytokentype}
   id = Cint(icxx""" return ((int)($t)); """);
   rr = get_raw_ptr(parent(a));
   data = id_Copy(get_raw_ptr(a), rr);
   return ToLeftv(id, (icxx""" return ((void*)($data)); """), rr);
end

function ToLeftv( a::SingularModule )
   t = MODUL_CMD();
   id = Cint(icxx""" return ((int)($t)); """);
   rr = get_raw_ptr(parent(a));
   p = get_raw_ptr(a);
   data = id_Copy(p, rr);
   return ToLeftv(id, (icxx""" return ((void*)($data)); """), rr);
end

function ToLeftv( a::SingularCoeffsElems )
   id = NUMBER_CMD();
   c = get_raw_ptr(parent(a));
   rr = currRing();

   #### TODO: for Hans on Singular side: e.g. currentCoeffs?
   (c != rGetCoeffs(rr)) && error("Error during converting NUMBER -> LEFTV: number coeffs is not from current ring!");

   data = n_Copy(get_raw_ptr(a), c);
   return ToLeftv(id, (icxx""" return ((void*)($data)); """), rr); # no ring!
end

function FromLeftv( cmd::Cint, data::Ptr{Void}, R::ring )
    if (cmd == STRING_CMD())
         s = bytestring( Ptr{Cuchar}(data) ); omFree(Ptr{Void}(data));
	 return(s);
    end	 
    (cmd == INT_CMD()) && return Int( data );
    (cmd == INTVEC_CMD()) && return intvec(data) ;

    (cmd == LINK_CMD()) && return si_link(data) ;
    (cmd == PROC_CMD()) && return procinfov(data) ;

    if (cmd == BIGINT_CMD())  ##return convert(BigInt, Singular_ZZElem(number(data));
       c = coeffs_BIGINT(); 
       n = Ref(icxx""" return ((number)($data)); """);       
       b = n_MPZ(n, c);
       n_Delete( n[], c);
       return b;
    end	
 
    (cmd == BIGINTMAT_CMD()) && return bigintmat(data) ;
    (cmd == RESOLUTION_CMD()) && return syStrategy(data) ;
    (cmd == RING_CMD()) && return PRing(ring(data)); 

#    if R != C_NULL
       (cmd == NUMBER_CMD()) && return base_ring(PRing(R))(icxx""" return ((number)($data)); """); 

       (cmd == POLY_CMD()) && return PRingElem(PRing(R), (icxx""" return ((poly)($data)); """) );   
       (cmd == VECTOR_CMD()) && return PModuleElem(PRing(R), (icxx""" return ((poly)($data)); """) );

       (cmd == IDEAL_CMD()) && return SingularIdeal(PRing(R), (icxx""" return ((ideal)($data)); """) );
       (cmd == MODUL_CMD()) && return SingularModule(PRing(R), (icxx""" return ((ideal)($data)); """) );
#    end

    return Leftv(cmd, data, R);
end

#=
#### top(leftv) <-> bottom(Val{cmd}) ### ::Type{Val{Cint()}} # eval!
function FromLeftv( INT?CMD() )
   data = get_raw_data(l);
   return Int( data )
end
=#

function LEFTV(arg :: Cint)
    (arg == ANY_TYPE()) && return :Any; ##    DEF_CMD,?

    (arg == STRING_CMD()) && return :AbstractString; # Ptr{Cuchar}; # symbol() ;
    (arg == INT_CMD()) && return :Int ;

    (arg == INTVEC_CMD()) && return :intvec ;
    (arg == LINK_CMD()) && return :si_link ;
    (arg == PROC_CMD()) && return :procinfov ;

    (arg == BIGINTMAT_CMD()  ) && return :bigintmat ;
    (arg == BIGINT_CMD()  ) && return :BigInt;

    (arg == RING_CMD()  ) && return :PRing;

    (arg == IDEAL_CMD()  ) && return :SingularIdeal ;
    (arg == MODUL_CMD()  ) && return :SingularModule ;

    (arg == POLY_CMD()  ) && return :PRingElem ;
    (arg == VECTOR_CMD()  ) && return :PModuleElem ;

    (arg == RESOLUTION_CMD()  ) && return :syStrategy ;

    (arg == NUMBER_CMD()  ) && return :SingularCoeffsElems ; ### TODO: ????

    return :(Leftv{$arg})


######################################################

###!!! (arg == IDHDL()) && return :idhdl; ### ????
###????
      (arg == PACKAGE_CMD() ) && return :idhdl ;

## easy:
#    (arg == QRING_CMD()  ) && return :SingularPolynomialRing; ### not yet...
#    (arg == LIST_CMD()  ) && return :lists ; ### Array(Any, 1)
#    (arg == INTMAT_CMD()  ) && return :intmat ;


### Ring dependent:

# TODO: ring?
#    (arg == @cxx MAP_CMD) && return :SingularMap ;
#    (arg == @cxx MATRIX_CMD) && return :SingularMatrix ;

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



## ?
function currRingHdl()
   return(@cxx currRingHdl);
end

function rGetHdl(r::ring)
   @assert r != C_NULL
   return(idhdl(@cxx r -> idroot));
end

function IDRING(h::idhdl)
   @assert h != C_NULL
   return(icxx""" return (IDRING($h)); """);
end

function IDNEXT(h::idhdl)
   @assert h != C_NULL
   n = (icxx""" return (IDNEXT($h)); """);
   return idhdl(icxx""" return (void*)($n); """);
end

function IDTYP(h::idhdl)
   @assert h != C_NULL
   t = icxx""" return (IDTYP($h)); """ 
   return Cint(icxx""" return (int)($t); """);
end

function IDID(h::idhdl)
   @assert h != C_NULL
   return Ptr{Cuchar}(icxx""" return (char*)(IDID($h)); """);
end

function IDLEV(h::idhdl)
   @assert h != C_NULL
   return(icxx""" return (int)(IDLEV($h)); """);
end


function IDPROC(h::idhdl)
   @assert h != C_NULL
   p = (icxx""" return (procinfov)(IDPROC($h)); """);
   return procinfov(icxx""" return ((void*)($p)); """);
end

function IDPACKAGE(h::idhdl)
   @assert h != C_NULL
   p = (icxx""" return (package)(IDPACKAGE($h)); """);
   return package(icxx""" return ((void*)($p)); """);
end



function TOP_PKG()
   return (@cxx basePack);
end

function TOP_HDL()
   return (@cxx basePackHdl);
end

function CURR_PKG()
   return (@cxx currPack);
end

function IDROOT( p :: package)
   @assert p != C_NULL
   r = (@cxx p -> idroot);
   return idhdl(icxx""" return (void*)($r); """);
end

function IDROOT() ### currPack->idroot
   r = (icxx""" return (IDROOT); """)
   return idhdl(icxx""" return (void*)($r); """);
end

function LANGUAGE(p)
   i = Int(icxx""" return (int)($p -> language); """);

   if (i > 4); i = 4; end;

   @assert (0 <= i) && (i <= 4)
   return LANGUAGES[1+i];
end


function visitPackages(f) 
   H = TOP_HDL();
   @assert (IDTYP(H) == PACKAGE_CMD());
   p = TOP_PKG();
   PKG = ObjectIdDict(p => H);
   visitPackages(H, PKG);
end

module LIBS
end

function visitPackages(H :: idhdl, PKG)
  @assert (IDTYP(H) == PACKAGE_CMD());
  P  = IDPACKAGE(H);

  pk = bytestring(IDID(H));

#TODO: FIXME: # ERROR: LoadError: LoadError: InitError: syntax: module expression not at top level
##  M  = symbol(pk);  Main.Nemo.SingularKernel.eval( :( module $M; end; @show module_parent($M); @show module_name($M); ) ); 

  h  = IDROOT(P);

  while (h != C_NULL)

    t = IDTYP(h);
    n = IDID(h);
    l = IDLEV(h);

    PrintS( pointer( "[$l]: " * bytestring(n) * " :: " * Tok2Cmdname(t) * " " ) );

    if (t == PACKAGE_CMD())
       p = IDPACKAGE(h);
       (@cxx paPrint(n, p));

       lang = LANGUAGE(p); 
       PrintS( pointer( " | $lang "  ) );

       if !haskey(PKG, p)
          PKG[p] = h;

          hh = IDROOT(p);

          if (hh != C_NULL)
            PrintLn();
            PrintS(pointer("{")); PrintLn();
            visitPackages( h, PKG );
            PrintS(pointer("}")); PrintLn();
          end
       end       

    elseif (t == PROC_CMD())
       p = IDPROC(h);
       ln = bytestring(@cxx p -> libname);
 
       st = (@cxx p -> is_static) > 0 ;
       nn = bytestring(@cxx p -> procname);
       lang = LANGUAGE(p);
       PrintS( pointer( ((st)? " (static)" : "") * " in $pk / $ln  | $lang => $nn" ) );

       pkg = (@cxx p -> pack)

       if (! st) && (H == (@cxx packFindHdl(pkg)))
           procname = symbol(pk, "__", nn); # sname = (pk * "::" * nn);
           eval( :( $procname(args...) = CALLPROC($h, args...) ) )  # LIBS. ? # @show $procname 
       end
    end

    PrintLn();
    h = IDNEXT(h);
  end # while
end


function rSetHdl(h::idhdl)
   @assert h != C_NULL

   origin = currRingHdl();
   (origin == h) && return(origin);

   ## void rSetHdl(idhdl h); ## void rChangeCurrRing(ring r)
   (@cxx rSetHdl(h));
   return(origin);
end



function ggetid(n::AbstractString)
   # idhdl ggetid(const char *n); 
   return (@cxx ggetid(pointer(n)));
end

function ggetid(n::AbstractString, loc::Cint, packhdl::Ptr{idhdl})
   # idhdl ggetid(const char *n, BOOLEAN local, idhdl *packhdl);
   return (@cxx ggetid(pointer(n), loc, packhdl));
end


#   #//idhdl enterid(const char * a, int lev /*nesting level,0=global*/, int t, idhdl* root, BOOLEAN init=TRUE, BOOLEAN serach=TRUE);
#   return (icxx""" return (idhdl)(enterid( \"R\"         /*ring name*/, 0, RING_CMD, &IDROOT, FALSE ));""");
#   return (icxx""" return (idhdl)(enterid( \" Nemo fake currRingHdl \", 0, RING_CMD, &IDROOT, FALSE, FALSE)); """);

function rSetFakeRingHdl()
   r = currRing();

   (r == C_NULL) && return idhdl(C_NULL);

   h = currRingHdl();

   if h != C_NULL
       (IDRING(h) == r) && return idhdl(C_NULL);
   end    
   
   #### TODO: Q? use omStrDup as ID name
   tmpHdl = (icxx""" return (idhdl)enterid(\" Nemo fake currRingHdl \" , 0, RING_CMD, &IDROOT, FALSE, FALSE); """);

   @assert tmpHdl != C_NULL

   (icxx""" idhdl h = (idhdl)$tmpHdl; IDRING(h) = currRing; currRing->ref++; currRingHdl = h; """);
  
   return(tmpHdl); 
end

function rKillFakeRingHdl(tmpHdl::idhdl)
   if tmpHdl != C_NULL
       (icxx""" killhdl(((idhdl)$tmpHdl), currPack); currRingHdl = NULL; """);
   end
end 


end; ## module SingularKernel 



