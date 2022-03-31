struct VaxFloatF <: VaxFloat
    x::UInt32

    VaxFloatF(x::UInt32) = new(ltoh(x))
end

function VaxFloatF(x::T) where {T<:Real}
    ieeepart1 = reinterpret(UInt32, convert(Float32, x))
    e = reinterpret(Int32, ieeepart1 & IEEE_S_EXPONENT_MASK)

    if ieeepart1 & ~SIGN_BIT === zero(UInt32)
        # ±0.0 becomes 0.0
        return zero(VaxFloatF)
    elseif e === IEEE_S_EXPONENT_MASK
        # Vax types don't support ±Inf or NaN
        throw(InexactError(:VaxFloatF, VaxFloatF, x))
    else
        e >>>= VAX_F_MANTISSA_SIZE
        m = ieeepart1 & VAX_F_MANTISSA_MASK

        if e === zero(Int32)
            m <<= 1
            while m & VAX_F_HIDDEN_BIT === zero(UInt32)
                m <<= UNO
                e -= one(Int32)
            end
            m &= VAX_F_MANTISSA_MASK
        end

        e += one(Int32) + VAX_F_EXPONENT_BIAS - IEEE_S_EXPONENT_BIAS
        if e <= 0
            # Silent underflow
            return zero(VaxFloatF)
        elseif e > (2*VAX_F_EXPONENT_BIAS - 1)
            # Overflow
            throw(InexactError(:VaxFloatF, VaxFloatF, x))
        else
            vaxpart = (ieeepart1 & SIGN_BIT) | (e << VAX_F_MANTISSA_SIZE) | m
        end
    end

    vaxpart = htol(vaxpart)
    vaxpart1 = vaxpart & bmask16
    vaxpart2 = (vaxpart >>> 16) & bmask16
    vaxpart1 = (vaxpart1 << 16) | vaxpart2

    return VaxFloatF(vaxpart1)
end

function convert(::Type{Float32}, x::VaxFloatF)
    y = x.x
    vaxpart1 = y & bmask16
    vaxpart2 = (y >>> 16) & bmask16
    vaxpart1 = (vaxpart1 << 16) | vaxpart2

    e = reinterpret(Int32, vaxpart1 & VAX_F_EXPONENT_MASK)

    if e === zero(Int32)
        if vaxpart1 & SIGN_BIT === SIGN_BIT
            # Reserved floating-point reserved operand
            throw(InexactError(:convert, Float32, x))
        end

        # Dirty zero
        return zero(Float32)
    else
        e >>>= VAX_F_MANTISSA_SIZE

        e -= one(Int32) + VAX_F_EXPONENT_BIAS - IEEE_S_EXPONENT_BIAS
        if e > zero(Int32)
            out = vaxpart1 -
                (( UNO + VAX_F_EXPONENT_BIAS - IEEE_S_EXPONENT_BIAS ) <<
                    IEEE_S_MANTISSA_SIZE)
        else
            # out will be a subnormal
            out = (vaxpart1 & SIGN_BIT) |
                ((VAX_F_HIDDEN_BIT | (vaxpart1 & VAX_F_MANTISSA_MASK)) >>> (UNO - e))
        end
    end

    return reinterpret(Float32, out)
end

function convert(::Type{T}, x::VaxFloatF) where {T<:Union{Float16,Float64,BigFloat,Integer}}
    return convert(T, convert(Float32, x))
end

floatmax(::Type{VaxFloatF}) = VaxFloatF(0xffff7fff)
floatmin(::Type{VaxFloatF}) = VaxFloatF(0x00010000)
typemax(::Type{VaxFloatF}) = VaxFloatF(0xffff7fff)
typemin(::Type{VaxFloatF}) = VaxFloatF(typemax(UInt32))

zero(::Type{VaxFloatF}) = VaxFloatF(0x00000000)
one(::Type{VaxFloatF}) = VaxFloatF(0x00004080)

uinttype(::Type{VaxFloatF}) = UInt32

exponent_bits(::Type{VaxFloatF}) = VAX_F_EXPONENT_SIZE
exponent_mask(::Type{VaxFloatF}) = VAX_F_EXPONENT_MASK
exponent_bias(::Type{VaxFloatF}) = VAX_F_EXPONENT_BIAS
significand_bits(::Type{VaxFloatF}) = VAX_F_MANTISSA_SIZE
significand_mask(::Type{VaxFloatF}) = VAX_F_MANTISSA_MASK

