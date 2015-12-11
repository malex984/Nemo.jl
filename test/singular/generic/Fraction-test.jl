function test_fraction_constructors_singular()
   print("Fraction.constructors / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();

   S, x = PolynomialRing(ZZ, "x")
   T = FractionField(S)

   @test isa(T, FractionField)

   @test isa(T(3), FractionElem)

   @test isa(T(fmpz(7)), FractionElem)

   @test isa(T(x + 2), FractionElem)

   @test isa(T(3, 7), FractionElem)

   @test isa(T(x + 2, x + 1), FractionElem)

   @test isa(T(x + 2, 4), FractionElem)

   @test isa(T(3, x + 1), FractionElem)

   @test isa(T(T(x + 2)), FractionElem)

   @test isa(T(), FractionElem)

   @test isa((x + 3)//(x^2 + 2), FractionElem)

   @test isa((x + 3)//12, FractionElem)

   @test isa(12//(x + 2), FractionElem)

   @test isa((x + 1)//T(x + 2, x + 1), FractionElem)

   @test isa(T(x + 2, x + 1)//(x + 1), FractionElem)

   @test isa(T(x + 2, x + 1)//T(x, x + 2), FractionElem) 

   println("PASS")
end

function test_fraction_manipulation_singular()
   print("Fraction.manipulation / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();

   R = FractionField(ZZ)
   S, x = PolynomialRing(ZZ, "x")

   @test den((x + 1)//(-x^2 + 1)) == x - 1

   @test num((x + 1)//(-x^2 + 1)) == -1

   @test iszero(zero(R))

   @test isone(one(S))

   @test canonical_unit((x + 1)//(-x^2 + 1)) == -1//(x-1)

   @test isunit((x + 1)//(-x^2 + 1))

   @test deepcopy((x + 1)//(-x^2 + 1)) == (x + 1)//(-x^2 + 1)
   println("PASS")
end

function test_fraction_unary_ops_singular()
   print("Fraction.unary_ops / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();

   S, x = PolynomialRing(ZZ, "x")

   @test -((x + 1)//(-x^2 + 1)) == 1//(x - 1)

   println("PASS")
end

function test_fraction_binary_ops_singular()
   print("Fraction.binary_ops / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();

   S, x = PolynomialRing(ZZ, "x")

   a = -(x + 3)//(x + 1) + (2x + 3)//(x^2 + 4)
   b = (x + 1)//(-x^2 + 1) - x//(2x + 1)
   c = ((x^2 + 3x)//(5x))*((x + 1)//(2x^2 + 2))

   @test a == (-x^3-x^2+x-9)//(x^3+x^2+4*x+4)

   @test b == (-x^2-x-1)//(2*x^2-x-1)

   @test c == (x^2+4*x+3)//(10*x^2+10)

   println("PASS")
end

function test_fraction_adhoc_binary_singular()
   print("Fraction.adhoc_binary / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();

   S, x = PolynomialRing(ZZ, "x")

   a = (-x + 1)//(2x^2 + 3)
   b = (x + 1)//(-x^2 + 1)

   @test a + 2 == (4*x^2-x+7)//(2*x^2+3)

   @test a - 2 == (-4*x^2-x-5)//(2*x^2+3)

   @test 3 + a == (6*x^2-x+10)//(2*x^2+3)

   @test 3 - a == (6*x^2+x+8)//(2*x^2+3)

   @test b*(x + 1) == (-x-1)//(x-1)

   @test (x + 1)*b == (-x-1)//(x-1)

   println("PASS")
end

function test_fraction_comparison_singular()
   print("Fraction.comparison / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();

   S, x = PolynomialRing(ZZ, "x")

   a = -((x + 1)//(-x^2 + 1))

   @test a == 1//(x - 1)

   @test isequal(a, 1//(x - 1))

   println("PASS")
end

function test_fraction_adhoc_comparison_singular()
   print("Fraction.adhoc_comparison / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();

   S, x = PolynomialRing(ZZ, "x")

   a = 1//(x - 1)

   @test 1//a == x - 1

   @test x - 1 == 1//a

   @test one(S) == 1

   @test 1 == one(S)

   println("PASS")
end

function test_fraction_powering_singular()
   print("Fraction.powering() / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();

   S, x = PolynomialRing(ZZ, "x")

   a = (x + 1)//(-x^2 + 1)

   @test a^-12 == x^12-12*x^11+66*x^10-220*x^9+495*x^8-792*x^7+924*x^6-792*x^5+495*x^4-220*x^3+66*x^2-12*x+1

   println("PASS")
end

function test_fraction_inversion_singular()
   print("Fraction.inversion() / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();

   S, x = PolynomialRing(ZZ, "x")

   a = (x + 1)//(-x^2 + 1)

   @test inv(a) == -x + 1

   println("PASS")
end

function test_fraction_exact_division_singular()
   print("Fraction.exact_division / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();

   S, x = PolynomialRing(ZZ, "x")

   a = -(x + 3)//(x + 1) + (2x + 3)//(x^2 + 4)
   b = ((x^2 + 3x)//(5x))*((x + 1)//(2x^2 + 2))

   @test a//b == (-10*x^5-10*x^4-100*x^2+10*x-90)//(x^5+5*x^4+11*x^3+23*x^2+28*x+12)

   println("PASS")
end

function test_fraction_adhoc_exact_division_singular()
   print("Fraction.adhoc_exact_division / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();

   S, x = PolynomialRing(ZZ, "x")

   a = (-x + 1)//(2x^2 + 3)
   b = (x + 1)//(-x^2 + 1)

   @test a//5 == (-x+1)//(10*x^2+15)

   @test a//(x + 1) == (-x+1)//(2*x^3+2*x^2+3*x+3)

   @test (x + 1)//b == -x^2+1

   @test 5//a == (-10*x^2-15)//(x-1)

   println("PASS")
end

function test_fraction_gcd_singular()
   print("Fraction.gcd / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();

   S, x = PolynomialRing(ZZ, "x")

   a = (x + 1)//(-x^2 + 1) - x//(2x + 1)
   
   @test gcd(a, (x + 1)//(x - 1)) == 1//(2*x^2-x-1)

   println("PASS")
end

function test_fraction_singular()
   test_fraction_constructors_singular()
   test_fraction_manipulation_singular()
   test_fraction_unary_ops_singular()
   test_fraction_binary_ops_singular()
   test_fraction_adhoc_binary_singular()
   test_fraction_comparison_singular()
   test_fraction_adhoc_comparison_singular()
   test_fraction_powering_singular()
   test_fraction_inversion_singular()
   test_fraction_exact_division_singular()
   test_fraction_adhoc_exact_division_singular()
   test_fraction_gcd_singular()

   println("")
end
