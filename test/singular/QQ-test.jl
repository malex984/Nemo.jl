function test_QQ_constructors_singular()
   print("QQ.constructors() / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ();

   R = FractionField(ZZ)

#   println(R)
#   println(typeof(R))

   @test typeof(R) <: Nemo.Field
   @test isa(R, Nemo.Field)

   @test isa(R(2), FractionElem)
   @test isa(R(), FractionElem)
   @test isa(R(2, 3), FractionElem)
   @test isa(R(ZZ(2), 3), FractionElem)
   @test isa(R(2, ZZ(3)), FractionElem)
   @test isa(R(ZZ(2), ZZ(3)), FractionElem)
   @test isa(R(R(2)), FractionElem)

##   @test isa(R(BigInt(1)//2), FractionElem) 

   const QQ = Nemo.SingularQQ();

   @test is(R, QQ)

#   typealias FE FieldElem # !!!!! NOT FractionElem for now! :(

   typealias FE FractionElem

#   @test QQ <: Nemo.Field
   @test typeof(QQ) <: Nemo.Field

   @test isa(QQ(), FE)
   @test isa(QQ(2), FE)

###   @test isa(QQ(BigInt(1)//2), FE) # Not implemented :(

   @test isa(QQ(2, 3), FE)
   @test isa(QQ(ZZ(2), ZZ(3)), FE)
   @test isa(QQ(ZZ(2), 3), FE)
   @test isa(QQ(2, ZZ(3)), FE)

#   @test isa(QQ(R(2)), FE)

   println("PASS")
end

function test_QQ_conversions_singular()
   print("QQ.conversions() / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   @test Rational{BigInt}(ZZ(12)) == 12
   @test Rational{BigInt}(QQ(3, 7)) == 3//7 

   println("PASS")
end

function test_QQ_manipulation_singular()
   print("QQ.manipulation() / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   R = FractionField(ZZ)

   a = -ZZ(2)//3
   b = ZZ(123)//234

##### Return the height of the fraction a, namely the largest of the absolute values of the numerator and denominator. The type of the return value is a ZZ.
#   @test height(a) == 3 ## max(abs_Den, abs_Num) ?

##### Return the number of bits of the height of the fraction a. The type of the return value is an Int.
#   @test height_bits(b) == 7

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

### As above.....

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

#   print(" b ")
   b = ZZ(1)//2
#   print("  :::  ")
#   println(typeof(b))
#   println(b)

   @test a < b

   @test b > a

   @test b >= a

   @test a <= b

   @test a != b

   @test a == ZZ(-4)//6

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

#   print( "divexact($a, $b)")
   q = divexact(a, b)
#   print(": ", q)

   @test q == ZZ(-4)//3 # ??
   
   println("PASS")
end

function test_QQ_adhoc_exact_division_singular()
   print("QQ.adhoc_exact_division() / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   a = -ZZ(2)//3

   b = QQ(3)

   r = ZZ(-2)//9 

#   print( "divexact($a, $b)")
   q = divexact(a, b)
#   print(": ", q, " =?=", r)


#   print( "divexact($b, $a)")
   qq = divexact(b, a)
#   print(": ", qq, " =?=", inv(r) )

   @test divexact(a, 3) == r
   @test divexact(a, ZZ(3)) == r

   @test divexact(3, a) == inv(r) # ZZ(-9)//2   

   @test divexact(ZZ(3), a) == inv(r) # ZZ(-9)//2
   
   println("PASS")
end

function test_QQ_modular_arithmetic_singular()
   print("QQ.modular_arithmetic() / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   a = -ZZ(2)//3
   b = ZZ(1)//2


   println( "mod, (a: $a, b: $b)")
   print(" mod(a,7) ")
   m = mod(a, 7)
   println(": ", m)

   print(" mod(b, ZZ(5)) ")
   mm = mod(b, ZZ(5))
   println(": ", mm)

#   @test iszero(m)
   @test m == QQ(mod(Rational{Int}(Int(num(a)), Int(den(a))), 7))  #### TODO: FIXME: Flint QQ: 4???
#   @test iszero(mm)
   @test mm == QQ(mod(Rational{Int}(Int(num(b)), Int(den(b))), 5)) ## Flint QQ: 3???
   
   println("PASS????") # Note: Not compatible with Flint QQ but with Rational{Int}...
end

function test_QQ_gcd_singular()
   print("QQ.gcd() / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   a = -ZZ(2)//3
   b = ZZ(1)//2

#   print( "\ngcd(a: $a, b: $b)")
   g = gcd(a, b)
#   println(": ", g)


   @test g == ZZ(1)//6
   
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
   test_QQ_powering_singular()
   test_QQ_inversion_singular()
   test_QQ_gcd_singular()

   test_QQ_exact_division_singular()
   test_QQ_adhoc_exact_division_singular()

   test_QQ_modular_arithmetic_singular() # ?

   println("")
end

###   test_QQ_shifting_singular()   # no shifting on Singular side :(

