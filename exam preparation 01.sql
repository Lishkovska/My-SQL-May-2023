CREATE SCHEMA `softuni_imdb`;

CREATE TABLE `countries` (
`id` INT Primary Key AUTO_INCREMENT,
`name` VARCHAR(30) NOT NULL UNIQUE,
`continent` VARCHAR(30) NOT NULL,
`currency` VARCHAR(5) NOT NULL
);

CREATE TABLE `genres` (
`id` INT Primary Key AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE `actors` (
`id` INT Primary Key AUTO_INCREMENT,
`first_name` VARCHAR(50) NOT NULL,
`last_name` VARCHAR(50) NOT NULL,
`birthdate` DATE NOT NULL,
`height` INT,
`awards` INT,
`country_id` INT NOT NULL,
CONSTRAINT fk_actors_countries
FOREIGN KEY (`country_id`)
REFERENCES `countries` (`id`)
);

CREATE TABLE `movies_additional_info`(
`id` INT Primary Key AUTO_INCREMENT,
`rating` DECIMAL(10,2) NOT NULL,
`runtime` INT NOT NULL,
`picture_url` VARCHAR(80) NOT NULL,
`budget` DECIMAL(10,2),
`release_date` DATE NOT NULL,
`has_subtitles` TINYINT(1),
`description` TEXT
);

CREATE TABLE `movies`(
`id` INT Primary Key AUTO_INCREMENT,
`title` VARCHAR(70) UNIQUE NOT NULL,
`country_id` INT NOT NULL,
`movie_info_id` INT NOT NULL UNIQUE,
CONSTRAINT fk_movies_countries
FOREIGN KEY (`country_id`)
REFERENCES `countries` (`id`),
CONSTRAINT fk_movies_movies_additional_info
FOREIGN KEY (`movie_info_id`)
REFERENCES `movies_additional_info`(`id`)
);

CREATE TABLE `movies_actors` (
`movie_id` INT,
`actor_id` INT,
CONSTRAINT fk_movies_actors_movies
FOREIGN KEY (`movie_id`)
REFERENCES `movies` (`id`),
CONSTRAINT fk_movies_actors_actors
FOREIGN KEY (`actor_id`)
REFERENCES `actors` (`id`)
);

CREATE TABLE `genres_movies` (
`genre_id` INT,
`movie_id` INT,
CONSTRAINT fk_movies_genres_movies
FOREIGN KEY (`genre_id`)
REFERENCES `genres` (`id`),
CONSTRAINT fk_movies_movies
FOREIGN KEY (`movie_id`)
REFERENCES `movies` (`id`)
);



# 2. Insert
INSERT INTO `actors` (`first_name`, `last_name`, `birthdate` ,`height`, `awards`, `country_id`)
SELECT (REVERSE(`first_name`)), (REVERSE(`last_name`)) , (subdate(`birthdate`, 2)) , (`height` + 10), (`country_id`)
, (3)
FROM `actors`
WHERE `id` <= 10;

# 3.Update
UPDATE `movies_additional_info` AS mai
SET `runtime` = `runtime` - 10
WHERE  `id` BETWEEN 15 AND 25;

# 4.Delete
DELETE c FROM `countries` AS c
LEFT JOIN `movies` AS m
ON c.`id` = m.`country_id`
WHERE m.`country_id` IS NULL;


# 05. Countries
SELECT `id`, `name`, `continent` ,`currency`
FROM `countries`
ORDER BY `currency` DESC , `id`;

# 06. Old movies
SELECT mai.`id` , m.`title`, mai.`runtime`, mai.`budget`, mai.`release_date`
FROM `movies_additional_info` AS mai
JOIN `movies` AS m
ON m.`movie_info_id` = mai.`id`
WHERE YEAR(mai.release_date) BETWEEN 1996 AND 1999
ORDER BY mai.`runtime` , `id`
LIMIT 20;

# 07. Movie casting
SELECT CONCAT(`first_name`," " ,`last_name`) AS `full_name` , CONCAT(REVERSE(`last_name`), char_length(`last_name`),
'@cast.com') AS `email` , 2022 - YEAR(`birthdate`) AS age , `height`
FROM `actors` 
WHERE `id` NOT IN (SELECT `actor_id` FROM `movies_actors`)
ORDER BY `height`;

# 08. International festival
SELECT c.`name` , COUNT(m.`title`) AS `movies_count`
FROM `countries` AS c
JOIN `movies` AS m
ON c.`id` =  m.`country_id`
GROUP BY m.`country_id`
HAVING `movies_count` >= 7
ORDER BY c.`name` DESC;

# 09. Rating system
SELECT m.`title` , 
CASE 
WHEN mai.`rating` <= 4 THEN 'poor'
WHEN mai.`rating` <= 7 THEN 'good'
ELSE'excellent'
END AS `rating`,
CASE 
WHEN mai.`has_subtitles` = 1
THEN 'english'
ELSE '-'
END
AS `subtitles`
,
 mai.`budget`
FROM `movies` AS m
JOIN `movies_additional_info` AS mai
ON m.`movie_info_id` = mai.`id`
ORDER BY mai.`budget` DESC;

# 10. History movies
DELIMITER %%
CREATE FUNCTION udf_actor_history_movies_count(full_name VARCHAR(50))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE movies_count INT;
    SET movies_count := (
    SELECT  COUNT(g.`name`) AS movies_count
    FROM `actors` AS a
    JOIN `movies_actors` AS ma
    ON ma.`actor_id` = a.`id`
    JOIN `movies` AS m
    ON ma.`movie_id` = m.`id`
    JOIN `genres_movies` AS gm
    ON gm.`movie_id` =  m.`id`
    JOIN `genres` AS g
    ON gm.`genre_id` = g.`id`
    WHERE g.`name` = 'History' AND full_name = CONCAT(a.`first_name`, ' ', `last_name`)
    GROUP BY g.`name`);
    RETURN movies_count;
END
%%

# 11. Movie awards
DELIMITER %%
CREATE PROCEDURE udp_award_movie(movie_title VARCHAR(50))
    BEGIN
       UPDATE `actors` AS a
       JOIN `movies_actors` AS ma
    ON ma.`actor_id` = a.`id`
    JOIN `movies` AS m
    ON ma.`movie_id` = m.`id`
    SET a.`awards` = a.`awards` + 1
    WHERE m.`title` = movie_title;
    END
    %%


