DROP VIEW IF EXISTS q0, q1i, q1ii, q1iii, q1iv, q2i, q2ii, q2iii, q3i, q3ii, q3iii, q4i, q4ii, q4iii, q4iv, q4v;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT
  namefirst, namelast, birthyear
  FROM people
  WHERE weight > 300;
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT
  namefirst, namelast, birthyear
  FROM people
  WHERE namefirst
  LIKE '% %';
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT
  birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear
  ORDER BY birthyear;
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT
  birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear
  HAVING AVG(height) > 70
  ORDER BY birthyear;
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT
  namefirst, namelast, people.playerid, yearid
  FROM people
  INNER JOIN halloffame
  ON people.playerid = halloffame.playerid
  WHERE inducted = 'Y'
  ORDER BY halloffame.yearid DESC;
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT
  namefirst, namelast, people.playerid, schools.schoolid, halloffame.yearid
  FROM people
  INNER JOIN halloffame
  ON people.playerid = halloffame.playerid
  INNER JOIN collegeplaying
  ON people.playerid = collegeplaying.playerid
  INNER JOIN schools
  ON collegeplaying.schoolid = schools.schoolid
  WHERE inducted = 'Y' and schoolstate = 'CA'
  ORDER BY halloffame.yearid DESC, collegeplaying.schoolid, collegeplaying.playerid;
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT
  people.playerid, namefirst, namelast, schools.schoolid
  FROM people
  INNER JOIN halloffame
  ON people.playerid = halloffame.playerid
  LEFT JOIN collegeplaying
  ON people.playerid = collegeplaying.playerid
  LEFT JOIN schools
  ON collegeplaying.schoolid = schools.schoolid
  WHERE inducted = 'Y'
  ORDER BY people.playerid DESC, collegeplaying.schoolid;
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT
  batting.playerid, namefirst, namelast, yearid, ((h - h2b - h3b - hr) + 2 * h2b + 3 * h3b + 4 * hr)/CAST(ab AS float) AS sg
  FROM batting
  INNER JOIN people
  ON batting.playerid = people.playerid
  WHERE ab > 50
  ORDER BY sg DESC
  LIMIT 10;
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT
  batting.playerid, namefirst, namelast, ((SUM(h) - SUM(h2b) - SUM(h3b) - SUM(hr)) + 2 * SUM(h2b) + 3 * SUM(h3b) + 4 * SUM(hr))/CAST(SUM(ab) AS float) as lslg
  FROM batting
  INNER JOIN people
  ON batting.playerid = people.playerid
  GROUP BY batting.playerid, namefirst, namelast
  HAVING SUM(ab) > 50
  ORDER BY lslg DESC
  LIMIT 10;
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT
  namefirst, namelast, ((SUM(h) - SUM(h2b) - SUM(h3b) - SUM(hr)) + 2 * SUM(h2b) + 3 * SUM(h3b) + 4 * SUM(hr))/CAST(SUM(ab) AS float) as lslg
  FROM batting
  INNER JOIN people
  ON batting.playerid = people.playerid
  GROUP BY batting.playerid, namefirst, namelast
  HAVING SUM(ab) > 50 AND ((SUM(h) - SUM(h2b) - SUM(h3b) - SUM(hr)) + 2 * SUM(h2b) + 3 * SUM(h3b) + 4 * SUM(hr))/CAST(SUM(ab) AS float) > (
    SELECT ((SUM(h) - SUM(h2b) - SUM(h3b) - SUM(hr)) + 2 * SUM(h2b) + 3 * SUM(h3b) + 4 * SUM(hr))/CAST(SUM(ab) AS float) as lslg
    FROM batting
    GROUP BY playerid
    HAVING playerid = 'mayswi01'
  )
  ORDER BY namefirst;
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg, stddev)
AS
  SELECT
  yearid, MIN(salary), MAX(salary), AVG(salary), STDDEV(salary)
  FROM salaries
  GROUP BY yearid
  ORDER BY yearid;
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  with SalaryMin AS (
    SELECT MIN(salary)
    FROM salaries
    WHERE yearid = 2016
  ), SalaryRange AS (
    SELECT
    (MAX(salary) - MIN(salary)) / 10 AS bucketsize
    FROM salaries
    WHERE yearid=2016
  ), SalaryBins AS (
    SELECT
    salary,
    LEAST(9, FLOOR((salary - (SELECT min FROM SalaryMin)) / (SELECT bucketsize FROM SalaryRange))) as binid
    FROM salaries
    WHERE yearid = 2016
  )

  SELECT
  binid,
  (SELECT min FROM SalaryMin) + binid * (SELECT bucketsize FROM SalaryRange) AS low,
  (SELECT min FROM SalaryMin) + (binid + 1) * (SELECT bucketsize FROM SalaryRange) as high,
  COUNT(binid)
  FROM SalaryBins
  GROUP BY binid
  ORDER BY binid;
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT
  yearid,
  MIN(Salary) - LAG(MIN(Salary)) OVER (ORDER BY yearid) as mindiff,
  MAX(Salary) - LAG(MAX(Salary)) OVER (ORDER BY yearid) as maxdiff,
  AVG(Salary) - LAG(AVG(Salary)) OVER (ORDER BY yearid) as avgdiff
  FROM salaries
  GROUP BY yearid
  ORDER BY yearid
  OFFSET 1;
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT
  people.playerid, people.namefirst, people.namelast, salary, salaries.yearid
  FROM (
    SELECT
    yearid, MAX(Salary) AS maxsalary
    FROM salaries
    WHERE yearid in (2000, 2001)
    GROUP BY yearid
  ) MaxSalaries
  INNER JOIN salaries
  ON MaxSalaries.maxsalary = salaries.salary AND MaxSalaries.yearid = salaries.yearid
  INNER JOIN people
  ON salaries.playerid = people.playerid;

;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT
  allstarfull.teamid, MAX(salaries.salary) - MIN(salaries.salary) as diffavg
  FROM allstarfull
  INNER JOIN salaries
  ON allstarfull.playerid = salaries.playerid and allstarfull.yearid = salaries.yearid
  WHERE allstarfull.yearid = 2016
  GROUP BY allstarfull.teamid
  ORDER BY allstarfull.teamid;
;
