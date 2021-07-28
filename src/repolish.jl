mutable struct Repolish
    rhs_red::Ptr{Nothing}
    plsh::Ptr{Nothing}
    pol_sol::Ptr{Nothing}
    rhs::Ptr{Nothing}
    mred::Cc_int

end

function Repolish() 
    repolish = Repolish(Ptr{Nothing}(C_NULL), Ptr{Nothing}(C_NULL), Ptr{Nothing}(C_NULL), Ptr{Nothing}(C_NULL), -1)
    finalizer(OSQP.clean!, repolish)
    return repolish
end

function update_status!(model::OSQP.Model, status::Int64)
    model.isempty && throw(ErrorException("You are trying to polish an empty model. Please setup the model before calling polish!()."))
    workspace = unsafe_load(model.workspace)
    ccall((:update_status, OSQP.osqp), OSQP.Cc_int, (Ptr{OSQP.CInfo}, OSQP.Cc_int), workspace.info, status)
end

function repolish!(model::OSQP.Model, data::OSQP.Repolish, results::OSQP.Results = Results())
    model.isempty && throw(ErrorException("You are trying to polish an empty model. Please setup the model before calling polish!()."))
    ccall((:repolish, OSQP.osqp), OSQP.Cc_int, (Ptr{OSQP.Workspace}, Ref{OSQP.Repolish}), model.workspace, data)
    workspace = unsafe_load(model.workspace)
    info = results.info
    OSQP.copyto!(info, unsafe_load(workspace.info))
    solution = unsafe_load(workspace.solution)
    data = unsafe_load(workspace.data)
    n = data.n
    m = data.m
    resize!(results, n, m)
    has_solution = false
    for status in OSQP.SOLUTION_PRESENT
        info.status == status && (has_solution = true; break)
    end
    if has_solution
        # If solution exists, copy it
        unsafe_copyto!(pointer(results.x), solution.x, n)
        unsafe_copyto!(pointer(results.y), solution.y, m)
        fill!(results.prim_inf_cert, NaN)
        fill!(results.dual_inf_cert, NaN)
    else
        # else fill with NaN and return certificates of infeasibility
        fill!(results.x, NaN)
        fill!(results.y, NaN)
        if info.status == :Primal_infeasible || info.status == :Primal_infeasible_inaccurate
            unsafe_copyto!(pointer(results.prim_inf_cert), workspace.delta_y, m)
            fill!(results.dual_inf_cert, NaN)
        elseif info.status == :Dual_infeasible || info.status == :Dual_infeasible_inaccurate
            fill!(results.prim_inf_cert, NaN)
            unsafe_copyto!(pointer(results.dual_inf_cert), workspace.delta_x, n)
        else
            fill!(results.prim_inf_cert, NaN)
            fill!(results.dual_inf_cert, NaN)
        end
    end

    if info.status == :Non_convex
        info.obj_val = NaN
    end

    results
end

function update_active!(model::OSQP.Model, data::OSQP.Repolish)
    model.isempty && throw(ErrorException("You are trying to polish an empty model. Please setup the model before calling polish!()."))
    ccall((:update_active, OSQP.osqp), OSQP.Cc_int, (Ptr{OSQP.Workspace}, Ref{OSQP.Repolish}), model.workspace, data)
end

function cleanup!(model::OSQP.Model, data::OSQP.Repolish)
    model.isempty && throw(ErrorException("You are trying to polish an empty model. Please setup the model before calling polish!()."))
    ccall((:cleanup, OSQP.osqp), Nothing, (Ptr{OSQP.Workspace}, Ref{OSQP.Repolish}), model.workspace, data)
end

function clean!(data::OSQP.Repolish)
    ccall((:clean, OSQP.osqp), Nothing, (Ref{OSQP.Repolish}, ), data)
end