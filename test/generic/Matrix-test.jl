function test_matrix_constructors()
   print("Matrix.constructors...")
 
   R, t = PolynomialRing(QQ, "t")
   S = MatrixSpace(R, 3, 3)

   @test typeof(S) <: MatrixSpace

   f = S(t^2 + 1)

   @test isa(f, MatElem)

   g = S(2)

   @test isa(g, MatElem)

   h = S(fmpz(23))

   @test isa(h, MatElem)

   k = S([t t + 2 t^2 + 3t + 1; 2t R(2) t + 1; t^2 + 2 t + 1 R(0)])

   @test isa(k, MatElem)

   l = S(k)

   @test isa(l, MatElem)

   m = S()

   @test isa(m, MatElem)

   println("PASS")
end

function test_matrix_manipulation()
   print("Matrix.manipulation...")

   R, t = PolynomialRing(QQ, "t")
   S = MatrixSpace(R, 3, 3)

   A = S([t + 1 t R(1); t^2 t t; R(-2) t + 2 t^2 + t + 1])
   B = S([R(2) R(3) R(1); t t + 1 t + 2; R(-1) t^2 t^3])

   @test iszero(zero(S))
   @test isone(one(S))

   B[1, 1] = R(3)

   @test B[1, 1] == R(3)

   @test rows(B) == 3
   @test cols(B) == 3

   @test deepcopy(A) == A

   println("PASS")
end

function test_matrix_unary_ops()
   print("Matrix.unary_ops...")

   R, t = PolynomialRing(QQ, "t")
   S = MatrixSpace(R, 3, 3)

   A = S([t + 1 t R(1); t^2 t t; R(-2) t + 2 t^2 + t + 1])
   B = S([-t - 1 (-t) -R(1); -t^2 (-t) (-t); -R(-2) (-t - 2) (-t^2 - t - 1)])

   @test -A == B

   println("PASS")
end

function test_matrix_binary_ops()
   print("Matrix.binary_ops...")

   R, t = PolynomialRing(QQ, "t")
   S = MatrixSpace(R, 3, 3)

   A = S([t + 1 t R(1); t^2 t t; R(-2) t + 2 t^2 + t + 1])
   B = S([R(2) R(3) R(1); t t + 1 t + 2; R(-1) t^2 t^3])

   @test A + B == S([t+3 t+3 R(2); t^2 + t 2*t+1 2*t+2; R(-3) t^2 + t + 2 t^3 + 1*t^2 + t + 1])

   @test A - B == S([t-1 t-3 R(0); t^2 - t R(-1) R(-2); R(-1) (-t^2 + t + 2) (-t^3 + t^2 + t + 1)])

   @test A*B == S([t^2 + 2*t + 1 2*t^2 + 4*t + 3 t^3 + t^2 + 3*t + 1; 3*t^2 - t (t^3 + 4*t^2 + t) t^4 + 2*t^2 + 2*t; t-5 t^4 + t^3 + 2*t^2 + 3*t - 4 t^5 + 1*t^4 + t^3 + t^2 + 4*t + 2])

   println("PASS")
end

function test_matrix_adhoc_binary()
   print("Matrix.adhoc_binary...")

   R, t = PolynomialRing(QQ, "t")
   S = MatrixSpace(R, 3, 3)

   A = S([t + 1 t R(1); t^2 t t; R(-2) t + 2 t^2 + t + 1])

   @test 12 + A == A + 12
   @test fmpz(11) + A == A + fmpz(11)
   @test (t + 1) + A == A + (t + 1)
   @test A - (t + 1) == -((t + 1) - A)
   @test A - 3 == -(3 - A)
   @test A - fmpz(7) == -(fmpz(7) - A)
   @test 3*A == A*3
   @test fmpz(3)*A == A*fmpz(3)
   @test (t - 1)*A == A*(t - 1)

   println("PASS")
end

function test_matrix_comparison()
   print("Matrix.comparison...")

   R, t = PolynomialRing(QQ, "t")
   S = MatrixSpace(R, 3, 3)

   A = S([t + 1 t R(1); t^2 t t; R(-2) t + 2 t^2 + t + 1])
   B = S([t + 1 t R(1); t^2 t t; R(-2) t + 2 t^2 + t + 1])

   @test A == B

   @test A != one(S)

   println("PASS")
end

function test_matrix_adhoc_comparison()
   print("Matrix.adhoc_comparison...")

   R, t = PolynomialRing(QQ, "t")
   S = MatrixSpace(R, 3, 3)

   A = S([t + 1 t R(1); t^2 t t; R(-2) t + 2 t^2 + t + 1])

   @test S(12) == 12
   @test S(5) == fmpz(5)
   @test S(t + 1) == t + 1
   @test 12 == S(12)
   @test fmpz(5) == S(5)
   @test t + 1 == S(t + 1)
   @test A != one(S)
   @test one(S) == one(S)

   println("PASS")
end

function test_matrix_powering()
   print("Matrix.powering...")

   R, t = PolynomialRing(QQ, "t")
   S = MatrixSpace(R, 3, 3)

   A = S([t + 1 t R(1); t^2 t t; R(-2) t + 2 t^2 + t + 1])

   @test A^5 == A^2*A^3

   @test A^0 == one(S)

   println("PASS")
end

function test_matrix_adhoc_exact_division()
   print("Matrix.adhoc_exact_division...")

   R, t = PolynomialRing(QQ, "t")
   S = MatrixSpace(R, 3, 3)

   A = S([t + 1 t R(1); t^2 t t; R(-2) t + 2 t^2 + t + 1])

   @test divexact(5*A, 5) == A
   @test divexact(12*A, fmpz(12)) == A
   @test divexact((1 + t)*A, 1 + t) == A

   println("PASS")
end

function test_matrix_gram()
   print("Matrix.gram...")

   R, t = PolynomialRing(QQ, "t")
   S = MatrixSpace(R, 3, 3)

   A = S([t + 1 t R(1); t^2 t t; R(-2) t + 2 t^2 + t + 1])

   @test gram(A) == S([2*t^2 + 2*t + 2 t^3 + 2*t^2 + t 2*t^2 + t - 1; t^3 + 2*t^2 + t t^4 + 2*t^2 t^3 + 3*t; 2*t^2 + t - 1 t^3 + 3*t t^4 + 2*t^3 + 4*t^2 + 6*t + 9])

   println("PASS")
end

function test_matrix_trace()
   print("Matrix.trace...")

   R, t = PolynomialRing(QQ, "t")
   S = MatrixSpace(R, 3, 3)

   A = S([t + 1 t R(1); t^2 t t; R(-2) t + 2 t^2 + t + 1])

   @test trace(A) == t^2 + 3t + 2

   println("PASS")
end

function test_matrix_content()
   print("Matrix.content...")

   R, t = PolynomialRing(QQ, "t")
   S = MatrixSpace(R, 3, 3)

   A = S([t + 1 t R(1); t^2 t t; R(-2) t + 2 t^2 + t + 1])

   @test content((1 + t)*A) == 1 + t 
   println("PASS")
end

function test_matrix()
   test_matrix_constructors()
   test_matrix_manipulation()
   test_matrix_unary_ops()
   test_matrix_binary_ops()
   test_matrix_adhoc_binary()
   test_matrix_comparison()
   test_matrix_adhoc_comparison()
   test_matrix_powering()
   test_matrix_adhoc_exact_division()
   test_matrix_gram()
   test_matrix_trace()
   test_matrix_content()

   println("")
end
