CREATE SCHEMA `online_store`;
#Online store – electronic devices (exam prep 05.06.23)

CREATE TABLE `brands` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE `categories` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE `reviews` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`content` TEXT,
`rating` DECIMAL (10,2) NOT NULL,
`picture_url` VARCHAR(80) NOT NULL,
`published_at` DATETIME NOT NULL
);

CREATE TABLE `products` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL ,
`price` DECIMAL (19,2) NOT NULL,
`quantity_in_stock` INT,
`description` TEXT,
`brand_id` INT NOT NULL,
`category_id` INT NOT NULL,
`review_id` INT,
CONSTRAINT fk_brands_products
FOREIGN KEY (`brand_id`)
REFERENCES `brands` (`id`),
CONSTRAINT fk_categories_products
FOREIGN KEY (`category_id`)
REFERENCES `categories` (`id`),
CONSTRAINT fk_reviws_products
FOREIGN KEY (`review_id`)
REFERENCES `reviews` (`id`)
);

CREATE TABLE `customers` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(20) NOT NULL,
`last_name` VARCHAR(20) NOT NULL,
`phone` VARCHAR(30) NOT NULL UNIQUE,
`address` VARCHAR(60) NOT NULL,
`discount_card` BIT(1) NOT NULL DEFAULT 0
);

CREATE TABLE `orders` (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`order_datetime` DATETIME NOT NULL,
`customer_id` INT NOT NULL,
CONSTRAINT fk_customers_orders
FOREIGN KEY (`customer_id`)
REFERENCES `customers` (`id`)
);

CREATE TABLE `orders_products` (
`order_id` INT,
`product_id` INT,
CONSTRAINT fk_productss_orders
FOREIGN KEY (`order_id`)
REFERENCES `orders` (`id`),
CONSTRAINT fk_orders
FOREIGN KEY (`product_id`)
REFERENCES `products` (`id`)
);

# 2. Insert
INSERT INTO `reviews` (content ,picture_url ,published_at, rating)
SELECT SUBSTR(p.`description`,1,15), REVERSE(p.`name`) , (DATE '2010/10/10'), p.price/8
FROM `products` AS p
WHERE p.`id` >= 5;

# 3.Update
UPDATE `products`
SET `quantity_in_stock` = `quantity_in_stock` - 5
WHERE `quantity_in_stock` BETWEEN 60 AND 70;

# 4.Delete
delete from customers
where id not in (select distinct(customer_id) from orders);

# 05. Categories
SELECT `id` , `name`
FROM `categories`
ORDER BY `name` DESC;

# 06. Quantity
SELECT id, brand_id, `name` , quantity_in_stock
FROM `products`
WHERE price > 1000 AND quantity_in_stock < 30
ORDER BY quantity_in_stock, id;

# 07. Review
SELECT id, content, rating, picture_url , published_at
FROM `reviews`
WHERE content LIKE 'My%' AND CHAR_LENGTH(content) > 61
ORDER BY rating DESC;

# 08. First customers
SELECT CONCAT(c.`first_name`, ' ', c.`last_name`) AS full_name, c.`address` , o.`order_datetime` AS `order_date`
FROM `customers` AS c
JOIN `orders` AS o
ON o.`customer_id` = c.`id`
WHERE YEAR(o.`order_datetime`) <= 2018
ORDER BY full_name DESC;

# 09. Best categories
SELECT COUNT(c.`id`) AS `items_count` , c.`name` , SUM(p.`quantity_in_stock`) AS `total_quantity`
FROM `categories` AS c
 JOIN `products` AS p
ON p.`category_id` = c.`id`
GROUP BY c.`id`
ORDER BY `items_count` DESC, `total_quantity`
LIMIT 5;


# 10. Extract client cards count
 DELIMITER %%
CREATE FUNCTION udf_customer_products_count(`name` VARCHAR(30))
RETURNS INT
DETERMINISTIC
BEGIN
     declare product_count int;
    set product_count := (select count(c.id)
                          from customers c
                                   join orders o on c.id = o.customer_id
                                   join orders_products op on o.id = op.order_id
                          where c.first_name = name);
    return product_count;
END
%%

# 11. Reduce price
DELIMITER %%
CREATE PROCEDURE udp_reduce_price(`category_name` VARCHAR(50))
    BEGIN
      UPDATE `products` AS p
      JOIN `categories` AS c
      ON c.`id` = p.`category_id`
      JOIN `reviews` AS r
      ON r.`id` = p.`review_id`
      SET p.price = p.price * 0.7
      WHERE c.`name` = `category_name` AND r.`rating` < 4;
    END
    %%