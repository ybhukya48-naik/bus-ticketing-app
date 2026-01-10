package com.busticketing.busticketingbackend.controller;

import com.busticketing.busticketingbackend.model.Route;
import com.busticketing.busticketingbackend.repository.RouteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.lang.NonNull;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/routes")
@CrossOrigin(origins = "*")
public class RouteController {

    @Autowired
    private RouteRepository routeRepository;

    @GetMapping
    public ResponseEntity<List<Route>> getAllRoutes() {
        return ResponseEntity.ok(routeRepository.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Route> getRouteById(@PathVariable @NonNull Long id) {
        return routeRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
