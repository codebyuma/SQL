/* set syntax to SQL
sqlite> .tables
actors     directors_genres  movies_directors  roles
directors  movies            movies_genres*/

/*===
Car

Find all movie-names that have the word "Car" as the first word in the name.*/

SELECT name
FROM movies
WHERE name LIKE "CAR %";

/*====
Birthyear

Find all movies made in the year you were born. */

SELECT *
FROM movies
WHERE year = 1985;

/*====
1982

How many movies does our dataset have for the year 1982?*/

SELECT COUNT (name)   // SELECT COUNT(*) num85movies
FROM movies
WHERE year = 1982;

/*====
Stacktors

Find actors who have "stack" in their last name.*/


SELECT first_name, last_name
FROM actors
WHERE last_name LIKE "%stack%";

/*====
Fame Name Game

We all want our kids to be actors (...right), so what's the best first name and last name to give them? What are the 10 most popular first names and last names in the business? And how many actors have each given first or last name? This can be multiple queries.
*/

SELECT count(*), first_name 
FROM actors
GROUP BY first_name
ORDER BY count(*) DESC
LIMIT 10;

SELECT count(*), last_name 
FROM actors
GROUP BY last_name
ORDER BY count(*) DESC
LIMIT 10;


/* solution/notes: count(*) adds all the rows together and writes one row. Use GroupBy to tell it how to smush them together... So count all of the same names*/
SELECT first_name, COUNT(*) as name_count
FROM actors
GROUP BY first_name
ORDER BY name_count DESC
LIMIT 10;


/* ====
Prolific

List the top 100 most active actors and the number of movies they have starred in.
// group them by actor id, each role the actor has = one row
// then count them and order by how many rows each actor has*/

SELECT a.first_name, a.last_name, count(r.role)
FROM actors a
INNER JOIN roles r
on a.id = r.actor_id
GROUP BY a.id
ORDER BY count(*) DESC
LIMIT 100;

/*  solution/notes:
// fundamentally, we need to count roles. 
// if actor appears more than once, smush on actors and then count the number of rows
// when you group by 'field', anything the same in that field, you smush together. then you count number of rows that were collapsed to make that one row. ie group by actor id, so it counts how many rows with the duplicate actor id, then deletes duplicates and puts in one row with that name and the count. */

SELECT first_name, last_name, COUNT(*) as num_roles
FROM actors, roles, movies
WHERE actors.id = roles.actor_id
AND movies.id = roles.movie_id
GROUP BY actors.id
ORDER BY num_roles DESC
LIMIT 100;


/*===
Bottom of the Barrel

How many movies does IMDB have of each genre, ordered by least popular genre?*/

SELECT genre, count(movie_id)
FROM movies_genres
GROUP BY genre
ORDER BY count(*) ASC;


/*====
Braveheart

List the first and last names of all the actors who played in the 1995 movie 'Braveheart', arranged alphabetically by last name. */

SELECT a.first_name, a.last_name
FROM actors a
INNER JOIN roles r
on a.id = r.actor_id
INNER JOIN movies m
on r.movie_id = m.id
WHERE m.name = "Braveheart" AND m.year ="1995"
ORDER BY a.last_name ASC;

/*===
Leap Noir

List all the directors who directed a 'Film-Noir' movie in a leap year (you need to check that the genre is 'Film-Noir' and may, for the sake of this challenge, pretend that all years divisible by 4 are leap years). Your query should return director name, the movie name, and the year, sorted by movie name.
*/

SELECT d.first_name, d.last_name, m.name, m.year
FROM directors d
INNER JOIN movies_directors md
on d.id = md.director_id
INNER JOIN movies m
on md.movie_id = m.id
INNER JOIN movies_genres mg
on m.id = mg.movie_id
WHERE mg.genre = "Film-Noir" AND (m.year%4==0);
ORDER BY movies.name;

/*===

° Bacon

List all the actors that have worked with Kevin Bacon in Drama movies (include the movie name).*/


SELECT m.name, a.first_name, a.last_name 
FROM actors a
INNER JOIN roles r
on a.id = r.actor_id
INNER JOIN movies m
on r.movie_id = m.id
WHERE a.first_name <> "Kevin" AND a.last_name <> "Bacon" AND m.name
IN
	(SELECT m.name
	FROM actors a
	INNER JOIN roles r
	on a.id = r.actor_id
	INNER JOIN movies m
	on r.movie_id = m.id
	INNER JOIN movies_genres mg
	on m.id = mg.movie_id
	WHERE mg.genre = "Drama" AND a.first_name = "Kevin" AND a.last_name ="Bacon")
ORDER BY m.name;

/* ALTERNATE / SOLUTION / COMMENTS
// use subquery OR join on table twice */

SELECT m.name, costars.first_name, costars.last_name
FROM actors a, roles r, movies m, movies_genres mg, roles costar_roles, actors costars
WHERE 
	a.first_name = "Kevin" AND a.last_name = "Bacon" AND  --filter actors a to one record
	a.id = r.actor_id AND --currently only Kevin Bacon's, join it with roles to get all of his roles
    r.movie_id = m.id AND --now join to the movies to get the movie ids of the movies he's been in. At this point we have all of the movies he's in
    m.id = mg.movie_id AND
    mg.genre = "Drama" AND --at this point, have all of kevin's movies that are drama
    m.id = costar_roles.movie_id AND --now, start syncing up to get the other ids. so from the movie list we filtered above, link it up to the fresh copy 							of the roles to list all roles in these movies
    costar_roles.actor_id = costars.id AND --now get the actors in these roles
    costars.id <> a.id --the actors in this list should not match kevin bacon's id (a.id)l
 ORDER BY m.name;



/*===

Immortal Actors

Which actors have acted in a film before 1900 and also in a film after 2000?*/

SELECT a.first_name, a.last_name, a.id
FROM actors a
INNER JOIN roles r
on a.id = r.actor_id
INNER JOIN movies m
on r.movie_id = m.id
WHERE m.year < 1900 AND a.id in 
(
	SELECT a.id
	FROM actors a
	INNER JOIN roles r
	on a.id = r.actor_id
	INNER JOIN movies m
	on r.movie_id = m.id
	WHERE m.year >2000
)
GROUP BY a.id;

/* ALTERNATE / NOTES - using intersect*/

SELECT actors.first_name, actors.last_name
FROM actors
INNER JOIN roles ON roles.actor_id = actors.id
INNER JOIN movies ON roles.movie_id = movies.id
WHERE movies.year < 1900
INTERSECT --looking for intersection of these two result sets. if something on one side but not other, throw it away. intersect may only be 
		  -- possible if you select the same columns
SELECT actors.first_name, actors.last_name
FROM actors
INNER JOIN roles ON roles.actor_id = actors.id
INNER JOIN movies ON roles.movie_id = movies.id
WHERE movies.year < 2000
ORDER BY actors.last_name;


/*====

Busy Filming

Find actors that played five or more roles in the same movie after the year 1990. Notice that ROLES may have occasional duplicates, but we are not interested in these: we want actors that had five or more distinct roles in the same movie. Write a query that returns the actors' names, the movie name, and the number of distinct roles that they played in that movie (which will be ≥ 5).
*/


SELECT a.first_name, a.last_name, r.movie_id, m.name, count(DISTINCT r.role)
FROM actors a
INNER JOIN roles r
on a.id = r.actor_id
INNER JOIN movies m
on r.movie_id = m.id
WHERE m.year > 1990
GROUP BY m.id, a.id
HAVING count(DISTINCT r.role) >=5; --THIS ONLY WORKED AFTER I PUT DISTINCT IN THIS LINE



SELECT a.first_name, a.last_name, r.movie_id, m.name, count(r.role)
FROM actors a
INNER JOIN roles r
on a.id = r.actor_id
INNER JOIN movies m
on r.movie_id = m.id
WHERE a.first_name = "Robert" AND a.last_name = "Bockstael" AND m.year>1990
GROUP BY m.id
HAVING count(r.role) >=5;


/* SOLUTION / COMMENTS
// trying to smush/aggregate actor ids and movie ids*/

SELECT actors.first_name, actors.last_name, movies.name, COUNT(DISTINCT roles.role) AS num_roles
FROM actors
INNER JOIN roles on actors.id = roles.actor_id
INNER JOIN movies ON roles.movie_id = movies.id
WHERE movies.year > 1990
GROUP BY roles.actor_id, roles.movie_id --could do actors.actor_id and movies.movie_id
HAVING num_roles > 4;



/*====
♀

For each year, count the number of movies in that year that had only female actors. For movies where no one was casted, you can decide whether to consider them female-only.*/

SELECT count(*), m.year, m.name
FROM movies m
INNER JOIN roles r
on m.id = r.movie_id
INNER JOIN actors a
on r.actor_id = a.id
WHERE m.year = 1988 AND a.id NOT IN (
	SELECT a.id
	FROM actors a
	WHERE a.gender = "M")
GROUP BY m.id, m.year
LIMIT 10;

/* SOLUTION / COMMENTS */

SELECT y, COUNT(*) as num_movies --can't do movies.year instead of y, because it goes looking for a table named movies but everything in our (
								-- select brackets table doesn't have a name)
FROM 
(SELECT movies.name, movies.year as y
FROM movies
EXCEPT
SELECT movies.name, movies.year as y
FROM movies
INNER JOIN roles on roles.movie_id = movies.id
INNER JOIN actors on roles.actor_id = actors.id
WHERE actors.gender = "M")
GROUP BY y -- squish records that are the same year. 


/*ALTERNATE SOLUTION*/

SELECT m.year, count(*) femaleOnly
FROM movies m
WHERE not exists (
	SELECT *
	FROM roles as ma, actors as a
	WHERE a.id = ma.actor_id
	AND ma.movie_id = m.id
	AND a.gender = 'M')
GROUP BY m.year;



