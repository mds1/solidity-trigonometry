#!julia
input = parse(Int64, ARGS[1])

fractional_part= mod(input, 1e18)
whole_part = input - fractional_part

fractional_part = fractional_part/1e18
whole_part = whole_part/1e18

x = whole_part + fractional_part

println(asin(x))
