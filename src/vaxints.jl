export VaxInt16, VaxInt32

primitive type VaxInt16 16 end
primitive type VaxInt32 32 end

VaxInt16(x::Union{UInt16,Int16}) = reinterpret(VaxInt16, htol(x))
VaxInt16(x::Integer) = reinterpret(VaxInt16, htol(trunc(Int16,x)))
convert(::Type{T},x::VaxInt16) where T <: Union{UInt16,Int16} = reinterpret(T,ltoh(x))

VaxInt32(x::Union{UInt32,Int32}) = reinterpret(VaxInt32, htol(x))
VaxInt32(x::Integer) = reinterpret(VaxInt32, htol(trunc(Int32,x)))
convert(::Type{T},x::VaxInt32) where T <: Union{UInt32,Int32} = reinterpret(T,ltoh(x))

