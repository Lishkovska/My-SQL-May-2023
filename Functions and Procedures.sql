USE `soft_uni` ;

# 1. Employees with Salary Above 35000
DELIMITER %%
CREATE PROCEDURE usp_get_employees_salary_above_35000()
BEGIN
   SELECT e.first_name, e.last_name
   FROM `employees` AS e
   WHERE e.salary > 35000
   ORDER BY e.first_name, e.last_name, e.employee_id;
END
%%

# 2. Employees with Salary Above Number
DELIMITER %%
CREATE PROCEDURE usp_get_employees_salary_above(needed_salary DECIMAL(19,4))
BEGIN
   SELECT e.first_name, e.last_name
   FROM `employees` AS e
   WHERE e.salary >= needed_salary
   ORDER BY e.first_name, e.last_name, e.employee_id;
END
%%

# 3. Town Names Starting With
DELIMITER %%
CREATE PROCEDURE usp_get_towns_starting_with(letter_to_start VARCHAR(20))
BEGIN
  SELECT `name`
  FROM `towns`
  WHERE `name` LIKE CONCAT(letter_to_start,'%')
  ORDER BY `name`;
END
%%

# 4. Employees from Town
DELIMITER %%
CREATE PROCEDURE usp_get_employees_from_town(town_to_check VARCHAR(50))
BEGIN
   SELECT e.first_name, e.last_name
   FROM `employees` AS e
   JOIN `addresses` AS a
   ON e.address_id = a.address_id
   JOIN `towns` AS t
   ON a.town_id = t.town_id
   WHERE t.`name` = town_to_check
   ORDER BY e.first_name, e.last_name, e.employee_id;
END
%%

# 5. Salary Level Function
DELIMITER %%
CREATE FUNCTION ufn_get_salary_level(employee_salary INT)
RETURNS VARCHAR(30)
DETERMINISTIC
BEGIN
 DECLARE level_of_salary VARCHAR(30);
   IF employee_salary < 30000
   THEN SET level_of_salary = 'Low';
   ELSEIF employee_salary BETWEEN 30000 AND 50000 
   THEN SET level_of_salary = 'Average';
   ELSE SET level_of_salary = 'High';
   END IF;
   RETURN level_of_salary;
END
%%

# 6. Employees by Salary Level
DELIMITER %%
CREATE PROCEDURE usp_get_employees_by_salary_level(level_to_check VARCHAR(20))
BEGIN
   SELECT e.first_name, e.last_name
   FROM `employees` AS e
   WHERE ufn_get_salary_level(e.salary) LIKE level_to_check
   ORDER BY e.first_name DESC, e.last_name DESC;
END
%%


# 8. Find Full Name
DELIMITER %%
CREATE PROCEDURE usp_get_holders_full_name()
BEGIN
   SELECT CONCAT(ah.first_name, ' ' , ah.last_name) AS `full_name`
   FROM `account_holders` AS ah
   ORDER BY `full_name` , `id`;
END
%%

# 9. People with Balance Higher Than
DELIMITER %%
CREATE PROCEDURE usp_get_holders_with_balance_higher_than(number_to_check INT)
BEGIN
    SELECT ah.first_name, ah.last_name
    FROM `account_holders` AS ah
    JOIN `accounts` AS a
    ON ah.id = a.account_holder_id 
    GROUP BY ah.first_name, ah.last_name
    HAVING SUM(a.`balance`)  > number_to_check
    ORDER BY a.account_holder_id;
END
%%

# 10. Future Value Function
DELIMITER %%
CREATE FUNCTION ufn_calculate_future_value(sum DECIMAL(19,4) , interest_rate DOUBLE, number_of_years INT)
RETURNS DECIMAL(19,4)
DETERMINISTIC
BEGIN
 DECLARE total_sum DECIMAL(19,4);
    SET total_sum = sum * (POW(1 + interest_rate, number_of_years));
    RETURN total_sum;
END
%%

# 11. Calculating Interest
DELIMITER %%
CREATE PROCEDURE usp_calculate_future_value_for_account(id_to_check INT, interest_rate DOUBLE)
BEGIN
   SELECT ah.id AS account_id, ah.first_name, ah.last_name, a.balance AS current_balance,
    ufn_calculate_future_value(a.balance ,interest_rate, 5) AS balance_in_5_years
    FROM `account_holders` AS ah
    JOIN `accounts` AS a
    ON ah.id = a.account_holder_id 
    WHERE id_to_check = a.id ;
END
%%

# 12.   Deposit Money
DELIMITER %%
CREATE PROCEDURE usp_deposit_money(id INT, money_amount DECIMAL(19,4))
BEGIN
    START TRANSACTION;
    IF(money_amount <= 0 ) THEN
    ROLLBACK;
    ELSE
        UPDATE `accounts` AS ac SET ac.`balance` = ac.`balance` + money_amount
        WHERE ac.`id` = id;
    END IF; 
END
%%

# # 13. Withdraw Money
DELIMITER %%
CREATE PROCEDURE usp_withdraw_money(id int, money_amount decimal(19,4))
BEGIN
    START TRANSACTION;
    IF (money_amount <= 0 OR (SELECT `balance` FROM accounts AS a WHERE a.`id` = id) < money_amount) THEN
    ROLLBACK;
    ELSE
        UPDATE accounts as ac SET ac.balance = ac.balance - money_amount
        WHERE ac.id = id;
        COMMIT;
    END IF; 
END
%%

# 14.   Money Transfer
DELIMITER %%
CREATE PROCEDURE usp_transfer_money(fromID int, toID int,money_amount decimal(19,4))
BEGIN
    START TRANSACTION;
    IF(money_amount <= 0 OR (SELECT `balance` from `accounts` where `id` = fromID) < money_amount
    OR fromID = toID 
    OR (SELECT COUNT(id) FROM `accounts` WHERE `id` = fromID) <> 1
    OR (SELECT COUNT(id) FROM `accounts` WHERE `id` = toID) <> 1) 
    THEN ROLLBACK;
    ELSE
        UPDATE `accounts` SET `balance` = `balance` - money_amount
        WHERE `id` = fromID;
        UPDATE `accounts` SET `balance` = `balance` + money_amount
        WHERE `id` = toID;
        COMMIT;
    END IF; 
END
%%


