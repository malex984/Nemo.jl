function randelem(R::Nemo.SingularCoeffs, n :: Int)

   s = R(rand(-n:n))
   
   const p = Nemo.ngens(R)
   if p > 0
      for i = 1:p
         x = Nemo.geni(i, R)
      	 for j = 1:2
             s += R(rand(-n:n)) * (x^j)
      	 end  
      end
   end
   return s
end

function randelem(R::ResidueRing{Nemo.Singular_ZZElem}, n)
   return R(rand(-n:n))
end

#### TODO: FIXME: gen for all Singular Coeffs (return 0 if no params, or the first param by default...)
#### TODO: moreover it seems that in case of params - there *must* be a base_ring != None!!?! 

function test_matrix_constructors_singular()
   print("Matrix.constructors / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();
 
   R, t = PolynomialRing(QQ, "t")
   S = MatrixSpace(R, 3, 3)

   @test typeof(S) <: MatrixSpace

   f = S(t^2 + 1)

   @test isa(f, MatElem)

   g = S(2)

   @test isa(g, MatElem)

   h = S(QQ(23))

   @test isa(h, MatElem)

   k = S([t t + 2 t^2 + 3t + 1; 2t R(2) t + 1; t^2 + 2 t + 1 R(0)])

   @test isa(k, MatElem)

   l = S(k)

   @test isa(l, MatElem)

   m = S()

   @test isa(m, MatElem)

   println("PASS")
end

function test_matrix_manipulation_singular()
   print("Matrix.manipulation / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

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

function test_matrix_unary_ops_singular()
   print("Matrix.unary_ops / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   R, t = PolynomialRing(QQ, "t")
   S = MatrixSpace(R, 3, 3)

   A = S([t + 1 t R(1); t^2 t t; R(-2) t + 2 t^2 + t + 1])
   B = S([-t - 1 (-t) -R(1); -t^2 (-t) (-t); -R(-2) (-t - 2) (-t^2 - t - 1)])

   @test -A == B

   println("PASS")
end

function test_matrix_binary_ops_singular()
   print("Matrix.binary_ops / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   R, t = PolynomialRing(QQ, "t")
   S = MatrixSpace(R, 3, 3)

   A = S([t + 1 t R(1); t^2 t t; R(-2) t + 2 t^2 + t + 1])
   B = S([R(2) R(3) R(1); t t + 1 t + 2; R(-1) t^2 t^3])

   @test A + B == S([t+3 t+3 R(2); t^2 + t 2*t+1 2*t+2; R(-3) t^2 + t + 2 t^3 + 1*t^2 + t + 1])

   @test A - B == S([t-1 t-3 R(0); t^2 - t R(-1) R(-2); R(-1) (-t^2 + t + 2) (-t^3 + t^2 + t + 1)])

   @test A*B == S([t^2 + 2*t + 1 2*t^2 + 4*t + 3 t^3 + t^2 + 3*t + 1; 3*t^2 - t (t^3 + 4*t^2 + t) t^4 + 2*t^2 + 2*t; t-5 t^4 + t^3 + 2*t^2 + 3*t - 4 t^5 + 1*t^4 + t^3 + t^2 + 4*t + 2])

   println("PASS")
end

function test_matrix_adhoc_binary_singular()
   print("Matrix.adhoc_binary / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   R, t = PolynomialRing(QQ, "t")
   S = MatrixSpace(R, 3, 3)

   A = S([t + 1 t R(1); t^2 t t; R(-2) t + 2 t^2 + t + 1])

   @test 12 + A == A + 12
   @test QQ(11) + A == A + QQ(11)
   @test (t + 1) + A == A + (t + 1)
   @test A - (t + 1) == -((t + 1) - A)
   @test A - 3 == -(3 - A)
   @test A - QQ(7) == -(QQ(7) - A)
   @test 3*A == A*3
   @test QQ(3)*A == A*QQ(3)
   @test (t - 1)*A == A*(t - 1)

   println("PASS")
end

function test_matrix_permutation_singular()
   print("Matrix.permutation / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   R, t = PolynomialRing(QQ, "t")
   S = MatrixSpace(R, 3, 3)

   A = S([t + 1 t R(1); t^2 t t; R(-2) t + 2 t^2 + t + 1])

   T = PermutationGroup(3)
   P = T([2, 3, 1])

   @test A == inv(P)*(P*A)

   println("PASS")
end

function test_matrix_comparison_singular()
   print("Matrix.comparison / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   R, t = PolynomialRing(QQ, "t")
   S = MatrixSpace(R, 3, 3)

   A = S([t + 1 t R(1); t^2 t t; R(-2) t + 2 t^2 + t + 1])
   B = S([t + 1 t R(1); t^2 t t; R(-2) t + 2 t^2 + t + 1])

   @test A == B

   @test A != one(S)

   println("PASS")
end

function test_matrix_adhoc_comparison_singular()
   print("Matrix.adhoc_comparison / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   R, t = PolynomialRing(QQ, "t")
   S = MatrixSpace(R, 3, 3)

   A = S([t + 1 t R(1); t^2 t t; R(-2) t + 2 t^2 + t + 1])

   @test S(12) == 12
   @test S(5) == QQ(5)
   @test S(t + 1) == t + 1
   @test 12 == S(12)
   @test QQ(5) == S(5)
   @test t + 1 == S(t + 1)
   @test A != one(S)
   @test one(S) == one(S)

   println("PASS")
end

function test_matrix_powering_singular()
   print("Matrix.powering / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   R, t = PolynomialRing(QQ, "t")
   S = MatrixSpace(R, 3, 3)

   A = S([t + 1 t R(1); t^2 t t; R(-2) t + 2 t^2 + t + 1])

   @test A^5 == A^2*A^3

   @test A^0 == one(S)

   println("PASS")
end

function test_matrix_adhoc_exact_division_singular()
   print("Matrix.adhoc_exact_division / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   R, t = PolynomialRing(QQ, "t")
   S = MatrixSpace(R, 3, 3)

#   println(S)

   A = S([t + 1 t R(1); t^2 t t; R(-2) t + 2 t^2 + t + 1])
#   println("A: \n", A)

#   println("5A/5: \n", divexact(5*A, 5))	
   @test divexact(5*A, 5) == A

#   println("A*(1+t)/(1+t): \n", divexact((1 + t)*A, 1 + t))
   @test divexact((1 + t)*A, 1 + t) == A

#   print("12A/(12): ")
   a = divexact(12*A, (12))
#   println("  :::  ")
#   println(a)
   @test a == A

#   print("12A/R(12): ")
   a = divexact(12*A, R(12))
#   println("  :::  ")
#   println(a)
   @test a == A




#   print("12A/ZZ|QQ(12): ")
#   a = divexact(12*A, ZZ(12)) ## TODO: FIXME: ZZ & QQ do not work here :(
#   a = divexact(12*A, QQ(12)) ## TODO: FIXME: ZZ & QQ do not work here :(

   println("PASS?")
end

function test_matrix_gram_singular()
   print("Matrix.gram / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   R, t = PolynomialRing(QQ, "t")
   S = MatrixSpace(R, 3, 3)

   A = S([t + 1 t R(1); t^2 t t; R(-2) t + 2 t^2 + t + 1])

   @test gram(A) == S([2*t^2 + 2*t + 2 t^3 + 2*t^2 + t 2*t^2 + t - 1; t^3 + 2*t^2 + t t^4 + 2*t^2 t^3 + 3*t; 2*t^2 + t - 1 t^3 + 3*t t^4 + 2*t^3 + 4*t^2 + 6*t + 9])

   println("PASS")
end

function test_matrix_trace_singular()
   print("Matrix.trace / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   R, t = PolynomialRing(QQ, "t")
   S = MatrixSpace(R, 3, 3)

   A = S([t + 1 t R(1); t^2 t t; R(-2) t + 2 t^2 + t + 1])

   @test trace(A) == t^2 + 3t + 2

   println("PASS")
end

function test_matrix_content_singular()
   print("Matrix.content / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   R, t = PolynomialRing(QQ, "t")
   S = MatrixSpace(R, 3, 3)

   A = S([t + 1 t R(1); t^2 t t; R(-2) t + 2 t^2 + t + 1])

   @test content((1 + t)*A) == 1 + t 
   println("PASS")
end



function test_matrix_determinant_singular()
   print("Matrix.determinant / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, z = PolynomialRing(ZZ, "z")
#   println(S)

   for dim = 0:10
      R = MatrixSpace(S, dim, dim)
#      println(R)
      M = randmat(R, 3, 20)
#      println(M)
      @test determinant(M) == Nemo.determinant_clow(M)
   end

   S, x = PolynomialRing(ResidueRing(ZZ, ZZ(1009)*ZZ(2003)), "x")
#   println(S)
   for dim = 0:10
      R = MatrixSpace(S, dim, dim)
#      println(R)
      M = randmat(R, 5, 100)
#      println(M)
      @test determinant(M) == Nemo.determinant_clow(M)
   end



   R, x = PolynomialRing(ZZ, "x");
   S, y = PolynomialRing(R , "y");
#   println(S)
   for dim = 0:10
      T = MatrixSpace(S, dim, dim)
#      println(T)
      M = randmat(T, 20)
#      println(M)
      @test determinant(M) == Nemo.determinant_clow(M)
   end


   R, x = PolynomialRing(QQ, "x")
#   K, a = NumberField(x^3 + 3x + 1, "a")
   for dim = 0:5# 10
#      S = MatrixSpace(K, dim, dim)
      S = MatrixSpace(R, dim, dim)
#      println(S)
      M = randmat(S, 100)
#      println(M)
      @test determinant(M) == Nemo.determinant_clow(M)
   end

   println("PASS??")
end

function test_matrix_rank_singular()
   print("Matrix.rank / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, z = PolynomialRing(ZZ, "z")
   R = MatrixSpace(S, 4, 4)

   M = R([S(-2) S(0) S(5) S(3); 5*z^2+5*z-5 S(0) S(-z^2+z) 5*z^2+5*z+1; 2*z-1 S(0) z^2+3*z+2 S(-4*z); 3*z-5 S(0) S(-5*z+5) S(1)])

   @test rank(M) == 3

   R = MatrixSpace(S, 5, 5)

   for i = 0:5
      M = randmat_with_rank(R, 3, 20, i)

      @test rank(M) == i
   end

#   R, x = PolynomialRing(QQ, "x")
#   K, a = NumberField(x^3 + 3x + 1, "a")
#   S = MatrixSpace(K, 3, 3)
#   M = S([a a^2 + 2*a - 1 2*a^2 - 1*a; 2*a+2 2*a^2 + 2*a (-2*a^2 - 2*a); (-a) (-a^2) a^2])
#   @test rank(M) == 2
#   S = MatrixSpace(K, 5, 5)
#   for i = 0:5
#      M = randmat_with_rank(S, 100, i)
#      @test rank(M) == i
#   end

   R, x = PolynomialRing(ZZ, "x")
   S, y = PolynomialRing(R, "y")
   T = MatrixSpace(S, 3, 3)

   M = T([(2*x^2)*y^2+(-2*x^2-2*x)*y+(-x^2+2*x) S(0) (-x^2-2)*y^2+(x^2+2*x+2)*y+(2*x^2-x-1); 
    (-x)*y^2+(-x^2+x-1)*y+(x^2-2*x+2) S(0) (2*x^2+x-1)*y^2+(-2*x^2-2*x-2)*y+(x^2-x);
    (-x+2)*y^2+(x^2+x+1)*y+(-x^2+x-1) S(0) (-x^2-x+2)*y^2+(-x-1)*y+(-x-1)])

   @test rank(M) == 2

   T = MatrixSpace(S, 5, 5)

   for i = 0:5
      M = randmat_with_rank(T, 20, i)

      @test rank(M) == i
   end

   S, x = PolynomialRing(ResidueRing(ZZ, ZZ(1009)*ZZ(2003)), "x")
   R = MatrixSpace(S, 3, 3)

   M = R([S(3) S(2) S(1); S(2021024) S(2021025) S(2021026); 3*x^2+5*x+2021024 2021022*x^2+4*x+5 S(2021025)])

   @test rank(M) == 2

   S, x = PolynomialRing(ResidueRing(ZZ, ZZ(20011)*ZZ(10007)), "x")
   R = MatrixSpace(S, 5, 5)

   for i = 0:5
      M = randmat_with_rank(R, 5, 100, i);  ### TODO: FIXME ????!!!!

      @test rank(M) == i
   end


   println("PASS")   
end

function test_matrix_solve_singular()
   print("Matrix.solve / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, z = PolynomialRing(ZZ, "z")

   for dim = 0:10
      R = MatrixSpace(S, dim, dim)
      U = MatrixSpace(S, dim, rand(1:5))

      M = randmat_with_rank(R, 3, 20, dim);
      b = randmat(U, 3, 20);

      x, d = solve(M, b)

      @test M*x == d*b
   end

#   R, x = PolynomialRing(QQ, "x")
#   K, a = NumberField(x^3 + 3x + 1, "a")
#  
#   for dim = 0:10
#      S = MatrixSpace(K, dim, dim)
#      U = MatrixSpace(K, dim, rand(1:5))
#
#      M = randmat_with_rank(S, 100, dim);
#      b = randmat(U, 100);
#
#      x = solve(M, b)
#
#      @test M*x == b
#   end

   R, x = PolynomialRing(ZZ, "x")
   S, y = PolynomialRing(R, "y")
   
   for dim = 0:10
      T = MatrixSpace(S, dim, dim)
      U = MatrixSpace(S, dim, rand(1:5))
     
      M = randmat_with_rank(T, 20, dim)
      b = randmat(U, 20)
 
      x, d = solve(M, b)

      @test M*x == d*b
   end

#   R, t = PolynomialRing(QQ, "t")
#   K, a = NumberField(t^3 + 3t + 1, "a")
#   S, y = PolynomialRing(K, "y")
#   T = MatrixSpace(S, 3, 3)
#   U = MatrixSpace(S, 3, 1)
#
#   M = T([3y*a^2 + (y + 1)*a + 2y (5y+1)*a^2 + 2a + y - 1 a^2 + (-a) + 2y; (y + 1)*a^2 + 2y - 4 3y*a^2 + (2y - 1)*a + y (4y - 1)*a^2 + (y - 1)*a + 5; 2a + y + 1 (2y + 2)*a^2 + 3y*a + 3y a^2 + (-y-1)*a + (-y - 3)])
#   b = U([4y*a^2 + 4y*a + 2y + 1 5y*a^2 + (2y + 1)*a + 6y + 1 (y + 1)*a^2 + 3y*a + 2y + 4]')
#
#   x, d = solve(M, b)
#
#   @test M*x == d*b




   S, x = PolynomialRing(ResidueRing(ZZ, ZZ(20011)*ZZ(10007)), "x")

   for dim = 0:10
      R = MatrixSpace(S, dim, dim)
      U = MatrixSpace(S, dim, rand(1:5))

      M = randmat_with_rank(R, 5, 100, dim);
      b = randmat(U, 5, 100);

      x, d = solve(M, b)

      @test M*x == d*b
   end


   println("PASS")
end

function test_matrix_rref_singular()
   print("Matrix.rref / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, z = PolynomialRing(ZZ, "z")
   R = MatrixSpace(S, 5, 5)

   for i = 0:5
      M = randmat_with_rank(R, 3, 20, i)

      r, d, A = rref(M)

      @test r == i
      @test is_rref(A)
   end

#   R, x = PolynomialRing(QQ, "x")
#   K, a = NumberField(x^3 + 3x + 1, "a")
#   S = MatrixSpace(K, 5, 5)
#   for i = 0:5
#      M = randmat_with_rank(S, 100, i)
#      r, A = rref(M)
#      @test r == i
#      @test is_rref(A)
#   end

   R, x = PolynomialRing(ZZ, "x")
   S, y = PolynomialRing(R, "y")
   T = MatrixSpace(S, 5, 5)

   for i = 0:5
      M = randmat_with_rank(T, 20, i)

      r, d, A = rref(M)

      @test r == i
      @test is_rref(A)
   end

   S, x = PolynomialRing(ResidueRing(ZZ, ZZ(20011)*ZZ(10007)), "x")
   R = MatrixSpace(S, 5, 5)
   for i = 0:5
      M = randmat_with_rank(R, 5, 100, i)
      r, d, A = rref(M)
      @test r == i
      @test is_rref(A)
   end

   println("PASS")   
end

function test_matrix_nullspace_singular()
   print("Matrix.nullspace / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   R, x = PolynomialRing(ZZ, "x")
   S, y = PolynomialRing(R, "y")

   T = MatrixSpace(S, 5, 5)
#   println(T)

   for i = 0:5
   
      M = randmat_with_rank(T, 20, i)
#      println(i, "  :::  ", M)

      n, N = nullspace(M)   # TODO: BUG for i == 2?!

#      println(n);      println(N);

      @test n == 5 - i
      @test rank(N) == n
      @test iszero(M*N)
   end


   S, z = PolynomialRing(ZZ, "z")
   R = MatrixSpace(S, 5, 5)

   for i = 0:5
      M = randmat_with_rank(R, 3, 20, i)
#      println(M)

      n, N = nullspace(M)

      @test n == 5 - i
      @test rank(N) == n
      @test iszero(M*N)
   end

   S, x = PolynomialRing(ResidueRing(ZZ, ZZ(20011)*ZZ(10007)), "x")
   R = MatrixSpace(S, 5, 5)
#   println(R)

   for i = 0:5
      M = randmat_with_rank(R, 5, 100, i)
#      println(i, "  :::  ", M)

      n, N = nullspace(M)
      @test n == 5 - i
      @test rank(N) == n
      @test iszero(M*N)
   end


#   R, x = PolynomialRing(QQ, "x")
#   K, a = NumberField(x^3 + 3x + 1, "a") #### ????
#   S = MatrixSpace(K, 5, 5)
#   for i = 0:5
#      M = randmat_with_rank(S, 100, i)
#      n, N = nullspace(M)
#      @test n == 5 - i
#      @test rank(N) == n
#      @test iszero(M*N)
#   end


   println("PASS")   
end

function test_matrix_inversion_singular()
   print("Matrix.inversion / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   S, x = PolynomialRing(ResidueRing(ZZ, ZZ(20011)*ZZ(10007)), "x")
#   println(S)

   for dim = 1:10
      R = MatrixSpace(S, dim, dim)
#      println(R)
      
      M = randmat_with_rank(R, 5, 100, dim);
#      println(M)
      
      X, d = inv(M)

      @test M*X == d*one(R)
   end

   S, z = PolynomialRing(ZZ, "z")
#   println(S)

   for dim = 1:10
      R = MatrixSpace(S, dim, dim)
#      println(R)
      
      M = randmat_with_rank(R, 3, 20, dim);
#      println(M)
      
      X, d = inv(M)

      @test M*X == d*one(R)
   end

#   R, x = PolynomialRing(QQ, "x")
#   K, a = NumberField(x^3 + 3x + 1, "a") ##### ??????
#   for dim = 1:10
#      S = MatrixSpace(K, dim, dim)
#      M = randmat_with_rank(S, 100, dim);
#      X = inv(M)
#      @test isone(M*X)
#   end

   R, x = PolynomialRing(ZZ, "x")
   S, y = PolynomialRing(R, "y")
#   println(S)
   
   for dim = 1:10
      T = MatrixSpace(S, dim, dim)
#      println(T)
     
      M = randmat_with_rank(T, 20, dim)
#      println(M)
  
      X, d = inv(M)

      @test M*X == d*one(T)
   end

   println("PASS")   
end

function test_matrix_hessenberg_singular()
   print("Matrix.hessenberg / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   R = ResidueRing(ZZ, ZZ(18446744073709551629)) ## BigInt???

   for dim = 0:5
      S = MatrixSpace(R, dim, dim)
      U, x = PolynomialRing(R, "x")

      for i = 1:10
         M = randmat(S, 5)

         A = hessenberg(M)

         @test is_hessenberg(A)
      end
   end

   println("PASS")   
end

function test_matrix_charpoly_singular()
   print("Matrix.charpoly / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   R, x = PolynomialRing(ZZ, "x")
   U, z = PolynomialRing(R, "z")
   T = MatrixSpace(R, 6, 6)

   M = T()
   for i = 1:3
      for j = 1:3
         M[i, j] = randelem(R, 10)
         M[i + 3, j + 3] = deepcopy(M[i, j])
      end
   end

   p1 = charpoly(U, M)

   for i = 1:1#0
      similarity!(M, rand(1:rows(M)), randelem(R, 3)) # R(...)?
   end

   p2 = charpoly(U, M)

   @test p1 == p2

   println("PASS")   

   return 


   R = ResidueRing(ZZ, ZZ(18446744073709551629))

   for dim = 0:5
      S = MatrixSpace(R, dim, dim)
      U, x = PolynomialRing(R, "x")

      for i = 1:10
         M = randmat(S, 5)

         p1 = charpoly(U, M)
         p2 = charpoly_danilevsky!(U, M)

         @test p1 == p2
      end

      for i = 1:10
         M = randmat(S, 5)

         p1 = charpoly(U, M)
         p2 = charpoly_danilevsky_ff!(U, M)

         @test p1 == p2
      end

      for i = 1:10
         M = randmat(S, 5)

         p1 = charpoly(U, M)
         p2 = charpoly_hessenberg!(U, M)

         @test p1 == p2
      end
   end

end


   function test_minpoly(T, M, m)
      p = minpoly(T, M)
      if p != m
      	 println("T: ", T)
	 println("M: ", M)
      	 println("m: ", m)
         println("p: ", p)
	 println("diff: ", p - m, " :: iszero?: ", iszero(p - m))
      end
      @test p == m
   end

function test_matrix_minpoly_singular()
   print("Matrix.minpoly / Singular Coeffs...")
 
   const ZZ = Nemo.SingularZZ();
   const QQ = Nemo.SingularQQ();

   R, x = PolynomialRing(ZZ, "x")
   S, y = PolynomialRing(R, "y")
   T = MatrixSpace(S, 6, 6)

#   println(T)

   M = T()
   for i = 1:3
      for j = 1:3
         M[i, j] = randelem(S, 10)
         M[i + 3, j + 3] = deepcopy(M[i, j])
      end
   end

#   println(M);
   U, z = PolynomialRing(S, "z")
   f = minpoly(U, M)
#   println(f)

   @test degree(f) <= 3

   R, x = PolynomialRing(ZZ, "x")
   T = MatrixSpace(R, 6, 6)

#   println(T);
   M = T()
   for i = 1:3
      for j = 1:3
         M[i, j] = randelem(R, 10)
         M[i + 3, j + 3] = deepcopy(M[i, j])
      end
   end

   U, z = PolynomialRing(R, "z")
   
#   println(U);
#   println("M: ",M);
   p1 = minpoly(U, M)
#   println("p1: ", p1);
#   println()
 
   for i = 1:1#10? 2 - already tooooo long!!! TODO: FIXME!!!
      similarity!(M, rand(1:rows(M)), randelem(R, 3))# R()??
   end

#   println("simlarity! M: ", M);
   p2 = minpoly(U, M)
#   println("p2: ", p2);

   @test p1 == p2




   R = Nemo.SingularFp(103) # FiniteField(103, 1, "x")
#   println(R)
#   println("Fp: ", R, " @ ", typeof(R));
#   println("Fp(1): ", one(R), " @ ", typeof(one(R)));

   T, y = PolynomialRing(R, "y")

#   println("Fp[y]: ", T, " @ ", typeof(T));
#   println("y @ ", typeof(y));

   M = R[92 97 8;
          0 5 13;
          0 16 2]

#   test_minpoly(T, M, y^2+96*y+8)
   @test minpoly(T, M) == y^2+96*y+8 ###TODO: FIXME: test failed: y^3+23*y^2-30*y-31 == y^2-7*y+8 :((((

   R = Nemo.SingularFp(3) # FiniteField(3, 1, "x")
   T, y = PolynomialRing(R, "y")

   M = R[1 2 0 2;
         1 2 1 0;
         1 2 2 1;
         2 1 2 0]

   @test minpoly(T, M) == y^2 + 2y
#   test_minpoly(T, M, y^2 + 2y)

   R = Nemo.SingularFp(13) # FiniteField(13, 1, "x")
   T, y = PolynomialRing(R, "y")

   M = R[7 6 1;
         7 7 5;
         8 12 5]

   @test minpoly(T, M) == y^2+10*y
#   test_minpoly(T, M, y^2+10*y)

   M = R[4 0 9 5;
         1 0 1 9;
         0 0 7 6;
         0 0 3 10]

   @test minpoly(T, M) == y^2 + 9y
#   test_minpoly(T, M,  y^2 + 9y)

   M = R[2 7 0 0 0 0;
         1 0 0 0 0 0;
         0 0 2 7 0 0;
         0 0 1 0 0 0;
         0 0 0 0 4 3;
         0 0 0 0 1 0]

   @test minpoly(T, M) == (y^2+9*y+10)*(y^2+11*y+6)
#   test_minpoly(T, M, (y^2+9*y+10)*(y^2+11*y+6) )

   M = R[2 7 0 0 0 0;
         1 0 1 0 0 0;
         0 0 2 7 0 0;
         0 0 1 0 0 0;
         0 0 0 0 4 3;
         0 0 0 0 1 0]

   @test minpoly(T, M) == (y^2+9*y+10)*(y^2+11*y+6)^2
#   test_minpoly(T, M, (y^2+9*y+10)*(y^2+11*y+6)^2)

   S = MatrixSpace(R, 1, 1)
   M = S()

   @test minpoly(T, M) == y
#   test_minpoly(T, M, y)

   S = MatrixSpace(R, 0, 0)
   M = S()

   @test minpoly(T, M) == 1
#   test_minpoly(T, M, 1)


   println("PASS")   
end

function test_matrix_singular()

   test_matrix_nullspace_singular()
   test_matrix_minpoly_singular()
   test_matrix_determinant_singular()
###################################################### Wrong Singular numbers:
   test_matrix_hessenberg_singular() ## ?
   test_matrix_rref_singular()
   test_matrix_solve_singular()
   test_matrix_inversion_singular()

   test_matrix_constructors_singular()
   test_matrix_manipulation_singular()
   test_matrix_unary_ops_singular()
   test_matrix_binary_ops_singular()
   test_matrix_adhoc_binary_singular()
   test_matrix_permutation_singular()
   test_matrix_comparison_singular()
   test_matrix_adhoc_comparison_singular()
   test_matrix_powering_singular()
   test_matrix_gram_singular()
   test_matrix_trace_singular()
   test_matrix_content_singular()
   test_matrix_charpoly_singular()
   test_matrix_adhoc_exact_division_singular() # ?

   test_matrix_rank_singular() ## ?!

   println("")
end
#   test_matrix_lufact_singular() #   test_matrix_fflu_singular() # NumericField