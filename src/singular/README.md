# Nemo wrappers for Singular CAS (https://github.com/Singular/Sources, https://www.singular.uni-kl.de/)

About Singular: 

 * Introduction the the Singular sources: https://www.singular.uni-kl.de/Manual/intro_sing.pdf, http://www.mathematik.uni-kl.de/ftp/pub/Math/Singular/doc/singular-anatomy.tgz
 * (draft of) Singular Developer's manual: http://www.mathematik.uni-kl.de/~motsak/dox/html/pages.html
 * Singular internal structure with dependencies: http://www.mathematik.uni-kl.de/~motsak/dox/html/deps_page.html
 * Other (somewhat older docs): http://www.mathematik.uni-kl.de/ftp/pub/Math/Singular/doc/
 * Singular wiki: https://github.com/Singular/Sources/wiki

Reference on Singular wrappers:

 * Singular wrappers for GAP: https://github.com/gap-packages/SingularInterface
 * Macaulay2 uses factory (factorisation of recursive sparse univariate polynomials) http://www.math.uiuc.edu/Macaulay2/doc/Macaulay2-1.6/share/doc/Macaulay2/Macaulay2Doc/html/___Singular-__Factory.html
 * Sage uses Singular: 
    * Generic pexpect interface: http://doc.sagemath.org/html/en/reference/interfaces/sage/interfaces/singular.html
    * Factory wrappers: http://doc.sagemath.org/html/en/reference/libs/sage/libs/singular/function_factory.html
    * low-level Ring/polynomial wrappers 
       * http://doc.sagemath.org/html/en/reference/polynomial_rings/sage/rings/polynomial/multi_polynomial_libsingular.html
       * http://doc.sagemath.org/html/en/reference/polynomial_rings/sage/rings/polynomial/multi_polynomial_ideal_libsingular.html
 * Julia/Nemo: https://github.com/malex984/Nemo.jl
    * depends on Cxx.jl (https://github.com/Keno/Cxx.jl) - often clashes with Julia (Cxx: 7b6307bed is known to work well with Julia: 5b1b0c5)
    * deps/singular-build.jl - build NTL & libSingular shared libraries
    * src/singular/* -  Singular related functionality (main file with basic types: SingularTypes.jl)
Current functionality:
       * low-level wrappers over libpolys & libSingular (major part in : `libSingular.jl` which serves as the basis for the rest)
       * Smart wrappers for coeffs  and numer: `Coeffs.jl` & `NumberElem.jl` + `NumberCommons.jl`
       * Adapter for making a **Nemo** ring or field usable as Singular coeffs. 
       * Smart wrappers for multivariate polynomial rings over coeffs / free modules over such rings and their elements + some kernel algorithms: `PRings.jl`
       * `debugbreak.h` - trigger a breakpoint handling (from https://github.com/scottt/debugbreak)
       * Singular interpreter: Nemo.SingularKernel namespace gets all the "kernel" functions and procedures from LIB (`Interpreter.jl`)
       * `kernel_commands.h` - access to <Singular/table.h> (due to missing public API) for Interpreter + `__iiTwoOps / __Tok2Cmdname`
    * test/singular/* - corresponding test  (main file: all-tests.jl)



