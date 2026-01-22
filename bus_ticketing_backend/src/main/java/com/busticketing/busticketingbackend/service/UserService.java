package com.busticketing.busticketingbackend.service;

import com.busticketing.busticketingbackend.model.User;

import java.util.Optional;

public interface UserService {
    User registerNewUser(User user);
    Optional<User> findByUsername(String username);
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
}
