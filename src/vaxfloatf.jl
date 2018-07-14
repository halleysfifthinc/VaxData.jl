export VaxFloatF

primitive type VaxFloatF <: VaxFloat 32 end

VaxFloatF(x::UInt32) = reinterpret(VaxFloatF, ltoh(x))
function VaxFloatF(x::T) where T <: Real
    ieeepart1 = reinterpret(UInt32, convert(Float32, x))

    if ieeepart1 & ~SIGN_BIT === zero(UInt32)
        vaxpart = UInt32(0)
    elseif (e = ieeepart1 & IEEE_S_EXPONENT_MASK) === IEEE_S_EXPONENT_MASK
        throw(InexactError(:VaxFloatF, VaxFloatF, x))
    else
        e >>>= VAX_F_MANTISSA_SIZE
        m = ieeepart1 & VAX_F_MANTISSA_MASK

        if e === zero(UInt32)
            m <<= 1
            while m & VAX_F_HIDDEN_BIT === zero(UInt32)
                m <<= UNO
                e -= UNO
            end
            m &= VAX_F_MANTISSA_MASK
        end

        if (e += UNO + VAX_F_EXPONENT_BIAS - IEEE_S_EXPONENT_BIAS) <= 0
            vaxpart = UInt32(0)
        elseif e > (2*VAX_F_EXPONENT_BIAS - 1)
            throw(InexactError(:VaxFloatF, VaxFloatF, x))
        else
            vaxpart = (ieeepart1 & SIGN_BIT) | (e << VAX_F_MANTISSA_SIZE) | m
        end
    end

    vaxpart = htol(vaxpart)
    vaxpart1 = vaxpart & bmask16
    vaxpart2 = (vaxpart >>> 16) & bmask16
    res = (vaxpart1 << 16) | vaxpart2

    return reinterpret(VaxFloatF, res)
end

function Base.convert(::Type{Float32}, x::VaxFloatF)
    y = reinterpret(UInt32, x)
    vaxpart1 = y & bmask16
    vaxpart2 = (y >>> 16) & bmask16
    vaxpart1 = (vaxpart1 << 16) | vaxpart2

    if (e = vaxpart1 & VAX_F_EXPONENT_MASK) === zero(UInt32)
        if vaxpart1 & SIGN_BIT === SIGN_BIT
            throw(InexactError(:convert, Float32, x))
        end
        return Float32(0)
    else
        e >>>= VAX_F_MANTISSA_SIZE

        if (e -= UNO + VAX_F_EXPONENT_BIAS - IEEE_S_EXPONENT_BIAS) > 0
            out = vaxpart1 -
                (( UNO + VAX_F_EXPONENT_BIAS - IEEE_S_EXPONENT_BIAS ) <<
                    IEEE_S_MANTISSA_SIZE)
        else
            out = (vaxpart1 & SIGN_BIT) |
                ((VAX_F_HIDDEN_BIT | (vaxpart1 & VAX_F_MANTISSA_MASK)) >>> (UNO - e))
        end
    end

    return reinterpret(Float32, out)
end
Base.convert(::Type{T},x::VaxFloatF) where T <: Union{Float16, Float64, BigFloat, Integer} = convert(T,convert(Float32,x))

Base.promote_rule(::Type{T},::Type{VaxFloatF}) where T <: Union{AbstractVax, Float16, Float32, Float64, Integer} = (sizeof(T) <= 4) ? Float32 : Float64
Base.promote_rule(::Type{BigFloat},::Type{VaxFloatF}) = BigFloat

Base.promote_type(::Type{VaxFloatF}, ::Type{VaxFloatF}) = Float32

