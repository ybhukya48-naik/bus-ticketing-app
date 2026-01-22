package com.busticketing.busticketingbackend.controller;

import com.busticketing.busticketingbackend.model.BusStop;
import com.busticketing.busticketingbackend.repository.BusStopRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;
import java.util.Arrays;

@RestController
@RequestMapping("/api/stops")
@CrossOrigin(origins = "*", maxAge = 3600)
public class BusStopController {

    @Autowired
    private BusStopRepository busStopRepository;

    @GetMapping("/batch")
    public ResponseEntity<List<BusStop>> getStopsByIds(@RequestParam String ids) {
        List<Long> stopIds = Arrays.stream(ids.split(","))
                .map(Long::parseLong)
                .collect(Collectors.toList());
        return ResponseEntity.ok(busStopRepository.findAllById(stopIds));
    }

    @GetMapping
    public ResponseEntity<List<BusStop>> getAllStops() {
        return ResponseEntity.ok(busStopRepository.findAll());
    }
}
