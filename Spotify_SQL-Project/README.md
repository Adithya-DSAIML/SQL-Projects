# Spotify_Project

## Overview

This document serves as a comprehensive guide to exploring and analyzing the Spotify dataset, sourced from Kaggle. The dataset contains detailed metadata about tracks, including information on artists, albums, track characteristics, streaming platforms, and user engagement metrics such as views, likes, and comments.

The README is structured as follows:

**Dataset Information**: Basic details about the dataset source and content.  

**Table Structure**: Schema of the spotify table, describing its columns and data types.

**Exploratory Data Analysis (EDA)**: Queries designed to extract general statistics and insights about the dataset, such as the number of unique artists, album types, and track durations.  

**Analytical Queries**: Advanced SQL queries addressing specific questions, including the most-streamed tracks, energy analysis, cumulative engagement metrics, and window function applications for ranking and aggregation.  

This guide is intended to help users explore the dataset effectively and derive meaningful insights for music trend analysis, streaming platform comparisons, and user behavior patterns.

## Dataset Information

The dataset contains information about Spotify tracks, including attributes like artist, album, track name, views, likes, comments, and various audio features such as danceability, energy, loudness, and more.

## Table Structure

```sql
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
```

## Queries

After the table and the dataset are created various SQL queries can be written to explore and analyze the data. Queries are categorized into easy, medium, and advanced levels, as we progress the difficulty also increases.

### 1. Basic Data Exploration

**Total rows in the Dataset**
```sql
select count(*) as nbr_of_rows from spotify;
```

**Total Artist in the dataset**
```sql
select count(distinct artist) from spotify;
```

**Total Albums**
```sql
select count(distinct album) from spotify;
```

**Total Album Types**
```sql
select distinct album_type from spotify;
```

**Max and Min song duration**
```sql
select max(duration_min) as duration from spotify;
select min(duration_min) as duration from spotify;
```

**Deleting Tracks with 0 duration**
```sql
select * from spotify where duration_min = 0
Delete from spotify
where duration_min = 0;
```

**Count of unique various channels**
```sql
select distinct channel from spotify
select count(distinct channel) from spotify
```

**Platforms where tracks were played**
```sql
select distinct most_played_on from spotify
```

### Analytical Questions and Queries
**Q1.Retrieve the names of all tracks that have more than 1 billion streams.**
```sql
select track from spotify where stream > 1000000000;
```

**Q2.List all albums along with their respective artists.**
```sql
select distinct album, artist from spotify;
```

**Q3.Get the total number of comments for tracks where licensed = TRUE.**
```sql
select track,sum(comments) from spotify where licensed = true
group by 1;
```

**Q4.Find all tracks that belong to the album type single.**
```sql
select track from spotify where album_type = 'single'
```

**Q5.Count the total number of tracks by each artist.**
```sql
select artist, count(track) as nbr_of_track from spotify
group by 1;
```

**Q6.Calculate the average danceability of tracks in each album.**
```sql
select album, avg(danceability) as average_danceability from spotify
group by 1
order by average_danceability desc;
```

**Q7.Find the top 5 tracks with the highest energy values.**
```sql
with cte as (
select distinct track, energy, dense_rank() over(order by energy desc) as ranks from spotify
order by energy desc)
select track from cte where ranks <= 5
```

**Q8.List all tracks along with their views and likes where official_video = TRUE.**
```sql
select track, sum(views) as totol_views,sum(likes) as total_likes from spotify
where official_video = true
group by 1;
```

**Q9.For each album, calculate the total views of all associated tracks.**
```sql
select album, sum(views) as total_views from spotify
group by 1
order by total_views desc;
```

**Q10.Retrieve the track names that have been streamed on Spotify more than YouTube.**
```sql
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
```

**Q11.Find the top 3 most-viewed tracks for each artist using window functions.**
```sql
with cte as (
select artist,track,sum(views),dense_rank() over(partition by artist order by sum(views) desc) as ranks from spotify
group by 1,2
)
select artist,track,ranks from cte where ranks <=3;
```

**Q12.Write a query to find tracks where the liveness score is above the average.**
```sql
select track from spotify where liveness > (select avg(liveness) from spotify);
```

**Q13.Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.**
```sql
with cte as
(select album, max(energy) as max_energy,min(energy) as min_energy from spotify 
group by 1)

select album, (max_energy-min_energy) as energy_diff from cte
order by 2 desc;
```

**Q14.Find tracks where the energy-to-liveness ratio is greater than 1.2.**
```sql
select track, (energy/liveness) as energy_to_liveness from spotify
group by track,energy,liveness
having (energy/liveness) > 1.2
```

**Q15.Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.**
```sql
select track, views, likes, sum(likes) over(order by views desc) from spotify
order by 2 desc;
```

## Findings

**Total Rows**: The dataset contains a total of 20592 rows.  
**Unique Artists**: There are 2074 distinct artists represented in the dataset.  
**Albums**: The dataset includes 11853 unique albums with different album types such as singles, compilations, and albums.  
**Channels**: Tracks are associated with unique platforms such as Youtube and Spotify.  
**Track Popularity**: A total of 384 tracks have more than 1 billion streams, indicating their high popularity globally.  
**Licensed Tracks**: 12321 Tracks were licensed enabled.  
**Duration**: The shortest track is Steven Universe Future with a duration of 0.5 minutes, while the longest is Highest rated Gabru 52 Non Stop Hits with 78 minutes.  
**Number of Track by each artist**: The maximum number of tracks by each is 10
**Energy-To-Liveness**: There are a total of 17108 track where Energy-To-Liveness ratio is greater 1.2.
**Streamed on Spotify**: A total of 155 tracks streamed more on Spotify than Youtube.

## How to Use

Clone the Repository: Clone this repository to your local machine.
```sh
https://github.com/Adithya-DSAIML/Spotify_Project
```

Run the Queries: Setup the Database and use the SQL queries in the Spotify.sql file to perform the analysis.

Explore and Modify: Customize the queries as needed to explore different aspects of the data or to answer additional questions.

## Author - Adithya Anand

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions or feedback - feel free to reach out to me via LinkedIn : www.linkedin.com/in/adithyanand

