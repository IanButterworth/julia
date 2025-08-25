using Test

# Test that the core filtering functionality works
@testset "Test Filtering Summary" begin
    @testset "Direct Match" begin
        @test 1 == 1  # Should run with filter "Direct"
    end

    @testset "Parent Contains Child" begin
        @testset "child_hashing" begin
            @test hash("test") == hash("test")  # Should run with filter "hashing"
        end
        @testset "child_other" begin
            @test 2 == 2  # Should be skipped with filter "hashing"
        end
    end

    @testset "Unrelated" begin
        @test 3 == 3  # Should be skipped with filter "hashing"
    end
end
