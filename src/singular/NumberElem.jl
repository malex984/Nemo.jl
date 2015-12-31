typealias number libSingular.number; typealias number_ref libSingular.number_ref; typealias number_ptr libSingular.number_ptr;

## Generic with context. e.g. generic Integers modulosomething ...
# TODO: rename -> NumberRingElem
type NumberElem{CF<:SingularRing} <: SingularRingElem # TODO: rename -> NumberRElem
    ptr :: libSingular.number
    ctx :: CF

    function NumberElem()
    	error("Type NumberElem{$CF} requires context reference")
    end

    function NumberElem(c :: CF)
        z = new(number(0), c); finalizer(z, _SingularRingElem_clear_fn); return z
    end

    function NumberElem(c :: CF, p :: libSingular.number)
        z = new(p, c); finalizer(z, _SingularRingElem_clear_fn); return z
    end
    
    function NumberElem(c :: CF, x::Int)
        p :: libSingular.number = libSingular.n_Init(x, get_raw_ptr(c))
    	return NumberElem{CF}(c, p)
    end

function NumberElem(c::CF, b::BigInt) 
    p :: libSingular.number = libSingular.n_InitMPZ(b, get_raw_ptr(c))
    return NumberElem{CF}(c, p)
end

function NumberElem(x::NumberElem{CF})
    c = parent(x); p :: libSingular.number = libSingular.n_Copy(get_raw_ptr(x), get_raw_ptr(c)); 
    return NumberElem{CF}(c, p)
end

	#{CF<:SingularRing}
    NumberElem(c::CF, z::Integer) = NumberElem{CF}(c, BigInt(z))
    NumberElem(c::CF, s::AbstractString) = parseNumber(c, s)


end

# with context...
type NumberFElem{CF<:SingularField} <: SingularFieldElem
    ptr :: number
    ctx :: CF

    function NumberFElem()
    	error("Type NumberFElem{$CF} requires context reference")
    end

    function NumberFElem(c::CF)
        z = new(number(0), c); finalizer(z, _SingularRingElem_clear_fn); return z
    end

    function NumberFElem(c::CF, p::number)
        z = new(p, c); finalizer(z, _SingularRingElem_clear_fn); return z
    end

    function NumberFElem(c::CF, x::Int)
    	p = libSingular.n_Init(x, get_raw_ptr(c)); 
	return NumberFElem{CF}(c, p);
    end

    function NumberFElem(x::NumberFElem{CF})
        c = parent(x); p = libSingular.n_Copy(get_raw_ptr(x), get_raw_ptr(c)); 
        return NumberFElem{CF}(c, p)
    end

    function NumberFElem(c::CF, b::BigInt)
        # TODO: how to pass BigInt into C++ function with Cxx (which knows nothing about it)?
        p = libSingular.n_InitMPZ(b, get_raw_ptr(c)); 
	return NumberFElem{CF}(c, p)
   	error("Sorry NumberFElem(BigInt) seems to be unsupported ATM :(")
    end
end

# without context... CF is unique, e.g. Singular's ZZ 
type Number_Elem{CF<:SingularUniqueRing} <: SingularUniqueRingElem  # TODO: rename -> NumberR_Elem?
    ptr :: number

    function Number_Elem()
        z = new(number(0)); finalizer(z, _SingularRingElem_clear_fn); return z
    end

    function Number_Elem(::CF)
    	return Number_Elem{CF}()
    end

    function Number_Elem(p::number)
        z = new(p); finalizer(z, _SingularRingElem_clear_fn); return z
    end

    function Number_Elem(::CF, p::number)
    	return Number_Elem{CF}(p);
    end

    function Number_Elem(c::CF, x::Int)
    	p = libSingular.n_Init(x, get_raw_ptr(c)); return Number_Elem{CF}(p);
    end

    function Number_Elem(c::CF, b::BigInt)
#        # TODO: how to pass BigInt into C++ function with Cxx (which knows nothing about it)?
        p = libSingular.n_InitMPZ(b, get_raw_ptr(c)); 
	return Number_Elem{CF}(p)
    	error("Sorry Number_Elem(CF, BigInt) seems to be unsupported ATM :(")
    end

    function Number_Elem(x::Int)
	return Number_Elem{CF}(CF(), x)
    end

    function Number_Elem(b::BigInt)
	return Number_Elem{CF}(CF(), b)
    end

    function Number_Elem(x::Number_Elem{CF})
        c = parent(x); p = libSingular.n_Copy(get_raw_ptr(x), get_raw_ptr(c)); 
        return Number_Elem{CF}(p)
    end

end

# without context... CF is unique: e.g. QQ, RR, CC Rr?
type NumberF_Elem{CF<:SingularUniqueField} <: SingularUniqueFieldElem
    ptr :: number

    function NumberF_Elem()
        z = new(number(0)); finalizer(z, _SingularRingElem_clear_fn); return z
    end

    function NumberF_Elem(p::number)
        z = new(p); finalizer(z, _SingularRingElem_clear_fn); return z
    end


    function NumberF_Elem(::CF)
    	return NumberF_Elem{CF}();
    end

    function NumberF_Elem(::CF, p::number)
    	return NumberF_Elem{CF}(p);
    end

    function NumberF_Elem(c::CF, x::Int)
    	p = libSingular.n_Init(x, get_raw_ptr(c)); return NumberF_Elem{CF}(p);
    end

    function NumberF_Elem(x::Int)
    	p = libSingular.n_Init(x, get_raw_ptr(CF())); return NumberF_Elem{CF}(p);
    end

    function NumberF_Elem(x::NumberF_Elem{CF})
        c = parent(x); p = libSingular.n_Copy(get_raw_ptr(x), get_raw_ptr(c)); 
        return NumberF_Elem{CF}(p)
    end

    function NumberF_Elem(c::CF, b::BigInt)
#        # TODO: how to pass BigInt into C++ function with Cxx (which knows nothing about it)?
        p = libSingular.n_InitMPZ(b, get_raw_ptr(c)); 
	return NumberF_Elem{CF}(p)

    	error("Sorry NumberF_Elem(CF, BigInt) seems to be unsupported ATM :(")
    end

    function NumberF_Elem(b::BigInt)
        return NumberF_Elem{CF}(CF(), b)
    end
end

#######################################################
#######################################################


# without context... CF  == Singular_ZZ is unique + its super type is known to Nemo...
type Singular_ZZElem <: SingularIntegerRingElem
    ptr :: number

    function Singular_ZZElem()
        z = new(number(0)); finalizer(z, _SingularRingElem_clear_fn); return z
    end

    function Singular_ZZElem(p::number)
        z = new(p); finalizer(z, _SingularRingElem_clear_fn); return z
    end

    function Singular_ZZElem(x::Int)
    	c = libSingular.ptr_ZZ;
    	p = libSingular.n_Init(x, c); return Singular_ZZElem(p);
    end

    function Singular_ZZElem(b::BigInt)
#        # TODO: how to pass BigInt into C++ function with Cxx (which knows nothing about it)?
    	c = libSingular.ptr_ZZ;
        p = libSingular.n_InitMPZ(b, c); 
	return Singular_ZZElem(p)
    end

    function Singular_ZZElem(x::Singular_ZZElem)
    	c = libSingular.ptr_ZZ;
	p = libSingular.n_Copy(get_raw_ptr(x), c); 
        return Singular_ZZElem(p)
    end
end

# without context... CF == Singular_QQ is unique + FractionElem Nemo type
type Singular_QQElem <: SingularFractionElem{Singular_ZZElem}
    ptr :: number

    function Singular_QQElem()
        z = new(number(0)); finalizer(z, _SingularRingElem_clear_fn); return z
    end

    function Singular_QQElem(p::number)
        z = new(p); finalizer(z, _SingularRingElem_clear_fn); return z
    end

    function Singular_QQElem(x::Int)
    	c = libSingular.ptr_QQ;
    	p = libSingular.n_Init(x, c); return Singular_QQElem(p);
    end

    function Singular_QQElem(x::Singular_QQElem)
    	c = libSingular.ptr_QQ;
        p = libSingular.n_Copy(get_raw_ptr(x), c); 
        return Singular_QQElem(p)
    end

    function Singular_QQElem(b::BigInt)
#        # TODO: how to pass BigInt into C++ function with Cxx (which knows nothing about it)?
    	c = libSingular.ptr_QQ;
        p = libSingular.n_InitMPZ(b, c); 
	return Singular_QQElem(p)
    end

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

################################################################################



#######################################################
# Properties: 
#######################################################

get_raw_ptr(n::SingularCoeffsElems) = n.ptr
set_raw_ptr!(n::SingularCoeffsElems, p::libSingular.number) = n.ptr = p;

## Concrete: in general there may be no context attached
parent{CF<:SingularRing}(n::NumberElem{CF}) = n.ctx

function set_raw_ptr!{CF<:SingularRing}(n::NumberElem{CF}, p::libSingular.number, C::CF)
   n.ptr = p
   n.ctx = C
end

parent{CF<:SingularField}(n::NumberFElem{CF}) = n.ctx

function set_raw_ptr!{CF<:SingularField}(n::NumberFElem{CF}, p::libSingular.number, C::CF)
   n.ptr = p
   n.ctx = C
end


#Unique:

parent{CF<:SingularUniqueRing}(n::Number_Elem{CF}) = CF()
parent{CF<:SingularUniqueField}(n::NumberF_Elem{CF}) = CF()

function set_raw_ptr!{CF<:SingularUniqueRing}(n::Number_Elem{CF}, p::libSingular.number, ::CF)
   n.ptr = p
end

function set_raw_ptr!{CF<:SingularUniqueField}(n::NumberF_Elem{CF}, p::libSingular.number, ::CF)
   n.ptr = p
end

parent(n::Singular_ZZElem) = Singular_ZZ()
parent(n::Singular_QQElem) = Singular_QQ()

function set_raw_ptr!(n::Singular_ZZElem, p::libSingular.number, ::Singular_ZZ)
   n.ptr = p
end

function set_raw_ptr!(n::Singular_QQElem, p::libSingular.number, ::Singular_QQ)
   n.ptr = p
end


###############################################################################
#
#   Type and parent object methods
#
###############################################################################

base_ring(a::SingularCoeffs) = Union{}
base_ring(a::SingularCoeffsElems) = Union{}

base_ring(a::Singular_QQElem) = Singular_ZZElem

# NumberElem{CF<:SingularRing}

# Specials without context:
elem_type{CF<:SingularUniqueRing}(C::CF) = Number_Elem{CF} # Yeah!
elem_type{CF<:SingularUniqueField}(C::CF) = NumberF_Elem{CF}

elem_type(::Singular_ZZ) = Singular_ZZElem
elem_type(::Singular_QQ) = Singular_QQElem

# Generics
elem_type{CF<:SingularRing}(C::CF) = NumberElem{CF} # Yeah!
elem_type{CF<:SingularField}(C::CF) = NumberFElem{CF}


##




show_minus_one(::Type{Singular_ZZElem}) = false
show_minus_one(::Type{Singular_QQElem}) = false

show_minus_one{T <: RingElem}(::Type{SingularFractionElem{T}}) = false

check_parent(::Singular_QQElem, ::Singular_QQElem) = true

check_parent{T <: SingularUniqueCoeffsElems}(a::T, b::T) = true

function check_parent(a::SingularFractionElem, b::SingularFractionElem)
   parent(a) != parent(b) && error("Operations on elements with different parents are not supported")
end


function check_parent(a::SingularCoeffsElems, b::SingularCoeffsElems) 
   parent(a) != parent(b) && error("Operations on elements with different parents are not supported")
end


###############################################################################
#
#    Destructor
#
###############################################################################

function _SingularRingElem_clear_fn(n::SingularCoeffsElems)
   c = parent(n)
   cf = get_raw_ptr(c)

   p = get_raw_ptr(n)

   # ( (Int(p) & 255) != 0 )
   if libSingular.nCoeff_has_simple_Alloc(cf) || (p == number(0))
      return ;
   end

   p = libSingular._n_Delete(p, cf)

   set_raw_ptr!(n, number(0)) # p?
 
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

function convert(::Type{BigInt}, a::SingularCoeffsElems)
##    error("Sorry BigInt(SingularCoeffsElems) seems to be unsupported ATM :(") # TODO: how to pass BigInt into C++ function with Cxx (which knows nothing about it)?!

    aaa =  number_ref(get_raw_ptr(a)); 
    r = libSingular.n_MPZ(aaa, get_raw_ptr(parent(a))) # BigInt();
    set_raw_ptr!(a, aaa[]) # a.ptr = ptr

    return r
end

function convert(::Type{Int}, a::SingularCoeffsElems) 

    cf = get_raw_ptr(parent(a));  
    aa = number_ref(get_raw_ptr(a)) 
    r = libSingular.n_Int(aa, cf)
    set_raw_ptr!(a, aa[] ) # aaa[] # a.ptr = ptr
    return r
end

function convert(::Type{UInt}, x::SingularCoeffsElems)
    r = convert(Int, x)
    return UInt(r)

   error("Sorry this functionality (convert into UInt) is not implemented yet :(") #   return ccall((:?_get_ui, :libflint), UInt, (Ptr{?}, ), &x)
end

#function convert(::Type{Float64}, n::SingularCoeffsElems) # rounds to zero
#   error("Sorry this functionality (convert into Float64) is not implemented yet :(")
#end

Base.promote_rule{S <: SingularRing, T <: Integer}(C::Type{NumberElem{S}}, ::Type{T}) = NumberElem{S} # C # NumberElem{S}
Base.promote_rule{S <: SingularField, T <: Integer}(C::Type{NumberFElem{S}}, ::Type{T}) = NumberFElem{S} # C # NumberFElem{S}

Base.promote_rule{S <: SingularUniqueRing, T <: Integer}(C::Type{Number_Elem{S}}, ::Type{T}) = Number_Elem{S} # C # Number_Elem{S}
Base.promote_rule{S <: SingularUniqueField, T <: Integer}(C::Type{NumberF_Elem{S}}, ::Type{T}) = NumberF_Elem{S} # C # NumberF_Elem{S}


###############################################################################
#
#   Parent object call overloads
#
###############################################################################

Base.call(a::SingularCoeffs, b::AbstractString) = parseNumber(a, b)

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


### Base.call(a::SingularCoeffs, b::AbstractString) = parseNumber(a, b)

Number_Elem{CF<:SingularUniqueRing}(c::CF, s::AbstractString) = parseNumber(c, s)
#Number_Elem{CF<:SingularUniqueRing}(c::CF, z::Integer) = c(BigInt(z))

NumberFElem{CF<:SingularField}(c::CF, s::AbstractString) = parseNumber(c, s)
#NumberFElem{CF<:SingularField}(c::CF, z::Integer) = c(BigInt(z))

NumberF_Elem{CF<:SingularUniqueField}(c::CF, s::AbstractString) = parseNumber(c, s)
#NumberF_Elem{CF<:SingularUniqueField}(c::CF, z::Integer) = c(BigInt(z))


###############################################################################
#
#   String I/O
#
###############################################################################

function string(n::SingularCoeffsElems)
   libSingular.StringSetS("")
   nn = get_raw_ptr(n)
   nnn = number_ref(nn)	
   libSingular.n_Write( nnn, get_raw_ptr(parent(n)), false )
   set_raw_ptr!(n, nnn[])# n.ptr = ptr'

   m = libSingular.StringEndS()
   s = bytestring(m) 
   libSingular.omFree(m)

   return s
end

#### TODO: needs considering?
needs_parentheses(x::SingularCoeffsElems)   = false # TODO: FIXME: is coeffs has parameters?

# {T<:SingularCoeffsElems}

# ERROR: LoadError: MethodError: `show_minus_one` has no method matching show_minus_one(::Type{Nemo.NumberElem{Nemo.Coeffs}})

show_minus_one{CF<:SingularCoeffsElems}(::Type{CF}) = false

is_negative(x::SingularCoeffsElems) = isnegative(x) 

# TODO: 
#show(io::IO, n::SingularCoeffsElems) = print(io, "SingularCoeffsElems(", string(n), ")")
show(io::IO, n::SingularCoeffsElems) = print(io, string(n))



###############################################################################
#
#   Basic manipulation
#
###############################################################################


function hash(a::SingularCoeffsElems)
   return hash(parent(a)) $ hash(string(a))  ## TODO: string may be a bit too inefficient wherever hash is used...?
end


###### TODO: Q: Is this correct????!
# {CF} ???
deepcopy(a::SingularRingElem) = NumberElem(a)
deepcopy(a::SingularUniqueRingElem) = Number_Elem(a)

deepcopy(a::SingularFieldElem) = NumberFElem(a)
deepcopy(a::SingularUniqueFieldElem) = NumberF_Elem(a)


#### #wrong for ZZ???
isunit(a::SingularCoeffsElems) = !iszero(a) # FIXME: NOTE:Coeff-Rings are not supported at the moment



###############################################################################
#
#   Canonicalisation
#
###############################################################################

##### FIXME: wrong? for printing & normalization of fractions?
canonical_unit(x::SingularCoeffsElems) = isnegative(x) ? mone(parent(x)) : one(parent(x)) ## ZZ
## 


###############################################################################
#
#   ? DEN ? NUM ? NORM ?
#
###############################################################################

### void   n_Normalize(number& n, const coeffs r) # use cxx""" """  and  pointers?
### number n_GetDenom(number& n, const coeffs r)
### number n_GetNumerator(number& n, const coeffs r)

for (fJ, fC) in ((:_num, :_n_GetNumerator), (:_den, :_n_GetDenom))
    @eval begin
        function ($fJ)(x :: SingularCoeffsElems)
	    C = parent(x); r = number_ref(get_raw_ptr(x))
            ret = (libSingular.$fC)(r, get_raw_ptr(C))  # TODO: FIXME:!!!! ???
            set_raw_ptr!(x, r[])
	    return ret # TODO: result in the same Coeffs?? 

#	    error("Sorry: $fJ has to be verified yet!")
        end
    end
end


den(a::Singular_ZZElem) = one(parent(a))
num(a::Singular_ZZElem) = a # NOTE: TODO: not a deep copy, right?!

function den(a::Singular_QQElem)
    p = _den(a);
    pp = libSingular.nApplyMapFunc( libSingular.setMap_QQ2ZZ, p, libSingular.ptr_QQ, libSingular.ptr_ZZ )
    libSingular._n_Delete(p, libSingular.ptr_QQ)
    return Singular_ZZElem(pp);
end

function num(a::Singular_QQElem)
    p = _num(a);    
    pp = libSingular.nApplyMapFunc( libSingular.setMap_QQ2ZZ, p, libSingular.ptr_QQ, libSingular.ptr_ZZ )
    libSingular._n_Delete(p, libSingular.ptr_QQ)
    return Singular_ZZElem(pp);
end



# , (:normalise, :n_Normalize)
function normalize(x :: SingularCoeffsElems) #
   cf = get_raw_ptr(parent(x)); r = number_ref(get_raw_ptr(x));
   ret = libSingular.n_Normalize(r, cf); # TODO: FIXME:!!!! ???
   set_raw_ptr!(x, r[])
   return x
end


###############################################################################
#
#   Binary operators and functions
#
###############################################################################

# Metaprogram to define functions +, -, *, gcd, lcm
                                 
for (fJ, fC) in ((:+, :n_Add), (:-, :n_Sub), (:*, :n_Mult),
                 (:gcd, :n_Gcd), (:lcm, :n_Lcm) )
    @eval begin
        function ($fJ)(x::SingularCoeffsElems, y::SingularCoeffsElems)
            check_parent(x, y)
            c = parent(x)
            p = (libSingular.$fC)(get_raw_ptr(x), get_raw_ptr(y), get_raw_ptr(c));
            return  c(p)
        end
        
        ($fJ)(x::SingularCoeffsElems, i::Integer) = ($fJ)(x, parent(x)(i)) 
        ($fJ)(i::Integer, x::SingularCoeffsElems) = ($fJ)(parent(x)(i), x)
    end
end

function divexact(x::SingularCoeffsElems, y::SingularCoeffsElems)
    iszero(y) && throw(ErrorException("DivideError() in divexact"))
    check_parent(x, y)
    C = parent(x)
    return C(libSingular.n_ExactDiv(get_raw_ptr(x), get_raw_ptr(y), get_raw_ptr(C)))
end

##### TODO: check for exact multiple before divexact & error?

# Metaprogram to define functions /, div, mod

# SingularRingElems
for (fJ, fC) in ((://, :n_Div), ## ?? /: floating point division?
    (:div, :n_ExactDiv), ##### FIXME / TODO : Euclid domain???
    (:_mod, :n_IntMod))
    @eval begin
        function ($fJ)(x::SingularCoeffsElems, y::SingularCoeffsElems)
            iszero(y) && throw(ErrorException("DivideError() in $fJ"))
            check_parent(x, y)
            c = parent(x)
            return  c((libSingular.$fC)(get_raw_ptr(x), get_raw_ptr(y), get_raw_ptr(c)))
        end
        ($fJ)(x::SingularCoeffsElems, i::Integer) = ($fJ)(x,  parent(x)(i)) 
        ($fJ)(i::Integer, x::SingularCoeffsElems) = ($fJ)(parent(x)(i), x)
    end
end

function mod(x::SingularCoeffsElems, y::SingularCoeffsElems) 
    iszero(y) && throw(ErrorException("DivideError() in % (mod)"))
    check_parent(x, y)
    m = _mod(x, y)
    if m >= 0
       return m
    end
    yy = abs(y)
    m += yy
    while m < 0
    	m += yy
    end
    return m  
end


mod{T <: Integer}(x::SingularCoeffsElems, i::T) = mod(x,  parent(x)(i)) 
mod{T <: Integer}(i::T, x::SingularCoeffsElems) = mod(parent(x)(i), x)


function mulmod{T <: SingularCoeffsElems}(a::T, b::T, d::T)
    check_parent(a, b)
    return mod(a * b, d)
end


function powmod{T <: SingularCoeffsElems}(a::T, b::Int, d::T)
   check_parent(a, d)
   if iszero(a)
      return zero(parent(a))
   elseif b == 0
      return one(parent(a))
   else
      if b < 0
         a = invmod(a, d)
         b = -b
      end
      bit = ~((~UInt(0)) >> 1)
      while (UInt(bit) & b) == 0
         bit >>= 1
      end
      z = a
      bit >>= 1
      while bit !=0
         z = mulmod(z, z, d)
         if (UInt(bit) & b) != 0
            z = mulmod(z, a, d)
         end
         bit >>= 1
      end
      return z
   end
end

function powmod{T <: SingularCoeffsElems}(a::T, p::SingularCoeffsElems, m::T)
    return powmod(a, Int(p), m)
end


function invmod{T <: SingularCoeffsElems}(a::T, d::T)
    check_parent(a, d)
    g, i  = gcdinv(a, d)
    (!isone(g)) && throw(ErrorException("DivideError() in % (invmod)"))
    return mod(i, d) # mod(inv(a), d) # TODO: better generic implementation???
end

#    (:%,   :n_IntMod))
function rem(x::SingularCoeffsElems, y::SingularCoeffsElems) 
	 # mod(x, y) ### ??? TODO: IntMod vs QuotRem??!
    iszero(y) && throw(ErrorException("DivideError() in % (rem)"))
    check_parent(x, y)
    return (x - div(x, y) * y)
end

rem{T <: Integer}(x::SingularCoeffsElems, i::T) = rem(x,  parent(x)(i)) 
rem{T <: Integer}(i::T, x::SingularCoeffsElems) = rem(parent(x)(i), x)

function remQR(x::SingularCoeffsElems, y::SingularCoeffsElems)
    iszero(y) && throw(ErrorException("DivideError() in % (remQR)"))
    check_parent(x, y)
    C = parent(x); cf = get_raw_ptr(C);

    q, m = libSingular.n_QuotRem(get_raw_ptr(x), get_raw_ptr(y), cf);

    q = libSingular._n_Delete(q, cf);
    return C(m)
end


function divQR(x::SingularCoeffsElems, y::SingularCoeffsElems)
    iszero(y) && throw(ErrorException("DivideError() in % (divQR)"))
    check_parent(x, y)

    C = parent(x); cf = get_raw_ptr(C)

    q, m = libSingular.n_QuotRem(get_raw_ptr(x), get_raw_ptr(y), cf);

    m = libSingular._n_Delete(m, cf);
    return C(q)
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
#   Unary operators and functions
#
###############################################################################

function -(x::SingularCoeffsElems) 
    C = parent(x)

    ptr = libSingular.n_Neg( get_raw_ptr(x),  get_raw_ptr(C) )
    
    return C(ptr) 

#    return (zero(parent(x)) - x)   ### TODO: FIXME: deepcopy & n_InpNeg!
end

function abs(x::SingularCoeffsElems)
    ispositive(x) && return x
    return (-x)
end

function sign(a::SingularCoeffsElems)
    ispositive(a) && return 1
    iszero(a) && return 0
    return -1
end

function inv(x::SingularCoeffsElems)
    iszero(x) && error("Division by zero!")
    C = parent(x)

    p = libSingular.n_Invers(get_raw_ptr(x), get_raw_ptr(C)) 

    if p != number(0); return C(p); end

    isring(C) && error("Sorry but input has no inverse in its ring!")

    error("Sorry: could not compute inverse for your input!")
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
#   Extended GCD
#
###############################################################################

function gcdx(a::SingularCoeffsElems, b::SingularCoeffsElems)
    check_parent(a, b)
    C = parent(a)

    if iszero(b) # shortcut this to ensure consistent results with gcdx(a,b)
        return (a < 0) ? (-a, -one(C), zero(C)) : (a, one(C), zero(C))
    end

    g, s, t = libSingular.n_ExtGcd(get_raw_ptr(a), get_raw_ptr(b), get_raw_ptr(C));

    C(g), C(s), C(t)
end

function gcdinv(a::SingularCoeffsElems, b::SingularCoeffsElems)
    check_parent(a, b)
    c = parent(a)

    if iszero(b) # shortcut this to ensure consistent results with gcdx(a,b)
        return a < 0 ? (-a, -one(c)) : (a, one(c))
    end

    a < 0 && throw(ErrorException("DivideError(): a < 0 (gcdinv)"))
    b < a && throw(ErrorException("DivideError(): b < a (gcdinv)")) 

    cf = get_raw_ptr(c);

    g, s, t = libSingular.n_ExtGcd(get_raw_ptr(a), get_raw_ptr(b), cf);

    t = libSingular._n_Delete(t, cf)

    c(g), c(s)
end


###############################################################################
#
#   Comparison
#
###############################################################################

for (fJ, fC) in ((:isone, :n_IsOne), (:ismone, :n_IsMOne), 
                (:iszero, :n_IsZero), (:ispositive, :n_GreaterZero), 
		(:size,   :n_Size)) 
    @eval begin
        function ($fJ)(x :: SingularCoeffsElems)
            return (libSingular.$fC)(get_raw_ptr(x), get_raw_ptr(parent(x)))
        end
    end
end

isnegative(a::SingularCoeffsElems) = (!iszero(a)) && (!ispositive(a))

# see also https://github.com/JuliaLang/julia/blob/master/base/operators.jl

function cmp(x::SingularCoeffsElems, y::SingularCoeffsElems)
    check_parent(x, y)
    cf = get_raw_ptr(parent(x))
    xx = get_raw_ptr(x) 
    yy = get_raw_ptr(y)

    libSingular.n_Greater(xx, yy, cf)  && return 1
    libSingular.n_Equal(xx, yy, cf)  && return 0

    return -1
end

cmpabs(x::SingularCoeffsElems, y::SingularCoeffsElems) = cmp( abs(x), abs(y) )


function ==(x::SingularCoeffsElems, y::SingularCoeffsElems)
    check_parent(x, y)
    return libSingular.n_Equal(get_raw_ptr(x), get_raw_ptr(y), get_raw_ptr(parent(x)))
end

isequal(x::SingularCoeffsElems, y::SingularCoeffsElems) = (x == y)

# <(x,y) = isless(x,y)
function isless(x::SingularCoeffsElems, y::SingularCoeffsElems)
    check_parent(x, y)
    return libSingular.n_Greater(get_raw_ptr(y), get_raw_ptr(x), get_raw_ptr(parent(x)))
end


###############################################################################
#
#   Ad hoc comparison
#
###############################################################################

==(x::SingularCoeffsElems, y::Int) = (x ==  parent(x)(y))
==(x::Int, y::SingularCoeffsElems) = (parent(y)(x) == y)

isequal(x::SingularCoeffsElems, y::Int) = (x == y)
isequal(x::Int, y::SingularCoeffsElems) = (x == y)

isless(x::SingularCoeffsElems, y::Int) = isless(x, parent(x)(y))
isless(x::Int, y::SingularCoeffsElems) = isless(parent(y)(x), y)


###############################################################################
#
#   Number-theoretic/combinatorial
#
###############################################################################

#### Return true if x is divisible by y, otherwise return false. If y = 0 a ~DivideError() is raised.
function divisible(x::SingularCoeffsElems, y::SingularCoeffsElems)
   iszero(y) && throw(ErrorException("DivideError() in divisible"))  # throw(DivideError())
   
   # test whether 'x' is divisible by 'y';
   # in Z: TRUE iff 'y' divides 'x' (with remainder = zero)
   return libSingular.n_DivBy( get_raw_ptr(x), get_raw_ptr(y), get_raw_ptr(parent(x)) )
end

function divisible(x::SingularCoeffsElems, y::Int)
   (y==0) && throw(ErrorException("DivideError() in divisible")) # throw(DivideError())

   return divisible(x, parent(x)(y)) # for now
end


###############################################################################
#
#   String parser
#
###############################################################################

function parseNumber(c::SingularCoeffs, s::AbstractString) # TODO: FIXME: wrap properly!
    return c(parse(BigInt,s))   

    error("Sorry this functionality (parseNumber) is not implemented yet :(")

#    s = bytestring(s)
#    sgn = s[1] == '-' ? -1 : 1
#    i = 1 + (sgn == -1)
## TODO!
#    err == 0 || error("Invalid big integer: $(repr(s))")
#    return sgn < 0 ? -z : z
end

#####################################################################! Julia/Cxx bugs:

#function >(x::Int, y::SingularCoeffsElems) 
#   return (sicmp(y,x) < 0)

#   return (iscmp(x,y) > 0) # BUG:
# /home/malex/JJ/usr/bin/julia-debug: symbol lookup error: /home/malex/.julia/v0.4/Cxx/src/../deps/usr/lib/libcxxffi-debug.so: undefined symbol: _ZNK5clang7CodeGen17CGBuilderInserterILb0EE12InsertHelperEPN4llvm11InstructionERKNS3_5TwineEPNS3_10BasicBlockENS3_14ilist_iteratorIS4_EE
#end

#function >(x::SingularCoeffsElems, y::Int)
#   return (iscmp(y,x) < 0) # OK

#   return (sicmp(x,y) > 0) # BUG:
# /home/malex/JJ/usr/bin/julia-debug: symbol lookup error: /home/malex/.julia/v0.4/Cxx/src/../deps/usr/lib/libcxxffi-debug.so: undefined symbol: _ZNK5clang7CodeGen17CGBuilderInserterILb0EE12InsertHelperEPN4llvm11InstructionERKNS3_5TwineEPNS3_10BasicBlockENS3_14ilist_iteratorIS4_EE
#end

#function >=(x::Int, y::SingularCoeffsElems) 
#   return (sicmp(y,x) <= 0)

#   return (iscmp(x,y) >= 0) # BUG:
#fq_poly.adhoc_exact_division... /home/malex/JJ/usr/bin/julia-debug: symbol lookup error: /home/malex/.julia/v0.4/Cxx/src/../deps/usr/lib/libcxxffi-debug.so: undefined symbol: _ZNK5clang7CodeGen17CGBuilderInserterILb0EE12InsertHelperEPN4llvm11InstructionERKNS3_5TwineEPNS3_10BasicBlockENS3_14ilist_iteratorIS4_EE
#end


#function >=(x::SingularCoeffsElems, y::Int) # x >= y !(x<y)
#    error("Sorry Julia bug!") # OK

#   return  !(x<y)            # BUG:
#   return (iscmp(y,x) <= 0)  # BUG:
#   return (sicmp(x,y) >= 0)  # BUG:
#### julia-debug: codegen.cpp:3005: llvm::Value* emit_assignment(llvm::Value*, jl_value_t*, jl_value_t*, bool, bool, jl_codectx_t*): 
#### Assert on `rval->getType() == jl_pvalue_llvmt || rval->getType() == NoopType' failed.
#end



###############################################################################
#
#   Unsafe functions  for performance
#
###############################################################################

### void n_InpMult(number &a, number b, const coeffs r)
### void n_InpAdd(number &a, number b, const coeffs r)

##### TODO: FIX/VERIFY !!!!!!!!!!!!!!!!!!!!!! #####

#### Internal!!!
function muleq!(x :: SingularCoeffsElems, y :: SingularCoeffsElems)
#	if is(x, y) # IN-PLACE: x := x^2 
    @assert parent(x) == parent(y)#        check_parent(x, y)

    cf = get_raw_ptr(parent(x)); yy = get_raw_ptr(y)

    xx = number_ref(get_raw_ptr(x))
    icxx""" n_InpMult($xx, $yy, $cf); """
    set_raw_ptr!(x, xx[]);
end

function addeq!(x :: SingularCoeffsElems, y :: SingularCoeffsElems)
#	if is(x, y) # IN-PLACE: x = 2 * x
    @assert parent(x) == parent(y)#        check_parent(x, y)

    cf = get_raw_ptr(parent(x)); yy = get_raw_ptr(y)

    xx = number_ref(get_raw_ptr(x))
    icxx""" n_InpAdd($xx, $yy, $cf); """
    set_raw_ptr!(x, xx[]);
end

# c = T(); c = x * y ; M += c   
# NOTE: usually in a loop => on the next cycle c is initialized => free its data!
function mul!(c::SingularCoeffsElems, x::SingularCoeffsElems, y::SingularCoeffsElems)
    if is(c,x) 
        return muleq!(c, y)
    end
    if is(c,y) 
        return muleq!(c, x) # NOTE: Commutative multiplication!???
    end

    @assert !(is(c,x) || is(c,y))
    @assert parent(x) == parent(y)#    check_parent(x, y)
    
    C = parent(x); cf = get_raw_ptr(C);

    xx = get_raw_ptr(x); yy = get_raw_ptr(y);

    ptr = libSingular.n_Mult(xx, yy, cf);

    cc = get_raw_ptr(c);

    if cc != number(0)
        libSingular._n_Delete(cc, get_raw_ptr(parent(c)));
    end
    
    set_raw_ptr!(c, ptr, C)
end

