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

    @testset "Conversion..." begin
        for (vax, ieee) in zip(d8_vax, d8_ieee)
            @test VaxFloatD(vax) == VaxFloatD(ieee)
            @test convert(Float64, VaxFloatD(vax)) == ieee
        end
    end

    @testset "Promotion..." begin
        for t in [Int8, Int16, Int32, Int64, Int128, Float16, Float32, Float64]
            @test isa(one(t)*VaxFloatD(1), Float64)
        end
    end
end

