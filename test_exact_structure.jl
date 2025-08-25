using Test

@testset "Outer" begin
    @testset "misc.jl" begin
        @testset "hashing" begin
            @test 1 == 1
        end
    end
end
