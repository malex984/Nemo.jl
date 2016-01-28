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
const ntl="ntl-9.5.0"

try
  run(`wget -q -nc -c -O "$wdir/$ntl.tar.gz" "http://www.shoup.net/ntl/$ntl.tar.gz"`)
except
end

LDFLAGS = "-Wl,-rpath,$vdir/lib -Wl,-rpath,\$\$ORIGIN/../share/julia/site/v$(VERSION.major).$(VERSION.minor)/Nemo/local/lib"

const tmp = mktempdir(wdir)

# http://www.shoup.net/ntl/WinNTL-9_5_0.zip # under Windows?
if !on_windows
   cd( tmp )
   run(`tar -C "$tmp" -xkvf "$wdir/$ntl.tar.gz"`)
#   run(`rm $ntl.tar.gz`) ### avoid redownloading the same tarball...?
   cd( joinpath(tmp, ntl, "src") )

   withenv(()->run(`./configure DEF_PREFIX="$vdir" SHARED=on NTL_THREADS=off NTL_EXCEPTIONS=off NTL_GMP_LIP=on CXXFLAGS="-I$vdir/include"`), "LD_LIBRARY_PATH"=>"$vdir/lib", "LDFLAGS"=>LDFLAGS, "CFLAGS"=>LDFLAGS)

   withenv(()->run(`make -j4`), "LD_LIBRARY_PATH"=>"$vdir/lib", "LDFLAGS"=>LDFLAGS, "CFLAGS"=>LDFLAGS)
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
###  withenv(()->run(`$srcs/configure --prefix=$vdir --disable-static --disable-p-procs-static --enable-p-procs-dynamic --enable-shared --with-gmp=$vdir --with-flint=$vdir --with-ntl=$vdir --without-python --with-readline=no --disable-gfanlib --with-debug --enable-debug --disable-optimizationflags`), "LD_LIBRARY_PATH"=>"$vdir/lib", "LDFLAGS"=>LDFLAGS, "CFLAGS"=>LDFLAGS)

   withenv(()->run(`$srcs/configure --prefix=$vdir --disable-static --disable-p-procs-static --enable-p-procs-dynamic --enable-shared --with-gmp=$vdir --with-flint=$vdir --with-ntl=$vdir --without-python --with-readline=no --disable-gfanlib --without-debug --disable-debug --enable-optimizationflags`), "LD_LIBRARY_PATH"=>"$vdir/lib", "LDFLAGS"=>LDFLAGS, "CFLAGS"=>LDFLAGS)
   run(`make -j`)
   run(`make install`)
   run(`rm -Rf $tmp`)

   ### add debugbreak.h into local/include/
    run(`ln -sf $pkgdir/src/singular/debugbreak.h $vdir/include/debugbreak.h`)
end

cd(oldwdir);

end
