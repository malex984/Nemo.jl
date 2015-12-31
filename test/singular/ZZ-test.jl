function test_ZZ_abstract_types_singular()
   print("ZZ.abstract_types / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()

   @test elem_type(ZZ) <: RingElem
   @test elem_type(ZZ) <: Nemo.SingularCoeffsElems

   @test isa(ZZ, Nemo.Ring)
   @test isa(ZZ, Nemo.SingularCoeffs)

   @test typeof(ZZ) <: Nemo.Ring
   @test typeof(ZZ) <: Nemo.SingularCoeffs

   println("PASS")
end

function test_ZZ_constructors_singular()
   print("ZZ.constructors / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()

   a = ZZ(-123)
   @test isa(a, RingElem)

#   b = ZZ(12.0)
#   @test isa(b, RingElem)

   c = ZZ("-1234567876545678376545678900000000000000000000000000") 
   @test isa(c, RingElem)

   d = ZZ(a)
   @test isa(d, RingElem)

   e = deepcopy(d)
   @test isa(e, RingElem)

#   f = ZZ(BigFloat(10)^100)
#   @test isa(f, RingElem)
   
   g = ZZ()
   @test isa(g, RingElem)

   const bb =  parse(BigInt,"-12345678901234567890")

   c = ZZ(bb)
#   println("c: ", c)
   @test isa(c, RingElem)

   bbb = BigInt(c)
#   println("bbb: ", bbb)
   @test bbb == bb

   println("PASS")
end

function test_ZZ_convert_singular()
   print("ZZ.convert / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()

   a = ZZ(-123)
   b = ZZ(12)

   @test Int(a) == -123
   @test UInt(b) == UInt(12)
#   @test BigInt(a) == BigInt(-123)
#   @test Float64(a) == Float64(-123)
#   @test Float32(a) == Float32(-123)
#   @test Float16(a) == Float16(-123)
#   @test BigFloat(a) == BigFloat(-123)

   println("PASS")
end

function test_ZZ_manipulation_singular()
   print("ZZ.manipulation / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()

   a = one(ZZ)
   b = zero(ZZ)

   @test isa(a, RingElem)
   
   @test isa(b, RingElem)

   @test sign(a) == 1

#   @test fits(Int, a)   #TODO: FIXME: Not implemented yet...
#   @test fits(UInt, a)
   
   @test size(a) == 1

   @test canonical_unit(ZZ(-12)) == -1

   @test isunit(ZZ(-1))

   @test iszero(b)

   @test isone(a)
   
   @test num(ZZ(12)) == ZZ(12)

   @test den(ZZ(12)) == ZZ(1)

   println("PASS")
end

function test_ZZ_binary_ops_singular()
   print("ZZ.binary_ops / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()

   a = ZZ(12)
   b = ZZ(26)

   @test a + b == 38

   @test a - b == -14

   @test a*b == 312

   @test Int(a) == 12
   @test Int(b) == 26

   @test b % a == 2 # TODO: FIXME: rem is crashing!...?!?

#   @test b&a == 8 #### TODO: FIXME: nothing like that on Singular side!! :(
#   @test b|a == 30
#   @test b$a == 22

   println("PASS?")
end

function test_ZZ_division_singular()
   print("ZZ.division / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()

   a = ZZ(12)
   b = ZZ(26)

#   @test fdiv(b, a) == 2

#   @test cdiv(b, a) == 3

#   @test tdiv(b, a) == 2

   @test div(b, a) == 2

   println("PASS")
end

function test_ZZ_remainder_singular()
   print("ZZ.remainder / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()

   a = ZZ(12)
   b = ZZ(26)

   @test mod(b, a) == 2

   @test rem(b, a) == 2

   @test mod(b, 12) == 2

   @test rem(b, 12) == 2


   println("PASS")
end

function test_ZZ_exact_division_singular()
   print("ZZ.exact_division / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()

   @test divisible(ZZ(24), ZZ(12))

   @test divexact(ZZ(24), ZZ(12)) == 2

   @test divisible(ZZ(12), ZZ(6))

   println("PASS")
end

function test_ZZ_gcd_lcm_singular()
   print("ZZ.gcd_lcm / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()

   a = ZZ(12)
   b = ZZ(26)

   @test gcd(a, b) == 2

   @test lcm(a, b) == 156
 
   println("PASS")
end

function test_ZZ_adhoc_binary_singular()
   print("ZZ.adhoc_binary / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()

   a = ZZ(-12)

   @test 3 + a == -9

   @test a + 3 == -9

   @test a - 3 == -15

   @test 5 - a == 17

   @test a*5 == -60

   @test 5*a == -60

   @test a%5 == -2

   println("PASS")
end

function test_ZZ_adhoc_division_singular()
   print("ZZ.adhoc_division / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()

   a = ZZ(-12)

#   @test fdiv(a, 5) == -3
#   @test tdiv(a, 7) == -1
#   @test cdiv(a, 7) == -1

   @test div(a, 3) == -4
   
   println("PASS")
end


function test_ZZ_powering_singular()
   print("ZZ.powering / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()

   a = ZZ(-12)

   @test a^5 == -248832
  
   @test a^UInt(5) == -248832
   
   println("PASS")
end

function test_ZZ_comparison_singular()
   print("ZZ.comparison / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()

   a = ZZ(-12)
   b = ZZ(5)

   @test a < b

   @test b > a

   @test b >= a

   @test a <= b

   @test a == ZZ(-12)

   @test a != b

   @test isequal(a, ZZ(-12))

   @test cmp(a, b) == -1

##   println("a: $a, abs: ", abs(a))

   @test cmpabs(a, b) == 1

   println("PASS")
end

function test_ZZ_adhoc_comparison_singular()
   print("ZZ.adhoc_comparison / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()

   a = ZZ(-12)
   
   @test a < 7

   @test a > -40

   @test 7 > a

   @test -40 < a

   @test a <= 7

   @test a >= -40

   @test 7 >= a

   @test -40 <= a

   @test a == -12

   @test a != 4

   @test -12 == a

   @test 4 != a

   println("PASS")
end

function test_ZZ_unary_ops_singular()
   print("ZZ.unary_ops / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()

   @test -ZZ(12) == -12

##   @test ~ZZ(-5) == 4

   println("PASS")
end

function test_ZZ_abs_singular()
   print("ZZ.abs / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()

   @test abs(ZZ(-12)) == 12

   println("PASS")
end

function test_ZZ_divrem_singular()
   print("ZZ.divrem / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()

#   @test fdivrem(ZZ(12), ZZ(5)) == (ZZ(2), ZZ(2))

#   @test tdivrem(ZZ(12), ZZ(5)) == (ZZ(2), ZZ(2))

   @test divrem(ZZ(12), ZZ(5)) == (ZZ(2), ZZ(2))

   println("PASS")
end


function test_ZZ_extended_gcd_singular()
   print("ZZ.extended_gcd / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()


#   print("gcdx(ZZ(12), ZZ(5)) ")
   g, s, t = gcdx(ZZ(12), ZZ(5))
 #  print( "  :::  ")

 #  println(g)
 #  println(s)
 #  println(t)

   a = (g, s, t)
   @test a == (1, -2, 5)

#   print("gcdinv(ZZ(5), ZZ(12)) ")
   g, s = gcdinv(ZZ(5), ZZ(12))
#   print( "  :::  ")
#   println( g, " ; ", s )
   
   @test (g, s) == (1, 5)


   println("PASS")
end


function test_ZZ_string_io_singular()
   print("ZZ.string_io / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()

   a = ZZ(12)

   @test string(a) == "12"

   println("PASS")
end


function test_ZZ_modular_arithmetic_singular()
   print("ZZ.modular_arithmetic / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()

   @test powmod(ZZ(12), ZZ(110), ZZ(13)) == 1

   @test powmod(ZZ(12), 110, ZZ(13)) == 1

   @test invmod(ZZ(12), ZZ(13)) == 12

#   @test sqrtmod(ZZ(12), ZZ(13)) == 5 ## ??

#   @test crt(ZZ(5), ZZ(13), ZZ(7), ZZ(37), true) == 44 # TODO: FIXME: wrap it?
#   @test crt(ZZ(5), ZZ(13), 7, 37, false) == 44

   println("PASS?")
end


function test_ZZ_singular()
   test_ZZ_extended_gcd_singular()

   test_ZZ_constructors_singular()
   test_ZZ_convert_singular()
   test_ZZ_manipulation_singular()
   test_ZZ_binary_ops_singular()
   test_ZZ_division_singular()
   test_ZZ_remainder_singular()
   test_ZZ_gcd_lcm_singular()
   test_ZZ_adhoc_binary_singular()
   test_ZZ_adhoc_division_singular()
   test_ZZ_powering_singular()
   test_ZZ_comparison_singular()
   test_ZZ_adhoc_comparison_singular()
   test_ZZ_unary_ops_singular()
   test_ZZ_abs_singular()
   test_ZZ_divrem_singular()
   test_ZZ_string_io_singular()
   test_ZZ_abstract_types_singular()
   test_ZZ_exact_division_singular()
#   test_ZZ_bases_singular() #  ### TODO: FIXME: Not yet :(
   test_ZZ_modular_arithmetic_singular()  ### TODO: FIXME: Not yet :(

   println("")
end

#   test_ZZ_logarithm_singular() ## Nothing like this on Singular side!
#   test_ZZ_shift_singular()
#   test_ZZ_roots_singular()
#   test_ZZ_bit_twiddling_singular()
#   test_ZZ_number_theoretic_singular()
