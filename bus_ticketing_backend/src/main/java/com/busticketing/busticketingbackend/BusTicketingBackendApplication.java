package com.busticketing.busticketingbackend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import com.busticketing.busticketingbackend.config.AppProperties;
import com.busticketing.busticketingbackend.config.StripeProperties;
import com.busticketing.busticketingbackend.config.RazorpayProperties;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
@EnableConfigurationProperties({AppProperties.class, StripeProperties.class, RazorpayProperties.class})
public class BusTicketingBackendApplication {

    public static void main(String[] args) {
		System.out.println("Starting Bus Ticketing Backend Application...");
		String port = System.getenv("PORT");
		System.out.println("PORT environment variable: " + port);
		SpringApplication.run(BusTicketingBackendApplication.class, args);
		System.out.println("Application started successfully!");
	}

    @Bean
    public CommandLineRunner commandLineRunner() {
        return args -> {
            System.out.println("CommandLineRunner: App is fully up and running!");
        };
    }
}
