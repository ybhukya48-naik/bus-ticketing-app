package com.busticketing.busticketingbackend.controller;

import com.busticketing.busticketingbackend.dto.JwtResponse;
import com.busticketing.busticketingbackend.dto.LoginRequest;
import com.busticketing.busticketingbackend.dto.RegisterRequest;
import com.busticketing.busticketingbackend.model.User;
import com.busticketing.busticketingbackend.payload.request.ForgotPasswordRequest;
import com.busticketing.busticketingbackend.service.PasswordResetService;
import com.busticketing.busticketingbackend.service.UserService;
import com.busticketing.busticketingbackend.security.jwt.JwtUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.CrossOrigin;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*", maxAge = 3600)
public class UserController {

    @Autowired
    private UserService userService;

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private PasswordResetService passwordResetService;

    @Autowired
    private JwtUtils jwtUtils;

    @GetMapping("/test")
    public String test() {
        return "Backend is working!";
    }

    @PostMapping({"/register", "/signup"})
    public ResponseEntity<?> registerUser(@RequestBody RegisterRequest registerRequest) {
        System.out.println("!!! Received registration request for username: " + registerRequest.getUsername() + ", email: " + registerRequest.getEmail() + " !!!");
        
        if (registerRequest.getUsername() == null || registerRequest.getUsername().isEmpty()) {
            return new ResponseEntity<>("Error: Username is required!", HttpStatus.BAD_REQUEST);
        }
        if (registerRequest.getEmail() == null || registerRequest.getEmail().isEmpty()) {
            return new ResponseEntity<>("Error: Email is required!", HttpStatus.BAD_REQUEST);
        }
        if (registerRequest.getPassword() == null || registerRequest.getPassword().isEmpty()) {
            return new ResponseEntity<>("Error: Password is required!", HttpStatus.BAD_REQUEST);
        }

        if (userService.existsByUsername(registerRequest.getUsername())) {
            System.out.println("!!! Registration failed: Username " + registerRequest.getUsername() + " already taken !!!");
            return new ResponseEntity<>("Error: Username is already taken!", HttpStatus.BAD_REQUEST);
        }

        if (userService.existsByEmail(registerRequest.getEmail())) {
            System.out.println("!!! Registration failed: Email " + registerRequest.getEmail() + " already in use !!!");
            return new ResponseEntity<>("Error: Email is already in use!", HttpStatus.BAD_REQUEST);
        }

        try {
            User user = new User();
            user.setUsername(registerRequest.getUsername());
            user.setPassword(registerRequest.getPassword());
            user.setEmail(registerRequest.getEmail());

            System.out.println("!!! Saving user to database... !!!");
            User savedUser = userService.registerNewUser(user);
            System.out.println("!!! User saved successfully with ID: " + savedUser.getId() + " !!!");
            
            return ResponseEntity.ok("User registered successfully!");
        } catch (Exception e) {
            System.out.println("!!! Error during registration: " + e.getMessage() + " !!!");
            e.printStackTrace();
            return new ResponseEntity<>("Error: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping({"/login", "/signin"})
    public ResponseEntity<?> authenticateUser(@RequestBody LoginRequest loginRequest) {
        System.out.println("!!! Login attempt for user: " + loginRequest.getUsername() + " !!!");
        try {
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            loginRequest.getUsername(),
                            loginRequest.getPassword()
                    )
            );

            SecurityContextHolder.getContext().setAuthentication(authentication);
            String jwt = jwtUtils.generateJwtToken(authentication);
            
            // Get the actual username from the authenticated user details
            org.springframework.security.core.userdetails.User userDetails = 
                (org.springframework.security.core.userdetails.User) authentication.getPrincipal();
            String actualUsername = userDetails.getUsername();

            System.out.println("!!! Login successful for user: " + actualUsername + " !!!");
            return ResponseEntity.ok(new JwtResponse(jwt, actualUsername));
        } catch (AuthenticationException e) {
            System.out.println("!!! Login failed for user: " + loginRequest.getUsername() + " - Error: " + e.getMessage() + " !!!");
            return new ResponseEntity<>("Error: Invalid username or password", HttpStatus.UNAUTHORIZED);
        }
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@RequestBody ForgotPasswordRequest forgotPasswordRequest) {
        String email = forgotPasswordRequest.getEmail();
        String token = passwordResetService.generatePasswordResetToken(email);

        if (token != null) {
            passwordResetService.sendPasswordResetEmail(email, token);
            return new ResponseEntity<>("Password reset link sent to your email!", HttpStatus.OK);
        } else {
            return new ResponseEntity<>("User with that email not found!", HttpStatus.NOT_FOUND);
        }
    }

    @GetMapping("/profile")
    public ResponseEntity<?> getUserProfile() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated() || authentication.getName().equals("anonymousUser")) {
            return new ResponseEntity<>("Error: Not authenticated", HttpStatus.UNAUTHORIZED);
        }
        
        String username = authentication.getName();
        System.out.println("!!! Fetching profile for user: " + username + " !!!");
        
        User user = userService.findByUsername(username).orElse(null);
        if (user != null) {
            return ResponseEntity.ok(user);
        } else {
            return new ResponseEntity<>("Error: User not found in database", HttpStatus.NOT_FOUND);
        }
    }
}
