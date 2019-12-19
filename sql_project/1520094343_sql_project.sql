/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

-- A simple query with WHERE solves this problem.

SELECT name
FROM country_club.Facilities
WHERE membercost > 0

/* Q2: How many facilities do not charge a fee to members? */

-- Four facilities do not have a cost to members.

SELECT COUNT(name)
FROM country_club.Facilities
WHERE membercost = 0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

-- This is possible through basic numeric calculation and comparison operators

SELECT facid, name, membercost, monthlymaintenance
FROM country_club.Facilities
WHERE membercost < (0.2 * monthlymaintenance)
  AND membercost > 0

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

-- An IN statement does the job handily.

SELECT *
FROM country_club.Facilities
WHERE facid IN (1,5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

-- A case statement with basic comparison operators can do this.

SELECT name, monthlymaintenance,
   CASE WHEN monthlymaintenance >= 100 THEN 'expensive'
        ELSE 'cheap' END AS costclass
FROM country_club.Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

-- The clause used if LIMIT was a possible solution is as below, but this 
-- does not allow for multiple members who joined on the same day.

SELECT firstname, lastname
FROM country_club.Members
ORDER BY joindate DESC
LIMIT 1

-- The amended clause involves a subquery to determine the maximum value of 
-- the joindate value. This can then be used for a comparison filter using WHERE.

SELECT firstname, surname, joindate
FROM country_club.Members
WHERE joindate = (SELECT MAX(joindate) FROM country_club.Members)

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

-- Concatenating information from the three way joined table can provide the required
-- data. It would also be possible to use an IN statement listing the two Teenis Court
-- facility names, but due to ease of implementation I have used LIKE here.

SELECT DISTINCT CONCAT(firstname,' ',surname) AS fullname, name AS courtname
FROM country_club.Members m
INNER JOIN country_club.Bookings b
ON m.memid = b.memid
INNER JOIN country_club.Facilities f
ON b.facid = f.facid
WHERE name LIKE 'Tennis Court%'
ORDER BY fullname

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

-- Seemed simplest to perform filtering in the WHERE clause to get only bookings
-- that reached the cost threshold. It's also possible to note that no member 
-- booking costs are over $30, so the query could be restricted to the guest table
-- alone if this is taken as fact. I attempted to write a query that would be valid
-- if a new facility were added in the future with member costs above $30.

SELECT name, CONCAT(firstname,' ',surname) AS fullname, 
CASE WHEN b.memid > 0 THEN membercost
     ELSE guestcost END totalcost
FROM country_club.Members m
INNER JOIN country_club.Bookings b
  ON m.memid = b.memid
INNER JOIN country_club.Facilities f
  ON b.facid = f.facid
WHERE ((membercost > 30 AND b.memid > 0) OR (guestcost > 30 AND b.memid = 0))
  AND (starttime BETWEEN '2012-09-14 00:00:00' AND '2012-09-15 00:00:00')
ORDER BY totalcost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

-- I really didn't know the best way to do this, as you're still required to
-- have the result of the multiple joins as well as the single column output
-- of the actual price charged. The best way I could figure to shoehorn in a
-- subquery was when considering the where statement.

SELECT name, CONCAT(firstname,' ',surname) AS fullname, 
CASE WHEN b.memid > 0 THEN membercost
     ELSE guestcost END totalcost
FROM country_club.Members m
INNER JOIN country_club.Bookings b
  ON m.memid = b.memid
INNER JOIN country_club.Facilities f
  ON b.facid = f.facid
WHERE ((b.memid > 0 AND b.facid IN (SELECT facid FROM country_club.Facilities WHERE membercost > 30)) 
        OR (b.memid = 0 AND b.facid IN (SELECT facid FROM country_club.Facilities WHERE guestcost > 30)))
  AND (starttime BETWEEN '2012-09-14 00:00:00' AND '2012-09-15 00:00:00')
ORDER BY totalcost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

-- GROUP BY and HAVING provide a method by which to compare the aggregated
-- totalrevenue field and return the necessary output.

SELECT name, 
SUM(CASE WHEN b.memid > 0 THEN membercost
         ELSE guestcost END) AS totalrevenue
FROM country_club.Members m
INNER JOIN country_club.Bookings b
  ON m.memid = b.memid
INNER JOIN country_club.Facilities f
  ON b.facid = f.facid
GROUP BY name
HAVING totalrevenue < 1000
ORDER BY totalrevenue DESC
