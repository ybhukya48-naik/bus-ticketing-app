package com.busticketing.busticketingbackend.repository;

import com.busticketing.busticketingbackend.model.Route;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RouteRepository extends JpaRepository<Route, Long> {
}
