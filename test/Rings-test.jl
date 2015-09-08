module Test

using Base.Test, Nemo

export test_all

include("flint/fmpz-test.jl")
include("flint/fmpz_poly-test.jl")
include("flint/fmpz_mod_poly-test.jl")
include("flint/nmod_poly-test.jl")

include("generic/Poly-test.jl")
include("generic/Residue-test.jl")

include("PowerSeries-test.jl")
include("nmod_mat-test.jl")
include("Fields-test.jl")

function test_pkg_status(pkg)
   tempiobuffer = IOBuffer(); 
   Pkg.status(pkg, tempiobuffer);
   return (tempiobuffer.size != 0);
end
   
if( test_pkg_status("Cxx") )
   include("singular-test.jl");
else
   test_singular() = println("\n\nIt appears that package 'Cxx' required for wrapping Singular (C++ code!) is missing! :(");
end

function test_rings()
   test_fmpz()
   test_fmpz_poly()
   test_fmpz_mod_poly()
   test_nmod_poly()

   test_poly()
   test_residue()

   test_series()
   test_nmod_mat()
end

function test_all()
   test_rings()
   test_fields()
   test_singular()
end

end # module
