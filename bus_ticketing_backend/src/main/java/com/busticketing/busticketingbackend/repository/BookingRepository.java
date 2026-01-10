package com.busticketing.busticketingbackend.repository;

import com.busticketing.busticketingbackend.model.Booking;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface BookingRepository extends JpaRepository<Booking, Long> {
    List<Booking> findByUsername(String username);
    Optional<Booking> findByQrCodeData(String qrCodeData);
}