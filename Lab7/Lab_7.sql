-- Task 1: Simple View Creation
CREATE VIEW employee_overview AS
SELECT e.emp_name, e.salary, d.dept_name, d.location
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;

-- Task 2: Department Summary View
CREATE VIEW department_summary AS
SELECT d.dept_name,
       COUNT(e.emp_id) AS num_employees,
       AVG(e.salary) AS avg_salary,
       COUNT(p.project_id) AS num_projects
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
GROUP BY d.dept_name;

-- Task 3: View with Calculation (Efficiency)
CREATE VIEW department_efficiency AS
SELECT d.dept_name,
       SUM(e.salary) AS total_salaries,
       SUM(p.budget) AS total_budgets,
       ROUND(SUM(p.budget) / SUM(e.salary), 2) AS efficiency_score,
       CASE
           WHEN (SUM(p.budget) / SUM(e.salary)) > 2 THEN 'High'
           WHEN (SUM(p.budget) / SUM(e.salary)) BETWEEN 1 AND 2 THEN 'Medium'
           ELSE 'Low'
       END AS rating
FROM departments d
JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
GROUP BY d.dept_name;

-- Task 4: Updatable View
CREATE VIEW hr_employees AS
SELECT emp_id, emp_name, salary
FROM employees
WHERE dept_id = 102
WITH CHECK OPTION;


-- Task 5: Materialized View
CREATE MATERIALIZED VIEW project_report AS
SELECT p.project_name, p.budget, d.dept_name, COUNT(e.emp_id) AS employees_in_dept
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY p.project_name, p.budget, d.dept_name;

-- Task 6: Refresh Materialized View
REFRESH MATERIALIZED VIEW project_report;


-- Task 7: Create Role and Grant Access
CREATE ROLE analyst LOGIN PASSWORD 'analyst123';
GRANT CONNECT ON DATABASE your_database_name TO analyst;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analyst;
GRANT SELECT ON employee_overview, department_summary, department_efficiency TO analyst;


-- Task 8: Revoke Access
REVOKE SELECT ON department_efficiency FROM analyst;
