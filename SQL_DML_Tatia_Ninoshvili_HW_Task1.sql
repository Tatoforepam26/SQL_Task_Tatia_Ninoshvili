--adding my top 3 favorite movies
--used SELECT instead of VALUES because that way i can use WHERE NOT EXISTS to avoid duplicates
--if something goes wrong i can rollback before committing

INSERT INTO public.film (title, description, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating, special_features, last_update)
SELECT 'Train Dreams',
'A logger living through a changing America in the early 1900s.',
2025, 1, 5, 2.99, 100, 24.99, 'R'::mpaa_rating,
'{"Trailers","Behind the Scenes"}'::text[], current_date
WHERE NOT EXISTS (select 1 from public.film where title = 'Train Dreams')
RETURNING film_id, title;

INSERT INTO public.film (title, description, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating, special_features, last_update)
SELECT 'Magnolia',
'Multiple storylines connect on one intense day in the San Fernando Valley.',
1999, 1, 7, 4.99, 188, 29.99, 'R'::mpaa_rating,
'{"Commentaries","Behind the Scenes"}'::text[], current_date
WHERE NOT EXISTS (select 1 from public.film where title = 'Magnolia')
RETURNING film_id, title;

INSERT INTO public.film (title, description, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating, special_features, last_update)
SELECT 'Interstellar',
'A father travels through space to find a new home for humanity.',
2014, 1, 6, 3.99, 169, 27.99, 'PG-13'::mpaa_rating,
'{"Trailers","Deleted Scenes","Behind the Scenes"}'::text[], current_date
WHERE NOT EXISTS (select 1 from public.film where title = 'Interstellar')
RETURNING film_id, title;

--I chose movies from 3 different genres and gave them the appropriate ones
--film_category connects films and categories together
--WHERE NOT EXISTS is here so running this twice wont break anything

INSERT INTO public.film_category (film_id, category_id, last_update)
SELECT
(select film_id from public.film where title = 'Train Dreams'),
(select category_id from public.category where name = 'Drama'),
current_date
WHERE NOT EXISTS (select 1 from public.film_category
where film_id = (select film_id from public.film where title = 'Train Dreams'));

INSERT INTO public.film_category (film_id, category_id, last_update)
SELECT
(select film_id from public.film where title = 'Magnolia'),
(select category_id from public.category where name = 'Classics'),
current_date
WHERE NOT EXISTS (select 1 from public.film_category
where film_id = (select film_id from public.film where title = 'Magnolia'));

INSERT INTO public.film_category (film_id, category_id, last_update)
SELECT
(select film_id from public.film where title = 'Interstellar'),
(select category_id from public.category where name = 'Sci-Fi'),
current_date
WHERE NOT EXISTS (select 1 from public.film_category
where film_id = (select film_id from public.film where title = 'Interstellar'));

COMMIT;

--updated rental rates and durations, had to convert weeks to days since thats how the database stores it

UPDATE public.film
SET rental_rate = 4.99, rental_duration = 7, last_update = current_date
WHERE title = 'Train Dreams';

UPDATE public.film
SET rental_rate = 9.99, rental_duration = 14, last_update = current_date
WHERE title = 'Magnolia';

UPDATE public.film
SET rental_rate = 19.99, rental_duration = 21, last_update = current_date
WHERE title = 'Interstellar';

COMMIT;

--adding the lead actors from each movie (i checked and none of them exist in the database yet)
--matching both first and last name to check for duplicates since there could be people with the same last name

insert into public.actor (first_name, last_name, last_update)
select 'JOEL', 'EDGERTON', current_date
where not exists (select 1 from public.actor
where first_name = 'JOEL' and last_name = 'EDGERTON')
returning actor_id, first_name, last_name;

insert into public.actor (first_name, last_name, last_update)
select 'FELICITY', 'JONES', current_date
where not exists (select 1 from public.actor
where first_name = 'FELICITY' and last_name = 'JONES')
returning actor_id, first_name, last_name;

insert into public.actor (first_name, last_name, last_update)
select 'TOM', 'CRUISE', current_date
where not exists (select 1 from public.actor
where first_name = 'TOM' and last_name = 'CRUISE')
returning actor_id, first_name, last_name;

insert into public.actor (first_name, last_name, last_update)
select 'JULIANNE', 'MOORE', current_date
where not exists (select 1 from public.actor
where first_name = 'JULIANNE' and last_name = 'MOORE')
returning actor_id, first_name, last_name;

insert into public.actor (first_name, last_name, last_update)
select 'MATTHEW', 'MCCONAUGHEY', current_date
where not exists (select 1 from public.actor
where first_name = 'MATTHEW' and last_name = 'MCCONAUGHEY')
returning actor_id, first_name, last_name;

insert into public.actor (first_name, last_name, last_update)
select 'ANNE', 'HATHAWAY', current_date
where not exists (select 1 from public.actor
where first_name = 'ANNE' and last_name = 'HATHAWAY')
returning actor_id, first_name, last_name;

--connecting actors to their movies through film_actor, no hardcoded ids, finding everything by name

insert into public.film_actor (actor_id, film_id, last_update)
select
(select actor_id from public.actor where first_name = 'JOEL' and last_name = 'EDGERTON'),
(select film_id from public.film where title = 'Train Dreams'),
current_date
where not exists (select 1 from public.film_actor
where actor_id = (select actor_id from public.actor where first_name = 'JOEL' and last_name = 'EDGERTON')
and film_id = (select film_id from public.film where title = 'Train Dreams'))
returning actor_id, film_id;

insert into public.film_actor (actor_id, film_id, last_update)
select
(select actor_id from public.actor where first_name = 'FELICITY' and last_name = 'JONES'),
(select film_id from public.film where title = 'Train Dreams'),
current_date
where not exists (select 1 from public.film_actor
where actor_id = (select actor_id from public.actor where first_name = 'FELICITY' and last_name = 'JONES')
and film_id = (select film_id from public.film where title = 'Train Dreams'))
returning actor_id, film_id;

insert into public.film_actor (actor_id, film_id, last_update)
select
(select actor_id from public.actor where first_name = 'TOM' and last_name = 'CRUISE'),
(select film_id from public.film where title = 'Magnolia'),
current_date
where not exists (select 1 from public.film_actor
where actor_id = (select actor_id from public.actor where first_name = 'TOM' and last_name = 'CRUISE')
and film_id = (select film_id from public.film where title = 'Magnolia'))
returning actor_id, film_id;

insert into public.film_actor (actor_id, film_id, last_update)
select
(select actor_id from public.actor where first_name = 'JULIANNE' and last_name = 'MOORE'),
(select film_id from public.film where title = 'Magnolia'),
current_date
where not exists (select 1 from public.film_actor
where actor_id = (select actor_id from public.actor where first_name = 'JULIANNE' and last_name = 'MOORE')
and film_id = (select film_id from public.film where title = 'Magnolia'))
returning actor_id, film_id;

insert into public.film_actor (actor_id, film_id, last_update)
select
(select actor_id from public.actor where first_name = 'MATTHEW' and last_name = 'MCCONAUGHEY'),
(select film_id from public.film where title = 'Interstellar'),
current_date
where not exists (select 1 from public.film_actor
where actor_id = (select actor_id from public.actor where first_name = 'MATTHEW' and last_name = 'MCCONAUGHEY')
and film_id = (select film_id from public.film where title = 'Interstellar'))
returning actor_id, film_id;

insert into public.film_actor (actor_id, film_id, last_update)
select
(select actor_id from public.actor where first_name = 'ANNE' and last_name = 'HATHAWAY'),
(select film_id from public.film where title = 'Interstellar'),
current_date
where not exists (select 1 from public.film_actor
where actor_id = (select actor_id from public.actor where first_name = 'ANNE' and last_name = 'HATHAWAY')
and film_id = (select film_id from public.film where title = 'Interstellar'))
returning actor_id, film_id;

COMMIT;

--putting movies in store 1 so they can be rented

insert into public.inventory (film_id, store_id, last_update)
select (select film_id from public.film where title = 'Train Dreams'), 1, current_date
where not exists (select 1 from public.inventory
where film_id = (select film_id from public.film where title = 'Train Dreams') and store_id = 1)
returning inventory_id, film_id, store_id;

insert into public.inventory (film_id, store_id, last_update)
select (select film_id from public.film where title = 'Magnolia'), 1, current_date
where not exists (select 1 from public.inventory
where film_id = (select film_id from public.film where title = 'Magnolia') and store_id = 1)
returning inventory_id, film_id, store_id;

insert into public.inventory (film_id, store_id, last_update)
select (select film_id from public.film where title = 'Interstellar'), 1, current_date
where not exists (select 1 from public.inventory
where film_id = (select film_id from public.film where title = 'Interstellar') and store_id = 1)
returning inventory_id, film_id, store_id;

COMMIT;

--changing an existing customer to my name and last name. found one with 43+ rentals and payments using a select query first

update public.customer
set first_name = 'TATIA',
last_name = 'NINOSHVILI',
email = 'tatianinoshvili12@gmail.com',
address_id = 1,
last_update = current_date
where customer_id = (
    select c.customer_id
    from public.customer c
    inner join public.rental r on c.customer_id = r.customer_id
    inner join public.payment p on c.customer_id = p.customer_id
    group by c.customer_id
    having count(distinct r.rental_id) >= 43
    and count(distinct p.payment_id) >= 43
    order by count(distinct r.rental_id) desc
    limit 1);

COMMIT;

--removing my rental and payment records, if i deleted rental first it would fail
--this only touches my records so other customers arent affected, if something looks wrong i can rollback before the commit

delete from public.payment
where customer_id = (select customer_id from public.customer
where first_name = 'TATIA' and last_name = 'NINOSHVILI');

delete from public.rental
where customer_id = (select customer_id from public.customer
where first_name = 'TATIA' and last_name = 'NINOSHVILI');

COMMIT;

--renting my top 3 movies and paying for them
--had to use dates from 2017 because thats what the payment table partitions cover (each rental is in a different month so they land in different partitions)

insert into public.rental (rental_date, inventory_id, customer_id, staff_id, last_update)
select '2017-03-01 10:00:00',
(select inventory_id from public.inventory
where film_id = (select film_id from public.film where title = 'Train Dreams') limit 1),
(select customer_id from public.customer
where first_name = 'TATIA' and last_name = 'NINOSHVILI'),
1, current_date
returning rental_id, inventory_id, customer_id;

insert into public.rental (rental_date, inventory_id, customer_id, staff_id, last_update)
select '2017-04-01 14:00:00',
(select inventory_id from public.inventory
where film_id = (select film_id from public.film where title = 'Magnolia') limit 1),
(select customer_id from public.customer
where first_name = 'TATIA' and last_name = 'NINOSHVILI'),
1, current_date
returning rental_id, inventory_id, customer_id;

insert into public.rental (rental_date, inventory_id, customer_id, staff_id, last_update)
select '2017-05-01 16:00:00',
(select inventory_id from public.inventory
where film_id = (select film_id from public.film where title = 'Interstellar') limit 1),
(select customer_id from public.customer
where first_name = 'TATIA' and last_name = 'NINOSHVILI'),
1, current_date
returning rental_id, inventory_id, customer_id;

--paying for the rentals obviously

insert into public.payment (customer_id, staff_id, rental_id, amount, payment_date)
select
(select customer_id from public.customer
where first_name = 'TATIA' and last_name = 'NINOSHVILI'),
1,
(select max(rental_id) from public.rental
where customer_id = (select customer_id from public.customer
where first_name = 'TATIA' and last_name = 'NINOSHVILI')
and rental_date = '2017-03-01 10:00:00'),
4.99, '2017-03-01 10:00:00';

insert into public.payment (customer_id, staff_id, rental_id, amount, payment_date)
select
(select customer_id from public.customer
where first_name = 'TATIA' and last_name = 'NINOSHVILI'),
1,
(select max(rental_id) from public.rental
where customer_id = (select customer_id from public.customer
where first_name = 'TATIA' and last_name = 'NINOSHVILI')
and rental_date = '2017-04-01 14:00:00'),
9.99, '2017-04-01 14:00:00';

insert into public.payment (customer_id, staff_id, rental_id, amount, payment_date)
select
(select customer_id from public.customer
where first_name = 'TATIA' and last_name = 'NINOSHVILI'),
1,
(select max(rental_id) from public.rental
where customer_id = (select customer_id from public.customer
where first_name = 'TATIA' and last_name = 'NINOSHVILI')
and rental_date = '2017-05-01 16:00:00'),
19.99, '2017-05-01 16:00:00';

COMMIT;