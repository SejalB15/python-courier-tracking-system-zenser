CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(50) NOT NULL,
    role VARCHAR(20) CHECK (role IN ('Admin', 'User')) NOT NULL
);

INSERT INTO Users (username, password, role) VALUES ('admin1', 'adminpass', 'Admin');
INSERT INTO Users (username, password, role) VALUES ('user1', 'userpass', 'User');
INSERT INTO Users (username, password, role) VALUES ('user2', 'userpass', 'User');
INSERT INTO Users (username, password, role) VALUES ('admin2', 'adminpass', 'Admin');
INSERT INTO Users (username, password, role) VALUES ('user3', 'userpass', 'User');

-- CUSTOMERS TABLE
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    address VARCHAR(100),
    phone VARCHAR(15),
    email VARCHAR(50)
);

INSERT INTO Customers (name, address, phone, email) VALUES ('John Doe', '123 Street, NY', '1234567890', 'john@example.com');
INSERT INTO Customers (name, address, phone, email) VALUES ('Alice Brown', '456 Road, LA', '2345678901', 'alice@example.com');
INSERT INTO Customers (name, address, phone, email) VALUES ('Bob Smith', '789 Lane, SF', '3456789012', 'bob@example.com');
INSERT INTO Customers (name, address, phone, email) VALUES ('Charlie Puth', '567 Blvd, TX', '4567890123', 'charlie@example.com');
INSERT INTO Customers (name, address, phone, email) VALUES ('Diana Prince', '890 Ave, WA', '5678901234', 'diana@example.com');

-- COURIERS TABLE
CREATE TABLE Couriers (
    courier_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    origin VARCHAR(50),
    destination VARCHAR(50),
    shipment_date DATE,
    delivery_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

INSERT INTO Couriers (customer_id, origin, destination, shipment_date, status) 
VALUES (1, 'NY', 'LA', CURDATE(), 'In Transit');
INSERT INTO Couriers (customer_id, origin, destination, shipment_date, status) 
VALUES (2, 'LA', 'SF', CURDATE(), 'Out for Delivery');
INSERT INTO Couriers (customer_id, origin, destination, shipment_date, status) 
VALUES (3, 'TX', 'NY', CURDATE(), 'Delivered');
INSERT INTO Couriers (customer_id, origin, destination, shipment_date, status) 
VALUES (4, 'SF', 'TX', CURDATE(), 'Pending');
INSERT INTO Couriers (customer_id, origin, destination, shipment_date, status) 
VALUES (5, 'WA', 'LA', CURDATE(), 'In Transit');

-- TRACKING TABLE
CREATE TABLE Tracking (
    tracking_id INT AUTO_INCREMENT PRIMARY KEY,
    courier_id INT,
    location VARCHAR(50),
    status_update VARCHAR(50),
    timestamp DATE,
    FOREIGN KEY (courier_id) REFERENCES Couriers(courier_id)
);

INSERT INTO Tracking (courier_id, location, status_update, timestamp) 
VALUES (1, 'NY Hub', 'Dispatched', CURDATE());
INSERT INTO Tracking (courier_id, location, status_update, timestamp) 
VALUES (1, 'LA Hub', 'In Transit', CURDATE());
INSERT INTO Tracking (courier_id, location, status_update, timestamp) 
VALUES (2, 'LA Center', 'Out for Delivery', CURDATE());
INSERT INTO Tracking (courier_id, location, status_update, timestamp) 
VALUES (3, 'TX Hub', 'Delivered', CURDATE());
INSERT INTO Tracking (courier_id, location, status_update, timestamp) 
VALUES (4, 'SF Warehouse', 'Pending', CURDATE());

-- DELIVERY_BOY TABLE
CREATE TABLE Delivery_Boy (
    delivery_boy_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    phone VARCHAR(15),
    email VARCHAR(50),
    assigned_courier_id INT,
    status VARCHAR(20),
    rating DECIMAL(2,1),
    FOREIGN KEY (assigned_courier_id) REFERENCES Couriers(courier_id)
);

INSERT INTO Delivery_Boy (name, phone, email, assigned_courier_id, status, rating) 
VALUES ('Mike Ross', '5678901234', 'mike@example.com', 1, 'Busy', 4.5);
INSERT INTO Delivery_Boy (name, phone, email, assigned_courier_id, status, rating) 
VALUES ('Rachel Zane', '6789012345', 'rachel@example.com', 2, 'Busy', 4.7);
INSERT INTO Delivery_Boy (name, phone, email, assigned_courier_id, status, rating) 
VALUES ('Harvey Specter', '7890123456', 'harvey@example.com', NULL, 'Available', 5.0);
INSERT INTO Delivery_Boy (name, phone, email, assigned_courier_id, status, rating) 
VALUES ('Louis Litt', '8901234567', 'louis@example.com', 3, 'Busy', 4.0);
INSERT INTO Delivery_Boy (name, phone, email, assigned_courier_id, status, rating) 
VALUES ('Donna Paulsen', '9012345678', 'donna@example.com', NULL, 'Available', 4.8);

-- PAYMENTS TABLE
CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    courier_id INT,
    amount DECIMAL(10,2),
    payment_date DATE,
    payment_status VARCHAR(20),
    payment_mode VARCHAR(30),
    FOREIGN KEY (courier_id) REFERENCES Couriers(courier_id)
);

INSERT INTO Payments (courier_id, amount, payment_date, payment_status, payment_mode) 
VALUES (1, 50.00, CURDATE(), 'Paid', 'Online');
INSERT INTO Payments (courier_id, amount, payment_date, payment_status, payment_mode) 
VALUES (2, 75.00, CURDATE(), 'Pending', 'Cash');
INSERT INTO Payments (courier_id, amount, payment_date, payment_status, payment_mode) 
VALUES (3, 100.00, CURDATE(), 'Paid', 'Card');
INSERT INTO Payments (courier_id, amount, payment_date, payment_status, payment_mode) 
VALUES (4, 60.00, CURDATE(), 'Failed', 'Online');
INSERT INTO Payments (courier_id, amount, payment_date, payment_status, payment_mode) 
VALUES (5, 90.00, CURDATE(), 'Paid', 'Online');

-- FEEDBACK TABLE
CREATE TABLE Feedback (
    feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    courier_id INT,
    delivery_boy_id INT,
    rating DECIMAL(2,1),
    comments VARCHAR(255),
    feedback_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (courier_id) REFERENCES Couriers(courier_id),
    FOREIGN KEY (delivery_boy_id) REFERENCES Delivery_Boy(delivery_boy_id)
);

INSERT INTO Feedback (customer_id, courier_id, delivery_boy_id, rating, comments, feedback_date) 
VALUES (1, 1, 1, 4.5, 'Great Service!', CURDATE());
INSERT INTO Feedback (customer_id, courier_id, delivery_boy_id, rating, comments, feedback_date) 
VALUES (2, 2, 2, 4.7, 'Quick Delivery!', CURDATE());
INSERT INTO Feedback (customer_id, courier_id, delivery_boy_id, rating, comments, feedback_date) 
VALUES (3, 3, 4, 4.0, 'Satisfied.', CURDATE());

-- WAREHOUSE TABLE
CREATE TABLE Warehouse (
    warehouse_id INT AUTO_INCREMENT PRIMARY KEY,
    location VARCHAR(50),
    manager_name VARCHAR(50),
    capacity INT,
    current_load INT,
    status VARCHAR(20)
);

INSERT INTO Warehouse (location, manager_name, capacity, current_load, status) 
VALUES ('NY Hub', 'Tom Keller', 500, 300, 'Active');
INSERT INTO Warehouse (location, manager_name, capacity, current_load, status) 
VALUES ('LA Hub', 'Sara Lane', 600, 450, 'Active');