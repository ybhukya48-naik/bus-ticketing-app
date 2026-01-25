package com.busticketing.busticketingbackend.service;

import com.busticketing.busticketingbackend.model.Booking;
import com.busticketing.busticketingbackend.repository.BookingRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class BookingService {

    @Autowired
    private BookingRepository bookingRepository;

    public Booking createBooking(Booking booking) {
        // Generate a unique QR code data
        String qrCodeData = UUID.randomUUID().toString();
        booking.setQrCodeData(qrCodeData);
        booking.setStatus("PENDING"); // Set initial status to PENDING
        return bookingRepository.save(booking);
    }

    public List<Booking> getBookingsByUsername(String username) {
        return bookingRepository.findByUsername(username);
    }

    public void updateBookingStatus(String bookingId, String status) {
        bookingRepository.findByQrCodeData(bookingId).ifPresent(booking -> {
            booking.setStatus(status);
            bookingRepository.save(booking);
        });
    }
}
