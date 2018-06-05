export VaxFloatF

primitive type VaxFloatF <: AbstractFloat 32  end

VaxFloatF(x::UInt32) = reinterpret(VaxFloatF,ltoh(x))
function VaxFloatF(x::Float32)
    ieeepart1 = reinterpret(UInt32,x)
    if (ieeepart1 & ~SIGN_BIT) == 0
        vaxpart = UInt32(0)
    elseif (e::UInt32 = ieeepart1 & IEEE_S_EXPONENT_MASK) == IEEE_S_EXPONENT_MASK
        throw(InexactError())
    else
        e >>>= VAX_F_MANTISSA_SIZE
        m = ieeepart1 & VAX_F_MANTISSA_MASK

        if e == 0
            m <<= 1
            while (m & VAX_F_HIDDEN_BIT) == 0
                m::UInt32 <<= 1
                e::UInt32 -= 1
            end
            m &= VAX_F_MANTISSA_MASK
        end

        if (e::UInt32 += UNO + VAX_F_EXPONENT_BIAS - IEEE_S_EXPONENT_BIAS) <= 0
            vaxpart = UInt32(0)
        elseif e > (2*VAX_F_EXPONENT_BIAS - 1)
            throw(InexactError())
        else
            vaxpart = (ieeepart1 & SIGN_BIT) | (e << VAX_F_MANTISSA_SIZE) | m
        end
    end

    return reinterpret(VaxFloatF,reinterpret(UInt16, [htol(vaxpart)])[[2,1]])[1]
end

function Base.convert(::Type{Float32}, x::VaxFloatF)
    vaxpart1 = reinterpret(UInt32,reinterpret(UInt16, [x])[[2,1]])[1]

    if (e::UInt32 = vaxpart1 & VAX_F_EXPONENT_MASK) == 0
        if (vaxpart1 & SIGN_BIT) == SIGN_BIT
            throw(InexactError())
        end
        return Float32(0)
    else
        e >>>= VAX_F_MANTISSA_SIZE

        if (e::UInt32 -= ( UNO + VAX_F_EXPONENT_BIAS - IEEE_S_EXPONENT_BIAS )) > 0
            return reinterpret(Float32, vaxpart1 - ( ( UNO + VAX_F_EXPONENT_BIAS - IEEE_S_EXPONENT_BIAS )::UInt32 << IEEE_S_MANTISSA_SIZE ))
        else
            return reinterpret(Float32, ( vaxpart1 & SIGN_BIT ) | ((VAX_F_HIDDEN_BIT | (vaxpart1 & VAX_F_MANTISSA_MASK)) >>> ( UNO - e)))
        end
    end
end
