package com.busticketing.busticketingbackend.service;

import com.busticketing.busticketingbackend.model.User;
import com.busticketing.busticketingbackend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.ArrayList;

@Service
public class UserDetailsServiceImpl implements UserDetailsService {

    @Autowired
    private UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String usernameOrEmail) throws UsernameNotFoundException {
        if (usernameOrEmail != null) {
            usernameOrEmail = usernameOrEmail.trim();
        }
        
        // Try to find by username first
        User user = userRepository.findByUsername(usernameOrEmail);
        
        // If not found, try to find by email
        if (user == null) {
            user = userRepository.findByEmail(usernameOrEmail).orElse(null);
        }

        if (user == null) {
            throw new UsernameNotFoundException("User not found with username or email: " + usernameOrEmail);
        }
        return new org.springframework.security.core.userdetails.User(user.getUsername(), user.getPassword(), new ArrayList<>());
    }
}
