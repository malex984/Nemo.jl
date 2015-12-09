using Base.Test
using Cxx

# include("generic/Fraction-test.jl")
# include("generic/Residue-test.jl")
# include("generic/PowerSeries-test.jl")

include("generic/Poly-test.jl")
# include("generic/Matrix-test.jl")


function test_singular_wrappers()
   println("Printing Singular resources pathes...")  
   Nemo.libSingular.PrintResources("Singular Resources info: ")
   println("PASS")
end


# TODO: untangle this mess!!!
function test_singular_lowlevel_coeffs()

   print("Wrapping libSingular constants/functions with Cxx/Julia...\n")  

cxx"""
void test_coeffs(n_coeffType t, void *p, long v)
{
   int seed = siSeed;

   PrintS("Singular coeffs output: ");
   coeffs C = nInitChar(t, p); 
   n_CoeffWrite(C, 1);

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

   n_Delete(&nn, C);
   nKillChar(C);
   siSeed = seed;
}
"""

   @test Nemo.libSingular.n_Zp() == Nemo.libSingular.n_coeffType(1)
   @test Nemo.libSingular.n_Q() == Nemo.libSingular.n_coeffType(2)
   @test Nemo.libSingular.n_Z() == Nemo.libSingular.n_coeffType(9)

   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   print("SingularZZ: $ZZ, SingularQQ: $QQ...")
   println("PASS")


### TODO: separate creation for Coeffs & pass them into jtest_coeffs instead!


   function jtest_coeffs(n :: Nemo.libSingular.n_coeffType, p :: Ptr{Void}, i::Int)

        print("Test embedding (Int)$i into Singular coeffs: $n ($p) via Cxx:\n")  
        @cxx test_coeffs(n, p, i)
        println("\n...PASS")


	print("Test embedding (Int)$i into Singular coeffs: $n ($p) via iCxx:\n")  

	C = Nemo.Coeffs( n, p )

	print("coeffs: ")
	println( Nemo.get_raw_ptr(C) )

	print("Singular coeffs output: ")
	Nemo.libSingular.n_CoeffWrite( Nemo.get_raw_ptr(C), false )

 	const ch = Nemo.characteristic(C)

	println("Char coeffs: ", ch)

	println("C: ", C)
        
        zr = zero(C)
	println("C(0): ", zr)

        id = one(C)
	println("C(1): ", id)
        mid = C(-1)
	println("C(-1): ", mid)

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
	@test (id > 0) # bug somewhere in the Julia engine :(

        if (ch == 0)  
            @test (id > mid)
            @test (zr > mid)

            @test (id > -1) # bug as above ...?
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

	const ii = Nemo.libSingular.n_Int( Nemo.get_raw_ptr(z), Nemo.get_raw_ptr( Nemo.parent(z)) )

	@test ((ch == 0) && (i == ii)) || ((ch > 0) && ((i - ii) % ch == 0))


        const P = Nemo.npars(C)

        for j = 1:P
           k = C(0)

           while( Nemo.iszero(k) )
              k = C(Nemo.libSingular.siRand())
           end

#           p = par(i, C)
#	   muleq!(p, k)
           z = z + par(i, C) * k 
# addeq!(z, p)
        end

        for j = 0:(P+4)
            println("Singular number output: ", z^j);
        end

##	Nemo.n_Delete(z, C.ptr)
#	print("Deleted number: ")
#	println(z);


        R, x = PolynomialRing(C, "x")

        f = x^3 + 3x - 1
        println("f: ", f)


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

#        g = (f+1)^10 + 1 
	g = g + R(1)

#        g = (f+1)^10 + 1 
        println("g: ", g)


        println("f*g: ", f * g)

	if !Nemo.isring(C) 
           println("C is not a RING - Field?")
##	   println("gcd: ", gcd(f, g))
        end

	S, y = PolynomialRing(R, "y")
        T, z = PolynomialRing(S, "z")
	U, t = PolynomialRing(T, "t")

        p = (1+x+y+z+t);
        println("p: ", p)
        @time pp = p^10

        # println("pp: ", pp)
        @time ppp = pp*(pp+1);

###	g = h^5 ## bug in powering ???
		
        println("\n...PASS")
   end	  


   # q = 66 in QQ
#   @test Nemo.SingularQQ() == Nemo.Coeffs( Nemo.libSingular.n_Q(), Ptr{Void}(0) )
   jtest_coeffs( Nemo.libSingular.n_Q(), Ptr{Void}(0), 66)
#   @cxx test_coeffs( n_Q(), Ptr{Void}(0), 66) 

   ## z = 666 in ZZ
#   @test Nemo.SingularZZ() == Nemo.Coeffs( Nemo.libSingular.n_Z(), Ptr{Void}(0) )
   jtest_coeffs( Nemo.libSingular.n_Z(), Ptr{Void}(0), 666) 
#   @cxx test_coeffs( n_Z, Ptr{Void}(0), 666) 

   ## zz = 6 in Zp{11}
   jtest_coeffs( Nemo.libSingular.n_Zp(), Ptr{Void}(11), 11*3 + 6) 
#   @cxx test_coeffs( n_Zp, Ptr{Void}(11), 11*3 + 6) 

end


function test_singular_polynomial_rings()
   print("Constructing/showing/deleting Singular rings via Cxx...")

##TODO## icxx" char* n [] = { (char*)\"t\"}; ring r = rDefault( 13, 1, n); rWrite(r); PrintLn(); rDelete(r); "

cxx"""
ring test_contruct_ring()
{
  char* n [] = { (char*)\"t\"}; 
  ring r = rDefault( 13, 1, n); 
  rWrite(r); 
  PrintLn(); 
  return (r);
}
"""
   r = @cxx test_contruct_ring()
   println(r)
   @cxx rDelete(r)
   println("PASS")


   print("Constructing Singular Polynomial Ring over native coeffs...\n")  

   const ZZ = Nemo.SingularZZ();
   RZ = Nemo.PRing(ZZ, Symbol("x, y"));

   print("_ Over Singular Integer Ring [", string(ZZ), "]: ", string(RZ))
   # @test parent(RZ) == ZZ # ?
   println("...PASS")

   const QQ = Nemo.SingularQQ();
   RQ = Nemo.PRing(QQ, Symbol("x, y"));

   print("_ Over Singular Rational Field [", QQ, "]: ", string(RQ))
   # @test parent(RQ) == QQ # ?
   println("...PASS")

end



function test_singular()
   println()

   test_singular_wrappers()
   test_singular_lowlevel_coeffs()
   test_singular_polynomial_rings()

   # generic polynomials over SingularZZ()...
   test_poly_singular()

end

#### TODOs:

## Generic Polys over Singular Coeffs with benchmarks!
## Matrices over Singular Coeffs with benchmarks!
## Benchmarks?!

##### Generic Poly : gcd :( ?


#######################################################
### TODO? Nemo Fields (e.g. BigFloat/QQ?) as Singular Coeffs?

### Register Coeffs into Singular?


#function dummy(cf::Ptr{Void})
#  println("new coeffs: $cf"); return
#end
#const dummy_c = cfunction(dummy, Void, (Ptr{Void},))
#cxx"""
#BOOLEAN myInitChar(coeffs n, void*){
#n->cfCoeffWrite  = (???)$dummy_c; return FALSE; } 
#"""
                
#function jlInit(cf::Ptr{Void}, ::Ptr{Void})
#  println("jlInit: new coeffs: $cf"); return convert( Cint, 1);
#end
#const cjlInit = cfunction(jlInit, Cint, (Ptr{Void},Ptr{Void}))
#newTyp = icxx" return nRegister( n_unknown, (cfInitCharProc)$cjlInit); " # CppEnum{:n_coeffType}(14)
#newCoeff = icxx" return nInitChar( $newTyp, 0 ); "
