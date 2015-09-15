module Nemo

import Base: abs, asin, asinh, atan, atanh, base, bin, call, checkbounds,
             convert, cmp, cos, cosh, dec, deepcopy, den, deserialize, div,
             divrem, exp, factor, gcd, gcdx, getindex, hash, hex, inv, invmod,
             isequal, isless, isprime, isqrt, lcm, length, log, lufact, mod,
             ndigits, nextpow2, norm, nullspace, num, oct, one, parent,
             parseint, precision, prevpow2, promote_rule, rank, Rational, rem,
             reverse, serialize, setindex!, show, sign, sin, sinh, size, sqrt,
             string, sub, tan, tanh, trace, trailing_zeros, transpose,
             transpose!, truncate, var, zero

export Collection, Ring, Field, CollectionElem, RingElem, FieldElem, Pari,
       Flint, Antic, Singular, Generic

export PolyElem, SeriesElem, ResidueElem, FractionElem, MatElem,
       NumberFieldElem

export ZZ, QQ, PadicField, FiniteField, NumberField, CyclotomicField,
       MaximalRealSubfield, MaximalOrder, Ideal

export create_accessors, get_handle, package_handle

include("AbstractTypes.jl")

###############################################################################
#
#   Set up environment / load libraries
#
###############################################################################

pkgdir = Pkg.dir("Nemo")

const on_windows = @windows ? true : false
const on_linux = @linux ? true : false

function test_pkg_status(pkg)
   tempiobuffer = IOBuffer(); 
   Pkg.status(pkg, tempiobuffer);
   return (tempiobuffer.size != 0);
end
   
const with_cxx = test_pkg_status("Cxx")

if on_windows
   push!(Libdl.DL_LOAD_PATH, "$pkgdir\\local\\lib")
else
   try
      if "HOSTNAME" in ENV && ENV["HOSTNAME"] == "juliabox"
         push!(Libdl.DL_LOAD_PATH, "/usr/local/lib")
      elseif on_linux
         push!(Libdl.DL_LOAD_PATH, "$pkgdir/local/lib")
         ENV["LD_LIBRARY_PATH"] = "$pkgdir/local/lib"

         Libdl.dlopen("$pkgdir/local/lib/libgmp")
         Libdl.dlopen("$pkgdir/local/lib/libmpfr")
         Libdl.dlopen("$pkgdir/local/lib/libflint")
         libpari = Libdl.dlopen("$pkgdir/local/lib/libpari")
      else
         push!(Libdl.DL_LOAD_PATH, "$pkgdir/local/lib")
      end
   catch
      push!(Libdl.DL_LOAD_PATH, "$pkgdir/local/lib")
   end
end

ccall((:pari_init, :libpari), Void, (Int, Int), 3000000000, 10000)

###############################################################################
#
#   Load Nemo Rings/Fields/etc
#
###############################################################################

include("generic/GenericTypes.jl")

include("flint/FlintTypes.jl")

include("antic/AnticTypes.jl")

include("pari/PariTypes.jl")

include("Rings.jl")

if with_cxx
   include("singular/Types.jl")
end

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
#   Library initialisation message
#
###############################################################################

function __init__()
   println("")
   println("Welcome to Nemo version 0.2")
   println("")
   println("Nemo comes with absolutely no warranty whatsoever")
   println("")
end

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

include("../test/Rings-test.jl")

end # module
