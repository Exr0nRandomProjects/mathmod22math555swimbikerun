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
kv_namedtuple(ks, vs) = (; zip(Symbol.(ks), vs)... )

# nt_histogram(nt, args...; kwargs...) = histogram(nt|>values, labels=nt|>keys|>collect.|>string|>permutedims, args...; kwargs...)

function nt_histogram(nt, args...; kwargs...) 
    histogram(nt|>values|>collect, labels=nt|>keys|>collect.|>string|>permutedims, linewidth=0, alpha=0.8, args...; kwargs...)
end

df = @chain df begin
    dropmissing
    transform(TIME_COMPONENTS .=> ByRow(x -> Dates.value(x)/1e9), renamecols=false)
    select(cat(TIME_COMPONENTS, ["CATEGORY", "GENDER"]; dims=1))
end

# # function compare_gender_forall_sports()
# # plot each sport seprately, overlay by gender
# gd = @chain df groupby(:GENDER)
# println(first(gd))
# data_by_gender_by_sport = Dict(
#     key => Dict(
#         group[1, :GENDER] => group[!, key] |> collect
#         for group in gd
#     ) for key in TIME_COMPONENTS
# )   # cringe because "broadcasting over GroupedDataFrames is reserved"
# charts = [
#     histogram(d_by_g|>values|>collect, label=d_by_g|>keys|>collect|>permutedims,
#               opacity=0.7, title=sport, xrotation=45)
#     for (sport, d_by_g) in data_by_gender_by_sport ]
# plot(charts...)
# # end

# function compare_sports()
# d_by_s = Dict( k => df[!, k] for k in TIME_COMPONENTS )
# histogram(d_by_s|>values|>collect, labels=(@chain d_by_s keys collect permutedims),
#           linewidth=0, xlabel="time (s)", ylabel="# contestants", opacity=0.8)
# end


cum_df = @chain df begin
    transform(_, TIME_COMPONENTS => ByRow(
        (r...) -> kv_namedtuple(  (@chain TIME_COMPONENTS string.("cum_", _)), r |> cumsum  )
    ) => AsTable)
end

gd = @chain cum_df groupby(:CATEGORY)
# show events forall category
data(category) = kv_namedtuple( names(cum_df, r"cum_"), names(cum_df, r"cum_") .|> (checkpoint -> category[!, checkpoint]) )

hists = [nt_histogram(data(category), title=category[1, :CATEGORY]) for category in gd]

# show/compare category forall event
gd = @chain cum_df groupby(:CATEGORY)
category_names = cum_df[!, :CATEGORY] |> unique
# @show data(event) = kv_namedtuple( category_names, category_names .|> (cn -> cum_df[cum_df[!, :CATEGORY] == cn, event]) )
data(event) = kv_namedtuple( category_names, category_names .|> (cn -> gd[(cn,)][!, event]) )
hists = [ nt_histogram(data(event), title=event) for event in names(cum_df, r"cum_") ]
# plot(hists...)

