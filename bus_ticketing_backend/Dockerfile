# Stage 1: Build the application
FROM eclipse-temurin:17-jdk AS build
WORKDIR /app

# Copy only the necessary files for building
COPY gradlew .
COPY gradle/ gradle/
COPY settings.gradle .
COPY build.gradle .
COPY src/ src/

# Fix line endings and permissions using sed (more robust than dos2unix if image changes)
RUN sed -i 's/\r$//' gradlew
RUN chmod +x gradlew

# Build the application using bootJar
RUN ./gradlew bootJar -x test

# Stage 2: Runtime
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/build/libs/app.jar app.jar
EXPOSE 8080

# JVM flags for memory management in 512MB container
ENTRYPOINT ["java", "-Xms256m", "-Xmx512m", "-XX:+UseG1GC", "-jar", "app.jar"]
