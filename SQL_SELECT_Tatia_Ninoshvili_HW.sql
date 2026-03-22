--The marketing team needs a list of animation movies between 2017 and 2019 to promote family-friendly content in an upcoming season in stores. 
--Show all animation movies released during this period with rate more than 1, sorted alphabetically

select PF.title, PF.release_year, PF.rental_rate
from public.film as PF
inner join public.film_category fc 
on pf.film_id = fc.film_id
inner join public.category c 
on fc.category_id = c.category_id 
where c."name" = 'Animation'
and PF.release_year>=2017 and PF.release_year <=2019
and PF.rental_rate >1
order by pf.title; 

--this one is with JOIN, used inner join because I needed films that have category assigned to them. 
--this is the simplest solution and it also gives you the opportunity to show data from any of the joined tables
--I would use this one in production because it is straight forward and I feel that I can add anything anytime

select PF.title, PF.release_year, PF.rental_rate
from public.film as PF
where PF.film_id in (select fc.film_id 
from film_category fc 
where fc.category_id = (select c.category_id 
from category c 
where c."name" = 'Animation'))
and PF.release_year>=2017 and PF.release_year <=2019
and pf.rental_rate > 1
order by pf.title; 

--subquery is a bit more cut into chunks but I feel like this is not how my brain works
--this seperates filtering into steps and it is more visible what we are trying to accomplish, too many levels can get confusing easily

with animation_films as (select fc.film_id
from public.film_category fc
inner join public.category c 
on fc.category_id = c.category_id
where c.name='Animation')
select f.title, f. release_year, f.rental_rate
from public.film f
inner join animation_films af 
on f.film_id = af.film_id 
where f.release_year >= 2017 and f.release_year <= 2019
and f.rental_rate > 1
order by f.title; 

--I used inner join here as well, since we still need the films that are animation
--both the CTE and the Subquery seem easier to read than write



--The finance department requires a report on store performance to assess profitability and plan resource allocation for stores after March 2017. 
--Calculate the revenue earned by each rental store after March 2017 (since April) (include columns: address and address2 – as one column, revenue)


select CONCAT(a.address, ' ', a.address2) AS store_address, SUM(p.amount) AS revenue
from public.payment p
inner join public.rental r on p.rental_id = r.rental_id
inner join public.inventory i on r.inventory_id = i.inventory_id
inner join public.store s on i.store_id = s.store_id
inner join public.address a on  s.address_id = a.address_id
where p.payment_date >= '2017-04-01'
group by a.address, a.address2
order by  revenue DESC;

-- this is a direct approach, I used inner joins everywhere because we don't need any unmatched rows, would use this in production
--I simply calculated the revenues with SUM, concat and sum are pretty common excel formulas as well so they were easy to use
--I assumed that the revenue meant sum of payment amounts


select CONCAT(a.address, ' ', a.address2) AS store_address, sub.revenue
from  (select i.store_id, SUM(p.amount) AS revenue
from public.payment p
inner join public.rental r on  p.rental_id = r.rental_id
inner join public.inventory i on  r.inventory_id = i.inventory_id
where p.payment_date >= '2017-04-01'
group by  i.store_id
) sub
inner join public.store s on  sub.store_id = s.store_id
inner join public.address a on  s.address_id = a.address_id
order by sub.revenue DESC;


--I calculated the revenue per store inside the inner query and then added the address using the outer query
--found out that writing stuff on the same lines makes it easier to read and less overwhelming 

with store_revenue as (
select i.store_id, SUM(p.amount) as revenue
from public.payment p
inner join public.rental r on p.rental_id = r.rental_id
inner join public.inventory i on r.inventory_id = i.inventory_id
where p.payment_date >= '2017-04-01'
group by  i.store_id)
select CONCAT(a.address, ' ', a.address2) as store_address, sr.revenue
from store_revenue sr
inner join public.store s on  sr.store_id = s.store_id
inner join public.address a on  s.address_id = a.address_id
order by sr.revenue DESC;

--the first step calculates the revenue and the second one adds the address
--this one was the easiest to read and write, would use in production 

--The marketing department in our stores aims to identify the most successful actors since 2015 to boost customer interest in their films. 
--Show top-5 actors by number of movies (released since 2015) they took part in (columns: first_name, last_name, number_of_movies, sorted by number_of_movies in descending order)

select a.first_name, a.last_name, COUNT(f.film_id) AS number_of_movies
from public.actor a
inner join public.film_actor fa on  a.actor_id = fa.actor_id
inner join  public.film f on  fa.film_id = f.film_id
where  f.release_year >= 2015
group by a.first_name, a.last_name
order by number_of_movies DESC
limit  5;

--this is simple, I used inner join to get the actors that have movies
--would absolutely be my first choice for this problem
--I assumed that since 2015 meant release year >= 2015


select a.first_name, a.last_name, (select COUNT(*)
from public.film_actor fa
inner join public.film f ON fa.film_id = f.film_id
where fa.actor_id = a.actor_id
and f.release_year >= 2015) as number_of_movies
from public.actor a
order by number_of_movies DESC
limit  5;

--the inner query checks each actor seperately, this is safe but slower

with actor_movies as (select fa.actor_id, COUNT(f.film_id) AS number_of_movies
from  public.film_actor fa
inner join public.film f on  fa.film_id = f.film_id
where  f.release_year >= 2015
group by fa.actor_id)
select a.first_name, a.last_name, am.number_of_movies
from public.actor a
inner join actor_movies am ON a.actor_id = am.actor_id
order by am.number_of_movies DESC
limit  5;

--this version first counts movies per actor and then gets the names of the actor
--this one would also be great to use in production

--The marketing team needs to track the production trends of Drama, Travel, and Documentary films to inform genre-specific marketing strategies.
--Show number of Drama, Travel, Documentary per year (include columns: release_year, number_of_drama_movies, number_of_travel_movies, number_of_documentary_movies), sorted by release year in descending order. Dealing with NULL values is encouraged)

--did this one but the code did not run so I will reattempt until I get it right
--subquery seems impossible for this

--The HR department aims to reward top-performing employees in 2017 with bonuses to recognize their contribution to stores revenue.
-- Show which three employees generated the most revenue in 2017? 

select s.first_name, s.last_name, SUM(p.amount) AS revenue
from  public.payment p
inner join public.staff s ON p.staff_id = s.staff_id
where EXTRACT(YEAR FROM p.payment_date) = 2017
group by s.staff_id, s.first_name, s.last_name
order by revenue DESC
limit  3;

--adds up payments in per employee

select s.first_name, s.last_name, sub.revenue
from (select p.staff_id, SUM(p.amount) AS revenue
from public.payment p
where EXTRACT(YEAR FROM p.payment_date) = 2017
group by p.staff_id) sub
inner join public.staff s on sub.staff_id = s.staff_id
order by sub.revenue DESC
limit 3;

--does the math inside the query and gets the names from outside the query, like usual

with staff_revenue as (select p.staff_id, SUM(p.amount) AS revenue
from public.payment p
where EXTRACT(YEAR FROM p.payment_date) = 2017
group by p.staff_id)
select s.first_name, s.last_name, sr.revenue
from staff_revenue sr
inner join public.staff s on sr.staff_id = s.staff_id
order by sr.revenue DESC
limit 3;

--same as subquery but a bit clearer, easy to read

select  DISTINCT on (p.staff_id) p.staff_id, i.store_id as last_store_id
from public.payment p
inner join public.rental r on p.rental_id = r.rental_id
inner join public.inventory i on r.inventory_id = i.inventory_id
where EXTRACT(YEAR from p.payment_date) = 2017
order by p.staff_id, p.payment_date DESC, p.payment_id DESC;

--this query ties everything together, sorts every employees payments by date and gives the top 
--if two payments have the same date payment_id desc will help with that

--The management team wants to identify the most popular movies and their target audience age groups to optimize marketing efforts. 
--Show which 5 movies were rented more than others (number of rentals), and what's the expected age of the audience for these movies?

select f.title, f.rating, COUNT(r.rental_id) AS number_of_rentals,
case when f.rating = 'G' then 'All ages'
when  f.rating = 'PG' then 'All ages (parental guidance suggested)'
when  f.rating = 'PG-13' then '13 and older'
when  f.rating = 'R' then '17 and older (with parent/guardian)'
when  f.rating = 'NC-17' then '18 and older only'
end as expected_age
from public.film f
inner join  public.inventory i on f.film_id = i.film_id
inner join  public.rental r on i.inventory_id = r.inventory_id
group by f.film_id, f.title, f.rating
order by number_of_rentals DESC
limit 5;

--again I used inner join because we only want films that have been rented, I used case when to get the expected age of the audience like the task asked

select f.title, f.rating, (select  COUNT(*)
from public.inventory i
inner join public.rental r on  i.inventory_id = r.inventory_id
where i.film_id = f.film_id) as number_of_rentals,
case when f.rating = 'G' then 'All ages'
when f.rating = 'PG' then 'All ages (parental guidance suggested)'
when f.rating = 'PG-13' then '13 and older'
when f.rating = 'R' then '17 and older (with parent/guardian)'
when f.rating = 'NC-17' then '18 and older only'
end as expected_age
from public.film f
ORDER by number_of_rentals DESC
limit  5;

--it counts rental amounts for each movie, this is slower
--case when does the same thing here

with rental_counts as (
select i.film_id, COUNT(r.rental_id) as number_of_rentals
from public.inventory i
inner join public.rental r on i.inventory_id = r.inventory_id
group by  i.film_id)
select f.title, f.rating, rc.number_of_rentals,
case when  f.rating = 'G' THEN 'All ages'
when  f.rating = 'PG' THEN 'All ages (parental guidance suggested)'
when  f.rating = 'PG-13' THEN '13 and older'
when  f.rating = 'R' THEN '17 and older (with parent/guardian)'
when  f.rating = 'NC-17' THEN '18 and older only'
end as expected_age
from public.film f
inner join rental_counts rc ON f.film_id = rc.film_id
order by rc.number_of_rentals DESC
limit 5;

--counts rentals in the name block and then gets title and rating afterwards
--case when is the solution for all three

select a.first_name, a.last_name, MAX(f.release_year) as latest_movie_year,
EXTRACT(YEAR FROM CURRENT_DATE) - MAX(f.release_year) as years_since_last_movie
from public.actor a
inner join public.film_actor fa on a.actor_id = fa.actor_id
inner join public.film f on fa.film_id = f.film_id
group by a.actor_id, a.first_name, a.last_name
order by years_since_last_movie DESC;

--gets the latest year and calculates the difference between that and max
--I assumed that we had to get the current year from Current_date

select a.first_name, a.last_name,
(select MAX(f.release_year)
from public.film_actor fa
inner join public.film f on fa.film_id = f.film_id
where fa.actor_id = a.actor_id
) as latest_movie_year,
EXTRACT(YEAR from CURRENT_DATE) -
(select MAX(f.release_year)
from public.film_actor fa
inner join public.film f on fa.film_id = f.film_id
where fa.actor_id = a.actor_id) as years_since_last_movie
from public.actor a
order by years_since_last_movie DESC;

--this runs the max query on each actor seperately, again this is a slower option


with latest_movies as (
select fa.actor_id, MAX(f.release_year) as latest_movie_year
from public.film_actor fa
inner join public.film f on fa.film_id = f.film_id
group by fa.actor_id)
select a.first_name, a.last_name, lm.latest_movie_year,
EXTRACT(YEAR FROM CURRENT_DATE) - lm.latest_movie_year as years_since_last_movie
from public.actor a
inner join latest_movies lm ON a.actor_id = lm.actor_id
order by years_since_last_movie DESC;

--finds latest year and joines it with the appropriate actor

--V2

select a.first_name, a.last_name, f1.release_year as film_year,
MIN(f2.release_year) AS next_film_year,
MIN(f2.release_year) - f1.release_year as gap
from public.actor a
inner join public.film_actor fa1 on a.actor_id = fa1.actor_id
inner join public.film f1 on fa1.film_id = f1.film_id
inner join public.film_actor fa2 on a.actor_id = fa2.actor_id
inner join public.film f2 on fa2.film_id = f2.film_id
and f2.release_year > f1.release_year
group by a.actor_id, a.first_name, a.last_name, f1.release_year
order by gap DESC
limit 10;

--the self join part was pretty tricky here, this joins the same actors films twice and each films year is later than the last


select sub.first_name, sub.last_name, sub.release_year AS film_year,
(select MIN(f2.release_year)
from public.film_actor fa2
inner join public.film f2 on fa2.film_id = f2.film_id
where fa2.actor_id = sub.actor_id
and f2.release_year > sub.release_year) as next_film_year,
(select MIN(f2.release_year)
from public.film_actor fa2
inner join public.film f2 on fa2.film_id = f2.film_id
where fa2.actor_id = sub.actor_id
and f2.release_year > sub.release_year) - sub.release_year AS gap
from (select distinct a.actor_id, a.first_name, a.last_name, f.release_year
from public.actor a
inner join public.film_actor fa on a.actor_id = fa.actor_id
inner join public.film f on fa.film_id = f.film_id) sub
order by gap DESC NULLS LAST
limit 10;

--istead of a self join we got one subquery repeating itself twice
--nulls last is there because the last film has no next one and the solution won't know that itself


with actor_years as (select distinct a.actor_id, a.first_name, a.last_name, f.release_year
from public.actor a
inner join public.film_actor fa on a.actor_id = fa.actor_id
inner join public.film f on fa.film_id = f.film_id),
actor_gaps as (
select ay1.actor_id, ay1.first_name, ay1.last_name, ay1.release_year AS film_year,
MIN(ay2.release_year) as next_film_year
from actor_years ay1
inner join actor_years ay2
on ay1.actor_id = ay2.actor_id
and ay2.release_year > ay1.release_year
group by ay1.actor_id, ay1.first_name, ay1.last_name, ay1.release_year)
select first_name, last_name, film_year, next_film_year, next_film_year - film_year as gap
from actor_gaps
order by gap DESC
limit 10;

--first cte got distinct years per actor, second one does the self join to find the next year
--main query is for calculating the gap 