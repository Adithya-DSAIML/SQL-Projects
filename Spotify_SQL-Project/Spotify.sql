-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

select * from spotify

--- EDA

-- No. of rows in the Dataset
select count(*) as nbr_of_rows from spotify;

-- No. of artists in the dataset
select count(distinct artist) from spotify;

-- No. of Albums
select count(distinct album) from spotify;

-- Album Types
select distinct album_type from spotify;

-- Max and Min durations of songs
select max(duration_min) as duration from spotify;
select min(duration_min) as duration from spotify;

-- Checking for tracks with 0 min duration and deleting them.
select * from spotify where duration_min = 0

Delete from spotify
where duration_min = 0;

select * from spotify where duration_min = 0;

-- Various Channels
select distinct channel from spotify
select count(distinct channel) from spotify


-- Various platforms tracks played on
select distinct most_played_on from spotify

--Q1.Retrieve the names of all tracks that have more than 1 billion streams.
select track from spotify where stream > 1000000000;

--Q2.List all albums along with their respective artists.
select distinct album, artist from spotify;

--Q3.Get the total number of comments for tracks where licensed = TRUE.
select track,sum(comments) from spotify where licensed = true
group by 1;

--Q4.Find all tracks that belong to the album type single.
select track from spotify where album_type = 'single' 

--Q5.Count the total number of tracks by each artist.
select artist, count(track) as nbr_of_track from spotify
group by 1;

--Q6.Calculate the average danceability of tracks in each album.
select album, avg(danceability) as average_danceability from spotify
group by 1
order by average_danceability desc;

--Q7.Find the top 5 tracks with the highest energy values.
with cte as (
select distinct track, energy, dense_rank() over(order by energy desc) as ranks from spotify
order by energy desc)
select track from cte where ranks <= 5

--Q8.List all tracks along with their views and likes where official_video = TRUE.
select track, sum(views) as totol_views,sum(likes) as total_likes from spotify
where official_video = true
group by 1

--Q9.For each album, calculate the total views of all associated tracks.
select album, sum(views) as total_views from spotify
group by 1
order by total_views desc

--Q10.Retrieve the track names that have been streamed on Spotify more than YouTube.
select * from 
(
select track,
coalesce(sum(case when most_played_on = 'Youtube' then stream END),0) as streamed_on_Youtube,
coalesce(sum(case when most_played_on = 'Spotify' then stream END),0) as streamed_on_Spotify
from spotify
group by 1
) as t1
where
streamed_on_Spotify > streamed_on_Youtube and streamed_on_Youtube != 0

--Q11.Find the top 3 most-viewed tracks for each artist using window functions.
with cte as (
select artist,track,sum(views),dense_rank() over(partition by artist order by sum(views) desc) as ranks from spotify
group by 1,2
)
select artist,track,ranks from cte where ranks <=3

--Q12.Write a query to find tracks where the liveness score is above the average.
select track from spotify where liveness > (select avg(liveness) from spotify)

--Q13.Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
with cte as
(select album, max(energy) as max_energy,min(energy) as min_energy from spotify 
group by 1)

select album, (max_energy-min_energy) as energy_diff from cte
order by 2 desc;

--Q14.Find tracks where the energy-to-liveness ratio is greater than 1.2.
select track, (energy/liveness) as energy_to_liveness from spotify
group by track,energy,liveness
having (energy/liveness) > 1.2

--Q15.Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
select track, views, likes, sum(likes) over(order by views desc) from spotify
order by 2 desc




















