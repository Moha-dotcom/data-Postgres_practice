
-- BEFORE Implementing Indexing
-- Planning Time: 0.194 ms
-- Execution Time: 40.596 ms

-- Here i have been trying to turn of the index scanning but enable_indexscan just turns of B-tree
-- enable_indexscan only disables regular B-tree index scans, not bitmap index scans.
SET enable_indexscan = OFF;
-- Turning of bitMapscanner
SET enable_indexscan = OFF;    -- disables regular B-tree index scans
SET enable_bitmapscan = OFF;   -- disables bitmap index scans
SET enable_tidscan = OFF;      -- disables TID (tuple ID) scans
--- Execution Time: 124.483 ms Before using Index
EXPLAIN ANALYZE
SELECT customer_id, status, total_amount
FROM orders
WHERE customer_id = 1
  AND status = 'Delivered';


-- CREATING INDEX TO OPTIMIZE QUERY TIME

CREATE INDEX idx_covering_customer_status_total
    ON orders(customer_id, status);

-- DROP INDEX idx_covering_customer_status_total
 DROP INDEX idx_covering_customer_status_total;

 --- After INdexing
-- Index Only Scan using idx_covering_customer_status_total on orders o  (cost=10000000000.43..10000001103.23 rows=46940 width=13) (actual time=0.027..12.560 rows=46676 loops=1)
-- Index Cond: ((customer_id = 1) AND (status = 'Delivered'::text))
-- Heap Fetches: 0
-- Planning Time: 0.114 ms
-- Execution Time: 15.501 ms


EXPLAIN ANALYZE
SELECT o.customer_id, o.status FROM orders o
WHERE customer_id  = 1
  AND status = 'Delivered';





-- ========== EXERCISE 1.1: Basic SELECT ==========
SELECT * FROM customers;
SELECT customers.first_name, customers.email FROM customers;
SELECT product_name, price FROM products;
SELECT * FROM departments;

-- ========== EXERCISE 1.2: WHERE Clause ==========
-- 5. Find all employees with salary greater than 60000
SELECT * FROM employees
WHERE salary > 60000;

-- 6. Find all products priced under $50
SELECT * FROM products
WHERE price < 50;

-- 7. Find all customers from 'New York'
SELECT * FROM customers
WHERE city = 'New York';

-- 8. Find all orders with status 'Shipped'
SELECT * FROM orders
WHERE status = 'Shipped';

-- 9. Find all employees hired after '2021-01-01'
SELECT * FROM employees
WHERE hire_date > '2021-01-01';

-- 10. Find products in the Electronics category (category_id = 1)
SELECT * FROM products
WHERE category_id = 1;

-- ========== EXERCISE 1.3: WHERE with Multiple Conditions ==========
-- 11. Find employees in department_id 2 with salary > 65000
SELECT * FROM employees
WHERE department_id = 2
  AND salary > 65000;

-- 12. Find products with price between $20 and $100
SELECT * FROM products
WHERE price BETWEEN 20 AND 100;

-- 13. Find customers from either 'New York' or 'Los Angeles'
SELECT * FROM customers
WHERE city = 'New York' OR city = 'Los Angeles';

-- 14. Find orders placed in 2023 with status 'Delivered'
SELECT * FROM orders
WHERE EXTRACT(YEAR FROM order_date) = 2023 AND status = 'Delivered';

-- 15. Find products NOT in category 1 (Electronics)
SELECT * FROM products
WHERE category_id != 1;

-- ========== EXERCISE 1.4: Sorting and Limiting ==========
-- 16. List all employees ordered by salary (highest first)
SELECT * FROM employees
ORDER BY salary DESC;

-- 17. List all products ordered by price (lowest first)
SELECT * FROM products
ORDER BY price ASC;

-- 18. Find the 5 most expensive products
SELECT * FROM products
ORDER BY price DESC LIMIT 5;

-- 19. Find the 10 newest customers (by registration_date)
SELECT * FROM customers
ORDER BY registration_date DESC LIMIT 10;

-- 20. List employees alphabetically by last name
SELECT * FROM employees
ORDER BY last_name ASC;

-- ============================================
-- LEVEL 2: INTERMEDIATE - JOINS
-- ============================================

-- ========== EXERCISE 2.1: INNER JOIN ==========
-- 21. List all employees with their department names
SELECT E.first_name, E.last_name, E.email, D.dept_name
FROM employees AS E
         JOIN departments AS D ON D.id = E.department_id;

-- 22. List all products with their category names
SELECT * FROM products p
                  JOIN categories c ON p.category_id = c.id;

-- 23. List all orders with customer names
SELECT * FROM orders O
                  JOIN customers AS C ON O.customer_id = C.id;

-- 24. Find employee names and their manager names
SELECT * FROM employees
                  JOIN departments d ON d.id = employees.department_id;

-- 25. List order items with product names and prices
SELECT * FROM orders AS O
                  JOIN products AS P ON O.id = P.id;

-- ========== EXERCISE 2.2: Multiple JOINS ==========
-- 26. List all order items with: order date, customer name, and product name
SELECT o.order_date,
       c.first_name || ' ' || c.last_name AS customer_name,
       p.product_name,
       oi.quantity
FROM order_items oi
         INNER JOIN orders o ON oi.order_id = o.id
         INNER JOIN customers c ON c.id = o.customer_id
         INNER JOIN products p ON oi.product_id = p.id;

-- 27. Show employees with department name and location
SELECT e.first_name, e.last_name, d.dept_name, d.location
FROM employees e
         INNER JOIN departments AS d ON d.id = e.department_id;

-- 28. List products with category name and description
SELECT p.product_name, p.price, c.category_name, c.description
FROM products p
         INNER JOIN categories AS c ON p.category_id = c.id;

-- 29. Show order details: customer name, order date, product name, quantity
SELECT c.first_name || ' ' || c.last_name AS customer_name,
       O.order_date AS orderDate,
       P.product_name AS ProductName,
       OI.quantity AS Quantity
FROM orders O
         INNER JOIN customers AS C ON O.customer_id = C.id
         INNER JOIN order_items AS OI ON O.id = OI.order_id
         INNER JOIN products AS P ON P.id = OI.product_id;

-- 30. Find all Employees with their department and manager (if they have one)
SELECT e.first_name || ' ' || e.last_name AS employee,
       de.dept_name,
       m.first_name || ' ' || m.last_name AS manager
FROM employees AS E
         INNER JOIN departments AS DE ON E.department_id = DE.id
         INNER JOIN employees AS m ON m.manager_id = e.manager_id;

-- ========== EXERCISE 2.3: LEFT JOIN ==========
-- 31. List all customers and their orders (including customers with no orders)
SELECT c.first_name, c.last_name, o.id AS order_id, o.order_date
FROM customers c
         LEFT JOIN orders AS o ON c.id = o.customer_id;

-- 32. Show all products and their order items (including never-ordered products)
SELECT p.product_name, oI.order_id, oi.quantity
FROM products p
         LEFT JOIN order_items oI ON p.id = oI.product_id;

-- 33. List all employees and their subordinates (including those without subordinates)
SELECT m.first_name || ' ' || m.last_name AS manager,
       e.first_name || ' ' || e.last_name AS employee
FROM employees m
         LEFT JOIN employees E ON m.id = E.manager_id
WHERE m.id IN (SELECT DISTINCT manager_id FROM employees WHERE manager_id IS NOT NULL);

SELECT * FROM employees;

-- 34. Show all categories and their products (including empty categories)
-- (Query not provided in original)

-- 35. List departments with employee count (including departments with 0 employees)
SELECT COUNT(e.id) AS EMPLOYEE_COUNT
FROM departments d
         FULL JOIN employees e ON d.id = e.department_id
GROUP BY d.id, d.dept_name;

-- ============================================
-- LEVEL 3: ADVANCED - AGGREGATION & GROUP BY
-- ============================================

-- ========== EXERCISE 3.1: Basic Aggregation ==========
-- 36. Count total number of employees
SELECT COUNT(employees.id) AS Employee_COUNT FROM employees;

-- 37. Find the average salary of all employees
SELECT AVG(salary) FROM employees;

-- 38. Find the highest and lowest product prices
SELECT MIN(products.price) AS Min_price, MAX(products.price) AS Max_price FROM products;

-- 39. Calculate total revenue from all orders
SELECT SUM(orders.total_amount) AS Total_revenue FROM orders;

-- 40. Count how many orders each customer has placed
SELECT orders.customer_id,
       COUNT(*) AS number_of_order_placed_by_customer
FROM orders
GROUP BY customer_id;

-- ========== EXERCISE 3.2: GROUP BY ==========
-- 41. Count employees per department
SELECT d.dept_name, COUNT(e.id)
FROM departments d
         LEFT JOIN employees e ON d.id = e.department_id
GROUP BY d.dept_name;

SELECT d.dept_name, COUNT(e.id)
FROM departments AS d
         JOIN employees AS E ON d.id = e.department_id
GROUP BY d.dept_name;

SELECT * FROM employees;
SELECT * FROM departments;

-- 42. Calculate average salary per department
SELECT d.dept_name, AVG(e.salary)
FROM employees e
         JOIN departments AS d ON e.department_id = d.id
GROUP BY d.id, d.dept_name;

-- 43. Find total sales per product
SELECT p.product_name,
       SUM(oi.unit_price * oi.quantity) AS total_sales_per_product
FROM order_items oi
         JOIN orders o ON oi.order_id = o.id
         JOIN products p ON p.id = oi.product_id
GROUP BY p.id, product_name
ORDER BY total_sales_per_product DESC;

-- 44. Count orders per customer
SELECT c.first_name || ' ' || c.last_name AS Fullname, COUNT(o.id)
FROM customers c
         LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id;

-- 45. Find the number of products in each category
SELECT * FROM categories;
SELECT * FROM products;

SELECT c.id, c.category_name, COUNT(p.id)
FROM categories c
         LEFT JOIN products p ON c.id = p.category_id
GROUP BY c.id, c.category_name;

-- ========== EXERCISE 3.3: HAVING Clause ==========
-- 46. Find departments with more than 2 employees
SELECT d.dept_name, COUNT(e.id) AS employee_count
FROM employees e
         LEFT JOIN departments d ON e.department_id = d.id
GROUP BY d.id, d.dept_name
HAVING COUNT(e.id) > 2;

-- 47. Find products that have been ordered more than 3 times
SELECT p.product_name, COUNT(oi.id)
FROM products p
         INNER JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.product_name
HAVING COUNT(oi.id) > 3;

-- 48. Find customers who have placed more than 2 orders
SELECT c.first_name || ' ' || c.last_name AS Full_name,
       COUNT(o.id)
FROM customers c
         INNER JOIN orders o ON o.customer_id = c.id
GROUP BY Full_name
HAVING COUNT(o.id) > 2;

-- 49. Find categories with average product price > $50
SELECT c.category_name,
       AVG(p.price)
FROM categories c
         INNER JOIN products p ON c.id = p.category_id
GROUP BY c.id, c.category_name
HAVING AVG(p.price) > 50;

-- 50. Find departments with average salary > $65,000
SELECT d.dept_name, AVG(e.salary)
FROM departments d
         INNER JOIN employees e ON e.department_id = d.id
GROUP BY d.id, d.dept_name
HAVING AVG(e.salary) > 65000;

-- ========== EXERCISE 3.4: Complex Aggregation ==========
-- 51. Find the top 5 customers by total spending
SELECT c.id,
       c.first_name || ' ' || c.last_name AS Full_name,
       SUM(o.total_amount) AS total_spent
FROM customers c
         INNER JOIN orders o ON c.id = o.id
GROUP BY c.id
ORDER BY total_spent DESC
LIMIT 5;

-- 52. Calculate monthly revenue for 2023
SELECT EXTRACT(MONTH FROM o.order_date) AS month,
       SUM(o.total_amount)
FROM orders o
WHERE EXTRACT(YEAR FROM o.order_date) = 2023
GROUP BY month
ORDER BY month;

-- 53. Find products that have never been ordered
SELECT * FROM products pr
                  LEFT JOIN order_items o ON pr.id = o.product_id
WHERE o.id IS NULL;

-- 54. Find the most popular product (by quantity sold)
SELECT p.product_name,
       COUNT(p.id) AS count,
       SUM(oi.unit_price * oi.quantity) AS total_sold
FROM products p
         JOIN order_items oi ON oi.product_id = p.id
GROUP BY p.product_name
ORDER BY total_sold DESC
LIMIT 1;

-- 55. Calculate total sales per product category
SELECT c.category_name,
       SUM(o.quantity * o.unit_price) AS amount_of_sales
FROM categories c
         INNER JOIN products p ON p.category_id = c.id
         INNER JOIN order_items o ON p.id = o.product_id
GROUP BY c.category_name
ORDER BY amount_of_sales DESC;

-- ============================================
-- LEVEL 4: EXPERT - SUBQUERIES & ADVANCED
-- ============================================

-- ========== EXERCISE 4.1: Subqueries ==========
-- 56. Find employees earning more than the average salary
SELECT e.first_name || ' ' || e.last_name AS name, salary
FROM employees e
WHERE e.salary > (SELECT AVG(salary) FROM employees);

-- 57. Find products more expensive than the average product in their category
SELECT p.product_name, p.price, c.category_name
FROM products p
         INNER JOIN categories c ON p.category_id = c.id
WHERE p.price > (
    SELECT AVG(pr.price) FROM products pr
    WHERE pr.category_id = p.category_id
);

-- 58. Find customers who have spent more than the average customer (Version 1)
SELECT c.id,
       c.first_name || ' ' || c.last_name,
       SUM(o.total_amount) AS total_order
FROM orders o
         INNER JOIN customers c ON c.id = o.customer_id
WHERE total_amount > (
    SELECT AVG(oi.total_amount) FROM orders oi
    WHERE oi.customer_id = o.customer_id
)
GROUP BY c.id;

-- 58. Find customers who have spent more than average (Version 2)
SELECT c.first_name || ' ' || c.last_name AS customer,
       SUM(o.total_amount) AS total_spent
FROM customers c
         INNER JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.first_name, c.last_name
HAVING SUM(o.total_amount) > (
    SELECT AVG(customer_total)
    FROM (
             SELECT SUM(total_amount) AS customer_total
             FROM orders
             GROUP BY customer_id
         ) avg_spending
);

-- 59. Find the department with the highest average salary
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM departments d
         INNER JOIN employees e ON d.id = e.department_id
GROUP BY d.dept_name
ORDER BY avg_salary DESC
LIMIT 1;

-- 60. Find products that cost more than all products in the 'Books' category
SELECT p.product_name, p.price
FROM products p
WHERE p.price > (
    SELECT MAX(p.price) FROM products p
    WHERE p.category_id = (SELECT c.id FROM categories c WHERE category_name = 'Books')
)
ORDER BY p.price DESC;

-- ========== EXERCISE 4.2: Window Functions ==========
-- 61. Rank employees by salary within each department
SELECT e.first_name || ' ' || e.last_name AS Full_name,
       e.salary,
       d.dept_name,
       RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS salary_rank
FROM employees e
         JOIN departments d ON e.department_id = d.id;

-- 63. Calculate running total of orders by date
SELECT EXTRACT(YEAR FROM o.order_date),
       o.total_amount,
       SUM(o.total_amount) OVER (ORDER BY order_date) AS running_total
FROM orders o
ORDER BY o.order_date;

SELECT first_name,
       department_id,
       salary,
       AVG(salary) OVER (PARTITION BY department_id ORDER BY first_name ASC) AS dept_avg
FROM employees
GROUP BY first_name, department_id, salary;

SELECT order_date, total_amount,
       SUM(total_amount) OVER (ORDER BY orders.order_date) AS running_total
FROM orders
ORDER BY order_date;

-- 64. Find customers who ordered both Electronics AND Clothing
SELECT DISTINCT c.first_name || ' ' || c.last_name AS Full_name
FROM customers c
WHERE c.id IN (
    SELECT o.customer_id
    FROM orders o
             JOIN order_items oi ON o.id = oi.order_id
             JOIN products p ON oi.product_id = p.id
    WHERE p.category_id = 1
)
  AND c.id IN (
    SELECT o.customer_id
    FROM orders o
             JOIN order_items oi ON o.id = oi.order_id
             JOIN products p ON oi.product_id = p.id
    WHERE p.category_id = 2
);

-- Find employees with orders having quantity > 5
SELECT employees.last_name FROM employees
WHERE id IN (
    SELECT o.customer_id FROM orders o
                                  JOIN order_items oi ON o.id = oi.order_id
    WHERE oi.quantity > 5
);

-- Find employees hired in the same month as their manager
SELECT e.first_name || ' ' || e.last_name AS Employee_Full_name,
       m.first_name || '' || m.last_name AS Manager_Full_name,
       e.hire_date AS Employee_hired_date,
       m.hire_date AS Manager_hired_date
FROM employees e
         JOIN employees m ON e.manager_id = m.id
WHERE EXTRACT(YEAR FROM e.hire_date) = EXTRACT(YEAR FROM m.hire_date)
  AND EXTRACT(MONTH FROM e.hire_date) = EXTRACT(MONTH FROM m.hire_date);

-- ============================================
-- ADDITIONAL JOIN PRACTICE
-- ============================================

-- Customer total spending
SELECT c.first_name || ' ' || c.last_name AS customer_name, SUM(o.total_amount)
FROM customers c
         INNER JOIN orders o ON c.id = o.customer_id
GROUP BY customer_name;

-- Get all products with their categories (LEFT JOIN to include products without category)
SELECT p.product_name, p.price, c.category_name, c.description
FROM products p
         LEFT JOIN categories c ON p.category_id = c.id;

-- Insert sample data
-- INSERT INTO products (id, product_name, category_id, price, stock_quantity) VALUES (93923, 'Microphone', NULL, 12.99, 234);
-- INSERT INTO customers (first_name, last_name, email, city, country, registration_date) VALUES ('Ahmed', 'ismail', 'Ahmedismail@gmail.com', 'Brooklyn Park', 'USA', '2026-01-01');

-- Customer order counts
SELECT c.first_name || ' ' || c.last_name AS customer_name,
       COUNT(o.id) AS order_count,
       c.email
FROM customers c
         LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY customer_name, c.email
ORDER BY order_count DESC;

-- New York customers with their orders
SELECT c.first_name, c.last_name, o.order_date, o.total_amount
FROM customers c
         INNER JOIN orders o ON c.id = o.customer_id
WHERE c.city = 'New York'
ORDER BY o.order_date;

-- Full order details with customer and product info
SELECT c.first_name || ' ' || c.last_name AS customer_name,
       o.order_date,
       p.product_name,
       oi.quantity
FROM customers c
         INNER JOIN orders o ON o.customer_id = c.id
         INNER JOIN order_items oi ON o.id = oi.order_id
         INNER JOIN products p ON oi.product_id = p.id;

-- Products ordered count
SELECT p.product_name,
       COUNT(oi.id) AS times_ordered
FROM products p
         LEFT JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.product_name
ORDER BY times_ordered DESC;

-- Customer average order value
SELECT c.first_name || ' ' || c.last_name AS customer_name,
       AVG(o.total_amount) AS avg_order_value
FROM customers c
         INNER JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.first_name, c.last_name
ORDER BY avg_order_value DESC;

-- Products with categories ordered by category and product name
SELECT p.*, c.*
FROM products p
         INNER JOIN categories c ON p.category_id = c.id
ORDER BY c.category_name, p.product_name;

-- New York customers orders
SELECT c.first_name || ' ' || c.last_name AS Full_name,
       o.order_date,
       o.total_amount
FROM customers c
         INNER JOIN orders o ON c.id = o.customer_id
WHERE c.city = 'New York'
ORDER BY o.order_date;

-- Customers with no orders
SELECT * FROM customers c
                  LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.id IS NULL;

-- Full order details
SELECT c.first_name || ' ' || c.last_name AS customer_name,
       o.order_date,
       p.product_name,
       oi.quantity
FROM customers c
         INNER JOIN orders o ON c.id = o.customer_id
         INNER JOIN order_items oi ON o.id = oi.order_id
         INNER JOIN products p ON oi.product_id = p.id
ORDER BY o.order_date, c.last_name;

-- Self Join: Employee and Manager names
SELECT e.first_name || ' ' || e.last_name AS employee_name,
       m.first_name || ' ' || m.last_name AS manager_name
FROM employees e
         LEFT JOIN employees m ON e.manager_id = m.id;

SELECT * FROM employees;

-- Category total revenue
SELECT c.category_name,
       SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM categories c
         LEFT JOIN products p ON c.id = p.category_id
         INNER JOIN order_items oi ON p.id = oi.product_id
GROUP BY c.category_name
ORDER BY total_revenue;

-- Products order frequency
SELECT p.product_name, COUNT(oi.id) AS times_ordered
FROM products p
         INNER JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.product_name
ORDER BY times_ordered DESC;

-- Customer average order amount
SELECT c.first_name, AVG(o.total_amount) AS Avg_per_customer
FROM orders o
         INNER JOIN customers c ON o.customer_id = c.id
GROUP BY c.first_name
ORDER BY Avg_per_customer DESC;

-- Customers with orders (using IN)
SELECT c.first_name || ' ' || c.last_name AS customer_name
FROM customers c
WHERE c.id IN (SELECT customer_id FROM orders)
ORDER BY c.first_name DESC;

-- Exercise 12: Employees below average salary
SELECT e.first_name || ' ' || e.last_name AS emp_name, e.salary
FROM employees e
WHERE e.salary < (SELECT AVG(em.salary) FROM employees em);

-- Exercise 13: Products that have been ordered (using IN)
SELECT p.product_name, p.price
FROM products p
WHERE p.id IN (SELECT oi.product_id FROM order_items oi)
ORDER BY p.price DESC;

-- Cheapest product
SELECT p.product_name, p.price
FROM products p
WHERE p.price = (SELECT MIN(p2.price) FROM products p2);

-- Exercise 15: Employee salary vs company average
SELECT e.salary AS EMPLOYEE_SALARY,
       a.avg_salary AS AVG_EMPLOYEE_AVG,
       e.salary - a.avg_salary AS difference
FROM employees e
         CROSS JOIN (SELECT AVG(em.salary) AS avg_salary FROM employees em) a
WHERE e.salary - a.avg_salary > 1;

-- Category average prices
SELECT c.category_name, AVG(p.price)
FROM products p
         INNER JOIN categories c ON p.category_id = c.id
GROUP BY c.category_name;

-- Products above category average
SELECT p2.product_name, c.category_name, p2.price
FROM products p2
         INNER JOIN categories c ON p2.category_id = c.id
WHERE p2.price > (
    SELECT AVG(p.price) FROM products p
    WHERE p.category_id = c.id
)
ORDER BY c.category_name, p2.price DESC;

-- Exercise 17: Customers who bought Electronics (EXISTS)
SELECT DISTINCT c.first_name || ' ' || c.last_name AS customer_name
FROM customers c
WHERE EXISTS (
    SELECT 1 FROM orders o
                      INNER JOIN order_items oi ON o.id = oi.order_id
                      INNER JOIN products p ON oi.product_id = p.id
    WHERE o.customer_id = c.id AND p.category_id = 1
);

-- Exercise 18: Departments with no employees
SELECT d.dept_name
FROM departments d
WHERE NOT EXISTS (
    SELECT 1 FROM employees em
    WHERE d.id = em.department_id
);

-- Exercise 19: Product rank within category (correlated subquery)
SELECT p.product_name, p.price, c.category_name,
       (SELECT COUNT(*) + 1 FROM products p2
        WHERE p2.category_id = p.category_id AND p2.price > p.price) AS price_rank
FROM products p
         INNER JOIN categories c ON p.category_id = c.id
ORDER BY c.category_name, price_rank;

-- Employees with department average
SELECT e.first_name || ' ' || e.last_name AS full_name,
       AVG(e.salary),
       d.dept_name
FROM employees e
         INNER JOIN departments d ON e.department_id = d.id
GROUP BY full_name, d.dept_name;

-- Exercise 20: Employees above department average
SELECT e.first_name || ' ' || e.last_name AS full_name,
       e.salary,
       d.dept_name,
       (SELECT AVG(salary) FROM employees e2 WHERE e2.department_id = e.department_id) AS dept_avg
FROM employees e
         INNER JOIN departments d ON e.department_id = d.id
WHERE e.salary > (
    SELECT AVG(e3.salary) FROM employees e3
    WHERE e3.department_id = e.department_id
)
ORDER BY d.dept_name, e.salary DESC;

-- Highest spenders and their orders
SELECT hs.full_name, hs.Total_customer_order, o.order_date, o.total_amount
FROM (
         SELECT c.id,
                c.first_name || ' ' || c.last_name AS full_name,
                SUM(o.total_amount) AS Total_customer_order
         FROM customers c
                  INNER JOIN orders o ON o.customer_id = c.id
         GROUP BY full_name, c.id
         HAVING SUM(o.total_amount) > 1000
     ) hs
         INNER JOIN orders o ON hs.id = o.customer_id
ORDER BY hs.Total_customer_order DESC, o.order_date;

-- Customers who bought from 3+ categories (using IN)
SELECT c.first_name || ' ' || c.last_name AS customer_name
FROM customers c
WHERE c.id IN (
    SELECT o.customer_id FROM orders o
                                  INNER JOIN order_items oi ON o.id = oi.order_id
                                  INNER JOIN products p ON oi.product_id = p.id
    GROUP BY o.customer_id
    HAVING COUNT(DISTINCT p.category_id) >= 3
)
GROUP BY customer_name;

-- Customers who bought from 3+ categories (using JOIN)
SELECT c.first_name || ' ' || c.last_name AS customer_name,
       COUNT(DISTINCT p.category_id) AS category_count
FROM customers c
         INNER JOIN orders o ON c.id = o.customer_id
         INNER JOIN order_items oi ON o.id = oi.order_id
         INNER JOIN products p ON oi.product_id = p.id
GROUP BY c.id, c.first_name, c.last_name
HAVING COUNT(DISTINCT p.category_id) >= 3
ORDER BY category_count DESC;

-- Top 3 best-selling products (Version 1)
SELECT p.product_name,
       SUM(oi.unit_price * oi.quantity) AS total_amount_spent,
       SUM(oi.quantity) AS total_sum
FROM orders o
         INNER JOIN order_items oi ON o.id = oi.order_id
         INNER JOIN products p ON oi.product_id = p.id
GROUP BY p.product_name
ORDER BY total_sum DESC
LIMIT 3;

-- Top 3 best-selling products (Version 2 - using subquery)
SELECT p.product_name, total_sales.total_quantity_sold
FROM products p
         INNER JOIN (
    SELECT product_id,
           SUM(quantity) AS total_quantity_sold
    FROM order_items
    GROUP BY product_id
    ORDER BY total_quantity_sold DESC
    LIMIT 3
) total_sales ON p.id = total_sales.product_id
ORDER BY total_sales.total_quantity_sold DESC;

-- Exercise 24: Customers with 2+ orders AND $500+ spent (using JOIN)
SELECT c.first_name || ' ' || c.last_name AS customer_name,
       COUNT(o.id) AS order_count,
       SUM(o.total_amount) AS total_spent
FROM customers c
         INNER JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.first_name, c.last_name
HAVING COUNT(o.id) > 2 AND SUM(o.total_amount) > 500
ORDER BY total_spent DESC;

-- Exercise 24: Customers with 2+ orders AND $500+ spent (using subquery)
SELECT c.first_name || ' ' || c.last_name AS customer_name,
       total_sale.total_order,
       total_sale.total_spent
FROM customers c
         INNER JOIN (
    SELECT customer_id,
           COUNT(*) AS total_order,
           SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
    HAVING SUM(total_amount) > 500 AND COUNT(*) > 2
) AS total_sale ON c.id = total_sale.customer_id
ORDER BY total_sale.total_spent DESC;

-- Customer order totals
SELECT SUM(o.customer_id) AS customer_order, o.total_amount
FROM orders o
GROUP BY o.total_amount;

-- Exercise 25: Categories above store average price
SELECT AVG(pk.price) FROM products pk;
SELECT * FROM categories;

SELECT c.category_name,
       AVG(p.price),
       (SELECT AVG(pl.price) FROM products pl) AS store_avg
FROM categories c
         INNER JOIN products p ON c.id = p.category_id
GROUP BY CUBE (c.category_name)
HAVING AVG(p.price) > (SELECT AVG(pk.price) FROM products pk);

-- Index examples
-- CREATE INDEX idx_orders_customer_id ON orders(customer_id);
-- DROP INDEX idx_orders_customer_id;

SELECT * FROM orders WHERE customer_id = 1;

-- Exercise 26: Customers who bought BOTH Electronics AND Clothing (Version 1)
SELECT DISTINCT c.first_name || ' ' || c.last_name AS full_name
FROM customers c
         INNER JOIN orders o ON c.id = o.customer_id
         INNER JOIN order_items oi ON o.id = oi.order_id
         INNER JOIN products p ON oi.product_id = p.id
         INNER JOIN categories cat ON p.category_id = cat.id
WHERE cat.category_name IN ('Electronics', 'Clothing')
ORDER BY full_name;

-- Exercise 26: Customers who bought BOTH Electronics AND Clothing (Version 2 - using subqueries)
SELECT DISTINCT c.first_name || ' ' || c.last_name AS full_name
FROM customers c
WHERE c.id IN (
    SELECT o.customer_id FROM orders o
                                  INNER JOIN order_items oi ON o.id = oi.order_id
                                  INNER JOIN products p ON oi.product_id = p.id
    WHERE p.category_id = 1
)
  AND c.id IN (
    SELECT o.customer_id FROM orders o
                                  INNER JOIN order_items oi ON o.id = oi.order_id
                                  INNER JOIN products p ON oi.product_id = p.id
    WHERE p.category_id = 2
);

-- Products more expensive than all Books
SELECT c.category_name, p2.product_name, p2.price
FROM products p2
         INNER JOIN categories c ON p2.category_id = c.id
WHERE p2.price > (
    SELECT MAX(p.price) AS total_cost_of_all_books FROM products p
                                                            INNER JOIN categories c ON p.category_id = c.id
    WHERE category_name = 'Books'
    GROUP BY c.category_name
);

SELECT p.product_name,
       p.price,
       c.category_name
FROM products p
         INNER JOIN categories c ON p.category_id = c.id
WHERE p.price > (
    SELECT MAX(price)
    FROM products p2
             INNER JOIN categories c2 ON p2.category_id = c2.id
    WHERE c2.category_name = 'Books'
)
ORDER BY p.price DESC;

-- Category comparison with store average
SELECT c.category_name,
       COUNT(p.id) AS product_count,
       ROUND(AVG(p.price), 2) AS avg_price,
       ROUND((SELECT AVG(price) FROM products), 2) AS store_avg,
       CASE
           WHEN AVG(price) > (SELECT AVG(price) FROM products)
               THEN 'Above average'
           ELSE 'Below Average'
           END AS comparison
FROM categories c
         INNER JOIN products p ON c.id = p.category_id
GROUP BY c.category_name;

-- ============================================
-- GROUPING SETS, ROLLUP, CUBE
-- ============================================

-- Sales by category and country with grouping sets
SELECT c.category_name,
       cu.country,
       SUM(oi.quantity * oi.unit_price) AS total_sales,
       COUNT(DISTINCT o.id) AS num_orders
FROM order_items oi
         JOIN orders o ON oi.order_id = o.id
         JOIN products p ON oi.product_id = p.id
         JOIN categories c ON p.category_id = c.id
         JOIN customers cu ON o.customer_id = cu.id
GROUP BY GROUPING SETS (
    (c.category_name, cu.country),
    (c.category_name),
    (cu.country),
    ()
    )
ORDER BY GROUPING(c.category_name),
         GROUPING(cu.country),
         c.category_name,
         cu.country;

-- Sales by status and month with ROLLUP
SELECT o.status,
       TO_CHAR(o.order_date, 'YYYY-MM') AS order_month,
       SUM(oi.quantity * oi.unit_price) AS total_sales,
       COUNT(DISTINCT o.id) AS num_orders
FROM orders o
         JOIN order_items oi ON o.id = oi.order_id
GROUP BY ROLLUP (o.status, TO_CHAR(o.order_date, 'YYYY-MM'));

-- Basic GROUP BY
SELECT department_id, SUM(salary)
FROM employees
GROUP BY department_id;

-- ROLLUP example
SELECT department_id,
       EXTRACT(YEAR FROM hire_date) AS hire_year,
       SUM(salary)
FROM employees
GROUP BY ROLLUP (department_id, EXTRACT(YEAR FROM hire_date));

-- CUBE example
SELECT department_id,
       EXTRACT(YEAR FROM hire_date) AS hire_year,
       SUM(salary)
FROM employees
GROUP BY CUBE (department_id, EXTRACT(YEAR FROM hire_date));

-- GROUPING SETS example
SELECT department_id,
       EXTRACT(YEAR FROM hire_date) AS hire_year,
       SUM(salary)
FROM employees
GROUP BY GROUPING SETS (
    (department_id),
    (EXTRACT(YEAR FROM hire_date)),
    ()
    );

-- Hire year counts with GROUPING function
SELECT EXTRACT(YEAR FROM hire_date) AS date_ordered,
       COUNT(id),
       CASE
           WHEN GROUPING(EXTRACT(YEAR FROM hire_date)) = 1 THEN 'Total'
           ELSE CAST(EXTRACT(YEAR FROM hire_date) AS VARCHAR)
           END AS hire_year
FROM employees
GROUP BY GROUPING SETS (
    EXTRACT(YEAR FROM hire_date),
    ()
    );

SELECT * FROM employees;

-- CUBE with department and manager
SELECT department_id, manager_id, SUM(salary)
FROM employees
GROUP BY CUBE (department_id, manager_id);

-- GROUPING SETS with department and manager
SELECT department_id, manager_id, SUM(salary)
FROM employees
GROUP BY GROUPING SETS (
    (department_id),
    (manager_id)
    );

-- ============================================
-- CTEs (Common Table Expressions)
-- ============================================

-- Sample CTE
WITH total_sales AS (
    SELECT department_id, manager_id, SUM(salary)
    FROM employees
    GROUP BY department_id, manager_id
), top_region AS (
    SELECT department_id, manager_id FROM total_sales
)
SELECT employees.manager_id FROM employees;

-- High salary employees in Sales
WITH high_salary AS (
    SELECT * FROM employees
    WHERE salary > 70000
),
     engineering AS (
         SELECT * FROM departments
         WHERE dept_name = 'Sales'
     )
SELECT e.first_name, e.salary
FROM high_salary e
         JOIN engineering d ON e.department_id = d.id;

-- Department averages
WITH dept_avg AS (
    SELECT department_id,
           AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
)
SELECT * FROM dept_avg
WHERE avg_salary > 65000
ORDER BY department_id ASC;

-- Employees above department average using CTE
WITH dept_avgs AS (
    SELECT e.id, e.first_name, e.department_id, e.salary,
           AVG(e.salary) OVER (PARTITION BY e.department_id) AS dept_avg_salary
    FROM employees e
),
     depts_row AS (
         SELECT id, dept_name FROM departments
     )
SELECT *
FROM dept_avgs
         JOIN depts_row ON dept_avgs.department_id = depts_row.id
WHERE salary > dept_avg_salary;

-- Customer categories
WITH customer_categories AS (
    SELECT DISTINCT o.customer_id, p.category_id
    FROM orders o
             JOIN order_items oi ON o.id = oi.order_id
             JOIN products p ON oi.product_id = p.id
)
SELECT * FROM customer_categories;

-- Top 25% customers by average order value
WITH customer_avg_orders AS (
    SELECT c.id,
           c.first_name || ' ' || c.last_name AS customer_name,
           AVG(o.total_amount) AS avg_order_value
    FROM customers c
             INNER JOIN orders o ON c.id = o.customer_id
    GROUP BY c.id, c.first_name, c.last_name
),
     percentile_75 AS (
         SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY avg_order_value) AS p75_value
         FROM customer_avg_orders
     )
SELECT cao.customer_name,
       ROUND(cao.avg_order_value, 2) AS avg_order_value,
       'Top 25%' AS percentile
FROM customer_avg_orders cao
         CROSS JOIN percentile_75 p
WHERE cao.avg_order_value >= p.p75_value
ORDER BY cao.avg_order_value DESC;

SELECT * FROM employees_2021;

-- Update example (commented out)
-- UPDATE employees_2020 SET hire_date = '2023-01-23', id = 33 WHERE id = 1;

-- CTE with DELETE and INSERT (data migration)
-- WITH delete_row_and_Insert_into_employee_2020 AS (
--     DELETE FROM employees_2020
--     WHERE id = 33
--     RETURNING *
-- )
-- INSERT INTO employees_2021
-- SELECT * FROM delete_row_and_Insert_into_employee_2020;

-- ============================================
-- TABLE CREATION EXAMPLES
-- ============================================

-- World flag table
-- CREATE TABLE World_flag (
--     _id NUMERIC(4,2) NOT NULL,
--     country_name VARCHAR(10) NOT NULL
-- );

-- INSERT INTO World_flag (_id, country_name) VALUES (12.22, 'USA');

SELECT * FROM UFA_CUP;

-- UFA CUP table
-- CREATE TABLE UFA_CUP (
--     _id BIGINT GENERATED ALWAYS AS IDENTITY,
--     country_name VARCHAR(10) NOT NULL
-- );

-- Payments table with UUID
-- CREATE TABLE PAYMENTS (
--     _id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--     payment_id BIGINT GENERATED ALWAYS AS IDENTITY (START WITH 3001),
--     amount NUMERIC(12,2) NOT NULL,
--     payer_name VARCHAR(100)
-- );

-- INSERT INTO PAYMENTS (amount, payer_name) VALUES (1023, 'Mohamed Abdullahi');

SELECT * FROM PAYMENTS;

-- Type casting examples
SELECT '12.34'::FLOAT8::NUMERIC::MONEY;
SELECT CHAR_LENGTH('hello');

-- Timezone examples
SELECT '2026-01-19 02:00'::TIMESTAMPTZ AT TIME ZONE 'America/Chicago';

-- Meetings table
-- CREATE TABLE meetings (
--     id SERIAL PRIMARY KEY,
--     title TEXT,
--     start_time TIMESTAMPTZ
-- );

-- INSERT INTO meetings(title, start_time) VALUES ('ND Meeting', '2026-01-20 14:00:00-5');

-- Query meetings in different timezones
SELECT id, title,
       start_time AT TIME ZONE 'America/New_York' AS ny_time,
       start_time AT TIME ZONE 'America/Los_Angeles' AS la_time,
       start_time AT TIME ZONE 'America/Chicago' AS ci_time
FROM meetings;

-- Payments table with timezone
-- CREATE TABLE payments (
--     id BIGSERIAL PRIMARY KEY,
--     user_id UUID NOT NULL,
--     amount NUMERIC(12,2) NOT NULL,
--     currency CHAR(3) NOT NULL DEFAULT 'USD',
--     payment_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
--     status VARCHAR(20) NOT NULL DEFAULT 'pending'
-- );

-- INSERT INTO payments (user_id, amount, payment_time) VALUES ('3fa85f64-5717-4562-b3fc-2c963f66afa6', 2290.00, '2026-01-19 02:27:28-6');
-- INSERT INTO payments (user_id, amount, payment_time) VALUES ('3fa85f64-5717-4562-b3fc-2c963f66afa6', 12220.00, '2026-01-19T21:27:28Z');

SELECT id, user_id, amount,
       payment_time AT TIME ZONE 'America/Chicago' AS mn_time
FROM payments;

-- ============================================
-- JSON/JSONB EXAMPLES
-- ============================================

SELECT '{"bar": "baz", "balance": 7.77, "active": false}'::JSON;

SELECT '[1,2,3]'::JSONB @> '[1,3]'::JSONB;  -- true
SELECT '{"a":1, "b":2}'::JSONB @> '{"b":2}'::JSONB;  -- true

-- PaymentK table with JSONB
-- CREATE TABLE paymentK (
--     id SERIAL PRIMARY KEY,
--     user_id UUID,
--     details JSONB
-- );

-- INSERT INTO paymentK (user_id, details) VALUES (
--     '3fa85f64-5717-4562-b3fc-2c963f66afa6',
--     '{"amount": 190.00, "currency": "USD", "method": "card", "date": "2026-01-19T16:27:28-06:00"}'::JSONB
-- );

-- INSERT INTO paymentK (user_id, details) VALUES (
--     '3fa85f64-5717-4562-b3fc-2c963f66afa6',
--     '{"amount": 190.00, "currency": "USD", "method": "card", "date": "2026-01-19T16:27:28-06:00", "name": {"firstname": "Mohamed"}}'::JSONB
-- );

SELECT * FROM paymentK;
SELECT details->'method' AS Method, details->>'amount' FROM paymentK;
SELECT details->'method' AS payment_method FROM paymentK;

-- Update JSONB field
-- UPDATE paymentK
-- SET details['name']['firstname'] = '"Ahmedsddas SImail"'
-- WHERE details['name']['firstname'] = '"AhmeK SImail"'
--   AND user_id = '3fa85f64-5717-4562-b3fc-2c963f66afa6'
--   AND id = 3;

-- Build JSON objects
SELECT jsonb_build_object(
               'user', user_id,
               'amount', details->>'amount',
               'currency', details->>'currency'
       ) AS payment_info
FROM paymentK;

-- Aggregate JSON
SELECT jsonb_agg(
               jsonb_build_object(
                       'user', user_id,
                       'amount', details->>'amount'
               )
       ) AS all_payments
FROM paymentK;

-- Users table with JSONB profile
-- CREATE TABLE users (
--     id SERIAL PRIMARY KEY,
--     profile JSONB
-- );

-- Various INSERT examples for users table (commented out)

SELECT u.id, u.profile::JSONB FROM users u;

SELECT '{"user": {"id": 1, "roles": ["admin", "editor"]}}'::JSONB AS profile;

SELECT * FROM USERS WHERE profile['name'] = '"Mohamed Abdullahi"';

-- EXPLAIN ANALYZE on JSONB query
EXPLAIN ANALYZE
SELECT * FROM USERS WHERE profile['name'] = '"Mohamed Abdullahi"';

-- Create GIN index on JSONB
-- CREATE INDEX idx_users_profile ON users USING GIN (profile->>'name');

-- JSONB path queries
EXPLAIN ANALYZE
SELECT users.profile #> '{Refered, name}' AS ADDRESS FROM users;

SELECT profile -> 'cities' -> 0 AS ADDRESS
FROM users
WHERE profile['name'] = '"Ahmed Abdullahi"'
ORDER BY ADDRESS ASC
LIMIT 1;

SELECT jsonb_agg(profile)
FROM users
WHERE profile['name'] = '"Mohamed Abdullahi"';

SELECT * FROM departments;

-- Convert to JSON
SELECT jsonb_build_object('department', jsonb_build_object(
        'id', d.id, 'dept_name', d.dept_name, 'location', d.location
                                        ))
FROM departments d;

SELECT to_json(d) FROM departments d WHERE d.dept_name = 'Sales';
SELECT jsonb_agg(d) FROM departments d WHERE d.dept_name = 'Sales';

-- ============================================
-- CASE EXPRESSION
-- ============================================

SELECT id, first_name, last_name, hire_date,
       CASE
           WHEN EXTRACT(YEAR FROM hire_date) = 2020 THEN 'last Year'
           ELSE 'This Year'
           END AS grade
FROM employees;

-- ============================================
-- INDEX EXAMPLES
-- ============================================

EXPLAIN ANALYZE
SELECT e.id, e.first_name, e.salary FROM employees e WHERE e.first_name = 'John';

-- CREATE INDEX find_employee_by_name ON employees(first_name);
-- CREATE INDEX find_employee_by_id ON employees(id);

EXPLAIN ANALYZE
SELECT e.id, e.first_name, e.salary FROM employees e WHERE e.id = 1;

EXPLAIN ANALYZE
SELECT * FROM employees WHERE department_id = 2;

-- CREATE INDEX find_employee_by_dep_id ON employees(department_id);

EXPLAIN ANALYZE
SELECT e.first_name, e.last_name, d.dept_name
FROM employees e
         JOIN departments d ON e.department_id = d.id;

-- CREATE INDEX find_order_by_customer_id ON orders(customer_id);

EXPLAIN ANALYZE
SELECT * FROM orders WHERE customer_id = 1;

-- CREATE INDEX find_common ON products(id, category_id);

EXPLAIN ANALYZE
SELECT * FROM products WHERE id = 1 AND category_id = 1;

-- CREATE INDEX find_order_by_date ON orders(customer_id, order_date DESC);

-- SET enable_seqscan = ON;

EXPLAIN ANALYZE
SELECT * FROM orders
WHERE customer_id = 1
  AND order_date >= '2023-01-01'
ORDER BY order_date DESC;

-- ANALYZE orders;

-- CREATE INDEX find_total ON orders(id, customer_id, total_amount);

EXPLAIN ANALYZE
SELECT * FROM orders WHERE id = 1;

-- SET enable_seqscan = ON;

-- CREATE INDEX find_by_id_king ON orders USING btree(id);

EXPLAIN ANALYZE
SELECT * FROM orders WHERE id = 1;



DROP INDEX find_by_id_king_23;
CREATE INDEX find_by_id_king_23 ON orders USING hash(id);



