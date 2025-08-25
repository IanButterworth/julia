using Test

@testset "Outer" begin
    @testset "misc_tests" begin
        @test 1 + 1 == 2
    end
end
