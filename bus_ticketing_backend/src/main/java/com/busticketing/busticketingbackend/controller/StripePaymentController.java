package com.busticketing.busticketingbackend.controller;

import com.stripe.Stripe;
import com.stripe.exception.StripeException;
import com.stripe.model.PaymentIntent;
import com.stripe.param.PaymentIntentCreateParams;
import org.springframework.beans.factory.annotation.Autowired;
import com.busticketing.busticketingbackend.config.StripeProperties;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/stripe")
public class StripePaymentController {

    @Autowired
    private StripeProperties stripeProperties;

    @PostMapping("/create-payment-intent")
    public ResponseEntity<Map<String, String>> createPaymentIntent(@RequestBody Map<String, Object> data) throws StripeException {
        Stripe.apiKey = stripeProperties.getSecretKey();

        PaymentIntentCreateParams params = PaymentIntentCreateParams.builder()
                .setAmount(Long.parseLong(data.get("amount").toString())) // amount in cents
                .setCurrency("usd")
                .putMetadata("productName", "Bus Ticket")
                .build();

        PaymentIntent paymentIntent = PaymentIntent.create(params);

        Map<String, String> responseData = new HashMap<>();
        responseData.put("clientSecret", paymentIntent.getClientSecret());
        return new ResponseEntity<>(responseData, HttpStatus.OK);
    }
}
