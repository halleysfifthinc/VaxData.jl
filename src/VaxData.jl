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

end # module
