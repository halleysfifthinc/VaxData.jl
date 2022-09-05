function isvalid_bitpattern(::Type{T}, x::UInt32) where {T<:VaxFloat}
    (~Base.exponent_mask(T) ⊻ (x | Base.exponent_mask(T))) === typemax(x)
end

inexacts = [ UInt32[] for _ in 1:Threads.nthreads() ]

Threads.@threads for i in typemin(UInt32):typemax(UInt32)
    !isvalid_bitpattern(VaxFloatF, i) && continue
    if convert(VaxFloatF, convert(BigFloat, VaxFloatF(i))) !== VaxFloatF(i)
        push!(inexacts[Threads.threadid()], i)
    end
end

allinexact = reduce(vcat, inexacts)

@test isempty(allinexact)

