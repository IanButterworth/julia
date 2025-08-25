#!/usr/bin/env julia

# Test script to verify testset filtering functionality

using Test

@testset "foo tests" begin
    @test 1 + 1 == 2
    @test 2 + 2 == 4
    @test "hello" == "hello"
end

@testset "bar tests" begin
    @test 3 + 3 == 6
    @test 4 + 4 == 8
end

@testset "baz tests with foo" begin
    @test 5 + 5 == 10
    @test 6 + 6 == 12
end

@testset "other tests" begin
    @test 7 + 7 == 14
    @test 8 + 8 == 16
end
