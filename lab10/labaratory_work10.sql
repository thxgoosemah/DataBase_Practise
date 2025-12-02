CREATE TABLE accounts (
                          id SERIAL PRIMARY KEY,
                          name VARCHAR(100) NOT NULL,
                          balance DECIMAL(10, 2) DEFAULT 0.00
);
CREATE TABLE products (
                          id SERIAL PRIMARY KEY,
                          shop VARCHAR(100) NOT NULL,
                          product VARCHAR(100) NOT NULL,
                          price DECIMAL(10, 2) NOT NULL
);


INSERT INTO accounts (name, balance) VALUES
                                         ('Alice', 1000.00),
                                         ('Bob', 500.00),
                                         ('Wally', 750.00);

INSERT INTO products (shop, product, price) VALUES
                                         ('Joe''s Shop', 'Coke', 2.50),
                                         ('Joe''s Shop', 'Pepsi', 3.00);


BEGIN;
UPDATE accounts SET balance = balance - 100.00
WHERE name = 'Alice';
UPDATE accounts SET balance = balance + 100.00
WHERE name = 'Bob';
COMMIT;

-- Task Basic Transaction with COMMIT

BEGIN;
UPDATE accounts SET balance = balance - 500.00
WHERE name = 'Alice';
SELECT * FROM accounts WHERE name = 'Alice';
-- Oops! Wrong amount, let's undo
ROLLBACK;
SELECT * FROM accounts WHERE name = 'Alice';


-- Task ROLLBACK

BEGIN;
UPDATE accounts SET balance = balance - 500.00
WHERE name = 'Alice';
SELECT * FROM accounts WHERE name = 'Alice';
-- Oops! Wrong amount, let's undo
ROLLBACK;
SELECT * FROM accounts WHERE name = 'Alice';

-- Task Working with SAVEPOINTs
BEGIN;
UPDATE accounts SET balance = balance - 100.00
WHERE name = 'Alice';
SAVEPOINT my_savepoint;
UPDATE accounts SET balance = balance + 100.00
WHERE name = 'Bob';
-- Oops, should transfer to Wally instead
ROLLBACK TO my_savepoint;
UPDATE accounts SET balance = balance + 100.00
WHERE name = 'Wally';
COMMIT;

-- Task Isolation Level Demonstration

-- Scenario A: READ COMMITTED
-- Terminal 1:
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to make changes and COMMIT
-- Then re-run:
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;
-- Terminal 2 (while Terminal 1 is still running):
BEGIN;
DELETE FROM products WHERE shop = 'Joe''s Shop';
INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'Fanta', 3.50);
COMMIT;
-- Scenario B: SERIALIZABLE
-- Repeat the above scenario but use:
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;



-- Task Phantom Read Demonstration
-- Terminal 1:
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT MAX(price), MIN(price) FROM products
WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2
SELECT MAX(price), MIN(price) FROM products
WHERE shop = 'Joe''s Shop';
COMMIT;
-- Terminal 2:
BEGIN;
INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'Sprite', 4.00);
COMMIT;

-- Task Dirty Read Demonstration
-- Terminal 1:
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to UPDATE but NOT commit
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to ROLLBACK
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;
-- Terminal 2:
BEGIN;
UPDATE products SET price = 99.99
WHERE product = 'Fanta';
-- Wait here (don't commit yet)
-- Then:
ROLLBACK;

-- Independent Exercises
-- Exercise 1
DO $$
    DECLARE
        bob_balance DECIMAL(10,2);
    BEGIN
        -- Start the transaction
        BEGIN
            SELECT balance INTO bob_balance
            FROM accounts
            WHERE name = 'Bob'
                FOR UPDATE;

            -- Check if Bob has enough money
            IF bob_balance < 200 THEN
                RAISE EXCEPTION 'Bob does not have enough funds';
            END IF;

            -- Perform the transfer
            UPDATE accounts
            SET balance = balance - 200
            WHERE name = 'Bob';

            UPDATE accounts
            SET balance = balance + 200
            WHERE name = 'Wally';

            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                -- Roll back everything if something fails
                ROLLBACK;
                RAISE NOTICE 'Transfer failed: %', SQLERRM;
        END;
    END $$;

-- Exercise 2
BEGIN;


-- Step 1: Insert a new product
INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'Fanta', 3.50);

-- Step 2: Create the first savepoint
SAVEPOINT sp1;

-- Step 3: Update the price
UPDATE products
SET price = 4.00
WHERE product = 'Fanta';

-- Step 4: Create the second savepoint
SAVEPOINT sp2;

-- Step 5: Delete the product
DELETE FROM products
WHERE product = 'Fanta';

-- Step 6: Rollback to the first savepoint
ROLLBACK TO SAVEPOINT sp1;

-- Step 7: Commit the transaction
COMMIT;

-- Exercise 3

-- Step 1
INSERT INTO accounts (name, balance) VALUES ('Alice', 500.00);

-- Step 2
-- Terminal 1
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Check balance
SELECT balance FROM accounts WHERE name = 'Alice';

-- Withdraw 400 if enough funds
UPDATE accounts
SET balance = balance - 400
WHERE name = 'Alice' AND balance >= 400;

COMMIT;

-- Step 3
-- Terminal 2
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT balance FROM accounts WHERE name = 'Alice';

UPDATE accounts
SET balance = balance - 400
WHERE name = 'Alice' AND balance >= 400;

COMMIT;

-- Exercise 4 — MAX < MIN Problem
-- Step 1
CREATE TABLE sells (
                       shop VARCHAR(100),
                       product VARCHAR(100),
                       price DECIMAL(10,2)
);

INSERT INTO sells (shop, product, price) VALUES
                                             ('Joe''s Shop', 'Coke', 2.50),
                                             ('Joe''s Shop', 'Pepsi', 3.00);


-- Step 2
-- Sally reads
SELECT MAX(price) FROM sells WHERE shop = 'Joe''s Shop';
SELECT MIN(price) FROM sells WHERE shop = 'Joe''s Shop';

-- Step 3 Fix Using Transactions

-- Sally starts a transaction
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT MAX(price), MIN(price) FROM sells WHERE shop = 'Joe''s Shop';

-- Joe inserts new product inside his own transaction
BEGIN;
INSERT INTO sells (shop, product, price) VALUES ('Joe''s Shop', 'Fanta', 4.00);
COMMIT;

-- Sally reads again inside the same transaction
SELECT MAX(price), MIN(price) FROM sells WHERE shop = 'Joe''s Shop';

COMMIT;



