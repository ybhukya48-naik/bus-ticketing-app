package com.busticketing.busticketingbackend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import com.busticketing.busticketingbackend.config.AppProperties;
import com.busticketing.busticketingbackend.config.StripeProperties;
import com.busticketing.busticketingbackend.config.RazorpayProperties;

@SpringBootApplication
@EnableConfigurationProperties({AppProperties.class, StripeProperties.class, RazorpayProperties.class})
public class BusTicketingBackendApplication {

    public static void main(String[] args) {
		System.out.println("Starting Bus Ticketing Backend Application...");
		SpringApplication.run(BusTicketingBackendApplication.class, args);
		System.out.println("Application started successfully!");
	}
}
