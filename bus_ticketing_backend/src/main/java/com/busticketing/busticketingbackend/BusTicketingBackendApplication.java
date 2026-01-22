package com.busticketing.busticketingbackend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import java.util.Arrays;

@SpringBootApplication
@ConfigurationPropertiesScan
public class BusTicketingBackendApplication {

	private static final Logger logger = LoggerFactory.getLogger(BusTicketingBackendApplication.class);

	public static void main(String[] args) {
		SpringApplication.run(BusTicketingBackendApplication.class, args);
	}

	@Bean
	public CommandLineRunner commandLineRunner(ApplicationContext ctx) {
		return args -> {
			logger.info("Inspecting beans provided by Spring Boot:");
			String[] beanNames = ctx.getBeanDefinitionNames();
			Arrays.sort(beanNames);
			for (String beanName : beanNames) {
				if (beanName.contains("securityConfig") || beanName.contains("userController") || beanName.contains("filterChain")) {
					logger.debug("FOUND BEAN: {}", beanName);
				}
			}
		};
	}
}