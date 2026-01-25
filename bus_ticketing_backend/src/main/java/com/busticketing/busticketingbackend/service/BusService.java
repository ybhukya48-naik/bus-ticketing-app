package com.busticketing.busticketingbackend.service;

import com.busticketing.busticketingbackend.model.Bus;
import com.busticketing.busticketingbackend.repository.BusRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@org.springframework.context.annotation.Lazy
public class BusService {

    @Autowired
    @org.springframework.context.annotation.Lazy
    private BusRepository busRepository;

    public List<Bus> getAllBuses() {
        return busRepository.findAll();
    }

    public Optional<Bus> getBusById(@NonNull Long id) {
        return busRepository.findById(id);
    }

    public Bus saveBus(@NonNull Bus bus) {
        return busRepository.save(bus);
    }

    public void deleteBus(@NonNull Long id) {
        busRepository.deleteById(id);
    }
}
