# This file is a part of Julia. License is MIT: https://julialang.org/license

# Activate a temporary project that depends on every installed stdlib, so that building the
# stdlib caches does not depend on a hand-kept list.
let project = mktempdir()
    stdlibs = filter(name -> isfile(joinpath(Sys.STDLIB, name, "Project.toml")), readdir(Sys.STDLIB))
    open(joinpath(project, "Project.toml"), "w") do io
        println(io, "[deps]")
        for name in stdlibs
            uuid = Base.parsed_toml(joinpath(Sys.STDLIB, name, "Project.toml"))["uuid"]
            println(io, name, " = \"", uuid, "\"")
        end
    end
    Base.set_active_project(project)
end
