package com.busticketing.busticketingbackend.controller;

import com.busticketing.busticketingbackend.model.BusStop;
import com.busticketing.busticketingbackend.repository.BusStopRepository;
import com.busticketing.busticketingbackend.repository.RouteRepository;
import com.busticketing.busticketingbackend.service.BusService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/buses")
@CrossOrigin(origins = "*", maxAge = 3600)
public class BusController {

    private static final Logger logger = LoggerFactory.getLogger(BusController.class);

    @Autowired
    private BusService busService;

    @Autowired
    private RouteRepository routeRepository;

    @Autowired
    private BusStopRepository busStopRepository;

    @GetMapping
    public ResponseEntity<List<Bus>> getAllBuses(
            @RequestParam(required = false) String city,
            @RequestParam(required = false) String origin,
            @RequestParam(required = false) String destination) {
        logger.debug("Received Fetch Buses Request: city={}, origin={}, destination={}", city, origin, destination);
        
        List<Bus> allBuses = busService.getAllBuses();

        if (origin != null && !origin.isEmpty() && destination != null && !destination.isEmpty()) {
            final String trimmedOrigin = origin.trim();
            final String trimmedDestination = destination.trim();
            
            // 1. Try matching by Route (Origin -> Destination)
            List<Route> matchingRoutes = routeRepository.findAll().stream()
                    .filter(r -> r.getOrigin().trim().equalsIgnoreCase(trimmedOrigin) && r.getDestination().trim().equalsIgnoreCase(trimmedDestination))
                    .toList();
            
            List<String> matchingRouteNames = matchingRoutes.stream()
                    .map(Route::getRouteName)
                    .toList();

            List<Bus> filteredByRoute = allBuses.stream()
                    .filter(bus -> matchingRouteNames.contains(bus.getRoute()))
                    .toList();
            
            if (!filteredByRoute.isEmpty()) {
                return ResponseEntity.ok(filteredByRoute);
            }

            // 2. Try matching by stops in routeStopsOrder
            Optional<BusStop> originStop = busStopRepository.findByStopNameIgnoreCase(trimmedOrigin);
            Optional<BusStop> destStop = busStopRepository.findByStopNameIgnoreCase(trimmedDestination);

            if (originStop.isPresent() && destStop.isPresent()) {
                String originId = originStop.get().getId().toString();
                String destId = destStop.get().getId().toString();

                List<Bus> filteredByStops = allBuses.stream()
                        .filter(bus -> {
                            String stopsOrder = bus.getRouteStopsOrder();
                            if (stopsOrder == null || stopsOrder.isEmpty()) return false;
                            
                            List<String> stopIds = Arrays.asList(stopsOrder.split(","));
                            int originIndex = stopIds.indexOf(originId);
                            int destIndex = stopIds.indexOf(destId);
                            
                            // Origin must exist, destination must exist, and origin must come before destination
                            return originIndex != -1 && destIndex != -1 && originIndex < destIndex;
                        })
                        .toList();

                if (!filteredByStops.isEmpty()) {
                    return ResponseEntity.ok(filteredByStops);
                }
            }
            
            // 3. Fallback: return buses at current location
            return ResponseEntity.ok(allBuses.stream()
                    .filter(bus -> bus.getCurrentLocation().equalsIgnoreCase(trimmedOrigin) || bus.getCurrentLocation().equalsIgnoreCase(city))
                    .toList());
        }

        if (city != null && !city.isEmpty()) {
            List<Bus> filteredBuses = allBuses.stream()
                    .filter(bus -> bus.getCurrentLocation().equalsIgnoreCase(city))
                    .toList();
            return ResponseEntity.ok(filteredBuses);
        }
        return ResponseEntity.ok(allBuses);
    }
}
