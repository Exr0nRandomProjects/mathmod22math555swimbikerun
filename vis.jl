using DataFrames, CSV
using Plots
using Dates

df = CSV.File("cleaned_dataset.csv") |> DataFrame;

# print(data)

keys = ["SWIM" "BIKE" "RUN"]

data, keys = keys .|> (k -> [df[!, k] .|> Dates.value .|> (x -> x/1e9), lowercase(k)]) |> (x -> zip(x...)) |> collect
# print(typeof(data), typeof(keys), typeof(collect(keys)), typeof([keys...]), typeof(reshape(collect(keys), :, 1)))
# print([permutedims(collect(keys))] .|> typeof)

histogram([data...], xlabel="time", ylabel="number of contestants", label=permutedims(collect(keys)))   # have to do this cursed permutedims thing because plots.jl treats first dim as things to cycle thru in the current series, and second dim as a diff series. 



# p = histogram()
# keys .|> (k -> histogram!(p, df[!, k], xlabel="time", ylabel="# contestants", label=k))
# p
# # print(length(data))
# 
