-- Student: Бекесов Азамат Салаватұлы
-- ID: 24B031003


-- PART 1. CHECK CONSTRAINTS


-- Task 1.1
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK (age BETWEEN 18 AND 65),
    salary NUMERIC CHECK (salary > 0)
);

-- Valid data
INSERT INTO employees (first_name, last_name, age, salary) VALUES
('Айдос', 'Бекенов', 30, 250000),
('Жанар', 'Төлегенова', 45, 380000);

-- Invalid data (violates CHECK)
-- INSERT INTO employees (first_name, last_name, age, salary) VALUES ('Алишер', 'Сериков', 70, 200000); -- age out of range
-- INSERT INTO employees (first_name, last_name, age, salary) VALUES ('Меруерт', 'Кәрімова', 25, -50000); -- salary negative


-- Task 1.2
CREATE TABLE products_catalog (
    product_id SERIAL PRIMARY KEY,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0 AND
        discount_price > 0 AND
        discount_price < regular_price
    )
);

-- Valid data
INSERT INTO products_catalog (product_name, regular_price, discount_price) VALUES
('Ноутбук Acer', 350000, 300000),
('Телефон Samsung', 280000, 250000);

-- Invalid data (violates valid_discount)
-- INSERT INTO products_catalog (product_name, regular_price, discount_price) VALUES ('Телефон iPhone', 0, 100000);
-- INSERT INTO products_catalog (product_name, regular_price, discount_price) VALUES ('Құлаққап', 20000, 25000);


-- Task 1.3
CREATE TABLE bookings (
    booking_id SERIAL PRIMARY KEY,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER CHECK (num_guests BETWEEN 1 AND 10),
    CHECK (check_out_date > check_in_date)
);

-- Valid data
INSERT INTO bookings (check_in_date, check_out_date, num_guests) VALUES
('2025-10-10', '2025-10-15', 2),
('2025-11-01', '2025-11-05', 5);

-- Invalid data
-- INSERT INTO bookings (check_in_date, check_out_date, num_guests) VALUES ('2025-10-10', '2025-10-08', 2);
-- INSERT INTO bookings (check_in_date, check_out_date, num_guests) VALUES ('2025-11-01', '2025-11-05', 15);


-- PART 2. NOT NULL CONSTRAINTS


-- Task 2.1
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

INSERT INTO customers (email, phone, registration_date) VALUES
('ayan.bekov@example.com', '+77015556677', '2025-10-01'),
('dana.serikbayeva@example.com', '+77024445566', '2025-10-02');

-- Violations
-- INSERT INTO customers (email, registration_date) VALUES (NULL, '2025-10-01'); -- email cannot be NULL


-- Task 2.2
CREATE TABLE inventory (
    item_id SERIAL PRIMARY KEY,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);

INSERT INTO inventory (item_name, quantity, unit_price, last_updated) VALUES
('Принтер Canon', 10, 95000, NOW()),
('Флешка 32GB', 40, 6000, NOW());

-- Violations
-- INSERT INTO inventory (item_name, quantity, unit_price, last_updated) VALUES ('Қате өнім', -5, 5000, NOW());



-- PART 3. UNIQUE CONSTRAINTS


-- Task 3.1
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    created_at TIMESTAMP
);

INSERT INTO users (username, email, created_at) VALUES
('aidos', 'aidos@example.com', NOW()),
('aigerim', 'aigerim@example.com', NOW());

-- Violations
-- INSERT INTO users (username, email, created_at) VALUES ('aidos', 'newmail@example.com', NOW()); -- duplicate username


-- Task 3.2
CREATE TABLE course_enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    CONSTRAINT unique_student_course UNIQUE (student_id, course_code, semester)
);

INSERT INTO course_enrollments (student_id, course_code, semester) VALUES
(1, 'CS101', 'Fall2025'),
(2, 'CS101', 'Fall2025');

-- Violations
-- INSERT INTO course_enrollments (student_id, course_code, semester) VALUES (1, 'CS101', 'Fall2025');



-- PART 4. PRIMARY KEY CONSTRAINTS


-- Task 4.1
CREATE TABLE departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);

INSERT INTO departments (dept_id, dept_name, location) VALUES
(1, 'Информатика', 'Алматы'),
(2, 'Физика', 'Астана'),
(3, 'Математика', 'Шымкент');

-- Violations
-- INSERT INTO departments (dept_id, dept_name, location) VALUES (1, 'Қайталанған', 'Алматы');
-- INSERT INTO departments (dept_id, dept_name, location) VALUES (NULL, 'Химия', 'Қарағанды');


-- Task 4.2
CREATE TABLE student_courses (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);

INSERT INTO student_courses (student_id, course_id, enrollment_date, grade) VALUES
(1, 1, '2025-09-01', 'A'),
(2, 1, '2025-09-01', 'B');


-- Task 4.3: Explanation
-- UNIQUE allows multiple NULLs; PRIMARY KEY does not allow NULLs.
-- A table can have only one PRIMARY KEY but multiple UNIQUE constraints.
-- Composite PK is used when a single column cannot uniquely identify a record.



-- PART 5. FOREIGN KEY CONSTRAINTS


-- Task 5.1
CREATE TABLE employees_dept (
    emp_id SERIAL PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id),
    hire_date DATE
);

INSERT INTO employees_dept (emp_name, dept_id, hire_date) VALUES
('Ермек Сапаров', 1, '2024-06-01'),
('Гүлжан Төлеуова', 2, '2024-07-10');

-- Violations
-- INSERT INTO employees_dept (emp_name, dept_id, hire_date) VALUES ('Айдана Рахым', 10, '2024-06-01'); -- dept_id 10 doesn't exist


-- Task 5.2
CREATE TABLE authors (
    author_id SERIAL PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE publishers (
    publisher_id SERIAL PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);

CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);

INSERT INTO authors (author_name, country) VALUES
('George Orwell', 'UK'),
('Ernest Hemingway', 'USA'),
('Franz Kafka', 'Germany');

INSERT INTO publishers (publisher_name, city) VALUES
('Penguin Books', 'London'),
('HarperCollins', 'New York');

INSERT INTO books (title, author_id, publisher_id, publication_year, isbn) VALUES
('1984', 1, 1, 1949, 'ISBN-1234'),
('The Old Man and The Sea', 2, 2, 1952, 'ISBN-5678'),
('The Trial', 3, 1, 1925, 'ISBN-9999');


-- Task 5.3
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
    product_id SERIAL PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE orders_fk (
    order_id SERIAL PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE order_items (
    item_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders_fk(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk(product_id),
    quantity INTEGER CHECK (quantity > 0)
);

-- Test Data
INSERT INTO categories (category_name) VALUES ('Электроника'), ('Кітаптар');
INSERT INTO products_fk (product_name, category_id) VALUES ('Ноутбук', 1), ('Роман', 2);
INSERT INTO orders_fk (order_date) VALUES ('2025-10-10');
INSERT INTO order_items (order_id, product_id, quantity) VALUES (1, 1, 2);

-- ON DELETE RESTRICT test:
-- DELETE FROM categories WHERE category_id = 1; -- fails, category has products

-- ON DELETE CASCADE test:
-- DELETE FROM orders_fk WHERE order_id = 1; -- order_items auto-deleted



-- PART 6. PRACTICAL APPLICATION — E-COMMERCE DATABASE


CREATE TABLE customers_ecom (
    customer_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE products_ecom (
    product_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC CHECK (price >= 0),
    stock_quantity INT CHECK (stock_quantity >= 0)
);

CREATE TABLE orders_ecom (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers_ecom(customer_id) ON DELETE CASCADE,
    order_date DATE NOT NULL,
    total_amount NUMERIC CHECK (total_amount >= 0),
    status TEXT CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);

CREATE TABLE order_details (
    order_detail_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders_ecom(order_id) ON DELETE CASCADE,
    product_id INT REFERENCES products_ecom(product_id),
    quantity INT CHECK (quantity > 0),
    unit_price NUMERIC CHECK (unit_price > 0)
);

-- Sample Data
INSERT INTO customers_ecom (name, email, phone, registration_date) VALUES
('Айдос Бекенов', 'aidos.ecom@example.com', '+77015556611', '2025-09-01'),
('Жанар Нұртаева', 'janar.ecom@example.com', '+77024446622', '2025-09-02'),
('Бекзат Ахметов', 'bekzat.ecom@example.com', '+77037778899', '2025-09-03'),
('Еркеназ Мусаева', 'erkenaz.ecom@example.com', '+77013337744', '2025-09-04'),
('Серік Сапаров', 'serik.ecom@example.com', '+77016669988', '2025-09-05');

INSERT INTO products_ecom (name, description, price, stock_quantity) VALUES
('Смартфон Xiaomi', 'Redmi Note 13', 250000, 40),
('Ноутбук HP', 'HP Pavilion 15', 380000, 20),
('Құлаққап JBL', 'Bluetooth wireless', 18000, 100),
('Монитор Samsung', '27-inch LED', 140000, 15),
('Пернетақта Logitech', 'Wireless keyboard', 22000, 60);

INSERT INTO orders_ecom (customer_id, order_date, total_amount, status) VALUES
(1, '2025-10-01', 250000, 'delivered'),
(2, '2025-10-03', 380000, 'processing'),
(3, '2025-10-04', 18000, 'shipped'),
(4, '2025-10-06', 140000, 'pending'),
(5, '2025-10-10', 22000, 'cancelled');

INSERT INTO order_details (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 250000),
(2, 2, 1, 380000),
(3, 3, 1, 18000),
(4, 4, 1, 140000),
(5, 5, 1, 22000);


