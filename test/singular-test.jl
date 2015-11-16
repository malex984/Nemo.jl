using Base.Test
using Cxx

function test_singular()
   println()

   print("Printing Singular resources pathes...\n")  

   Nemo.PrintResources("Singular Resources info: ")

   println("PASS")

   print("Constructing/showing/deleting Singular rings via Cxx...")

##TODO## icxx" char* n [] = { (char*)\"t\"}; ring r = rDefault( 13, 1, n); rWrite(r); PrintLn(); rDelete(r); "

cxx"""
void test_contruct_ring()
{
  char* n [] = { (char*)\"t\"}; 
  ring r = rDefault( 13, 1, n); 
  rWrite(r); 
  PrintLn(); 
  rDelete(r);
}
"""
   @cxx test_contruct_ring()

   println("PASS")

#function dummy(cf::Ptr{Void})
#  println("new coeffs: $cf"); return
#end
#const dummy_c = cfunction(dummy, Void, (Ptr{Void},))
#cxx"""
#BOOLEAN myInitChar(coeffs n, void*){
#n->cfCoeffWrite  = (???)$dummy_c; return FALSE; } 
#"""

#######################################################
                
#function jlInit(cf::Ptr{Void}, ::Ptr{Void})
#  println("jlInit: new coeffs: $cf"); return convert( Cint, 1);
#end
#const cjlInit = cfunction(jlInit, Cint, (Ptr{Void},Ptr{Void}))
#newTyp = icxx" return nRegister( n_unknown, (cfInitCharProc)$cjlInit); " # CppEnum{:n_coeffType}(14)
#newCoeff = icxx" return nInitChar( $newTyp, 0 ); "

   print("Wrapping libSingular constants/functions with Cxx...\n")  

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

   function jtest_coeffs(n :: Nemo.n_coeffType, p :: Ptr{Void}, i::Int)

        print("Test embedding (Int)$i into Singular coeffs: $n ($p) via Cxx:\n")  
        @cxx test_coeffs(n, p, i)
        println("\n...PASS")


	print("Test embedding (Int)$i into Singular coeffs: $n ($p) via iCxx:\n")  

	C = Nemo.Coeffs( n, p )

	print("coeffs: ")
	println( Nemo.get_raw_ptr(C) )

	print("Singular coeffs output: ")
	Nemo.n_CoeffWrite( Nemo.get_raw_ptr(C), false )

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

        @test (id > zr) && (id != zr)
        @test (1 > zr) && (1 != zr)
        @test (id > 0) && (id != 0)

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
	Nemo.n_Print(r, Nemo.get_raw_ptr( Nemo.parent(z)) )
	println();

	println("z: ", z)

	const ii = Nemo.n_Int( Nemo.get_raw_ptr(z), Nemo.get_raw_ptr( Nemo.parent(z)) )

	@test ((ch == 0) && (i == ii)) || ((ch > 0) && ((i - ii) % ch == 0))


        const P = Nemo.npars(C)

        for j = 1:P
           k = C(0)

           while( Nemo.iszero(k) )
              k = C(Nemo.siRand())
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
        @time pp = p^20

        # println("pp: ", pp)
        @time ppp = pp*(pp+1);

##	g = h^5
		
        println("\n...PASS")
   end	  

   println("PASS")

   @test Nemo.n_Zp() == Nemo.n_coeffType(1)
   @test Nemo.n_Q() == Nemo.n_coeffType(2)
   @test Nemo.n_Z() == Nemo.n_coeffType(9)

### TODO: separate creation for Coeffs & pass them into jtest_coeffs instead!
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();
   println("SingularZZ: ", ZZ)
   println("SingularQQ: ", QQ)

   # q = 66 in QQ
#   @test Nemo.SingularQQ() == Nemo.Coeffs( Nemo.n_Q(), Ptr{Void}(0) )
   jtest_coeffs( Nemo.n_Q(), Ptr{Void}(0), 66)#   @cxx test_coeffs( n_Q(), Ptr{Void}(0), 66) 

   ## z = 666 in ZZ
#   @test Nemo.SingularZZ() == Nemo.Coeffs( Nemo.n_Z(), Ptr{Void}(0) )
   jtest_coeffs( Nemo.n_Z(), Ptr{Void}(0), 666) #   @cxx test_coeffs( n_Z, Ptr{Void}(0), 666) 

   ## zz = 6 in Zp{11}
   jtest_coeffs( Nemo.n_Zp(), Ptr{Void}(11), 11*3 + 6) #   @cxx test_coeffs( n_Zp, Ptr{Void}(11), 11*3 + 6) 


   println()


end

##### SingPoly : p * q & gcd 


