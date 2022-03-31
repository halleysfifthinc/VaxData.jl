# Define common arithmetic operations (default for two of the same unknown number type is to no-op error)
# Promotion rules are such that the promotion will always be to a valid IEEE number type,
# even in the case of two identical AbstractVax types
for op in [:+, :-, :*, :/, :^, :<=]
    @eval(begin
        Base.$op(x::T, y::T) where {T<:AbstractVax} = ($op)(promote(x,y)...)
    end)
end

Base.signbit(x::VaxFloat) = !iszero(x.x & 0x8000)
Base.:-(x::T) where {T<:VaxFloat} = T(x.x ⊻ 0x8000)

function Base.:<(x::T,y::T) where {T<:VaxFloat}
    if signbit(x) == signbit(y)
        return (swap16bword(x.x) & (typemax(uinttype(T)) >> 1)) < (swap16bword(y.x) & (typemax(uinttype(T)) >> 1))
    else
        return signbit(x) > signbit(y)
    end
end

# copied and slightly modified from Base
function nextfloat(f::VaxFloat, d::Integer)
    F = typeof(f)
    fumax = swap16bword(typemax(f).x)
    U = typeof(fumax)

    fi = signed(swap16bword(f.x))
    fneg = fi < 0
    fu = unsigned(fi & typemax(fi))

    dneg = d < 0

    da = Base.uabs(d)
    if da > typemax(U)
        fneg = dneg
        fu = fumax
    else
        du = da % U
        if fneg ⊻ dneg
            if du > fu
                fu = min(fumax, du - fu)
                fneg = !fneg
            else
                fu = fu - du
            end
        else
            if fumax - fu < du
                fu = fumax
            else
                fu = fu + du
            end
        end
    end
    if fneg
        fu |= SIGN_BIT
    end

    # Jump past the VAX FP reserved operand (sign = 1, exp = 0, mant ≠ 0)
    dz_hi = ~(swap16bword(exponent_mask(F)) % U)
    dz_lo = dz_hi - swap16bword(significand_mask(F))
    if dz_lo ≤ fu ≤ dz_hi
        return dneg ? nextfloat(F(0x00008080), d + 1) :
                      nextfloat(zero(F), d - 1)
    end

    return F(swap16bword(fu))
end

nextfloat(f::VaxFloat) = nextfloat(f,1)
prevfloat(f::VaxFloat) = nextfloat(f,-1)
prevfloat(f::VaxFloat, d::Integer) = nextfloat(f, -d)

