CREATE TABLE employees (
                           employee_id INTEGER,
                           first_name TEXT,
                           last_name TEXT,
                           age INTEGER CHECK (age BETWEEN 18 AND 65),
                           salary NUMERIC CHECK (salary > 0)
);
CREATE TABLE products_catalog (
                                  product_id INTEGER,
                                  product_name TEXT,
                                  regular_price NUMERIC,
                                  discount_price NUMERIC,
                                  CONSTRAINT valid_discount CHECK (
                                      regular_price > 0
                                          AND discount_price > 0
                                          AND discount_price < regular_price
                                      )
);
CREATE TABLE bookings (
                          booking_id INTEGER,
                          check_in_date DATE,
                          check_out_date DATE,
                          num_guests INTEGER CHECK (num_guests BETWEEN 1 AND 10),
                          CHECK (check_out_date > check_in_date)
);
INSERT INTO employees VALUES (1, 'John', 'Smith', 30, 2500);
INSERT INTO employees VALUES (2, 'Alice', 'Brown', 45, 4000);

INSERT INTO products_catalog VALUES (1, 'Laptop', 1500, 1200);
INSERT INTO products_catalog VALUES (2, 'Headphones', 200, 150);

INSERT INTO bookings VALUES (1, '2025-10-10', '2025-10-12', 2);
INSERT INTO bookings VALUES (2, '2025-11-01', '2025-11-05', 5);

CREATE TABLE customers (
                           customer_id SERIAL PRIMARY KEY,
                           name TEXT NOT NULL,
                           email TEXT UNIQUE NOT NULL,
                           phone TEXT,
                           registration_date DATE NOT NULL
);
CREATE TABLE inventory (
                           item_id INTEGER NOT NULL,
                           item_name TEXT NOT NULL,
                           quantity INTEGER NOT NULL CHECK (quantity >= 0),
                           unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
                           last_updated TIMESTAMP NOT NULL
);
INSERT INTO customers VALUES (1, 'alice@example.com', '87075554433', '2025-10-14');
INSERT INTO customers VALUES (2, 'bob@example.com', NULL, '2025-10-10');

INSERT INTO inventory VALUES (1, 'Laptop', 10, 2500, '2025-10-14 10:00:00');
INSERT INTO inventory VALUES (2, 'Mouse', 50, 25, '2025-10-14 10:05:00');

CREATE TABLE users (
                       user_id INTEGER,
                       username TEXT,
                       email TEXT,
                       created_at TIMESTAMP,
                       CONSTRAINT unique_username UNIQUE (username),
                       CONSTRAINT unique_email UNIQUE (email)
);
CREATE TABLE course_enrollments (
                                    enrollment_id INTEGER,
                                    student_id INTEGER,
                                    course_code TEXT,
                                    semester TEXT,
                                    CONSTRAINT unique_enrollment UNIQUE (student_id, course_code, semester)
);

INSERT INTO users VALUES (1, 'alice', 'alice@example.com', '2025-10-14 10:00:00');
INSERT INTO users VALUES (2, 'bob', 'bob@example.com', '2025-10-14 10:05:00');

CREATE TABLE departments (
                             dept_id INTEGER PRIMARY KEY,
                             dept_name TEXT NOT NULL,
                             location TEXT
);

INSERT INTO departments VALUES (1, 'Human Resources', 'Building A');
INSERT INTO departments VALUES (2, 'Finance', 'Building B');
INSERT INTO departments VALUES (3, 'IT', 'Building C');

CREATE TABLE student_courses (
                                 student_id INTEGER,
                                 course_id INTEGER,
                                 enrollment_date DATE,
                                 grade TEXT,
                                 CONSTRAINT pk_student_course PRIMARY KEY (student_id, course_id)
);

INSERT INTO student_courses VALUES (1, 101, '2025-09-01', 'A');
INSERT INTO student_courses VALUES (1, 102, '2025-09-01', 'B');
INSERT INTO student_courses VALUES (2, 101, '2025-09-02', 'A');

CREATE TABLE departments (
                             dept_id INTEGER PRIMARY KEY,
                             dept_name TEXT NOT NULL,
                             location TEXT
);


INSERT INTO departments VALUES (1, 'Human Resources', 'Building A');
INSERT INTO departments VALUES (2, 'Finance', 'Building B');
INSERT INTO departments VALUES (3, 'IT', 'Building C');

CREATE TABLE employees_dept (
                                emp_id INTEGER PRIMARY KEY,
                                emp_name TEXT NOT NULL,
                                dept_id INTEGER REFERENCES departments(dept_id),
                                hire_date DATE
);

INSERT INTO employees_dept VALUES (1, 'Alice', 1, '2023-05-10');
INSERT INTO employees_dept VALUES (2, 'Bob', 2, '2024-02-15');
INSERT INTO employees_dept VALUES (3, 'Charlie', 3, '2025-01-20');


CREATE TABLE authors (
                         author_id INTEGER PRIMARY KEY,
                         author_name TEXT NOT NULL,
                         country TEXT
);


INSERT INTO authors VALUES
                        (1, 'J.K. Rowling', 'United Kingdom'),
                        (2, 'George Orwell', 'United Kingdom'),
                        (3, 'Ernest Hemingway', 'United States'),
                        (4, 'Haruki Murakami', 'Japan');




CREATE TABLE publishers (
                            publisher_id INTEGER PRIMARY KEY,
                            publisher_name TEXT NOT NULL,
                            city TEXT
);


INSERT INTO publishers VALUES
                           (1, 'Bloomsbury Publishing', 'London'),
                           (2, 'Penguin Books', 'New York'),
                           (3, 'Vintage Books', 'Tokyo');




CREATE TABLE books (
                       book_id INTEGER PRIMARY KEY,
                       title TEXT NOT NULL,
                       author_id INTEGER REFERENCES authors(author_id),
                       publisher_id INTEGER REFERENCES publishers(publisher_id),
                       publication_year INTEGER,
                       isbn TEXT UNIQUE
);


INSERT INTO books VALUES
                      (1, 'Harry Potter and the Philosopher''s Stone', 1, 1, 1997, '9780747532699'),
                      (2, '1984', 2, 2, 1949, '9780451524935'),
                      (3, 'The Old Man and the Sea', 3, 2, 1952, '9780684801223'),
                      (4, 'Kafka on the Shore', 4, 3, 2002, '9781400079278');



CREATE TABLE categories (
                            category_id INTEGER PRIMARY KEY,
                            category_name TEXT NOT NULL
);


CREATE TABLE products_fk (
                             product_id INTEGER PRIMARY KEY,
                             product_name TEXT NOT NULL,
                             category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
);


CREATE TABLE orders (
                        order_id SERIAL PRIMARY KEY,
                        customer_id INTEGER REFERENCES customers(customer_id) ON DELETE CASCADE,
                        order_date DATE NOT NULL,
                        total_amount NUMERIC(10,2) NOT NULL CHECK (total_amount >= 0),
                        status TEXT NOT NULL CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);


CREATE TABLE order_items (
                             item_id INTEGER PRIMARY KEY,
                             order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
                             product_id INTEGER REFERENCES products_fk(product_id),
                             quantity INTEGER CHECK (quantity > 0)
);

CREATE TABLE order_details (
                               order_detail_id SERIAL PRIMARY KEY,
                               order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
                               product_id INTEGER REFERENCES products(product_id) ON DELETE RESTRICT,
                               quantity INTEGER NOT NULL CHECK (quantity > 0),
                               unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0)
);

INSERT INTO categories VALUES
                           (1, 'Electronics'),
                           (2, 'Books');


INSERT INTO products_fk VALUES
                            (1, 'Laptop', 1),
                            (2, 'Headphones', 1),
                            (3, 'Novel', 2);


INSERT INTO orders VALUES
                       (100, '2025-10-14'),
                       (101, '2025-10-15');


INSERT INTO order_items VALUES
                            (1, 100, 1, 2),
                            (2, 100, 2, 1),
                            (3, 101, 3, 5);

DELETE FROM orders WHERE order_id = 100;

CREATE TABLE products (
                          product_id SERIAL PRIMARY KEY,
                          name TEXT NOT NULL,
                          description TEXT,
                          price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
                          stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

INSERT INTO customers (name, email, phone, registration_date) VALUES
                                                                  ('Alice Smith', 'alice@example.com', '123456789', '2025-01-10'),
                                                                  ('Bob Johnson', 'bob@example.com', '987654321', '2025-02-14'),
                                                                  ('Charlie Brown', 'charlie@example.com', '555666777', '2025-03-05'),
                                                                  ('Diana Miller', 'diana@example.com', '222333444', '2025-03-20'),
                                                                  ('Ethan Walker', 'ethan@example.com', NULL, '2025-04-01');



INSERT INTO products (name, description, price, stock_quantity) VALUES
                                                                    ('Laptop', '15-inch screen, 16GB RAM', 950.00, 10),
                                                                    ('Headphones', 'Noise-cancelling wireless', 150.00, 30),
                                                                    ('Mouse', 'Wireless optical mouse', 25.00, 100),
                                                                    ('Keyboard', 'Mechanical RGB keyboard', 70.00, 50),
                                                                    ('Monitor', '27-inch 4K display', 300.00, 20);


INSERT INTO orders (customer_id, order_date, total_amount, status) VALUES
                                                                       (1, '2025-10-01', 1120.00, 'pending'),
                                                                       (2, '2025-10-02', 175.00, 'processing'),
                                                                       (3, '2025-10-03', 300.00, 'shipped'),
                                                                       (4, '2025-10-04', 70.00, 'delivered'),
                                                                       (5, '2025-10-05', 1250.00, 'cancelled');


INSERT INTO order_details (order_id, product_id, quantity, unit_price) VALUES
                                                                           (1, 1, 1, 950.00),
                                                                           (1, 2, 1, 150.00),
                                                                           (2, 3, 5, 25.00),
                                                                           (3, 5, 1, 300.00),
                                                                           (4, 4, 1, 70.00);


