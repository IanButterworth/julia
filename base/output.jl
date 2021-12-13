# This file is a part of Julia. License is MIT: https://julialang.org/license

"""
    exit_save_sysimage(fpath::String)

Save the current state as a sysimage. The sysimage is saved after julia exit, which this
function triggers.
"""
function exit_save_sysimage(fpath::String)
    fpath = abspath(fpath)
    ccall(:jl_options_set_outputo, Cvoid, (Cstring,), fpath)
    ccall(:jl_restore_module_init_order_cache, Cvoid, ())
    @info "Julia exiting. A sysimage will be generated at $(repr(fpath))"
    exit()
end
