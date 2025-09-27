
-- Ex.1
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    department VARCHAR(50),
    salary INTEGER DEFAULT 0,
    hire_date DATE,
    status VARCHAR(10) DEFAULT 'Active'
);

CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL,
    budget INTEGER,
    manager_id INTEGER
);
CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    dept_id INTEGER,
    start_date DATE,
    end_date DATE
);

-- Ex.2
INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (1, 'Asylhan', 'Badiev', 'HR');

-- Ex.3
INSERT INTO employees (emp_id, first_name, last_name, department, salary, hire_date, status)
VALUES (2, 'Alia', 'Berikkyzy', 'IT', DEFAULT, CURRENT_DATE, DEFAULT);

-- Ex.4
INSERT INTO departments (dept_name, budget, manager_id)
VALUES
('Marketing', 500000, 101),
('Finance', 750000, 102),
('Operations', 400000, 103);

-- Ex.5
INSERT INTO employees (emp_id, first_name, last_name, department, salary, hire_date, status)
VALUES (107, 'Kamila', 'Alimova', 'Marketing', 50000 * 1.1, CURRENT_DATE, DEFAULT);

--  *** Дополнительные данные для UPDATE и DELETE ***
INSERT INTO employees (emp_id, first_name, last_name, department, salary, hire_date, status) VALUES
-- Adil Sultanov - Зарплата > 60000 И дата найма до 2020-01-01 (для Задания 8)
(3, 'Adil', 'Sultanov', 'IT', 75000, '2019-08-15', 'Active'),
-- Dana Myrzakhmet - Зарплата > 80000 (для Задания 9) и отдел Sales (для Задания 12)
(4, 'Dana', 'Myrzakhmet', 'Sales', 95000, '2022-01-01', 'Active'),
-- Alua Zhumagalieva - Отдел Sales (для Задания 12)
(5, 'Alua', 'Zhumagalieva', 'Sales', 65000, '2021-06-15', 'Active'),
-- Nurlan Kenesov - Для тестирования DELETE (Задание 13)
(6, 'Nurlan', 'Kenesov', 'HR', 55000, '2020-03-25', 'Active');

-- Ex.6
-- 1. Создание временной таблицы 'temp_employees'
CREATE TEMPORARY TABLE temp_employees AS
SELECT *
FROM employees
WHERE 1 = 0;

-- 2. Вставка данных из employees, где department = 'IT'
INSERT INTO temp_employees
SELECT *
FROM employees
WHERE department = 'IT';

-- Ex.7
UPDATE employees
SET salary = salary * 1.10;

-- Ex.8
UPDATE employees
SET status = 'Senior'
WHERE salary > 60000 AND hire_date < '2020-01-01';

-- Ex.9
UPDATE employees
SET department = CASE
    WHEN salary > 80000 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
END;


-- Ex.10 (Два шага для Inactive -> General)
UPDATE employees SET status = 'Inactive' WHERE emp_id = 1;

UPDATE employees
SET department = 'General'
WHERE status = 'Inactive';


-- Ex.11
UPDATE departments d
SET budget = (
    SELECT AVG(e.salary) * 1.20
    FROM employees e
    WHERE e.department = d.dept_name
);


-- Ex.12
UPDATE employees
SET
    salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';


-- Ex.13
-- Сначала создадим фиктивного сотрудника для удаления
INSERT INTO employees (emp_id, first_name, last_name, department, salary, hire_date, status)
VALUES (108, 'Berik', 'Terminov', 'None', 0, CURRENT_DATE, 'Terminated');

-- Выполняем DELETE
DELETE FROM employees
WHERE status = 'Terminated';


-- 14. DELETE with complex WHERE clause
-- Сначала вставим сотрудника, который соответствует условиям для удаления
INSERT INTO employees (emp_id, first_name, last_name, department, salary, hire_date, status)
VALUES (109, 'Zhanar', 'Aliyeva', NULL, 35000, '2023-06-01', 'Active');

-- Выполняем DELETE
DELETE FROM employees
WHERE salary < 40000 AND hire_date > '2023-01-01' AND department IS NULL;

-- 15. DELETE with subquery
DELETE FROM departments
WHERE dept_name NOT IN (
    SELECT DISTINCT department
    FROM employees
    WHERE department IS NOT NULL
);

-- 16. DELETE with RETURNING clause
-- Вставим проект для тестирования
INSERT INTO projects (project_name, dept_id, start_date, end_date) VALUES
('Legacy System Migration', 1, '2021-03-01', '2022-12-31');

-- Выполняем DELETE с RETURNING
DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;


-- 17. INSERT with NULL values
INSERT INTO employees (emp_id, first_name, last_name, department, salary, hire_date, status)
VALUES (110, 'Yerlan', 'Tulepov', NULL, NULL, CURRENT_DATE, DEFAULT);

-- 18. UPDATE NULL handling
UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

-- 19. DELETE with NULL conditions
DELETE FROM employees
WHERE salary IS NULL OR department IS NULL;


-- 20. INSERT with RETURNING
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Zhuldyz', 'Nurieva', 'HR', 60000, CURRENT_DATE, DEFAULT)
RETURNING emp_id, first_name || ' ' || last_name AS full_name;

-- 21. UPDATE with RETURNING
UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id, salary - 5000 AS old_salary, salary AS new_salary;

-- 22. DELETE with RETURNING all columns
DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;


-- Ex.23 (Conditional INSERT)
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
SELECT 'Baurzhan', 'Sattarov', 'Finance', 72000, CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1 FROM employees
    WHERE first_name = 'Baurzhan' AND last_name = 'Sattarov'
);


-- Ex.24 (UPDATE с подзапросом)
UPDATE employees
SET salary =
    CASE
        WHEN department IN (SELECT dept_name FROM departments WHERE budget > 100000) THEN salary * 1.10 -- Увеличение на 10%
        ELSE salary * 1.05 -- Иначе на 5%
    END
WHERE department IS NOT NULL;


-- Ex.25 (Bulk Operations)
-- 1. Вставка 5 сотрудников
INSERT INTO employees (first_name, last_name, department, salary, hire_date) VALUES
('Madi', 'Karatay', 'Marketing', 40000, CURRENT_DATE),
('Aizhan', 'Esenova', 'HR', 35000, CURRENT_DATE),
('Askhat', 'Dosan', 'IT', 60000, CURRENT_DATE),
('Ainur', 'Talgat', 'Finance', 45000, CURRENT_DATE),
('Zakir', 'Bekov', 'Operations', 50000, CURRENT_DATE);

-- 2. Обновление зарплаты для всех (Unsafe query, но по заданию)
UPDATE employees
SET salary = salary * 1.10;


-- Ex.26 (Data Migration Simulation)
-- 1. Создание таблицы архива
CREATE TABLE employee_archive AS
SELECT * FROM employees WHERE 1 = 0;

-- 2. Перемещение данных в архив (используем RETURNING для получения перемещенных строк)
WITH moved_employees AS (
    DELETE FROM employees
    WHERE status = 'Inactive'
    RETURNING *
)
INSERT INTO employee_archive
SELECT * FROM moved_employees;


-- Ex.27 (Complex Business Logic)
UPDATE projects p
SET end_date = end_date + INTERVAL '30 days'
WHERE p.dept_id IN (
    SELECT d.dept_id
    FROM departments d
    -- Подзапрос для проверки условия бюджета и количества сотрудников
    WHERE d.budget > 50000 AND (
        SELECT COUNT(*)
        FROM employees e
        WHERE e.department = d.dept_name
    ) > 3
);
