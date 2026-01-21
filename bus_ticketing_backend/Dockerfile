# Stage 1: Build the application
FROM eclipse-temurin:17-jdk AS build
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

# Stage 2: Create the runtime image
FROM eclipse-temurin:17-jre
WORKDIR /app

# Copy the JAR from the build stage
COPY --from=build /app/build/libs/app.jar app.jar

# Expose the port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
