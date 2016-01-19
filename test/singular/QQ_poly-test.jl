function test_QQ_poly_constructors_singular()
   print("QQ_poly.constructors / Singular...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, y = PolynomialRing(QQ, "y")

   @test isa(S, SingularPolynomialRing)

   @test isa(y, SingularPolynomialElem)

   T, z = PolynomialRing(S, "z")

   @test typeof(T) <: PolynomialRing

   @test isa(z, PolyElem)

   f = ZZ(12)//3 + y^3 + z + 1

   @test isa(f, PolyElem)

   g = S(2)

   @test isa(g, PolyElem)

   h = S(ZZ(12)//7 + 1)

   @test isa(h, PolyElem)

   j = T(ZZ(12)//7 + 2)

   @test isa(j, PolyElem)

   k = S([ZZ(12)//7, ZZ(12)//7 + 2, ZZ(3)//11 + 1])

   @test isa(k, PolyElem)

   l = S(k)

   @test isa(l, PolyElem)

   R, x = PolynomialRing(ZZ, "x")

   m = S(3x^3 + 2x + 1) # ZZ[x] -> QQ[x]?

   @test isa(m, SingularPolynomialElem)

   @test m == 3y^3 + 2y + 1

   n = S(ZZ(12))

   @test isa(n, SingularPolynomialElem)
   
   println("PASS")
end

function test_QQ_poly_manipulation_singular()
   print("QQ_poly.manipulation / Singular...")

   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, y = PolynomialRing(QQ, "y")

   @test iszero(zero(S))
   
   @test isone(one(S))

   @test isgen(gen(S))
   
   @test isunit(one(S))

   f = 2y + ZZ(11)//7 + 1

   @test lead(f) == 2

   @test degree(f) == 1

   h = ZZ(12)//7*y^2 + 5*y + 3

   @test coeff(h, 2) == ZZ(12)//7

   @test length(h) == 3

   @test canonical_unit(-ZZ(12)//7*y + 1) == ZZ(-12)//7

   @test deepcopy(h) == h

   @test den(-ZZ(12)//7*y + 1) == 7

   println("PASS")
end

function test_QQ_poly_binary_ops_singular()
   print("QQ_poly.binary_ops / Singular...")

   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, y = PolynomialRing(QQ, "y")

   f = 3*y^2 + 7*y + 3
   g = 2*y + 11
   
   @test f - g == 3*y^2 + 5*y - 8

   @test f + g == 3*y^2 + 9*y + 14

   @test f*g == 6*y^3 + 47*y^2 + 83*y + 33

   println("PASS")
end

function test_QQ_poly_adhoc_binary_singular()
   print("QQ_poly.adhoc_binary / Singular...")

   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, y = PolynomialRing(QQ, "y")

   f = 3*y^2 + 7*y + 3
   g = 2*y + 11
   
   @test f*4 == 12*y^2 + 28*y + 12

   @test 7*f == 21*y^2 + 49*y + 21
   
   @test ZZ(5)*g == 10*y+55

   @test g*ZZ(3) == 6*y+33

   @test QQ(5, 7)*g == ZZ(10)//7*y+ZZ(55)//7

   @test g*QQ(5, 7) == ZZ(10)//7*y+ZZ(55)//7

   @test f + 4 == 3*y^2 + 7*y + 7

   @test 7 + f == 3*y^2 + 7*y + 10
   
   @test ZZ(5) + g == 2*y+16

   @test g + ZZ(3) == 2*y+14

   @test QQ(5, 7) + g == 2*y+ZZ(82)//7

   @test g + QQ(5, 7) == 2*y+ZZ(82)//7

   @test f - 4 == 3*y^2 + 7*y - 1

   @test 7 - f == -3*y^2 - 7*y + 4
   
   @test ZZ(5) - g == -2*y-6

   @test g - ZZ(3) == 2*y+8

   @test QQ(5, 7) - g == -2*y-ZZ(72)//7

   @test g - QQ(5, 7) == 2*y+ZZ(72)//7

   println("PASS")
end

function test_QQ_poly_comparison_singular()
   print("QQ_poly.comparison / Singular...")

   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, y = PolynomialRing(QQ, "y")

   f = 3*y^2 + 7*y + 3
   g = 3*y^2 + 7*y + 3
   
   @test f == g

   @test isequal(f, g)

   println("PASS")
end

function test_QQ_poly_adhoc_comparison_singular()
   print("QQ_poly.adhoc_comparison / Singular...")

   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, y = PolynomialRing(QQ, "y")

   @test S(1) == 1 

   @test 1 != ZZ(11)//7 + y

   @test S(ZZ(3)//5) == QQ(3, 5)

   @test QQ(3, 5) != y + 1

   println("PASS")
end

function test_QQ_poly_unary_ops_singular()
   print("QQ_poly.unary_ops / Singular...")

   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, y = PolynomialRing(QQ, "y")

   f = 3*y^2 + 2*y + 3

   @test -f == -3*y^2 - 2*y - 3

   println("PASS")
end

function test_QQ_poly_truncation_singular()
   print("QQ_poly.truncation / Singular...")

   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, y = PolynomialRing(QQ, "y")

   f = 3*y^2 + 7*y + 3
   g = 2*y^2 + 11*y + 1
   
   @test truncate(f, 1) == 3

   @test mullow(f, g, 4) == 47*y^3 + 86*y^2 + 40*y + 3

   println("PASS")
end

function test_QQ_poly_reverse_singular()
   print("QQ_poly.reverse / Singular...")

   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, y = PolynomialRing(QQ, "y")

   f = 3*y^2 + 7*y + 3
   
   @test reverse(f, 7) == 3*y^6 + 7*y^5 + 3*y^4

   println("PASS")
end

function test_QQ_poly_shift_singular()
   print("QQ_poly.shift / Singular...")

   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, y = PolynomialRing(QQ, "y")

   f = 3*y^2 + 7*y + 3
   
   @test shift_left(f, 7) == 3*y^9 + 7*y^8 + 3*y^7

   @test shift_right(f, 3) == 0

   println("PASS")
end

function test_QQ_poly_powering_singular()
   print("QQ_poly.powering / Singular...")

   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, y = PolynomialRing(QQ, "y")

   f = 3*y^2 + 7*y + 3
   
   @test f^5 == 243*y^10 + 2835*y^9 + 14445*y^8 + 42210*y^7 + 78135*y^6 + 95557*y^5 + 78135*y^4 + 42210*y^3 + 14445*y^2 + 2835*y + 243

   println("PASS")
end

function test_QQ_poly_modular_arithmetic_singular()
   print("QQ_poly.modular_arithmetic / Singular...")

   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, y = PolynomialRing(QQ, "y")
   
   f = 7y + 1
   g = 11y^2 + 12y + 21
   h = 17y^5 + 2y + 1

   @test invmod(f, g) == -ZZ(77)//956*y-ZZ(73)//956
   
   @test mulmod(f, g, h) == 77*y^3 + 95*y^2 + 159*y + 21
   
   @test powmod(f, 3, h) == 343*y^3 + 147*y^2 + 21*y + 1
   
   println("PASS")
end

function test_QQ_poly_exact_division_singular()
   print("QQ_poly.exact_division / Singular...")

   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, y = PolynomialRing(QQ, "y")

   f = 3*y^2 + 7*y + 3
   g = 11*y^2 + 2*y + 3
   
   @test divexact(f*g, f) == g

   println("PASS")
end

function test_QQ_poly_adhoc_exact_division_singular()
   print("QQ_poly.adhoc_exact_division / Singular...")

   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, y = PolynomialRing(QQ, "y")

   f = 3*y^2 + 7*y + 3
   
   @test divexact(3*f, 3) == f

   @test divexact(ZZ(3)*f, ZZ(3)) == f

   @test divexact(ZZ(12)//7*f, ZZ(12)//7) == f

   println("PASS")
end

function test_QQ_poly_euclidean_division_singular()
   print("QQ_poly.euclidean_division / Singular...")

   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, y = PolynomialRing(QQ, "y")

   f = y^3 + 3*y^2 + 7*y + 3
   g = 11*y^2 + 2*y + 3
   
   @test mod(f, g) == ZZ(752)//121*y+ZZ(270)//121
   
   @test divrem(f, g) == (ZZ(1)//11*y+ZZ(31)//121, ZZ(752)//121*y+ZZ(270)//121)
 
   println("PASS")
end

function test_QQ_poly_content_primpart_gcd_singular()
   print("QQ_poly.content_primpart_gcd / Singular...")

   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, y = PolynomialRing(QQ, "y")

   k = 3y^2 + 7y + 3
   l = 11y + 5
   m = y^2 + 17

   @test content(k) == 1

   @test primpart(k*ZZ(13)//6) == k

   @test gcd(k*m, l*m) == m

   @test lcm(k*m, l*m) == k*l*m

   println("PASS")
end

function test_QQ_poly_evaluation_singular()
   print("QQ_poly.evaluation / Singular...")

   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, y = PolynomialRing(QQ, "y")

   f = ZZ(12)//7
   g = 3y^2 + 11*y + 3

   @test evaluate(g, 3) == 63

   @test g(3) == 63

   @test evaluate(g, ZZ(3)) == 63

   @test g(ZZ(3)) == 63

   @test evaluate(g, f) == ZZ(1503)//49

   @test g(f) == ZZ(1503)//49

   println("PASS")
end

function test_QQ_poly_composition_singular()
   print("QQ_poly.composition / Singular...")

   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, y = PolynomialRing(QQ, "y")

   f = 7y^2 + 12y + 3
   g = 11y + 9

   @test compose(f, g) == 847*y^2 + 1518*y + 678

   println("PASS")
end

function test_QQ_poly_derivative_singular()
   print("QQ_poly.derivative / Singular...")

   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, y = PolynomialRing(QQ, "y")

   h = 17y^2 + 2y + 3

   @test derivative(h) == 34y + 2

   println("PASS")
end

function test_QQ_poly_integral_singular()
   print("QQ_poly.integral / Singular...")

   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, y = PolynomialRing(QQ, "y")
   
   f = 17y^2 + 2y - 11
   
   @test integral(f) == ZZ(17)//3*y^3 + y^2 - 11y

   println("PASS")
end

function test_QQ_poly_resultant_singular()
   print("QQ_poly.resultant / Singular...")

   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, y = PolynomialRing(QQ, "y")

   f = 13y^2 + 7y + 3
   g = 6y + 11

   @test resultant(f, g) == 1219

   println("PASS")
end

function test_QQ_poly_discriminant_singular()
   print("QQ_poly.discriminant / Singular...")

   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, y = PolynomialRing(QQ, "y")

   f = 17y^2 + 11y + 3

   @test discriminant(f) == -83

   println("PASS")
end

function test_QQ_poly_gcdx_singular()
   print("QQ_poly.gcdx / Singular...")

   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, y = PolynomialRing(QQ, "y")

   f = 17y^2 + 11y + 3
   g = 61y - 9

   @test gcdx(f, g) == (1, ZZ(3721)//18579, -ZZ(1037)//18579*y-ZZ(824)//18579)

   println("PASS")
end

function test_QQ_poly_signature_singular()
   print("QQ_poly.signature / Singular...")

   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   R, x = PolynomialRing(QQ, "x")

   f = (x^3 + 3x + QQ(2)//QQ(3))

   @test signature(f) == (1, 1)

   println("PASS")
end

function test_QQ_poly_special_singular()
   print("QQ_poly.special / Singular...")

   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, y = PolynomialRing(QQ, "y")

   @test chebyshev_t(20, y) == 524288*y^20-2621440*y^18+5570560*y^16-6553600*y^14+4659200*y^12-2050048*y^10+549120*y^8-84480*y^6+6600*y^4-200*y^2+1

   @test chebyshev_u(15, y) == 32768*y^15-114688*y^13+159744*y^11-112640*y^9+42240*y^7-8064*y^5+672*y^3-16*y

   println("PASS")
end

function test_QQ_poly_Polynomials_singular()
   print("QQ_poly.Polynomials / Singular...")

   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   R, x = PolynomialRing(QQ, "x")
   S, y = PolynomialRing(R, "y")

   f = (3x^2 + 2x + 1)*y^3 + (2x^2 + 4)*y^2 + 4x*y + (2x^2 - x + 1)

   @test f^40*f^60 == f^50*f^50

   println("PASS")
end

function test_QQ_poly_singular()
   test_QQ_poly_constructors_singular()
   test_QQ_poly_manipulation_singular()
   test_QQ_poly_binary_ops_singular()
   test_QQ_poly_adhoc_binary_singular()
   test_QQ_poly_comparison_singular()
   test_QQ_poly_adhoc_comparison_singular()
   test_QQ_poly_unary_ops_singular()
   test_QQ_poly_truncation_singular()
   test_QQ_poly_reverse_singular()
   test_QQ_poly_shift_singular()
   test_QQ_poly_powering_singular()
   test_QQ_poly_modular_arithmetic_singular()
   test_QQ_poly_exact_division_singular()
   test_QQ_poly_adhoc_exact_division_singular()
   test_QQ_poly_euclidean_division_singular()
   test_QQ_poly_content_primpart_gcd_singular()
   test_QQ_poly_evaluation_singular()
   test_QQ_poly_composition_singular()
   test_QQ_poly_derivative_singular()
   test_QQ_poly_integral_singular()
   test_QQ_poly_resultant_singular()
   test_QQ_poly_discriminant_singular()
   test_QQ_poly_gcdx_singular()
   test_QQ_poly_signature_singular()
   test_QQ_poly_special_singular()
   test_QQ_poly_Polynomials_singular()

   println("")
end
