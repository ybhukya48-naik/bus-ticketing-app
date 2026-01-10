package com.busticketing.busticketingbackend.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "Bus")
public class Bus {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "busNumber")
    private String busNumber;

    @Column(name = "route")
    private String route;

    @Column(name = "capacity")
    private int capacity;

    @Column(name = "availableSeats")
    private int availableSeats;

    @Column(name = "currentLocation")
    private String currentLocation;

    @Column(name = "rating")
    private double rating;

    @Column(name = "price")
    private double price;

    @Column(name = "routeStopsOrder", columnDefinition = "TEXT")
    private String routeStopsOrder; // Field for real-time bus data from GitHub

    public Bus() {
    }

    public Bus(Long id, String busNumber, String route, int capacity, int availableSeats, String currentLocation, double rating, double price, String routeStopsOrder) {
        this.id = id;
        this.busNumber = busNumber;
        this.route = route;
        this.capacity = capacity;
        this.availableSeats = availableSeats;
        this.currentLocation = currentLocation;
        this.rating = rating;
        this.price = price;
        this.routeStopsOrder = routeStopsOrder;
    }

    // Getters and Setters
    public String getRouteStopsOrder() {
        return routeStopsOrder;
    }

    public void setRouteStopsOrder(String routeStopsOrder) {
        this.routeStopsOrder = routeStopsOrder;
    }

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

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public int getAvailableSeats() {
        return availableSeats;
    }

    public void setAvailableSeats(int availableSeats) {
        this.availableSeats = availableSeats;
    }

    public String getCurrentLocation() {
        return currentLocation;
    }

    public void setCurrentLocation(String currentLocation) {
        this.currentLocation = currentLocation;
    }

    public double getRating() {
        return rating;
    }

    public void setRating(double rating) {
        this.rating = rating;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }
}