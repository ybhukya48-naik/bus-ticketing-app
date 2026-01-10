package com.busticketing.busticketingbackend.controller;

import com.busticketing.busticketingbackend.service.BookingService;
import com.stripe.exception.SignatureVerificationException;
import com.stripe.model.Event;
import com.stripe.model.PaymentIntent;
import com.stripe.model.Charge;
import com.stripe.net.Webhook;
import com.stripe.exception.StripeException;

import com.google.gson.JsonSyntaxException;
import com.busticketing.busticketingbackend.config.StripeProperties;
import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/stripe/webhook")
public class StripeWebhookController {

    @Autowired
    private StripeProperties stripeProperties;

    @Autowired
    private BookingService bookingService;



    @PostMapping
    public ResponseEntity<String> handleStripeWebhook(@RequestBody String payload, @RequestHeader("Stripe-Signature") String sigHeader) {
        Event event;

        try {
           event = Webhook.constructEvent(payload, sigHeader, stripeProperties.getWebhookSecret());
        } catch (SignatureVerificationException e) {
            System.out.println("⚠️  Webhook error while validating signature." + e.getMessage());
            return new ResponseEntity<>("Webhook Error: Invalid Signature", HttpStatus.BAD_REQUEST);
        } catch (JsonSyntaxException e) { // Malformed JSON
            System.out.println("⚠️  Webhook error while parsing payload." + e.getMessage());
            return new ResponseEntity<>("Webhook Error: Malformed JSON", HttpStatus.BAD_REQUEST);
        }

        // Deserialize the event object
        try {
            switch (event.getType()) {
                case "payment_intent.succeeded":
                    PaymentIntent paymentIntent = (PaymentIntent) event.getDataObjectDeserializer().deserializeUnsafe();
                    System.out.println("Payment Intent Succeeded: " + paymentIntent.getId());
                    String bookingIdFromPaymentIntent = paymentIntent.getMetadata().get("bookingId");
                    if (bookingIdFromPaymentIntent != null) {
                        bookingService.updateBookingStatus(bookingIdFromPaymentIntent, "PAID");
                        System.out.println("Booking " + bookingIdFromPaymentIntent + " status updated to PAID.");
                    }
                    break;
                case "charge.succeeded":
                    Charge charge = (Charge) event.getDataObjectDeserializer().deserializeUnsafe();
                    System.out.println("Charge Succeeded: " + charge.getId());
                    String bookingIdFromCharge = charge.getMetadata().get("bookingId");
                    if (bookingIdFromCharge != null) {
                        bookingService.updateBookingStatus(bookingIdFromCharge, "PAID");
                        System.out.println("Booking " + bookingIdFromCharge + " status updated to PAID.");
                    }
                    break;
                case "payment_intent.payment_failed":
                    PaymentIntent failedPaymentIntent = (PaymentIntent) event.getDataObjectDeserializer().deserializeUnsafe();
                    System.out.println("Payment Intent Failed: " + failedPaymentIntent.getId());
                    String failedBookingId = failedPaymentIntent.getMetadata().get("bookingId");
                    if (failedBookingId != null) {
                        bookingService.updateBookingStatus(failedBookingId, "FAILED");
                        System.out.println("Booking " + failedBookingId + " status updated to FAILED.");
                    }
                    break;
                default:
                    System.out.println("Unhandled event type: " + event.getType());
                    break;
            }
        } catch (StripeException e) {
            System.out.println("⚠️  Error deserializing event object: " + e.getMessage());
            return new ResponseEntity<>("Webhook Error: Failed to deserialize event object", HttpStatus.INTERNAL_SERVER_ERROR);
        }

        return new ResponseEntity<>("Success", HttpStatus.OK);
    }
}
