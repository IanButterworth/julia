@testset "included_hashing_tests" begin
    @test hash("included") == hash("included")
    @test 2 + 2 == 4
end

@testset "other_included_tests" begin
    @test "hello" == "hello"
end
