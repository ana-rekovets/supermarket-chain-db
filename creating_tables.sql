DROP DATABASE IF EXISTS supermarket_chain;
CREATE DATABASE supermarket_chain;
USE supermarket_chain;

-- =========================
-- 1) CORE TABLES
-- =========================

CREATE TABLE POINT_OF_SALE (
  point_id       INT PRIMARY KEY,
  name           VARCHAR(100) NOT NULL,
  country        VARCHAR(80)  NOT NULL,
  city           VARCHAR(80)  NOT NULL,
  postal_code    VARCHAR(20)  NOT NULL,
  street_address VARCHAR(150) NOT NULL
);

CREATE TABLE CUSTOMER (
  customer_id INT PRIMARY KEY,
  first_name  VARCHAR(60) NOT NULL,
  last_name   VARCHAR(60) NOT NULL,
  phone       VARCHAR(30),
  email       VARCHAR(120)
);

CREATE TABLE PRODUCT (
  product_id  INT PRIMARY KEY,
  name        VARCHAR(120) NOT NULL,
  brand       VARCHAR(80),
  category    VARCHAR(80),
  list_price  DECIMAL(10,2) NOT NULL CHECK (list_price >= 0)
);

-- Loyalty card is 1:1 with customer (enforced via UNIQUE(customer_id))
CREATE TABLE LOYALTY_CARD (
  card_id        INT PRIMARY KEY,
  issue_date     DATE NOT NULL,
  points_balance INT NOT NULL DEFAULT 0,
  customer_id    INT NOT NULL UNIQUE,
  point_id       INT NOT NULL,
  CONSTRAINT fk_card_customer FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id),
  CONSTRAINT fk_card_point    FOREIGN KEY (point_id)    REFERENCES POINT_OF_SALE(point_id)
);

-- Store-accepted payment methods
CREATE TABLE PAYMENT_METHOD (
  point_id        INT NOT NULL,
  payment_method  VARCHAR(40) NOT NULL,
  PRIMARY KEY (point_id, payment_method),
  CONSTRAINT fk_pay_point FOREIGN KEY (point_id) REFERENCES POINT_OF_SALE(point_id)
);

-- TRANSACTION is a keyword, therefore we use backticks
CREATE TABLE `TRANSACTION` (
  transaction_id   INT PRIMARY KEY,
  `date`           DATE NOT NULL,
  total_price      DECIMAL(12,2) NOT NULL CHECK (total_price >= 0),
  customer_id      INT NOT NULL,
  point_id         INT NOT NULL,
  payment_method   VARCHAR(40) NOT NULL,

  CONSTRAINT fk_tr_customer
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id),

  CONSTRAINT fk_tr_point
    FOREIGN KEY (point_id) REFERENCES POINT_OF_SALE(point_id),

  CONSTRAINT fk_tr_payment
    FOREIGN KEY (point_id, payment_method)
    REFERENCES PAYMENT_METHOD(point_id, payment_method)
);


CREATE TABLE PRODUCT_IN_TRANSACTION (
  product_id      INT NOT NULL,
  transaction_id  INT NOT NULL,
  quantity        INT NOT NULL CHECK (quantity > 0),
  unit_price      DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
  PRIMARY KEY (product_id, transaction_id),
  CONSTRAINT fk_pit_product     FOREIGN KEY (product_id)     REFERENCES PRODUCT(product_id),
  CONSTRAINT fk_pit_transaction FOREIGN KEY (transaction_id) REFERENCES `TRANSACTION`(transaction_id)
);

CREATE TABLE POINT_OFFERS_PRODUCT (
  point_id   INT NOT NULL,
  product_id INT NOT NULL,
  quantity   INT NOT NULL CHECK (quantity >= 0),
  PRIMARY KEY (point_id, product_id),
  CONSTRAINT fk_pop_point   FOREIGN KEY (point_id)   REFERENCES POINT_OF_SALE(point_id),
  CONSTRAINT fk_pop_product FOREIGN KEY (product_id) REFERENCES PRODUCT(product_id)
);

CREATE TABLE POINTS_MOVEMENT (
  movements_id   INT PRIMARY KEY,
  movement_type  VARCHAR(30) NOT NULL,  -- e.g., EARN, REDEEM, ADJUST
  `date`         DATE NOT NULL,
  points_delta   INT NOT NULL,
  transaction_id INT,
  card_id        INT NOT NULL,
  CONSTRAINT fk_pm_transaction FOREIGN KEY (transaction_id) REFERENCES `TRANSACTION`(transaction_id),
  CONSTRAINT fk_pm_card        FOREIGN KEY (card_id)        REFERENCES LOYALTY_CARD(card_id)
);

-- Helpful indexes
CREATE INDEX idx_tr_customer_date ON `TRANSACTION` (customer_id, `date`);
CREATE INDEX idx_pit_transaction  ON PRODUCT_IN_TRANSACTION (transaction_id);
CREATE INDEX idx_pm_card_date     ON POINTS_MOVEMENT (card_id, `date`);

-- =========================
-- 2) SAMPLE DATA
-- =========================

-- ------------------------------------------------------------
-- POINT OF SALE
-- ------------------------------------------------------------
INSERT INTO POINT_OF_SALE VALUES
(1, 'Lugano Central', 'Switzerland', 'Lugano', '6900', 'Via Nassa 10'),
(2, 'Milan Centro',  'Italy',       'Milano', '20121', 'Corso Buenos Aires 5'),
(3, 'Munich Mitte',  'Germany',     'München','80331', 'Sendlinger Str. 8');

-- ------------------------------------------------------------
-- CUSTOMERS
-- ------------------------------------------------------------
INSERT INTO CUSTOMER VALUES
(101, 'Anna',   'Rossi',   '+41 77 111 11 11', 'anna.rossi@mail.com'),
(102, 'Mark',   'Weber',   '+49 151 222 22 22','mark.weber@mail.com'),
(103, 'Giulia', 'Bianchi', '+39 333 333 333', 'giulia.b@mail.com'),
(104, 'Tom',    'Keller',  '+49 89 444 44 44', 'tom.keller@mail.com'),
(105, 'Sofia',  'Conti',   '+41 79 555 55 55', 'sofia.conti@mail.com');

-- ------------------------------------------------------------
-- PRODUCTS
-- ------------------------------------------------------------
INSERT INTO PRODUCT VALUES
(201, 'Milk 1L',        'Alpine',  'Dairy',   1.50),
(202, 'Pasta 500g',     'Roma',    'Grocery', 1.20),
(203, 'Chocolate 100g', 'ChocoCo', 'Snacks',  2.10),
(204, 'Olive Oil 1L',   'Medit',   'Grocery', 9.90),
(205, 'Bananas 1kg',    'Fresh',   'Fruit',   2.50),
(206, 'Shampoo 250ml',  'CarePlus','Hygiene', 4.80);

-- ------------------------------------------------------------
-- LOYALTY CARDS (1:1 with CUSTOMER)
-- ------------------------------------------------------------
INSERT INTO LOYALTY_CARD VALUES
(301, '2025-10-01', 120, 101, 1),
(302, '2025-10-02',  40, 102, 3),
(303, '2025-10-05', 220, 103, 2),
(304, '2025-10-07',  10, 104, 3),
(305, '2025-10-10',  80, 105, 1);

-- ------------------------------------------------------------
-- PAYMENT METHODS PER STORE
-- ------------------------------------------------------------
INSERT INTO PAYMENT_METHOD VALUES
(1, 'cash'), (1, 'credit_card'), (1, 'check'),
(2, 'cash'), (2, 'credit_card'),
(3, 'cash'), (3, 'credit_card'), (3, 'mobile_pay');

-- ------------------------------------------------------------
-- PRODUCT AVAILABILITY / STOCK PER STORE
-- ------------------------------------------------------------
INSERT INTO POINT_OFFERS_PRODUCT VALUES
(1,201,120),(1,202,200),(1,203,150),(1,204, 60),(1,205, 90),(1,206, 70),
(2,201, 80),(2,202,220),(2,203,140),(2,204, 50),(2,205,110),(2,206, 65),
(3,201,100),(3,202,180),(3,203,160),(3,204, 55),(3,205, 95),(3,206, 75);

-- ------------------------------------------------------------
-- TRANSACTIONS
-- ------------------------------------------------------------
INSERT INTO `TRANSACTION` VALUES
(401,'2025-11-01',  8.40,101,1,'credit_card'),
(402,'2025-11-02', 12.30,103,2,'cash'),
(403,'2025-11-02',  6.90,105,1,'cash'),
(404,'2025-11-03', 15.00,102,3,'mobile_pay'),
(405,'2025-11-04',  9.60,104,3,'credit_card'),
(406,'2025-11-05', 22.10,101,1,'check');

-- ------------------------------------------------------------
-- PRODUCTS IN TRANSACTIONS (line items)
-- ------------------------------------------------------------
INSERT INTO PRODUCT_IN_TRANSACTION VALUES
(201,401,2,1.50),(203,401,1,2.10),(205,401,1,2.50),
(202,402,3,1.20),(204,402,1,9.90),
(201,403,1,1.50),(205,403,2,2.50),
(206,404,2,4.80),(203,404,1,2.10),
(202,405,2,1.20),(201,405,2,1.50),(205,405,1,2.50),
(204,406,2,9.90),(203,406,1,2.30);

-- ------------------------------------------------------------
-- POINTS MOVEMENTS
-- ------------------------------------------------------------
INSERT INTO POINTS_MOVEMENT VALUES
(501,'EARN',  '2025-11-01',  80,401,301),
(502,'EARN',  '2025-11-02', 120,402,303),
(503,'EARN',  '2025-11-02',  70,403,305),
(504,'EARN',  '2025-11-03', 150,404,302),
(505,'EARN',  '2025-11-04',  90,405,304),
(506,'REDEEM','2025-11-05', -50,406,301);

