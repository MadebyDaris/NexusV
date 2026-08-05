module MockFrontend

export get_mock_llvm

# This function fakes what the @nexus_accelerate macro will do later.
# Instead of compiling code, it just reads the text files you created.
function get_mock_llvm(operation::String)
    # The current file is in src/Frontend/
    # So we need to go up two directories to reach the root, then into mocks/
    filepath = joinpath(@__DIR__, "..", "..", "mocks", "mock_$(operation).ll")
    
    if isfile(filepath)
        println("[Mock Frontend] Successfully captured Julia function.")
        println("[Mock Frontend] Extracted LLVM IR for: $operation\n")
        
        # Read the file and return it as a string
        llvm_string = read(filepath, String)
        return llvm_string
    else
        error("Mock file not found!")
    end
end

end
