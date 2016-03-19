using Base.Test
using Cxx

#==============================================================================
#   PolynomialRing constructor
==============================================================================#

# Union{Type{Val{:lex}}, Type{Val{:degrevlex}}}

function SingularPolynomialRing(R::Nemo.SingularCoeffs, varstr::AbstractString{}, ordering::Symbol = :degrevlex) 
#   try
       parent_obj = Nemo.PRing(R, varstr, Nemo.libSingular.dictOrdSymbols[ordering]);
       return parent_obj, gen(parent_obj)
#   catch e
#        @show e
#       error("Could not create a singular polynomial ring $R [$varstr] ordered via '$ordering'") 
#   end
#   error("Sorry: something went wrong... ")
end

#=
function PolynomialRing(R::Nemo.SingularCoeffs, s::AbstractString{}, ordering::Symbol = :lex)
   try
       parent_obj = Nemo.PRing(R, s, Nemo.libSingular.dictOrdSymbols[ordering]);
       return parent_obj, gen(parent_obj)
   catch
       error("Could not create a singular polynomial ring '$R' [$s] ordered via '$ordering'") 
   end
   error("Sorry: something went wrong... ")
end

function PolynomialRing(P::Nemo.SingularPolynomialRing, s::AbstractString{}, ordering::Symbol = :lex)
   try
      R = Nemo.PRing(base_ring(P), s, Nemo.libSingular.dictOrdSymbols[ordering]);

      parent_obj = P + R; # TODO: FIXME: does NOT work yet! :(( 

      return parent_obj, gen(parent_obj)
   catch
       error("Could not create a singular polynomial ring '$P' [$s] ordered via '$ordering'") 
   end
   error("Sorry: something went wrong... ")
end
=#


include("generic/Fraction-test.jl")
include("generic/Residue-test.jl") # TODO >= unary ops
include("generic/Poly-test.jl")
include("generic/Matrix-test.jl")
include("generic/PowerSeries-test.jl")

include("ZZ-test.jl")
include("QQ-test.jl")

include("ZZ_poly-test.jl")
include("QQ_poly-test.jl") # NOTE: not yet... maybe almost...?

include("Benchmark-test.jl")

function test_singular_wrappers()
   println("Printing Singular resources pathes...")  
   Nemo.libSingular.PrintResources("Singular Resources info: ")
   println("PASS")

   println("Printing Singular' omalloc info stats...")  
   Nemo.libSingular.omPrintInfoStats()
   println("PASS")
end

function test_generic_polys(C::Nemo.SingularCoeffs)
   println("test_generic_polys for 'C'...")
   println("C: ", C)

   print("zero(C): ")
   println(zero(C))

   print("C(0): ")
   println(C(Int(0)))

   print("R = C[x].... "); 

   R, x = PolynomialRing(C, "x"); # Singular
   println(R);
   
   println("x: $x"); 

   print("R(0): "); 
   println(R(0))

   print("zero(R): "); 
   println(zero(R))

   ff = R(3)*x + R(1) ### ??? 
   println("ff: ", ff)

   print("f")
   f = 0
   print(" :")
   f = f - 1 ### ??? 
   print(";")
   f = f + 3x
   print(":")
   f = f + x^3
   print(";")
   f = x^3 + 3x - 1  
   print(" : ")
   println(f)


   h = f + R(1)
   g = R(1)
   for j = 1:10
      println("j: ", j)
      g = g * h
#            println("g: ", g)
#            hj = (h^j)  
#            println("h^j: ", hj)
#            println("@test: ", g - hj)
#            @test length(g - hj) == 0 
   end


   print("Product(f+1, 10): "); 
   println(g)

   print("g: "); 
   g = g + 1
   println(g)

   print("(f+1)^10: "); 
   h = h^10; #### ERROR: LoadError: DivideError: integer division error   # TODO: FIXME: Zp{11}
   println(h);

   print("h: "); 
   h = h + 1
   println(h)

   println("h - g: ", h - g)
   @test (g == h)

   print("f*g: ")
   println(f*g)

   g = h^5; ## bug in powering ???

#	if !Nemo.isring(C)  # use isa(...Field)?
#           println("C is not a RING - Field?")
###	   println("gcd: ", gcd(f, g))
#        end

   # Benchmark:

   println("!!!!!!!!!!!!Generic Poly vs PRing!!!!!!!!!!!!!!!!")


   U, t = SingularPolynomialRing(C, "x, y, z, t"); 
   x = gen(U, 1); y = gen(U, 2); z = gen(U, 3);

	println(U);

        p = (t + z + y + x + 1);
        println("p: ", p)

        @time pp = p^4;
        @time pp = p^4;

        @time ppp = pp*(pp+1);
        @time ppp = pp*(pp+1);
		
        println("\n...PASS")


        R, x = PolynomialRing(C, "x"); 
	S, y = PolynomialRing(R, "y"); 
        T, z = PolynomialRing(S, "z"); 
	U, t = PolynomialRing(T, "t");

	println(U);

        p = (t + z + y + x + 1);
        println("p: ", p)

        @time pp = p^4;
        @time pp = p^4;
        @time ppp = pp*(pp+1);
        @time ppp = pp*(pp+1);
		
        println("\n...PASS")


end


function jtest_coeffs(C::Nemo.SingularCoeffs, i::Int)
	ptr =  Nemo.get_raw_ptr(C)

        println("Test embedding (Int)$i into Singular coeffs via Cxx... ")  
	println("Coeffs ptr: ", ptr)
	println("Coeffs    : ", C)

cxx"""
number test_coeffs(const coeffs C, long v)
{
   int seed = siSeed;

   PrintS("Singular coeffs output: \n"); n_CoeffWrite(C, 1);

   number nn = n_Init(v, C);

//   const int h = n_GetChar(C);
   const int P = n_NumberOfParameters(C);

   for (int i = 1; i <= P; i++) 
   {
      number k = NULL;

      while( n_IsZero(k, C) )
         k = n_Init(siRand(), C);

      number p = n_Param(i, C);
      n_InpMult(p, k, C);
      n_InpAdd(nn, p, C);
      n_Delete(&k, C);
      n_Delete(&p, C);
   }
 
   for (int i = 0; i <= 4 + P ; i++) 
   {
     number n;
     n_Power(nn, i, &n, C);

     PrintS("Singular number output: ");
     n_Print(n, C);
     PrintLn();

     n_Delete(&n, C);
   }

//   n_Delete(&nn, C);
   siSeed = seed;

   return (nn);
}
"""
        nn = @cxx test_coeffs(ptr, i);
        println("\n...PASS")

	print("Singular coeffs output: ")
	Nemo.libSingular.n_CoeffWrite( Nemo.get_raw_ptr(C), false )

	println("C: ")
	println(C)
        
 	const ch = Nemo.characteristic(C)
	println("Char coeffs: ", ch)

	print("C(1): ")
        id = one(C)
	println(id)

	print("C(0): ")
        zr = zero(C)
	println(zr) ## convert???!

        mid = C(-1)
	print("C(-1): ")
	println(mid)

        @test (!Nemo.isone(zr)) && (Nemo.iszero(zr)) && (!Nemo.ispositive(zr)) && (!Nemo.isnegative(zr))
        @test Nemo.isone(id) && (!Nemo.iszero(id)) && Nemo.ispositive(id)
        @test Nemo.ismone(mid) 
        @test Nemo.isnegative(mid)
        @test !Nemo.iszero(mid) 
        @test !Nemo.ispositive(mid)

        @test id > zr
	@test id != zr
	@test (1 != zr) 
        @test (id != 0)
        @test (1 > zr) 
	@test (id > 0)

        if (ch == 0)  
            @test (id > mid)
            @test (zr > mid)

            @test (id > -1)
            @test (zr > -1)
            @test (1 > mid)
            @test (0 > mid)
        end

	z = C(i)
	print("Number out of $i: ")
	println( Nemo.get_raw_ptr(z) )

	print("Singular number output: ")
        r = Nemo.get_raw_ptr(z)
	Nemo.libSingular.n_Print(r, Nemo.get_raw_ptr( Nemo.parent(z)) )
	println();

	println("z: ", z)

	const ii = Int(z) # Nemo.libSingular.n_Int( Nemo.get_raw_ptr(z), Nemo.get_raw_ptr( Nemo.parent(z)) )

	zz = C(ii)
	println("Convertions mappings: $i -> $z -> $ii -> $zz (mod $ch).....")

#	@test ((ch == 0) && (i == ii)) || ((ch > 0) && ((i - ii) % ch == 0)) #NOTE: HOW TO TEST IN GF(9)?

        print("P: "); 
        const P = Nemo.ngens(C)
        println(P);

        for j = 1:P
	   print("k: "); 
           k = C(Int(0))
	   println(k);

           while( Nemo.iszero(k) )
              print("k: "); 
	      k = C(Nemo.libSingular.siRand())
   	      println(k);
           end

#           p = par(i, C)
#	   muleq!(p, k)

	   print("k: "); 
	   k = gen(C, i) * k 
 	   println(k);

	   print("z: "); 
           z = z + k
 	   println(z);

# addeq!(z, p)
        end

        for j = 0:(P+4)
            print("Singular number output: ")
	    zz = z^j;
  	    println(zz);
        end

#	@test z == C(nn)

	Nemo.libSingular._n_Delete(nn, Nemo.get_raw_ptr(C))
#	print("Deleted number: ")
#	println(z);
end	  


# TODO: untangle this mess!!!
function test_singular_lowlevel_coeffs()

   print("Wrapping libSingular constants/functions with Cxx/Julia...\n")  

   const ZZ = Nemo.SingularZZ();
   const Z11 = Nemo.SingularZp(11);
   const QQ = Nemo.SingularQQ();

   println("SingularZZ: $ZZ")
   println("SingularQQ: $QQ")
   println("SingularZp(11): $Z11")

#   const GF = Nemo.SingularGF(3,2,"n"); ## TODO : FIXME : ???
#   println("SingularGF(3,2,'n'): $GF") #### 7,1???? // ** illegal GF-table size: 7  // ** Sorry: cannot init lookup table!??

   println("...................PASS")


### TODO: separate creation for Coeffs & pass them into jtest_coeffs instead!

   ## z = 666 in ZZ
   jtest_coeffs(ZZ, 2) 

   # q = 66 in QQ
   jtest_coeffs(QQ, 2)

   ## zz = 6 in Zp{11}
   jtest_coeffs(Z11, 11*3 + 2) 

###   jtest_coeffs(GF, 3*666 + 2) 

   test_generic_polys(ZZ)

   test_generic_polys(QQ)

   test_generic_polys(Z11)

###   test_generic_polys(GF)

end




function test_singular_polynomial_ring(C, s)

   print("Constructing Singular Polynomial Ring over $C: \n")  

#   R = Nemo.PRing(C, s); # just testing ATM!
   R, lastvar = SingularPolynomialRing(C, s, :degrevlex); # Nemo.

   println("_ Over [", string(C), "]: ", string(R))
   @test base_ring(R) == C # ?

   p = one(R) * R(2) + 3 + lastvar * gen(R);

   println("1*2+3+lastgen()^2: ", p, " @@ ", typeof(p))

   p = 0

   for i in 1:Nemo.ngens(R)
       p += (10 * Int(i)) * gen(R, i)
   end

## TODO: FIXME: add automatic mapping K -> K[x,y,z...]!?

   println("sum(10*i*gen(i)): ", p, " @@ ", typeof(p))

   println("...PASS")

   println("\nSingular Maximal ideals: "); 

   II = Nemo.maxideal(R, 2); println("MAX IDEAL[2]: ", II); 
   II = Nemo.std(II);  println("STD: ", II);
   II = Nemo.syz(II);  println("SYZ: ", II);

   println("...PASS")

   println("\nSingular Free Modules: "); 

   II = Nemo.freemodule(R, 2); println("FREE MODULE[2]: ", II);
   II = Nemo.std(II); println("STD: ", II);
   II = Nemo.syz(II);  println("SYZ: ", II);

   println("...PASS")
end

function test_singular_polynomial_rings()
   print("Constructing/showing/deleting Singular rings via Cxx...")

##TODO## icxx" char* n [] = { (char*)\"t\"}; ring r = rDefault( 13, 1, n); rWrite(r); PrintLn(); rDelete(r); "

cxx"""
ring test_construct_ring()
{
  char* n [] = { (char*)\"t\"}; 
  ring r = rDefault( 13, 1, n); 
  PrintLn(); rWrite(r, 1); 
  PrintLn(); 
  return (r);
}
"""
   r = @cxx test_construct_ring()
   println(r, string(r))
   @cxx rDelete(r)
   println("PASS")


   test_singular_polynomial_ring(Nemo.SingularZZ(), "z1")
   test_singular_polynomial_ring(Nemo.SingularZZ(), "z1, z2")
   test_singular_polynomial_ring(Nemo.SingularZZ(), "z1, z2, z3")
   test_singular_polynomial_ring(Nemo.SingularZZ(), "z1, z2, z3, z4")
   test_singular_polynomial_ring(Nemo.SingularQQ(), "q1, q2, q3")
   test_singular_polynomial_ring(Nemo.SingularQQ(), "q1, q2, q3,q4,q5,q6")

   test_singular_polynomial_ring(Nemo.SingularZp(3), "p1, p2, p3, p4, p5, p6")
   test_singular_polynomial_ring(Nemo.SingularZp(5), "p, pp, ppp")
   test_singular_polynomial_ring(Nemo.SingularZp(11), "p")

## TODO: FIXME: GF!
#   test_singular_polynomial_ring(Nemo.SingularGF(7, 1, "T")) #  // ** illegal GF-table size: 7  // ** Sorry: cannot init lookup table!??
#   test_singular_polynomial_ring(Nemo.SingularGF(3, 3, "T"))
#   test_singular_polynomial_ring(Nemo.SingularGF(5, 2, "T"))

end



function test_SINGULAR()

   const n = "iSingularVersion";
   s = "int $n = system(\"version\");RETURN();\n";
   println("Evaluating singular code: ", s);

   ### TODO: Ask Hans about myynest!
   icxx""" myynest = 1; /* <=0: interactive at eof / >=1: non-interactive */ """;
   error_code = Cint( icxx""" return ((int)iiAllStart(NULL, (char*)$(pointer(s)), BT_execute, 0)); """ )

   println("Singular interpreter returns: $error_code, errorreported: ", (@cxx errorreported));

   if (error_code > 0) 
      icxx""" errorreported = 0; /* reset error handling */ """
   end

   ##idhdl ggetid(const char *n); idhdl ggetid(const char *n, BOOLEAN local, idhdl *packhdl);
   h = (@cxx ggetid(pointer(n)))

   println(h);
   println(typeof(h));
   @show h

   if (h == typeof(h)(C_NULL))
      println("Singular's name '$n' does not exist!");   
   else
      println("Singular Variable '$n' of type ", Nemo.SingularKernel.Tok2Cmdname(@cxx h -> typ), 
              ", with value: ", (icxx""" return (IDINT($h)); """) );
#      println("Singular Variable '$n' of type ", (@cxx h -> typ),", with value: ", (icxx""" return ((int)(long)IDDATA($h)); """))
   end

   h = (@cxx ggetid(pointer("datetime"))); # Singular Proc from standard.lib

   println(h);
   println(typeof(h));
   @show h

   if (h == typeof(h)(C_NULL))
      println("Singular's name 'datetime' does not exist!");   
   else
      println("Singular's name 'datetime' of type ", Nemo.SingularKernel.Tok2Cmdname(@cxx h -> typ)); 

      ### BOOLEAN iiMake_proc(idhdl pn, package pack, sleftv* sl);
      error_code = Cint(icxx""" return ((int)iiMake_proc($h, NULL, NULL)); """); 

      println("Singular interpreter returns: $error_code, errorreported: ", (@cxx errorreported));

      if (error_code > 0)
         icxx""" errorreported = 0; /* reset error handling */ """
      else
         println("datetime returned type: ", Nemo.SingularKernel.Tok2Cmdname( (icxx""" return (iiRETURNEXPR.Typ()); """) ) );
         println("datetime returned data: ",  bytestring( Ptr{Cuchar}(icxx""" return ((char *)iiRETURNEXPR.Data()); """)) );
      end
   end


##  R=rDefault(32003,3,n);
   const R,zz = SingularPolynomialRing(Nemo.SingularZp(32003), "x,y,z"); 
   println("\nSingular RING: ", R, "... z: $zz");

   #//idhdl enterid(const char * a, int lev, int t, idhdl* root, BOOLEAN init=TRUE, BOOLEAN serach=TRUE);
   ringID = (icxx""" return (enterid( "R"/*ring name*/, 0,/*nesting level,0=global*/ RING_CMD, &IDROOT, FALSE ));""");

   @show ringID

   const r = get_raw_ptr(R); icxx""" IDRING($ringID) = ring($r);"""
   
   # // make R the default ring (include rChangeCurrRing):
   @cxx rSetHdl(ringID);

   @assert r == (@cxx currRing);

   icxx""" myynest = 1; /* <=0: interactive at eof / >=1: non-interactive */ """;

   s = "print(R);poly p=3*x^3-2*y^2+1*z;print(p);listvar();RETURN();\n";
   error_code = Cint( icxx""" return ((int)iiAllStart(NULL, (char*)$(pointer(s)), BT_proc, 0)); """ )

   println("Singular interpreter returns: $error_code, errorreported: ", (@cxx errorreported));

   if (error_code > 0) 
      icxx""" errorreported = 0; /* reset error handling */ """
   end

   h = (@cxx ggetid(pointer("p")));

   println(h);
   println(typeof(h));
   @show h

   if (h == typeof(h)(C_NULL))
      println("Singular's name 'p' does not exist!");   
   else
      print("Singular Variable 'p' of type ", Nemo.SingularKernel.Tok2Cmdname(@cxx h -> typ),", with value: ");
      p = (icxx""" return ((poly)IDPOLY($h)); """); 

      const P = R(p, true); # TODO: FIXME: takes ownership!!! For later cleanup!
      
      println("p: $P from ", p);
   end



## class sleftv; typedef sleftv * leftv; #(leftv)omAllocBin(sleftv_bin);
   r1 = (icxx""" return ((leftv)omAllocBin(sleftv_bin)); """);
   @show r1
   @cxx r1 -> Init(); 

   arg = (icxx""" return ((leftv)omAllocBin(sleftv_bin)); """);
   @cxx arg -> Init(); 

   @show arg

   icxx""" $arg -> rtyp = STRING_CMD; $arg -> data = omStrDup("huhu"); """

   @cxx arg -> Print()
 
   error_code = Cint( icxx""" return ((int)iiExprArith1($r1, $arg, TYPEOF_CMD)); """ )
   println("Singular interpreter returns: $error_code, errorreported: ", (@cxx errorreported));

   if (error_code > 0) 
      (icxx""" errorreported = 0; /* reset error handling */ """);
   else
      println("Singular '", Nemo.SingularKernel.Tok2Cmdname(@cxx TYPEOF_CMD),
       "' returned type: ", Nemo.SingularKernel.Tok2Cmdname(@cxx r1 -> Typ()));
      println("Returned data: ", bytestring( Ptr{Cuchar}(@cxx r1 -> Data())));

      (@cxx r1 -> Print());
   end


   @cxx r1 -> CleanUp(r);
   @cxx arg -> CleanUp(r);


# Singular kernel procedure # { "maxideal",    0, MAXID_CMD ,         CMD_1},

   @cxx arg -> Init(); icxx""" $arg -> rtyp = INT_CMD; $arg -> data = (void*)4; """

   @cxx r1 -> Init(); 

   c, mx = Nemo.SingularKernel.IsCmd("maxideal");

   @assert c == (@cxx CMD_1);
   @assert mx == (@cxx MAXID_CMD);

# {D(jjidMaxIdeal), MAXID_CMD,       IDEAL_CMD,      INT_CMD       , ALLOW_PLURAL |ALLOW_RING}
   error_code = Cint( icxx""" return ((int)iiExprArith1($r1, $arg, $mx)); """ )

   println("Singular interpreter returns: $error_code, errorreported: ", (@cxx errorreported));

   if (error_code > 0)
         icxx""" errorreported = 0; /* reset error handling */ """
   else
         (@cxx r1 -> Print());

         const t = (@cxx r1 -> Typ());

         println("Singular '", Nemo.SingularKernel.Tok2Cmdname(mx),"' returned type: ", Nemo.SingularKernel.Tok2Cmdname(t));
         println("Returned data: ") #  bytestring( Ptr{Cuchar}(@cxx r1 -> Data())));

	 @assert t == (@cxx IDEAL_CMD);

	 I = Nemo.SingularIdeal(R, Nemo.ideal(@cxx r1 -> Data()), true);
	 println("maxideal(): ", I);

         @cxx arg -> CleanUp(r);

	 _, std = Nemo.SingularKernel.IsCmd("std");
	 @assert std == (@cxx STD_CMD);

         error_code = Cint( icxx""" return ((int)iiExprArith1($arg, $r1, $std)); """ )

         println("Singular interpreter returns: $error_code, errorreported: ", (@cxx errorreported));

   	 if (error_code > 0)
            icxx""" errorreported = 0; /* reset error handling */ """
	 else
	    (@cxx arg -> Print());
	 end

   end

   @cxx arg -> CleanUp(r);   @cxx r1 -> CleanUp(r);
   icxx""" omFreeBin((ADDRESS)$r1, sleftv_bin); """
   icxx""" omFreeBin((ADDRESS)$arg, sleftv_bin); """

###############################################################

   nPos :: Cint = 0;
   while true
      p = Nemo.SingularKernel.iiArithGetCmd( nPos );

      (p == C_NULL) && break;

      s = bytestring(p);

      t, op = Nemo.SingularKernel.IsCmd(s);
      println("$nPos: cmd: $op ('$s') / '", Nemo.SingularKernel.iiTwoOps(op), "', type[$t]: ", Nemo.SingularKernel.Toktype(t));

      nPos = nPos + Cint(1);
   end

##############################################################

   @test Nemo.SingularKernel.varstr(1) == "x"
   @test Nemo.SingularKernel.varstr(2) == "y"
   @test Nemo.SingularKernel.varstr(3) == "z"
   @test Nemo.SingularKernel._size("123456") == 6
   @test Nemo.SingularKernel._size("..") == 2
   @test Nemo.SingularKernel.rvar("x") == 1
   @test Nemo.SingularKernel.rvar("y") == 2
   @test Nemo.SingularKernel.rvar("z") == 3
   @test Nemo.SingularKernel.rvar("a") == 0

   println("Executing string: "); 
   Nemo.SingularKernel.execute("int j = 3; ASSUME(0, (j*j+j) == 12); ");

   @test Nemo.SingularKernel._size("") == 0

   println("maxideal(3): ", Nemo.SingularKernel.maxideal(3));
   println("freemodule(3): ", Nemo.SingularKernel.freemodule(5));

end




function test_NemoCoeffs()
   println("Testing NemoCoeffs(FlintQQ/ZZ).................");

   NZ = Nemo.NemoCoeffs(FlintZZ);
   println("Nemo.NemoCoeffs(FlintZZ): ", NZ);

   print("NZ(6)");
   v = NZ(6);
   print("   :::   ");
   println(v);
   

   NQ = Nemo.NemoCoeffs(FlintQQ);
   println("Nemo.NemoCoeffs(FlintQQ): ", NQ);
   print("NQ(66)");
   vv = NQ(66);
   print("   :::   ");
   println(vv);
   
   jtest_coeffs(NQ, 2)

   test_generic_polys(NQ)

   test_singular_polynomial_ring(NQ, "_")

   println("\n...................PASS")

end

function test_singular()
   println("Singular unique rings & fields will use context-less implementation, right?  ", Nemo.uq_default_choice)

   println(); gc(); test_singular_wrappers()

   println(); gc(); test_SINGULAR();


   println(); gc(); test_singular_lowlevel_coeffs()

   println(); gc(); test_singular_polynomial_rings()

   println(); gc(); test_ZZ_singular()

   println(); gc(); test_QQ_singular() 

   println(); gc(); test_poly_singular() # TODO: FIXME: rSum!?

   println(); gc(); test_ZZ_poly_singular(); # TODO: FIXME: many things are missing at the moment :(

   println(); gc(); test_QQ_poly_singular(); # TODO: as for ZZ_poly!

##   include("???.jl"); #test_????()

   println(); gc(); test_fraction_singular()

   println(); gc(); test_residue_singular() 

   println(); gc(); test_series_singular()

   println(); gc(); test_matrix_singular()

   println(); gc(); test_benchmarks_singular()

#   println(); gc(); Nemo.libSingular.omPrintInfoStats()

   println(); gc(); Nemo.libSingular.omPrintInfoStats()

   println(); gc(); test_NemoCoeffs();


   println()
end

