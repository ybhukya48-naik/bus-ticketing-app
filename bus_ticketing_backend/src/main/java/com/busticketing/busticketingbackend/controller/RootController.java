package com.busticketing.busticketingbackend.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.HashMap;
import java.util.Map;

@RestController
public class RootController {

    // Temporarily disabled to speed up startup
    // @Autowired(required = false)
    // @org.springframework.context.annotation.Lazy
    // private JdbcTemplate jdbcTemplate;

    @GetMapping("/api-info")
    public Map<String, String> root() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "UP");
        response.put("message", "Bus Ticketing Backend is running");
        response.put("version", "0.0.1-SNAPSHOT");
        return response;
    }

    @GetMapping("/api/health/db")
    public Map<String, String> dbHealth() {
        Map<String, String> response = new HashMap<>();
        response.put("database", "CHECK_DISABLED");
        return response;
    }
}
