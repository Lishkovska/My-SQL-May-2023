CREATE SCHEMA `softuni_stores_system` ;
# Database Basics MySQL Exam - 18 Oct 2020 part 2



CREATE TABLE  `pictures` (
`id` INT Primary Key AUTO_INCREMENT,
`url` VARCHAR(100) NOT NULL ,
`added_on` DATETIME NOT NULL 
);

CREATE TABLE  `categories` (
`id` INT Primary Key AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE  `products` (
`id` INT Primary Key AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL UNIQUE,
`best_before` DATE ,
`price` DECIMAL(10,2) NOT NULL ,
`description` TEXT  ,
`category_id` INT NOT NULL  ,
`picture_id` INT NOT NULL  ,
CONSTRAINT fk_products_categories
FOREIGN KEY (`category_id`)
REFERENCES `categories` (`id`),
CONSTRAINT fk_products_picrures
FOREIGN KEY (`picture_id`)
REFERENCES `pictures` (`id`)
);

CREATE TABLE  `towns` (
`id` INT Primary Key AUTO_INCREMENT,
`name` VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE  `addresses` (
`id` INT Primary Key AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL UNIQUE,
`town_id` INT NOT NULL,
CONSTRAINT fk_addresses_towns
FOREIGN KEY (`town_id`)
REFERENCES `towns` (`id`)
);

CREATE TABLE  `stores` (
`id` INT Primary Key AUTO_INCREMENT,
`name` VARCHAR(20) NOT NULL UNIQUE,
`rating` FLOAT NOT NULL,
`has_parking` TINYINT(1),
`address_id` INT NOT NULL,
CONSTRAINT fk_addresses_stores
FOREIGN KEY (`address_id`)
REFERENCES `addresses` (`id`)
);

CREATE TABLE `products_stores`(
`product_id` INT NOT NULL,
`store_id` INT not null,
CONSTRAINT fk_products_products
FOREIGN KEY (`product_id`)
REFERENCES `products` (`id`),
CONSTRAINT fk_stores
FOREIGN KEY (`store_id`)
REFERENCES `stores` (`id`)
);



CREATE TABLE `employees` (
`id` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(15) NOT NULL,
`middle_name` CHAR(1) ,
`last_name` VARCHAR(20) NOT NULL ,
`salary` DECIMAL(19,2) DEFAULT 0 ,
`hire_date` DATE NOT NULL,
`manager_id` INT,
`store_id` INT NOT NULL,
CONSTRAINT fk_employess_stores
FOREIGN KEY (`store_id`)
REFERENCES `stores` (`id`)
);

# 2. Insert
insert into products_stores(product_id, store_id)
select p.id, 1
from products as p
left join products_stores ps on p.id = ps.product_id
where ps.store_id is null;

# 3.Update
UPDATE employees AS e
    JOIN stores s 
    ON s.id = e.store_id
set e.first_name  = 'Carolyn',
    e.middle_name = 'Q',
    e.last_name   = 'Dyett',
    e.manager_id  = 3,
    e.salary      = e.salary - 500
where YEAR(e.hire_date) > 2003
  and s.name != 'Cardguard'
  and s.name != 'Veribet';
# WHERE YEAR(`hire_date`) > 2003 AND `store_id` NOT IN (5,14);

# 4.Delete
delete e
from employees as e
where e.manager_id is not null
  and e.salary >= 6000;

# 5.Employees
SELECT `first_name` , `middle_name` , `last_name` , `salary` , `hire_date`
FROM `employees`
ORDER BY `hire_date` DESC;

# 06. Products with old pictures
SELECT p.`name` AS `product_name` , p.`price` , p.`best_before` , 
CONCAT(SUBSTR(p.`description`,1,10),'...') AS `short_description`, pi.`url`
FROM `products` AS p
JOIN `pictures` AS pi
ON pi.`id` = p.`picture_id`
WHERE LENGTH(`description`) > 100 AND YEAR(pi.`added_on` ) < 2019 AND p.`price` > 20
ORDER BY p.`price` DESC;

# 07. Counts of products in stores
SELECT s.`name` , COUNT(p.`id`) AS `product_count`, round(avg(p.`price`),2) AS `avg`
FROM `stores` AS s
 LEFT JOIN `products_stores` AS ps
 ON s.`id` = ps.`store_id`
 LEFT JOIN `products` AS p
 ON  p.`id` = ps.`product_id`
 GROUP BY s.`id` 
 ORDER BY `product_count` DESC,  `avg` DESC , s.`id`;
 
 # 08. Specific employee
 SELECT CONCAT(e.`first_name` ,' ' ,e.`last_name`) AS `full_name`, s.`name` AS `store_name` , a.`name` AS `address`,
 e.`salary`
 FROM `employees` AS e
 JOIN `stores` AS s
 ON e.`store_id` = s.`id`
 JOIN `addresses` AS a
 ON s.`address_id` = a.`id`
 WHERE e.`salary` < 4000 AND LENGTH(s.`name`) > 8 AND a.`name` LIKE '%5%'
AND e.`last_name` LIKE '%n';

# 09. Find all information of stores
SELECT REVERSE(s.`name`) AS `reversed_name` , CONCAT(UPPER(t.`name`),'-',a.`name`) AS `full_address`, 
COUNT(e.`id`) AS `employees_count`
FROM `employees` AS e
 JOIN `stores` AS s
 ON e.`store_id` = s.`id`
 JOIN `addresses` AS a
 ON s.`address_id` = a.`id`
 JOIN `towns` AS t
 ON t.`id` = a.`town_id`
 GROUP BY s.`name`
 ORDER BY `full_address`;
 
 # 10. Find name of top paid employee by store name
 DELIMITER %%
CREATE FUNCTION udf_top_paid_employee_by_store(store_name VARCHAR(50))
RETURNS TEXT
DETERMINISTIC
BEGIN
    RETURN 
    (select concat(e.first_name, ' ', e.middle_name, '.', ' ', e.last_name, ' works in store for ',
                          2020 - year(e.hire_date), ' years')
    FROM `employees` AS e
 JOIN `stores` AS s
 ON e.`store_id` = s.`id`
    WHERE s.`name` = store_name
    ORDER BY e.`salary` DESC
    LIMIT 1 
);
END
%%

# 11. Update product price by address
DELIMITER %%
CREATE PROCEDURE udp_update_product_price(address_name VARCHAR(50))
    BEGIN
      DECLARE increase_level INT;
    if address_name LIKE '0%' THEN
        SET increase_level = 100;
    else
        SET increase_level = 200;
    end if;
    UPDATE products AS p
    SET price = price + increase_level
    WHERE p.id IN (SELECT ps.product_id
                   FROM addresses AS a
                            JOIN stores AS s ON a.id = s.address_id
                            JOIN products_stores AS ps ON ps.store_id = s.id
                   WHERE a.name = address_name);
       END
    %%






