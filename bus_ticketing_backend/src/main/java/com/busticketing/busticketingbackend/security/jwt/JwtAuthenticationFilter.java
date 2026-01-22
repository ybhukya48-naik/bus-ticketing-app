package com.busticketing.busticketingbackend.security.jwt;

import com.busticketing.busticketingbackend.service.UserDetailsServiceImpl;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.lang.NonNull;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

import org.springframework.stereotype.Component;

import org.springframework.context.annotation.Lazy;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private static final Logger logger = LoggerFactory.getLogger(JwtAuthenticationFilter.class);

    @Autowired
    private JwtUtils jwtUtils;

    @Autowired
    @Lazy
    private UserDetailsServiceImpl userDetailsService;

    @Override
    protected boolean shouldNotFilter(@NonNull HttpServletRequest request) throws ServletException {
        String path = request.getServletPath();
        return path.startsWith("/api/auth/login") || 
               path.startsWith("/api/auth/signin") || 
               path.startsWith("/api/auth/register") || 
               path.startsWith("/api/auth/signup") ||
               path.startsWith("/api/auth/test") ||
               path.startsWith("/actuator") ||
               path.startsWith("/error");
    }

    @Override
    protected void doFilterInternal(@NonNull HttpServletRequest request, @NonNull HttpServletResponse response, @NonNull FilterChain filterChain)
            throws ServletException, IOException {
        String path = request.getServletPath();
        String method = request.getMethod();
        logger.debug("Incoming request: {} {}", method, path);
        try {
            String jwt = parseJwt(request);
            if (jwt != null) {
                if (jwtUtils.validateJwtToken(jwt)) {
                    String username = jwtUtils.getUserNameFromJwtToken(jwt);
                    logger.debug("JWT token is valid. Username: {}", username);
                    UserDetails userDetails = userDetailsService.loadUserByUsername(username);
                    UsernamePasswordAuthenticationToken authentication =
                            new UsernamePasswordAuthenticationToken(
                                    userDetails,
                                    null,
                                    userDetails.getAuthorities());
                    authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

                    SecurityContextHolder.getContext().setAuthentication(authentication);
                    logger.debug("SecurityContext updated with authentication for user: {}", username);
                } else {
                    logger.warn("Invalid JWT Token for path: {}", path);
                }
            } else {
                logger.trace("No JWT found in request for path: {}", path);
            }
        } catch (Exception e) {
            logger.error("Cannot set user authentication: {} for path: {}", e.getMessage(), path);
        }

        filterChain.doFilter(request, response);
    }

    private String parseJwt(HttpServletRequest request) {
        String headerAuth = request.getHeader("Authorization");

        if (StringUtils.hasText(headerAuth) && headerAuth.startsWith("Bearer ")) {
            return headerAuth.substring(7);
        }

        return null;
    }
}
