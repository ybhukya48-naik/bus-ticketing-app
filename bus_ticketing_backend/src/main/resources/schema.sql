DROP TABLE IF EXISTS Schedule;
DROP TABLE IF EXISTS RouteBusStop;
DROP TABLE IF EXISTS BusStop;
DROP TABLE IF EXISTS Route;
DROP TABLE IF EXISTS Booking;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS Bus;

CREATE TABLE Bus (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    busNumber VARCHAR(255) NOT NULL UNIQUE,
    route VARCHAR(255),
    capacity INT NOT NULL,
    availableSeats INT NOT NULL,
    currentLocation VARCHAR(255),
    rating DOUBLE,
    price DOUBLE,
    routeStopsOrder TEXT
);

CREATE TABLE Booking (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    busNumber VARCHAR(255),
    route VARCHAR(255),
    bookingDate VARCHAR(255),
    numberOfSeats INT,
    totalPrice DOUBLE,
    username VARCHAR(255),
    qrCodeData VARCHAR(255),
    status VARCHAR(255)
);

CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_reset_token VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS Route (
    id BIGINT PRIMARY KEY,
    routeName VARCHAR(255) NOT NULL,
    origin VARCHAR(255) NOT NULL,
    destination VARCHAR(255) NOT NULL,
    distance DOUBLE
);

CREATE TABLE IF NOT EXISTS BusStop (
    id BIGINT PRIMARY KEY,
    stopName VARCHAR(255) NOT NULL,
    latitude DOUBLE,
    longitude DOUBLE
);

CREATE TABLE IF NOT EXISTS RouteBusStop (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    routeId BIGINT NOT NULL,
    busStopId BIGINT NOT NULL,
    stopOrder INT NOT NULL,
    arrivalTime TIME,
    departureTime TIME,
    FOREIGN KEY (routeId) REFERENCES Route(id),
    FOREIGN KEY (busStopId) REFERENCES BusStop(id)
);

CREATE TABLE IF NOT EXISTS Schedule (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    busId BIGINT NOT NULL,
    routeId BIGINT NOT NULL,
    departureTime DATETIME NOT NULL,
    arrivalTime DATETIME NOT NULL,
    fare DECIMAL(10, 2) NOT NULL,
    availableSeats INT NOT NULL,
    FOREIGN KEY (busId) REFERENCES Bus(id),
    FOREIGN KEY (routeId) REFERENCES Route(id)
);
