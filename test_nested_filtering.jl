using Test

@testset "Outer Package Tests" begin
    @testset "hashing" begin
        @test hash("hello") == hash("hello")
        @test hash(42) == hash(42)
    end

    @testset "other functionality" begin
        @test 1 + 1 == 2
        @test 2 * 3 == 6
    end
end

@testset "Another Top Level Test" begin
    @test 5 + 5 == 10
end
