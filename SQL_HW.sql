USE sakila;

-- 1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper
-- case letters. Name the column `Actor Name`.
ALTER TABLE actor ADD COLUMN `Actor Name` VARCHAR(50);
UPDATE actor SET `Actor Name` = CONCAT(first_name, ' ', last_name);

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name,
-- "Joe." What is one query would you use to obtain this information?
SELECT * FROM actor
WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters `GEN`
SELECT DISTINCT(last_name) FROM actor WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT DISTINCT(last_name) FROM actor WHERE last_name LIKE '%LI%'
ORDER BY last_name DESC, first_name DESC;
-- Ask for help on how to display first name too

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column
-- in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor ADD COLUMN `description` BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor DROP COLUMN `description`;

SELECT * FROM actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) from actor GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.
SELECT last_name, COUNT(last_name) from actor GROUP BY last_name HAVING COUNT(*)>1;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor SET first_name = REPLACE(first_name,'GROUCHO','HARPO');
UPDATE actor SET `Actor Name` = REPLACE(`Actor Name`,'GROUCHO WILLIAMS','HARPO WILLIAMS');

-- * 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a 
-- single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor SET first_name = REPLACE(first_name,'HARPO','GROUCHO');

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
CREATE TABLE IF NOT EXISTS address;
SHOW CREATE TABLE address;


-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT first_name, last_name FROM staff s JOIN address a ON (s.address_id = a.address_id);

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT SUM(amount) FROM payment p JOIN staff s ON (p.staff_id = s.staff_id) WHERE payment_date BETWEEN "2005-08-01" AND "2005-09-01";

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT f.title, COUNT(fa.actor_id) AS 'Actor Count'
FROM film f, film_actor fa
WHERE f.film_id = fa.film_id
GROUP BY title;
-- done

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT COUNT(*)
FROM inventory
WHERE film_id IN
(
  SELECT film_id
  FROM film
  WHERE TITLE = "Hunchback Impossible"
);
-- done


-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT p.customer_id, c.first_name, c.last_name, SUM(amount) AS 'total'
FROM payment p, customer c
WHERE p.customer_id = c.customer_id
GROUP BY last_name;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` 
-- have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT title
FROM film
WHERE language_id
IN (
  SELECT language_id
  FROM `language`
  WHERE language_id = 1
   )
   AND title LIKE "K%" OR title LIKE "Q%";
-- done

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN
  (
    SELECT film_id
    FROM film
    WHERE title = "Alone Trip"
  )
);
-- done

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT email
FROM customer
WHERE address_id IN
(
  SELECT address_id
  FROM address
  WHERE city_id IN
  (
    SELECT city_id
    FROM city
    WHERE country_id IN
    (
      SELECT country_id
      FROM country
      WHERE country_id = 20
    )
  )
 );
 -- suppose to use joins, maybe go back and redo if have time
 
 
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT title
FROM film
WHERE film_id IN
(
  SELECT film_id
  FROM film_category
  WHERE category_id IN
  (
    SELECT category_id
    FROM category
    WHERE category_id = 8
  )
);
-- done

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(*) AS 'rentalCounts'
FROM rental r, inventory i, film f
WHERE r.inventory_id = i.inventory_id AND i.film_id = f.film_id
GROUP BY title
ORDER BY 'rentalCounts' DESC;
-- close to being the solution
-- ORDER BY DESC needs to be implemented


-- 7f. Write a query to display how much business, in dollars, each store brought in.
-- use payment and customer
SELECT c.store_id, SUM(amount)
FROM payment p, customer c
WHERE p.customer_id = c.customer_id
GROUP BY store_id;
-- done

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, ci.city, co.country
FROM store s, address a, city ci, country co
WHERE s.address_id = a.address_id AND a.city_id = ci.city_id AND ci.country_id = co.country_id;
-- done

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.category_id, SUM(amount)
FROM rental r, film f, category c, payment p, inventory i
WHERE f.film_id = i.film_id AND i.inventory_id = r.inventory_id AND r.rental_id = p.rental_id
GROUP BY category_id;
-- Need help

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the 
-- problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
-- Substituted another query because 7h is not done
CREATE VIEW total_sales AS
SELECT s.store_id, SUM(amount) AS Gross
    FROM payment p
    JOIN rental r
    ON (p.rental_id = r.rental_id)
    JOIN inventory i
    ON (i.inventory_id = r.inventory_id)
    JOIN store s
    ON (s.store_id = i.store_id)
    GROUP BY s.store_id;

SELECT * FROM total_sales;

-- 8b. How would you display the view that you created in 8a?
-- ????

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.