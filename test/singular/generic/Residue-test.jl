function test_residue_constructors_singular()
   print("Residue.constructors / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
 
   R = ResidueRing(ZZ, ZZ(16453889))

   @test isa(R, ResidueRing)

   a = R(123)

   @test isa(a, ResidueElem)

   b = R(a)

   @test isa(b, ResidueElem)

   c = R(ZZ(12))

   @test isa(c, ResidueElem)

   d = R()

   @test isa(d, ResidueElem)

   S, x = PolynomialRing(R, "x")
   T = ResidueRing(S, x^3 + 3x + 1)

   @test isa(T, ResidueRing)

   f = T(x^4)

   @test isa(f, ResidueElem)

   g = T(f)

   @test isa(g, ResidueElem)

   println("PASS")
end

function test_residue_manipulation_singular()
   print("Residue.manipulation / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
 
   R = ResidueRing(ZZ, ZZ(16453889))

   @test modulus(R) == 16453889

   g = zero(R)

   @test iszero(g)

   @test modulus(g) == 16453889

   S, x = PolynomialRing(R, "x")
   T = ResidueRing(S, x^3 + 3x + 1)

   h = one(T)

   @test isunit(h)

   @test isone(h)

   @test data(h) == 1

   @test canonical_unit(R(11)) == R(11)
   
   @test canonical_unit(T(x + 1)) == T(x + 1)

   @test deepcopy(h) == h

   println("PASS")
end

function test_residue_unary_ops_singular()
   print("Residue.unary_ops / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
 
   R = ResidueRing(ZZ, ZZ(16453889))

   @test -R(12345) == R(16441544)

   S, x = PolynomialRing(R, "x")
   T = ResidueRing(S, x^3 + 3x + 1)

   @test -T(x^5 + 1) == T(x^2+16453880*x+16453885)

   println("PASS")
end

function test_residue_binary_ops_singular()
   print("Residue.binary_ops / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
 
   R = ResidueRing(ZZ, ZZ(12))

   f = R(4)
   g = R(6)

   @test f + g == R(10)

   @test f - g == R(10)

   @test f*g == R(0)

   Q = ResidueRing(ZZ, ZZ(7))
   S, x = PolynomialRing(Q, "x")
   T = ResidueRing(S, x^3 + 3x + 1)

   n = T(x^5 + 1)
   p = T(x^2 + 2x + 1)

   @test n + p == T(4x + 5)

   @test n - p == T(5x^2 + 3)

   @test n*p == T(3x^2 + 4x + 4)

   println("PASS")
end

function test_residue_gcd_singular()
   print("Residue.gcd / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
 
   R = ResidueRing(ZZ, ZZ(12))

   f = R(4)
   g = R(6)

   @test gcd(f, g) == R(2)

   Q = ResidueRing(ZZ, ZZ(7))
   S, x = PolynomialRing(Q, "x")
   T = ResidueRing(S, x^3 + 3x + 1)

   n = T(x^5 + 1)
   p = T(x^2 + 2x + 1)

   @test gcd(n, p) == 1

   println("PASS")
end

function test_residue_adhoc_binary_singular()
   print("Residue.adhoc_binary / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
 
   R = ResidueRing(ZZ, ZZ(7))

   a = R(3)

   @test a + 3 == R(6)

   @test 3 - a == R(0)

   @test 5a == R(1)

   S, x = PolynomialRing(R, "x")
   T = ResidueRing(S, x^3 + 3x + 1)

   f = T(x^5 + 1)

   @test f + 4 == T(x^5 + 5)

   @test 4 - f == T(x^2+5*x)

   @test f*5 == T(2*x^2+3*x+6)

   println("PASS")
end

function test_residue_comparison_singular()
   print("Residue.comparison / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
 
   R = ResidueRing(ZZ, ZZ(7))

   a = R(3)
   b = a
   c = R(2)

   @test b == a

   @test isequal(b, a)

   @test c != a

   S, x = PolynomialRing(R, "x")
   T = ResidueRing(S, x^3 + 3x + 1)

   f = T(x^5 + 1)
   g = 8f
   h = f + g

   @test f == g
   @test h != g

   @test isequal(f, g)

   println("PASS")
end

function test_residue_adhoc_comparison_singular()
   print("Residue.adhoc_comparison / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
 
   R = ResidueRing(ZZ, ZZ(7))

   a = R(3)

   @test a == 3
   @test 4 != a

   S, x = PolynomialRing(R, "x")
   T = ResidueRing(S, x^3 + 3x + 1)

   f = T(x^5 + 1)

   @test f != 5

   println("PASS")
end

function test_residue_powering_singular()
   print("Residue.powering / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
 
   R = ResidueRing(ZZ, ZZ(7))

   a = R(3)

   @test a^5 == 5

   S, x = PolynomialRing(R, "x")
   T = ResidueRing(S, x^3 + 3x + 1)

   f = T(x^5 + 1)

   @test f^100 == T(x^2 + 2x + 1)

   println("PASS")
end

function test_residue_inversion_singular()
   print("Residue.inversion / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
 
   R = ResidueRing(ZZ, ZZ(49))

   a = R(5)

   @test inv(a) == 10

   R = ResidueRing(ZZ, ZZ(41))
   S, x = PolynomialRing(R, "x")
   T = ResidueRing(S, x^3 + 3x + 1)

   f = T(x^5 + 1)

   @test inv(f) == T(26*x^2+31*x+10)

   println("PASS")
end

function test_residue_exact_division_singular()
   print("Residue.exact_division / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
 
   R = ResidueRing(ZZ, ZZ(49))

   a = R(5)
   b = R(3)

   @test divexact(a, b) == 18

   R = ResidueRing(ZZ, ZZ(41))
   S, x = PolynomialRing(R, "x")
   T = ResidueRing(S, x^3 + 3x + 1)

   f = T(x^5 + 1)
   g = T(x^4 + x + 2)

   @test divexact(f, g) == T(7*x^2+25*x+26)

   println("PASS")
end

function test_residue_singular()
   test_residue_constructors_singular()
   test_residue_manipulation_singular()
   test_residue_unary_ops_singular()
   test_residue_binary_ops_singular()
   test_residue_gcd_singular()
   test_residue_adhoc_binary_singular()
   test_residue_comparison_singular()
   test_residue_adhoc_comparison_singular()
   test_residue_powering_singular()
   test_residue_inversion_singular()
   test_residue_exact_division_singular()

   println("")
end
