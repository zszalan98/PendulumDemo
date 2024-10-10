module PendulumDemo

using ModelingToolkit
using OrdinaryDiffEq

export sys, prob, resolve, startup_thetas, startup_omegas, startup_x, startup_y

using ModelingToolkit: t_nounits as t, D_nounits as D
# Pendulum model
@mtkmodel Pendulum begin
    @parameters begin
        g, [description="Gravity", unit="m/s²"]
        L, [description="Length of the pendulum", unit="m"]
    end
    @variables begin
        θ(t), [description="Angle of the pendulum", unit="rad"]
        ω(t), [description="Angular velocity of the pendulum", unit="rad/s"]
        x(t), [description="x-coordinate of the pendulum", unit="m"] 
        y(t), [description="y-coordinate of the pendulum", unit="m"]
    end
    @equations begin
        D(θ) ~ ω
        D(ω) ~ -g/L*sin(θ)
        x ~ L*sin(θ)
        y ~ -L*cos(θ)
    end
end

@mtkbuild sys = Pendulum()
u0 = [sys.θ => 2.5, sys.ω => 0.0]
p = [sys.g => 9.81, sys.L => 1.0]
tspan = (0.0, 10.0)
prob = ODEProblem(sys, u0, tspan, p, eval_module = @__MODULE__, eval_expression = true)
sol = solve(prob)

times = collect(0.0:0.05:10.0)
startup_thetas = sol(times; idxs=sys.θ).u
startup_omegas = sol(times; idxs=sys.ω).u
startup_x = sin.(startup_thetas)
startup_y = -1.0 .* cos.(startup_thetas)

# == Helper functions ==
function resolve(sys::ODESystem, prob::ODEProblem, theta_init::Float64, omega_init::Float64, g::Float64, L::Float64, times::Vector{Float64} = collect(0.0:0.05:10.0))
    p = remake(prob, u0=[sys.θ => theta_init, sys.ω => omega_init], p=[sys.g => g, sys.L => L])
    sol = solve(p)
    thetas = sol(times; idxs=sys.θ).u
    omegas = sol(times; idxs=sys.ω).u
    x = L .* sin.(thetas)
    y = -1.0 .* L .* cos.(thetas)
    return thetas, omegas, x, y
end

thetas, omegas, x, y = resolve(sys, prob, 2.5, 0.0, 1.62, 1.0)

end # module PendulumDemo
