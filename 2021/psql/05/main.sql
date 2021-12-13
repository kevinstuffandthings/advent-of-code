/*
--- Day 5: Hydrothermal Venture ---

You come across a field of hydrothermal vents on the ocean floor! These vents constantly produce large, opaque clouds, so it would be best to avoid them if possible.

They tend to form in lines; the submarine helpfully produces a list of nearby lines of vents (your puzzle input) for you to review. For example:

0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2
Each line of vents is given as a line segment in the format x1,y1 -> x2,y2 where x1,y1 are the coordinates of one end the line segment and x2,y2 are the coordinates of the other end. These line segments include the points at both ends. In other words:

An entry like 1,1 -> 1,3 covers points 1,1, 1,2, and 1,3.
An entry like 9,7 -> 7,7 covers points 9,7, 8,7, and 7,7.
For now, only consider horizontal and vertical lines: lines where either x1 = x2 or y1 = y2.

So, the horizontal and vertical lines from the above list would produce the following diagram:

.......1..
..1....1..
..1....1..
.......1..
.112111211
..........
..........
..........
..........
222111....
In this diagram, the top left corner is 0,0 and the bottom right corner is 9,9. Each position is shown as the number of lines which cover that point or . if no line covers that point. The top-left pair of 1s, for example, comes from 2,2 -> 2,1; the very bottom row is formed by the overlapping lines 0,9 -> 5,9 and 0,9 -> 2,9.

To avoid the most dangerous areas, you need to determine the number of points where at least two lines overlap. In the above example, this is anywhere in the diagram with a 2 or larger - a total of 5 points.

Consider only horizontal and vertical lines. At how many points do at least two lines overlap?
*/

-- first, let's load our segment data into a temp table
CREATE TEMPORARY TABLE segment_data (value text NOT NULL);
\COPY segment_data(value) FROM 'input.txt';

-- since all the data in there is raw (0,9 -> 5,9), let's make a view on top of the table to parse it into sensible fields
CREATE TEMPORARY VIEW segments
AS
SELECT value[1]::int AS x1, value[2]::int AS y1, value[3]::int AS x2, value[4]::int AS y2 -- postgres arrays are indexed from 1, not 0!!!!
FROM (
  SELECT REGEXP_SPLIT_TO_ARRAY(value, E'\\D*') AS value -- this splits the data into an array of values based on non-numeric consecutive chars
  FROM segment_data
) x;

-- we're gonna want to use this a few times, so we make a "CTE" (common table expression).
-- we could have made another view, but what fun would that be?
WITH axial_segments
AS (
  SELECT *
  FROM segments
  WHERE x1=x2 OR y1=y2 -- the problem tells us only to consider horizontal or vertical
)
SELECT COUNT(*)
FROM (
  SELECT x, y
  FROM (
    -- GENERATE_SERIES is super convenient, but it wants ascending numbers.
    -- we could provide a -1 as a 3rd argument to specify the "increment" value, but
    -- since we don't care about direction, we can just use LEAST and GREATEST to end
    -- up with increasing series, no matter what. it saves us a conditional!
    SELECT GENERATE_SERIES(LEAST(x1, x2), GREATEST(x1, x2)) AS x, y1 AS y
    FROM axial_segments
    WHERE x1!=x2
    UNION ALL
    SELECT x1 AS x, GENERATE_SERIES(LEAST(y1, y2), GREATEST(y1, y2)) AS y
    FROM axial_segments
    WHERE y1!=y2
  ) s
  GROUP BY x, y
  HAVING COUNT(*)>1 -- the HAVING clause is like a WHERE, but for the aggregate metrics calculated during a GROUP BY
) s;
