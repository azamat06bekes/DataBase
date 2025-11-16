CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    dept_id INT,
    salary DECIMAL(10,2),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

CREATE TABLE projects (
    proj_id INT PRIMARY KEY,
    proj_name VARCHAR(100),
    budget DECIMAL(12,2),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

INSERT INTO departments VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Operations', 'Building C');

INSERT INTO employees VALUES
(1, 'Damir', 101, 2500000),
(2, 'Aigul', 101, 2750000),
(3, 'Murat', 102, 2400000),
(4, 'Saule', 102, 2600000),
(5, 'Timur', 103, 3000000);

INSERT INTO projects VALUES
(201, 'Website Redesign', 37500000, 101),
(202, 'Database Migration', 60000000, 101),
(203, 'HR System Upgrade', 25000000, 102);


-- PART 2:
-- Exercise 2.1
CREATE INDEX emp_salary_idx ON employees(salary);

-- Verify the index was created
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';

-- Answer:
-- There are 2 indexes on the employees table - one automatically created
-- for the PRIMARY KEY (emp_id_pkey), and the one we just created (emp_salary_idx).


-- Exercise 2.1
CREATE INDEX emp_dept_idx ON employees(dept_id);

-- Verify the index was created
EXPLAIN SELECT * FROM employees WHERE dept_id = 101;

-- Answer:
-- Indexing foreign key columns is beneficial because:
-- 	 It speeds up JOIN operations between tables
-- 	 It improves the performance of foreign key constraint checks
-- 	 It accelerates queries that filter by the foreign key column


-- Exercise 2.3
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Answer:
-- The automatically created indexes are those for PRIMARY KEY and UNIQUE constraints


-- PART 3:
-- Exercise 3.1
CREATE INDEX emp_dept_salary_idx ON employees(dept_id, salary);

-- Verify the index was created
EXPLAIN SELECT emp_name, salary
FROM employees
WHERE dept_id = 101 AND salary > 26000000;

-- Answer:
-- No, the index (dept_id, salary) would NOT be useful for a query
-- filtering only by salary because in composite indexes, the leading
-- column (dept_id) must be used in the query for the index to be effective.

-- Exercise 3.2
CREATE INDEX emp_salary_dept_idx ON employees(salary, dept_id);

--  Compare with queries
EXPLAIN SELECT * FROM employees WHERE dept_id = 102 AND salary > 25000000;
EXPLAIN SELECT * FROM employees WHERE salary > 25000000 AND dept_id = 102;

-- Answer:
-- Yes, the order of columns in a multicolumn index matters
-- significantly. The index is most effective when queries use the columns
-- in the same order as defined in the index, starting from the left.


-- PART 4:
-- Exercise 2.1
ALTER TABLE employees ADD COLUMN email VARCHAR(100);
UPDATE employees SET email = 'damir2012@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'aigul1992@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'murat1988@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'saule2003@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'timur2015@company.com' WHERE emp_id = 5;

CREATE UNIQUE INDEX emp_email_unique_idx ON employees(email);

--  Test the uniqueness constraint
INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
VALUES (6, 'New Employee', 101, 27500000, 'damir0212@company.com');

-- Answer:
-- We get an error "duplicate key value violates unique constraint 'emp_email_unique_idx'"

-- Exercise 4.2
ALTER TABLE employees ADD COLUMN phone VARCHAR(20) UNIQUE;

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees' AND indexname LIKE '%phone%';

-- Answer:
-- Yes, PostgreSQL automatically created a B-tree index for the UNIQUE constraint on the phone column.


-- PART 5:
-- Exercise 5.1
CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);

EXPLAIN SELECT emp_name, salary
FROM employees
ORDER BY salary DESC;

-- Answer:
-- The DESC index helps ORDER BY queries use index scanning instead
-- of performing expensive sort operations on the result set.

-- Exercise 5.2
CREATE INDEX proj_budget_nulls_first_idx ON projects(budget NULLS FIRST);

EXPLAIN SELECT proj_name, budget
FROM projects
ORDER BY budget NULLS FIRST;


-- PART 6:
-- Exercise 6.1
CREATE INDEX emp_name_lower_idx ON employees(LOWER(emp_name));

EXPLAIN SELECT * FROM employees WHERE LOWER(emp_name) = 'Damir';

-- Answer:
-- Without the expression index, PostgreSQL would perform a sequential table scan and
-- apply the LOWER() function to every row for comparison, which is much slower.

--Exercise 6.2
ALTER TABLE employees ADD COLUMN hire_date DATE;
UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;

CREATE INDEX emp_hire_year_idx ON employees(EXTRACT(YEAR FROM hire_date));

EXPLAIN SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;


-- PART 7:
-- Exercise 7.1
ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;

SELECT indexname FROM pg_indexes WHERE tablename = 'employees';

-- Exercise 7.2
DROP INDEX emp_salary_dept_idx;

-- Answer:
-- You might want to drop an index to:
--  	Free up disk space
--  	Reduce overhead on INSERT/UPDATE/DELETE operations
--  	Remove duplicate or redundant indexes

-- Exercise 7.3
REINDEX INDEX employees_salary_index;

-- PART 8:
-- Exercise 8.1
CREATE INDEX emp_salary_filter_idx ON employees(salary) WHERE salary > 25000000;

EXPLAIN SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 25000000
ORDER BY e.salary DESC;

-- Exercise 8.2
CREATE INDEX proj_high_budget_idx ON projects(budget)
WHERE budget > 40000000;

EXPLAIN SELECT proj_name, budget
FROM projects
WHERE budget > 40000000;

-- Answer:
-- The advantage of a partial index is that it's smaller (only indexes relevant rows), faster,
-- and consumes less disk space since it only includes rows that match the WHERE condition.

-- Exercise 8.3
EXPLAIN SELECT * FROM employees WHERE salary > 26000000;

-- Answer:
-- The output shows "Index Scan" which tells us that PostgreSQL is using the index
-- to efficiently retrieve data instead of scanning the entire table.


-- PART 9:
-- Exercise 9.1
CREATE INDEX dept_name_hash_idx ON departments USING HASH (dept_name);

EXPLAIN SELECT * FROM departments WHERE dept_name = 'IT';

-- Answer:
-- Use HASH indexes only for equality comparisons (=) when you don't need range queries or
-- sorting. B-tree indexes are more versatile and support range queries and ordering.

-- Exercise 9.2
CREATE INDEX proj_name_btree_idx ON projects(proj_name);
CREATE INDEX proj_name_hash_idx ON projects USING HASH (proj_name);

EXPLAIN SELECT * FROM projects WHERE proj_name = 'Website Redesign';
EXPLAIN SELECT * FROM projects WHERE proj_name > 'Database';


-- PART 10:
-- Exercise 10.1
SELECT
   schemaname,
   tablename,
   indexname,
   pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Answer:
-- Typically, indexes on columns with more data or composite indexes with multiple columns
-- are the largest. The exact size depends on the data volume and column types.

-- Exercise 10.2
DROP INDEX IF EXISTS proj_name_hash_idx;

-- Exercise 10.3
CREATE VIEW index_documentation AS
SELECT
   tablename,
   indexname,
   indexdef,
   'Improves salary-based queries' as purpose
FROM pg_indexes
WHERE schemaname = 'public'
AND indexname LIKE '%salary%';

SELECT * FROM index_documentation;

-- Summary Questions Answers:
-- 1.	What is the default index type in PostgreSQL?
-- B-tree

-- 2.Name three scenarios where you should create an index:
--  	Columns frequently used in WHERE clauses
--  	Foreign key columns
--  	Columns used in JOIN conditions

-- 3.Name two scenarios where you should NOT create an index:
--  	On small tables (where sequential scan is faster)
--  	On columns with frequent write operations but rare read operations

-- 4.What happens to indexes when you INSERT, UPDATE, or DELETE data?
-- Indexes are automatically updated, which slows down these write operations because PostgreSQL needs to maintain the index structures.

-- 5.	How can you check if a query is using an index?
-- Use the EXPLAIN or EXPLAIN ANALYZE command before the query to see the execution plan.



--  Additional Challenges
-- Exercise 1
-- Creating an index to optimize the search by month
CREATE INDEX emp_hire_month_idx ON employees(EXTRACT(MONTH FROM hire_date));

-- Testing the request
EXPLAIN ANALYZE
SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(MONTH FROM hire_date) = 1; -- January


-- Exercise 2
-- Creating a composite unique index
CREATE UNIQUE INDEX emp_dept_email_unique_idx ON employees(dept_id, email);

-- Checking the index creation
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees' AND indexname = 'emp_dept_email_unique_idx';

-- Testing the uniqueness constraint
-- This should work (different departments)
INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
VALUES (6, 'New Employee', 102, 27500000, 'damir2012@company.com');

-- This should cause an error (same email in the same department)
INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
VALUES (7, 'Another Employee', 101, 22500000, 'damir2012@company.com');


-- Exercise 3
--Testing a query WITHOUT an index (first we delete the existing index)
DROP INDEX IF EXISTS emp_salary_filter_idx;

-- Query 1: WITHOUT index
EXPLAIN ANALYZE
SELECT emp_name, salary
FROM employees
WHERE salary > 52000 AND dept_id = 101;

-- Creating the index back
CREATE INDEX emp_salary_filter_idx ON employees(salary) WHERE salary > 50000;

-- Query 2: WITH an index
EXPLAIN ANALYZE
SELECT emp_name, salary
FROM employees
WHERE salary > 52000 AND dept_id = 101;


-- Exercise 4
-- Let's say we have a frequent request for employee reporting:
SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE dept_id = 101
ORDER BY salary DESC;

-- Creating a covering index that includes all the necessary columns
CREATE INDEX emp_covering_idx ON employees(dept_id, salary DESC)
INCLUDE (emp_id, emp_name);

-- Testing the covering index
EXPLAIN ANALYZE
SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE dept_id = 101
ORDER BY salary DESC;
