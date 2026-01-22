# Stage 1: Build the application
FROM eclipse-temurin:20-jdk AS build
WORKDIR /app

# Install dos2unix to fix Windows line endings in gradlew
RUN apt-get update && apt-get install -y dos2unix


# Copy only the necessary files for building
COPY gradlew .
COPY gradle/ gradle/
COPY settings.gradle .
COPY build.gradle .
COPY src/ src/

# Fix line endings and permissions
RUN dos2unix gradlew
RUN chmod +x gradlew

# Build the application using bootJar
RUN ./gradlew bootJar -x test

# Stage 2: Runtime
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/build/libs/app.jar app.jar
EXPOSE 8080

# JVM flags for memory management in 512MB container
# -Xmx512m: Max heap 512MB
# -Xms256m: Start heap 256MB
# -XX:+UseG1GC: Modern garbage collector
ENTRYPOINT ["java", "-Xms256m", "-Xmx512m", "-XX:+UseG1GC", "-jar", "app.jar"]
