using Pkg
using Test

# Create a simple test to demonstrate filtering with Pkg types
@testset "hashing" begin
    @test hash(Pkg.Types.Project()) == hash(Pkg.Types.Project())
    @test hash(Pkg.Types.VersionBound()) == hash(Pkg.Types.VersionBound())
    @test 2 + 2 == 4  # Additional test
end

@testset "other test" begin
    @test 1 + 1 == 2
    @test 3 + 3 == 6
end

@testset "more hashing tests" begin
    @test hash("hello") == hash("hello")
    @test hash(42) == hash(42)
end
