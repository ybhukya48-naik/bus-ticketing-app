package com.busticketing.busticketingbackend;

import org.springframework.boot.SpringApplication;
import com.busticketing.busticketingbackend.config.AppProperties;
import com.busticketing.busticketingbackend.config.StripeProperties;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.boot.CommandLineRunner;
import java.util.Arrays;

@SpringBootApplication(scanBasePackages = "com.busticketing.busticketingbackend")
@EnableConfigurationProperties({AppProperties.class, StripeProperties.class})
@ConfigurationPropertiesScan
public class BusTicketingBackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(BusTicketingBackendApplication.class, args);
	}

	@Bean
	public CommandLineRunner commandLineRunner(ApplicationContext ctx) {
		return args -> {
			System.out.println("Let's inspect the beans provided by Spring Boot:");
			String[] beanNames = ctx.getBeanDefinitionNames();
			Arrays.sort(beanNames);
			for (String beanName : beanNames) {
				if (beanName.contains("securityConfig") || beanName.contains("userController") || beanName.contains("filterChain")) {
					System.out.println("!!! FOUND BEAN: " + beanName);
				}
			}
		};
	}
}