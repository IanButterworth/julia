# Precompilation API Design

## Goals
- Allow package precompilation to run in foreground (blocking) or background (non-blocking)
- Allow users to monitor, detach from, stop, or cancel background precompilation
- Keep the API simple and the implementation maintainable

## Execution Modes

### 1. Foreground (Blocking)
Default behavior. Precompilation runs in background task, monitored by the front task, blocking the REPL.
- Shows progress in real-time
- Returns when complete
- Can be interrupted with Ctrl-C
- Can be cancelled with `c`
- Can be detatched from with `d`

### 2. Background (Non-blocking)
Like 1, but detatches immediately, returning control to the REPL.
- No monitoring
- Can be monitored, where it can be cancelled, or re-detatched from later


## API Structure

```julia
# Main entry point
precompilepkgs(pkgs;
    mode::Symbol = :foreground,  # :foreground or :background
    # ... other options
)

# Background control (separate functions)
Base.Precompilation.monitor_background_precompile()    # Attach to running background task
Base.Precompilation.stop_background_precompile(graceful)  # Stop background task
Base.Precompilation.is_precompiling_in_background()    # Check if background task is running
```

## Simplified Function Structure

```
precompilepkgs(pkgs; mode=:foreground, ...)
  └─> _precompilepkgs(pkgs, ..., mode)
      └─> launch_background_precompile(pkgs, ...)  [always runs in background]
      └─> if mode == :foreground: monitor_background_precompile() [blocks]
      └─> if mode == :background: return immediately

launch_background_precompile(pkgs, ...)
  └─> spawn background task → do_precompile(pkgs, ...)
  └─> manages BACKGROUND_PRECOMPILE state
  └─> handles output streaming with notifications

do_precompile(pkgs, ...)
  └─> actual precompilation logic (mode-agnostic)
  └─> parallel compilation, dependency resolution, etc.

monitor_background_precompile(io)
  └─> attach to BACKGROUND_PRECOMPILE.task
  └─> stream output from buffer
  └─> allow 'd' to detach (returns to REPL)
  └─> allow 'c' to cancel (interrupts task)

stop_background_precompile(graceful=true)
  └─> if graceful: set flag, task checks and exits
  └─> if !graceful: schedule InterruptException
```

## Implementation Plan

### Phase 1: Simplify parameters ✅ COMPLETE
- Replaced `detach`, `detachable`, `monitor`, `stop`, `cancel` with single `mode` parameter
- Kept other precompile options unchanged

### Phase 2: Refactor internal functions ✅ COMPLETE
```julia
# Public API
precompilepkgs(pkgs; mode=:foreground, ...)
  → routes to appropriate mode

# Internal functions
_precompilepkgs(pkgs, ..., mode)
  → launches background task, optionally monitors

do_precompile(pkgs, io, fancyprint, ...)
  → actual precompilation logic (no mode awareness)

launch_background_precompile(pkgs, ...)
  → wrapper that spawns do_precompile in background task
  → manages BACKGROUND_PRECOMPILE state
```

### Phase 3: Background control (already exists)
```julia
# Module-level functions for background control
monitor_background_precompile(io)
stop_background_precompile(graceful=true)
is_precompiling_in_background()
```

## Benefits of This Design

1. **Clear separation of concerns**
   - `_do_precompile()` doesn't know about modes
   - Background logic isolated in `_run_in_background()`
   - Control operations are separate functions

2. **Single mode parameter**
   - Eliminates conflicting combinations
   - Makes behavior predictable
   - Easier to document

3. **Simpler call sites**
   ```julia
   # Pkg auto-precompile (monitored, allows detaching)
   precompilepkgs(pkgs; mode=:monitored, internal_call=true)

   # Explicit pkg> precompile (foreground)
   precompilepkgs(pkgs)

   # Explicit pkg> precompile --detach (background)
   precompilepkgs(pkgs; mode=:background)
   ```

4. **Testing**
   - Each mode can be tested independently
   - No complex parameter combinations

## Migration Path

1. Add `mode` parameter alongside existing parameters (deprecated)
2. Update Pkg.jl to use new `mode` parameter
3. Remove old parameters in next breaking release

## Open Questions

1. Should `:monitored` be the default for `internal_call=true`?
2. How to handle `_from_loading` mode interactions?
3. Should we expose `mode` in Pkg REPL or keep as internal?
