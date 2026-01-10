package com.busticketing.busticketingbackend.service;

import com.busticketing.busticketingbackend.model.User;
import com.busticketing.busticketingbackend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;
import java.util.UUID;

@Service
public class PasswordResetService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    public String generatePasswordResetToken(String email) {
        Optional<User> userOptional = userRepository.findByEmail(email);
        if (userOptional.isPresent()) {
            User user = userOptional.get();
            String token = UUID.randomUUID().toString();
            user.setPasswordResetToken(token);
            userRepository.save(user);
            return token;
        }
        return null;
    }

    public void sendPasswordResetEmail(String email, String token) {
        System.out.println("Sending password reset email to: " + email);
        System.out.println("Reset link: http://localhost:8080/api/auth/reset-password?token=" + token);
    }

    public boolean resetPassword(String token, String newPassword) {
        Optional<User> userOptional = userRepository.findByPasswordResetToken(token);
        if (userOptional.isPresent()) {
            User user = userOptional.get();
            user.setPassword(passwordEncoder.encode(newPassword));
            user.setPasswordResetToken(null);
            userRepository.save(user);
            return true;
        }
        return false;
    }
}
