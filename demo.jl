#!/usr/bin/env julia

# Example demonstrating testset filtering

using Test

println("=== Testset Filtering Demo ===")
println("Filter: ", get(ENV, "JULIA_TEST_TESTSET_FILTER", "none"))
println()

@testset "Basic math tests" begin
    @test 1 + 1 == 2
    @test 2 * 3 == 6
end

@testset "String foo operations" begin
    @test "hello" * " " * "world" == "hello world"
    @test length("foo") == 3
    @test contains("foobar", "foo")
end

@testset "Array operations" begin
    @test [1, 2, 3] == [1, 2, 3]
    @test length([1, 2, 3, 4]) == 4
end

@testset "Advanced foo algorithms" begin
    @test sort([3, 1, 2]) == [1, 2, 3]
    @test reverse([1, 2, 3]) == [3, 2, 1]
end

@testset "Performance tests" begin
    @test 2^10 == 1024
    @test factorial(5) == 120
end

println("\n=== Demo Complete ===")
println("Run with: JULIA_TEST_TESTSET_FILTER=\"foo\" julia demo.jl")
println("to only run testsets containing 'foo'")
