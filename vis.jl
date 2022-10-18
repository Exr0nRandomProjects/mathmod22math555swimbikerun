using Chain

using DataFrames, CSV
using Plots
using Dates
using Statistics

df = CSV.File("cleaned_dataset.csv") |> DataFrame;

# print(data)

keys = ["SWIM" "BIKE" "RUN"]

# data, keys = keys .|> (k -> [df[!, k] .|> Dates.value .|> (x -> x/1e9), lowercase(k)]) |> (x -> zip(x...)) |> collect
# histogram([data...], xlabel="time", ylabel="number of contestants", label=permutedims(collect(keys)))   # have to do this cursed permutedims thing because plots.jl treats first dim as things to cycle thru in the current series, and second dim as a diff series. 

using Chain

res = @chain df begin
    dropmissing
    # transform(_, :CATEGORY => ByRow(r -> (println(r); @chain r split (; gender=_[1], level=_[2]) )) => :EMACS)
    groupby(_, :CATEGORY)
    transform(_, [:SWIM, :T1, :BIKE, :T2, :RUN] .=> ByRow(x -> Dates.value(x)/1e9), renamecols=false)
end

# series, labels = 
# 
# gd = groupby(df, :CATEGORY)
# gd |> (gd -> combine(gd, :SWIM => mean))

# print(gd[1]["SWIM"])
# gd .|> println
# data, labels = gd .|> (g -> [g[!, "SWIM"], g[!, "CATEGORY"]]) |> (x -> zip(x...))
# histogram([gd...], xlabel="time", ylabel="# ppl", label=permutedims(collect(labels)))



