module Test

using Base.Test, Nemo

export test_all

include("fmpz-test.jl")
include("Poly-test.jl")
include("Residue-test.jl")
include("PowerSeries-test.jl")
include("nmod_mat-test.jl")
include("nmod_poly-test.jl")

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
   test_singular()
end

end # module
