using Test

# Let's test what we have so far
@testset "Parent" begin
    @testset "child_with_misc" begin
        @test 1 == 1
    end

    @testset "other_child" begin
        @test 2 == 2
    end
end
