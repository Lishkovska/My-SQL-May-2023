CREATE DATABASE `minions`;

USE `minions`;
CREATE TABLE `minions` (`id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(50) NOT NULL,
  `age` INT);
  
  CREATE TABLE `towns` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL
);

ALTER TABLE `minions`
ADD COLUMN `town_id` INT ;

ALTER TABLE `minions`
ADD COLUMN `town_id` INT,
ADD CONSTRAINT fk_minions_towns
FOREIGN KEY (town_id)
REFERENCES `towns`(`id`);

INSERT INTO `towns` 
VALUES ("1" ,"Sofia"),
("2" , "Plovdiv"),
("3" , "Varna");

INSERT INTO `minions`
VALUES (1, "Kevin", 22, 1),
(2, "Bob" , 15, 3),
(3, "Steward" , NULL ,2);

TRUNCATE `minions` ;

DROP TABLE `minions`;
DROP TABLE `towns`;

CREATE DATABASE `minions`;

USE `minions`;
CREATE TABLE `people` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `picture` BLOB,
    `height` FLOAT(5,2 ),
    `weight` FLOAT(5,2 ),
    `gender` CHAR NOT NULL,
    `birthdate` DATE NOT NULL,
    `biography` TEXT
);

INSERT INTO `people`
VALUES (1, "Toni", null, 170, 65, 'f', '2021-05-18', "none"),
(2, "Mimi", null, 110, 20, 'f', '2021-05-18', "none"),
(3, "Sofi", null, 80, 10, 'f', '2021-05-18', "none"),
(4, "Dani", null, 180, 80, 'm', '2021-05-18', "none"),
(5, "Stefi", null, 120, 20, 'm', '2021-05-18', "none");

USE `minions`;
CREATE TABLE `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(30) UNIQUE NOT NULL,
    `password` VARCHAR(26) NOT NULL,
    `profile_picture` BLOB,
    `last_login_time` DATETIME,
    `is_deleted` BOOL
)
;



INSERT INTO `users` 
VALUES (1, "test" , "softuni", null, '2021-05-18 08:31:00' , 0 ),
(2, "cat" , "softuni4", null, '2021-05-18 08:31:00' , 0),
(3, "dog" , "meat", null, '2021-05-18 08:31:00' , 0 ),
(4, "parrot" , "grass", null, '2021-05-18 08:31:00' , 0 ),
(5, "Sisis" , "1547", null, '2021-05-18 08:31:00' , 0 )
;

ALTER TABLE `users`
DROP PRIMARY KEY,
ADD PRIMARY KEY pk_users (`id`, `username`);

ALTER TABLE `users`
MODIFY COLUMN `last_login_time` DATETIME DEFAULT NOW();

ALTER TABLE `users`
DROP PRIMARY KEY ,
ADD CONSTRAINT pk_users 
PRIMARY KEY (`id`),
MODIFY COLUMN `username` VARCHAR(30) UNIQUE;

CREATE DATABASE `movies`;
CREATE TABLE `directors` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`director_name` VARCHAR(255) NOT NULL,
`notes` TEXT);

INSERT INTO `directors`
VALUES (1, "Robert Deniro", "none"),
(2, "Jason", "none"),
(3, "Steven", "none"),
(4, "Robert George", "none"),
(5, "Segal", "none");


CREATE TABLE `genres` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`genre_name` VARCHAR(255) NOT NULL,
`notes` TEXT
);

INSERT INTO `genres`
VALUES (1, "comedy", "empty"),
(2, "triller", "empty"),
(3, "drama", "empty"),
(4, "opera", "empty"),
(5, "scary", "empty");


CREATE TABLE `categories` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`category_name` VARCHAR(255) NOT NULL,
`notes` TEXT
);

INSERT INTO `categories` 
VALUES (1, "love", "all"),
(2, "hate", "all"),
(3, "fake", "all"),
(4, "test", "all"),
(5, "pain", "all");


CREATE TABLE `movies` (
`id` INT PRIMARY KEY AUTO_INCREMENT, 
`title` VARCHAR(100) NOT NULL, 
`director_id` INT NOT NULL, 
`copyright_year` YEAR, 
`length` DECIMAL (5,2) NOT NULL,
 `genre_id` INT NOT NULL,
 `category_id` INT NOT NULL, 
 `rating` INT NOT NULL,
 `notes` TEXT);
 
 INSERT INTO `movies`
 VALUES (1, "Harry Potter", 2 , 1998 , 120 , 1, 1, 10, "none"),
 (2, "American pie", 2 , 1999 , 120 , 2, 4, 8, "none"),
 (3, "Karate kid", 3 , 1997 , 110 , 3, 3, 8, "none"),
 (4, "Godzilla", 1 , 1994 , 110 , 4, 4, 8, "none"),
 (5, "Firestone", 5 , 2000 , 120 , 4, 2, 8, "none");
 
 CREATE DATABASE `car_rental`;
 
 CREATE TABLE `categories` (
 `id` INT AUTO_INCREMENT PRIMARY KEY,
 `category` VARCHAR(100) NOT NULL,
 `daily_rate` INT NOT NULL,
 `weekly_rate` INT NOT NULL,
 `monthly_rate` INT NOT NULL,
 `weekend_rate` INT NOT NULL);
 

 INSERT INTO `categories` 
 VALUES (1, "sport car", 1, 7, 30, 5),
 (2, "casual car", 2, 7, 40, 6),
 (3, "pink car", 6, 7, 40, 8);
 
 CREATE TABLE `cars` (
 `id` INT AUTO_INCREMENT PRIMARY KEY,
 `plate_number` VARCHAR(30) NOT NULL,
 `make` VARCHAR(30) NOT NULL,
 `model` VARCHAR(30) NOT NULL,
 `car_year` YEAR NOT NULL,
 `category_id` INT NOT NULL,
 `doors` INT,
 `picture` BLOB NOT NULL,
 `car_condition` VARCHAR(30) NOT NULL,
 `available` BOOL);
 
 INSERT INTO `cars`
 VALUES (1, "4455c", "yes", "toyota", 2021, 2, 4, "yes", "new", 1),
 (2, "447kc", "yes", "shkoda", 2018, 1, 4, "yes", "new", 1),
 (3, "4t7kc", "yes", "mazda", 2019, 3, 4, "yes", "new", 1);
 

 CREATE TABLE `employees`(
 `id` INT AUTO_INCREMENT PRIMARY KEY,
 `first_name` VARCHAR (100) NOT NULL,
 `last_name` VARCHAR (100) NOT NULL,
 `title` VARCHAR(20),
 `notes` TEXT);
 
 INSERT INTO `employees`
 VALUES (1, "Toni", "Lishkovska", "dev", "none"),
 (2, "Simona", "Petrova", "saler", "none"),
 (3, "Petia", "Ivanova", "accounter", "none");


CREATE TABLE `customers` (
`id` INT AUTO_INCREMENT PRIMARY KEY,
`driver_licence_number` INT NOT NULL,
 `full_name` VARCHAR (100) NOT NULL,
 `address` VARCHAR(255) NOT NULL,
 `city` VARCHAR(100) NOT NULL,
 `zip_code` INT,
 `note` TEXT);
 
 INSERT INTO `customers`
 VALUES (1, "1555", "Danail Velikov", "Storgozia", "Pleven", 5800, "none"),
  (2, "15785", "Hristo Velikov", "Storgozia3", "Pleven", 5800, "none"),
  (3, "77785", "Valeri Velikov", "Medicine square", "Sofia", 1000, "none");
 

 CREATE TABLE `rental_orders` (
 `id` INT AUTO_INCREMENT PRIMARY KEY,
 `employee_id` INT NOT NULL,
 `customer_id` INT NOT NULL,
 `car_id` INT NOT NULL,
 `car_condition` VARCHAR(30) NOT NULL,
 `tank_level` INT,
 `kilometrage_start` INT NOT NULL,
 `kilometrage_end` INT NOT NULL,
 `total_kilometrage` INT NOT NULL,
 `start_date` DATE NOT NULL,
 `end_date` DATE NOT NULL,
 `total_days` INT NOT NULL,
 `rate_applied` INT NOT NULL,
 `tax_rate` FLOAT NOT NULL,
 `order_status` VARCHAR(100) NOT NULL,
 `notes` TEXT);
 
 INSERT INTO `rental_orders`
 VALUES (1, 1, 2, 2, "good", 10, 15, 75, 60, "2021-05-18" , "2021-05-19", 1,4 ,25.5, "complete", "none"),
  (2, 1, 3, 2, "good", 10, 15, 75, 60, "2021-04-18" , "2021-05-19", 1,20 ,26.5, "complete", "none"),
  (3, 2, 2, 2, "good", 10, 15, 75, 60, "2021-05-19" , "2021-05-20", 1,4 ,25.5, "complete", "none");

CREATE DATABASE `soft_uni`;

USE `soft_uni`;
CREATE TABLE `towns` (
`id` INT AUTO_INCREMENT PRIMARY KEY,
`name` VARCHAR(100) NOT NULL);


INSERT INTO `towns`
VALUES (1, "Sofia"),
 (2, "Plovdiv"),
 (3, "Varna"),
 (4, "Burgas");

USE `soft_uni`;
CREATE TABLE `addresses` (
`id` INT AUTO_INCREMENT PRIMARY KEY,
`address_text` TEXT NOT NULL,
`town_id` INT NOT NULL);

ALTER TABLE `addresses`
 ADD CONSTRAINT pk_addresses_towns FOREIGN KEY (`town_id`)
        REFERENCES `towns` (`id`);

USE `soft_uni`;
CREATE TABLE `departments` (
`id` INT AUTO_INCREMENT PRIMARY KEY,
`name` VARCHAR(100) NOT NULL);

INSERT INTO `departments`
VALUES (1, "Engineering"),
 (2, "Sales"),
 (3, "Marketing"),
 (4, "Software Development"),
 (5, "Quality Assurance");

USE `soft_uni`;
CREATE TABLE `employees` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(255) NOT NULL,
`middle_name` VARCHAR(255),
`last_name` VARCHAR(255) NOT NULL,
 `job_title` VARCHAR(100) NOT NULL,
 `department_id` INT NOT NULL,
 `hire_date` DATE NOT NULL,
 `salary` FLOAT NOT NULL,
 `address_id` INT NOT NULL);
 
 ALTER TABLE `employees`
  ADD CONSTRAINT pk_employees_departments
 FOREIGN KEY (`department_id`) REFERENCES `departments`(`id`) ,
 ADD CONSTRAINT pk_employees_addresses
 FOREIGN KEY (`address_id`) REFERENCES `addresses`(`id`);
 
 INSERT INTO `employees`
 VALUES (1, 'Ivan', 'Ivanov', 'Ivanov',	'.NET Developer',	4, '2013-02-01', 3500.00, 1),
(2, 'Petar', 'Petrov', 'Petrov',	'Senior Engineer',	1,'2004-03-02', 4000.00, 3),
(3, 'Maria', 'Petrova', 'Ivanova',	'Intern',	5,	'2016-08-28', 525.25, 2),
(4, 'Georgi', 'Terziev', 'Ivanov', 'CEO',	2,'2007-12-09', 3000.00, 2),
(5, 'Peter', 'Pan', 'Pan',	'Intern',	3,'2016-08-28',	599.88, 3);

SELECT * FROM `towns`;
SELECT * FROM `departments`;
SELECT * FROM `employees`;

#15
SELECT * FROM `towns`
ORDER BY `name`;

SELECT * FROM `departments`
ORDER BY `name`;

SELECT 
    *
FROM
    `employees`
ORDER BY `salary` DESC;




SELECT `name` FROM  `towns` ORDER BY name ; 

SELECT `name `FROM `departments` ORDER BY `name`;
SELECT `first_name`, `last_name`, `job_title`, `salary` FROM `employees` ORDER BY salary DESC;

UPDATE `eployees`
SET `salary` = `salary` * 1.1 ;
SELECT `salary` FROM `employees`;






