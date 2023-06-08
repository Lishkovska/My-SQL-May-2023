CREATE SCHEMA `restaurant_db`;
# exam prep 02.06.23

CREATE TABLE `products` (
`id` INT Primary Key AUTO_INCREMENT,
`name` VARCHAR(30) NOT NULL UNIQUE,
`type` VARCHAR(30) NOT NULL ,
`price` DECIMAL(10,2) NOT NULL 
);

CREATE TABLE `clients`(
`id` INT Primary Key AUTO_INCREMENT,
`first_name` VARCHAR(50) NOT NULL ,
`last_name` VARCHAR(50) NOT NULL ,
`birthdate` DATE NOT NULL ,
`card` VARCHAR(50) ,
`review` TEXT
);

CREATE TABLE `tables` (
`id` INT Primary Key AUTO_INCREMENT,
`floor` INT NOT NULL,
`reserved` TINYINT(1),
`capacity` INT NOT NULL
);

CREATE TABLE `waiters` (
`id` INT Primary Key AUTO_INCREMENT,
`first_name` VARCHAR(50) NOT NULL ,
`last_name` VARCHAR(50) NOT NULL ,
`email` VARCHAR(50) NOT NULL ,
`phone` VARCHAR(50)  ,
`salary` DECIMAL (10,2)
);

CREATE TABLE `orders` (
`id` INT Primary Key AUTO_INCREMENT,
`table_id` INT NOT NULL,
`waiter_id` INT NOT NULL,
`order_time` TIME NOT NULL,
`payed_status` TINYINT(1),
CONSTRAINT fk_orders_tables
FOREIGN KEY (`table_id`)
REFERENCES `tables` (`id`),
CONSTRAINT fk_aorders_waiters
FOREIGN KEY (`waiter_id`)
REFERENCES `waiters` (`id`)
);

CREATE TABLE `orders_clients` (
`order_id` INT,
`client_id` INT,
CONSTRAINT fk_orders_orders
FOREIGN KEY (`order_id`)
REFERENCES `orders` (`id`),
CONSTRAINT fk_aorders_clients
FOREIGN KEY (`client_id`)
REFERENCES `clients` (`id`)
);

CREATE TABLE `orders_products` (
`order_id` INT,
`product_id` INT,
CONSTRAINT fk_orders_orders_products
FOREIGN KEY (`order_id`)
REFERENCES `products` (`id`),
CONSTRAINT fk_aorders_products
FOREIGN KEY (`product_id`)
REFERENCES `products` (`id`)
);


# 2.Insert
insert into products(name, type, price)
select CONCAT(w.last_name, ' ', 'specialty'),
       'Cocktail',
       ceiling(w.salary / 100)
from waiters as w
where w.id > 6;

# 3.Update
update orders
set table_id = table_id - 1
where id >= 12
  and id <= 23;

# 4.Delete
# Delete all waiters, who don't have any orders. т.е нямат връзка waiters and orders
delete from waiters
where id not in (select distinct(waiter_id) from orders);



# 05. Clients
SELECT id ,first_name, last_name,  birthdate, card, review
FROM `clients`
ORDER BY birthdate DESC, id DESC;

# 06. Birthdate
SELECT first_name, last_name, birthdate, review
FROM `clients`
WHERE card IS NULL AND YEAR(birthdate) BETWEEN 1978 AND 1993
ORDER BY last_name DESC, id
LIMIT 5;

# 07. Accounts
SELECT CONCAT(last_name,first_name, char_length(w.first_name),'Restaurant') AS username ,
REVERSE(substr(`email`,2,12)) AS `password`
FROM `waiters` AS w
where w.salary > 0
ORDER BY `password` DESC;

# 08. Top from menu
SELECT p.`id` , p.`name` , COUNT(op.`order_id`) AS counts
FROM `products` AS p
LEFT JOIN `orders_products` AS op
ON p.id = op.product_id
GROUP BY p.`name`
HAVING counts >= 5
ORDER BY counts DESC ,p.`name`;

# 09. Availability
SELECT t.`id` AS `table_id`, t.`capacity`, COUNT(oc.client_id) AS `count_clients`,
 (CASE
            WHEN count(oc.client_id) > t.capacity THEN 'Extra seats'
            WHEN count(oc.client_id) < t.capacity THEN 'Free seats'
            WHEN count(oc.client_id) = t.capacity THEN 'Full'
           END)            AS 'availability'
       FROM   `tables` AS t
       JOIN `orders` AS o
       ON t.`id` = o.`table_id`
       JOIN `orders_clients` AS oc
       ON oc.`order_id` = o.`id`
       WHERE t.`floor` = 1
       GROUP BY t.`id`
       ORDER BY t.`id` DESC;
       
# 10. Extract bill
 DELIMITER %%
 CREATE FUNCTION udf_client_bill(full_name VARCHAR(50))
    RETURNS DECIMAL(19, 2)
    DETERMINISTIC
BEGIN
    DECLARE bill DECIMAL(19, 2);
    SET bill := (SELECT SUM(p.price)
                 FROM clients AS c
                          JOIN orders_clients AS oc ON c.id = oc.client_id
                          JOIN orders AS o ON oc.order_id = o.id
                          JOIN orders_products AS op ON o.id = op.order_id
                          JOIN products AS p ON op.product_id = p.id
                 WHERE CONCAT(c.first_name, ' ', last_name) = full_name);
    RETURN bill;
END
%%

# 11. Happy hour
DELIMITER %%
CREATE PROCEDURE udp_happy_hour(`type` VARCHAR(50))
    BEGIN
      UPDATE `products` AS p
      SET p.price = p.price * 0.8
      WHERE p.`type` = `type` AND p.`price` >= 10;
    END
    %%

