using Test

println("Testing precise filtering with JULIA_TEST_TESTSET_FILTER=\"$(get(ENV, "JULIA_TEST_TESTSET_FILTER", "none"))\"")

@testset "1" begin
    println("foo() - should be skipped")
    @test 1 + 1 == 2  # should be skipped
    @testset "2" begin
        println("bar() - should be skipped") 
        @test 2 + 2 == 4  # should be skipped
        @testset "3" begin
            println("baz() - should run")
            @test 3 + 3 == 6  # should run
        end
    end
end

println("Testing completed")
