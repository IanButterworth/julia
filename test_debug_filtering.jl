using Test

println("Testing with filter: $(get(ENV, "JULIA_TEST_TESTSET_FILTER", "none"))")

@testset "outer" begin
    println("Running in outer testset")
    @test 1 == 1
    
    @testset "middle_2" begin
        println("Running in middle_2 testset")
        @test 2 == 2
        
        @testset "inner" begin
            println("Running in inner testset")
            @test 3 == 3
        end
    end
    
    @testset "other" begin
        println("Running in other testset")
        @test 4 == 4
    end
end
