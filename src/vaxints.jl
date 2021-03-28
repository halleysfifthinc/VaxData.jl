export VaxInt16, VaxInt32

primitive type VaxInt16 <: VaxInt 16 end
primitive type VaxInt32 <: VaxInt 32 end

VaxInt16(x::UInt16) = reinterpret(VaxInt16, htol(x))
VaxInt16(x::Signed) = reinterpret(VaxInt16, htol(trunc(Int16,x)))

Base.convert(::Type{Int16},x::VaxInt16) = reinterpret(Int16,ltoh(x))
Base.convert(::Type{T},x::VaxInt16) where T <: Union{Int32,Int64,Int128,BigInt,AbstractFloat} = convert(T,convert(Int16,x))

VaxInt32(x::UInt32) = reinterpret(VaxInt32, htol(x))
VaxInt32(x::Signed) = reinterpret(VaxInt32, htol(trunc(Int32,x)))

Base.convert(::Type{Int32},x::VaxInt32) = reinterpret(Int32,ltoh(x))
Base.convert(::Type{T},x::VaxInt32) where T <: Union{Int16,Int64,Int128,AbstractFloat} = convert(T,convert(Int32,x))

