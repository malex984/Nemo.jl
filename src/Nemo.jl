function with_singular() 
   # user settings in $HOME/.julia/v0.4/Nemo/Make.user 
   # todo: move elsewhere?
   isfile(joinpath(dirname(@__FILE__), "..", "UserConfig.jl")) && include(joinpath(dirname(@__FILE__), "..", "UserConfig.jl"))
#   local const nm = joinpath(dirname(@__FILE__), "..", "UserConfig.jl")
#   include(nm)
#   print("Evaluating file: "); println(nm); local f = open(nm, "r"); while !eof(f); txt = readline(f); end; close(f)


   if !isdefined(:try_singular)
      return false
   end

   @assert isdefined(:try_singular)
   if !try_singular
      return false
   end

   # Cxx is required for Singular!
   local tempiobuffer = IOBuffer(); Pkg.status("Cxx", tempiobuffer);
   return (tempiobuffer.size!=0)
end

function _check_precompile_()
   (VERSION < v"0.4.0-dev+6521") && return false

   # for Singular we require Cxx, but Cxx does NOT support precompilation yet!
   with_singular() && return false 

   return true # Ok... let's try to precompile Nemo (without Cxx / Singular)
end

### _check_precompile_() && __precompile__()

module Nemo

import Base: Array, abs, asin, asinh, atan, atanh, base, bin, call,
             checkbounds, convert, cmp, contains, cos, cosh, dec, deepcopy,
             den, deserialize, div, divrem, exp, factor, gcd, gcdx, getindex,
             hash, hcat, hex, intersect, inv, invmod, isequal, isfinite,
             isless, isprime, isqrt, lcm, ldexp, length, log, lufact, mod,
             ndigits, nextpow2, norm, nullspace, num, oct, one, parent, parity,
             parseint, precision, prevpow2, promote_rule, rank, Rational, rem,
             reverse, serialize, setindex!, show, sign, sin, sinh, size, sqrt,
             string, sub, tan, tanh, trace, trailing_zeros, transpose,
             transpose!, truncate, typed_hvcat, typed_hcat, var, vcat, zero,
             zeros,
             +, -, *, ==, ^, &, |, $, <<, >>, ~, <=, >=, <, >, //,
             /, !=

import Base: floor, ceil, hypot, sqrt,
             log, log1p, exp, expm1, sin, cos, sinpi, cospi, tan, cot,
             sinh, cosh, tanh, coth, atan, asin, acos,
             atanh, asinh, acosh, gamma, lgamma, digamma, zeta,
             sinpi, cospi, atan2

export SetElem, GroupElem, RingElem, FieldElem, Pari, Flint, Antic,
       Generic, Singular

export PolyElem, SeriesElem, ResidueElem, FractionElem, MatElem,
       NumberFieldElem, PermElem

export ZZ, QQ, PadicField, FiniteField, NumberField, CyclotomicField,
       MaximalRealSubfield, MaximalOrder, Ideal, PermutationGroup

export create_accessors, get_handle, package_handle, allocatemem, zeros,
       Array, method_with_sig_exists

export flint_cleanup, flint_set_num_threads

export on_windows64

include("AbstractTypes.jl")

###############################################################################
#
#   Set up environment / load libraries
#
###############################################################################

const pkgdir = realpath(joinpath(dirname(@__FILE__), ".."))
const libdir = joinpath(pkgdir, "local", "lib")
const libgmp = joinpath(pkgdir, "local", "lib", "libgmp")
const libmpfr = joinpath(pkgdir, "local", "lib", "libmpfr")
const libflint = joinpath(pkgdir, "local", "lib", "libflint")
const libpari = joinpath(pkgdir, "local", "lib", "libpari")
const libarb = joinpath(pkgdir, "local", "lib", "libarb")
const libsingular = joinpath(pkgdir, "local", "lib", "libSingular")

# default config
try_singular = true # false

# isfile(joinpath(pkgdir, "UserConfig.jl")) && include(joinpath(pkgdir, "UserConfig.jl"))
  
function allocatemem(bytes::Int)
   newsize = pari(fmpz(bytes)).d
   ccall((:gp_allocatemem, :libpari), Void, (Ptr{Int},), newsize)
end

function pari_sigint_handler()
   error("User interrupt")
   return
end

const on_windows64 = (@windows ? true : false) && (Int == Int64)

function with_singular() 
   # user settings in $HOME/.julia/v0.4/Nemo/Make.user 
   # todo: move elsewhere?
#   local const nm = joinpath(dirname(@__FILE__), "..", "UserConfig.jl")
#   if isfile(nm)
#      include(nm)
#      print("Evaluating file: "); println(nm); local f = open(nm, "r"); while !eof(f); txt = readline(f); end; close(f)
#   end
#   if !isdefined(:try_singular)
#      return false
#   end

#   @assert isdefined(:try_singular)

   local tempiobuffer = IOBuffer(); Pkg.status("Cxx", tempiobuffer);
   return ((tempiobuffer.size!=0) ) # && try_singular
end

function __init__()
#   @assert isdefined(:try_singular)
    @assert with_singular()

   on_windows = @windows ? true : false
   on_linux = @linux ? true : false

   if "HOSTNAME" in keys(ENV) && ENV["HOSTNAME"] == "juliabox"
       push!(Libdl.DL_LOAD_PATH, "/usr/local/lib")
   elseif on_linux
       push!(Libdl.DL_LOAD_PATH, libdir)
       Libdl.dlopen(libgmp)
       Libdl.dlopen(libmpfr)
       Libdl.dlopen(libflint)
       Libdl.dlopen(libpari)
       Libdl.dlopen(libarb)

       with_singular() && Libdl.dlopen(libsingular,Libdl.RTLD_GLOBAL)
   else
      push!(Libdl.DL_LOAD_PATH, libdir)
   end
 
   ccall((:pari_set_memory_functions, libpari), Void,
      (Ptr{Void},Ptr{Void},Ptr{Void},Ptr{Void}),
      cglobal(:jl_malloc),
      cglobal(:jl_calloc),
      cglobal(:jl_realloc),
      cglobal(:jl_free))

   ccall((:pari_init, libpari), Void, (Int, Int), 300000000, 10000)
  
   global avma = cglobal((:avma, libpari), Ptr{Int})

   global gen_0 = cglobal((:gen_0, libpari), Ptr{Int})

   global gen_1 = cglobal((:gen_1, libpari), Ptr{Int})

   global pari_sigint = cglobal((:cb_pari_sigint, libpari), Ptr{Void})

   unsafe_store!(pari_sigint, cfunction(pari_sigint_handler, Void, ()), 1)

   ccall((:__gmp_set_memory_functions, libgmp), Void,
      (Ptr{Void},Ptr{Void},Ptr{Void}),
      cglobal(:jl_gc_counted_malloc),
      cglobal(:jl_gc_counted_realloc_with_old_size),
      cglobal(:jl_gc_counted_free))

   ccall((:__flint_set_memory_functions, libflint), Void,
      (Ptr{Void},Ptr{Void},Ptr{Void},Ptr{Void}),
      cglobal(:jl_malloc),
      cglobal(:jl_calloc),
      cglobal(:jl_realloc),
      cglobal(:jl_free))

   with_singular() && __singular_init__()

   println("")
   println("Welcome to Nemo version 0.4.0")
   println("")
   println("Nemo comes with absolutely no warranty whatsoever")
   println("")
end

function flint_set_num_threads(a::Int)
   ccall((:flint_set_num_threads, libflint), Void, (Int,), a)
end

function flint_cleanup()
   ccall((:flint_cleanup, libflint), Void, ())
end

###############################################################################
#
#   Load Nemo Rings/Fields/etc
#
###############################################################################

include("generic/GenericTypes.jl")

include("flint/FlintTypes.jl")

include("antic/AnticTypes.jl")

include("arb/ArbTypes.jl")

include("pari/PariTypes.jl")

with_singular() && include("singular/SingularTypes.jl")

include("Groups.jl")

###########################################################
#
#   Package handle creation
#
###########################################################

const package_handle = [1]

function get_handle()
   package_handle[1] += 1
   return package_handle[1] - 1
end

###############################################################################
#
#   Auxilliary data accessors
#
###############################################################################

function create_accessors(T, S, handle)
   accessor_name = gensym()
   @eval begin
      function $(symbol(:get, accessor_name))(a::$T)
         return a.auxilliary_data[$handle]::$S
      end,
      function $(symbol(:set, accessor_name))(a::$T, b::$S)
         if $handle > length(a.auxilliary_data)
            resize(a.auxilliary_data, $handle)
         end
         a.auxilliary_data[$handle] = b
      end
   end
end

###############################################################################
#
#   Array creation functions
#
###############################################################################

Array(R::Ring, r::Int...) = Array(elem_type(R), r)

function zeros(R::Ring, r::Int...)
   T = elem_type(R)
   A = Array(T, r)
   for i in eachindex(A)
      A[i] = R()
   end
   return A
end

###############################################################################
#
#   Set domain for PermutationGroup to Flint
#
###############################################################################

PermutationGroup = FlintPermGroup

###############################################################################
#
#   Set domain for ZZ, QQ, PadicField, FiniteField to Flint
#
###############################################################################

ZZ = FlintZZ
QQ = FlintQQ
PadicField = FlintPadicField
FiniteField = FlintFiniteField

###############################################################################
#
#   Set domain for NumberField to Antic
#
###############################################################################

NumberField = AnticNumberField
CyclotomicField = AnticCyclotomicField
MaximalRealSubfield = AnticMaximalRealSubfield

###############################################################################
#
#   Set domain for MaximalOrder and Ideal to Pari
#
###############################################################################

MaximalOrder = PariMaximalOrder
Ideal = PariIdeal

###############################################################################
#
#   Test code
#
###############################################################################

include("../test/Nemo-test.jl")

include("../benchmarks/runbenchmarks.jl")

end # module
