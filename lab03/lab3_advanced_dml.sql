-- =========================
-- Part A: Create and Populate
-- =========================

DROP TABLE IF EXISTS employee_projects CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS departments CASCADE;

CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(100),
    budget NUMERIC(12,2)
);

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    salary NUMERIC(10,2),
    hire_date DATE,
    status VARCHAR(20),
    dept_id INT REFERENCES departments(dept_id)
);

CREATE TABLE projects (
    proj_id SERIAL PRIMARY KEY,
    proj_name VARCHAR(100),
    end_date DATE,
    budget NUMERIC(12,2)
);

CREATE TABLE employee_projects (
    emp_id INT NOT NULL REFERENCES employees(emp_id),
    proj_id INT NOT NULL REFERENCES projects(proj_id),
    PRIMARY KEY (emp_id, proj_id)
);

-- Departments
INSERT INTO departments (dept_name, budget) VALUES
    ('IT', 150000),
    ('Sales', 80000),
    ('HR', 40000);

-- Employees
INSERT INTO employees (name, salary, hire_date, status, dept_id) VALUES
    ('Alice', 25000, '2022-01-15', 'Active', 1),
    ('Bob',   60000, '2019-06-10', 'Active', 2),
    ('Carol', 90000, '2015-03-05', 'Active', 3),
    ('David', 45000, '2020-07-20', 'Inactive', 1),
    ('Eve',   70000, '2018-09-12', 'Active', 2),
    ('Frank', 55000, '2012-02-01', 'Terminated', 3);

-- Projects
INSERT INTO projects (proj_name, end_date, budget) VALUES
    ('Legacy System', '2020-12-31', 40000),
    ('Active Platform', '2025-12-31', 120000);

-- EmployeeProjects
INSERT INTO employee_projects (emp_id, proj_id)
SELECT e.emp_id, p.proj_id
FROM employees e
         JOIN projects p ON (
    (e.name = 'Alice'  AND p.proj_name = 'Active Platform') OR
    (e.name = 'Bob'    AND p.proj_name = 'Active Platform') OR
    (e.name = 'Carol'  AND p.proj_name = 'Legacy System') OR
    (e.name = 'David'  AND p.proj_name = 'Legacy System') OR
    (e.name = 'Eve'    AND p.proj_name = 'Active Platform')
    );

-- =======================
-- Part B. Advanced INSERT Operations
-- =======================

-- Task B.2
INSERT INTO employees (name, hire_date, dept_id)
VALUES ('Frank Miller', '2021-09-01', 2);

-- Task B.3
INSERT INTO employees (name, hire_date, dept_id)
VALUES ('Grace Lee', '2022-03-10', 3);

-- Task B.4
INSERT INTO departments (dept_name, budget) VALUES
    ('Marketing Department', 90000),
    ('Support Department', 60000),
    ('R&D Department', 150000);

-- Task B.5
INSERT INTO employees (name, hire_date, salary, dept_id)
VALUES ('Henry Adams', CURRENT_DATE, 50000 * 1.1, 2);

-- Task B.6: INSERT from SELECT (subquery)
-- Создаём временную таблицу и копируем сотрудников из IT Department (dept_id = 2)
DROP TABLE IF EXISTS temp_employees;

CREATE TEMP TABLE temp_employees AS
SELECT * FROM employees WHERE dept_id = 2;

-- =======================
-- Part C. Complex UPDATE Operations
-- =======================

-- Task C.7
UPDATE employees
SET salary = salary * 1.10;

-- Task C.8
UPDATE employees
SET status = 'Senior'
WHERE salary > 60000
  AND hire_date < '2020-01-01';

-- Task C.9
UPDATE employees
SET status = CASE
    WHEN salary > 80000 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
    END;

-- Task C.10
UPDATE employees
SET dept_id = DEFAULT
WHERE status = 'Inactive';

-- Task C.11
UPDATE departments d
SET budget = (
    SELECT AVG(e.salary) * 1.2
    FROM employees e
    WHERE e.dept_id = d.dept_id
)
WHERE EXISTS (
    SELECT 1 FROM employees e WHERE e.dept_id = d.dept_id
);

-- Task C.12
UPDATE employees e
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE e.dept_id = (
    SELECT dept_id FROM departments WHERE dept_name = 'Sales' LIMIT 1
);

-- =======================
-- Part D. Advanced DELETE Operations
-- =======================

-- Task D.13
DELETE FROM employees
WHERE status = 'Terminated';

-- Task D.14
DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND dept_id IS NULL;

-- Task D.15
DELETE FROM departments
WHERE dept_id NOT IN (
    SELECT DISTINCT dept_id
    FROM employees
    WHERE dept_id IS NOT NULL
);

-- Task D.16
DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

-- =======================
-- Part E. Operations with NULL Values
-- =======================

-- Task E.17
INSERT INTO employees (name, salary, hire_date, status, dept_id)
VALUES ('Null Guy', NULL, CURRENT_DATE, 'Active', NULL);

-- Task E.18
UPDATE employees
SET status = 'Unassigned'
WHERE dept_id IS NULL;

-- Task E.19
DELETE FROM employees
WHERE salary IS NULL
   OR dept_id IS NULL;

-- =========================
-- Part F. RETURNING Clause Operations
-- =========================

-- Task F.20: INSERT with RETURNING
-- Добавляем нового сотрудника и возвращаем emp_id + полное имя
INSERT INTO employees (name, salary, hire_date, status, dept_id)
VALUES ('George Lucas', 65000, CURRENT_DATE, 'Active', 1)
RETURNING emp_id, name;

-- Task F.21: UPDATE with RETURNING
-- Повышаем зарплаты сотрудникам из IT на 5000 и возвращаем id, старую и новую зарплату
UPDATE employees
SET salary = salary + 5000
WHERE dept_id = (SELECT dept_id FROM departments WHERE dept_name = 'IT' LIMIT 1)
RETURNING emp_id, salary - 5000 AS old_salary, salary AS new_salary;

-- Task F.22: DELETE with RETURNING
-- Удаляем сотрудников, нанятых до 2020-01-01, возвращаем все колонки
DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

-- =========================
-- Part G. Advanced DML Patterns
-- =========================

-- Task G.23: Conditional INSERT
-- Добавляем сотрудника, только если такого ещё нет
INSERT INTO employees (name, salary, hire_date, status, dept_id)
SELECT 'Helen Parker', 72000, CURRENT_DATE, 'Active', 2
WHERE NOT EXISTS (
    SELECT 1 FROM employees WHERE name = 'Helen Parker'
);

-- Task G.24: UPDATE with JOIN logic using subqueries
-- Зарплата растёт на 10%, если бюджет отдела > 100000, иначе на 5%
UPDATE employees e
SET salary = salary * (
    CASE
        WHEN (SELECT budget FROM departments d WHERE d.dept_id = e.dept_id) > 100000
            THEN 1.10
        ELSE 1.05
        END
    );

-- Task G.25: Bulk operations
-- Вставляем 5 сотрудников за раз
INSERT INTO employees (name, salary, hire_date, status, dept_id) VALUES
    ('Ivan', 40000, CURRENT_DATE, 'Active', 1),
    ('Julia', 42000, CURRENT_DATE, 'Active', 2),
    ('Kevin', 43000, CURRENT_DATE, 'Active', 3),
    ('Laura', 44000, CURRENT_DATE, 'Active', 1),
    ('Mark', 45000, CURRENT_DATE, 'Active', 2);

-- Обновляем их зарплаты на +10%
UPDATE employees
SET salary = salary * 1.10
WHERE name IN ('Ivan','Julia','Kevin','Laura','Mark');

-- Task G.26: Data migration simulation
-- Создаём архив сотрудников
DROP TABLE IF EXISTS employee_archive;
CREATE TABLE employee_archive AS TABLE employees WITH NO DATA;

-- Переносим Inactive сотрудников
INSERT INTO employee_archive
SELECT * FROM employees WHERE status = 'Inactive';

-- Удаляем их из основной таблицы
DELETE FROM employees WHERE status = 'Inactive';

-- Task G.27: Complex business logic
-- Обновляем дату окончания проекта +30 дней, если бюджет > 50000
-- и в отделе > 3 сотрудников
UPDATE projects p
SET end_date = end_date + INTERVAL '30 days'
WHERE budget > 50000
  AND EXISTS (
    SELECT 1
    FROM departments d
             JOIN employees e ON e.dept_id = d.dept_id
    WHERE d.dept_id IN (
        SELECT d2.dept_id FROM departments d2
        WHERE d2.dept_id = d.dept_id
    )
    GROUP BY d.dept_id
    HAVING COUNT(e.emp_id) > 3
);
