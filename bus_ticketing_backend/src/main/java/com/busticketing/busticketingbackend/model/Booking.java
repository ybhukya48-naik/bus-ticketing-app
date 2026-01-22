package com.busticketing.busticketingbackend.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "bookings")
public class Booking {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "bus_number")
    private String busNumber;

    @Column(name = "route")
    private String route;

    @Column(name = "booking_date")
    private String bookingDate;

    @Column(name = "number_of_seats")
    private int numberOfSeats;

    @Column(name = "total_price")
    private double totalPrice;

    @Column(name = "username")
    private String username; // To link booking to a user

    @Column(name = "qr_code_data")
    private String qrCodeData;

    @Column(name = "status")
    private String status; // e.g., PENDING, PAID, FAILED

    public Booking() {
    }

    public Booking(String busNumber, String route, String bookingDate, int numberOfSeats, double totalPrice, String username, String status) {
        this.busNumber = busNumber;
        this.route = route;
        this.bookingDate = bookingDate;
        this.numberOfSeats = numberOfSeats;
        this.totalPrice = totalPrice;
        this.username = username;
        this.status = status;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getBusNumber() {
        return busNumber;
    }

    public void setBusNumber(String busNumber) {
        this.busNumber = busNumber;
    }

    public String getRoute() {
        return route;
    }

    public void setRoute(String route) {
        this.route = route;
    }

    public String getBookingDate() {
        return bookingDate;
    }

    public void setBookingDate(String bookingDate) {
        this.bookingDate = bookingDate;
    }

    public int getNumberOfSeats() {
        return numberOfSeats;
    }

    public void setNumberOfSeats(int numberOfSeats) {
        this.numberOfSeats = numberOfSeats;
    }

    public double getTotalPrice() {
        return totalPrice;
    }

    public void setTotalPrice(double totalPrice) {
        this.totalPrice = totalPrice;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getQrCodeData() {
        return qrCodeData;
    }

    public void setQrCodeData(String qrCodeData) {
        this.qrCodeData = qrCodeData;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
