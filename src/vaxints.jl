export VaxInt16, VaxInt32

struct VaxInt16 <: VaxInt
    x::UInt16

    VaxInt16(x::UInt16) = new(htol(x))
end

VaxInt16(x::Signed) = VaxInt16(trunc(Int16,x) % UInt16)

Base.convert(::Type{Int16}, x::VaxInt16) = ltoh(x.x) % Int16
function Base.convert(::Type{T}, x::VaxInt16) where T <: Union{Int32,Int64,Int128,BigInt,AbstractFloat}
    return convert(T, convert(Int16, x))
end

struct VaxInt32 <: VaxInt
    x::UInt32

    VaxInt32(x::UInt32) = new(htol(x))
end

VaxInt32(x::Signed) = VaxInt32(trunc(Int32,x) % UInt32)

Base.convert(::Type{Int32}, x::VaxInt32) = ltoh(x.x) % Int32
function Base.convert(::Type{T}, x::VaxInt32) where T <: Union{Int16,Int64,Int128,AbstractFloat}
    return convert(T,convert(Int32,x))
end

