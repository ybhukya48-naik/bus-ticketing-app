# Build stage
FROM eclipse-temurin:17-jdk-alpine AS build
WORKDIR /app

# Copy gradle files for caching
COPY gradlew .
RUN chmod +x gradlew
COPY gradle gradle
COPY build.gradle .
COPY settings.gradle .

# Download dependencies
RUN ./gradlew dependencies --no-daemon

# Copy source code and data
COPY src src
COPY *.csv .
COPY *.sql .

# Build the application - skip tests to speed up and avoid DB connection issues during build
RUN ./gradlew clean bootJar -x test --no-daemon

# Final stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Copy the jar from build stage
COPY --from=build /app/build/libs/*.jar app.jar

# Copy data.sql if needed for runtime initialization (though Hibernate handles it)
# The jar contains the resources, but if you want to keep them external:
# COPY --from=build /app/src/main/resources/data.sql data.sql

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
