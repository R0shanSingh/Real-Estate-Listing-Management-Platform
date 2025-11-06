CREATE DATABASE RealEstateDB;
USE RealEstateDB;

-- Table 1: Agents
CREATE TABLE Agents (
  AgentID INT PRIMARY KEY AUTO_INCREMENT,
  Name VARCHAR(100),
  Email VARCHAR(100) UNIQUE,
  Phone VARCHAR(15),
  Experience INT,
  CommissionRate DECIMAL(5,2)
);

-- Table 2: Property Categories
CREATE TABLE Categories (
  CategoryID INT PRIMARY KEY AUTO_INCREMENT,
  CategoryName VARCHAR(50) UNIQUE
);

-- Table 3: Properties
CREATE TABLE Properties (
  PropertyID INT PRIMARY KEY AUTO_INCREMENT,
  AgentID INT,
  CategoryID INT,
  Title VARCHAR(100),
  Type VARCHAR(50),
  Location VARCHAR(100),
  Price DECIMAL(10,2),
  Status VARCHAR(20),
  Description TEXT,
  FOREIGN KEY (AgentID) REFERENCES Agents(AgentID) ON DELETE CASCADE,
  FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- Table 4: PropertyImages
CREATE TABLE PropertyImages (
  ImageID INT PRIMARY KEY AUTO_INCREMENT,
  PropertyID INT,
  ImageURL VARCHAR(200),
  FOREIGN KEY (PropertyID) REFERENCES Properties(PropertyID) ON DELETE CASCADE
);

-- Table 5: Clients
CREATE TABLE Clients (
  ClientID INT PRIMARY KEY AUTO_INCREMENT,
  Name VARCHAR(100),
  Email VARCHAR(100),
  Phone VARCHAR(15)
);

-- Table 6: Appointments
CREATE TABLE Appointments (
  AppointmentID INT PRIMARY KEY AUTO_INCREMENT,
  ClientID INT,
  AgentID INT,
  PropertyID INT,
  Date DATE,
  Time TIME,
  FOREIGN KEY (ClientID) REFERENCES Clients(ClientID) ON DELETE CASCADE,
  FOREIGN KEY (AgentID) REFERENCES Agents(AgentID),
  FOREIGN KEY (PropertyID) REFERENCES Properties(PropertyID)
);

-- Table 7: Bookings
CREATE TABLE Bookings (
  BookingID INT PRIMARY KEY AUTO_INCREMENT,
  PropertyID INT,
  ClientID INT,
  BookingDate DATE,
  Amount DECIMAL(10,2),
  FOREIGN KEY (PropertyID) REFERENCES Properties(PropertyID),
  FOREIGN KEY (ClientID) REFERENCES Clients(ClientID)
);

-- Table 8: Payments
CREATE TABLE Payments (
  PaymentID INT PRIMARY KEY AUTO_INCREMENT,
  BookingID INT,
  PaymentDate DATE,
  Amount DECIMAL(10,2),
  PaymentMode VARCHAR(20),
  FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);

-- Table 9: Feedback
CREATE TABLE Feedback (
  FeedbackID INT PRIMARY KEY AUTO_INCREMENT,
  ClientID INT,
  PropertyID INT,
  Rating INT CHECK (Rating BETWEEN 1 AND 5),
  Comments TEXT,
  FOREIGN KEY (ClientID) REFERENCES Clients(ClientID),
  FOREIGN KEY (PropertyID) REFERENCES Properties(PropertyID)
);

INSERT INTO Agents (Name, Email, Phone, Experience, CommissionRate) VALUES
('Rahul Sharma', 'rahul@estate.com', '9999000011', 5, 3.5),
('Priya Mehta', 'priya@estate.com', '9999000012', 3, 2.5),
('Arjun Patel', 'arjun@estate.com', '9999000013', 7, 4.0);

INSERT INTO Categories (CategoryName) VALUES ('Residential'), ('Commercial'), ('Land');

INSERT INTO Properties (AgentID, CategoryID, Title, Type, Location, Price, Status, Description)
VALUES
(1, 1, '2BHK Apartment', 'Flat', 'Mohali', 4500000, 'Available', 'Modern apartment near city center'),
(2, 2, 'Office Space', 'Commercial', 'Chandigarh', 12000000, 'Available', 'Fully furnished office'),
(3, 3, 'Agricultural Land', 'Land', 'Zirakpur', 8000000, 'Sold', '5 acres fertile land');

INSERT INTO Clients (Name, Email, Phone) VALUES
('Rohit Kumar', 'rohit@gmail.com', '9898989898'),
('Sneha Gupta', 'sneha@gmail.com', '9876543210');

INSERT INTO Appointments (ClientID, AgentID, PropertyID, Date, Time) VALUES
(1, 1, 1, '2025-11-10', '11:00:00'),
(2, 2, 2, '2025-11-12', '14:00:00');

INSERT INTO Bookings (PropertyID, ClientID, BookingDate, Amount) VALUES
(3, 1, '2025-11-05', 1000000);

INSERT INTO Payments (BookingID, PaymentDate, Amount, PaymentMode) VALUES
(1, '2025-11-06', 1000000, 'Online');

INSERT INTO Feedback (ClientID, PropertyID, Rating, Comments) VALUES
(1, 1, 5, 'Excellent property and great location!'),
(2, 2, 4, 'Spacious and well maintained.');


-- 1. View all Agents
SELECT * FROM Agents;

-- 2. View all Property Categories
SELECT * FROM Categories;

-- 3. View all Properties
SELECT * FROM Properties;

-- 4. View all Property Images
SELECT * FROM PropertyImages;

-- 5. View all Clients
SELECT * FROM Clients;

-- 6. View all Appointments
SELECT * FROM Appointments;

-- 7. View all Bookings
SELECT * FROM Bookings;

-- 8. View all Payments
SELECT * FROM Payments;

-- 9. View all Feedback
SELECT * FROM Feedback;

-- View All Properties with Agent Name
SELECT p.PropertyID, p.Title, p.Location, p.Price, a.Name AS Agent
FROM Properties p JOIN Agents a ON p.AgentID = a.AgentID;

-- Search Properties by Price Range
SELECT * FROM Properties WHERE Price BETWEEN 4000000 AND 10000000;

-- Count Properties by Category
SELECT c.CategoryName, COUNT(p.PropertyID) AS Total
FROM Categories c LEFT JOIN Properties p ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryName;

-- Display Appointments with Client and Agent
SELECT ap.AppointmentID, c.Name AS Client, a.Name AS Agent, p.Title, ap.Date
FROM Appointments ap
JOIN Clients c ON ap.ClientID = c.ClientID
JOIN Agents a ON ap.AgentID = a.AgentID
JOIN Properties p ON ap.PropertyID = p.PropertyID;

-- Show Feedback with Average Rating
SELECT p.Title, AVG(f.Rating) AS Avg_Rating
FROM Properties p LEFT JOIN Feedback f ON p.PropertyID = f.PropertyID
GROUP BY p.Title;

-- Revenue Report
SELECT SUM(Amount) AS Total_Revenue FROM Payments;

-- List properties handled by agents having more than 5 years experience
SELECT a.Name AS AgentName, p.Title, p.Location, p.Price
FROM Agents a
JOIN Properties p ON a.AgentID = p.AgentID
WHERE a.Experience > 5;

-- Find agents with total number of properties they manage
SELECT a.Name AS AgentName, COUNT(p.PropertyID) AS Total_Properties
FROM Agents a
LEFT JOIN Properties p ON a.AgentID = p.AgentID
GROUP BY a.AgentID;

-- Find properties booked but not yet paid fully
SELECT b.BookingID, c.Name AS Client, p.Title AS Property, b.Amount AS Booking_Amount
FROM Bookings b
JOIN Clients c ON b.ClientID = c.ClientID
JOIN Properties p ON b.PropertyID = p.PropertyID
LEFT JOIN Payments pay ON pay.BookingID = b.BookingID
WHERE pay.Amount < b.Amount;

-- Show total commission earned by each agent
SELECT a.Name AS AgentName,
       SUM(p.Price * (a.CommissionRate / 100)) AS Commission_Earned
FROM Agents a
JOIN Properties p ON a.AgentID = p.AgentID
GROUP BY a.AgentID;

-- Clients who gave rating >= 4
SELECT c.Name AS ClientName, f.Rating, p.Title AS Property
FROM Feedback f
JOIN Clients c ON f.ClientID = c.ClientID
JOIN Properties p ON f.PropertyID = p.PropertyID
WHERE f.Rating >= 4;

-- Show all available properties (not booked/sold)
SELECT Title, Type, Location, Price
FROM Properties
WHERE Status = 'Available';

-- List top 3 most expensive properties
SELECT Title, Location, Price
FROM Properties
ORDER BY Price DESC
LIMIT 3;

-- Average price of properties by type
SELECT Type, AVG(Price) AS Avg_Price
FROM Properties
GROUP BY Type;

-- Get number of appointments per agent
SELECT a.Name AS Agent, COUNT(ap.AppointmentID) AS Total_Appointments
FROM Agents a
LEFT JOIN Appointments ap ON a.AgentID = ap.AgentID
GROUP BY a.AgentID;

-- List clients who booked more than one property
SELECT c.Name AS ClientName, COUNT(b.BookingID) AS Total_Bookings
FROM Clients c
JOIN Bookings b ON c.ClientID = b.ClientID
GROUP BY c.ClientID
HAVING COUNT(b.BookingID) > 1;
