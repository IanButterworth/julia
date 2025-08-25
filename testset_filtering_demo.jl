"""
Test file demonstrating Julia Test.jl testset filtering capabilities and limitations.

Run with different filters to see the behavior:
    JULIA_TEST_TESTSET_FILTER="hashing" julia testset_filtering_demo.jl
    JULIA_TEST_TESTSET_FILTER="networking" julia testset_filtering_demo.jl
    JULIA_TEST_TESTSET_FILTER="math" julia testset_filtering_demo.jl
    JULIA_TEST_TESTSET_FILTER="3" julia testset_filtering_demo.jl

This file demonstrates:
1. ✅ Precise filtering - only code inside matching testsets runs
2. ✅ Intelligent parent-child filtering with lookahead
3. ✅ Multiple package filtering
4. ✅ Nested testset filtering
5. ❌ Include-based limitation (see included_tests.jl)
"""

using Test

println("=== Testing Precise Testset Filtering Feature ===")
filter_str = get(ENV, "JULIA_TEST_TESTSET_FILTER", "none")
println("Filter: $filter_str")
println()

# ✅ WORKS: Precise filtering - only matching content runs
@testset "Outer Container" begin
    println("❌ This should NOT print when filtering for 'inner'")
    @test 1 == 1  # Should be skipped when filtering for 'inner'
    
    @testset "inner_target" begin
        println("✅ This SHOULD print when filtering for 'inner'")
        @test 2 == 2  # Should run when filtering for 'inner'
        @test 3 == 3  # Should run when filtering for 'inner'
    end
    
    @testset "other_nested" begin
        println("❌ This should NOT print when filtering for 'inner'")
        @test 4 == 4  # Should be skipped when filtering for 'inner'
    end
end

# ✅ WORKS: Direct match runs all content
@testset "hashing_algorithms" begin
    println("✅ This SHOULD print when filtering for 'hashing'")
    @test hash("test") == hash("test")
    @test hash([1,2,3]) == hash([1,2,3])
    
    @testset "nested_under_hashing" begin
        println("✅ This SHOULD also print when filtering for 'hashing'")
        @test length("test") == 4
    end
end

# ✅ WORKS: Demonstrates different filtering outcomes
@testset "Complex Example" begin
    println("❓ Conditional - prints only if parent or child matches")
    @test 100 == 100
    
    @testset "networking_protocols" begin
        println("✅ This SHOULD print when filtering for 'networking'")
        @test "tcp" == "tcp"
        @test length("protocol") == 8
        
        @testset "deeply_nested" begin
            println("✅ This SHOULD also print when filtering for 'networking'")
            @test true
        end
    end
    
    @testset "math_operations" begin
        println("✅ This SHOULD print when filtering for 'math'")
        @test 2 + 2 == 4
        @test sqrt(16) == 4
    end
    
    @testset "unrelated_stuff" begin
        println("❌ This should NOT print with specific filters")
        @test "hello" == "hello"
    end
end

println()
println("=== Expected Behavior Summary ===")
if filter_str == "none"
    println("No filter - all content should run and print")
elseif filter_str == "inner"
    println("Filter='inner':")
    println("  ❌ 'Outer Container' direct content skipped")
    println("  ✅ 'inner_target' content runs")
    println("  ❌ 'other_nested' skipped entirely")
    println("  ❌ 'hashing_algorithms' skipped entirely")
    println("  ❌ 'Complex Example' direct content skipped")
    println("  ❌ All nested in 'Complex Example' skipped")
elseif filter_str == "hashing"
    println("Filter='hashing':")
    println("  ❌ 'Outer Container' skipped entirely")
    println("  ✅ 'hashing_algorithms' ALL content runs")
    println("  ❌ 'Complex Example' skipped entirely")
elseif filter_str == "networking"
    println("Filter='networking':")
    println("  ❌ 'Outer Container' skipped entirely") 
    println("  ❌ 'hashing_algorithms' skipped entirely")
    println("  ❌ 'Complex Example' direct content skipped")
    println("  ✅ 'networking_protocols' ALL content runs")
    println("  ❌ 'math_operations' skipped")
    println("  ❌ 'unrelated_stuff' skipped")
elseif filter_str == "math"
    println("Filter='math':")
    println("  ❌ 'Outer Container' skipped entirely")
    println("  ❌ 'hashing_algorithms' skipped entirely") 
    println("  ❌ 'Complex Example' direct content skipped")
    println("  ❌ 'networking_protocols' skipped")
    println("  ✅ 'math_operations' content runs")
    println("  ❌ 'unrelated_stuff' skipped")
else
    println("Custom filter='$filter_str' - check which testset names contain this pattern")
end
println()
