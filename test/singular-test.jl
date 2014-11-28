function test_singular()

on_windows = @windows ? true : false
pkgdir = Pkg.dir("Nemo") 
if on_windows
   wdir = "$pkgdir\\deps"
   vdir = "$pkgdir\\local"
   wdir2 = split(wdir, "\\")
   s = lowercase(shift!(wdir2)[1])
   unshift!(wdir2, string(s))
   unshift!(wdir2, "")
   wdir2 = join(wdir2, "/") 
   vdir2 = split(vdir, "\\")
   s = lowercase(shift!(vdir2)[1])
   unshift!(vdir2, string(s))
   unshift!(vdir2, "")
   vdir2 = join(vdir2, "/") 
else
   wdir = joinpath(pkgdir, "deps")
   vdir = joinpath(pkgdir, "local")
end

const singdir = vdir
const singbinpath = joinpath( singdir, "bin", "Singular" )
ENV["SINGULAR_EXECUTABLE"] = singbinpath

libSingular = dlopen(joinpath(singdir, "lib", "libSingular.so"), RTLD_GLOBAL)



addHeaderDir(joinpath(singdir, "include"), kind = C_System)
addHeaderDir(joinpath(singdir, "include", "singular"), kind = C_System)

cxxinclude("Singular/libsingular.h", isAngled=false)

@cxx siInit(pointer(singbinpath))



@cxx StringSetS(pointer("Path info:"))
@cxx feStringAppendResources(0)
s = @cxx StringEndS()
# @cxx PrintS(s)  # BUG: PrintS is a C function
# icxx" PrintS($s); "   # quick and dirty shortcut

PrintS(m) = ccall( dlsym( libSingular, :PrintS), Void, (Ptr{Uint8},), m) # another workaround
PrintS(s)



icxx" char* n [] = { (char*)\"t\"}; ring r = rDefault( 13, 1, n); rWrite(r); PrintLn(); rDelete(r); "




#function dummy(cf::Ptr{Void})
#  println("new coeffs: $cf"); return
#end
#const dummy_c = cfunction(dummy, Void, (Ptr{Void},))
#cxx"""
#BOOLEAN myInitChar(coeffs n, void*){
#n->cfCoeffWrite  = (???)$dummy_c; return FALSE; } 
#"""
                
#function jlInit(cf::Ptr{Void}, ::Ptr{Void})
#  println("jlInit: new coeffs: $cf"); return convert( Cint, 1);
#end
#const cjlInit = cfunction(jlInit, Cint, (Ptr{Void},Ptr{Void}))
#newTyp = icxx" return nRegister( n_unknown, (cfInitCharProc)$cjlInit); " # CppEnum{:n_coeffType}(14)
#newCoeff = icxx" return nInitChar( $newTyp, 0 ); "


const n_Q = icxx" return n_Q; "
const n_Z = icxx" return n_Z; "
const n_Zp =icxx" return n_Zp; "


nInitChar(n, p)  = icxx" return nInitChar( $n, (void*)($p) ); "
n_CoeffWrite(cf, details::Bool = true) = icxx" n_CoeffWrite($cf, ($details? 1 : 0)); "
n_Init(i, cf) = icxx" return n_Init($i, $cf ); "
n_Delete(n, cf) = icxx" n_Delete(& $n, $cf); "
n_Print(n, cf) = icxx" n_Print( $n, $cf); "


# q = 66 in QQ
Q = nInitChar( n_Q, 0 )
n_CoeffWrite(Q)
q = n_Init(66, Q )
n_Print( q, Q)
print(q)
n_Delete(q, Q)
print(q)


## z = 666 in ZZ
Z = nInitChar( n_Z, 0 )
n_CoeffWrite(Z)
z = n_Init(666, Z )
n_Print( z, Z)
print(z)
n_Delete(z, Z)
print(z)


## zz = 6 in Zp{11}
Z11 = nInitChar( n_Zp, 11 )
n_CoeffWrite(Z11)
zz = n_Init(11*3 + 6, Z11 )
n_Print( zz, Z11)
print(zz)
n_Delete(zz, Z11)
print(zz)

end
