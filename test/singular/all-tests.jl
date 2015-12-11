using Base.Test
using Cxx

include("generic/Fraction-test.jl")
include("generic/Residue-test.jl")
include("generic/Poly-test.jl")
include("generic/Matrix-test.jl")
include("generic/PowerSeries-test.jl")
include("Benchmark-test.jl")

#include("flint/fmpz-test.jl")
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

#   test_fmpz()
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

function test_singular_wrappers()
   println("Printing Singular resources pathes...")  
   Nemo.libSingular.PrintResources("Singular Resources info: ")
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


function _mullow{T <: Nemo.SingularRingElem}(a::PolyElem{T}, b::PolyElem{T}, n::Int)
   check_parent(a, b)
   lena = length(a)
   lenb = length(b)

   if lena == 0 || lenb == 0
      return zero(parent(a))
   end

   if n < 0
      n = 0
   end

   lenz = min(lena + lenb - 1, n)

   d = Array(T, lenz)

   for i = 1:min(lena, lenz)
      d[i] = coeff(a, i - 1)*coeff(b, 0)
   end

   if lenz > lena
      for j = 2:min(lenb, lenz - lena + 1)
          d[lena + j - 1] = coeff(a, lena - 1)*coeff(b, j - 1)
      end
   end

   print("d: "); println(d);

   t = T()
   for i = 1:lena - 1
      if lenz > i
         for j = 2:min(lenb, lenz - i + 1)
	    # d[i + j - 1] += ( coeff(a, i - 1) * b.coeffs[j] =: t )

            mul!(t, coeff(a, i - 1), b.coeffs[j]) #??!
            addeq!(d[i + j - 1], t)#??
         end
      end
   end
     
   z = parent(a)(d)
   
   set_length!(z, normalise(z, lenz))

   return z
end


function _pow_multinomial{T <: Nemo.SingularRingElem}(a::PolyElem{T}, e::Int)
   e < 0 && throw(DomainError())
   lena = length(a)
   lenz = (lena - 1) * e + 1
   res = Array(T, lenz)
   for k = 1:lenz
      res[k] = base_ring(a)()
   end
   d = base_ring(a)()
   first = coeff(a, 0)
   res[1] = first ^ e
   for k = 1 : lenz - 1
      u = -k
      for i = 1 : min(k, lena - 1)
         t = coeff(a, i) * res[(k - i) + 1]
         u += e + 1
         addeq!(res[k + 1], t * u) ## !!!
      end
      addeq!(d, first) ## !!!
      res[k + 1] = divexact(res[k + 1], d) ## ?????!
   end
   z = parent(a)(res)
   set_length!(z, normalise(z, lenz))
   return z
end

function ^{T <: Nemo.SingularCoeffsElems}(a::PolyElem{T}, b::Int)
   b < 0 && throw(DomainError())
   # special case powers of x for constructing polynomials efficiently
   if isgen(a)
      d = Array(T, b + 1)
      d[b + 1] = coeff(a, 1)
      for i = 1:b
         d[i] = coeff(a, 0)
      end
      z = parent(a)(d)
      set_length!(z, b + 1)
      return z
   elseif length(a) == 0
      return zero(parent(a))
   elseif length(a) == 1
      return parent(a)(coeff(a, 0)^b)
   elseif b == 0
      return one(parent(a))
   else
#      if T <: SingularFieldElem
#         zn = 0
#         while iszero(coeff(a, zn))
#            zn += 1
#         end
#         if length(a) - zn < 8 && b > 4
#             f = shift_right(a, zn)
#             return shift_left(_pow_multinomial(f, b), zn*b)  ### BUG ???
#         end
#      end
      bit = ~((~UInt(0)) >> 1)
      while (UInt(bit) & b) == 0
         bit >>= 1
      end
      z = a
      bit >>= 1
      while bit != 0
         z = z*z
         if (UInt(bit) & b) != 0
            z *= a
         end
         bit >>= 1
      end
      return z
   end
end

function test_generic_polys(C::Nemo.SingularCoeffs)
   println("test_generic_polys for 'C'...")
   println("C: ", C)

   println("C(0): ", C(0))
   println("zero(C): ", zero(0))

   print("R = C[x].... "); 

   R, x = _PolynomialRing(C, "x")

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

	@test z == C(nn)

##	Nemo.n_Delete(z, C.ptr)
#	print("Deleted number: ")
#	println(z);
end	  


# TODO: untangle this mess!!!
function test_singular_lowlevel_coeffs()

#   print("Wrapping libSingular constants/functions with Cxx/Julia...\n")  

   const ZZ = Nemo.SingularZZ();
   const Z11 = Nemo.SingularZp(11);
   const QQ = Nemo.SingularQQ();

   print("SingularZZ: $ZZ, SingularQQ: $QQ, SingularZ11: $Z11...")
   println("PASS")


### TODO: separate creation for Coeffs & pass them into jtest_coeffs instead!

   ## z = 666 in ZZ
   jtest_coeffs(ZZ, 666) 

   ## zz = 6 in Zp{11}
   jtest_coeffs(Z11, 11*3 + 6) 

   # q = 66 in QQ
   jtest_coeffs(QQ, 66)

   test_generic_polys(ZZ)

   test_generic_polys(QQ)

   test_generic_polys(Z11)
end


function test_singular_polynomial_rings()
   print("Constructing/showing/deleting Singular rings via Cxx...")

##TODO## icxx" char* n [] = { (char*)\"t\"}; ring r = rDefault( 13, 1, n); rWrite(r); PrintLn(); rDelete(r); "

cxx"""
ring test_contruct_ring()
{
  char* n [] = { (char*)\"t\"}; 
  ring r = rDefault( 13, 1, n); 
  PrintLn(); rWrite(r, 1); 
  PrintLn(); 
  return (r);
}
"""
   r = @cxx test_contruct_ring()

   println(r, string(r))
   @cxx rDelete(r)
   println("PASS")

   print("Constructing Singular Polynomial Ring over native coeffs...\n")  

   const ZZ = Nemo.SingularZZ();
   RZ = Nemo.PRing(ZZ, "x, y"); # just testing ATM!

   print("_ Over Singular Integer Ring [", string(ZZ), "]: ", string(RZ))
   # @test parent(RZ) == ZZ # ?
   println("...PASS")

   const QQ = Nemo.SingularQQ();
   RQ = Nemo.PRing(QQ, "x, y"); # just testing ATM!

   print("_ Over Singular Rational Field [", QQ, "]: ", string(RQ))
   # @test parent(RQ) == QQ # ?
   println("...PASS")

end



function test_singular()
   println()
   test_benchmarks_singular()

   println()
   test_fraction_singular()

   println()
   test_residue_singular()

   println()
   test_matrix_singular()

   println()
   test_series_singular()

   println()
   test_singular_wrappers()

   println()
   test_singular_lowlevel_coeffs()

   println()
   test_singular_polynomial_rings()

   # generic polynomials over SingularZZ() & sometimes over SingularQQ()...
   println()
   test_poly_singular()

   println()
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
#newTyp = icxx" return nRegister( n_unknown, (cfInitCharProc)$cjlInit); " 
#newCoeff = icxx" return nInitChar( $newTyp, 0 ); "

