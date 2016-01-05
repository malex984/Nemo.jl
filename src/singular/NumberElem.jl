typealias number libSingular.number; typealias number_ref libSingular.number_ref; typealias number_ptr libSingular.number_ptr;

#==============================================================================#

## Generic with context. e.g. generic Integers modulosomething ...
# TODO: rename -> NumberRingElem
type NumberElem{CF<:SingularRing} <: SingularRingElem # TODO: rename -> NumberRElem
    ptr :: libSingular.number
    ctx :: CF

    function NumberElem()
    	error("Type NumberElem{$CF} requires context reference")
    end

    function NumberElem(c :: CF, p :: libSingular.number)        
        z = new(n_Test(p, get_raw_ptr(c)), c); 
	finalizer(z, _SingularRingElem_clear_fn); return z
    end
    
    function NumberElem(c :: CF)
    	return NumberElem{CF}(c, 0)
#=
        const p = number(0);
	z = new(n_Test(p, get_raw_ptr(c)), c); 
	finalizer(z, _SingularRingElem_clear_fn); return z
=#
    end

    function NumberElem(c :: CF, x::Int)
        const p :: libSingular.number = libSingular.n_Init(x, get_raw_ptr(c))
    	return NumberElem{CF}(c, p)
    end

    function NumberElem(c::CF, b::BigInt) 
    	const p :: libSingular.number = libSingular.n_InitMPZ(b, get_raw_ptr(c))
	return NumberElem{CF}(c, p)
    end

    function NumberElem(x::NumberElem{CF})
        const c = parent(x); 
	const p :: libSingular.number = libSingular.n_Copy(get_raw_ptr(x), get_raw_ptr(c)); 
    	return NumberElem{CF}(c, p)
    end

end

#==============================================================================#

# with context...
type NumberFElem{CF<:SingularField} <: SingularFieldElem
    ptr :: number
    ctx :: CF

    function NumberFElem()
    	error("Type NumberFElem{$CF} requires context reference")
    end

    function NumberFElem(c::CF, p::number)
        z = new(n_Test(p, get_raw_ptr(c)), c); 
        finalizer(z, _SingularRingElem_clear_fn); return z
    end

    function NumberFElem(c::CF, x::Int)
    	p = libSingular.n_Init(x, get_raw_ptr(c)); 
	return NumberFElem{CF}(c, p);
    end

    function NumberFElem(c::CF)
	return NumberFElem{CF}(c, 0);    
#=
        const p = number(0);
        z = new(n_Test(p, get_raw_ptr(c)), c); 
        finalizer(z, _SingularRingElem_clear_fn); return z
=#
    end


    function NumberFElem(x::NumberFElem{CF})
        c = parent(x); p = libSingular.n_Copy(get_raw_ptr(x), get_raw_ptr(c)); 
        return NumberFElem{CF}(c, p)
    end

    function NumberFElem(c::CF, b::BigInt)
        p = libSingular.n_InitMPZ(b, get_raw_ptr(c)); 
	return NumberFElem{CF}(c, p)
    end
end

#==============================================================================#

# without context... CF is unique, e.g. Singular's ZZ 
type Number_Elem{CF<:SingularUniqueRing} <: SingularUniqueRingElem  # TODO: rename -> NumberR_Elem?
    ptr :: number

    function Number_Elem(p::number)
        z = new(n_Test(p, get_raw_ptr(CF()))); 
        finalizer(z, _SingularRingElem_clear_fn); return z
    end

    function Number_Elem(x::Number_Elem{CF})
        c = parent(x); 
        @assert is(c, CF())	
	p = libSingular.n_Copy(get_raw_ptr(x), get_raw_ptr(c)); 
        return Number_Elem{CF}(p)
    end

    function Number_Elem()
    	return Number_Elem{CF}(0)
#=
        const p = number(0)
        z = new(n_Test(p, get_raw_ptr(CF()))); 
        finalizer(z, _SingularRingElem_clear_fn); return z
=#
    end

    function Number_Elem(c::CF)
        @assert is(c, CF())
    	return Number_Elem{CF}()
    end

    function Number_Elem(c::CF, p::number)
        @assert is(c, CF())
    	return Number_Elem{CF}(p);
    end

    function Number_Elem(c::CF, x::Int)
        @assert is(c, CF())
    	p = libSingular.n_Init(x, get_raw_ptr(c)); return Number_Elem{CF}(p);
    end

    function Number_Elem(c::CF, b::BigInt)
        @assert is(c, CF())
        p = libSingular.n_InitMPZ(b, get_raw_ptr(c)); 
	return Number_Elem{CF}(p)
    end

    function Number_Elem(x::Int)
	return Number_Elem{CF}(CF(), x)
    end

    function Number_Elem(b::BigInt)
	return Number_Elem{CF}(CF(), b)
    end
end

#==============================================================================#

# without context... CF is unique: e.g. QQ, RR, CC Rr?
type NumberF_Elem{CF<:SingularUniqueField} <: SingularUniqueFieldElem
    ptr :: number

    function NumberF_Elem(p::number)
        z = new(n_Test(p, get_raw_ptr(CF()))); 
	finalizer(z, _SingularRingElem_clear_fn); return z
    end

    function NumberF_Elem()
        return NumberF_Elem{CF}(0);
#=    	     
    	const p = number(0); 
        z = new(n_Test(p, get_raw_ptr(CF()))); 
        finalizer(z, _SingularRingElem_clear_fn); return z
=#
    end

    function NumberF_Elem(x::Int)
    	const cf = get_raw_ptr(CF());
      	const p = libSingular.n_Init(x, cf); 	
	return NumberF_Elem{CF}(p);
    end

    function NumberF_Elem(x::NumberF_Elem{CF})
        const C = parent(x);
    	@assert is(C, CF())
        const cf = get_raw_ptr(C); 
  	const p = libSingular.n_Copy(get_raw_ptr(x), cf);
        return NumberF_Elem{CF}(p)
    end

    function NumberF_Elem(b::BigInt)
    	const cf = get_raw_ptr(CF());
        const p = libSingular.n_InitMPZ(b, cf); 
	return NumberF_Elem{CF}(p)
    end
    function NumberF_Elem(c::CF)
    	@assert is(c, CF())
    	return NumberF_Elem{CF}();
    end

    function NumberF_Elem(c::CF, p)
    	@assert is(c, CF())
        return  NumberF_Elem{CF}(p)
    end
end

#==============================================================================#

# without context... CF  == Singular_ZZ is unique + its super type is known to Nemo...
type Singular_ZZElem <: SingularIntegerRingElem
    ptr :: number

    function Singular_ZZElem()
        return Singular_ZZElem(0)
#=    
    	const p = number(0); 
    	const c = libSingular.ptr_ZZ;
        z = new(n_Test(p, c)); 
        finalizer(z, _SingularRingElem_clear_fn); return z
=#
    end

    function Singular_ZZElem(p::number)
    	const c = libSingular.ptr_ZZ;
        z = new(n_Test(p, c)); 
        finalizer(z, _SingularRingElem_clear_fn); return z
    end

    function Singular_ZZElem(x::Int)
    	const c :: libSingular.coeffs = libSingular.ptr_ZZ;
    	const p :: libSingular.number = libSingular.n_Init(x, c); 
	return Singular_ZZElem(p);
    end

    function Singular_ZZElem(b::BigInt)
    	const c = libSingular.ptr_ZZ;
        const p = libSingular.n_InitMPZ(b, c); 
	return Singular_ZZElem(p)
    end

    function Singular_ZZElem(x::Singular_ZZElem)
    	const c = libSingular.ptr_ZZ;
	const p = libSingular.n_Copy(get_raw_ptr(x), c); 
        return Singular_ZZElem(p)
    end

    Singular_ZZElem(::Singular_ZZ, p) = Singular_ZZElem(p)
end

#==============================================================================#

# without context... CF == Singular_QQ is unique + FractionElem Nemo type
type Singular_QQElem <: SingularFractionElem{Singular_ZZElem}
    ptr :: number

    function Singular_QQElem()
        return Singular_ZZElem(0)
#=
    	const p = number(0); 
    	const c = libSingular.ptr_QQ;
        z = new(n_Test(p, c)); 
        finalizer(z, _SingularRingElem_clear_fn); return z
=#
    end

    function Singular_QQElem(p::number)
    	const c = libSingular.ptr_QQ;
        z = new(n_Test(p, c)); 
        finalizer(z, _SingularRingElem_clear_fn); return z
    end

    function Singular_QQElem(x::Int)
    	const c = libSingular.ptr_QQ;
    	const p = libSingular.n_Init(x, c); 
	return Singular_QQElem(p);
    end

    function Singular_QQElem(x::Singular_QQElem)
    	const c = libSingular.ptr_QQ;
        const p = libSingular.n_Copy(get_raw_ptr(x), c); 
        return Singular_QQElem(p)
    end

    function Singular_QQElem(b::BigInt)
    	const c = libSingular.ptr_QQ;
        const p = libSingular.n_InitMPZ(b, c); 
	return Singular_QQElem(p)
    end

    Singular_QQElem(::Singular_QQ, p) = Singular_QQElem(p)

    function Singular_QQElem(a::Singular_ZZElem)
        return Singular_QQElem( Int(a) ) # TODO: mapping: n_Z -> n_Q???
    end

    function Singular_QQElem(a::Singular_ZZElem, b::Singular_ZZElem)
    	return Singular_QQElem(a) // Singular_QQElem(b)
    end

    function Singular_QQElem(a::Int, b::Int)
    	return (Singular_QQElem(a) // Singular_QQElem(b))
    end

end

#==============================================================================#

#=====================================================#
# Properties: 
#=====================================================#

# Concrete: in general there may be no context attached
parent{CF<:SingularRing}(n::NumberElem{CF}) = n.ctx
parent{CF<:SingularField}(n::NumberFElem{CF}) = n.ctx

# Unique:
parent{CF<:SingularUniqueRing}(n::Number_Elem{CF}) = CF()
parent{CF<:SingularUniqueField}(n::NumberF_Elem{CF}) = CF()
parent(n::Singular_ZZElem) = Singular_ZZ()
parent(n::Singular_QQElem) = Singular_QQ()



function set_raw_ptr!{CF<:SingularRing}(n::NumberElem{CF}, p::libSingular.number, C::CF)
   n.ptr = p;
   n.ctx = C;
   get_raw_ptr(n); # Test...
end

function set_raw_ptr!{CF<:SingularField}(n::NumberFElem{CF}, p::libSingular.number, C::CF)
   n.ptr = p;
   n.ctx = C;
   get_raw_ptr(n); # Test...
end

function set_raw_ptr!{CF<:SingularUniqueRing}(n::Number_Elem{CF}, p::libSingular.number, ::CF)
   n.ptr = p;
   get_raw_ptr(n); # Test...
end

function set_raw_ptr!{CF<:SingularUniqueField}(n::NumberF_Elem{CF}, p::libSingular.number, ::CF)
   n.ptr = pl;
   get_raw_ptr(n); # Test...
end

function set_raw_ptr!(n::Singular_ZZElem, p::libSingular.number, ::Singular_ZZ)
   n.ptr = p;
   get_raw_ptr(n); # Test...
end

function set_raw_ptr!(n::Singular_QQElem, p::libSingular.number, ::Singular_QQ)
   n.ptr = p;
   get_raw_ptr(n); # Test...
end


#=====================================================#
# Type and parent object methods
#=====================================================#

# Generics
elem_type{CF<:SingularRing}(C::CF) = NumberElem{CF}
elem_type{CF<:SingularField}(C::CF) = NumberFElem{CF}

base_ring(a::Singular_QQElem) = Singular_ZZElem

## NOTE: the following would lead to:
# ERROR: LoadError: MethodError: `elem_type` has no method matching elem_type(::Type{Nemo.Singular_ZZ})
#base_ring(::Singular_ZZ) = Union{}                                                                                                   #base_ring(::Singular_QQ) = Singular_ZZ

# Specials without context:
elem_type{CF<:SingularUniqueRing}(C::CF) = Number_Elem{CF}
elem_type{CF<:SingularUniqueField}(C::CF) = NumberF_Elem{CF}

elem_type(::Singular_ZZ) = Singular_ZZElem
elem_type(::Singular_QQ) = Singular_QQElem

## ? # elem_type(::Type{Singular_ZZ}) = Singular_ZZElem

show_minus_one(::Type{Singular_ZZElem}) = false
show_minus_one(::Type{Singular_QQElem}) = false

show_minus_one{T <: RingElem}(::Type{SingularFractionElem{T}}) = false

check_parent(::Singular_QQElem, ::Singular_QQElem) = true

check_parent{T <: SingularUniqueCoeffsElems}(a::T, b::T) = true

function check_parent(a::SingularFractionElem, b::SingularFractionElem)
   parent(a) != parent(b) && error("Operations on elements with different parents are not supported")
end



###############################################################################
#
#   Conversions and promotions
#
###############################################################################

#### Unique!!!

#convert{S <: SingularUniqueRing, T <: Integer}(::Type{Number_Elem{S}}, a::T) = Number_Elem{S}(a)
#convert{S <: SingularUniqueField, T <: Integer}(::Type{NumberF_Elem{S}}, a::T) = NumberF_Elem{S}(a)

### convert(::Type{Rational{BigInt}}, a::fmpq) = Rational(a)

## TODO: FIXME: the following can be simplified...?

Base.promote_rule{S <: SingularRing, T <: Integer}(C::Type{NumberElem{S}}, ::Type{T}) = NumberElem{S} # C # NumberElem{S}
Base.promote_rule{S <: SingularField, T <: Integer}(C::Type{NumberFElem{S}}, ::Type{T}) = NumberFElem{S} # C # NumberFElem{S}

Base.promote_rule{S <: SingularUniqueRing, T <: Integer}(C::Type{Number_Elem{S}}, ::Type{T}) = Number_Elem{S} # C # Number_Elem{S}
Base.promote_rule{S <: SingularUniqueField, T <: Integer}(C::Type{NumberF_Elem{S}}, ::Type{T}) = NumberF_Elem{S} # C # NumberF_Elem{S}


###############################################################################
#
#   Parent object call overloads
#
###############################################################################

## TODO: FIXME: the following can be simplified...!

Base.call{CF<:SingularRing}(a::CF) = NumberElem{CF}(a)
Base.call{CF<:SingularRing}(a::CF, b::Int) = NumberElem{CF}(a, b)
Base.call{CF<:SingularRing}(a::CF, b::Integer) = NumberElem{CF}(a, BigInt(b))
Base.call{CF<:SingularRing}(a::CF, b::libSingular.number) = NumberElem{CF}(a, b)

function Base.call{CF<:SingularRing}(a::CF, b::NumberElem{CF}) 
   a != parent(b) && error("Operations on elements from different rings (mappings) are not supported yet!")
   return b 
##   return deepcopy(b) # NOTE: fine no need in deepcopy!?? TODO?????
end


Base.call{CF<:SingularUniqueRing}(::CF) = Number_Elem{CF}()
Base.call{CF<:SingularUniqueRing}(::CF, b::Int) = Number_Elem{CF}(b)
Base.call{CF<:SingularUniqueRing}(::CF, b::Integer) = Number_Elem{CF}(BigInt(b))
Base.call{CF<:SingularUniqueRing}(::CF, b::libSingular.number) = Number_Elem{CF}(b)

function Base.call{CF<:SingularUniqueRing}(::CF, b::Number_Elem{CF}) 
   return b 
##   return deepcopy(b) # NOTE: fine no need in deepcopy!?? TODO?????
end


Base.call(::Singular_ZZ) = Singular_ZZElem()
Base.call(::Singular_ZZ, b::Int) = Singular_ZZElem(b)
Base.call(::Singular_ZZ, b::Integer) = Singular_ZZElem(BigInt(b))
Base.call(::Singular_ZZ, b::libSingular.number) = Singular_ZZElem(b)

function Base.call(::Singular_ZZ, b::Singular_ZZElem) 
   return b 
##   return deepcopy(b) # NOTE: fine no need in deepcopy!?? TODO?????
end



Base.call{CF<:SingularField}(a::CF) = NumberFElem{CF}(a)
Base.call{CF<:SingularField}(a::CF, b::Int) = NumberFElem{CF}(a, b)
Base.call{CF<:SingularField}(a::CF, b::Integer) = NumberFElem{CF}(a, BigInt(b))
Base.call{CF<:SingularField}(a::CF, b::libSingular.number) = NumberFElem{CF}(a, b)
function Base.call{CF<:SingularField}(a::CF, b::NumberFElem{CF}) 
   a != parent(b) && error("Operations on elements from different field (mappings) are not supported yet!")
   return b 
##   return deepcopy(b) # NOTE: fine no need in deepcopy!?? TODO?????
end


Base.call{CF<:SingularUniqueField}(::CF) = NumberF_Elem{CF}()
Base.call{CF<:SingularUniqueField}(::CF, b::Int) = NumberF_Elem{CF}(b)
Base.call{CF<:SingularUniqueField}(::CF, b::Integer) = NumberF_Elem{CF}(BigInt(b))
Base.call{CF<:SingularUniqueField}(::CF, b::libSingular.number) = NumberF_Elem{CF}(b)

function Base.call{CF<:SingularUniqueField}(::CF, b::NumberF_Elem{CF}) 
   return b 
##   return deepcopy(b) # NOTE: fine no need in deepcopy!?? TODO?????
end

Base.call(::Singular_QQ) = Singular_QQElem()
Base.call(::Singular_QQ, b::Int) = Singular_QQElem(b)
Base.call(::Singular_QQ, b::Integer) = Singular_QQElem(BigInt(b))
Base.call(::Singular_QQ, b::libSingular.number) = Singular_QQElem(b)

function Base.call(::Singular_QQ, b::Singular_QQElem) 
   return b 
##   return deepcopy(b) # NOTE: fine no need in deepcopy!?? TODO?????
end


###############################################################################
#
#   Constructors
#
###############################################################################

#NumberElem{CF<:SingularRing}(c::CF, z::Integer) = NumberElem{CF}(c, BigInt(z))
NumberElem{CF<:SingularRing}(c::CF, s::AbstractString) = parseNumber(c, s)

Number_Elem{CF<:SingularUniqueRing}(c::CF, s::AbstractString) = parseNumber(c, s)
#Number_Elem{CF<:SingularUniqueRing}(c::CF, z::Integer) = c(BigInt(z))

NumberFElem{CF<:SingularField}(c::CF, s::AbstractString) = parseNumber(c, s)
#NumberFElem{CF<:SingularField}(c::CF, z::Integer) = c(BigInt(z))

NumberF_Elem{CF<:SingularUniqueField}(c::CF, s::AbstractString) = parseNumber(c, s)
#NumberF_Elem{CF<:SingularUniqueField}(c::CF, z::Integer) = c(BigInt(z))

###############################################################################
#
#   ? DEN ? NUM ? NORM ?
#
###############################################################################

den(a::Singular_ZZElem) = one(parent(a))
num(a::Singular_ZZElem) = a # NOTE: TODO: not a deep copy, right?!

function den(_a::Singular_QQElem)
    a = _a; 
#    a = deepcopy(_a);
    p = _den!(a);
    pp = libSingular.nApplyMapFunc( libSingular.setMap_QQ2ZZ, p, libSingular.ptr_QQ, libSingular.ptr_ZZ )
    libSingular._n_Delete(p, libSingular.ptr_QQ)
    return Singular_ZZElem(pp);
end

function num(_a::Singular_QQElem)
    a = _a; 
#    a = deepcopy(_a);
    p = _num!(a);    
    pp = libSingular.nApplyMapFunc( libSingular.setMap_QQ2ZZ, p, libSingular.ptr_QQ, libSingular.ptr_ZZ )
    libSingular._n_Delete(p, libSingular.ptr_QQ)
    return Singular_ZZElem(pp);
end


###############################################################################
#
#   Powering
#
###############################################################################

function ^(x::SingularRingElems, y::Int)
    if y < 0;  throw(ErrorException("DivideError(): Negative power: " * string(y) * "!")); end
    if isone(x); return x; end
    if ismone(x); return isodd(y) ? x : -x; end
    if y > typemax(UInt); throw(ErrorException("DivideError(): Power is too big: " * string(y) * ", sorry!" )); end
    c = parent(x)
    if y == 0; return one(c); end
    if y == 1; return x; end
    p = libSingular.n_Power(get_raw_ptr(x), y, get_raw_ptr(c))
    return c(p)
end

function ^(x::SingularFieldElems, y::Int)
    if y < 0;  return parent(x)(1) // (x^(-y)); end

    if isone(x); return x; end
    if ismone(x); return isodd(y) ? x : -x; end
    if y > typemax(UInt); throw(ErrorException("DivideError(): Power is too big: " * string(y) * ", sorry!" )); end

    C = parent(x)
    if y == 0; return one(C); end
    if y == 1; return x; end

    p = libSingular.n_Power(get_raw_ptr(x), y, get_raw_ptr(C))
    return C(p)
end


###############################################################################
#
#   Division with remainder
#
###############################################################################

function divrem(x::SingularRingElems, y::SingularRingElems)
    iszero(y) && throw(ErrorException("DivideError() in divrem"))

    check_parent(x, y)

    d = div(x, y)
    r = x - d* y

    d, r  ### TODO: @cxx ??? mod (non-negative) vs rem (C semantics)??? s

#    C = parent(x); cf = get_raw_ptr(C)
#    q, m = libSingular.n_QuotRem(get_raw_ptr(x), get_raw_ptr(y), cf);
#    C(q), C(m)
end



function divremQR(x::SingularRingElems, y::SingularRingElems)
    iszero(y) && throw(ErrorException("DivideError() in divrem"))
    check_parent(x, y)

    C = parent(x); cf = get_raw_ptr(C)
    (q, m) = libSingular.n_QuotRem(get_raw_ptr(x), get_raw_ptr(y), cf);
    C(q), C(m)
end

function crt(r1::SingularCoeffsElems, m1::SingularCoeffsElems, r2::SingularCoeffsElems, m2::SingularCoeffsElems, signed=false)
   error("Sorry this functionality (crt) is not implemented yet :(")

#   z = fmpz()
#   ccall((:fmpz_CRT, :libflint), Void, (Ptr{fmpz}, Ptr{fmpz}, Ptr{fmpz}, Ptr{fmpz}, Ptr{fmpz}, Cint), &z, &r1, &m1, &r2, &m2, signed)
#   return z
end

function crt(r1::SingularCoeffsElems, m1::SingularCoeffsElems, r2::Int, m2::Int, signed=false)
   r2 < 0 && throw(ErrorException("DivideError() in crt")) #throw(DomainError())
   m2 < 0 && throw(ErrorException("DivideError() in crt")) # throw(DomainError())

   error("Sorry this functionality (int crt) is not implemented yet :(")

#   z = fmpz()
#   ccall((:fmpz_CRT_ui, :libflint), Void, (Ptr{fmpz}, Ptr{fmpz}, Ptr{fmpz}, Int, Int, Cint), &z, &r1, &m1, r2, m2, signed)
#   return z
end


###############################################################################
#
#   String parser
#
###############################################################################

function parseNumber(c::SingularCoeffs, s::AbstractString) # TODO: FIXME: wrap properly!
    return c(parse(BigInt,s)) ## ??
#    return elem_type(c)(c, parse(BigInt,s))   

    error("Sorry this functionality (parseNumber) is not implemented yet :(")

#    s = bytestring(s)
#    sgn = s[1] == '-' ? -1 : 1
#    i = 1 + (sgn == -1)
## TODO!
#    err == 0 || error("Invalid big integer: $(repr(s))")
#    return sgn < 0 ? -z : z
end
