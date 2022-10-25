using Chain, DataFrames, Statistics, Downloads, CSV, Dates

SHIFTED_START_TIMES = (; :M_PRO=>10.2, :F_PRO=>10.2, :M_PREMIER=>10.2, :F_PREMIER=>10.2, :M_OPEN=>10.2, :F_OPEN=>10.2, :ATH=>10.2, :CLY=>10.2)
TIME_COMPONENTS = ["START", "SWIM", "T1", "BIKE", "T2", "RUN"]
const CUM_TIME_COMPONENTS = ["cum_START", "cum_SWIM", "cum_T1", "cum_BIKE", "cum_T2", "cum_RUN"]


begin
    grouped_to_2d(gd) = @chain gd select(TIME_COMPONENTS)
    kv_namedtuple(ks, vs) = (; zip(Symbol.(ks), vs)... )
    function nt_histogram(nt, args...; kwargs...) 
        histogram(nt|>values|>collect,
                  labels=nt|>keys|>collect.|>string|>permutedims, linewidth=0, alpha=0.8, args...; 	kwargs...)
    end
end

df = @chain begin 	
    "https://raw.githubusercontent.com/Exr0nRandomProjects/mathmod22math555swimbikerun/main/cleaned_dataset.csv"
    Downloads.download
    CSV.File
    DataFrame
    dropmissing
    transform(:CATEGORY => ByRow(cat -> getindex(SHIFTED_START_TIMES, @chain cat replace(" "=>"_") Symbol)) => :START)
    transform(TIME_COMPONENTS .=> ByRow(x -> x isa Float64 ? x : Dates.value(x)/1e9), renamecols=false)
    select(cat(TIME_COMPONENTS, ["CATEGORY", "GENDER"]; dims=1))
    transform(TIME_COMPONENTS => ByRow((times...) -> sum(times)) => :TOTAL)
    transform(TIME_COMPONENTS => ByRow((times...) -> kv_namedtuple(CUM_TIME_COMPONENTS, cumsum(times |> collect), dims=1)) => AsTable)
end

