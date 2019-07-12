using MCMCBenchmarks,Test

@testset "Regression Tests " begin
    path = pathof(MCMCBenchmarks)
    include(joinpath(path,
      "../../Models/Linear_Regression/Linear_Regression_Models.jl"))
    Nd=1000
    β0=1
    β=fill(.5,1)
    σ=1
    Nreps = 1
    ProjDir = @__DIR__
    cd(ProjDir)
    samplers=(
      CmdStanNUTS(CmdStanConfig,ProjDir),
      AHMCNUTS(AHMCregression,AHMCconfig),
      DHMCNUTS(sampleDHMC,2000))
    options = (Nsamples=2000,Nadapt=1000,delta=.8,Nd=Nd)
    results = benchmark(samplers,simulateRegression,Nreps;options...)
    @test results[Symbol("B[1]_mean")][results[:sampler] .== :AHMCNUTS,:][1] ≈ β[1] atol = .05
    @test results[Symbol("B[1]_mean")][results[:sampler] .== :CmdStanNUTS,:][1] ≈ β[1] atol = .05
    @test results[Symbol("B[1]_mean")][results[:sampler] .== :DHMCNUTS,:][1] ≈ β[1] atol = .05
    @test results[:B0_mean][results[:sampler] .== :AHMCNUTS,:][1] ≈ β0[1] atol = .05
    @test results[:B0_mean][results[:sampler] .== :CmdStanNUTS,:][1] ≈ β0[1] atol = .05
    @test results[:B0_mean][results[:sampler] .== :DHMCNUTS,:][1] ≈ β0[1] atol = .05
    @test results[:sigma_mean][results[:sampler] .== :AHMCNUTS,:][1] ≈ σ atol = .05
    @test results[:sigma_mean][results[:sampler] .== :CmdStanNUTS,:][1] ≈ σ atol = .05
    @test results[:sigma_mean][results[:sampler] .== :DHMCNUTS,:][1] ≈ σ atol = .05

    @test results[Symbol("B[1]_r_hat")][results[:sampler] .== :AHMCNUTS,:][1] ≈ 1 atol = .03
    @test results[Symbol("B[1]_r_hat")][results[:sampler] .== :CmdStanNUTS,:][1] ≈ 1 atol = .03
    @test results[Symbol("B[1]_r_hat")][results[:sampler] .== :DHMCNUTS,:][1] ≈ 1 atol = .03
    @test results[:B0_r_hat][results[:sampler] .== :AHMCNUTS,:][1] ≈ 1 atol = .03
    @test results[:B0_r_hat][results[:sampler] .== :CmdStanNUTS,:][1] ≈ 1 atol = .03
    @test results[:B0_r_hat][results[:sampler] .== :DHMCNUTS,:][1] ≈ 1 atol = .03
    @test results[:sigma_r_hat][results[:sampler] .== :AHMCNUTS,:][1] ≈ 1 atol = .03
    @test results[:sigma_r_hat][results[:sampler] .== :CmdStanNUTS,:][1] ≈ 1 atol = .03
    @test results[:sigma_r_hat][results[:sampler] .== :DHMCNUTS,:][1] ≈ 1 atol = .03
    isdir("tmp") && rm("tmp", recursive=true)
end
