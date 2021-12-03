[Day 1](https://adventofcode.com/2021/day/1)

```
$ bash main.sh report.txt
ENTRY: 199; PREV:
ENTRY: 200; PREV: 199; INCREASE!
ENTRY: 208; PREV: 200; INCREASE!
ENTRY: 210; PREV: 208; INCREASE!
ENTRY: 200; PREV: 210
ENTRY: 207; PREV: 200; INCREASE!
ENTRY: 240; PREV: 207; INCREASE!
ENTRY: 269; PREV: 240; INCREASE!
ENTRY: 260; PREV: 269
ENTRY: 263; PREV: 260; INCREASE!
7
```

without debugging info:
```
$ bash main.sh report.txt 2>/dev/null
7
```
