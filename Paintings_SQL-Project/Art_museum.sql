--Q1.Fetch all the paintings which are not displayed on any museums?
SELECT distinct w.name
FROM works AS w
LEFT JOIN museum AS m
ON m.museum_id = w.museum_id
WHERE m.museum_id IS NULL;

--Q2.Are there museums without any paintings?
select m.name
from
museum as m
left join
works as w
on w.museum_id = m.museum_id
where w.work_id is NULL

--Q3.How many paintings have an asking price of more than their regular price?
select * from product_size
where sale_price > regular_price;


--Q4.Identify the paintings whose asking price is less than 50% of its regular price
select distinct w.name
from
works as w
left join
product_size as ps
on w.work_id = ps.work_id
where ps.sale_price < (regular_price/2)

--Q5.Which canva size costs the most?
select distinct c.label, p.regular_price from
canva_size as c
join
product_size as p
on c.size_id = p.size_id
order by p.regular_price desc
limit 1

--Q6.Delete duplicate records from work, product_size, subject and image_link tables
delete from works 
where ctid not in (select min(ctid) from works
group by work_id );

delete from product_size 
where ctid not in (select min(ctid) from product_size
group by work_id, size_id );

delete from subject 
where ctid not in (select min(ctid) from subject
group by work_id, subject );

delete from image_link 
where ctid not in (select min(ctid) from image_link
group by work_id );

--Q7.Identify the museums with invalid city information in the given dataset
select * from museum 
where city ~'[0-9]'

--Q8.Museum_Hours table has 1 invalid entry. Identify it and remove it.
delete from museum_hours 
where ctid not in (select min(ctid)
from museum_hours
group by museum_id, day );

--Q9.Fetch the top 10 most famous painting subject
select subject, nbr_of_painting  from (
select s.subject, count(*) as nbr_of_painting, dense_rank() over(order by count(*) desc) as rnk from
works as w
join
subject as s
on s.work_id = w.work_id
group by 1) x 
where rnk<= 10

--Q10.Identify the museums which are open on both Sunday and Monday. Display museum name, city.
select distinct m.name, m.city from
museum as m
join
museum_hours as mh
on mh.museum_id = m.museum_id
where mh.day = 'Sunday' or mh.day = 'Monday'
group by m.name,m.city
having count(distinct mh.day) = 2

--Q11.How many museums are open every single day?
select m.name from
museum as m
join
museum_hours as mh
on mh.museum_id = m.museum_id
where mh.day in ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday')
group by m.name, m.museum_id
having count(distinct mh.day)=7

--Q12.Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)
select m.museum_id, m.name, count(w.name) as nbr_of_painting
from
museum as m
left join
works as w
on m.museum_id = w.museum_id
group by 1,2
order by nbr_of_painting desc
limit 5

--Q13.Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)
select a.full_name, count(w.work_id) as nbr_of_painting from
artist as a
left join
works as w
on a.artist_id = w.artist_id
group by 1
order by nbr_of_painting desc
limit 5;

--Q14.Display the 3 least popular canva sizes
with cte as (
select c.label, count(w.work_id) as nbr_of_painting, dense_rank() over(order by count(w.work_id) asc) as rnk
from
canva_size as c
left join
product_size as ps
on c.size_id = ps.size_id
join
works as w
on ps.work_id = w.work_id
group by 1)

select label, nbr_of_painting from cte where rnk <=3

--Q15.Which museum is open for the longest during a day. Dispay museum name, city and hours open and which day?
select m.museum_id,m.name, m.city,(mh.close - mh.open) as time_diff, mh.day from
museum as m
left join
museum_hours as mh
on m.museum_id = mh.museum_id
order by (mh.close - mh.open) desc
limit 1


--Q16.Which museum has the most no of most popular painting style?
select m.name as museum_name, count(*) as nbr_of_painting from
museum as m
left join
works as w
on m.museum_id = w.museum_id
where w.style = (select style from works
group by 1
order by count(*) desc
limit 1)
group by 1
order by nbr_of_painting desc
limit 1;

--Q17.Identify the artists whose paintings are displayed in multiple countries
select a.full_name as artist_name,count(distinct m.country) as nbr_of_countries from
artist as a
left join
works as w
on a.artist_id = w.artist_id
left join
museum as m
on m.museum_id = w.museum_id
group by 1
having count(distinct m.country) > 1
order by nbr_of_countries desc, a.full_name

--Q18.Display the country and the city with most no of museums. Output 2 seperate columns to mention the city and country. 
--If there are multiple value, seperate them with comma.
with cte1 as(
select country, city, count(*) as nbr_of_museum from
museum
group by 1,2
order by 3 desc)

select string_agg(country,','),string_agg(city,','), max(nbr_of_museum) from cte1
where nbr_of_museum = (select max(nbr_of_museum) from cte1)

--Q19.Identify the artist and the museum where the most expensive and least expensive painting is placed. 
--Display the artist name, sale_price, painting name, museum name, museum city and canvas label
select a.full_name , p.sale_price, w.name as painting_name, m.name as museum_name,
m.city as city_name ,c.label as canvas_label from
works as w
left join product_size as p
on w.work_id = p.work_id
left join artist as a
on a.artist_id = w.artist_id
left join museum as m
on m.museum_id = w.museum_id
left join canva_size as c
on c.size_id = p.size_id
where (p.sale_price) in 
(select max(sale_price) from product_size
union
select min(sale_price) from product_size)
order by p.sale_price desc

--Q20.Which country has the 5th highest no of paintings?
with cte as (
select m.country , count(w.name) as nbr_of_painting,dense_rank() over(order by count(w.name) desc) as rnk from
works as w
left join museum as m
on w.museum_id = m.museum_id
group by 1
)
select country, nbr_of_painting from cte where rnk = 5


--Q21.Which are the 3 most popular and 3 least popular painting styles?
with cte as (
select style, count(*) as painting_style_cnt, dense_rank() over(order by count(*) desc) as rnk, 
count(style) over() as no_of_records
from works
where style is not NULL
group by 1)

select style,
case when rnk <= 3 then 'Most Popular painting style' else 'Least Popular painting style' end as remarks
from cte
where rnk <=3 or rnk > no_of_records - 3

--Q22.Which artist has the most no of Portraits paintings outside USA?. 
--Display artist name, no of paintings and the artist nationality.
with cte as (
select a.full_name as artist_name, count(w.name) as nbr_of_painting, a.nationality,
dense_rank() over(order by count(w.name) desc) as rnk from
artist as a
left join
works as w
on a.artist_id = w.artist_id
left join
subject as s
on s.work_id = w.work_id
left join museum as m
on m.museum_id = w.museum_id
where m.country != 'USA' and s.subject = 'Portraits'
group by 1,3
order by nbr_of_painting desc)
select artist_name,nationality,nbr_of_painting from cte where rnk = 1
