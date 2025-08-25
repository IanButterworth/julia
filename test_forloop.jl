#!/usr/bin/env julia

# Test script with for loop testsets

using Test

@testset "test with value $i" for i in 1:3
    @test i > 0
    @test i <= 3
end

@testset "foo test with value $i" for i in 1:2
    @test i + i == 2*i
end

@testset "bar test with value $i" for i in 1:2
    @test i * i == i^2
end
