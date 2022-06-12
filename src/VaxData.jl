module VaxData

export AbstractVax, VaxInt, VaxFloat

abstract type AbstractVax <: Real end
abstract type VaxInt <: AbstractVax end
abstract type VaxFloat <: AbstractVax end

import Base: IEEEFloat, convert, read, exponent, significand_bits, significand_mask,
    exponent_bits, exponent_mask, exponent_bias, floatmin, floatmax, typemin, typemax,
    nextfloat, prevfloat, zero, one, uinttype

export VaxInt16, VaxInt32, VaxFloatF, VaxFloatD, VaxFloatG, @vaxf_str, @vaxd_str, @vaxg_str

include("constants.jl")
include("vaxints.jl")
include("vaxfloatf.jl")
include("vaxfloatd.jl")
include("vaxfloatg.jl")
include("promote.jl")
include("math.jl")

const VaxTypes = Union{VaxInt16,VaxInt32,VaxFloatF,VaxFloatD,VaxFloatG}

function convert(::Type{T}, b::BigFloat) where {T<:VaxFloat}
    sig = abs(significand(b))
    U = uinttype(T)
    m = zero(uinttype(T))
    mbits = 0
    while !iszero(sig) && mbits <= significand_bits(T)
        setbit = Bool(sig >= 1)
        sig -= setbit
        m = U(m | setbit) << 1
        sig *= 2
        mbits += 1
    end
    e = ((exponent(b) + exponent_bias(T) + 1) % uinttype(T)) << (15 - exponent_bits(T))
    if e > exponent_mask(T)
        # overflow
        throw(InexactError(:convert, T, b))
    end
    m <<= significand_bits(T) - mbits
    if iszero(e)
        # underflow
        return zero(T)
    end
    m = swap16bword(m)
    m &= significand_mask(T)
    return T(e | (UInt32(signbit(b)) << 15) | m)
end

# dumb and probably not-at-all performant
function convert(::Type{BigFloat}, v::T; precision=significand_bits(T)+1) where {T<:VaxFloat}
    m = swap16bword(v.x)
    bstr = bitstring(m)
    s = signbit(v) ? "-" : ""
    local sig
    setprecision(precision) do
        sig = parse(BigFloat,
            string(s, "0.1", @view(bstr[end-significand_bits(T)+1:end]));
            base=2)
        sig *= big"2."^exponent(v)
    end
    return sig
end

function read(s::IO, ::Type{T}) where {T<:VaxTypes}
    return read!(s, Ref{T}(0))[]::T
end

export swap16bword
@inline function swap16bword(x::Union{UInt32,Int32})
    part1 = x & typemax(UInt16)
    part2 = (x >>> 16) & typemax(UInt16)
    part1 = (part1 << 16) | part2
end

@inline function swap16bword(x::Union{UInt64,Int64})
    part1 = UInt64(swap16bword(UInt32(x & typemax(UInt32))))
    part2 = UInt64(swap16bword(UInt32((x >>> 32) & typemax(UInt32))))
    part1 = (part2 << 32) | part1
end

function Base.show(io::IO, x::VaxFloat)
    T = typeof(x)
    letter = (T === VaxFloatF) ? 'f' :
             (T === VaxFloatD) ? 'd' : 'g'
    print(io, "vax", letter)
    if T === VaxFloatF
        show(io, strip(repr(convert(Float32, x); context=IOContext(io)), ['f', '0']))
    else
        show(io, repr(convert(Float64, x); context=IOContext(io)))
    end

    return nothing
end

end # module
