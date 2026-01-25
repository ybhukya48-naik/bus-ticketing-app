package com.busticketing.busticketingbackend.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collections;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import javax.sql.DataSource;

@RestController
public class HealthController {

    @Autowired
    private ApplicationContext context;

    @GetMapping({"/", "/health"})
    public ResponseEntity<Map<String, String>> health() {
        // Basic health check
        return ResponseEntity.ok(Collections.singletonMap("status", "UP"));
    }

    @GetMapping("/api/health/ready")
    public ResponseEntity<Map<String, String>> ready() {
        // This check ensures the database bean is at least loaded
        try {
            DataSource ds = context.getBean(DataSource.class);
            if (ds != null) {
                return ResponseEntity.ok(Collections.singletonMap("status", "READY"));
            }
        } catch (Exception e) {
            // Bean not ready yet
        }
        return ResponseEntity.status(503).body(Collections.singletonMap("status", "INITIALIZING"));
    }
}
