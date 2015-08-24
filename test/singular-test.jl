using Base.Test
using Cxx

function test_singular()
   println()

   print("libSingular loading...")  

on_windows = @windows ? true : false
pkgdir = Pkg.dir("Nemo") 
if on_windows
   wdir = "$pkgdir\\deps"
   vdir = "$pkgdir\\local"
   wdir2 = split(wdir, "\\")
   s = lowercase(shift!(wdir2)[1])
   unshift!(wdir2, string(s))
   unshift!(wdir2, "")
   wdir2 = join(wdir2, "/") 
   vdir2 = split(vdir, "\\")
   s = lowercase(shift!(vdir2)[1])
   unshift!(vdir2, string(s))
   unshift!(vdir2, "")
   vdir2 = join(vdir2, "/") 
else
   wdir = joinpath(pkgdir, "deps")
   vdir = joinpath(pkgdir, "local")
end

const singdir = vdir
const singbinpath = joinpath( singdir, "bin", "Singular" )
ENV["SINGULAR_EXECUTABLE"] = singbinpath

libSingular = Libdl.dlopen(joinpath(singdir, "lib", "libSingular.so"), Libdl.RTLD_GLOBAL)

   println("PASS")

   print("including Singular headers with Cxx...")  

   addHeaderDir(joinpath(singdir, "include"), kind = C_System)
   addHeaderDir(joinpath(singdir, "include", "singular"), kind = C_System)

   cxxinclude("Singular/libsingular.h", isAngled=false)
   cxxinclude("coeffs/coeffs.h", isAngled=false)

   cxx"""
   #include "Singular/libsingular.h"
   #include "coeffs/coeffs.h"
   """

   println("PASS")

   println("Calling siInit via Cxx...")  

   @cxx siInit(pointer(singbinpath))

   println("PASS")

   print("Printing Singular resources pathes...\n")  
@cxx StringSetS(pointer("Path info:"))
@cxx feStringAppendResources(0)
s = @cxx StringEndS()
# @cxx PrintS(s)  # BUG: PrintS is a C function
# icxx" PrintS($s); "   # quick and dirty shortcut

PrintS(m) = ccall( Libdl.dlsym(libSingular, :PrintS), Void, (Ptr{Uint8},), m) # another workaround
PrintS(s)

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
   Print("Singular coeffs output: ");
   coeffs C = nInitChar( t, p ); 
   n_CoeffWrite(C, 1);

   Print("Singular number output: ");
   number nn = n_Init(i, C);
   n_Print(nn, C);
   PrintLn();

   n_Delete(&nn, C);
   nKillChar(C);
}
"""

   function jtest_coeffs(n::Cxx.CppEnum{:n_coeffType}, p, i::Int)

        print("Test embedding (Int)$i into Singular coeffs: $n ($p) via Cxx:\n")  
        @cxx test_coeffs(n, Ptr{Void}(p), i)
        println("\n...PASS")


	print("Test embedding (Int)$i into Singular coeffs: $n ($p) via iCxx:\n")  

   	nInitChar(n, p) = icxx" return nInitChar( $n, (void*)($p) ); "
	n_CoeffWrite(cf, details::Bool = true) = icxx" n_CoeffWrite($cf, ($details? 1 : 0)); "
	n_Init(i::Int, cf) = icxx" return n_Init($i, $cf ); "
	n_Int(n, cf) = icxx" return n_Int($n, $cf); "
	n_Delete(n, cf) = icxx" n_Delete(& $n, $cf); "
	n_Print(n, cf) = icxx" n_Print( $n, $cf); "
	n_GetChar(cf) = icxx" return n_GetChar($cf); "
	nKillChar(cf) = icxx" nKillChar($cf); "

	print("Coeffs: ")
	C = nInitChar( n, p )
	println(C);
	print("Singular coeffs output: ")
	n_CoeffWrite(C)

	z = n_Init(i, C )
	print("Number out of $i: ")
	println(z);

	print("Singular number output: ")
	n_Print(z, C)
	println();

	ii = n_Int(z, C)
 	ch = n_GetChar(C)

	@test ((ch == 0) && (i == ii)) || ((ch > 0) && ((i - ii) % ch == 0))

	n_Delete(z, C)

	print("Deleted number: ")
	println(z);
		
        println("\n...PASS")
   end	  

   println("PASS")

cxx"""
static n_coeffType get_Q() { return n_Q; };
static n_coeffType get_Z() { return n_Z; };
static n_coeffType get_Zp(){ return n_Zp; }; // n_coeffType.
"""

   const n_Zp = @cxx get_Zp() #  # get_Zp() = icxx" return n_Zp; "
   const n_Q  = @cxx get_Q() # Cxx.CppEnum{:n_coeffType}(2) # icxx" return n_Q; "
   const n_Z  = @cxx get_Z() # Cxx.CppEnum{:n_coeffType}(9) # icxx" return n_Z; "

   @test n_Zp == Cxx.CppEnum{:n_coeffType}(1)
   @test n_Q == Cxx.CppEnum{:n_coeffType}(2)
   @test n_Z == Cxx.CppEnum{:n_coeffType}(9)

   # q = 66 in QQ
   jtest_coeffs( n_Q, 0, 66)#   @cxx test_coeffs( n_Q, Ptr{Void}(0), 66) 

   ## z = 666 in ZZ
   jtest_coeffs( n_Z, 0, 666) #   @cxx test_coeffs( n_Z, Ptr{Void}(0), 666) 

   ## zz = 6 in Zp{11}
   jtest_coeffs( n_Zp, 11, 11*3 + 6) #   @cxx test_coeffs( n_Zp, Ptr{Void}(11), 11*3 + 6) 

end
