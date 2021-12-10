/*
--- Day 2: Dive! ---

Now, you need to figure out how to pilot this thing.

It seems like the submarine can take a series of commands like forward 1, down 2, or up 3:

forward X increases the horizontal position by X units.
down X increases the depth by X units.
up X decreases the depth by X units.
Note that since you're on a submarine, down and up affect your depth, and so they have the opposite result of what you might expect.

The submarine seems to already have a planned course (your puzzle input). You should probably figure out where it's going. For example:

forward 5
down 5
forward 8
up 3
down 8
forward 2
Your horizontal position and depth both start at 0. The steps above would then modify them as follows:

forward 5 adds 5 to your horizontal position, a total of 5.
down 5 adds 5 to your depth, resulting in a value of 5.
forward 8 adds 8 to your horizontal position, a total of 13.
up 3 decreases your depth by 3, resulting in a value of 2.
down 8 adds 8 to your depth, resulting in a value of 10.
forward 2 adds 2 to your horizontal position, a total of 15.
After following these instructions, you would have a horizontal position of 15 and a depth of 10. (Multiplying these together produces 150.)

Calculate the horizontal position and depth you would have after following the planned course. What do you get if you multiply your final horizontal position by your final depth?
*/

-- we'll set up a temp table to hold our instructions, and then insert the individual records into it
CREATE TEMPORARY TABLE tt_instructions (
  id SERIAL,
  direction text NOT NULL,
  distance int NOT NULL
);
INSERT INTO tt_instructions (direction, distance)
VALUES
  ('forward', 5),
  ('down', 5),
  ('forward', 8),
  ('up', 3),
  ('down', 8),
  ('forward', 2);

-- we have our list of instructions, and want to consider 2 general axes
-- to do this, we'll use our instruction list twice
SELECT hpos*depth AS result
FROM (
  -- we did what might be called a "natural join" here. it essentially "explodes" the combo of rows, joining each to each.
  -- since our 2 subqueries only yield one row each, we end up with one row
  SELECT h.distance AS hpos, d.distance AS depth
  FROM (
    -- this subquery handles the horizontal axis. since there's no backwards, we can just handle forward, and sum up
    SELECT SUM(distance) AS distance
    FROM tt_instructions
    WHERE direction IN ('forward')
  ) h, (
    -- this subquery handles the vertical axis. here, we need to do different things based on up v down
    SELECT SUM((CASE WHEN direction='up' THEN -1 ELSE 1 END)*distance) AS distance
    FROM tt_instructions
    WHERE direction IN ('up', 'down')
  ) d
) x;
