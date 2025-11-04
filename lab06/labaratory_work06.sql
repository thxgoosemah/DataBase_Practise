
CREATE TABLE employees (
                           emp_id INT PRIMARY KEY,
                           emp_name VARCHAR(50),
                           dept_id INT,
                           salary DECIMAL(10, 2)
);

CREATE TABLE departments (
                             dept_id INT PRIMARY KEY,
                             dept_name VARCHAR(50),
                             location VARCHAR(50)
);

CREATE TABLE projects (
                          project_id INT PRIMARY KEY,
                          project_name VARCHAR(50),
                          dept_id INT,
                          budget DECIMAL(10, 2)
);

-- employees
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES
    (1, 'John Smith', 101, 50000),
    (2, 'Jane Doe', 102, 60000),
    (3, 'Mike Johnson', 101, 55000),
    (4, 'Sarah Williams', 103, 65000),
    (5, 'Tom Brown', NULL, 45000);

-- departments
INSERT INTO departments (dept_id, dept_name, location) VALUES
                                                           (101, 'IT', 'Building A'),
                                                           (102, 'HR', 'Building B'),
                                                           (103, 'Finance', 'Building C'),
                                                           (104, 'Marketing', 'Building D');

-- projects
INSERT INTO projects (project_id, project_name, dept_id, budget) VALUES
                                                                     (1, 'Website Redesign', 101, 100000),
                                                                     (2, 'Employee Training', 102, 50000),
                                                                     (3, 'Budget Analysis', 103, 75000),
                                                                     (4, 'Cloud Migration', 101, 150000),
                                                                     (5, 'AI Research', NULL, 200000);


SELECT e.emp_name, d.dept_name
FROM employees e
         CROSS JOIN departments d;


SELECT e.emp_name, d.dept_name
FROM employees e, departments d;

SELECT e.emp_name, d.dept_name
FROM employees e
         INNER JOIN departments d ON TRUE;

SELECT e.emp_name, p.project_name
FROM employees e
         CROSS JOIN projects p;

SELECT e.emp_name, d.dept_name, d.location
FROM employees e
         INNER JOIN departments d ON e.dept_id = d.dept_id;

SELECT emp_name, dept_name, location
FROM employees
         INNER JOIN departments USING (dept_id);

SELECT emp_name, dept_name, location
FROM employees
         NATURAL INNER JOIN departments;

SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
         INNER JOIN departments d ON e.dept_id = d.dept_id
         INNER JOIN projects p ON d.dept_id = p.dept_id;

SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id;

SELECT emp_name, dept_id, dept_name
FROM employees
         LEFT JOIN departments USING (dept_id);

SELECT e.emp_name, e.dept_id
FROM employees e
         LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;

SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d
         LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;

SELECT e.emp_name, d.dept_name
FROM employees e
         RIGHT JOIN departments d ON e.dept_id = d.dept_id;

SELECT e.emp_name, d.dept_name
FROM departments d
         LEFT JOIN employees e ON e.dept_id = d.dept_id;

SELECT d.dept_name, d.location
FROM employees e
         RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;

SELECT
    e.emp_name,
    e.dept_id AS emp_dept,
    d.dept_id AS dept_dept,
    d.dept_name
FROM employees e
         FULL JOIN departments d ON e.dept_id = d.dept_id;

SELECT
    d.dept_name,
    p.project_name,
    p.budget
FROM departments d
         FULL JOIN projects p ON d.dept_id = p.dept_id;


SELECT
    CASE
        WHEN e.emp_id IS NULL THEN 'Department without employees'
        WHEN d.dept_id IS NULL THEN 'Employee without department'
        ELSE 'Matched'
        END AS record_status,
    e.emp_name,
    d.dept_name
FROM employees e
         FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;


SELECT
    e.emp_name,
    d.dept_name,
    e.salary
FROM employees e
         LEFT JOIN departments d
                   ON e.dept_id = d.dept_id
                       AND d.location = 'Building A';


SELECT
    e.emp_name,
    d.dept_name,
    e.salary
FROM employees e
         LEFT JOIN departments d
                   ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';


-- Query A: Filter in ON
SELECT
    e.emp_name,
    d.dept_name,
    e.salary
FROM employees e
         INNER JOIN departments d
                    ON e.dept_id = d.dept_id
                        AND d.location = 'Building A';

-- Query B: Filter in WHERE
SELECT
    e.emp_name,
    d.dept_name,
    e.salary
FROM employees e
         INNER JOIN departments d
                    ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';


SELECT
    d.dept_name,
    e.emp_name,
    e.salary,
    p.project_name,
    p.budget
FROM departments d
         LEFT JOIN employees e ON d.dept_id = e.dept_id
         LEFT JOIN projects p ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name;

ALTER TABLE employees ADD COLUMN manager_id INT;

UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
UPDATE employees SET manager_id = 3 WHERE emp_id = 5;

SELECT
    e.emp_name AS employee,
    m.emp_name AS manager
FROM employees e
         LEFT JOIN employees m ON e.manager_id = m.emp_id;

SELECT
    d.dept_name,
    AVG(e.salary) AS avg_salary
FROM departments d
         INNER JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 50000;

-- 1. INNER JOIN показывает только совпадения,
--    LEFT JOIN показывает все строки из левой таблицы (NULL справа при отсутствии совпадений).

-- 2. CROSS JOIN используется для всех возможных комбинаций строк (например, расписание сотрудников по проектам).

-- 3. В OUTER JOIN фильтр в ON сохраняет строки без совпадений,
--    а в WHERE — удаляет их. В INNER JOIN разницы нет.

-- 4. SELECT COUNT(*) FROM table1 CROSS JOIN table2 при 5 и 10 строках = 50 строк.

-- 5. NATURAL JOIN соединяет таблицы по всем столбцам с одинаковыми именами.

-- 6. Риск NATURAL JOIN — может соединить по ненужным одноимённым столбцам и дать ошибочные результаты.

-- 7. Эквивалент LEFT JOIN в виде RIGHT JOIN:
--    SELECT * FROM B RIGHT JOIN A ON A.id = B.id;

-- 8. FULL OUTER JOIN нужен, если нужно вывести все строки из обеих таблиц, независимо от совпадений.



