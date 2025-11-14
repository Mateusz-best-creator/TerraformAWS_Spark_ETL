use CompanyDatabase;

-- Drop in reverse-dependency order to avoid FK errors
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS customers;
SET FOREIGN_KEY_CHECKS = 1;

-- Customers table
CREATE TABLE customers (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(200) NOT NULL,
  email VARCHAR(255),                -- may be NULL or malformed
  phone VARCHAR(50),
  registered_date DATE,              -- canonical date if known
  raw_registered VARCHAR(255),       -- raw string from source (various formats)
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_customers_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Suppliers table
CREATE TABLE suppliers (
  supplier_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  contact_email VARCHAR(255),
  phone VARCHAR(50),
  country VARCHAR(80),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Products table
CREATE TABLE products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  sku VARCHAR(50) NOT NULL,
  name VARCHAR(255) NOT NULL,
  supplier_id INT,
  category VARCHAR(100),
  price DECIMAL(10,2) DEFAULT NULL,
  currency CHAR(3) DEFAULT 'EUR',
  attributes JSON DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_products_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Orders table
CREATE TABLE orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  order_date DATE,                   -- canonical date if parsed
  raw_order_date VARCHAR(255),       -- raw date string as ingested
  status ENUM('NEW','PROCESSING','SHIPPED','CANCELLED','RETURNED') DEFAULT 'NEW',
  total_amount DECIMAL(12,2) DEFAULT NULL,
  currency CHAR(3) DEFAULT 'EUR',
  shipping_address VARCHAR(1000),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Order items table
CREATE TABLE order_items (
  order_item_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  unit_price DECIMAL(10,2) NOT NULL,
  discount_percent DECIMAL(5,2) DEFAULT 0,
  line_total DECIMAL(12,2) GENERATED ALWAYS AS (quantity * unit_price * (1 - discount_percent/100)) VIRTUAL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_items_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
  CONSTRAINT fk_items_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Helpful indexes
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_products_sku ON products(sku);
