package com.busticketing.busticketingbackend.service;

import com.busticketing.busticketingbackend.model.BusStop;
import com.busticketing.busticketingbackend.repository.BusStopRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class BusStopServiceImpl implements BusStopService {

    @Autowired
    private BusStopRepository busStopRepository;

    @Override
    public List<BusStop> getBusStopsByIds(List<Long> ids) {
        if (ids == null) {
            return List.of();
        }
        return busStopRepository.findAllById(ids);
    }

    @Override
    public List<BusStop> getAllBusStops() {
        return busStopRepository.findAll();
    }

    @Override
    public List<BusStop> searchBusStops(String query) {
        return busStopRepository.findByStopNameContainingIgnoreCase(query);
    }
}
