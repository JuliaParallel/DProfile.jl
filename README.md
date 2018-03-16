# DProfile

## Usage

```
julia> using DProfile

julia> @dprofile @everywhere sum(sqrt.(rand(10^7)))

julia> DProfile.print()
211 ./distributed/macros.jl:102; (::##135#143)()
 211 ./distributed/remotecall.jl:367; remotecall_fetch(::Function, ::Int64, ::Expr, ::Vararg{Expr,N} where N)
  211 ./distributed/remotecall.jl:367; #remotecall_fetch#144(::Array{Any,1}, ::Function, ::Function, ::Int64, ::Expr, ...
   211 ./distributed/remotecall.jl:339; remotecall_fetch(::Function, ::Base.Distributed.LocalProcess, ::Expr, ::Vararg...
    211 ./distributed/remotecall.jl:339; #remotecall_fetch#140(::Array{Any,1}, ::Function, ::Function, ::Base.Distribut...
     211 ./distributed/process_messages.jl:56; run_work_thunk(::Base.Distributed.##135#136{Base.Distributed.#eval_ew_expr,Tup...
      211 ./distributed/remotecall.jl:314; (::Base.Distributed.##135#136{Base.Distributed.#eval_ew_expr,Tuple{Expr},Arra...
       211 ./distributed/macros.jl:116; eval_ew_expr
        65  ./broadcast.jl:455; broadcast(::Function, ::Array{Float64,1})
         1  ./broadcast.jl:312; broadcast_c
          1 ./inference.jl:5401; return_type(::Any, ::Any)
         64 ./broadcast.jl:316; broadcast_c
          12 ./broadcast.jl:268; broadcast_t(::Function, ::Type{T} where T, ::Tuple{Base.OneTo{Int64}}, ::Ca...
          52 ./broadcast.jl:270; broadcast_t(::Function, ::Type{T} where T, ::Tuple{Base.OneTo{Int64}}, ::Ca...
           52 ./broadcast.jl:141; _broadcast!(::Base.#sqrt, ::Array{Float64,1}, ::Tuple{Tuple{Bool}}, ::Tupl...
            52 ./broadcast.jl:149; macro expansion
             52 ./simdloop.jl:73; macro expansion
...
```

## API

- `@dprofile expr` -- run expr which may spawn tasks on other workers, track periodic backtraces
- `DProfile.print(;pids = procs(), args...)` -- print profile results with samples from given `pids`. `args` are the same as those for `Base.Profile.print`
- `DProfile.clear()` -- clear profile data everywhere
- `DProfile.init(; n, delay)` -- set `Base.Profile.init` options everywhere
