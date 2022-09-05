using VaxData, Test, InteractiveUtils

@testset "General" begin
    # Overflowing conversion
    @test_throws InexactError convert(VaxFloatF, big"1.7e39")

    @test sprint(show, vaxf"1.0") == "vaxf\"1.0\""

    @test -one(VaxFloatF) < one(VaxFloatF)
    @test one(VaxFloatF) < nextfloat(one(VaxFloatF))

    @test -one(VaxFloatF) <= one(VaxFloatF)
    @test one(VaxFloatF) <= nextfloat(one(VaxFloatF))

    @test prevfloat(one(VaxFloatF), -5) === nextfloat(one(VaxFloatF), 5)
end

include("vaxints.jl")
include("vaxfloatf.jl")
include("vaxfloatd.jl")
include("vaxfloatg.jl")

