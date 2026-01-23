package com.busticketing.busticketingbackend.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnExpression;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

import javax.sql.DataSource;
import java.net.URI;
import java.net.URISyntaxException;

@Configuration
public class DatabaseConfig {

    private static final Logger logger = LoggerFactory.getLogger(DatabaseConfig.class);

    @Value("${SPRING_DATASOURCE_URL:${DATABASE_URL:jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1;MODE=PostgreSQL}}")
    private String databaseUrl;

    @Value("${SPRING_DATASOURCE_USERNAME:sa}")
    private String defaultUsername;

    @Value("${SPRING_DATASOURCE_PASSWORD:}")
    private String defaultPassword;

    @Bean
    @Primary
    public DataSource dataSource() {
        if (databaseUrl.startsWith("postgres")) {
            logger.info("Detected postgres:// format. Converting to JDBC for PostgreSQL...");
            return createPostgresDataSource(databaseUrl);
        } else {
            logger.info("Using standard JDBC URL: {}", databaseUrl);
            return createDefaultDataSource(databaseUrl);
        }
    }

    private DataSource createPostgresDataSource(String url) {
        try {
            URI uri = new URI(url);
            String userInfo = uri.getUserInfo();
            String host = uri.getHost();
            int port = uri.getPort();
            String path = uri.getPath();

            String username = defaultUsername;
            String password = defaultPassword;

            if (userInfo != null) {
                String[] userPass = userInfo.split(":");
                username = userPass[0];
                password = userPass.length > 1 ? userPass[1] : "";
            }

            StringBuilder jdbcUrl = new StringBuilder("jdbc:postgresql://").append(host);
            if (port != -1) jdbcUrl.append(":").append(port);
            jdbcUrl.append(path);
            
            if (!jdbcUrl.toString().contains("?")) {
                jdbcUrl.append("?sslmode=require");
            } else if (!jdbcUrl.toString().contains("sslmode")) {
                jdbcUrl.append("&sslmode=require");
            }

            logger.info("Generated PostgreSQL JDBC URL for host: {}", host);

            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(jdbcUrl.toString());
            config.setUsername(username);
            config.setPassword(password);
            config.setDriverClassName("org.postgresql.Driver");
            config.setMaximumPoolSize(5);
            return new HikariDataSource(config);
        } catch (URISyntaxException e) {
            throw new RuntimeException("Failed to parse PostgreSQL URL", e);
        }
    }

    private DataSource createDefaultDataSource(String url) {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(url);
        config.setUsername(defaultUsername);
        config.setPassword(defaultPassword);
        
        if (url.contains("h2")) {
            config.setDriverClassName("org.h2.Driver");
        } else if (url.contains("postgresql")) {
            config.setDriverClassName("org.postgresql.Driver");
        }
        
        return new HikariDataSource(config);
    }
}
