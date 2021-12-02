#!/bin/bash

# this <<_EOF_ notiation is called a "heredoc".
# in this case, i'm using it just to have one big comment. we're not sending the doc anywhere,
# so it's useful for a comment block.
<<_EOF_
--- Day 1: Sonar Sweep ---

You're minding your own business on a ship at sea when the overboard alarm goes off! You rush to see if you can help. Apparently, one of the Elves tripped and accidentally sent the sleigh keys flying into the ocean!

Before you know it, you're inside a submarine the Elves keep ready for situations like this. It's covered in Christmas lights (because of course it is), and it even has an experimental antenna that should be able to track the keys if you can boost its signal strength high enough; there's a little meter that indicates the antenna's signal strength by displaying 0-50 stars.

Your instincts tell you that in order to save Christmas, you'll need to get all fifty stars by December 25th.

Collect stars by solving puzzles. Two puzzles will be made available on each day in the Advent calendar; the second puzzle is unlocked when you complete the first. Each puzzle grants one star. Good luck!

As the submarine drops below the surface of the ocean, it automatically performs a sonar sweep of the nearby sea floor. On a small screen, the sonar sweep report (your puzzle input) appears: each line is a measurement of the sea floor depth as the sweep looks further and further away from the submarine.

For example, suppose you had the following report:

199
200
208
210
200
207
240
269
260
263
This report indicates that, scanning outward from the submarine, the sonar sweep found depths of 199, 200, 208, 210, and so on.

The first order of business is to figure out how quickly the depth increases, just so you know what you're dealing with - you never know if the keys will get carried into deeper water by an ocean current or a fish or something.

To do this, count the number of times a depth measurement increases from the previous measurement. (There is no measurement before the first measurement.) In the example above, the changes are as follows:

199 (N/A - no previous measurement)
200 (increased)
208 (increased)
210 (increased)
200 (decreased)
207 (increased)
240 (increased)
269 (increased)
260 (decreased)
263 (increased)
In this example, there are 7 measurements that are larger than the previous measurement.

How many measurements are larger than the previous measurement?
_EOF_

# first, we want to see how many arguments have been passed to this command.
# we want exactly one argument -- the name of the file containing our input data.
if [ $# != 1 ]
then
  # if we didn't get exactly one argument, we'll send an error message to STDERR, and we'll
  # exit with a non-zero return code (which tells the caller that things didn't go well).
  echo "Usage: ${0##*/} REPORT" >&2
  exit 1
fi

# if we're here, we got exactly one command, so we assume it's our report input file.
# if we cannot find that file, we'll do more error stuff.
report=$1
if [ ! -f $report ]
then
  echo "Unable to locate report $report" >&2
  exit 1 # we could theoretically use a different return code here, but meh...
fi

# let's initialize some variables here...
increases=0
prev=

# we'll read each line into an entry variable, until we run out.
# it's the inward redirection at the end of the loop block that gives us our entries.
while read entry
do
  echo -n "ENTRY: $entry; PREV: $prev" # -n keeps us from adding a newline!

  # double brackets for multiple conditions
  if [[ -n "$prev" && $prev < $entry ]]
  then
    echo "; INCREASE!"
    increases=$(($increases + 1)) # double parens allows for math. complete different than singles
  else
    echo
  fi
  prev=$entry
done < $report

echo "WE HAVE $increases INCREASES"
