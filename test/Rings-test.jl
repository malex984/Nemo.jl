include("flint/fmpz-test.jl")
include("flint/fmpz_poly-test.jl")
include("flint/fmpz_mod_poly-test.jl")
include("flint/nmod_poly-test.jl")
include("flint/fmpq_poly-test.jl")
include("flint/fq_poly-test.jl")
include("flint/fq_nmod_poly-test.jl")
include("flint/fmpz_series-test.jl")
include("flint/fmpq_series-test.jl")
include("flint/fmpz_mod_series-test.jl")
include("flint/fq_series-test.jl")
include("flint/fq_nmod_series-test.jl")
include("flint/nmod_mat-test.jl")
include("flint/fmpz_mat-test.jl")

include("pari/pari_maximal_order_elem-test.jl")
include("pari/PariIdeal-test.jl")

include("generic/Poly-test.jl")
include("generic/Residue-test.jl")
include("generic/PowerSeries-test.jl")
include("generic/Matrix-test.jl")

function test_rings()

   test_fmpz()
   test_fmpz_poly()
   test_fmpz_mod_poly()
   test_nmod_poly()
   test_fmpq_poly()
   test_fq_poly()
   test_fq_nmod_poly()
   test_fmpz_series()
   test_fmpq_series()
   test_fmpz_mod_series()
   test_fq_series()
   test_fq_nmod_series()

   test_pari_maximal_order_elem()
   test_PariIdeal()

   test_poly()
   test_residue()
   test_series()
   test_matrix()
   test_nmod_mat()
   test_fmpz_mat()

#   if Nemo.with_singular()
#      for (c,nn) in Nemo.leftovers
#         println(c); println("Numbers: ")
#         
#         for (k,v) in nn
#            if (v > 1)
#                 println(k, "   ====>>>>   ", v)
#            end
#         end
#             
#	 println()
#     end
#   end

end

