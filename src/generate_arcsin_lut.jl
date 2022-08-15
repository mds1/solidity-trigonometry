#!julia

using Printf

# set the number of places after the decimal to be 18
Base.show(io::IO, f::Float64) = @printf(io, "%1.18f", f)

LOOKUP_TABLE_SIZE = 2048
step = 1/LOOKUP_TABLE_SIZE
for table_entry in 0:LOOKUP_TABLE_SIZE-1
  x = table_entry*step
  y = asin(x)

  # the solidity line
  out = string("lookup_table[",table_entry,"] = ", y)

  # remove periods
  out = replace(out, r"\."=>"")

  # remove leading zeroes to prevent solc complaining about octal numbers
  out = replace(out, r"= 0+"=>"= ")

  # add semi colon for solidity
  out = string(out, ";")

  println(out)
end
