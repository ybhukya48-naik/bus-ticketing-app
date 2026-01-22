package com.busticketing.busticketingbackend.service;

import com.busticketing.busticketingbackend.model.BusStop;
import java.util.List;

public interface BusStopService {
    List<BusStop> getBusStopsByIds(List<Long> ids);
    List<BusStop> getAllBusStops();
}
