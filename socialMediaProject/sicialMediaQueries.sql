-- 1. Identify the most liked type of media (photo or video)

SELECT 'photo' AS media_type,
	COUNT(post_likes.user_id) AS like_count 
FROM post_likes
JOIN photos
ON photos.post_id=post_likes.post_id
UNION ALL
SELECT 'video' AS media_type,
	COUNT(post_likes.user_id) AS like_count
FROM post_likes
JOIN videos
ON videos.post_id=post_likes.post_id
ORDER BY like_count DESC

-- 2. Find the Top 3 Most Commented Posts for Each User
WITH PostCommentCounts AS (
    SELECT 
        p.user_id, 
        p.post_id, 
        p.caption, 
        COUNT(c.comment_id) AS comment_count
    FROM post p
    LEFT JOIN comments c ON p.post_id = c.post_id
    GROUP BY p.user_id, p.post_id, p.caption
),
RankedComments AS (
    SELECT 
        user_id, 
        post_id, 
        caption, 
        comment_count,
        RANK() OVER (PARTITION BY user_id ORDER BY comment_count DESC) AS rank
    FROM PostCommentCounts
)
SELECT 
    user_id, 
    post_id, 
    caption, 
    comment_count
FROM RankedComments
WHERE rank <= 3;
 
-- 3. Retrieve the top 10 users with the most followers

SELECT 
	users.user_id,
	users.username,
	COUNT(follows.followee_id) AS total_followers 
FROM follows
JOIN users
ON users.user_id=follows.followee_id
GROUP BY users.user_id,users.username
ORDER BY total_followers DESC
LIMIT 10;
	
-- 4. Find the users who liked the most posts

SELECT 
	users.user_id,
	users.username,
	COUNT(post_likes.user_id) AS  like_count 
FROM users
JOIN post_likes
ON users.user_id=post_likes.user_id
GROUP BY users.user_id,users.username
ORDER BY like_count DESC,users.user_id

-- 5 Calculate the average number of likes per post

WITH CTE AS(
	SELECT post.post_id,
		COUNT(post_likes.post_id) AS total_likes 
	FROM post
	LEFT JOIN post_likes
	ON post.post_id=post_likes.post_id
	GROUP BY post.post_id
	ORDER BY post.post_id
)

SELECT AVG(total_likes)::int FROM cte

-- 6. Find Mutual Followers Between Two Users
SELECT 
    f1.follower_id AS user1, 
    f2.follower_id AS user2
FROM follows f1
JOIN follows f2 
    ON f1.follower_id = f2.followee_id
   AND f1.followee_id = f2.follower_id
WHERE f1.follower_id <> f2.follower_id
order by user1;

-- 7. Find the Most Liked Post of All Time
SELECT 
    p.post_id, 
    p.caption, 
    COUNT(pl.user_id) AS total_likes
FROM post p
LEFT JOIN post_likes pl ON p.post_id = pl.post_id
GROUP BY p.post_id, p.caption
ORDER BY total_likes DESC
LIMIT 1;

-- 8. Calculate the Average Number of Posts per User
WITH CTE AS(
	SELECT u.user_id, 
        COUNT(p.post_id) AS post_count
    FROM users u
    LEFT JOIN post p ON u.user_id = p.user_id
    GROUP BY u.user_id)

SELECT AVG(post_count)::int FROM CTE


