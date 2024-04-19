/* Which is the most profitable region & what is the top 5 most popular genre there? */

select billing_country, round(sum(total)) as total_amount
from invoice 
group by billing_country
order by total_amount desc
limit 1

/* Popular genre */

WITH popular_genre AS
(SELECT customer. country, genre.name As Genre_name, COUNT (invoice_line.quantity) AS Total_purchases
FROM invoice_line
JOIN invoice ON invoice.invoice_id = invoice_line. invoice_id
JOIN customer ON customer.customer_id = invoice.customer_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
GROUP BY 1, 2
ORDER BY 1 ASC, 3 DESC
)
SELECT * FROM popular_genre WHERE country = 'USA';

/* Which are the top 5 non-performing region? */ 

select billing_country, round(sum(total)) as total_amount
from invoice 
group by billing_country
order by total_amount asc
limit 5

/* Where are the top 10 customers located? */ 

SELECT first_name, last_name, ROUND (SUM(total)) AS total_spending, country
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY 1,2,4
ORDER BY total_spending DESC LIMIT 10;


/* Which genre has the most customers & which artist has sold the most records? */ 


WITH popular_genre AS
(SELECT  genre.name As Genre_name, COUNT (invoice_line.quantity) AS Total_purchases
FROM invoice_line
JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
JOIN customer ON customer.customer_id = invoice.customer_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
GROUP BY 1
ORDER BY 2 DESC
)
SELECT * FROM popular_genre limit 1;


/* top spending customer in each country? */

WITH top_customer_spendings AS
(SELECT first_name, last_name, ROUND(SUM(total)) AS total_spending_by, country,
ROW_NUMBER () OVER (PARTITION BY customer.country ORDER BY COUNT (total) DESC) AS RowNo
FROM customer
JOIN invoice ON customer. customer_id = invoice.customer_id
GROUP BY 1,2,4
ORDER BY 3 DESC )
SELECT * FROM top_customer_spendings WHERE RowNo <= 1

/* Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
 */

SELECT billing_city,SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;


/* Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT customer.customer_id, first_name, last_name, SUM(total) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spending DESC
LIMIT 1;

/* Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT A.name AS ArtistName, COUNT(P.playlist_id) AS total_track_count
FROM artist A
INNER JOIN album AL ON A.artist_id = AL.artist_id
INNER JOIN track T ON AL.album_id = T.album_id
INNER JOIN playlist_track P ON T.track_id = P.track_id
INNER JOIN genre G ON T.genre_id = G.genre_id
WHERE G.name ='Rock'
GROUP BY A.name
ORDER BY total_track_count DESC
LIMIT 10;


/*Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT name,miliseconds
FROM track
WHERE miliseconds > (
	SELECT AVG(miliseconds) AS avg_track_length
	FROM track )
ORDER BY miliseconds DESC;

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */


WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;



/* Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1


