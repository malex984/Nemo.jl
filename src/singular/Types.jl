###############################################################################
#
#   Types.jl : Parent and object types for Singular
#
###############################################################################

using Cxx

const prefix = joinpath(Pkg.dir("Nemo"), "local")
const singular_binary_path = joinpath(prefix, "bin", "Singular")

libSingular = Libdl.dlopen(joinpath(prefix, "lib", "libSingular"), Libdl.RTLD_GLOBAL)


ENV["SINGULAR_EXECUTABLE"] = singular_binary_path

addHeaderDir(joinpath(prefix, "include"), kind = C_System)
addHeaderDir(joinpath(prefix, "include", "singular"), kind = C_System)

cxxinclude("Singular/libsingular.h", isAngled=false)
cxxinclude("coeffs/coeffs.h", isAngled=false)

cxx"""
    #include "Singular/libsingular.h"
    #include "coeffs/coeffs.h"
"""

# @cxx PrintS(s)  # BUG: PrintS is a C function
# icxx" PrintS($s); "   # quick and dirty shortcut
PrintS(m) = ccall( Libdl.dlsym(Nemo.libSingular, :PrintS), Void, (Ptr{Uint8},), m) # workaround for C function

function StringSetS(m) 
   @cxx StringSetS(pointer(m))
end

function StringEndS() 
   return @cxx StringEndS()
end

function feStringAppendResources(i :: Int = -1)
   @cxx feStringAppendResources(i)
end

function siInit(p) 
   @cxx siInit(pointer(p))
end


siInit(singular_binary_path) # Initialize Singular!

function PrintResources(s)
   Nemo.StringSetS(s)
   Nemo.feStringAppendResources(0)
   m = Nemo.StringEndS()
   Nemo.PrintS(m)
end



###############################################################################
#
#   SingularFields
#
###############################################################################

abstract SingularField <: Field{Singular}
abstract SingularFieldElem <: FieldElem ### {Singular}?

const CoeffID = ObjectIdDict() # Dict{Ptr{Void}, SingularField}()

# Ring?   
# todo: add default constructor for QQ, Fp ?! 
# TODO: fix the following to work 
# 2 into separate low-level functions
# 3 back to types <: mathematical using those functions!

typealias n_coeffType Cxx.CppEnum{:n_coeffType}

cxx"""
static n_coeffType get_Q() { return n_Q; };
static n_coeffType get_Z() { return n_Z; };
static n_coeffType get_Zp(){ return n_Zp; }; // n_coeffType.
"""
## todo: avoid the above!
const n_Zp = @cxx get_Zp() #  # get_Zp() = icxx" return n_Zp; "
const n_Q  = @cxx get_Q() # Cxx.CppEnum{:n_coeffType}(2) # icxx" return n_Q; "
const n_Z  = @cxx get_Z() # Cxx.CppEnum{:n_coeffType}(9) # icxx" return n_Z; "

typealias coeffs Cxx.CppPtr{Cxx.CxxQualType{Cxx.CppBaseType{:n_Procs_s},(false,false,false)},(false,false,false)}
# Ptr{Void}

typealias number Cxx.CppPtr{Cxx.CxxQualType{Cxx.CppBaseType{:snumber},(false,false,false)},(false,false,false)}
# Ptr{Void}

# include("cxx_singular_lowlevel.jl") # TODO: move most wrappers there from around here!

function nInitChar(n :: n_coeffType, p :: Ptr{Void})
   return @cxx nInitChar( n, p )
end

function nKillChar(cf::coeffs)
   @cxx nKillChar(cf)
end

function n_GetChar(cf::coeffs)
   @cxx n_GetChar(cf)
end

function n_CoeffWrite(cf :: coeffs, details::Bool = true)
   d :: Int = (details? 1 : 0)
   @cxx n_CoeffWrite(cf, d)
end

function n_Init(i::Int, cf :: coeffs) 
   return @cxx n_Init(i, cf)
end

function n_Int(n :: number, cf :: coeffs) 
   return @cxx n_Int(n, cf)
end

function n_Print(n :: number, cf :: coeffs) 
   @cxx n_Print(n, cf)
end

function n_Delete(n_ptr :: Ptr{number}, cf :: coeffs)
   @cxx n_Delete(n_ptr, cf)
end




type Coeffs <: SingularField
   ptr :: coeffs

   function Coeffs(nt::n_coeffType, par::Ptr{Void}) 
      try
         return CoeffID[nt, par]
      catch
      end

      ptr = nInitChar(nt, par)
      (ptr == coeffs(0)) && error("Singular coeff.domain construction failure")
      try
         cf = CoeffID[ptr]
	 nKillChar(ptr)
	 return cf
      catch
         d = CoeffID[nt, par] = CoeffID[ptr] = new(ptr)
         finalizer(d, _Coeffs_clear_fn)
         return d
      end
   end
end

function _Coeffs_clear_fn(cf::Coeffs)
   nKillChar(cf.ptr)
end

type Number <: SingularFieldElem
    ptr    :: number
    parent :: Coeffs

    function Number(ctx::Coeffs, x::Int = 0)
        z = new()
	cf = ctx.ptr
	ptr = @cxx n_Init(x, cf) 
	z.ptr = ptr
	z.parent = ctx
        finalizer(z, _Number_clear_fn)
        return z
    end

    function Number(x::Number)
        z = new()
	ptr = x.ptr
        cf = x.ctx.ptr
	ptr = @cxx n_Copy(ptr, cf) 
	z.ptr = ptr
	z.parent = x.parent
        finalizer(z, _Number_clear_fn)
        return z
    end
end

function _Number_clear_fn(n::Number)
   cf = n.ctx.ptr
   @cxx n_Delete(&(n.ptr), cf)
end


const SingularQQ = Coeffs(n_Q, Ptr{Void}(0)) # SingularRationalField()
const SingularZZ = Coeffs(n_Z, Ptr{Void}(0)) # SingularRing()

# include("coeff.jl")
# include("poly.jl")
