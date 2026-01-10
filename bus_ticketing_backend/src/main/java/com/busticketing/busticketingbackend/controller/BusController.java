package com.busticketing.busticketingbackend.controller;

import com.busticketing.busticketingbackend.model.Bus;
import com.busticketing.busticketingbackend.service.BusService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/buses")
@CrossOrigin(origins = "*", maxAge = 3600)
public class BusController {

    @Autowired
    private BusService busService;

    @Autowired
    private com.busticketing.busticketingbackend.repository.RouteRepository routeRepository;

    @GetMapping
    public ResponseEntity<List<Bus>> getAllBuses(
            @RequestParam(required = false) String city,
            @RequestParam(required = false) String origin,
            @RequestParam(required = false) String destination) {
        System.out.println("!!! BUS REQUEST REACHED CONTROLLER !!!");
        System.out.println("!!! Received Fetch Buses Request: city=" + city + ", origin=" + origin + ", destination=" + destination + " !!!");
        
        List<Bus> allBuses = busService.getAllBuses();

        if (origin != null && !origin.isEmpty() && destination != null && !destination.isEmpty()) {
            final String trimmedOrigin = origin.trim();
            final String trimmedDestination = destination.trim();
            
            // Find routes that match origin and destination
            List<com.busticketing.busticketingbackend.model.Route> matchingRoutes = routeRepository.findAll().stream()
                    .filter(r -> r.getOrigin().trim().equalsIgnoreCase(trimmedOrigin) && r.getDestination().trim().equalsIgnoreCase(trimmedDestination))
                    .toList();
            
            List<String> matchingRouteNames = matchingRoutes.stream()
                    .map(com.busticketing.busticketingbackend.model.Route::getRouteName)
                    .toList();

            List<Bus> filteredBuses = allBuses.stream()
                    .filter(bus -> matchingRouteNames.contains(bus.getRoute()))
                    .toList();
            
            // If no exact match by route name, try a looser match or just return based on origin/city
            if (filteredBuses.isEmpty()) {
                return ResponseEntity.ok(allBuses.stream()
                        .filter(bus -> bus.getCurrentLocation().equalsIgnoreCase(origin) || bus.getCurrentLocation().equalsIgnoreCase(city))
                        .toList());
            }
            
            return ResponseEntity.ok(filteredBuses);
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
