module Test

using Base.Test, Nemo

export test_all

include("Groups-test.jl")
include("Rings-test.jl")
include("Fields-test.jl")
include("Benchmark-test.jl")

Nemo.with_singular() && include("singular/all-tests.jl")

function test_all()

   Nemo.with_singular() && test_singular()
#   Nemo.with_singular() && Nemo.toggle_uq_default_choice()
#   Nemo.with_singular() && test_singular()

   gc()

   test_groups(); test_rings(); test_fields(); test_benchmarks()

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

   gc()
   Nemo.with_singular() && Nemo.libSingular.omPrintInfoStats()
end

end # module
