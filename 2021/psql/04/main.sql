/*
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
*/

-- the schema approach is nice, let's use it again!
DROP SCHEMA IF EXISTS aoc04 CASCADE;
CREATE SCHEMA aoc04;

-- this is not a particularly interesting table, but imagine if we wanted to assign a player
-- name to a board. this could be a nice place to do it.
CREATE TABLE aoc04.boards (
  id int NOT NULL PRIMARY KEY
);

-- we'll store the different cells in a related table
CREATE TABLE aoc04.board_cells (
  board_id int NOT NULL REFERENCES aoc04.boards(id) ON DELETE CASCADE, -- if we delete a board, all the cell records go along with it, automatically
  row_ord int NOT NULL, -- think our y coordinate
  col_ord int NOT NULL, -- and our x coordinate
  value int NOT NULL,
  selected boolean NOT NULL default false,
  UNIQUE (board_id, row_ord, col_ord) -- for each board, we better not have multiple rows for a single xy coordinate
);

-- reading from flat files and such isn't necessarily postgres' strength. but we can do it,
-- thanks to the power of a plpgsql anonymous code block!
DO $$
  DECLARE
    v_num_boards int := 3;
    v_board_id int;
    v_file text;
  BEGIN
    FOR v_board_id IN 1..v_num_boards
    LOOP
      v_file := '/Users/kevin/Development/advent-of-code/2021/psql/04/boards/0'||v_board_id||'.txt';

      -- for each board, we'll create a temporary table to read in the raw data...
      CREATE TEMP TABLE tt_board (row_ord SERIAL, data text);
      -- ... and then we'll use "dynamic sql" to load in the board contents
      EXECUTE FORMAT ('COPY tt_board(data) FROM %L', v_file);

      DECLARE
        v_board_row record;
      BEGIN
        -- first, we create our board record that we'll relate its cells to
        INSERT INTO aoc04.boards (id) VALUES (v_board_id);

        -- we'll then loop over each raw row we read in from the files
        FOR v_board_row IN SELECT * FROM tt_board
        LOOP
          -- we can split the raw row data (which will be 5 numbers) into an array,
          -- and then UNNEST the array which turns it into individual rows in our subquery.
          -- this then allows us to use the row_ord value and an ROW_NUMBER window function to get
          -- our x, our y, and our value
          INSERT INTO aoc04.board_cells (board_id, row_ord, col_ord, value)
          SELECT v_board_id, v_board_row.row_ord, ROW_NUMBER() OVER (), value::int
          FROM (
            SELECT UNNEST(REGEXP_SPLIT_TO_ARRAY(TRIM(v_board_row.data), E'\\s+')) AS value
          ) x;
        END LOOP;
      END;

      DROP TABLE tt_board;
    END LOOP;
  END;
$$;

-- at this point, we have all our boards populated into the db. let's use another anonymous block of code
-- to execute the actual drawing!
DO $$
  DECLARE
    v_drawings text[] := STRING_TO_ARRAY('7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1', ',');
    v_drawing text;
    v_board_id int;
    v_matched boolean;
    v_result int;
  BEGIN
    -- we'll go through the values one at a time, and...
    FOREACH v_drawing IN ARRAY v_drawings
    LOOP
      -- ... update each cell as "selected" if its number were called
      UPDATE aoc04.board_cells SET selected=true WHERE value=v_drawing::int;

      -- then, we want to see if we have any boards that won, meaning...
      SELECT board_id INTO v_board_id
      FROM (
        -- within a single column, 5 cells are selected
        SELECT board_id, col_ord AS ord, COUNT(*) AS num_selected
        FROM aoc04.board_cells
        WHERE selected
        GROUP BY board_id, col_ord
        UNION ALL
        -- or within a single row, 5 cells are selected
        SELECT board_id, row_ord AS ord, COUNT(*) AS num_selected
        FROM aoc04.board_cells
        WHERE selected
        GROUP BY board_id, row_ord
      ) x
      WHERE num_selected=5;

      -- if we found a board like this, let's do all the math the problem wants us to do, and end the game
      IF v_board_id IS NOT NULL
      THEN
        RAISE INFO 'board % wins with %!', v_board_id, v_drawing;
        SELECT SUM(value)*v_drawing::int INTO v_result FROM aoc04.board_cells WHERE board_id=v_board_id AND NOT selected;
        RAISE INFO 'result=%', v_result;
        EXIT;
      END IF;
    END LOOP;
  END;
$$;
