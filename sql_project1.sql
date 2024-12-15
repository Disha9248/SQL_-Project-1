-- SQL Mini Project 
-- SQL Mentor User Performance Analysis

-- DROP TABLE user_submissions; 

CREATE TABLE user_submissions (
    id SERIAL PRIMARY KEY,
    user_id BIGINT,
    question_id INT,
    points INT,
    submitted_at TIMESTAMP WITH TIME ZONE,
    username VARCHAR(50)
);

SELECT * FROM user_submissions;


-- Q.1 List all distinct users and their stats (return user_name, total_submissions, points earned)
-- Q.2 Calculate the daily average points for each user.
-- Q.3 Find the top 3 users with the most positive submissions for each day.
-- Q.4 Find the top 5 users with the highest number of incorrect submissions.
-- Q.5 Find the top 10 performers for each week.


-- -------------------
-- My Solutions
-- -------------------

-- Q.1 List all distinct users and their stats (return user_name, total_submissions, points earned)

-- SELECT COUNT(DISTINCT username)
-- FROM user_submissions;

SELECT username,
       COUNT(question_id) AS total_submissions,
       SUM(points) AS points_earned
FROM 
     user_submissions
GROUP BY 
      username
ORDER BY 
      total_submissions DESC;


-- Q.2 Calculate the daily average points for each user.

SELECT TO_CHAR(submitted_at,'dd-mm') AS day,
       username,
       ROUND(AVG(points),2) AS average_points
FROM 
     user_submissions
GROUP BY 
     day,username;


-- Q.3 Find the top 3 users with the most correct submissions for each day.

WITH daily_positive_submissions AS (
	SELECT username, 
	       TO_CHAR(submitted_at,'dd-mm') AS day,
		SUM(CASE 
			 WHEN points > 0 THEN 1 
			 ELSE 0
		    END) AS correct_submissions
	FROM 
	    user_submissions
	GROUP BY 
	    username,day
	ORDER BY 
	    correct_submissions DESC
)

SELECT day,username,correct_submissions,rank 
FROM (
    SELECT 
        day, 
        username, 
        correct_submissions, 
        RANK() OVER (PARTITION BY day ORDER BY correct_submissions DESC) AS rank
    FROM 
        daily_positive_submissions
) ranked_users
WHERE 
    rank <= 3
ORDER BY 
    day, rank;


-- Q.4 Find the top 5 users with the highest number of incorrect submissions.

SELECT username, 
	SUM(CASE 
	      WHEN points < 0 THEN 1 
		  ELSE 0
	    END) AS incorrect_submissions
FROM 
    user_submissions
GROUP BY 
    username
ORDER BY 
    incorrect_submissions DESC
LIMIT 5;


-- Q.5 Find the top 10 performers for each week.

WITH top_performers AS (
SELECT username,SUM(points)AS performance,
       EXTRACT(week from submitted_at) AS week
FROM 
     user_submissions
GROUP BY 
        username,week
ORDER BY 
        performance DESC
)

SELECT username,performance,week,rank
FROM (
       SELECT username, performance, week,
	          RANK()OVER(PARTITION BY week ORDER BY performance DESC)AS rank
	   FROM top_performers
)
WHERE 
    rank <= 10
ORDER BY 
    week, rank;
