-- 데이터베이스 생성
CREATE DATABASE IF NOT EXISTS shop;
USE shop;

-- 고객 테이블 생성
CREATE TABLE IF NOT EXISTS customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20)
);

-- 상품 테이블 생성
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 주문 테이블 생성
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    quantity INT NOT NULL DEFAULT 1,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- 더미 데이터 삽입
-- 고객 데이터
INSERT INTO customers (name, email, phone) VALUES
    ('김철수', 'kim@example.com', '010-1234-5678'),
    ('이영희', 'lee@example.com', '010-2345-6789'),
    ('박민준', 'park@example.com', '010-3456-7890'),
    ('정서연', 'jung@example.com', '010-4567-8901'),
    ('최준호', 'choi@example.com', '010-5678-9012');

-- 상품 데이터
INSERT INTO products (name, price, description) VALUES
    ('스마트폰', 1200000.00, '최신 스마트폰 모델'),
    ('노트북', 2500000.00, '고성능 노트북'),
    ('무선이어폰', 300000.00, '노이즈 캔슬링 지원'),
    ('스마트워치', 450000.00, '건강 모니터링 기능'),
    ('태블릿', 800000.00, '10.9인치 디스플레이');

-- 주문 데이터
INSERT INTO orders (customer_id, product_id, order_date, quantity, total_price, status) VALUES
    (1, 1, '2024-02-01 10:00:00', 1, 1200000.00, 'delivered'),
    (2, 3, '2024-02-02 15:30:00', 2, 600000.00, 'shipped'),
    (3, 2, '2024-02-03 09:15:00', 1, 2500000.00, 'confirmed'),
    (4, 5, '2024-02-04 14:20:00', 1, 800000.00, 'pending'),
    (5, 4, '2024-02-05 11:45:00', 1, 450000.00, 'cancelled');

-- 1. 전체 주문 내역 조회 (고객명, 상품명 포함)
SELECT 
    o.id as order_id,
    c.name as customer_name,
    p.name as product_name,
    o.quantity,
    o.total_price,
    o.status,
    o.order_date
FROM orders o
JOIN customers c ON o.customer_id = c.id
JOIN products p ON o.product_id = p.id
ORDER BY o.order_date DESC;

-- 2. 고객별 총 주문 금액
SELECT 
    c.name as customer_name,
    COUNT(o.id) as total_orders,
    SUM(o.total_price) as total_spent
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name
ORDER BY total_spent DESC;

-- 3. 상품별 판매 통계
SELECT 
    p.name as product_name,
    COUNT(o.id) as times_ordered,
    SUM(o.quantity) as total_quantity_sold,
    SUM(o.total_price) as total_revenue
FROM products p
LEFT JOIN orders o ON p.id = o.product_id
GROUP BY p.id, p.name
ORDER BY total_revenue DESC;