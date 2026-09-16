---
name: coverage
description: Look up test coverage for Julia's base/, stdlib/ and vendored Compiler/JuliaSyntax/JuliaLowering sources from Codecov, Coveralls or the raw lcov CI artifact, or collect it locally with an instrumented build. Use when asked whether a line, function or file is covered by the test suite, how to run coverage, or where coverage data comes from.
---

# Inspecting test coverage

Coverage is collected by the scheduled `Coverage` job in the `julialang/julia-ci`
Buildkite pipeline (defined in
[JuliaCI/julia-buildkite](https://github.com/JuliaCI/julia-buildkite) under
`pipelines/scheduled/coverage/`). Each platform builds with
`JULIA_COVERAGE_IMAGES=1`, runs the full test suite, uploads the lcov files as
a Buildkite artifact, and then pushes the merged result to Codecov and
Coveralls. Only `base/`, in-tree `stdlib/` packages, and the `src/` trees of the
vendored `Compiler`, `JuliaSyntax` and `JuliaLowering` are reported. Lines that
were never compiled are reported as uncovered, not omitted.

To answer a coverage question about master, query one of the three sources
below rather than collecting coverage locally: the instrumented build is a
normal rebuild, but running the full test suite under it takes several hours
(4 to 5 on CI). None of the sources needs a token. Collect locally only for an
unmerged change, or for one test file; see the local section below.

## Codecov: whole tree in one call

```sh
curl -s "https://api.codecov.io/api/v2/github/JuliaLang/repos/julia/report/?branch=master" -o codecov.json
```

Returns every file with a `line_coverage` array for the latest master commit
(about 1 MB). For one file:

```sh
curl -s "https://api.codecov.io/api/v2/github/JuliaLang/repos/julia/file_report/base/float.jl?branch=master"
```

Each `line_coverage` entry is `[line, status]`, where `status` is **0 = hit,
1 = miss, 2 = partial**. It is not a hit count; reading it as one inverts the
answer. `commit_sha` in the response says which commit the data is for, so
check it against the working tree before mapping line numbers.

Other commits: `.../commits?branch=master` lists commits with coverage, and
`file_report/<path>?sha=<sha>` selects one.

## Coveralls: real hit counts, one file per call

```sh
curl -s "https://coveralls.io/github/JuliaLang/julia.json?branch=master"      # summary, includes commit_sha
curl -s "https://coveralls.io/builds/<sha>/source.json?filename=base/float.jl"
curl -s "https://coveralls.io/builds/<sha>/source_files.json"                   # per-file totals only
```

`source.json` is a JSON array indexed 1:1 by source line: `null` for lines that
are not code, otherwise the merged hit count across platforms. Use this when the
number of hits matters; otherwise Codecov is fewer requests.

## Raw lcov artifact: per-platform counts

The only source that keeps platforms separate. Find the build from the commit
status, then the job and artifact through the anonymous frontend endpoints
described in the `buildkite-logs` skill:

```sh
gh api repos/JuliaLang/julia/commits/<sha>/status \
  --jq '.statuses[] | select(.context == "Coverage") | .target_url'   # .../julia-ci/builds/<N>#...
curl -sS -H "Accept: application/json" \
  "https://buildkite.com/julialang/julia-ci/builds/<N>/data/jobs" -o jobs.json   # ':linux: coverage (x86_64)' etc.
curl -sS -H "Accept: application/json" \
  "https://buildkite.com/organizations/julialang/pipelines/julia-ci/builds/<N>/jobs/<JOB-UUID>/artifacts"
curl -L -o lcov_files.tar.gz \
  "https://buildkite.com/organizations/julialang/pipelines/julia-ci/builds/<N>/jobs/<JOB-UUID>/artifacts/<ARTIFACT-ID>"
```

The tarball is around 100 MB per platform and is kept for 18 months. Paths
inside are as the test run saw them (`base/` files have no directory prefix,
stdlibs appear under `stdlib/vX.Y/`); `upload_coverage.jl` in julia-buildkite
shows how they are normalised and filtered. Read it with `Coverage.LCOV.readfolder`
from Coverage.jl. The download redirects to a signed S3 URL that only accepts
`GET`, so `curl -I` returns 403 even though the download works.

## Running coverage locally

A stock build only instruments code compiled in the running process, so Base
and stdlib code that lives in the system image or package images reports
nothing. To cover that code, build with instrumented images:

```sh
echo "JULIA_COVERAGE_IMAGES=1" >> Make.user
make -j
```

Keep that build separate from a normal one: the images stay instrumented even
when coverage is off, so timings from it are void. Then run tests with
`--code-coverage`, writing LCOV tracefiles; `%p` keeps the test workers from
clobbering each other:

```sh
./julia --code-coverage=lcov-%p.info -e 'Base.runtests(["all", "--skip", "Pkg"]; ncores=Sys.CPU_THREADS)'  # what CI runs
./julia --code-coverage=lcov-%p.info -e 'Base.runtests(["float"])'                                      # one test file
```

`--code-coverage=@base/float.jl` restricts the report to one path, and
`--code-coverage-mode=count` records execution counts instead of the default
hit/miss. Read the `.info` files with `Coverage.LCOV.readfolder` from
Coverage.jl, or `lcov`/`genhtml`. Without `--code-coverage=<file>` the
runtime writes `.cov` files next to each source file instead.

## More information

- `doc/src/manual/command-line-interface.md`: the `--code-coverage` and
  `--code-coverage-mode` flags and what `user`, `all` and `@<path>` select.
- `doc/src/devdocs/sysimg.md`, "Coverage instrumentation": how
  `JULIA_COVERAGE_IMAGES=1` instruments the system and package images, and
  which counters can serve which requests.
- `doc/src/devdocs/pkgimg.md`: how coverage flags take part in package image
  cache identity.
- `NEWS.md` entries for #62724: the hit-mode default and image reuse.
- [JuliaCI/julia-buildkite](https://github.com/JuliaCI/julia-buildkite),
  `pipelines/scheduled/coverage/`: the CI job (`coverage.yml`), the test
  invocation (`run_tests_parallel.jl`) and the filtering, merging and upload
  logic (`upload_coverage.jl`).
- [Coverage.jl](https://github.com/JuliaCI/Coverage.jl): LCOV parsing,
  merging, and the Codecov and Coveralls uploaders CI uses.

## Caveats

- Coverage lags master: it is produced by scheduled builds, not every merge.
  Compare the reported commit to the tree you are reading before trusting line
  numbers.
- Codecov and Coveralls agree line for line for a given commit; if they seem
  to disagree, check the status-code decoding above first.
- PR builds labelled `needs full CI` run the same collection and upload the
  lcov artifact to the `julia-pr` pipeline, but do not push to Codecov or
  Coveralls.
