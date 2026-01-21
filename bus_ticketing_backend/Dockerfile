# Stage 1: Build the application
FROM eclipse-temurin:17-jdk-alpine AS build
WORKDIR /app

# Copy gradle files for caching
COPY gradle/ gradle/
COPY gradlew .
COPY settings.gradle .
COPY build.gradle .

# Grant execution permissions for gradlew
RUN chmod +x ./gradlew

# Build dependencies (offline if possible)
RUN ./gradlew dependencies

# Copy the source code
COPY src/ src/

# Build the application (skipping tests for faster deployment)
RUN ./gradlew build -x test

# Remove the plain JAR so only the executable one remains
RUN rm -f build/libs/*-plain.jar

# Stage 2: Create the runtime image
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Copy the JAR from the build stage
COPY --from=build /app/build/libs/*.jar app.jar

# Expose the port (Render uses $PORT, but we'll default to 8080)
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
