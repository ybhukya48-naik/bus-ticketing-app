package com.busticketing.busticketingbackend.controller;

import com.busticketing.busticketingbackend.model.Booking;

import com.busticketing.busticketingbackend.service.BookingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/bookings")
@CrossOrigin(origins = "*", maxAge = 3600)
public class BookingController {

    @Autowired
    private BookingService bookingService;

    @PostMapping
    public ResponseEntity<Booking> createBooking(@RequestBody Booking booking) {
        System.out.println("!!! Received booking request for bus: " + booking.getBusNumber() + " !!!");
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();
        System.out.println("!!! Authenticated user for booking: " + username + " !!!");
        booking.setUsername(username);
        try {
            Booking createdBooking = bookingService.createBooking(booking);
            System.out.println("!!! Booking created successfully with ID: " + createdBooking.getId() + " !!!");
            return ResponseEntity.ok(createdBooking);
        } catch (Exception e) {
            System.out.println("!!! Error creating booking: " + e.getMessage() + " !!!");
            e.printStackTrace();
            throw e;
        }
    }

    @GetMapping
    public ResponseEntity<List<Booking>> getBookingHistory() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();
        System.out.println("!!! Fetching booking history for user: " + username + " !!!");
        List<Booking> bookings = bookingService.getBookingsByUsername(username);
        System.out.println("!!! Found " + bookings.size() + " bookings for user: " + username + " !!!");
        return ResponseEntity.ok(bookings);
    }
}