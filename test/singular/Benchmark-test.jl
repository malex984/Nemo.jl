function test_benchmark_fateman_singular()

########################################################
   println("Benchmark.fateman / Flint ZZ...")
 
   R, x = PolynomialRing(Nemo.FlintZZ, "x")
   S, y = PolynomialRing(R, "y")
   T, z = PolynomialRing(S, "z")
   U, t = PolynomialRing(T, "t")

   @time p = (x + y + z + t + 1)^10
   @time p = (x + y + z + t + 1)^10

   println()
   @time q = p*(p + 1)
   @test length(q) == 21

   println()
   @time p = (x + y + z + t + 1)^20
   @time q = p*(p + 1)
   @test length(q) == 41


   println("..........................................PASS")

########################################################

   println("Benchmark.fateman / Singular ZZ...")

   R, x = PolynomialRing(Nemo.SingularZZ(), "x")
   S, y = PolynomialRing(R, "y")
   T, z = PolynomialRing(S, "z")
   U, t = PolynomialRing(T, "t")

   @time p = (x + y + z + t + 1)^10
   @time p = (x + y + z + t + 1)^10

   println()
   @time q = p*(p + 1)
   @test length(q) == 21

   println()
   @time p = (x + y + z + t + 1)^20
   @time q = p*(p + 1)
   @test length(q) == 41
# REAL Thing: p = ()^30 !?

   println("..........................................PASS")
end

function test_benchmark_pearce_singular()

########################################################
   println("Benchmark.pearce / Flint ZZ...")
 
   R, x = PolynomialRing(Nemo.FlintZZ, "x")
   S, y = PolynomialRing(R, "y")
   T, z = PolynomialRing(S, "z")
   U, t = PolynomialRing(T, "t")
   V, u = PolynomialRing(U, "u")

   f = (x + y + 2z^2 + 3t^3 + 5u^5 + 1)^5
   g = (u + t + 2z^2 + 3y^3 + 5x^5 + 1)^5 

   @time q = f*g
   @time q = f*g
   @test length(q) == 31

   println()

   f = f * f # (x + y + 2z^2 + 3t^3 + 5u^5 + 1)^10
   g = g * g # (u + t + 2z^2 + 3y^3 + 5x^5 + 1)^10 

   @time q = f*g
   @test length(q) == 61

   println("..........................................PASS")

########################################################

   println("Benchmark.pearce / Singular Coeffs...")

   R, x = PolynomialRing(Nemo.SingularZZ(), "x")
   S, y = PolynomialRing(R, "y")
   T, z = PolynomialRing(S, "z")
   U, t = PolynomialRing(T, "t")
   V, u = PolynomialRing(U, "u")

   f = (x + y + 2z^2 + 3t^3 + 5u^5 + 1)^5
   g = (u + t + 2z^2 + 3y^3 + 5x^5 + 1)^5 

   @time q = f*g
   @time q = f*g
   @test length(q) == 31

   println()

   f = f * f # (x + y + 2z^2 + 3t^3 + 5u^5 + 1)^10
   g = g * g # (u + t + 2z^2 + 3y^3 + 5x^5 + 1)^10 

   @time q = f*g
   @test length(q) == 61

### Real thing ^ 16 - tooo long with Singular :( 

   println("..........................................PASS")
end

function test_benchmark_resultant_singular()
   println("Benchmark.resultant / Singular Coeffs...")
 
   # FiniteField(7, 11, "x") # ???
   R, x = Nemo.SingularGF(7, 3, "x") # // ** Sorry: illegal size: 7 ^ 11
   S, y = PolynomialRing(R, "y")
   T = ResidueRing(S, y^3 + 3x*y + 1)
   U, z = PolynomialRing(T, "z")

   f = (3y^2 + y + x)*z^2 + ((x + 2)*y^2 + x + 1)*z + 4x*y + 3
   g = (7y^2 - y + 2x + 7)*z^2 + (3y^2 + 4x + 1)*z + (2x + 1)*y + 1

   @time r = resultant(f^2, (s+g)^2)

   s = f^12
   t = (s + g)^12
   
   @time r = resultant(s, t)
#    @test r == (x^10+4*x^8+6*x^7+3*x^6+4*x^5+x^4+6*x^3+5*x^2+x)*y^2+(5*x^10+x^8+4*x^7+3*x^5+5*x^4+3*x^3+x^2+x+6)*y+(2*x^10+6*x^9+5*x^8+5*x^7+x^6+6*x^5+5*x^4+4*x^3+x+3)

### Real thing: 7->17:

   R, x = Nemo.SingularGF(17, 3, "x"); # FiniteField(7, 11, "x")
   S, y = PolynomialRing(R, "y")
   T = ResidueRing(S, y^3 + 3x*y + 1)
   U, z = PolynomialRing(T, "z")

   f = (3y^2 + y + x)*z^2 + ((x + 2)*y^2 + x + 1)*z + 4x*y + 3
   g = (7y^2 - y + 2x + 7)*z^2 + (3y^2 + 4x + 1)*z + (2x + 1)*y + 1

   @time r = resultant(f^2, (s+g)^2)

   s = f^12
   t = (s + g)^12
   
   @time r = resultant(s, t)


   println("PASS")
end


function test_benchmarks_singular()
   test_benchmark_pearce_singular()
   test_benchmark_fateman_singular()
   test_benchmark_resultant_singular()

   println("")
end

#   test_benchmark_poly_nf_elem_singular() # No Singular analog for CyclotomicField???!
