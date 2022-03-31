module VaxData

export AbstractVax, VaxInt, VaxFloat

abstract type AbstractVax <: Real end
abstract type VaxInt <: AbstractVax end
abstract type VaxFloat <: AbstractVax end

import Base: IEEEFloat, convert, read, significand_bits, significand_mask, exponent_bits,
    exponent_mask, exponent_bias, floatmin, floatmax, typemin, typemax, zero, one, uinttype


include("constants.jl")
include("vaxints.jl")
include("vaxfloatf.jl")
include("vaxfloatd.jl")
include("vaxfloatg.jl")
include("promote.jl")
include("math.jl")

const VaxTypes = Union{VaxInt16,VaxInt32,VaxFloatF,VaxFloatD,VaxFloatG}

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

end # module
