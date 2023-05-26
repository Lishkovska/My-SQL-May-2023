CREATE TABLE `employees` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR(255) NOT NULL,
    `last_name` VARCHAR(255) NOT NULL
)
;

CREATE TABLE `categories` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL
)
;


CREATE TABLE `products` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL,
    `category_id` INT NOT NULL
)
;


USE `gamebar`;
INSERT INTO `employees` (`id`, `first_name` , `last_name` )
VALUES ("1" ,"Tonka" ,"Lishkovska"),
("2","Maria", "Velikova"),
("3","Sofia" , "Velikova");

ALTER TABLE `products`
ADD CONSTRAINT fk_products_categories
FOREIGN KEY (`category_id`) REFERENCES `categories`(`id`);

ALTER TABLE `employees`
MODIFY COLUMN `middle_name` VARCHAR(100);

 