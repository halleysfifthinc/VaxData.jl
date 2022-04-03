@testset "Vax Float D" begin
    d8_vax = [  0x0000000000004080,
                0x000000000000c080,
                0x0000000000004160,
                0x000000000000c160,
                0x68c0a2210fda4149,
                0x68c0a2210fdac149,
                0x48d81abbbdc27df0,
                0x48d81abbbdc2fdf0,
                0x5c7814541cea0308,
                0x5c7814541cea8308,
                0xcee814620652409e,
                0xcee814620652c09e]

    d8_ieee = Array{Float64}([  one(Float64),
                                -one(Float64),
                                3.5,
                                -3.5,
                                Float64(pi),
                                -Float64(pi),
                                1.0e37,
                                -1.0e37,
                                9.9999999999999999999999999e-38,
                                -9.9999999999999999999999999e-38,
                                1.2345678901234500000000000000,
                                -1.2345678901234500000000000000 ])

    @testset "Basic operators" begin
        @test signbit(zero(VaxFloatD)) == false
        @test signbit(one(VaxFloatD)) == false
        @test signbit(-one(VaxFloatD)) == true
        @test signbit(-(-one(VaxFloatD))) == false

        @test zero(VaxFloatD) < one(VaxFloatD)
        @test !(one(VaxFloatD) < one(VaxFloatD))
        @test !(one(VaxFloatD) < zero(VaxFloatD))
        @test one(VaxFloatD) <= one(VaxFloatD)

        @test nextfloat(typemax(VaxFloatD)) == typemax(VaxFloatD)
        @test prevfloat(typemin(VaxFloatD)) == typemin(VaxFloatD)
        @test -prevfloat(-one(VaxFloatD)) == nextfloat(one(VaxFloatD))
        @test nextfloat(zero(VaxFloatD)) == floatmin(VaxFloatD)
        @test prevfloat(floatmin(VaxFloatD)) == zero(VaxFloatD)
        @test prevfloat(zero(VaxFloatD)) == -floatmin(VaxFloatD)
        @test nextfloat(-floatmin(VaxFloatD)) == zero(VaxFloatD)
    end

    @testset "Conversion..." begin
        for (vax, ieee) in zip(d8_vax, d8_ieee)
            @test VaxFloatD(vax) == VaxFloatD(ieee)
            @test convert(Float64, VaxFloatD(vax)) == ieee
        end
    end

    @testset "Promotion..." begin
        for t in [subtypes(VaxInt); subtypes(VaxFloat); Int8; Int16; Int32; Int64; Int128; Float16; Float32; Float64]
            @test isa(one(t)*VaxFloatD(1), Float64)
        end
        @test isa(one(BigInt)*VaxFloatD(1), BigFloat)
        @test isa(one(BigFloat)*VaxFloatD(1), BigFloat)

        un = one(VaxFloatD)
        @test promote(un, un, un) == (1.0, 1.0, 1.0)
        @test promote(un, un, un, un) == (1.0, 1.0, 1.0, 1.0)
    end

    @testset "Number definitions" begin
        @test floatmax(VaxFloatD) == typemax(VaxFloatD)
        @test -typemax(VaxFloatD) == typemin(VaxFloatD)

        @test zero(VaxFloatD) == 0
        @test one(VaxFloatD) == 1
    end

    @testset "Edge cases" begin
        # Reserved Vax floating point operand
        @test_throws InexactError convert(Float64, VaxFloatD(UInt64(0x8000)))

        # Inf and NaN should error too
        @test_throws InexactError VaxFloatD(Inf64)
        @test_throws InexactError VaxFloatD(-Inf64)
        @test_throws InexactError VaxFloatD(NaN64)

        # Both IEEE zeros should be converted to Vax true zero
        @test VaxFloatD(-0.0) === VaxFloatD(0.0) === zero(VaxFloatD)

        # Dirty zero
        @test convert(Float64, VaxFloatD(UInt64(0x08))) === zero(Float64)

        # Numbers smaller than floatmin(VaxFloatD) should underflow
        @test VaxFloatD(prevfloat(convert(Float64, floatmin(VaxFloatD)))) === zero(VaxFloatD)
        @test VaxFloatD(convert(Float64, floatmin(VaxFloatD))) === floatmin(VaxFloatD)

        # Numbers larger than floatmax(VaxFloatD) should error
        @test_throws InexactError VaxFloatD(nextfloat(convert(Float64, floatmax(VaxFloatD))))

        # Because the D Float as more precision, the conversion to Float64 and back to D Float will not be circular
        # @test VaxFloatD(convert(Float64, floatmax(VaxFloatD))) === floatmax(VaxFloatD)
    end

    @testset "IO" begin
        io = IOBuffer(reinterpret(UInt8, ones(VaxFloatD, 4)))
        @test read(io, VaxFloatD) === one(VaxFloatD)
        @test read!(io, Vector{VaxFloatD}(undef, 3)) == ones(VaxFloatD, 3)
    end
end

