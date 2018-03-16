module DProfile

export @dprofile

const samples = Dict{Int, Vector{UInt64}}()
const dict = Profile.getdict(UInt64[])

"""
`@profile <expression>`

runs expression while taking periodic backtraces.
The expression may spawn sub tasks on workers processes.
These are appended to an internal buffer of backtraces.

`DProfile.print()` will print the collated profile
"""
macro dprofile(ex)
    quote
        try
            @everywhere begin
                status = Profile.start_timer()
                if status < 0
                    error(Base.Profile.error_codes[status])
                end
            end
            $(esc(ex))
        finally
            @everywhere Profile.stop_timer()

            ps = procs()

            results = fetch.(map(p->remotecall(p) do
                samples = Base.Profile.fetch()
                (samples, Base.Profile.getdict(samples))
            end, ps))

            for (p, res) in zip(ps, results)
                samples, lineinfo = res
                if !haskey(DProfile.samples, p)
                    DProfile.samples[p] = UInt64[]
                end

                append!(DProfile.samples[p], samples)
                dict = reduce(merge, last.(results))

                merge!(DProfile.dict, dict)
            end
        end
    end
end

"""
`DProfile.print(;pids=procs())`

Prints the results of distributed profiling. `pids` will let you
constrain samples to only selected `pids`. Any arguments to
`Base.Profile.print` are also supported.
"""
function print(args...;pids = keys(samples), kwargs...)
    samps = UInt64[]
    for p in pids
        append!(samps, samples[p])
    end
    Base.Profile.print(args..., samps, dict; kwargs...)
end

"""
Clear backtraces from profile buffers on all processes.
"""
function clear()
    @everywhere Profile.clear()
    empty!(samples)
    empty!(dict)
    nothing
end

"""
`DProfile.init(; n::Integer, delay::Float64)`

Runs `Profile.init` with the given args on all processes.
"""
function init(args...;kwargs...)
    if length(args) == 0 && length(kwargs) == 0
        fetch.(
            remotecall.((pid) -> pid => Profile.init(), procs(), procs())
        )
    else
        @everywhere Profile.init($(args...); $(kwargs...))
    end
end

end
