# Utilities
# N.B. Cannot call constants directly. Constants in headers are not shared in dynamically linked library
# function constant(constant_name)
#         constant = ccall((:osqp_constant, OSQP.osqp), Clong, (Ptr{Clong}))
#         return constant
# end

SUITESPARSE_LDL_SOLVER=0
MKL_PARDISO_SOLVER=1

# Define OSQP infinity constants
OSQP_INFTY = 1e20

# OSQP return values
# https://github.com/oxfordcontrol/osqp/blob/master/include/constants.h
const status_map = Dict{Int, Symbol}(
    4 => :Dual_Infeasible_Inaccurate,
    3 => :Primal_Infeasible_Inaccurate,
    2 => :Solved_Inaccurate,
    1 => :Solved,
    -2 => :Max_Iter_Reached,
    -3 => :Primal_Infeasible,
    -4 => :Dual_Infeasible,
    -5 => :Interrupted,
    -10 => :Unsolved
)


# updatable_data
updatable_data = [:q, :l, :u, :Px, :Px_idx, :Ax, :Ax_idx]

# updatable_settings
updatable_settings = [:max_iter, :eps_aps, :eps_rel, :eps_prim_inf, :eps_dual_inf,
		      :rho, :alpha, :delta, :polish, :polish_refine_iter, :verbose, 
		      :check_termination,:warm_start]

