CREATE SCHEMA `stc`;
USE  `stc`;

# Softuni taxi company


# 2.Insert
INSERT INTO clients (full_name, phone_number)
SELECT CONCAT(d.first_name, ' ', d.last_name), CONCAT('(088) 9999', d.id * 2)
FROM drivers AS d
WHERE  d.id >= 10
  AND d.id <= 20;
;

# 3.Update
UPDATE cars
SET `condition` = 'C'
WHERE mileage > 800000 AND mileage is null AND `year` >= 2010 AND model != 'Mercedes-Benz';

# 4.Delete
delete from clients
where id not in (select distinct(client_id) from courses)
AND char_length(full_name) > 3;

# 5.Cars
select c.make, c.model, c.`condition`
from cars as c
order by c.id;


# 6.Drivers and cars
select d.first_name, d.last_name, c.make, c.model, c.mileage
from drivers as d
         join cars_drivers cd on d.id = cd.driver_id
         join cars c on c.id = cd.car_id
where c.mileage is not null
order by c.mileage desc, d.first_name;

# 07. Number of courses
SELECT c.id AS `car_id`, c.make, c.mileage, COUNT(cc.`car_id`) AS `count_of_courses`, ROUND(AVG(cc.bill),2) AS `avg_bill`
FROM cars AS c
LEFT JOIN courses AS cc
ON cc.car_id = c.id
GROUP BY c.id
HAVING `count_of_courses` > 2
ORDER BY `count_of_courses` DESC, c.id;

# 08. Regular clients
SELECT c.full_name, COUNT(cc.car_id) AS `count_of_cars` , SUM(cc.bill) AS `total_sum`
FROM clients AS c
JOIN courses AS cc
ON c.id = cc.client_id
GROUP BY c.full_name
HAVING c.full_name LIKE '_a%' AND count_of_cars > 1
ORDER BY full_name;

# 09. Full info for courses
select a.name,
       if(hour(c.start) between 6 and 20, 'Day', 'Night') as day_time,c.bill,c2.full_name,c3.make,
       c3.model,c4.name   as category_name
from addresses as a
         join courses c on a.id = c.from_address_id
         join clients c2 on c2.id = c.client_id
         join cars c3 on c3.id = c.car_id
         join categories c4 on c4.id = c3.category_id
order by c.id;

# 10. Find all courses by client’s phone number
DELIMITER %%
CREATE FUNCTION udf_courses_by_client(phone_num VARCHAR(20)) 
RETURNS INT
DETERMINISTIC
BEGIN
RETURN (SELECT count(*) 
FROM clients AS c
JOIN courses AS up ON  c.id = up.client_id
WHERE c.phone_number = phone_num);
END
%%

# 11. Full info for address
DELIMITER %%
create procedure `udp_courses_by_address`(address_name varchar(100))
begin
    select a.name,
           c2.full_name as full_names,
           (case
                when c.bill <= 20 then 'Low'
                when c.bill <= 30 then 'Medium'
                else 'High' end) as level_of_bill,
           c3.make, c3.`condition`,c4.name as cat_name
    from addresses as a
             join courses c on a.id = c.from_address_id
             join clients c2 on c2.id = c.client_id
             join cars c3 on c3.id = c.car_id
             join categories c4 on c4.id = c3.category_id
    where a.name = address_name
    order by c3.make, c2.full_name;
end %%
