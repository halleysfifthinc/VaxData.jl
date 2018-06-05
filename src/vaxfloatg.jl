export VaxFloatG

primitive type VaxFloatG <: AbstractFloat 64 end

VaxFloatG(x::UInt64) = reinterpret(VaxFloatG,ltoh(x))
function VaxFloatG(x::Float64)
    parts = reinterpret(UInt32,[ltoh(x)])
    if ENDIAN_BOM == 0x04030201 
        vaxpart2 = parts[1]
        ieeepart1 = parts[2]
    else
        vaxpart2 = parts[2]
        ieeepart1 = parts[1]
    end

    if (ieeepart1 & ~SIGN_BIT) == 0
        vaxpart = UInt32(0)
    elseif (e = ieeepart1 & IEEE_T_EXPONENT_MASK) == IEEE_T_EXPONENT_MASK
        throw(InexactError())
    else
        e >>>= VAX_G_MANTISSA_SIZE
        m = ieeepart1 & VAX_G_MANTISSA_MASK

        if e == 0
            m = (m << 1) | (vaxpart2 >>> 31)
            vaxpart2 <<= 1
            while (m & VAX_G_HIDDEN_BIT) == 0
                m = (m << 1) | (vaxpart2 >>> 31)
                vaxpart2 <<= 1
                e -= UInt32(1)
            end
            m &= VAX_G_MANTISSA_MASK
        end

        if (e += (UNO + VAX_G_EXPONENT_BIAS - IEEE_T_EXPONENT_BIAS)) <= 0
            vaxpart = UInt32(0)
            vaxpart2 = UInt32(0)
        elseif e > (2*VAX_G_EXPONENT_BIAS - 1)
            throw(InexactError())
        else
            vaxpart = (ieeepart1 & SIGN_BIT) | (e << VAX_G_MANTISSA_SIZE) | m
        end
    end
    return htol(reinterpret(VaxFloatG, reinterpret(UInt16,[vaxpart, vaxpart2])[[2,1,4,3]])[1])
end

function Base.convert(::Type{Float64}, x::VaxFloatG)
    parts = reinterpret(UInt16,[ltoh(x)])
    vaxpart1 = reinterpret(UInt32,parts[[2,1]])[1]
    vaxpart2 = reinterpret(UInt32,parts[[4,3]])[1]

    if (e = vaxpart1 & VAX_G_EXPONENT_MASK) == 0
        if (vaxpart1 & SIGN_BIT) == SIGN_BIT
            throw(InexactError())
        end

        out1 = UInt32(0)
        out2 = UInt32(0)
    else
        e >>>= VAX_G_MANTISSA_SIZE

        if (e::UInt32 -= (UNO + VAX_G_EXPONENT_BIAS - IEEE_T_EXPONENT_BIAS)) > 0
            ieeepart1 = vaxpart1  - (UInt32(UNO + VAX_G_EXPONENT_BIAS - IEEE_T_EXPONENT_BIAS) << IEEE_T_MANTISSA_SIZE)
            ieeepart2 = vaxpart2
        else
            vaxpart1 = (vaxpart1 & (SIGN_BIT | VAX_G_MANTISSA_MASK)) | VAX_G_HIDDEN_BIT
            ieeepart1 = (vaxpart1 & SIGN_BIT) | (UInt32(vaxpart1 & (VAX_G_HIDDEN_BIT | VAX_G_MANTISSA_MASK)) >>> (1 - e))
            ieeepart2 = (vaxpart1 << (31 + e)) | (vaxpart2 >>> (1-e))
        end
    end

    if ENDIAN_BOM == 0x04030201
        out1 = ieeepart2
        out2 = ieeepart1
    else
        out1 = ieeepart1
        out2 = ieeepart2
    end
    return reinterpret(Float64,[out1,out2])[1]
end
