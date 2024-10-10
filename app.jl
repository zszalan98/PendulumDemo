module App
# == Packages ==
# set up Genie development environment. Use the Package Manager to install new packages
using GenieFramework
@genietools

# == Code import ==
using PendulumDemo
# Testing the resolve function
@elapsed resolve(sys, prob, 2.5, 0.0, 1.62, 1.0)

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
        thetas, omegas, x, y = resolve(sys, prob, theta_init, omega_init, g, L)
    end

    @onchange L begin
        # Resolve the ODE and update the results
        thetas, omegas, x, y = resolve(sys, prob, theta_init, omega_init, g, L)
    end

    @onchange theta_init begin
        # Resolve the ODE and update the results
        thetas, omegas, x, y = resolve(sys, prob, theta_init, omega_init, g, L)
    end

    @onchange omega_init begin
        # Resolve the ODE and update the results
        thetas, omegas, x, y = resolve(sys, prob, theta_init, omega_init, g, L)
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
