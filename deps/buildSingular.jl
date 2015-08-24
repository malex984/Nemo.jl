function install_singular() # and NTL 9-3-0

const oldwdir = pwd()
const pkgdir = Pkg.dir("Nemo") 

const on_windows = @windows ? true : false

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
   wdir = "$pkgdir/deps"
   vdir = "$pkgdir/local"
end

cd(wdir)
const ntl="ntl-9.3.0"

try
  run(`wget -q -nc -c -O "$wdir/$ntl.tar.gz" "http://www.shoup.net/ntl/$ntl.tar.gz"`)
except
end

const tmp = mktempdir(wdir)

# http://www.shoup.net/ntl/WinNTL-9_3_0.zip # under Windows?
if !on_windows
   cd( tmp )
   run(`tar -C "$tmp" -xkvf "$wdir/$ntl.tar.gz"`)
#   run(`rm $ntl.tar.gz`) ### avoid redownloading the same tarball...?
   cd( joinpath(tmp, ntl, "src") )
   run(`./configure DEF_PREFIX="$vdir" SHARED=on NTL_THREADS=off NTL_EXCEPTIONS=off NTL_GMP_LIP=on CXXFLAGS="-I$vdir/include" LDFLAGS="-L$vdir/lib"`)
   run(`make -j4`)
   run(`make install`)
##   run(`rm -Rf $tmp/$ntl`)
end


## Install Singular
const srcs = joinpath(wdir, "Singular")

# get/update sources
try
  run(`git clone -b spielwiese https://github.com/Singular/Sources.git $srcs`)
except
  run(`cd $srcs && git pull --rebase`)
end  

run(`$srcs/autogen.sh`)


# out of source-tree building:
if !on_windows
   cd( mktempdir(tmp) )
   ## requires NTL on host system... TODO: install it as well?
   run(`$srcs/configure --prefix=$vdir --disable-static --disable-p-procs-static --enable-p-procs-dynamic --enable-shared --with-gmp=$vdir --with-flint=$vdir --with-ntl=$vdir --without-python --with-readline=no --disable-gfanlib --with-debug --enable-debug --disable-optimizationflags`)
   run(`make -j4`)
   run(`make install`)
   run(`rm -Rf $tmp`)
end

#const singdir = vdir
#const singbinpath = joinpath( singdir, "bin", "Singular" )
#ENV["SINGULAR_EXECUTABLE"] = singbinpath
#const libSingular = dlopen(joinpath(singdir, "lib", "libSingular.so"), RTLD_GLOBAL)

cd(oldwdir);

end
