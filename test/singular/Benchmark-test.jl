function test_benchmark_fateman_singular(CF_F, CF_S)


########################################################
   println("Benchmark.fateman / Flint...")
   gc()


   R, x = PolynomialRing(CF_F, "x")
   S, y = PolynomialRing(R, "y")
   T, z = PolynomialRing(S, "z")
   U, t = PolynomialRing(T, "t")

   println( "Flint CF: $CF_F, types: ")
   println( typeof(CF_F), "  @    ", typeof(one(CF_F)) )
#   println( typeof(R),    "  @    ", typeof(one(R   )) )
#   println( typeof(S),    "  @    ", typeof(one(S   )) )
#   println( typeof(T),    "  @    ", typeof(one(T   )) )
   println( U, " of Julia Type: ", typeof(U),    "  @    ", typeof(one(U   )) )

   @time p = (x + y + z + t + 1)^10
   @time p == (x + y + z + t + 1)^10

   println()
   @time q = p*(p + 1)
   @test length(q) == 21

   println()
   @time p = (x + y + z + t + 1)^20
   @time q = p*(p + 1)
   @test length(q) == 41


   println("..........................................PASS")

########################################################

   println("Benchmark.fateman / Singular Coeffs...")
   gc()


   U, t = SingularPolynomialRing(CF_S, "x, y, z, t", :lex);
   x = Nemo.gen(1, U);   y = Nemo.gen(2, U);   z = Nemo.gen(3, U);
#   S, y = PolynomialRing(R, "y")
#   T, z = PolynomialRing(S, "z")
#   U, t = PolynomialRing(T, "t")

   println( "Singular CF: $CF_S, types: ")
   println( typeof(CF_S), "  @    ", typeof(one(CF_S)) )
#   println( typeof(R),    "  @    ", typeof(one(R   )) )
#   println( typeof(S),    "  @    ", typeof(one(S   )) )
#   println( typeof(T),    "  @    ", typeof(one(T   )) )
   println( U, " of Julia Type: ", typeof(U),    "  @    ", typeof(t) )

   Nemo.libSingular.omPrintInfoStats()
   println("")

   @time p = (x + y + z + t + 1)^10
   @time p == (x + y + z + t + 1)^10

   @time q = p*(p + 1)
#   @test length(q) == 21

   println()
   @time p = (x + y + z + t + 1)^20

   println(length(p))

   @time q = p*(p + 1)

#   @test length(q) == 41

# REAL Thing: p = ()^30 !?

   gc()
   println("..........................................PASS")
end

function test_benchmark_pearce_singular(CF_F, CF_S)
########################################################
   println("Benchmark.pearce / Flint...")
   gc()
 
   R, x = PolynomialRing(CF_F, "x")
   S, y = PolynomialRing(R, "y")
   T, z = PolynomialRing(S, "z")
   U, t = PolynomialRing(T, "t")
   V, u = PolynomialRing(U, "u")

   println( "Flint CF: $CF_F, types: ")
   println( typeof(CF_F), "  @    ", typeof(one(CF_F)) )
   println( typeof(R),    "  @    ", typeof(one(R   )) )
   println( typeof(S),    "  @    ", typeof(one(S   )) )
   println( typeof(T),    "  @    ", typeof(one(T   )) )
   println( typeof(U),    "  @    ", typeof(one(U   )) )
   println( V, " of Julia Type: ", typeof(V),    "  @    ", typeof(one(V   )) )

   f = (x + y + 2z^2 + 3t^3 + 5u^5 + 1)^5
   g = (u + t + 2z^2 + 3y^3 + 5x^5 + 1)^5 

   @time q = f*g
   @time q == f*g
   @test length(q) == 31

   println()

   
   f *= f # (x + y + 2z^2 + 3t^3 + 5u^5 + 1)^10
   g *= g # (u + t + 2z^2 + 3y^3 + 5x^5 + 1)^10 

   println(length(f))
   println(length(g))

   @time q = f*g
   @test length(q) == 61

   println("..........................................PASS")

########################################################

   gc()

   println("Benchmark.pearce / Singular Coeffs...")

   V, u = SingularPolynomialRing(CF_S, "x, y, z, t, u", :lex);
   x = Nemo.geni(1, V);   y = Nemo.geni(2, V);   z = Nemo.geni(3, V); t = Nemo.geni(4, V);

#   R, x = PolynomialRing(CF_S, "x")
#   S, y = PolynomialRing(R, "y")
#   T, z = PolynomialRing(S, "z")
#   U, t = PolynomialRing(S, "t") # T
#   V, u = PolynomialRing(U, "u")

   println( "Singular CF: $CF_S, types: ")
   println( typeof(CF_S), "  @    ", typeof(one(CF_S)) )
#   println( typeof(R),    "  @    ", typeof(one(R   )) )
#   println( typeof(S),    "  @    ", typeof(one(S   )) )
#   println( typeof(T),    "  @    ", typeof(one(T   )) )
#   println( typeof(U),    "  @    ", typeof(one(U   )) )
   println( V, " of Julia Type: ", typeof(V),    "  @    ", typeof(u) )

   Nemo.libSingular.omPrintInfoStats()
   println("")

   f = (x + y + 2z^2 + 3t^3 + 5u^5 + 1)^5
   g = (u + t + 2z^2 + 3y^3 + 5x^5 + 1)^5 

   @time q = f*g
   @time q == f*g
#   @test length(q) == 31

   println()

   f *= f # (x + y + 2z^2 + 3t^3 + 5u^5 + 1)^7
   g *= g # (u + t + 2z^2 + 3y^3 + 5x^5 + 1)^7 

   println(length(f))
   println(length(g))

   @time q = f*g
#   @test length(q) == 61

### Real thing ^ 16 - tooo long with Singular :( 

   gc()
   println("..........................................'PASS'")

end

function test_benchmark_resultant_singular()
   println("Benchmark.resultant / Flint...")
 
   # FiniteField(7, 11, "x") # ???
   R, x = FiniteField(7, 3, "x") # // ** Sorry: illegal size: 7 ^ 11
   S, y = PolynomialRing(R, "y")
   T = ResidueRing(S, y^3 + 3x*y + 1)
   U, z = PolynomialRing(T, "z")

   f = (3y^2 + y + x)*z^2 + ((x + 2)*y^2 + x + 1)*z + 4x*y + 3
   g = (7y^2 - y + 2x + 7)*z^2 + (3y^2 + 4x + 1)*z + (2x + 1)*y + 1

   @time r = resultant(f^2, (s+g)^2)
   @time r = resultant(f^2, (s+g)^2)
   println(length(r))

   s = f^10
   t = (s + g)^10
   
   @time r = resultant(s, t)
   println(length(r))

#    @test r == (x^10+4*x^8+6*x^7+3*x^6+4*x^5+x^4+6*x^3+5*x^2+x)*y^2+(5*x^10+x^8+4*x^7+3*x^5+5*x^4+3*x^3+x^2+x+6)*y+(2*x^10+6*x^9+5*x^8+5*x^7+x^6+6*x^5+5*x^4+4*x^3+x+3)

### Real thing: 7->17:

   R, x = Nemo.FiniteField(17, 3, "x"); # FiniteField(7, 11, "x")
   S, y = PolynomialRing(R, "y")
   T = ResidueRing(S, y^3 + 3x*y + 1)
   U, z = PolynomialRing(T, "z")

#   Nemo.libSingular.omPrintInfoStats() #   println("")

   f = (3y^2 + y + x)*z^2 + ((x + 2)*y^2 + x + 1)*z + 4x*y + 3
   g = (7y^2 - y + 2x + 7)*z^2 + (3y^2 + 4x + 1)*z + (2x + 1)*y + 1

   s = f^2
   t = (s + g)^2

   @time r = resultant(s, t)
   @time r = resultant(s, t)
   println(length(r))

#   s = f^12
#   t = (s + g)^12
#  
#   @time r = resultant(s, t)

   println("PASS")
end


function test_benchmarks_singular()

   CF_F = Nemo.FlintZZ;
   CF_S = Nemo.SingularZZ();

   p = 32003;
   CF_F = ResidueRing(Nemo.FlintZZ, p);
   CF_S = Nemo.SingularZp(p); ## ???

   println("Testing Rings over Zp: ");

   Nemo.libSingular.omPrintInfoStats()
   test_benchmark_pearce_singular(CF_F, CF_S)

   println("")
   Nemo.libSingular.omPrintInfoStats()
   println("")

   test_benchmark_fateman_singular(CF_F, CF_S)
   Nemo.libSingular.omPrintInfoStats()
   println("")


   CF_F = Nemo.FlintQQ;
   CF_S = Nemo.SingularQQ();

   println("Testing Rings over Rationals: ");

   Nemo.libSingular.omPrintInfoStats()
   test_benchmark_pearce_singular(CF_F, CF_S)

   println("")
   Nemo.libSingular.omPrintInfoStats()
   println("")

   test_benchmark_fateman_singular(CF_F, CF_S)
   Nemo.libSingular.omPrintInfoStats()
   println("")





   println("Testing Rings over Integers: ");

   Nemo.libSingular.omPrintInfoStats()
   test_benchmark_pearce_singular(CF_F, CF_S)

   println("")
   Nemo.libSingular.omPrintInfoStats()
   println("")

   test_benchmark_fateman_singular(CF_F, CF_S)
   Nemo.libSingular.omPrintInfoStats()
   println("")



###   test_benchmark_resultant_singular() # ERROR: `start` has no method matching start(::Nemo.CoeffsField) ???
   println("")
end

#   test_benchmark_poly_nf_elem_singular() # No Singular analog for CyclotomicField???!
