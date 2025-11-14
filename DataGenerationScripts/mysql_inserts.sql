
START TRANSACTION;

-- Customers (some clean, some messy)
INSERT INTO customers (full_name, email, phone, registered_date, raw_registered, notes) VALUES
('Jan Kowalski', 'jan.kowalski@example.com', '+48 600 000 001', '2025-10-01', '2025-10-01', 'regular customer'),
('Anna Nowak', NULL, '+48 600 000 002', NULL, '01/10/2025', 'email missing in source'),
('Marek O\'Brien', 'marek.o\'brien@@example..com', NULL, NULL, 'Oct 1 2025', 'bad email in source'),
('Li Wei', 'li.wei@example.cn', '+86-10-0000-0000', '2025-09-28', '2025-09-28T14:21:00Z', 'imported from partner feed'),
('Sara García', 'sara.garcia@example.es', NULL, NULL, '1st Oct 2025', 'name has accent'),
('NoEmail Person', '', '12345', NULL, '2025/10/01', 'empty email field'),
('Bob   Smith', 'bob.smith@example.com', '+1 (555) 123-4567', '2025-10-02', '2025-10-02', 'extra spaces in name');

-- Suppliers (some missing emails; country typos)
INSERT INTO suppliers (name, contact_email, phone, country) VALUES
('Acme Corp', 'contact@acme.example', '+44 20 5555 0001', 'United Kingdom'),
('Global Widgets', NULL, '+1-800-555-0199', 'USA'),
('供应商一', 'supplier_china@example.cn', '+86 10 5555 0002', 'China');

-- Products (some NULL price or odd attributes)
INSERT INTO products (sku, name, supplier_id, category, price, currency, attributes) VALUES
('ACM-001', 'Acme Anvil - Standard', 1, 'tools', 49.99, 'EUR', '{"color":"black","weight_kg":10}'),
('ACM-002', 'Acme Anvil - Deluxe', 1, 'tools', NULL, 'EUR', '{"color":"black","weight_kg":12}'),  -- price missing in feed
('GLW-100', 'Widget A', 2, 'widgets', 9.5, 'USD', '{"units":"piece"}'),
('GLW-101', 'Widget B', 2, 'widgets', -5.00, 'USD', '{"note":"negative price from vendor feed"}'), -- erroneous negative price
('CHN-红-1', '中国产品一', 3, 'electronics', 199.99, 'CNY', '{"warranty_years":1}'),
('MIX-999', 'Mixed Format Product', NULL, 'misc', 0.00, 'EUR', NULL);

-- Orders (raw_order_date intentionally messy, order_date sometimes NULL)
INSERT INTO orders (customer_id, order_date, raw_order_date, status, total_amount, currency, shipping_address) VALUES
(1, '2025-10-05', '2025-10-05', 'NEW', 129.97, 'EUR', 'Krakow, Poland'),
(2, NULL, '05/10/2025 14:10', 'PROCESSING', 19.00, 'EUR', 'Warsaw, Poland'),
(3, NULL, 'October 5 2025', 'NEW', 199.99, 'CNY', 'Beijing, China'),
(4, '2025-09-29', '2025-09-29T13:00:00Z', 'SHIPPED', 9.50, 'USD', 'Beijing, China'),
(5, NULL, '5 Oct 2025', 'NEW', NULL, 'EUR', 'Madrid, Spain'),
(6, NULL, '2025/10/05', 'NEW', 0.00, 'EUR', 'Unknown'),
(7, '2025-10-06', '2025-10-06', 'PROCESSING', 59.99, 'EUR', 'Somewhere, Earth');

-- Order items (some with odd unit_price values; reference existing orders/products)
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_percent) VALUES
(1, 1, 1, 49.99, 0),     -- Jan buys anvil standard
(1, 3, 8, 9.50, 10),     -- lots of Widget A (currency mismatch in sample)
(2, 3, 1, 9.5, 0),       -- Anna orders widget
(3, 5, 1, 199.99, 0),    -- Marek orders product priced in CNY
(4, 3, 1, 9.5, 0),
(5, 2, 2, 0.00, 0),      -- product had NULL price, inserted as 0.00 in line (to simulate missing price)
(6, 6, 5, 0.00, 0),      -- Mixed product, zero price
(7, 1, 1, 49.99, 5),
(7, 4, 2, -5.00, 0);     -- product with negative price to test cleaning

COMMIT;
