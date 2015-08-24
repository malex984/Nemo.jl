module Nemo

import Base: abs, asin, asinh, atan, atanh, base, bin, call, convert, cos,
             cosh, dec, deepcopy, den, deserialize, div, divrem, exp, factor,
             gcd, gcdx, getindex, hash, hex, inv, invmod, isequal, isless,
             isprime, isqrt, lcm, length, log, lufact, mod, ndigits, nextpow2,
             norm, num, oct, one, parent, parseint, precision, promote_rule,
             rank, Rational, rem, reverse, serialize, setindex!, show, sign,
             sin, size, sqrt, string, sub, tan, tanh, trace, transpose,
             transpose!, truncate, var, zero

export Collection, Ring, Field, CollectionElem, RingElem, FieldElem, Pari,
       Flint, Antic, Generic

export PolyElem, SeriesElem, ResidueElem, FractionElem, MatElem

export ZZ, QQ, PadicField, FiniteField, NumberField, CyclotomicField,
       MaximalRealSubfield, MaximalOrder

include("AbstractTypes.jl")

###############################################################################
#
#   Set up environment / load libraries
#
###############################################################################

pkgdir = Pkg.dir("Nemo")

on_windows = @windows ? true : false
on_linux = @linux ? true : false

if on_windows
   push!(Libdl.DL_LOAD_PATH, "$pkgdir\\local\\lib")
else
   try
      if "HOSTNAME" in ENV && ENV["HOSTNAME"] == "juliabox"
         push!(Libdl.DL_LOAD_PATH, "/usr/local/lib")
      elseif on_linux
         push!(Libdl.DL_LOAD_PATH, "$pkgdir/local/lib")
         ENV["LD_LIBRARY_PATH"] = "$pkgdir/local/lib"

         Libdl.dlopen("$pkgdir/local/lib/libgmp.so")
         Libdl.dlopen("$pkgdir/local/lib/libmpfr.so")
         Libdl.dlopen("$pkgdir/local/lib/libflint.so")
         libpari = Libdl.dlopen("$pkgdir/local/lib/libpari.so")
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
#   Set domain for MaximalOrder to Pari
#
###############################################################################

MaximalOrder = PariMaximalOrder

###############################################################################
#
#   Test code
#
###############################################################################

include("../test/Rings-test.jl")

end # module
