function Base.promote(x::T, y::T) where T <: AbstractVax
    Base.@_inline_meta
    px, py = Base._promote(x, y)
    Base.not_sametype((x,y), (px,py))
    px, py
end
function Base.promote(x::T, y::T, z::T) where T <: AbstractVax
    Base.@_inline_meta
    px, py, pz = Base._promote(x, y, z)
    Base.not_sametype((x,y,z), (px,py,pz))
    px, py, pz
end
function Base.promote(x::T, y::T, z::T, a::T...) where T <: AbstractVax
    p = Base._promote(x, y, z, a...)
    Base.not_sametype((x, y, z, a...), p)
    p
end

Base.promote_rule(::Type{VaxInt16}, ::Type{T}) where T <: Union{Int8,Int16} = Int16
Base.promote_rule(::Type{VaxInt16}, ::Type{T}) where T <: Union{Int32,Int64,Int128} = T
Base.promote_rule(::Type{VaxInt16}, ::Type{T}) where T <: IEEEFloat = T

Base.promote_rule(::Type{VaxInt32}, ::Type{T}) where T <: Union{Int8,Int16,Int32,VaxInt16} = Int32
Base.promote_rule(::Type{VaxInt32}, ::Type{T}) where T <: Union{Int64,Int128,IEEEFloat} = T
Base.promote_rule(::Type{VaxInt32}, ::Type{T}) where T <: IEEEFloat = T

Base.promote_rule(::Type{VaxFloatF}, ::Type{T}) where T <: Union{Int8,Int16,Int32,Int64,Int128} = Float32
Base.promote_rule(::Type{VaxFloatF}, ::Type{T}) where T <: Union{Float16,Float32} = Float32
Base.promote_rule(::Type{VaxFloatF}, ::Type{T}) where T <: VaxInt = Float32
Base.promote_rule(::Type{VaxFloatF}, ::Type{Float64}) = Float64

Base.promote_rule(::Type{VaxFloatD}, ::Type{T}) where T <: Union{Int8,Int16,Int32,Int64,Int128} = Float64
Base.promote_rule(::Type{VaxFloatD}, ::Type{T}) where T <: Union{VaxFloatF,VaxFloatG} = Float64
Base.promote_rule(::Type{VaxFloatD}, ::Type{T}) where T <: VaxInt = Float64
Base.promote_rule(::Type{VaxFloatD}, ::Type{T}) where T <: IEEEFloat = Float64

Base.promote_rule(::Type{VaxFloatG}, ::Type{T}) where T <: Union{Int8,Int16,Int32,Int64,Int128} = Float64
Base.promote_rule(::Type{VaxFloatG}, ::Type{T}) where T <: Union{VaxFloatF,VaxFloatG} = Float64
Base.promote_rule(::Type{VaxFloatG}, ::Type{T}) where T <: VaxInt = Float64
Base.promote_rule(::Type{VaxFloatG}, ::Type{T}) where T <: IEEEFloat = Float64

Base.promote_rule(::Type{BigFloat}, ::Type{<:VaxFloat}) = BigFloat
Base.promote_rule(::Type{BigFloat}, ::Type{<:VaxInt}) = BigFloat

Base.promote_rule(::Type{BigInt}, ::Type{<:VaxFloat}) = BigFloat
Base.promote_rule(::Type{BigInt}, ::Type{<:VaxInt}) = BigFloat

Base.promote_type(::Type{VaxInt16}, ::Type{VaxInt16}) = Int16
Base.promote_type(::Type{VaxInt32}, ::Type{VaxInt32}) = Int32

Base.promote_type(::Type{VaxFloatF}, ::Type{VaxFloatF}) = Float32
Base.promote_type(::Type{VaxFloatD}, ::Type{VaxFloatD}) = Float64
Base.promote_type(::Type{VaxFloatG}, ::Type{VaxFloatG}) = Float64

