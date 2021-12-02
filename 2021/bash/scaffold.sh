#!/bin/bash

for i in {1..25}
do
  if [ ! -d $i ]
  then
    echo "Scaffolding day $i..."
    mkdir $i
    cat <<_EOF_ > $i/README.md
[Day $i] (https://adventofcode.com/2021/day/$i)

\`\`\`
$ bash main.sh
\`\`\`
_EOF_
  fi
done
