package com.busticketing.busticketingbackend.controller;

import com.busticketing.busticketingbackend.model.BusStop;
import com.busticketing.busticketingbackend.service.BusStopService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.ArrayList;

@RestController
@RequestMapping("/api/stops")
@CrossOrigin(origins = "*", maxAge = 3600)
public class BusStopController {

    private static final Logger logger = LoggerFactory.getLogger(BusStopController.class);

    @Autowired
    private BusStopService busStopService;

    @GetMapping("/batch")
    public ResponseEntity<List<BusStop>> getStopsByIds(@RequestParam String ids) {
        if (ids == null || ids.trim().isEmpty()) {
            return ResponseEntity.ok(java.util.Collections.emptyList());
        }
        
        List<Long> stopIds = new ArrayList<>();
        for (String idPart : ids.split(",")) {
            String trimmedId = idPart.trim();
            if (!trimmedId.isEmpty()) {
                try {
                    stopIds.add(Long.parseLong(trimmedId));
                } catch (NumberFormatException e) {
                    logger.warn("Invalid bus stop ID format: {}", trimmedId);
                }
            }
        }
        
        if (stopIds.isEmpty()) {
            return ResponseEntity.ok(java.util.Collections.emptyList());
        }
        
        return ResponseEntity.ok(busStopService.getBusStopsByIds(stopIds));
    }

    @GetMapping
    public ResponseEntity<List<BusStop>> getAllStops() {
        return ResponseEntity.ok(busStopService.getAllBusStops());
    }

    @GetMapping("/search")
    public ResponseEntity<List<BusStop>> searchStops(@RequestParam String query) {
        if (query == null || query.trim().length() < 2) {
            return ResponseEntity.ok(java.util.Collections.emptyList());
        }
        return ResponseEntity.ok(busStopService.searchBusStops(query.trim()));
    }
}
