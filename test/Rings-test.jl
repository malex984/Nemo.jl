module Test

using Base.Test, Nemo, Cxx

export test_all

include("fmpz-test.jl")
include("Poly-test.jl")
include("Residue-test.jl")
include("PowerSeries-test.jl")
include("nmod_mat-test.jl")
include("nmod_poly-test.jl")

include("Fields-test.jl")

include("singular-test.jl")

function test_rings()
   test_zz()
   test_poly()
   test_residue()
   test_series()
   test_nmod_mat()
   test_nmod_poly()
end

function test_all()
   test_rings()
   test_fields()
#   test_singular()
end

end # module
