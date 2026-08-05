macro nexus_accelerate(fn_def)
    # 1. Validate and capture the function syntax (supports both standard and short forms)
    if !(@capture(fn_def, function name_(args__) body_ end) || @capture(fn_def, name_(args__) = body_))
        error("[Nexus Compiler Error] Syntax error: @nexus_accelerate must be applied to a valid function definition.")
    end

    # 2. Extract arguments and type annotations
    arg_names = Symbol[]
    arg_types = Symbol[]

    for arg in args
        if @capture(arg, var_::T_)
            push!(arg_names, var)
            push!(arg_types, T)
        else
            push!(arg_names, arg)
            push!(arg_types, :Any) # Default fallback if no type annotation is provided
        end
    end


    # 3. Substitute the function body (prevents normal CPU execution)
    # Reconstructs a stub function that returns an interception tuple for Phase 2/3
    new_body = quote
        println("[Nexus Exec] Function '$($(QuoteNode(name)))' was bypassed. Redirecting to HW compilation pipeline...")
        return (
            name = $(QuoteNode(name)),
            args = $arg_names,
            types = $arg_types
        )
    end

    # Reconstruct AST with modified body
    modified_function = :(function $name($(args...))
        $new_body
    end)

    return modified_function
end