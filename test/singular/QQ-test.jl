function test_QQ_constructors_singular()
   print("QQ.constructors() / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   R = FractionField(ZZ)

   @test isa(R, Nemo.Field)

   @test isa(R(2), FractionElem)

   @test isa(R(), FractionElem)

   @test isa(R(BigInt(1)//2), FractionElem)

   @test isa(R(2, 3), FractionElem)

   @test isa(R(ZZ(2), 3), FractionElem)

   @test isa(R(2, ZZ(3)), FractionElem)

   @test isa(R(ZZ(2), ZZ(3)), FractionElem)

   @test isa(R(R(2)), FractionElem)

   @test isa(QQ(2), FractionElem)

   @test isa(QQ(), FractionElem)

   @test isa(QQ(BigInt(1)//2), FractionElem)

   @test isa(QQ(2, 3), FractionElem)

   @test isa(QQ(ZZ(2), 3), FractionElem)

   @test isa(QQ(2, ZZ(3)), FractionElem)

   @test isa(QQ(ZZ(2), ZZ(3)), FractionElem)

   @test isa(QQ(R(2)), FractionElem)

   println("PASS")
end

function test_QQ_conversions_singular()
   print("QQ.conversions() / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   @test Rational(ZZ(12)) == 12

   @test Rational(QQ(3, 7)) == 3//7

   println("PASS")
end

function test_QQ_manipulation_singular()
   print("QQ.manipulation() / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   R = FractionField(ZZ)

   a = -ZZ(2)//3
   b = ZZ(123)//234

   @test height(a) == 3

   @test height_bits(b) == 7

   @test abs(a) == ZZ(2)//3

   @test isone(one(R))

   @test iszero(zero(R))

   @test isunit(one(R))

   @test isunit(QQ(1, 3))

   @test deepcopy(QQ(2, 3)) == QQ(2, 3)

   @test num(QQ(2, 3)) == 2

   @test den(QQ(2, 3)) == 3

   println("PASS")
end

function test_QQ_unary_ops_singular()
   print("QQ.unary_ops() / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   a = QQ(-2, 3)

   @test -a == QQ(2, 3)

   println("PASS")
end

function test_QQ_binary_ops_singular()
   print("QQ.binary_ops() / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   a = QQ(-2, 3)
   b = ZZ(5)//7

   @test a + b == QQ(1, 21)

   @test a - b == QQ(-29, 21)

   @test a*b == QQ(-10, 21)

   println("PASS")
end

function test_QQ_adhoc_binary_singular()
   print("QQ.adhoc_binary() / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   a = QQ(-2, 3)
   
   @test a + 3 == QQ(7, 3)

   @test 3 + a == QQ(7, 3)

   @test a - 3 == QQ(-11, 3)

   @test 3 - a == QQ(11, 3)

   @test a*3 == -2

   @test 3a == -2

   @test a + ZZ(3) == QQ(7, 3)

   @test ZZ(3) + a == QQ(7, 3)

   @test a - ZZ(3) == QQ(-11, 3)

   @test ZZ(3) - a == QQ(11, 3)

   @test a*ZZ(3) == -2

   @test ZZ(3)*a == -2

   println("PASS")
end

function test_QQ_comparison_singular()
   print("QQ.comparison() / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   a = QQ(-2, 3)
   b = ZZ(1)//2

   @test a < b

   @test b > a

   @test b >= a

   @test a <= b

   @test a == ZZ(-4)//6

   @test a != b

   println("PASS")
end

function test_QQ_adhoc_comparison_singular()
   print("QQ.adhoc_comparison() / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   a = -ZZ(2)//3
   
   @test a < 1

   @test 1 > a

   @test a < ZZ(1)

   @test ZZ(1) > a

   @test a <= 0

   @test 0 >= a

   @test a <= ZZ(0)

   @test ZZ(0) >= a
   
   @test a != 1

   @test a != ZZ(1)

   @test 1 != a

   @test ZZ(1) != a

   @test a == QQ(-2, 3)

   println("PASS")
end

function test_QQ_shifting_singular()
   print("QQ.shifting() / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   a = -ZZ(2)//3
   b = QQ(1, 2)

   @test a << 3 == -ZZ(16)//3

   @test b >> 5 == ZZ(1)//64
   
   println("PASS")
end

function test_QQ_powering_singular()
   print("QQ.powering() / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   a = -ZZ(2)//3
   
   @test a^(-12) == ZZ(531441)//4096
   
   println("PASS")
end

function test_QQ_inversion_singular()
   print("QQ.inversion() / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   a = -ZZ(2)//3
   
   @test inv(a) == ZZ(-3)//2
   
   println("PASS")
end

function test_QQ_exact_division_singular()
   print("QQ.exact_division() / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   a = -ZZ(2)//3
   b = ZZ(1)//2

   @test divexact(a, b) == ZZ(-4)//3
   
   println("PASS")
end

function test_QQ_adhoc_exact_division_singular()
   print("QQ.adhoc_exact_division() / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   a = -ZZ(2)//3

   @test divexact(a, 3) == ZZ(-2)//9
   
   @test divexact(a, ZZ(3)) == ZZ(-2)//9

   @test divexact(3, a) == ZZ(-9)//2
   
   @test divexact(ZZ(3), a) == ZZ(-9)//2
   
   println("PASS")
end

function test_QQ_modular_arithmetic_singular()
   print("QQ.modular_arithmetic() / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   a = -ZZ(2)//3
   b = ZZ(1)//2

   @test mod(a, 7) == 4

   @test mod(b, ZZ(5)) == 3
   
   println("PASS")
end

function test_QQ_gcd_singular()
   print("QQ.gcd() / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   a = -ZZ(2)//3
   b = ZZ(1)//2

   @test gcd(a, b) == ZZ(1)//6
   
   println("PASS")
end

function test_QQ_rational_reconstruction_singular()
   print("QQ.rational_reconstruction() / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   @test reconstruct(7, 13) == ZZ(1)//2
   
   @test reconstruct(ZZ(15), 31) == -ZZ(1)//2
   
   @test reconstruct(ZZ(123), ZZ(237)) == ZZ(9)//2
   
   @test reconstruct(123, ZZ(237)) == ZZ(9)//2
   
   println("PASS")
end

function test_QQ_rational_enumeration_singular()
   print("QQ.rational_enumeration() / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   @test next_minimal(ZZ(2)//3) == ZZ(3)//2

   @test next_signed_minimal(-ZZ(21)//31) == ZZ(31)//21

   @test next_calkin_wilf(ZZ(321)//113) == ZZ(113)//244

   @test next_signed_calkin_wilf(-ZZ(51)//17) == ZZ(1)//4
   
   println("PASS")
end

function test_QQ_special_functions_singular()
   print("QQ.special_functions() / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   @test harmonic(12) == ZZ(86021)//27720
   
   @test dedekind_sum(12, 13) == -ZZ(11)//13

   @test dedekind_sum(ZZ(12), ZZ(13)) == -ZZ(11)//13

   @test dedekind_sum(-120, ZZ(1305)) == -ZZ(575)//522
  
   @test dedekind_sum(ZZ(-120), 1305) == -ZZ(575)//522
  
   println("PASS")
end

function test_QQ_singular()
   test_QQ_constructors_singular()
   test_QQ_conversions_singular()
   test_QQ_manipulation_singular()
   test_QQ_unary_ops_singular()
   test_QQ_binary_ops_singular()
   test_QQ_adhoc_binary_singular()
   test_QQ_comparison_singular()
   test_QQ_adhoc_comparison_singular()
   test_QQ_shifting_singular()
   test_QQ_powering_singular()
   test_QQ_inversion_singular()
   test_QQ_exact_division_singular()
   test_QQ_adhoc_exact_division_singular()
   test_QQ_modular_arithmetic_singular()
   test_QQ_gcd_singular()
   test_QQ_rational_reconstruction_singular()
   test_QQ_rational_enumeration_singular()
   test_QQ_special_functions_singular()

   println("")
end
