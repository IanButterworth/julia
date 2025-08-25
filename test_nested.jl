#!/usr/bin/env julia

# Test script with nested testsets

using Test

@testset "outer foo tests" begin
    @test 1 + 1 == 2

    @testset "inner test 1" begin
        @test 2 + 2 == 4
        @test 3 + 3 == 6
    end

    @testset "inner test 2" begin
        @test 4 + 4 == 8
    end

    @test 5 + 5 == 10
end

@testset "outer bar tests" begin
    @test 6 + 6 == 12

    @testset "inner test 3" begin
        @test 7 + 7 == 14
        @test 8 + 8 == 16
    end
end
