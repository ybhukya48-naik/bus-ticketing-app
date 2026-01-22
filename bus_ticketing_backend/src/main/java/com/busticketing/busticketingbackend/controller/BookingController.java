package com.busticketing.busticketingbackend.controller;

import com.busticketing.busticketingbackend.model.Booking;
import com.busticketing.busticketingbackend.service.BookingService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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

    private static final Logger logger = LoggerFactory.getLogger(BookingController.class);

    @Autowired
    private BookingService bookingService;

    @PostMapping
    public ResponseEntity<Booking> createBooking(@RequestBody Booking booking) {
        logger.info("Received booking request for bus: {}", booking.getBusNumber());
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();
        logger.debug("Authenticated user for booking: {}", username);
        booking.setUsername(username);
        try {
            Booking createdBooking = bookingService.createBooking(booking);
            logger.info("Booking created successfully with ID: {}", createdBooking.getId());
            return ResponseEntity.ok(createdBooking);
        } catch (Exception e) {
            logger.error("Error creating booking: {}", e.getMessage());
            throw e;
        }
    }

    @GetMapping
    public ResponseEntity<List<Booking>> getBookingHistory() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();
        logger.info("Fetching booking history for user: {}", username);
        List<Booking> bookings = bookingService.getBookingsByUsername(username);
        logger.debug("Found {} bookings for user: {}", bookings.size(), username);
        return ResponseEntity.ok(bookings);
    }
}