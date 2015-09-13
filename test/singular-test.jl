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
void test_coeffs(n_coeffType t, void *p, long i)
{
   PrintS("Singular coeffs output: ");
   coeffs C = nInitChar(t, p); 
   n_CoeffWrite(C, 1);

   PrintS("Singular number output: ");
   number nn = n_Init(i, C);
   n_Print(nn, C);
   PrintLn();

   n_Delete(&nn, C);
   nKillChar(C);
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

##	Nemo.n_Delete(z, C.ptr)
#	print("Deleted number: ")
#	println(z);
		
        println("\n...PASS")
   end	  

   println("PASS")

   @test Nemo.n_Zp == Nemo.n_coeffType(1)
   @test Nemo.n_Q == Nemo.n_coeffType(2)
   @test Nemo.n_Z == Nemo.n_coeffType(9)

### TODO: separate creation for Coeffs & pass them into jtest_coeffs instead!
   println("SingularZZ: ", Nemo.SingularZZ)

   # q = 66 in QQ
   @test Nemo.SingularQQ == Nemo.Coeffs( Nemo.n_Q, Ptr{Void}(0) )

   jtest_coeffs( Nemo.n_Q, Ptr{Void}(0), 66)#   @cxx test_coeffs( n_Q, Ptr{Void}(0), 66) 

   ## z = 666 in ZZ
   @test Nemo.SingularZZ == Nemo.Coeffs( Nemo.n_Z, Ptr{Void}(0) )
   jtest_coeffs( Nemo.n_Z, Ptr{Void}(0), 666) #   @cxx test_coeffs( n_Z, Ptr{Void}(0), 666) 

   ## zz = 6 in Zp{11}
   jtest_coeffs( Nemo.n_Zp, Ptr{Void}(11), 11*3 + 6) #   @cxx test_coeffs( n_Zp, Ptr{Void}(11), 11*3 + 6) 

   println("SingularQQ: ", Nemo.SingularQQ)

end
