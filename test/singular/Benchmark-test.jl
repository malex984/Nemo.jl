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
   x = gen(U, 1);   y = gen(U, 2);   z = gen(U, 3);
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
   @time p = (x + y + z + t + 1)^13 # 20

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
   x = gen(V, 1);   y = gen(V, 2);   z = gen(V, 3); t = gen(V, 4);

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

   f = (x + y + 2z^2 + 3t^3 + 5u^5 + 1)^6 # *= f
   g = (u + t + 2z^2 + 3y^3 + 5x^5 + 1)^6 # *= g

   println(length(f))
   println(length(g))

   @time q = f*g
#   @test length(q) == 61

### Real thing ^ 16 :( ^10 is already tooo long with SingularPolys :( 

   gc()
   println("..........................................'PASS'")

end

function test_singular_det_poly_benchmark_flint_vs_singular()
   print("Matrix.clow_determinant of poly rings: Singular vs Flint...")

   const maxD = 8;
   const maxK = div(maxD * maxD + 1, 2);

   # Flint & Singular both work over Z/2Z:
   p = 2;
   CF_F = ResidueRing(Nemo.FlintZZ, p);
   CF_S = Nemo.SingularZp(p);


   VV = Array(Nemo.RingElem, maxK); # Flint variables...

   k = 1;
   s = "x($k)";
   FF, VV[1] = PolynomialRing(CF_F, s);

   for dim = 2:3:maxD   
      const K = div(dim*dim + 1, 2);

      println(); println("dim: $dim, k: $k, K: $K");

      for i = (k+1):K
      	  const _s = "x($i)";
	  s = s * "," * _s;
	  FF, VV[i] = PolynomialRing(FF, _s);

	  for j = 1:(i-1)
	      VV[j] = FF(VV[j]); # TODO: For **each** new FF??
	  end
      end

      SS, last = SingularPolynomialRing(CF_S, s, :lex); # L(K)?
      println(SS);

      MMS = MatrixSpace(SS, dim, dim)();
      MMF = MatrixSpace(FF, dim, dim)();

      for j = 1:3 # dim
      	  println("Try $j / $dim @ [$dim x $dim]: ")
	  
	  for r = 1:dim; for c = 1:dim; MMF[r,c] = zero(FF); MMS[r,c] = zero(SS); end; end;

      	  i = 1;
	  while (i <= K)
              r = rand(1:dim); c = rand(1:dim);

	      if iszero(MMS[r,c])
                  @assert iszero(MMF[r,c])

             	  MMF[r,c] = VV[i];
             	  MMS[r,c] = gen(SS, i);

             	  i += 1;
              end
      	  end

	  println("Random Matrix (50%-vars): ");

	  println()
      	  println(MMS);
#      	  println(MMF);
	  println()

      	  println("Singular: Nemo.determinant_clow(MMS)... ")
      	  @time d_s = Nemo.determinant_clow(MMS)
#      	  println("Nemo.determinant_clow(MMS): ", d_s)

      	  println("Flint: Nemo.determinant_clow(MMF)...")
          @time d_f = Nemo.determinant_clow(MMF);
#          println("Nemo.determinant_clow(MMF): ", d_f)

	  println()
      end

      k = K;
   end

   println("PASS..?")
   

end


function test_benchmarks_singular()

   test_singular_det_poly_benchmark_flint_vs_singular()

#====================================================================#

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

#====================================================================#

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

#====================================================================#

   CF_F = Nemo.FlintZZ;
   CF_S = Nemo.SingularZZ();


   println("Testing Rings over Integers: ");

   Nemo.libSingular.omPrintInfoStats()
   test_benchmark_pearce_singular(CF_F, CF_S)

   println("")
   Nemo.libSingular.omPrintInfoStats()
   println("")

   test_benchmark_fateman_singular(CF_F, CF_S)

   Nemo.libSingular.omPrintInfoStats()
   println("")

#====================================================================#

   Nemo.libSingular.omPrintInfoStats(); println("")


###   test_benchmark_resultant_singular() # ERROR: `start` has no method matching start(::Nemo.CoeffsField) ???
   println("")
end
