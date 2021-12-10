/*
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
*/

-- instead of temp tables, let's make a new schema where we can store the stuff we need to make all this happen
DROP SCHEMA IF EXISTS aoc03 CASCADE;
CREATE SCHEMA aoc03;

-- we create a table full of the diagnostic inputs
CREATE TABLE aoc03.diagnostics (
  value text NOT NULL
);

COPY aoc03.diagnostics (value) FROM stdin;
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
\.

-- and let's try a view to be able to see each input as its constituent bits
CREATE VIEW aoc03.diagnostic_bits
AS
SELECT
  SUBSTR(value, 1, 1) AS b1,
  SUBSTR(value, 2, 1) AS b2,
  SUBSTR(value, 3, 1) AS b3,
  SUBSTR(value, 4, 1) AS b4,
  SUBSTR(value, 5, 1) AS b5
FROM aoc03.diagnostics;

-- we know we'll need to flip the gamma bits to get the epsilon bits, so let's write a function to do it.
-- this probably isn't what we'd do in real life, but we probably wouldn't analyze binary data with postgres, either.
CREATE FUNCTION aoc03.flip(p_bit char) RETURNS char
AS $$
  SELECT CASE WHEN p_bit='0' THEN '1' ELSE '0' END;
$$ LANGUAGE sql IMMUTABLE;

SELECT
  (gamma::bit(5))::int*(epsilon::bit(5))::int AS power_consumption -- we coerce each string to be a binary number, and then to an int
FROM (
  SELECT
    b1||b2||b3||b4||b5 AS gamma, -- concatenate the bits together to get our binary gamma value
    aoc03.flip(b1)||aoc03.flip(b2)||aoc03.flip(b3)||aoc03.flip(b4)||aoc03.flip(b5) AS epsilon -- and the epsilon is concatenated flipped bits
  FROM (
    SELECT -- this handy MODE function gives you the majority value of a column
      MODE() WITHIN GROUP (ORDER BY b1) AS b1,
      MODE() WITHIN GROUP (ORDER BY b2) AS b2,
      MODE() WITHIN GROUP (ORDER BY b3) AS b3,
      MODE() WITHIN GROUP (ORDER BY b4) AS b4,
      MODE() WITHIN GROUP (ORDER BY b5) AS b5
    FROM aoc03.diagnostic_bits
  ) x
) x;
