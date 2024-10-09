module App
# == Packages ==
# set up Genie development environment. Use the Package Manager to install new packages
using GenieFramework
@genietools

# == Code import ==
using ModelingToolkit
using OrdinaryDiffEq

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

@mtkbuild sys = Pendulum(g=9.81, L=1.0)
u0 = [sys.θ => 2.5, sys.ω => 0.0]
tspan = (0.0, 10.0)
prob = ODEProblem(sys, u0, tspan)
sol = solve(prob)

times = collect(0.0:0.05:10.0)
startup_thetas = sol(times; idxs=sys.θ).u
startup_omegas = sol(times; idxs=sys.ω).u
startup_x = sol(times; idxs=sys.x).u
startup_y = sol(times; idxs=sys.y).u

# == Helper functions ==
function resolve(sys::ODESystem, theta_init::Float64, omega_init::Float64, g::Float64, L::Float64, times::Vector{Float64} = collect(0.0:0.05:10.0))
    p = remake(prob, u0=[sys.θ => theta_init, sys.ω => omega_init], p=[sys.g => g, sys.L => L])
    sol = solve(p)
    thetas = sol(times; idxs=sys.θ).u
    omegas = sol(times; idxs=sys.ω).u
    x = sol(times; idxs=sys.x).u
    y = sol(times; idxs=sys.y).u
    return thetas, omegas, x, y
end


# == Reactive code ==
@app begin
    # == Reactive variables ==
    # reactive variables exist in both the Julia backend and the browser with two-way synchronization
    # @out variables can only be modified by the backend
    # @in variables can be modified by both the backend and the browser
    # variables must be initialized with constant values, or variables defined outside of the @app block
    # Parameters
    @in g = 9.81
    @in L = 1.0
    # Initial conditions
    @in theta_init = 2.5
    @in omega_init = 0.0
    # Simulation time
    # @in tend = 10.0

    # Results
    @out times = collect(0.0:0.05:10.0)
    @out thetas = startup_thetas
    @out omegas = startup_omegas
    @out x = startup_x
    @out y = startup_y

    # == Reactive handlers ==
    # reactive handlers watch a variable and execute a block of code when its value changes
    @onchange g begin
        # Resolve the ODE and update the results
        thetas, omegas, x, y = resolve(sys, theta_init, omega_init, g, L)
    end

    @onchange L begin
        # Resolve the ODE and update the results
        thetas, omegas, x, y = resolve(sys, theta_init, omega_init, g, L)
    end

    @onchange theta_init begin
        # Resolve the ODE and update the results
        thetas, omegas, x, y = resolve(sys, theta_init, omega_init, g, L)
    end

    @onchange omega_init begin
        # Resolve the ODE and update the results
        thetas, omegas, x, y = resolve(sys, theta_init, omega_init, g, L)
    end

end

# == Pages ==
# register a new route and the page that will be loaded on access
@page("/", "app.jl.html")
end

# == Advanced features ==
#=
- The @private macro defines a reactive variable that is not sent to the browser. 
This is useful for storing data that is unique to each user session but is not needed
in the UI.
    @private table = DataFrame(a = 1:10, b = 10:19, c = 20:29)

=#
