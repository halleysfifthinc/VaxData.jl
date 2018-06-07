export VaxInt16, VaxInt32

primitive type VaxInt16 <: Signed 16 end
primitive type VaxInt32 <: Signed 32 end

VaxInt16(x::Int16) = reinterpret(VaxInt16, htol(x))
VaxInt16(x::Signed) = reinterpret(VaxInt16, htol(trunc(Int16,x)))
Base.convert(::Type{Int16},x::VaxInt16) = reinterpret(Int16,ltoh(x))
Base.convert(::Type{T}, x::VaxInt16) where T <: Union{Signed,AbstractFloat} = convert(T,convert(Int16,x))
Base.promote_rule(::Type{T},::Type{VaxInt16}) where T <: Union{Signed,AbstractFloat} = T

VaxInt32(x::Int32) = reinterpret(VaxInt32, htol(x))
VaxInt32(x::Signed) = reinterpret(VaxInt32, htol(trunc(Int32,x)))
Base.convert(::Type{Int32},x::VaxInt32) = reinterpret(Int32,ltoh(x))
Base.convert(::Type{T}, x::VaxInt32) where T <: Union{Signed,AbstractFloat} = convert(T,convert(Int32,x))
Base.promote_rule(::Type{T},::Type{VaxInt32}) where T <: Union{Int32,Int64,Int128,AbstractFloat} = T

