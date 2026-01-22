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
@ConditionalOnExpression("'${DATABASE_URL:}'.startsWith('postgres')")
public class DatabaseConfig {

    private static final Logger logger = LoggerFactory.getLogger(DatabaseConfig.class);

    @Value("${DATABASE_URL}")
    private String databaseUrl;

    @Bean
    @Primary
    public DataSource dataSource() {
        logger.info("Detected DATABASE_URL in postgres:// format. Converting to JDBC...");
        try {
            URI uri = new URI(databaseUrl);
            String userInfo = uri.getUserInfo();
            String host = uri.getHost();
            int port = uri.getPort();
            String path = uri.getPath();

            if (userInfo == null || host == null) {
                throw new URISyntaxException(databaseUrl, "Invalid database URL components");
            }

            String[] userPass = userInfo.split(":");
            String username = userPass[0];
            String password = userPass.length > 1 ? userPass[1] : "";

            // Build JDBC URL
            StringBuilder jdbcUrl = new StringBuilder("jdbc:postgresql://").append(host);
            
            if (port != -1) {
                jdbcUrl.append(":").append(port);
            }
            
            jdbcUrl.append(path);
            
            if (!jdbcUrl.toString().contains("?")) {
                jdbcUrl.append("?sslmode=require");
            } else if (!jdbcUrl.toString().contains("sslmode")) {
                jdbcUrl.append("&sslmode=require");
            }

            logger.info("Generated JDBC URL successfully (password masked)");

            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(jdbcUrl.toString());
            config.setUsername(username);
            config.setPassword(password);
            config.setDriverClassName("org.postgresql.Driver");
            
            config.setMaximumPoolSize(10);
            config.setMinimumIdle(1);
            config.setIdleTimeout(60000);
            config.setConnectionTimeout(30000);
            config.setMaxLifetime(1800000);

            return new HikariDataSource(config);
        } catch (URISyntaxException e) {
            logger.error("Failed to parse DATABASE_URL: {}", e.getMessage());
            throw new RuntimeException("Invalid DATABASE_URL", e);
        }
    }
}
