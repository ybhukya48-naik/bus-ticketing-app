package com.busticketing.busticketingbackend.service;

import com.busticketing.busticketingbackend.model.User;

public interface UserService {
    User registerNewUser(User user);
    User findByUsername(String username);
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
}
