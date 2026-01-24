package com.busticketing.busticketingbackend.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.HashMap;
import java.util.Map;

@RestController
public class RootController {

    @Autowired(required = false)
    private JdbcTemplate jdbcTemplate;

    @GetMapping("/")
    public Map<String, String> root() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "UP");
        
        if (jdbcTemplate != null) {
            try {
                jdbcTemplate.execute("SELECT 1");
                response.put("database", "CONNECTED");
            } catch (Exception e) {
                response.put("database", "ERROR: " + e.getMessage());
            }
        }
        
        response.put("message", "Bus Ticketing Backend is running");
        response.put("version", "0.0.1-SNAPSHOT");
        return response;
    }
}
