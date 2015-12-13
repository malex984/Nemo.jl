function test_ZZ_abstract_types_singular()
   print("ZZ.abstract_types / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()


   @test ZZ <: Nemo.Ring
   @test ZZ <: SingularCoeffs

   @test elem_type(ZZ) <: RingElem
   @test elem_type(ZZ) <: SingularCoeffsElems

   println("PASS")
end

function test_ZZ_constructors_singular()
   print("ZZ.constructors / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()

   a = ZZ(-123)
   @test isa(a, RingElem)

   b = ZZ(12.0)
   @test isa(b, RingElem)

#   c = ZZ("-1234567876545678376545678900000000000000000000000000")
#   @test isa(c, RingElem)

   d = ZZ(c)
   @test isa(d, RingElem)

   e = deepcopy(c)
   @test isa(e, RingElem)

#   f = ZZ(BigFloat(10)^100)
#   @test isa(f, RingElem)
   
   g = ZZ()
   @test isa(f, RingElem)

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

   @test fits(Int, a)
   
   @test fits(UInt, a)
   
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

   @test b%a == 2

   @test b&a == 8

   @test b|a == 30

   @test b$a == 22

   println("PASS")
end

function test_ZZ_division_singular()
   print("ZZ.division / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()

   a = ZZ(12)
   b = ZZ(26)

   @test fdiv(b, a) == 2

   @test cdiv(b, a) == 3

   @test tdiv(b, a) == 2

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

   @test divexact(ZZ(24), ZZ(12)) == 2

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

function test_ZZ_logarithm_singular()
   print("ZZ.logarithm / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()

   a = ZZ(12)
   b = ZZ(26)

   @test flog(b, a) == 1

   @test flog(b, 12) == 1

   @test clog(b, a) == 2

   @test clog(b, 12) == 2

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

   @test fdiv(a, 5) == -3

   @test tdiv(a, 7) == -1

   @test cdiv(a, 7) == -1

   @test div(a, 3) == -4
   
   println("PASS")
end

function test_ZZ_shift_singular()
   print("ZZ.shift..")

   a = ZZ(-12)

   @test a >> 3 == -2

   @test fdivpow2(a, 2) == -3

   @test cdivpow2(a, 2) == -3

   @test tdivpow2(a, 2) == -3

   @test a << 4 == -192
   
   println("PASS")
end

function test_ZZ_powering()
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

   @test cmpabs(a, b) == 1

   @test cmp(a, b) == -1

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

   @test ~ZZ(-5) == 4

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

   @test fdivrem(ZZ(12), ZZ(5)) == (ZZ(2), ZZ(2))

   @test tdivrem(ZZ(12), ZZ(5)) == (ZZ(2), ZZ(2))

   @test divrem(ZZ(12), ZZ(5)) == (ZZ(2), ZZ(2))

   println("PASS")
end

function test_ZZ_roots_singular()
   print("ZZ.roots / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()

   @test isqrt(ZZ(12)) == 3

   @test isqrtrem(ZZ(12)) == (3, 3)

   @test root(ZZ(1000), 3) == 10

   println("PASS")
end

function test_ZZ_extended_gcd_singular()
   print("ZZ.extended_gcd / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()

   @test gcdx(ZZ(12), ZZ(5)) == (1, -2, 5)

   @test gcdinv(ZZ(5), ZZ(12)) == (1, 5)

   println("PASS")
end

function test_ZZ_bit_twiddling_singular()
   print("ZZ.bit_twiddling / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()

   a = ZZ(12)

   @test popcount(a) == 2

   @test nextpow2(a) == 16

   @test prevpow2(a) == 8

   @test trailing_zeros(a) == 2

   combit!(a, 2)

   @test a == 8

   setbit!(a, 0)

   @test a == 9

   clrbit!(a, 0)

   @test a == 8
   
   println("PASS")
end

function test_ZZ_bases_singular()
   print("ZZ.bases / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()

   a = ZZ(12)

   @test bin(a) == "1100"

   @test oct(a) == "14"

   @test dec(a) == "12"

   @test hex(a) == "c"

   @test base(a, 13) == "c"

   @test nbits(a) == 4

   @test ndigits(a, 3) == 3

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

   @test sqrtmod(ZZ(12), ZZ(13)) == 5

   @test crt(ZZ(5), ZZ(13), ZZ(7), ZZ(37), true) == 44

   @test crt(ZZ(5), ZZ(13), 7, 37, false) == 44

   println("PASS")
end

function test_ZZ_number_theoretic_singular()
   print("ZZ.number_theoretic / Singular Coeffs...")

   const ZZ = Nemo.SingularZZ()

   @test isprime(ZZ(13))

   @test isprobabprime(ZZ(13))

   @test divisible(ZZ(12), ZZ(6))

   @test issquare(ZZ(36))

   @test fac(100) == ZZ("93326215443944152681699238856266700490715968264381621468592963895217599993229915608941463976156518286253697920827223758251185210916864000000000000000000000000")

   @test sigma(ZZ(128), 10) == ZZ("1181745669222511412225")

   @test eulerphi(ZZ(12480)) == 3072

   @test remove(ZZ(12), ZZ(2)) == (2, 3)

   @test divisor_lenstra(ZZ(12), ZZ(4), ZZ(5)) == 4

   @test risingfac(ZZ(12), 5) == 524160

   @test risingfac(12, 5) == 524160

   @test primorial(7) == 210

   @test binom(12, 5) == 792

   @test bell(12) == 4213597

   @test moebiusmu(ZZ(13)) == -1

   @test jacobi(ZZ(2), ZZ(5)) == -1

   if !on_windows64

      @test numpart(10) == 42

      @test numpart(ZZ(1000)) == ZZ("24061467864032622473692149727991")

   end

   println("PASS")
end

function test_ZZ_singular()
   test_ZZ_abstract_types_singular()
   test_ZZ_constructors_singular()
   test_ZZ_convert_singular()
   test_ZZ_manipulation_singular()
   test_ZZ_binary_ops_singular()
   test_ZZ_division_singular()
   test_ZZ_remainder_singular()
   test_ZZ_exact_division_singular()
   test_ZZ_gcd_lcm_singular()
   test_ZZ_logarithm_singular()
   test_ZZ_adhoc_binary_singular()
   test_ZZ_adhoc_division_singular()
   test_ZZ_shift_singular()
   test_ZZ_powering_singular()
   test_ZZ_comparison_singular()
   test_ZZ_adhoc_comparison_singular()
   test_ZZ_unary_ops_singular()
   test_ZZ_abs_singular()
   test_ZZ_divrem_singular()
   test_ZZ_roots_singular()
   test_ZZ_extended_gcd_singular()
   test_ZZ_bit_twiddling_singular()
   test_ZZ_bases_singular()
   test_ZZ_string_io_singular()
   test_ZZ_modular_arithmetic_singular()
   test_ZZ_number_theoretic_singular()

   println("")
end
