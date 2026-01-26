package com.busticketing.busticketingbackend.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnExpression;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.jdbc.core.JdbcTemplate;
import java.util.concurrent.CompletableFuture;

import javax.sql.DataSource;
import java.net.URI;
import java.net.URISyntaxException;

@Configuration
public class DatabaseConfig {

    private static final Logger logger = LoggerFactory.getLogger(DatabaseConfig.class);

    @Bean
    public CommandLineRunner databaseWaker(DataSource dataSource) {
        return args -> {
            CompletableFuture.runAsync(() -> {
                logger.info("Database waker started in background thread...");
                try {
                    JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
                    jdbcTemplate.execute("SELECT 1");
                    logger.info("Database waker: Successfully pinged database!");
                } catch (Exception e) {
                    logger.warn("Database waker: Initial ping failed (DB might still be waking up): {}", e.getMessage());
                }
            });
        };
    }

    @Value("${SPRING_DATASOURCE_URL:${DATABASE_URL:jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1;MODE=PostgreSQL}}")
    private String databaseUrl;

    @Value("${SPRING_DATASOURCE_USERNAME:sa}")
    private String defaultUsername;

    @Value("${SPRING_DATASOURCE_PASSWORD:}")
    private String defaultPassword;

    @Value("${spring.datasource.hikari.maximum-pool-size:5}")
    private int maxPoolSize;

    @Value("${spring.datasource.hikari.connection-timeout:30000}")
    private long connectionTimeout;

    @Value("${spring.datasource.hikari.idle-timeout:30000}")
    private long idleTimeout;

    @Value("${spring.datasource.hikari.max-lifetime:600000}")
    private long maxLifetime;

    @Bean
    @Primary
    public DataSource dataSource() {
        if (databaseUrl != null && (databaseUrl.startsWith("postgres") || databaseUrl.startsWith("jdbc:postgresql"))) {
            logger.info("Initializing PostgreSQL DataSource. URL detected: {}", databaseUrl.startsWith("postgres://") ? "postgres://***" : "jdbc:postgresql://***");
            return createPostgresDataSource(databaseUrl);
        } else {
            logger.warn("No PostgreSQL URL detected (DATABASE_URL/SPRING_DATASOURCE_URL). Using H2/Default fallback: {}", databaseUrl);
            return createDefaultDataSource(databaseUrl);
        }
    }

    private DataSource createPostgresDataSource(String url) {
        try {
            // Use URI for robust parsing of postgres:// or postgresql://
            URI uri = new URI(url);
            String userInfo = uri.getUserInfo();
            String username = defaultUsername;
            String password = defaultPassword;

            if (userInfo != null && userInfo.contains(":")) {
                String[] parts = userInfo.split(":");
                username = parts[0];
                password = parts.length > 1 ? parts[1] : "";
            }

            String host = uri.getHost();
            int port = uri.getPort();
            if (port == -1) port = 5432;
            String path = uri.getPath();
            String dbName = (path != null && path.length() > 1) ? path.substring(1) : "";

            StringBuilder jdbcUrl = new StringBuilder("jdbc:postgresql://")
                    .append(host)
                    .append(":")
                    .append(port)
                    .append("/")
                    .append(dbName);
            
            // Append existing query parameters if any
            String query = uri.getQuery();
            if (query != null && !query.isEmpty()) {
                jdbcUrl.append("?").append(query);
            }

            // Ensure sslmode=require if not specified (required for Neon/Render)
            if (query == null || !query.contains("sslmode")) {
                if (jdbcUrl.toString().contains("?")) {
                    jdbcUrl.append("&sslmode=require");
                } else {
                    jdbcUrl.append("?sslmode=require");
                }
            }

            logger.info("Generated PostgreSQL JDBC URL (redacted): {}", jdbcUrl.toString().replaceAll(":.*@", ":***@"));

            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(jdbcUrl.toString());
            config.setUsername(username);
            config.setPassword(password);
            config.setDriverClassName("org.postgresql.Driver");
            config.setMaximumPoolSize(maxPoolSize > 0 ? maxPoolSize : 2);
            config.setMinimumIdle(maxPoolSize > 0 ? maxPoolSize : 2); // Set same as max to avoid dynamic pool overhead on Free Tier
            config.setConnectionTimeout(connectionTimeout);
            // config.setIdleTimeout(idleTimeout); // Removed to avoid warning in fixed size pool
            config.setMaxLifetime(maxLifetime);
            config.setPoolName("BusTicketingHikariPool");
            
            logger.info("HikariCP configured. Attempting to create DataSource...");
            return new HikariDataSource(config);
        } catch (Exception e) {
            logger.error("Error creating PostgreSQL DataSource: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to create PostgreSQL DataSource", e);
        }
    }

    private DataSource createDefaultDataSource(String url) {
        try {
            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(url);
            config.setUsername(defaultUsername);
            config.setPassword(defaultPassword);
            config.setMaximumPoolSize(maxPoolSize > 0 ? maxPoolSize : 2);
            config.setMinimumIdle(maxPoolSize > 0 ? maxPoolSize : 2); // Fixed size pool
            config.setConnectionTimeout(connectionTimeout);
            config.setPoolName("H2HikariPool");
            
            logger.info("H2/Default HikariCP configured. Attempting to create DataSource...");
            return new HikariDataSource(config);
        } catch (Exception e) {
            logger.error("Error creating default DataSource: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to create default DataSource", e);
        }
    }
}
