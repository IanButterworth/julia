using Test

@testset "Test Filtering Feature" begin
    @testset "feature_one" begin
        @test 1 + 1 == 2
        @test 2 + 2 == 4
    end

    @testset "feature_two" begin
        @test 3 + 3 == 6
        @test 4 + 4 == 8
    end

    @testset "hashing_utils" begin
        @test hash("test") == hash("test")
        @test hash(123) == hash(123)
    end
end
