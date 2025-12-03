-- Task 3.1

CREATE TABLE шоттар (
    id SERIAL PRIMARY KEY,
    аты VARCHAR(100) NOT NULL,
    баланс DECIMAL(10, 2) DEFAULT 0.00
);

CREATE TABLE өнімдер (
    id SERIAL PRIMARY KEY,
    дүкен VARCHAR(100) NOT NULL,
    өнім VARCHAR(100) NOT NULL,
    бағасы DECIMAL(10, 2) NOT NULL
);

INSERT INTO шоттар (аты, баланс) VALUES
    ('Әлия', 1000.00),
    ('Бауыржан', 500.00),
    ('Уәли', 750.00);

INSERT INTO өнімдер (дүкен, өнім, бағасы) VALUES
    ('Жомарттың дүкені', 'Кола', 2.50),
    ('Жомарттың дүкені', 'Пепси', 3.00);


-- Task 3.2
SELECT * FROM шоттар WHERE аты IN ('Әлия', 'Бауыржан');

BEGIN;
UPDATE шоттар SET баланс = баланс - 100.00
    WHERE аты = 'Әлия';
UPDATE шоттар SET баланс = баланс + 100.00
    WHERE аты = 'Бауыржан';
COMMIT;

SELECT * FROM шоттар WHERE аты IN ('Әлия', 'Бауыржан');

-- Answers of questions 3.2
-- a) After the transaction:

-- Әлия (Aliya): 900.00 (1000.00 - 100.00)

-- Бауыржан (Bauyrzhan): 600.00 (500.00 + 100.00)

-- b) It is important to group these two UPDATE statements in a single transaction to ensure
-- atomicity. Without a transaction, if a failure occurs after the first UPDATE and before
-- the second, the money would be deducted from Aliya but not added to Bauyrzhan, leading to data inconsistency.

-- c) If the system crashed between the two UPDATE statements without a transaction, only the first UPDATE
-- might be saved (Aliya's balance decreased by 100), and the second UPDATE would not be
-- executed (Bauyrzhan's balance unchanged). This would result in 100 tenge "disappearing" from
-- the system, breaking the total sum of money in the accounts.


-- Task 3.3
BEGIN;

UPDATE шоттар SET баланс = баланс - 500.00
    WHERE аты = 'Әлия';

SELECT * FROM шоттар WHERE аты = 'Әлия';  -- Баланс: 500.00

ROLLBACK;

SELECT * FROM шоттар WHERE аты = 'Әлия';  -- Баланс: 1000.00

-- Answers of questions 3.3
-- a) After the UPDATE but before ROLLBACK: Aliya's balance = 500.00
-- b) After ROLLBACK: Aliya's balance = 1000.00 (returns to the original value)
-- c) In real applications, ROLLBACK is used to:
--
-- Undo erroneous operations by users.
-- Handle exceptional situations in case of failures.
-- Rollback partially completed operations when validation errors occur.
-- Test changes without saving them.


-- Task 3.4
SELECT * FROM шоттар WHERE аты IN ('Әлия', 'Бауыржан', 'Уәли');

BEGIN;

UPDATE шоттар SET баланс = баланс - 100.00
    WHERE аты = 'Әлия';

SAVEPOINT менің_нуктем;

UPDATE шоттар SET баланс = баланс + 100.00
    WHERE аты = 'Бауыржан';

ROLLBACK TO менің_нуктем;

UPDATE шоттар SET баланс = баланс + 100.00
    WHERE аты = 'Уәли';

COMMIT;

SELECT * FROM шоттар WHERE аты IN ('Әлия', 'Бауыржан', 'Уәли');

-- Answers of questions 3.4
-- a) After COMMIT:
-- Aliya: 900.00 (1000 - 100)
-- Bauyrzhan: 500.00 (remained unchanged)
-- Wally (Уәли): 850.00 (750 + 100)

-- b) Bauyrzhan's account was temporarily credited to 600.00 after the second UPDATE, but this effect was undone by the ROLLBACK TO менің_нуктем command, which reverted the state to after the first UPDATE.

-- c) Advantages of using SAVEPOINT over starting a new transaction:
-- Allows partial rollback within a long transaction.
-- Saves resources (no need to start a new transaction).
-- Preserves locks acquired before the savepoint.
-- Convenient for complex operations with multiple stages.


-- Task 3.5
-- Терминал 1
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM өнімдер WHERE дүкен = 'Жомарттың дүкені';
-- Терминал 2
SELECT * FROM өнімдер WHERE дүкен = 'Жомарттың дүкені';
COMMIT;

-- Терминал 2
BEGIN;
DELETE FROM өнімдер WHERE дүкен = 'Жомарттың дүкені';
INSERT INTO өнімдер (дүкен, өнім, бағасы) VALUES
    ('Жомарттың дүкені', 'Фанта', 3.50);
COMMIT;

-- Терминал 1
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT * FROM өнімдер WHERE дүкен = 'Жомарттың дүкені';
-- Терминал 2
SELECT * FROM өнімдер WHERE дүкен = 'Жомарттың дүкені';
COMMIT;

-- Answers of questions 3.5
-- a) In Scenario A (READ COMMITTED):
-- The first SELECT in Terminal 1 sees the original data: Cola (2.50) and Pepsi (3.00).
-- After Terminal 2 commits, the second SELECT in Terminal 1 sees only Fanta (3.50).

-- b) In Scenario B (SERIALIZABLE):
-- Both SELECTs in Terminal 1 see the same data (the original: Cola and Pepsi) or the transaction may fail with a serialization error if strict serialization is enforced.

-- c) Difference in behavior:
-- READ COMMITTED allows seeing changes from other transactions after they are committed, which can lead to non-repeatable reads.
-- SERIALIZABLE provides the illusion of sequential execution, ensuring that repeated reads return the same data.


-- Task 3.6
-- Терминал 1
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT MAX(бағасы), MIN(бағасы) FROM өнімдер WHERE дүкен = 'Жомарттың дүкені';
-- Терминал 2
SELECT MAX(бағасы), MIN(бағасы) FROM өнімдер WHERE дүкен = 'Жомарттың дүкені';
COMMIT;

-- Терминал 2
BEGIN;
INSERT INTO өнімдер (дүкен, өнім, бағасы) VALUES
    ('Жомарттың дүкені', 'Спрайт', 4.00);
COMMIT;

-- Answers of questions 3.6
-- a) Terminal 1 does not see the new product (Sprite) inserted by Terminal 2. Both SELECT statements return the same MAX and MIN values.
--
-- b) A phantom read is a situation where re-execution of a query returns a different number of rows due to insertion or deletion of rows by other transactions.
--
-- c) The SERIALIZABLE isolation level prevents phantom reads. In PostgreSQL, REPEATABLE READ also prevents phantom reads in the current implementation, but according to the SQL standard, it might allow them.


-- Task 3.7
-- Терминал 1
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM өнімдер WHERE дүкен = 'Жомарттың дүкені';
-- Терминал 2
SELECT * FROM өнімдер WHERE дүкен = 'Жомарттың дүкені';
-- Терминал 2
SELECT * FROM өнімдер WHERE дүкен = 'Жомарттың дүкені';
COMMIT;

-- Терминал 2
BEGIN;
UPDATE өнімдер SET бағасы = 99.99 WHERE өнім = 'Фанта';
ROLLBACK;

-- Answers of questions 3.7
-- a) Terminal 1 does see the price of 99.99 in the second SELECT. This is problematic because:
-- 1. The data is inconsistent (Fanta might not exist in the table).
-- 2. These changes might be rolled back (as they were).
-- 3. Making decisions based on such data leads to errors.

-- b) A dirty read is reading uncommitted changes from other transactions, which may be rolled back.

-- c) READ UNCOMMITTED should be avoided in most applications because:
-- 1. It allows seeing temporary, invalid data.
-- 2. It breaks data consistency.
-- 3. It can lead to errors in business logic.
-- 4. In PostgreSQL, it actually behaves like READ COMMITTED (does not support true dirty reads).


-- Ex 1
BEGIN;
SAVEPOINT аудару_бастау;

SELECT баланс INTO ағымдағы_баланс
FROM шоттар WHERE аты = 'Бауыржан' FOR UPDATE;

IF ағымдағы_баланс >= 200 THEN
    UPDATE шоттар SET баланс = баланс - 200.00
    WHERE аты = 'Бауыржан';
    UPDATE шоттар SET баланс = баланс + 200.00
    WHERE аты = 'Уәли';
    COMMIT;
ELSE
    ROLLBACK TO аудару_бастау;
    RAISE NOTICE 'Бауыржанның шотында жеткілікті қаражат жоқ';
    ROLLBACK;
END IF;


-- Ex 2
BEGIN;

-- 1.
INSERT INTO өнімдер (дүкен, өнім, бағасы) VALUES
    ('Сынақ дүкені', 'Сынақ өнімі', 10.00);

-- 2.
SAVEPOINT нүкте1;

-- 3.
UPDATE өнімдер SET бағасы = 15.00
WHERE өнім = 'Сынақ өнімі' AND дүкен = 'Сынақ дүкені';

-- 4.
SAVEPOINT нүкте2;

-- 5.
DELETE FROM өнімдер
WHERE өнім = 'Сынақ өнімі' AND дүкен = 'Сынақ дүкені';

-- 6.
ROLLBACK TO нүкте1;

-- 7.
COMMIT;

SELECT * FROM өнімдер WHERE дүкен = 'Сынақ дүкені';


-- Ex 3
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT баланс FROM шоттар WHERE аты = 'Әлия' FOR UPDATE;

UPDATE шоттар SET баланс = баланс - 200
WHERE аты = 'Әлия';
COMMIT;

BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT баланс FROM шоттар WHERE аты = 'Әлия' FOR UPDATE;

UPDATE шоттар SET баланс = баланс - 300
WHERE аты = 'Әлия';
COMMIT;


-- Ex 4
UPDATE өнімдер SET бағасы = 2.00 WHERE өнім = 'Кола';
UPDATE өнімдер SET бағасы = 3.50 WHERE өнім = 'Пепси';

SELECT MAX(бағасы) FROM өнімдер WHERE дүкен = 'Жомарттың дүкені'; -- 3.00 көруі мүмкін
SELECT MIN(бағасы) FROM өнімдер WHERE дүкен = 'Жомарттың дүкені'; -- 2.00 көруі мүмкін


BEGIN;
UPDATE өнімдер SET бағасы = 2.00 WHERE өнім = 'Кола';
UPDATE өнімдер SET бағасы = 3.50 WHERE өнім = 'Пепси';
COMMIT;

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT MAX(бағасы), MIN(бағасы) FROM өнімдер WHERE дүкен = 'Жомарттың дүкені';
COMMIT;


--                            Self-Assessment Questions Answers:

-- 1. ACID properties with examples:
-- Atomicity: A money transfer between accounts - either both operations succeed or none.
-- Consistency: The sum of all account balances remains the same before and after the transaction.
-- Isolation: Two concurrent transfers do not interfere with each other.
-- Durability: Once a transfer is confirmed, the changes persist even after a power failure.

-- 2. Difference between COMMIT and ROLLBACK:
-- COMMIT saves all transaction changes to the database.
-- ROLLBACK undoes all changes made since the transaction began.

-- 3. When to use SAVEPOINT instead of a full ROLLBACK:
-- In complex transactions with multiple independent stages.
-- When you need to undo only part of the changes while keeping the rest.
-- For implementing multi-level undo operations.

-- 4. Comparison of the four SQL isolation levels:
-- READ UNCOMMITTED: Lowest level, allows all anomalies (dirty reads, non-repeatable reads, phantoms).
-- READ COMMITTED: Sees only committed data (standard in PostgreSQL), allows non-repeatable reads and phantoms.
-- REPEATABLE READ: Guarantees same data on repeated reads, allows phantoms (but not in PostgreSQL's implementation).
-- SERIALIZABLE: Highest isolation, prevents all anomalies.


-- 5. Dirty read and which isolation level allows it:
-- A dirty read is reading uncommitted changes from other transactions. It is allowed only in READ UNCOMMITTED.

-- 6. Non-repeatable read with an example:
-- A non-repeatable read occurs when re-reading the same data returns different values due to changes by other transactions. Example: checking an account balance twice in one transaction may show different values if a transfer occurred between the checks.

-- 7. Phantom read and which isolation levels prevent it:
-- A phantom read is when a repeated query returns a different number of rows. It is prevented by the SERIALIZABLE isolation level (and in PostgreSQL, also by REPEATABLE READ).

-- 8. Why choose READ COMMITTED over SERIALIZABLE in a high-traffic application:
-- READ COMMITTED provides better performance and fewer locks, at the cost of some isolation.

-- 9. How transactions help maintain consistency during concurrent access:
-- Transactions ensure that intermediate states are not visible to other transactions, maintaining a consistent view of the data.

-- 10. What happens to uncommitted changes if the database system crashes:
-- All uncommitted changes are automatically rolled back during recovery.

