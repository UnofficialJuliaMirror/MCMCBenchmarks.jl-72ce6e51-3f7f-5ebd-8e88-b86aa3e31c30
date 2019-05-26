using Base.Sys
"""
Convert DynamcHMC samples to a chain
* `posterior`: an array of NamedTuple consisting of mcmcm samples
"""
function nptochain(posterior,tune)
    Np = length(vcat(posterior[1]...))+1 #include lf_eps
    Ns = length(posterior)
    a3d = Array{Float64,3}(undef,Ns,Np,1)
    ϵ=tune.ϵ
    for (i,post) in enumerate(posterior)
        temp = Float64[]
        for p in post
            push!(temp,values(p)...)
        end
        push!(temp,ϵ)
        a3d[i,:,1] = temp'
    end
    parameter_names = getnames(posterior)
    push!(parameter_names,"lf_eps")
    chns = MCMCChains.Chains(a3d,parameter_names,
        Dict(:internals => ["lf_eps"]))
    return chns
end

function getnames(post)
    nt = post[1]
    Np =length(vcat(nt...))
    parm_names = fill("",Np)
    cnt = 0
    for (k,v) in pairs(nt)
        N = length(v)
        if N > 1
            for i in 1:N
                cnt += 1
                parm_names[cnt] = string(k,"[",i,"]")
            end
        else
            cnt+=1
            parm_names[cnt] = string(k)
        end
    end
    return parm_names
end

function setprocs(n)
    np = nprocs()-1
    m = max(n-np,0)
    addprocs(m)
end

function save(results,ProjDir)
    str = string(round(now(),Dates.Minute))
    str = replace(str,"-"=>"_")
    str = replace(str,":"=>"_")
    dir = string(ProjDir,"/results")
    !isdir(dir) ? mkdir(dir) : nothing
    newdir = dir*"/"*str
    mkdir(newdir)
    CSV.write(newdir*"/results.csv",results)
    metadata = getMetadata()
    CSV.write(newdir*"/metadata.csv",metadata)
end

function getMetadata()
    dict = Pkg.installed()
    df = DataFrame()
    pkgs = [:CmdStan,:DynamicHMC,
        :Turing,:AdvancedHMC]
    map(x->df[x]=dict[string(x)],pkgs)
    df[:julia] = VERSION
    df[:os] = MACHINE
    cpu = cpu_info()
    df[:cpu] = cpu[1].model
    return df
end