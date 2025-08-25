using Test

@testset "Package A" begin
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

@testset "Package B" begin
    @testset "networking" begin
        @test true
    end

    @testset "hashing_core" begin
        @test hash([1,2,3]) == hash([1,2,3])
        @test hash("hello") != hash("world")
    end
end

@testset "Package C" begin
    @testset "unrelated_stuff" begin
        @test 5 + 5 == 10
    end
end
