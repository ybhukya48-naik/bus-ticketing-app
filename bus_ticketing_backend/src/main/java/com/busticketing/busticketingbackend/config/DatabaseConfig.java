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
        logger.info("Initializing DataSource with URL: {}", databaseUrl);
        if (databaseUrl != null && databaseUrl.startsWith("postgres")) {
            logger.info("Detected postgres:// format. Converting to JDBC for PostgreSQL...");
            return createPostgresDataSource(databaseUrl);
        } else {
            logger.info("Using standard JDBC URL or H2 fallback: {}", databaseUrl);
            return createDefaultDataSource(databaseUrl);
        }
    }

    private DataSource createPostgresDataSource(String url) {
        try {
            // Remove postgres:// and split into parts
            String cleanUrl = url.substring(11); // Skip "postgres://"
            String[] userInfoHostPath = cleanUrl.split("@");
            
            String username = "";
            String password = "";
            String hostPath = "";

            if (userInfoHostPath.length > 1) {
                String userInfo = userInfoHostPath[0];
                hostPath = userInfoHostPath[1];
                String[] userPass = userInfo.split(":");
                username = userPass[0];
                password = userPass.length > 1 ? userPass[1] : "";
            } else {
                hostPath = userInfoHostPath[0];
                username = defaultUsername;
                password = defaultPassword;
            }

            // Extract host, port, and database name from hostPath (e.g., host:port/dbname)
            String[] hostPortDb = hostPath.split("/");
            String hostPort = hostPortDb[0];
            String dbName = hostPortDb.length > 1 ? hostPortDb[1] : "";

            StringBuilder jdbcUrl = new StringBuilder("jdbc:postgresql://").append(hostPort).append("/").append(dbName);
            
            // Render/Neon usually require SSL
            if (!jdbcUrl.toString().contains("?")) {
                jdbcUrl.append("?sslmode=require");
            }

            logger.info("Generated PostgreSQL JDBC URL: jdbc:postgresql://{}/{}", hostPort.split(":")[0], dbName);

            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(jdbcUrl.toString());
            config.setUsername(username);
            config.setPassword(password);
            config.setDriverClassName("org.postgresql.Driver");
            config.setMaximumPoolSize(Math.max(2, maxPoolSize)); // Ensure at least 2
            config.setConnectionTimeout(connectionTimeout);
            config.setIdleTimeout(idleTimeout);
            config.setMaxLifetime(maxLifetime);
            config.setPoolName("BusTicketingHikariPool");
            
            return new HikariDataSource(config);
        } catch (Exception e) {
            logger.error("Failed to parse PostgreSQL URL: {}. Falling back to default.", e.getMessage());
            return createDefaultDataSource(databaseUrl);
        }
    }

    private DataSource createDefaultDataSource(String url) {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(url);
        config.setUsername(defaultUsername);
        config.setPassword(defaultPassword);
        config.setMaximumPoolSize(maxPoolSize);
        config.setConnectionTimeout(connectionTimeout);
        config.setIdleTimeout(idleTimeout);
        config.setMaxLifetime(maxLifetime);
        
        if (url.contains("h2")) {
            config.setDriverClassName("org.h2.Driver");
        } else if (url.contains("postgresql")) {
            config.setDriverClassName("org.postgresql.Driver");
        }
        
        return new HikariDataSource(config);
    }
}
