CREATE SCHEMA `universities_db` ;

CREATE TABLE `countries` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE `cities` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL UNIQUE,
`population` INT,
`country_id` INT NOT NULL,
CONSTRAINT fk_cities_cities_country_country
FOREIGN KEY (`country_id`)
REFERENCES `countries` (`id`)
);

CREATE TABLE `universities` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(60) NOT NULL UNIQUE,
`address` VARCHAR(80) NOT NULL UNIQUE,
`tuition_fee` DECIMAL(19,2) NOT NULL,
`number_of_staff` INT,
`city_id` int,
CONSTRAINT fk_cities_cities_uni_uni
FOREIGN KEY (`city_id`)
REFERENCES `cities` (`id`)
);

CREATE TABLE `students` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(40) NOT NULL,
`last_name` VARCHAR(40) NOT NULL,
`age` int,
`phone` VARCHAR(20) NOT NULL UNIQUE,
`email` VARCHAR(255) NOT NULL UNIQUE,
`is_graduated` TINYINT(1) NOT NULL,
`city_id` int,
CONSTRAINT fk_students_cities_uni
FOREIGN KEY (`city_id`)
REFERENCES `cities` (`id`)
);

CREATE TABLE `courses` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL UNIQUE,
`duration_hours` DECIMAL(19,2),
`start_date` DATE,
`teacher_name` VARCHAR(60) NOT NULL UNIQUE,
`description` text,
`university_id` int,
CONSTRAINT fk_scourses_un_uni
FOREIGN KEY (`university_id`)
REFERENCES `universities` (`id`)
);

CREATE TABLE `students_courses` (
`grade` DECIMAL(19,2) NOT NULL,
`student_id` int not null,
`course_id` int not null,
CONSTRAINT fk_scourses_studentt
FOREIGN KEY (`student_id`)
REFERENCES `students` (`id`),
CONSTRAINT fk_scourses_coursesss
FOREIGN KEY (`course_id`)
REFERENCES `courses` (`id`)
);

# 2.Insert
INSERT INTO `courses` (`name`,`duration_hours`, `start_date`,`teacher_name`, `description`, `university_id`)
SELECT CONCAT(c.`teacher_name`, ' ', 'course'), CHAR_LENGTH(c.`name`)/10 , DATE(c.`start_date` + 5),
reverse(c.`teacher_name`), CONCAT('Course',' ',c.`teacher_name`, reverse(c.`description`)),
DAY(c.`start_date`)
FROM `courses` AS c
WHERE `id` <= 5;

# 3.Update
UPDATE `universities`
SET `tuition_fee` = `tuition_fee` + 300
WHERE `id` >= 5 AND `id` <= 12;

# 4.Delete
DELETE FROM `universities`
WHERE `number_of_staff` is null;

# 5.Cities
SELECT `id`, `name`, `population`, `country_id`
FROM `cities`
order by `population` desc;

# 6. Students age
SELECT `first_name`, `last_name`, `age`, `phone`, `email`
FROM `students`
WHERE `age` >= 21
order by `first_name` desc, `email`, `id`
LIMIT 10;

# 7. New students
SELECT CONCAT(`first_name` , ' ', `last_name`) as full_name, SUBSTR(`email`,2,10) as `username`,
reverse(`phone`) as `password`
FROM `students`
where id not in (select distinct(student_id) from students_courses)
ORDER BY `password` DESC;

# 8. Students count
SELECT COUNT(sss.`id`) as `students_count`, uuu.`name` as `university_name`
FROM `students` as sss
JOIN `students_courses` as sct
ON sct.`student_id` = sss.`id`
JOIN `courses` as cccc
ON cccc.`id` = sct.`course_id`
JOIN `universities` as uuu
ON uuu.`id` = cccc.`university_id`
GROUP BY uuu.`name`
HAVING `students_count` >= 8
ORDER BY `students_count` desc, uuu.`name` desc;

# 9. Price rankings
SELECT uuu.`name` AS `university_name`, ctt.`name` AS `city_name`, uuu.`address` ,
CASE 
WHEN uuu.`tuition_fee` < 800  THEN 'cheap'
WHEN uuu.`tuition_fee` >= 800 AND uuu.`tuition_fee` < 1200 THEN 'normal'
WHEN uuu.`tuition_fee` >= 1200 AND uuu.`tuition_fee` < 2500 THEN 'high'
ELSE 'expensive'
END
AS `price_rank` , uuu.`tuition_fee`
FROM `universities` as uuu
JOIN `cities` as ctt
ON uuu.`city_id` = ctt.`id`
order by uuu.`tuition_fee`;

# 10. Average grades
DELIMITER %%
 CREATE FUNCTION udf_average_alumni_grade_by_course_name(course_name VARCHAR(60))
    RETURNS DECIMAL(19, 2)
     DETERMINISTIC
BEGIN
    DECLARE avg_gradde DECIMAL(19, 2);
    SET avg_gradde := (SELECT AVG(stct.`grade`) 
    FROM `courses` as cct
    JOIN `students_courses` as stct
    ON stct.`course_id` = cct.`id`
    JOIN `students` as t
    ON t.`id` = stct.`student_id`
    WHERE t.`is_graduated` = 1 AND (SELECT cct.`name` = course_name)
    GROUP BY cct.`name` 
    );
    RETURN avg_gradde;
END
%%

# 11.Graduate students
DELIMITER %%
CREATE PROCEDURE udp_graduate_all_students_by_year(`year_started` INT)
    BEGIN
      UPDATE `students` as sss
JOIN `students_courses` as sct
ON sct.`student_id` = sss.`id`
JOIN `courses` as cccc
ON cccc.`id` = sct.`course_id` 
      SET `is_graduated` = 1
      WHERE YEAR(cccc.`start_date`) = `year_started`;
       END
    %%


