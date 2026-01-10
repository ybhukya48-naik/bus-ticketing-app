package com.busticketing.busticketingbackend.controller;

import com.razorpay.Order;
import com.razorpay.RazorpayClient;
import com.razorpay.RazorpayException;
import com.razorpay.QrCode;
import com.razorpay.Utils;
import com.busticketing.busticketingbackend.config.RazorpayProperties;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/razorpay")
@CrossOrigin(origins = "*", maxAge = 3600)
public class RazorpayPaymentController {

    @Autowired
    private RazorpayProperties razorpayProperties;

    @PostMapping("/create-order")
    public ResponseEntity<Map<String, Object>> createOrder(@RequestBody Map<String, Object> data) {
        try {
            RazorpayClient razorpay = new RazorpayClient(razorpayProperties.getKeyId(), razorpayProperties.getKeySecret());

            JSONObject orderRequest = new JSONObject();
            orderRequest.put("amount", Integer.parseInt(data.get("amount").toString())); // amount in paise
            orderRequest.put("currency", "INR");
            orderRequest.put("receipt", "txn_" + System.currentTimeMillis());

            Order order = razorpay.orders.create(orderRequest);

            Map<String, Object> response = new HashMap<>();
            response.put("orderId", order.get("id"));
            response.put("amount", order.get("amount"));
            response.put("currency", order.get("currency"));
            response.put("keyId", razorpayProperties.getKeyId());

            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RazorpayException e) {
            Map<String, Object> error = new HashMap<>();
            error.put("message", e.getMessage());
            return new ResponseEntity<>(error, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/create-qr")
    public ResponseEntity<Map<String, Object>> createQrCode(@RequestBody Map<String, Object> data) {
        try {
            RazorpayClient razorpay = new RazorpayClient(razorpayProperties.getKeyId(), razorpayProperties.getKeySecret());

            JSONObject qrRequest = new JSONObject();
            qrRequest.put("type", "upi_qr");
            qrRequest.put("usage", "single_use");
            qrRequest.put("fixed_amount", true);
            qrRequest.put("payment_amount", Integer.parseInt(data.get("amount").toString()));
            qrRequest.put("description", "Bus Ticket Booking: " + data.get("bookingId"));
            
            // Close the QR after 10 minutes
            qrRequest.put("close_by", (System.currentTimeMillis() / 1000) + 600);

            QrCode qrCode = razorpay.qrCode.create(qrRequest);

            Map<String, Object> response = new HashMap<>();
            response.put("qrId", qrCode.get("id"));
            response.put("payment_url", qrCode.get("image_url")); // This is the image URL
            response.put("upi_url", qrCode.get("payment_url"));   // This is the upi://pay link
            
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (RazorpayException e) {
            Map<String, Object> error = new HashMap<>();
            error.put("message", e.getMessage());
            return new ResponseEntity<>(error, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/verify-payment")
    public ResponseEntity<Map<String, String>> verifyPayment(@RequestBody Map<String, String> data) {
        Map<String, String> response = new HashMap<>();
        try {
            String orderId = data.get("razorpay_order_id");
            String paymentId = data.get("razorpay_payment_id");
            String signature = data.get("razorpay_signature");

            JSONObject options = new JSONObject();
            options.put("razorpay_order_id", orderId);
            options.put("razorpay_payment_id", paymentId);
            options.put("razorpay_signature", signature);

            boolean isValid = Utils.verifyPaymentSignature(options, razorpayProperties.getKeySecret());

            if (isValid) {
                response.put("status", "success");
                response.put("message", "Payment verified successfully");
                return new ResponseEntity<>(response, HttpStatus.OK);
            } else {
                response.put("status", "failed");
                response.put("message", "Invalid signature");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", e.getMessage());
            return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
