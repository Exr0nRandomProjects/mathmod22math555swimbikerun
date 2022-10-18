using Chain

using DataFrames, CSV
using Plots
using Dates
using Statistics

df = CSV.File("cleaned_dataset.csv") |> DataFrame;

# print(data)

# data, keys = keys .|> (k -> [df[!, k] .|> Dates.value .|> (x -> x/1e9), lowercase(k)]) |> (x -> zip(x...)) |> collect
# histogram([data...], xlabel="time", ylabel="number of contestants", label=permutedims(collect(keys)))   # have to do this cursed permutedims thing because plots.jl treats first dim as things to cycle thru in the current series, and second dim as a diff series. 

# const TIME_COMPONENTS = [:SWIM, :T1, :BIKE, :T2, :RUN]
const TIME_COMPONENTS = ["SWIM", "T1", "BIKE", "T2", "RUN"]

grouped_to_2d(gd) = @chain gd select(TIME_COMPONENTS)

df = @chain df begin
    dropmissing
    transform(_, TIME_COMPONENTS .=> ByRow(x -> Dates.value(x)/1e9), renamecols=false)
    select(cat(TIME_COMPONENTS, ["CATEGORY", "GENDER"]; dims=1))
end

# plot each sport seprately, overlay by gender
# println(typeof(df))
# plot(histogram(group[:T]))
gd = @chain df groupby(:GENDER)
println(first(gd))
data_by_gender_by_sport = Dict(
    key => Dict(
        group[1, :GENDER] => group[!, key] |> collect
        for group in gd
    ) for key in TIME_COMPONENTS
)   # cringe because "broadcasting over GroupedDataFrames is reserved"
compare_gender_forall_sports = [
    histogram(d_by_g|>values|>collect, label=d_by_g|>keys|>collect|>permutedims,
              opacity=0.7, title=sport, xrotation=45)
    for (sport, d_by_g) in data_by_gender_by_sport ]
plot(compare_gender_forall_sports...)

