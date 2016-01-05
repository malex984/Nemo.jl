using Base.Test
using Cxx

include("generic/Fraction-test.jl")
include("generic/Residue-test.jl") # TODO >= unary ops
include("generic/Poly-test.jl")
include("generic/Matrix-test.jl")
include("generic/PowerSeries-test.jl")
include("Benchmark-test.jl")

include("ZZ-test.jl")
include("QQ-test.jl")

function test_singular_wrappers()
   println("Printing Singular resources pathes...")  
   Nemo.libSingular.PrintResources("Singular Resources info: ")
   println("PASS")

   println("Printing Singular' omalloc info stats...")  
   Nemo.libSingular.omPrintInfoStats()
   println("PASS")
end

function _PolynomialRing(R::Nemo.Ring, s::AbstractString{})
   S = symbol(s)
   print("S: "); println(S)

   # ERROR: LoadError: TypeError: Type: in parameter, expected Type{T}, got Nemo.Coeffs
   # ERROR: LoadError: TypeError: NumberElem: in parameter, expected Type{T}, got Nemo.Coeffs
   T = Nemo.elem_type(R)
   print("T: "); println(T)

   parent_obj = Nemo.PolynomialRing{T}(R, S)
   print("parent_obj: "); println(parent_obj)

   base = Nemo.base_ring(R)
   print("base: "); println(base)

   R2 = R

   parent_type = Nemo.Poly{T}
   print("parent_type: "); println(parent_type)

   b = Nemo.base_ring(R2)
   print("b: "); println(b)

   while b != Union{}
      R2 = Nemo.base_ring(R2)
      print("R2: "); println(R2)

      T2 = Nemo.elem_type(R2)

      print("T2: "); println(T2)

      println(:(Base.promote_rule(::Type{$parent_type}, ::Type{$T2}) = $parent_type))
      eval(:(Base.promote_rule(::Type{$parent_type}, ::Type{$T2}) = $parent_type))

      b = Nemo.base_ring(R2)
      print("b: "); println(b)
   end

   print("v: ");
   v = parent_obj([R(0), R(1)]);
   println(v);

   return parent_obj, v
end





function test_generic_polys(C::Nemo.SingularCoeffs)
   println("test_generic_polys for 'C'...")
   println("C: ", C)

   print("zero(C): ")
   println(zero(C))

   print("C(0): ")
   println(C(Int(0)))

   print("R = C[x].... "); 

   R, x = PolynomialRing(C, "x")

   print("R(0): "); 
   println(R(0))

   print("zero(R): "); 
   println(zero(R))

   print("x: "); 
   println(x)

   print("C[x]: "); 
   println(R)

   ff = R(3)*x + R(1) ### ??? 
   println("ff: ", ff)

   f = x^3 + 3x - 1 ### ??? 
   print("f: ")
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

   @test g == h

   print("f*g: ")
   println(f*g)

#	if !Nemo.isring(C)  # use isa(...Field)?
#           println("C is not a RING - Field?")
###	   println("gcd: ", gcd(f, g))
#        end

   # Benchmark:
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
	   k = Nemo.gen(i, C) * k 
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


function test_singular_polynomial_ring(C)

   print("Constructing Singular Polynomial Ring over $C: \n")  

   R = Nemo.PRing(C, "x, y"); # just testing ATM!

   print("_ Over [", string(C), "]: ", string(R))
   @test base_ring(R) == C # ?

   p = one(R) * R(2) + 3 + gen(R);

   println(p, " @@ ", typeof(p))

   p = 0

   for i in 1:Int(Nemo.ngens(R))
       p += (10 * Int(i)) * Nemo.geni(Int(i), R)
   end

## TODO: FIXME: add automatic mapping K -> K[x,y,z...]!?

   println(p, " @@ ", typeof(p))

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


   test_singular_polynomial_ring(Nemo.SingularZZ())
   test_singular_polynomial_ring(Nemo.SingularQQ())

   test_singular_polynomial_ring(Nemo.SingularZp(3))
   test_singular_polynomial_ring(Nemo.SingularZp(5))
   test_singular_polynomial_ring(Nemo.SingularZp(11))

## TODO: FIXME: GF!
#   test_singular_polynomial_ring(Nemo.SingularGF(7, 1, "T")) #  // ** illegal GF-table size: 7  // ** Sorry: cannot init lookup table!??
#   test_singular_polynomial_ring(Nemo.SingularGF(3, 3, "T"))
#   test_singular_polynomial_ring(Nemo.SingularGF(5, 2, "T"))

end



function test_singular()
   println("Singular unique rings & fields will use context-less implementation, right?  ", Nemo.uq_default_choice)

   println(); gc(); test_singular_wrappers()

   println(); gc(); test_singular_polynomial_rings()

   println(); gc(); test_singular_lowlevel_coeffs()

   println(); gc(); test_ZZ_singular()

   println(); gc(); test_QQ_singular() 

   println(); gc(); test_fraction_singular()

   println(); gc(); test_residue_singular() 

   println(); gc(); test_series_singular()

   println(); gc(); test_poly_singular()

   println(); gc(); test_benchmarks_singular()

   println(); gc(); test_matrix_singular()

   println(); gc(); Nemo.libSingular.omPrintInfoStats()

   println()
end


#######################################################
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
#newTyp = icxx" return nRegister( n_unknown, (cfInitCharProc)$cjlInit); " 
#newCoeff = icxx" return nInitChar( $newTyp, 0 ); "



#include("flint/fmpz_poly-test.jl")
#include("flint/fmpz_mod_poly-test.jl")
#include("flint/nmod_poly-test.jl")
#include("flint/fmpq_poly-test.jl")
#include("flint/fq_poly-test.jl")
#include("flint/fq_nmod_poly-test.jl")
#include("flint/fmpz_series-test.jl")
#include("flint/fmpq_series-test.jl")
#include("flint/fmpz_mod_series-test.jl")
#include("flint/fq_series-test.jl")
#include("flint/fq_nmod_series-test.jl")
#include("flint/nmod_mat-test.jl")
#include("flint/fmpz_mat-test.jl")

#### TODO: remove those without analogs on Singular side!

#   test_fmpz_poly()
#   test_fmpz_mod_poly()
#   test_nmod_poly()
#   test_fmpq_poly()
#   test_fq_poly()
#   test_fq_nmod_poly()
#   test_fmpz_series()
#   test_fmpq_series()
#   test_fmpz_mod_series()
#   test_fq_series()
#   test_fq_nmod_series()
#   test_nmod_mat()
#   test_fmpz_mat()
