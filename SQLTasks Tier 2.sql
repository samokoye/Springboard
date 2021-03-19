/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

Answer:
SELECT name, membercost
FROM `Facilities`
WHERE membercost !=0
LIMIT 0 , 30

/* Q2: How many facilities do not charge a fee to members? */

#Answer:
SELECT COUNT( name )
FROM `Facilities`
WHERE membercost = 0.0


/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

#Answer:
SELECT facid, name, membercost,monthlymaintenance
FROM Facilities
WHERE membercost < 0.2 * monthlymaintenance
AND membercost !=0


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

#Answer:
SELECT *
FROM Facilities
WHERE facid IN ( 1, 5 )

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

#Answer:
SELECT name, monthlymaintenance,
CASE WHEN monthlymaintenance > 100 THEN expensive
ELSE cheap
END AS maintenancecost
FROM Facilities
LIMIT 30


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

#Answer:
SELECT firstname, surname, joindate
FROM Members
WHERE joindate = (SELECT MAX(joindate) FROM Members)

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

#Answer:

SELECT DISTINCT f.name AS facility_name, CONCAT(m.surname,' ',m.firstname) AS member_name, m.memid AS member_id, b.facid AS facility_id
FROM Members As m
INNER JOIN Bookings AS b
ON b.memid = m.memid
INNER JOIN Facilities AS f
ON b.facid = f.facid
WHERE b.facid BETWEEN 0 AND 1 AND m.memid !=0
ORDER BY member_name



/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */


#Answer:
SELECT DISTINCT f.name AS facility_name, 
CASE WHEN b.memid =0 THEN CONCAT(m.firstname) 
ELSE CONCAT(m.firstname, ' ', m.surname) 
END AS member_name,
CASE WHEN b.memid = 0 THEN b.slots * f.guestcost 
ELSE b.slots * f.membercost 
END AS cost_per_half_hr, b.starttime AS day_of
FROM Bookings as b
INNER JOIN Members as m
ON b.memid = m.memid
INNER JOIN Facilities as f
ON f.facid = b.facid
WHERE DATE(b.starttime) = '2012-09-14' 
AND b.memid = 0 or DATE(b.starttime) = '2012-09-14' 
AND b.memid != 0 AND
CASE WHEN b.memid = 0 THEN b.slots * f.guestcost 
     ELSE b.slots * f.membercost
END > 30
ORDER BY cost_per_half_hr DESC;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */


SELECT DISTINCT sub.name AS facility_name, 
CASE WHEN sub.memid =0 
THEN CONCAT(sub.firstname) 
ELSE CONCAT(sub.firstname, ' ', sub.surname) 
END AS member_name,
CASE WHEN sub.memid = 0 
THEN sub.slots * sub.guestcost 
ELSE sub.slots * sub.membercost 
END AS cost_per_half_hr, sub.starttime AS day_of
FROM(SELECT b.starttime, b.facid, b.memid, b.slots, f.membercost, f.guestcost, f.name,m.firstname, m.surname
FROM Bookings as b
INNER JOIN Members as m
ON b.memid = m.memid
INNER JOIN Facilities as f
ON f.facid = b.facid) AS sub
WHERE DATE(sub.starttime) = '2012-09-14' 
AND sub.memid = 0 or DATE(sub.starttime) = '2012-09-14' AND sub.memid != 0 
AND CASE WHEN sub.memid = 0 
THEN sub.slots * sub.guestcost 
     ELSE sub.slots * sub.membercost
END > 30
ORDER BY cost_per_half_hr DESC;

/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

/*Answer:*/

query_10 = pd.read_sql_query("SELECT f.name, SUM(CASE WHEN b.memid = 0\
                             THEN b.slots * f.guestcost ELSE b.slots * f.membercost \
                             END) AS total_revenue\
                             FROM Bookings AS b \
                             INNER JOIN Facilities AS f \
                             ON b.facid = f.facid \
                             GROUP BY f.name \
                             HAVING total_revenue < 1000",engine)
query_10.head()

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

# Answer:

Q11 = pd.read_sql_query("SELECT m.surname||', '|| m.firstname As member,\
                             n.surname||', '|| n.firstname AS Recommedended_by \
                             FROM Members AS m, Members AS n \
                             WHERE m.memid= n.recommendedby AND m.recommendedby !=0 \
                             OR n.memid= m.recommendedby AND m.recommendedby !=0 \
                             ORDER BY m.surname;", engine) 
Q11.head()

/* Q12: Find the facilities with their usage by member, but not guests */

#Answer:
Q12 = pd.read_sql_query("SELECT f.name AS facility_name, COUNT(b.starttime) AS usage \
FROM Bookings AS b \
INNER JOIN Facilities AS f \
ON b.facid = f.facid \
WHERE b.memid !=0 \
GROUP BY f.name", engine)

Q12

/* Q13: Find the facilities usage by month, but not guests */

#Answer:
Q13 = pd.read_sql_query("SELECT f.name AS facility_name,\
(strftime('%Y-%m', starttime)) as usage_by_month, \
COUNT(b.starttime) AS total_usage \
FROM Bookings AS b \
INNER JOIN Facilities AS f \
ON b.facid = f.facid \
WHERE b.memid !=0 \
GROUP BY f.name, usage_by_month", engine)

Q13