--Combine data from monthly sheets into one table allmonths by using the union function and needed columns

SELECT rideable_type, started_at, ended_at, start_station_name, end_station_name, member_casual 
	INTO  allmonths
FROM
(
	SELECT rideable_type, started_at, ended_at, start_station_name, end_station_name, member_casual FROM dbo.april
		UNION ALL
	SELECT rideable_type, started_at, ended_at, start_station_name, end_station_name, member_casual FROM dbo.august1
		UNION ALL
	SELECT rideable_type, started_at, ended_at, start_station_name, end_station_name, member_casual FROM dbo.august2
		UNION ALL
	SELECT rideable_type, started_at, ended_at, start_station_name, end_station_name, member_casual FROM dbo.dbojuly2
		UNION ALL
	SELECT rideable_type, started_at, ended_at, start_station_name, end_station_name, member_casual FROM dbo.december	
		UNION ALL
	SELECT rideable_type, started_at, ended_at, start_station_name, end_station_name, member_casual FROM dbo.february
		UNION ALL
	SELECT rideable_type, started_at, ended_at, start_station_name, end_station_name, member_casual FROM dbo.january
		UNION ALL
	SELECT rideable_type, started_at, ended_at, start_station_name, end_station_name, member_casual FROM dbo.july1
		UNION ALL
	SELECT rideable_type, started_at, ended_at, start_station_name, end_station_name, member_casual FROM dbo.june1
		UNION ALL
	SELECT rideable_type, started_at, ended_at, start_station_name, end_station_name, member_casual FROM dbo.june2
		UNION ALL
	SELECT rideable_type, started_at, ended_at, start_station_name, end_station_name, member_casual FROM dbo.march
		UNION ALL
	SELECT rideable_type, started_at, ended_at, start_station_name, end_station_name, member_casual FROM dbo.may
		UNION ALL
	SELECT rideable_type, started_at, ended_at, start_station_name, end_station_name, member_casual FROM dbo.november	
		UNION ALL
	SELECT rideable_type, started_at, ended_at, start_station_name, end_station_name, member_casual FROM dbo.october
		UNION ALL
	SELECT rideable_type, started_at, ended_at, start_station_name, end_station_name, member_casual FROM dbo.september
) a;


--Find how many total rides have been taken by members and casual riders in a one year period

SELECT 
	member_casual,
	COUNT(*) AS total_rides
FROM 
	dbo.allmonths
GROUP BY member_casual;




--Upon running running query, found an incorrect entry in the member_casual coulmn.  Queried the specific data to find a duplicated line of headers.

SELECT * FROM dbo.allmonths
WHERE member_casual = 'member_casual'


--Add a WHERE clause to exclude rows that have null values in start station, end station name, or that have an invalid rider type

SELECT 
	member_casual,
	COUNT(*) AS total_rides
FROM 
	dbo.allmonths
WHERE 
	start_station_name IS NOT NULL
	AND
	end_station_name IS NOT NULL
	AND member_casual <> 'member_casual'
GROUP BY member_casual;




--Find the total rides for members and casual riders per month
--Findings reveal a drastic increase of riders during the warm summer months for each type of rider
--Casual riders decline heavily during the coldest winter months.

SELECT 
	DATEPART(mm,started_at) AS month_of_year,
	COUNT(*) AS total_rides,
	COUNT(CASE
		WHEN member_casual = 'member' THEN started_at
	END
		) AS member_rides,
	COUNT(CASE
		WHEN member_casual = 'casual' THEN started_at
	END
		) AS casual_rides
FROM
	dbo.allmonths
WHERE 
	start_station_name IS NOT NULL
	AND
	end_station_name IS NOT NULL
	AND member_casual <> 'member_casual'
GROUP BY 
	DATEPART(mm,started_at)
ORDER BY
	DATEPART(mm,started_at);


--What is the percentage of member vs. casual rides of the total rides for one year

SELECT
	member_casual,
	COUNT(*)*100 / (
	SELECT	
		COUNT(*)
	FROM dbo.allmonths) AS percent_rides
FROM 
	dbo.allmonths
WHERE 
	start_station_name IS NOT NULL
	AND
	end_station_name IS NOT NULL
	AND member_casual <> 'member_casual'
GROUP BY member_casual;




--What types of bikes does each rider type prefer?
--Find total rides of eack bike type per rider type

SELECT 
	rideable_type,
	COUNT(*) AS ride_counts,
	member_casual
FROM
	dbo.allmonths
WHERE 
	start_station_name IS NOT NULL
	AND
	end_station_name IS NOT NULL
	AND rideable_type <> 'rideable_type'
	GROUP BY 
	rideable_type,
	member_casual
ORDER BY 
	member_casual,
	ride_counts DESC;



--What is the average ride duration by rider type by month?

SELECT 
	DATEPART(mm,started_at) AS Month_of_year,
	member_casual,
	AVG(DATEDIFF(minute,started_at, ended_at)) AS avg_trip_duration
FROM	
	dbo.allmonths
WHERE 
	start_station_name IS NOT NULL
	AND
	end_station_name IS NOT NULL
	AND member_casual <> 'member_casual'
GROUP BY
	DATEPART(mm,started_at),
	member_casual
ORDER BY 
	DATEPART(mm,started_at);
	



--Find the top 10 start stations used by members

SELECT 
	TOP(10)
	start_station_name,
	COUNT(*) AS num_trips,
	member_casual
FROM 
	dbo.allmonths
WHERE 
	start_station_name IS NOT NULL
	AND
	end_station_name IS NOT NULL
	AND member_casual = 'member'
GROUP BY
	start_station_name,
	member_casual
ORDER BY
	num_trips DESC;




--Find the top 10 start stations used by casual riders

SELECT 
	TOP(10)
	start_station_name,
	COUNT(*) AS num_trips,
	member_casual
FROM 
	dbo.allmonths
WHERE 
	start_station_name IS NOT NULL
	AND
	end_station_name IS NOT NULL
	AND member_casual = 'casual'
GROUP BY
	start_station_name,
	member_casual
ORDER BY
	num_trips DESC;



--Find the top 5 end stations used by members

SELECT 
	TOP(5)
	end_station_name,
	COUNT(*) AS num_trips,
	member_casual
FROM 
	dbo.allmonths
WHERE 
	start_station_name IS NOT NULL
	AND
	end_station_name IS NOT NULL
	AND member_casual = 'member'
GROUP BY
	end_station_name,
	member_casual
ORDER BY
	num_trips DESC;




--Find the top 5 end stations used by casual riders

SELECT 
	TOP(5)
	end_station_name,
	COUNT(*) AS num_trips,
	member_casual
FROM 
	dbo.allmonths
WHERE 
	start_station_name IS NOT NULL
	AND
	end_station_name IS NOT NULL
	AND member_casual = 'casual'
GROUP BY
	end_station_name,
	member_casual
ORDER BY
	num_trips DESC;



--Verify the current day of week 
--5/2/2023 is Tuesday, results of 3 for weekday therefore 1=Sunday, 2=Monday...7=Saturday

SELECT DATEPART(dw,'2023/05/02')

--Vefify dates in data match the weekday
--Select started_at dates for datepart dw of 2, picked a date to query to verify with calendar
--Find weekday for 4/25/2022, which is a Monday, resulted in 2

SELECT DATEPART(DW,'2022-04-25')



--Find trends among both rider types based on the day of the week over a year.
--Select the total rides by members and casual riders by day of the week
--Results show that a significantly more members are riding during the week.  Casual riders only surpass members on Saturdays as a total.

SELECT
	DATEPART(DW,started_at) AS day_of_week,
	COUNT(*) AS total_rides,
	COUNT(CASE
		WHEN member_casual = 'member' THEN rideable_type
	END
		) AS member_rides,
	COUNT(CASE
		WHEN member_casual = 'casual' THEN rideable_type
	END
		) AS casual_rides
FROM
	dbo.allmonths
WHERE 
	start_station_name IS NOT NULL
	AND
	end_station_name IS NOT NULL
	AND member_casual <> 'member_casual'
GROUP BY
	DATEPART(DW,started_at)
ORDER BY
	DATEPART(DW,started_at);


SELECT
	DATEPART(hh,started_at) AS hour_of_day,
	COUNT(*)
FROM
	dbo.allmonths
WHERE 
	start_station_name IS NOT NULL
	AND
	end_station_name IS NOT NULL
	AND member_casual <> 'member_casual'
	AND DATEPART(DW,started_at) = 2
GROUP BY
	DATEPART(hh,started_at);

SELECT *
FROM dbo.allmonths
WHERE 
	start_station_name IS NOT NULL
	AND
	end_station_name IS NOT NULL
	AND member_casual <> 'member_casual'
	AND DATEPART(DW,started_at) = 1
	AND DATEPART(hh,started_at) = 0;





	






