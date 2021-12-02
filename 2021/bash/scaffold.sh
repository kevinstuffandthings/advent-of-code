#!/bin/bash

# we have 25 days. we'll use an expansion to loop through each
for i in {1..25}
do
  dir=$(printf "%02d" $i) # so they sort nicely, we'll make sure each is 2 digits

  # if the directory doesn't exist, scaffold it out!
  if [ ! -d $dir ]
  then
    echo "Scaffolding day $i..."
    mkdir $dir

    # we'll add a simple readme to each day with a link to the exercise.
    # hopefully they don't change how they do it!
    # oh, this is a "heredoc". we'll talk about those later...
    cat <<_EOF_ > $dir/README.md
[Day $i](https://adventofcode.com/2021/day/$i)

\`\`\`
$ bash main.sh
\`\`\`
_EOF_
  fi
done
