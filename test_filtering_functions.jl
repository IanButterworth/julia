#!/usr/bin/env julia

# Comprehensive test of testset filtering functionality

using Test

println("Testing testset filtering functionality...")

# Test that the filter environment variable is read correctly
println("testset_filter() = ", Test.testset_filter())

# Test basic filtering functionality
println("\nTesting basic filtering...")

println("Testing should_skip_testset:")
println("  should_skip_testset(\"foo test\") = ", Test.should_skip_testset("foo test"))
println("  should_skip_testset(\"bar test\") = ", Test.should_skip_testset("bar test"))

# Test with DefaultTestSet objects
println("\nTesting with DefaultTestSet objects:")
foo_ts = Test.DefaultTestSet("foo test")
bar_ts = Test.DefaultTestSet("bar test")
println("  should_skip_testset(foo_ts) = ", Test.should_skip_testset(foo_ts))
println("  should_skip_testset(bar_ts) = ", Test.should_skip_testset(bar_ts))

# Test test counting
println("\nTesting test counting:")
test_expr = quote
    @test 1 == 1
    @test 2 == 2
    @test_throws BoundsError [1][2]
end
count = Test.count_tests_in_expr(test_expr)
println("  count_tests_in_expr for 3 tests = $count")

println("\nDone testing functionality.")
