CREATE SCHEMA fsd;
# Football Scout Database Database Basics MySQL Exam - 9 Feb 2020 

USE fsd;


CREATE TABLE countries(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(45) NOT NULL
);

CREATE TABLE towns (
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(45) NOT NULL,
country_id INT NOT NULL,
CONSTRAINT fk_towns_countries
FOREIGN KEY (country_id)
REFERENCES countries(id)
);

CREATE TABLE stadiums  (
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(45) NOT NULL,
capacity INT NOT NULL,
town_id INT NOT NULL,
CONSTRAINT fk_stadiums_towns
FOREIGN KEY (town_id)
REFERENCES towns(id)
);

CREATE TABLE teams   (
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(45) NOT NULL,
established DATE NOT NULL,
fan_base BIGINT NOT NULL DEFAULT 0,
stadium_id INT NOT NULL,
CONSTRAINT fk_stadiums_team
FOREIGN KEY (stadium_id)
REFERENCES stadiums(id)
);

CREATE TABLE skills_data (
id INT PRIMARY KEY AUTO_INCREMENT,
dribbling INT DEFAULT 0,
pace INT DEFAULT 0,
passing INT DEFAULT 0,
shooting INT DEFAULT 0,
speed INT DEFAULT 0,
strength INT DEFAULT 0
);

CREATE TABLE coaches (
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(10) NOT NULL,
last_name VARCHAR(20) NOT NULL,
salary DECIMAL(10, 2) NOT NULL DEFAULT 0,
coach_level INT NOT NULL DEFAULT 0
);

CREATE TABLE players (
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(10) NOT NULL,
last_name VARCHAR(20) NOT NULL, 
age INT NOT NULL DEFAULT 0,
position CHAR(1) NOT NULL,
salary DECIMAL(10, 2) NOT NULL DEFAULT 0,
hire_date DATETIME,
skills_data_id INT NOT NULL,
team_id INT,
CONSTRAINT fk_players_teams
FOREIGN KEY (team_id)
REFERENCES teams(id),
CONSTRAINT fk_players_skills_data
FOREIGN KEY (skills_data_id)
REFERENCES skills_data(id)
);

CREATE TABLE players_coaches (
player_id INT,
coach_id INT,
CONSTRAINT fk_maping_player
FOREIGN KEY (player_id)
REFERENCES players (id),
CONSTRAINT fk_maping_coaches
FOREIGN KEY (coach_id)
REFERENCES coaches(id),
CONSTRAINT pk_mappint PRIMARY KEY (player_id, coach_id)
);

# 2.Insert
INSERT INTO `coaches` (`first_name` , `last_name`, `salary`, `coach_level`)
SELECT p.`first_name` , p.`last_name` , p.`salary` * 2 , char_length(p.`first_name`)
FROM `players` AS p
WHERE p.`age` >= 45;

# 3.Update
UPDATE `coaches` AS c
JOIN `players_coaches` AS pc
ON c.`id` = pc.`coach_id`
SET c.`coach_level` = c.`coach_level` + 1
WHERE c.`first_name` LIKE 'A%';

# 4.Delete
DELETE FROM `coaches` 
WHERE age >= 45;

# 5. Players
SELECT first_name, age ,salary
FROM players
ORDER BY salary DESC;

# 6. Young offense players without contract
SELECT p.`id`, CONCAT(p.`first_name`, ' ', p.`last_name`) AS full_name, p.age, p.`position`, p.hire_date
FROM `players` AS p
JOIN `skills_data` AS sd
ON p.`skills_data_id` = sd.`id`
WHERE sd.strength > 50  AND p.age < 23 AND p.`position` = 'A' AND p.hire_date IS NULL 
ORDER BY p.salary, p.age;

# 7. Detail info for all teams
SELECT t.`name` AS team_name, t.`established`, t.`fan_base`, COUNT(p.`team_id`) AS `players_count`
FROM `teams` AS t
JOIN `players` AS p
ON p.`team_id` = t.`id`
GROUP BY p.`team_id`
ORDER BY `players_count` DESC , t.`fan_base` DESC;

# 8. The fastest player by towns
SELECT MAX(sd.speed) AS max_speed, t.`name` AS town_name
FROM `skills_data` AS sd
RIGHT JOIN `players` AS p
ON p.`skills_data_id` = sd.`id`
RIGHT JOIN `teams` AS tt
ON tt.`id` = p.`team_id`
RIGHT JOIN `stadiums` AS s
ON tt.`stadium_id` = s.`id`
RIGHT JOIN `towns` AS t
ON s.`town_id` = t.`id`
WHERE tt.`name` != 'Devify'
GROUP BY t.`name`
ORDER BY max_speed DESC,  town_name;

# 9. Total salaries and players by country
SELECT c.`name` ,COUNT(p.`id`) AS `total_count_of_players`, SUM(p.`salary`) AS `total_sum_of_salaries`
FROM `players` AS p
RIGHT JOIN `teams` AS tt
ON tt.`id` = p.`team_id`
RIGHT JOIN `stadiums` AS s
ON tt.`stadium_id` = s.`id`
RIGHT JOIN `towns` AS t
ON s.`town_id` = t.`id`
 RIGHT JOIN `countries` AS c
ON c.`id` = t.`country_id`
GROUP BY c.`name`
ORDER BY `total_count_of_players` DESC , c.`name`;

# 10. Find all players that play on stadium

DELIMITER %%
CREATE FUNCTION udf_stadium_players_count(`stadium_name` VARCHAR(30))
RETURNS INT
DETERMINISTIC
BEGIN
     declare player_count int;
    set player_count := (
    SELECT COUNT(p.`id`) FROM `players` AS p
     JOIN `teams` AS tt
ON tt.`id` = p.`team_id`
 JOIN `stadiums` AS s
ON tt.`stadium_id` = s.`id`
WHERE s.`name` = `stadium_name`
    );
    return player_count;
END
%%

# 11. Find good playmaker by teams
DELIMITER %%
CREATE PROCEDURE udp_find_playmaker(`min_points` INT,`team_name` VARCHAR(45))
    BEGIN
      SELECT CONCAT(p.`first_name`, ' ' , p.`last_name`) AS `full_name`,
      p.`age`, p.`salary` , sd.`dribbling` ,sd.`speed`, tt.`name` AS team_name
      FROM `skills_data` AS sd
 JOIN `players` AS p
ON p.`skills_data_id` = sd.`id`
RIGHT JOIN `teams` AS tt
ON tt.`id` = p.`team_id`
WHERE sd.`dribbling` > `min_points` AND tt.`name`= `team_name`
AND sd.`speed` > (SELECT AVG(speed) FROM skills_data)
ORDER BY sd.`speed` DESC
LIMIT 1;
    END
    %%




