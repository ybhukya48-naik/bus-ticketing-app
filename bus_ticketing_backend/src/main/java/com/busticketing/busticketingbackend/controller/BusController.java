package com.busticketing.busticketingbackend.controller;

import com.busticketing.busticketingbackend.model.Bus;
import com.busticketing.busticketingbackend.model.BusStop;
import com.busticketing.busticketingbackend.model.Route;
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
        List<Bus> allBuses = busService.getAllBuses();
        logger.info("Total buses in database: {}", allBuses.size());
        
        if (origin != null && !origin.isEmpty() && destination != null && !destination.isEmpty()) {
            final String trimmedOrigin = origin.trim();
            final String trimmedDestination = destination.trim();
            
            // 1. Try matching by Route (Origin -> Destination)
            List<Route> matchingRoutes = routeRepository.findAll().stream()
                    .filter(r -> (r.getOrigin() != null && r.getOrigin().trim().equalsIgnoreCase(trimmedOrigin) && r.getDestination() != null && r.getDestination().trim().equalsIgnoreCase(trimmedDestination)) ||
                                (r.getRouteName() != null && r.getRouteName().trim().equalsIgnoreCase(trimmedOrigin + " " + trimmedDestination)))
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

            // 2. Try matching by stops in routeStopsOrder (Handling duplicate stop names with multiple IDs)
            List<BusStop> originStops = busStopRepository.findAllByStopNameIgnoreCase(trimmedOrigin);
            List<BusStop> destStops = busStopRepository.findAllByStopNameIgnoreCase(trimmedDestination);

            if (!originStops.isEmpty() && !destStops.isEmpty()) {
                List<String> originIds = originStops.stream().map(s -> s.getId().toString()).toList();
                List<String> destIds = destStops.stream().map(s -> s.getId().toString()).toList();

                List<Bus> filteredByStops = allBuses.stream()
                        .filter(bus -> {
                            String stopsOrder = bus.getRouteStopsOrder();
                            if (stopsOrder == null || stopsOrder.isEmpty()) return false;
                            
                            List<String> stopIds = Arrays.stream(stopsOrder.split(","))
                                    .map(String::trim)
                                    .toList();
                            
                            // Find the first occurrence of any origin ID and any destination ID
                            int firstOriginIndex = -1;
                            for (String oid : originIds) {
                                int idx = stopIds.indexOf(oid);
                                if (idx != -1 && (firstOriginIndex == -1 || idx < firstOriginIndex)) {
                                    firstOriginIndex = idx;
                                }
                            }

                            int lastDestIndex = -1;
                            for (String did : destIds) {
                                int idx = stopIds.lastIndexOf(did);
                                if (idx != -1 && idx > lastDestIndex) {
                                    lastDestIndex = idx;
                                }
                            }
                            
                            return firstOriginIndex != -1 && lastDestIndex != -1 && firstOriginIndex < lastDestIndex;
                        })
                        .toList();

                if (!filteredByStops.isEmpty()) {
                    return ResponseEntity.ok(filteredByStops);
                }
            }
            
            // 2.5 Try fuzzy match by stop names in routeStopsOrder (if IDs don't match or aren't present)
            List<Bus> fuzzyFiltered = allBuses.stream()
                    .filter(bus -> {
                        String stopsOrder = bus.getRouteStopsOrder();
                        if (stopsOrder == null || stopsOrder.isEmpty()) return false;
                        
                        // If it's IDs, we already tried above. If it's names, we try here.
                        String lowerOrigin = trimmedOrigin.toLowerCase();
                        String lowerDest = trimmedDestination.toLowerCase();
                        String lowerStops = stopsOrder.toLowerCase();
                        
                        return lowerStops.contains(lowerOrigin) && lowerStops.contains(lowerDest) && 
                               lowerStops.indexOf(lowerOrigin) < lowerStops.indexOf(lowerDest);
                    })
                    .toList();
            
            if (!fuzzyFiltered.isEmpty()) {
                return ResponseEntity.ok(fuzzyFiltered);
            }
            
            // 3. Fallback: return buses at current location or any buses matching the route name partially
            List<Bus> fallbackBuses = allBuses.stream()
                    .filter(bus -> bus.getCurrentLocation().equalsIgnoreCase(trimmedOrigin) || 
                                  bus.getCurrentLocation().equalsIgnoreCase(city) ||
                                  (bus.getRoute() != null && (bus.getRoute().contains(trimmedOrigin) || bus.getRoute().contains(trimmedDestination))))
                    .toList();
            
            if (!fallbackBuses.isEmpty()) {
                return ResponseEntity.ok(fallbackBuses);
            }
            
            // 4. Final Fallback: if searching but nothing found, return all buses to not show an empty screen
            return ResponseEntity.ok(allBuses);
        }

        if (city != null && !city.isEmpty()) {
            List<Bus> filteredBuses = allBuses.stream()
                    .filter(bus -> bus.getCurrentLocation().equalsIgnoreCase(city))
                    .toList();
            return ResponseEntity.ok(filteredBuses);
        }

        return ResponseEntity.ok(allBuses);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Bus> getBusById(@PathVariable Long id) {
        return busService.getBusById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
