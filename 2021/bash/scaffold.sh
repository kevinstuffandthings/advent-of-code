#!/bin/bash

for i in {1..25}
do
  dir=$(printf "%02d" $i)
  if [ ! -d $dir ]
  then
    echo "Scaffolding day $i..."
    mkdir $dir
    cat <<_EOF_ > $dir/README.md
[Day $i] (https://adventofcode.com/2021/day/$i)

\`\`\`
$ bash main.sh
\`\`\`
_EOF_
  fi
done
