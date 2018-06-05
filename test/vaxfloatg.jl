@testset "Vax Float G" begin
    g8_vax = [  0x0000000000004010,
                0x000000000000C010,
                0x000000000000402C,
                0x000000000000C02C,
                0x2D18544421FB4029,
                0x2D18544421FBC029,
                0x691B435717B847BE,
                0x691B435717B8C7BE,
                0x8B8F428A039D3861,
                0x8B8F428A039DB861,
                0x59DD428CC0CA4013,
                0x59DD428CC0CAC013 ]

    g8_ieee = Array{Float64}([  one(Float64),
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

    for (vax, ieee) in zip(g8_vax, g8_ieee)
        @test VaxFloatG(vax) == VaxFloatG(ieee)
        @test convert(Float64,VaxFloatG(vax)) == ieee
    end
end
