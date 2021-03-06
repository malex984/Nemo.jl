function test_nf_elem_constructors()
   print("nf_elem.constructors...")
 
   R, x = PolynomialRing(QQ, "x")
   K, a = NumberField(x^3 + 3x + 1, "a")

   @test isa(K, AnticNumberField)

   a = K(123)

   @test isa(a, NumberFieldElem)

   b = K(a)

   @test isa(b, NumberFieldElem)

   c = K(fmpz(12))

   @test isa(c, NumberFieldElem)

   d = K()

   @test isa(d, NumberFieldElem)

   f = K(fmpq(2, 3))

   @test isa(f, NumberFieldElem)

   g = K(x^2 + 2x - 7)

   @test isa(g, NumberFieldElem)

   println("PASS")
end

function test_nf_elem_conversions()
   print("nf_elem.conversions...")
 
   R, x = PolynomialRing(QQ, "x")
   K, a = NumberField(x^3 + 3x + 1, "a")

   f = x^2 + 2x - 7

   @test R(K(f)) == f

   println("PASS")
end

function test_nf_elem_manipulation()
   print("nf_elem.manipulation...")
 
   R, x = PolynomialRing(QQ, "x")
   K, a = NumberField(x^3 + 3x + 1, "a")

   d = K(x^2 + 2x - 7)

   @test iszero(zero(K))
   @test isone(one(K))
   @test isgen(gen(K))

   @test deepcopy(d) == d

   @test coeff(d, 1) == 2
   @test coeff(d, 3) == 0

   @test degree(K) == 3

   println("PASS")
end

function test_nf_elem_unary_ops()
   print("nf_elem.unary_ops...")
 
   R, x = PolynomialRing(QQ, "x")
   K, a = NumberField(x^3 + 3x + 1, "a")

   d = a^2 + 2a - 7

   @test -d == -a^2 - 2a + 7

   println("PASS")
end

function test_nf_elem_binary_ops()
   print("nf_elem.binary_ops...")
 
   R, x = PolynomialRing(QQ, "x")
   K, a = NumberField(x^3 + 3x + 1, "a")

   c = a^2 + 2a - 7
   d = 3a^2 - a + 1

   @test c + d == 4a^2 + a - 6

   @test c - d == -2a^2 + 3a - 8

   @test c*d == -31*a^2 - 9*a - 12

   println("PASS")
end

function test_nf_elem_adhoc_binary()
   print("nf_elem.adhoc_binary...")
 
   R, x = PolynomialRing(QQ, "x")
   K, a = NumberField(x^3 + 3x + 1, "a")

   d = 3a^2 - a + 1

   @test d + 3 == 3 + d
   @test d + fmpz(3) == fmpz(3) + d
   @test d + fmpq(2, 3) == fmpq(2, 3) + d
   @test d - 3 == -(3 - d)
   @test d - fmpz(3) == -(fmpz(3) - d)
   @test d - fmpq(2, 3) == -(fmpq(2, 3) - d)
   @test d*3 == 3d
   @test d*fmpz(3) == fmpz(3)*d
   @test d*fmpq(2, 3) == fmpq(2, 3)*d
   
   println("PASS")
end

function test_nf_elem_powering()
   print("nf_elem.powering...")
 
   R, x = PolynomialRing(QQ, "x")
   K, a = NumberField(x^3 + 3x + 1, "a")

   d = a^2 + 2a - 7

   @test d^5 == -13195*a^2 + 72460*a + 336
   @test d^(-2) == fmpz(2773)//703921*a^2 + fmpz(1676)//703921*a + fmpz(12632)//703921
   @test d^0 == 1

   println("PASS")
end

function test_nf_elem_comparison()
   print("nf_elem.comparison...")
 
   R, x = PolynomialRing(QQ, "x")
   K, a = NumberField(x^3 + 3x + 1, "a")

   c = 3a^2 - a + 1
   d = a^2 + 2a - 7

   @test c != d
   @test c == 3a^2 - a + 1

   println("PASS")
end

function test_nf_elem_adhoc_comparison()
   print("nf_elem.adhoc_comparison...")
 
   R, x = PolynomialRing(QQ, "x")
   K, a = NumberField(x^3 + 3x + 1, "a")

   c = 3a^2 - a + 1

   @test c != 5
   @test K(5) == 5
   @test K(5) == fmpz(5)
   @test K(fmpq(2, 3)) == fmpq(2, 3)
   @test 5 == K(5)
   @test fmpz(5) == K(5)
   @test fmpq(2, 3) == K(fmpq(2, 3))

   println("PASS")
end

function test_nf_elem_inversion()
   print("nf_elem.inversion...")
 
   R, x = PolynomialRing(QQ, "x")
   K, a = NumberField(x^3 + 3x + 1, "a")

   c = 3a^2 - a + 1

   @test inv(c)*c == 1

   println("PASS")
end

function test_nf_elem_exact_division()
   print("nf_elem.exact_division...")
 
   R, x = PolynomialRing(QQ, "x")
   K, a = NumberField(x^3 + 3x + 1, "a")

   c = 3a^2 - a + 1
   d = a^2 + 2a - 7

   @test divexact(c, d) == c*inv(d)

   println("PASS")
end

function test_nf_elem_adhoc_exact_division()
   print("nf_elem.adhoc_exact_division...")
 
   R, x = PolynomialRing(QQ, "x")
   K, a = NumberField(x^3 + 3x + 1, "a")

   c = 3a^2 - a + 1
   
   @test divexact(7c, 7) == c
   @test divexact(7c, fmpz(7)) == c
   @test divexact(fmpq(2, 3)*c, fmpq(2, 3)) == c
  
   println("PASS")
end

function test_nf_elem_norm_trace()
   print("nf_elem.adhoc_norm_trace...")
 
   R, x = PolynomialRing(QQ, "x")
   K, a = NumberField(x^3 + 3x + 1, "a")

   c = 3a^2 - a + 1
   
   @test norm(c) == 113
   @test trace(c) == -15
  
   println("PASS")
end

function test_nf_elem()
   test_nf_elem_constructors()
   test_nf_elem_conversions()
   test_nf_elem_manipulation()
   test_nf_elem_unary_ops()
   test_nf_elem_binary_ops()
   test_nf_elem_adhoc_binary()
   test_nf_elem_powering()
   test_nf_elem_comparison()
   test_nf_elem_adhoc_comparison()
   test_nf_elem_inversion()
   test_nf_elem_exact_division()
   test_nf_elem_adhoc_exact_division()
   test_nf_elem_norm_trace()

   println("")
end
