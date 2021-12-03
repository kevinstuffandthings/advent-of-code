#!/bin/bash

<<_EOF_
--- Day 3: Binary Diagnostic ---

The submarine has been making some odd creaking noises, so you ask it to produce a diagnostic report just in case.

The diagnostic report (your puzzle input) consists of a list of binary numbers which, when decoded properly, can tell you many useful things about the conditions of the submarine. The first parameter to check is the power consumption.

You need to use the binary numbers in the diagnostic report to generate two new binary numbers (called the gamma rate and the epsilon rate). The power consumption can then be found by multiplying the gamma rate by the epsilon rate.

Each bit in the gamma rate can be determined by finding the most common bit in the corresponding position of all numbers in the diagnostic report. For example, given the following diagnostic report:

00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010
Considering only the first bit of each number, there are five 0 bits and seven 1 bits. Since the most common bit is 1, the first bit of the gamma rate is 1.

The most common second bit of the numbers in the diagnostic report is 0, so the second bit of the gamma rate is 0.

The most common value of the third, fourth, and fifth bits are 1, 1, and 0, respectively, and so the final three bits of the gamma rate are 110.

So, the gamma rate is the binary number 10110, or 22 in decimal.

The epsilon rate is calculated in a similar way; rather than use the most common bit, the least common bit from each position is used. So, the epsilon rate is 01001, or 9 in decimal. Multiplying the gamma rate (22) by the epsilon rate (9) produces the power consumption, 198.

Use the binary numbers in your diagnostic report to calculate the gamma rate and epsilon rate, then multiply them together. What is the power consumption of the submarine? (Be sure to represent your answer in decimal, not binary.)
_EOF_

# the parens are used for array notation. we'll set up our problem inputs as an array
entries=(00100 11110 10110 10111 10101 01111 00111 11100 10000 11001 00010 01010)
on=(0 0 0 0 0)

# to reference all the elements in the array, we use the brackets with a *
for num in ${entries[*]}
do
  for i in {0..4}
  do
    bit=${num:$i:1} # here we get a single character at index $i from the current $num
    on[$i]=$((${on[$i]} + $bit)) # and we're updating our array of "on" bits doing some math
  done
done

echo "bit tallies: ${on[*]}" >&2

gamma=()
epsilon=()
inflect=$((${#entries[*]} / 2))

for i in {0..4}
do
  bit=$((${on[$i]}<$inflect ? 0 : 1)) # for each bit, if we've found more of them than the "inflection point", we use it as majority
  gamma[$i]=$bit
  epsilon[$i]=$(($bit==1 ? 0 : 1))
done

echo "gamma bits: ${gamma[*]}" >&2
echo "epsilon bits: ${epsilon[*]}" >&2

# we have an array of bits, and we want to turn it into an integer.
# so first, we have to turn the array (1 0 1 1 0) into "10110"
# and then use bash math to convert that binary string representation into decimal
function bin_to_int
{
  local bin=$(echo $* |tr -d ' ')
  echo $((2#$bin))
}

# we'll use our function to convert each of the gamma and epsilon bit arrays to integers...
gi=$(bin_to_int ${gamma[*]})
ei=$(bin_to_int ${epsilon[*]})

echo "gamma=$gi, epsilon=$ei" >&2

# ... and finally, multiply them together
echo $((gi * ei))
