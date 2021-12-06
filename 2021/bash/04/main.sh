#!/bin/bash

<<_EOF_
--- Day 4: Giant Squid ---

You're already almost 1.5km (almost a mile) below the surface of the ocean, already so deep that you can't see any sunlight. What you can see, however, is a giant squid that has attached itself to the outside of your submarine.

Maybe it wants to play bingo?

Bingo is played on a set of boards each consisting of a 5x5 grid of numbers. Numbers are chosen at random, and the chosen number is marked on all boards on which it appears. (Numbers may not appear on all boards.) If all numbers in any row or any column of a board are marked, that board wins. (Diagonals don't count.)

The submarine has a bingo subsystem to help passengers (currently, you and the giant squid) pass the time. It automatically generates a random order in which to draw numbers and a random set of boards (your puzzle input). For example:

7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7

After the first five numbers are drawn (7, 4, 9, 5, and 11), there are no winners, but the boards are marked as follows (shown here adjacent to each other to save space):

22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
 8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
 6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
 1 12 20 15 19        14 21 16 12  6         2  0 12  3  7
After the next six numbers are drawn (17, 23, 2, 0, 14, and 21), there are still no winners:

22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
 8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
 6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
 1 12 20 15 19        14 21 16 12  6         2  0 12  3  7
Finally, 24 is drawn:

22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
 8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
 6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
 1 12 20 15 19        14 21 16 12  6         2  0 12  3  7

At this point, the third board wins because it has at least one complete row or column of marked numbers (in this case, the entire top row is marked: 14 21 17 24 4).

The score of the winning board can now be calculated. Start by finding the sum of all unmarked numbers on that board; in this case, the sum is 188. Then, multiply that sum by the number that was just called when the board won, 24, to get the final score, 188 * 24 = 4512.

To guarantee victory against the giant squid, figure out which board will win first. What will your final score be if you choose that board?
_EOF_

# bash doesn't have objects. and it can be hard to track state in its variables.
# but it has a filesystem! let's leverage that for our state tracking

# we'll make a temporary work area that we can write stuff to
workarea=$(mktemp -d) # we'll make a temporary work area that we can write stuff to
function cleanup
{
  echo "cleaning up $workarea..." >&2
  rm -rf $workarea
} 

# when the program exits, we'll execute our cleanup routine
trap cleanup EXIT

# we have each of our board configurations in a file. we'll turn those files into
# a set of directories. each board will have its own directory in the workarea.
# essentially, a board will look like:
# $workarea/
#   01/         # our board id
#     1/        # directory for row 1
#       1/      # directory for row 1/column 1
#         n     # a file containing the actual value the board has at that cell
#         u     # an empty indicator file to represent an "unmarked" cell
#       2/
#         n
#         u
#       3/
#         n
#         u
#       4/
#         n
#         u
#       5/
#         n
#         u
function parseBoard
{
  local input=$1
  local output=$workarea/${input%.*}
  local row
  local y=1

  mkdir -p $output
  while read row
  do
    local x=1
    local c
    for c in $row
    do
      local cdir=$output/$y/$x
      mkdir -p $cdir
      echo $c > $cdir/n
      touch $cdir/u
      x=$((x+1))
    done
    y=$((y+1))
  done<$input

  echo $output
}

# when a number is called, we'll mark a board with that number, assuming the number is found
function markBoard
{
  local num=$1
  local board=$2
  local cell

  for cell in $(find $board -name n) # just showcasing how we can use "find" to locate all files called "n", at any depth
  do
    if [ $(cat $cell) == $num ] # if the contents of the found "n" file match the called number...
    then
      local cdir=${cell%/n}
      rm -f $cdir/u # we will remove the unmarked status
      touch $cdir/m # and we'll mark it!
    fi
  done
}

# we can determine a board is a winner if we find 5 marked cells for any single row or column
function isWinningBoard
{
  local board=$1
  local n
  for n in {1..5} # using this for both rows (y) and cols (x)
  do
    # leveraging wildcard expansion to turn that row (or column) into an array of the found "m" files
    local y=($board/$n/*/m)
    local x=($board/*/$n/m)
    if [[ ${#x[@]} == 5 || ${#y[@]} == 5 ]] # if our n yields a fully marked row or column...
    then
      # then we return 0, indicating great success!
      return 0
    fi
  done
  return 1 # otherwise, we were a bit less successful. next time... maybe...
}

# to count up all our unmarked cells, we'll look for all the ones with a "u" file
function countUnmarked
{
  local board=$1
  local total=0
  local cell
  for cell in $board/*/*/u
  do
    local val=$(cat ${cell%/u}/n) # we find the corresponding "n" file, and get its contents (which is the value it held)
    total=$(($total+$val))
  done
  echo $total # shell scripts really just want to return a success int. so when you want a value, gotta echo and capture it!
}

boards=()
for f in boards/*.txt
do
  echo "reading board $f" >&2
  boards+=($(parseBoard $f)) # we read each board file, parse it, and keep its resulting directory in an array of boards
done

IFS=, read -a drawing <<< "7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1"

# now for each "n" in our drawing, we...
for n in ${drawing[@]}
do
  # ...iterate through each board
  for board in ${boards[@]}
  do
    echo "- marking board ${board##*/} with $n" >&2
    markBoard $n $board
    if isWinningBoard $board
    then
      echo "board ${board##*/} has bingo!" >&2
      unmarked=$(countUnmarked $board)
      echo $(($n*$unmarked))
      exit
    fi
  done
done
