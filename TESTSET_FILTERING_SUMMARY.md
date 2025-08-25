# Julia Test.jl Testset Filtering Feature

## Overview

This document describes the testset filtering functionality added to Julia's Test.jl module, which allows users to selectively run testsets based on pattern matching with **precise content execution**.

## Usage

Set the `JULIA_TEST_TESTSET_FILTER` environment variable to filter testsets:

```bash
JULIA_TEST_TESTSET_FILTER="pattern" julia test_file.jl
```

Only testsets whose descriptions contain the specified pattern will run their content. Other testsets will be skipped appropriately.

## Features

### ✅ Core Functionality

1. **Pattern Matching**: Testsets are filtered based on whether their description contains the filter string
2. **Precise Content Execution**: Only code inside matching testsets executes - parent testset structure is preserved but their direct content is skipped
3. **Intelligent Parent-Child Logic**: Parent testsets run if they contain matching child testsets, but only the matching children's content executes
4. **Skipped Result Type**: New `Skipped` result type with light black color display
5. **Complete Test Counting**: All skipped tests are properly counted and displayed
6. **No False Failures**: Skipped tests don't cause the overall test run to fail

### ✅ Precise Filtering Behavior

The filtering implements three distinct behaviors:

1. **Direct Match**: If a testset matches the filter, ALL its content runs (including nested testsets)
2. **Indirect Match**: If a testset doesn't match but contains matching children, it runs but only nested matching testsets execute their content
3. **No Match**: If a testset doesn't match and has no matching children, it's skipped entirely

### ✅ Output Format

The test summary includes a new "Skipped" column:

```text
Test Summary: | Pass  Skipped  Total  Time
Package A     |    2        4      6  0.0s
```

## Implementation Details

### New Functions Added

- `testset_filter()` - Get filter string from environment variable
- `should_skip_testset()` - Basic filtering logic
- `should_skip_testset_with_lookahead()` - Intelligent filtering with nested search
- `has_matching_nested_testset()` - Search for matching descendants
- `record_skipped_testset()` - Record tests as skipped
- `count_tests_in_expr()` - Count tests in expressions

### Modified Components

- **TestCounts struct**: Added `skipped` and `cumulative_skipped` fields
- **Result types**: Added `Skipped` result type with serialization support
- **Printing functions**: Updated to display skipped counts
- **Macro expansion**: Modified `@testset` to include filtering logic

## Limitations

### ❌ Include-Based Test Structure

The filtering cannot see into files loaded via `include()` statements. For example:

```julia
@testset "Package" begin
    include("test_file1.jl")  # Contains @testset "hashing"
    include("test_file2.jl")  # Contains other tests
end
```

In this case, filtering for "hashing" will skip the entire "Package" testset because the lookahead logic cannot see into the included files.

### ❌ Runtime String Interpolation

Complex string interpolation in testset descriptions may not be handled correctly:

```julia
@testset "Test $complex_expression" begin
    # This may not filter as expected
end
```

### ❌ Dynamic Testset Generation

Testsets generated dynamically at runtime are not visible to the filtering logic:

```julia
for name in dynamically_generated_names
    @testset "$name tests" begin
        # Filtering cannot predict these names
    end
end
```

## Examples

### Basic Filtering

```julia
using Test

@testset "Package Tests" begin
    @testset "feature_one" begin
        @test 1 + 1 == 2
    end
    
    @testset "hashing_utils" begin
        @test hash("test") == hash("test")
    end
end
```

```bash
# Run only hashing tests
JULIA_TEST_TESTSET_FILTER="hashing" julia test_file.jl
```

Output:
```
Test Summary:   | Pass  Skipped  Total  Time
Package Tests   |    1        1      2  0.0s
```

### Multi-Package Filtering

```julia
@testset "Package A" begin
    @testset "networking" begin
        @test true
    end
    @testset "hashing_core" begin
        @test hash([1,2,3]) == hash([1,2,3])
    end
end

@testset "Package B" begin
    @testset "unrelated" begin
        @test 2 + 2 == 4
    end
end
```

```bash
JULIA_TEST_TESTSET_FILTER="hashing" julia test_file.jl
```

Output:
```
Test Summary: | Pass  Skipped  Total  Time
Package A     |    1        1      2  0.0s
Test Summary: | Skipped  Total  Time
Package B     |       1      1  0.0s
```

## Best Practices

1. **Use descriptive testset names** that clearly indicate their purpose
2. **Organize related tests** into nested testsets for better filtering granularity
3. **Avoid complex string interpolation** in testset descriptions when filtering is needed
4. **Consider test organization** when using include-based structures if filtering is important

## Future Enhancements

Potential improvements could include:

1. **File-level filtering**: Support for filtering which test files to include
2. **Regex support**: More sophisticated pattern matching
3. **Multiple filters**: Support for multiple filter patterns
4. **Include-aware parsing**: Static analysis of included test files

## Technical Notes

The filtering is implemented at the macro expansion level, which means:

- It works at compile time for statically defined testsets
- It has minimal runtime overhead
- It integrates seamlessly with existing Test.jl infrastructure
- It maintains backward compatibility (no filtering when environment variable is not set)

The lookahead mechanism recursively searches the Abstract Syntax Tree (AST) of testset expressions to find nested @testset macro calls, enabling intelligent parent-child filtering decisions.
