#1
SHOW tables;

#2
SELECT title, length FROM film WHERE length>120;

#3
SELECT title, language.name FROM film JOIN language ON film.language_id=language.language_id
WHERE description LIKE "%Documentary%";

#4
SELECT title FROM film JOIN film_category ON film.film_id=film_category.film_id 
	JOIN category ON film_category.category_id=category.category_id
WHERE description NOT LIKE "%Documentary%" AND category.name="Documentary";

#5
SELECT distinct first_name, last_name FROM actor JOIN film_actor ON film_actor.actor_id=actor.actor_id
	JOIN film ON film.film_id=film_actor.film_id
WHERE special_features LIKE "%Deleted scenes%" 

#6
SELECT rating, count(title) AS number FROM film GROUP BY rating

#7
SELECT DISTINCT title FROM film JOIN inventory ON film.film_id=inventory.film_id 
	JOIN rental ON rental.inventory_id=inventory.inventory_id
WHERE rental.rental_date BETWEEN '2005.05.25' AND '2005.05.30'
ORDER BY title

#8
SELECT title FROM film WHERE rating="R"
ORDER BY length DESC
limit 5

#9 
SELECT DISTINCT first_name, last_name FROM customer JOIN rental R1 ON customer.customer_id=R1.customer_id
	JOIN rental R2 ON customer.customer_id=R2.customer_id
WHERE R1.staff_id > R2.staff_id
ORDER BY last_name

#10
CREATE VIEW cities AS SELECT country, count(city) AS number FROM city JOIN country ON country.country_id=city.country_id
	GROUP BY country;
SELECT country FROM cities WHERE number>=(SELECT number FROM cities WHERE country="Canada")
ORDER BY number desc;

#11
SELECT first_name, last_name, count(rental_id) AS rentals
FROM customer JOIN rental ON customer.customer_id=rental.customer_id 
group by first_name, last_name
HAVING rentals>(
SELECT count(rental_id) FROM customer JOIN rental ON customer.customer_id=rental.customer_id
WHERE customer.email="PETER.MENARD@sakilacustomer.org"
)

#12


#13
SELECT distinct first_name, last_name from actor JOIN film_actor ON actor.actor_id=film_actor.actor_id
JOIN film ON film.film_id=film_actor.film_id
WHERE actor.actor_id NOT IN (SELECT actor.actor_id from actor JOIN film_actor ON actor.actor_id=film_actor.actor_id
JOIN film ON film.film_id=film_actor.film_id WHERE title LIKE "B%")

#14
CREATE VIEW K1 AS select actor.actor_id, count(film_actor.film_id) as quanH from film_actor JOIN actor ON actor.actor_id=film_actor.actor_id
		JOIN film_category ON film_category.film_id=film_actor.film_id JOIN category ON film_category.category_id=category.category_id
       WHERE category.name="Horror" group by actor.actor_id;
CREATE VIEW K2 AS select actor.actor_id, count(film_actor.film_id) as quanA from film_actor JOIN actor ON actor.actor_id=film_actor.actor_id
		JOIN film_category ON film_category.film_id=film_actor.film_id JOIN category ON film_category.category_id=category.category_id
        WHERE category.name="Action" group by actor.actor_id; 

Select actor.actor_id, K1.quanH, K2.quanA from actor JOIN film_actor ON actor.actor_id=film_actor.actor_id
	JOIN film_category ON film_category.film_id=film_actor.film_id JOIN category ON film_category.category_id=category.category_id
	LEFT JOIN K1 ON actor.actor_id=K1.actor_id LEFT JOIN  K2 ON actor.actor_id=K2.actor_id
	WHERE (quanA IS NULL AND quanH IS NOT NULL) OR (quanA IS not null AND quanH is not null AND quanA<quanH)
	group by actor.actor_id;
    
#15
SELECT customer_id, avg(amount) AS average from payment group by customer_id
HAVING average > (SELECT avg(amount) from payment WHERE DATE(payment_date)='2005-07-07' group by DATE(payment_date));

#16
ALTER TABLE language ADD language_no int AFTER name;
CREATE OR REPLACE VIEW lan AS (SELECT language.language_id AS id, count(film.film_id) as number from film JOIN language ON film.language_id=language.language_id group by language.language_id);
UPDATE language JOIN lan
SET language_no = lan.number WHERE language.language_id=lan.id;

#17
UPDATE film SET language_id = (SELECT language_id from language WHERE name="Mandarin") WHERE title="WON DARES";
CREATE VIEW Nick AS SELECT film_id FROM film_actor JOIN actor ON film_actor.actor_id=actor.actor_id WHERE actor.first_name="NICK" AND actor.last_name="WAHLBERG";
UPDATE film JOIN Nick ON film.film_id=Nick.film_id SET language_id = (SELECT language_id from language WHERE name="German") ;

#18
ALTER TABLE film DROP release_year
