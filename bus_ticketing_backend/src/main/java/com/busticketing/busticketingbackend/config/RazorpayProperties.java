package com.busticketing.busticketingbackend.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationProperties(prefix = "razorpay")
@Data
public class RazorpayProperties {
    private String keyId;
    private String keySecret;
}
