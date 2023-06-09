CREATE DATABASE instd;

CREATE TABLE users(
`id` INT PRIMARY KEY,
`username` VARCHAR(30) NOT NULL UNIQUE, 
`password` VARCHAR(30) NOT NULL, 
`email` VARCHAR(50) NOT NULL,  
`gender` CHAR NOT NULL, 
`age` INT NOT NULL, 
`job_title` VARCHAR(40) NOT NULL, 
`ip` VARCHAR(30) NOT NULL
);

CREATE TABLE addresses (
`id` INT PRIMARY KEY AUTO_INCREMENT, 
`address` VARCHAR(30)  NOT NULL, 
`town` VARCHAR(30)  NOT NULL, 
`country` VARCHAR(30)  NOT NULL,
`user_id` INT NOT NULL,
CONSTRAINT fk_addresses_users
FOREIGN KEY (user_id)
REFERENCES users(id)
); 

CREATE TABLE photos (
`id` INT PRIMARY KEY AUTO_INCREMENT, 
`description` TEXT NOT NULL, 
`date` DATETIME NOT NULL, 
`views` INT NOT NULL DEFAULT 0
);

CREATE TABLE comments(
`id` INT PRIMARY KEY AUTO_INCREMENT, 
`comment` VARCHAR(255) NOT NULL, 
`date` DATETIME NOT NULL,
`photo_id` INT NOT NULL,
CONSTRAINT fk_comments_photos
FOREIGN KEY (photo_id)
REFERENCES photos(id)
);

CREATE TABLE users_photos(
`user_id` INT NOT NULL, 
`photo_id` INT NOT NULL,
CONSTRAINT fk_users_photos
FOREIGN KEY (user_id)
REFERENCES users(id),
CONSTRAINT fk_photos_users
FOREIGN KEY (photo_id)
REFERENCES photos(id)
);

CREATE TABLE likes(
`id` INT PRIMARY KEY AUTO_INCREMENT, 
`photo_id` INT,
`user_id` INT,
CONSTRAINT fk_likes_photos
FOREIGN KEY (photo_id)
REFERENCES photos(id),
CONSTRAINT fk_likes_users
FOREIGN KEY (user_id)
REFERENCES users(id)
);

# 2.Insert
INSERT INTO `addresses` (`address`, `town`, `country`, `user_id`)
SELECT u.`username` , u.`password`, u.`ip`, u.`age`
FROM `users` AS u
WHERE u.`gender` = 'M';

# 3.Update
UPDATE `addresses`
SET `country` = (
CASE
WHEN `country` LIKE 'B%' THEN `country` = 'Blocked'
WHEN `country` LIKE 'T%' THEN `country` = 'Test'
WHEN `country` LIKE 'P%' THEN `country` = 'In Progress'
ELSE `country`
END);

# 4.Delete
DELETE FROM `addresses`
WHERE `id` / 3;

# 5.Users
SELECT username ,gender, age
FROM `users`
ORDER BY age DESC, username;

# 06. Extract 5 Most Commented Photos
SELECT p.id, p.`date` AS date_and_time , p.`description`, COUNT(photo_id) AS `commentsCount`
FROM `photos` AS p
JOIN `comments` 
ON p.id = comments.photo_id
GROUP BY p.id
ORDER BY `commentsCount` DESC, p.`id`
LIMIT 5;

# 07. Lucky Users
SELECT CONCAT(`id` , ' ', `username`) AS `id_username` , `email`
FROM `users`
JOIN `users_photos` AS up
ON users.`id` = up.`user_id`
WHERE users.`id` = up.`photo_id`
ORDER BY users.`id`;

# 08. Count Likes and Comments
SELECT p.`id` AS `photo_id`, COUNT(DISTINCT l.`id`) AS `likes_count`, COUNT(DISTINCT  c.`id`) AS `comments_count`
FROM `photos` AS p
left JOIN `likes` AS l
ON l.`photo_id` = p.`id`
 left JOIN `comments` AS c
ON c.`photo_id` = p.`id`
GROUP BY p.`id`
ORDER BY `likes_count` DESC,  `comments_count` DESC, `photo_id`;

# 09. The Photo on the Tenth Day of the Month
SELECT CONCAT(SUBSTR(description,1,30), '...') AS `summary`, `date`
FROM `photos`
WHERE DAY(`date`) = 10
ORDER BY `date` DESC;
Database Basics MySQL Retake Exam - 31 March 2020 Judge Link

#10. Get user’s photos count
DELIMITER %%
CREATE FUNCTION udf_users_photos_count(username VARCHAR(30)) 
RETURNS INT
DETERMINISTIC
BEGIN
RETURN (SELECT count(*) 
FROM users AS u
JOIN users_photos AS up ON  u.id = up.user_id
WHERE u.username = username);
END
%%

# 11. Increase User Age
DELIMITER %%
CREATE PROCEDURE udp_modify_user(`address` VARCHAR(30),`town` VARCHAR(30))
BEGIN
  IF((SELECT a.address 
	FROM addresses AS a 
	WHERE address = a.address) IS NOT NULL)
    THEN UPDATE users AS u
		JOIN addresses AS aa ON u.id = aa.user_id
    SET u.age = u.age + 10
    WHERE aa.address = address AND aa.town = town;
    END IF;
    END
    %%
    
