export VaxFloatD

primitive type VaxFloatD <: AbstractFloat 64  end

VaxFloatD(x::UInt64) = reinterpret(VaxFloatD, ltoh(x))
function VaxFloatD(x::{<:Real})
    parts = reinterpret(UInt32,[x])
    if ENDIAN_BOM == 0x04030201
        vaxpart2 = parts[1]
        ieeepart1 = parts[2]
    else
        vaxpart2 = parts[2]
        ieeepart1 = parts[1]
    end

    if (ieeepart1 & ~SIGN_BIT) == 0
        vaxpart = UInt32(0)
    elseif (e::UInt32 = ieeepart1 & IEEE_T_EXPONENT_MASK) == IEEE_T_EXPONENT_MASK
        throw(InexactError())
    else
        e >>>= IEEE_T_MANTISSA_SIZE
        m = ieeepart1 & IEEE_T_MANTISSA_MASK

        if e == 0
            m = (m << 1) | (vaxpart2  >>> 31)
            vaxpart2 <<= 1
            while (m & IEEE_T_HIDDEN_BIT) == 0
                m = (m << 1) | (vaxpart2  >>> 31)
                vaxpart2 <<= 1
                e -= 1
            end
            m &= IEEE_T_MANTISSA_MASK
        end

        if (e += UNO + VAX_D_EXPONENT_BIAS - IEEE_T_EXPONENT_BIAS) <= 0
            vaxpart = UInt32(0)
            vaxpart2 = UInt32(0)
        elseif e > (2*VAX_D_EXPONENT_BIAS - 1)
            throw(InexactError())
        else
            vaxpart = UInt32(ieeepart1 & SIGN_BIT) |
                (e << VAX_D_MANTISSA_SIZE) |
                UInt32(m <<  (VAX_D_MANTISSA_SIZE - IEEE_T_MANTISSA_SIZE)) |
                (vaxpart2 >>> (32 - (VAX_D_MANTISSA_SIZE - IEEE_T_MANTISSA_SIZE)))
            vaxpart2 <<= (VAX_D_MANTISSA_SIZE - IEEE_T_MANTISSA_SIZE)
        end
    end

    return htol(reinterpret(VaxFloatD, reinterpret(UInt16,[vaxpart, vaxpart2])[[2,1,4,3]])[1])
end

function Base.convert(::Type{Float64}, x::VaxFloatD)
    parts = reinterpret(UInt16,[ltoh(x)])
    vaxpart1 = reinterpret(UInt32,parts[[2,1]])[1]
    vaxpart2 = reinterpret(UInt32,parts[[4,3]])[1]

    if (vaxpart1 & VAX_D_EXPONENT_MASK) == 0
        if (vaxpart1 & SIGN_BIT) == SIGN_BIT
            throw(InexactError())
        end

        out1 = UInt32(0)
        out2 = UInt32(0)
    else
        ieeepart1 = ((vaxpart1 & SIGN_BIT) |
                     ((vaxpart1 & ~SIGN_BIT) >>> 
                      (VAX_D_MANTISSA_SIZE - IEEE_T_MANTISSA_SIZE))) -
                     (UInt32(UNO + VAX_D_EXPONENT_BIAS - IEEE_T_EXPONENT_BIAS) << IEEE_T_MANTISSA_SIZE)
        ieeepart2 = (vaxpart1 << (32 - (VAX_D_MANTISSA_SIZE - IEEE_T_MANTISSA_SIZE))) |
                    (vaxpart2 >>> (VAX_D_MANTISSA_SIZE - IEEE_T_MANTISSA_SIZE))
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
Base.convert(::Type{T},x::VaxFloatD) where T <: Number = convert(T,convert(Float64,x))

Base.promote_rule(::Type{T},x::VaxFloatD) where T <: AbstractFloat = T

