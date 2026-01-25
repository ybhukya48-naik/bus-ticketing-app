# Build stage
FROM eclipse-temurin:17-jdk AS build
WORKDIR /app

# Set Gradle memory limits for Render free tier
ENV GRADLE_OPTS="-Dorg.gradle.daemon=false -Dorg.gradle.jvmargs='-Xmx384m -XX:MaxMetaspaceSize=128m'"

# Copy gradle files for caching
COPY gradlew .
RUN chmod +x gradlew
COPY gradle gradle
COPY build.gradle .
COPY settings.gradle .

# Download dependencies
RUN ./gradlew dependencies --no-daemon

# Copy source code
COPY src src
# Use wildcards safely to avoid build failure if files are missing
COPY *.csv . 

# Build the application - skip tests to speed up and avoid DB connection issues during build
RUN ./gradlew clean bootJar -x test --no-daemon

# Final stage
FROM eclipse-temurin:17-jre
WORKDIR /app

# Copy the jar from build stage
COPY --from=build /app/build/libs/*.jar app.jar

EXPOSE 8080

# Use optimized JVM flags for small memory environments
# -XX:+UseSerialGC: Better for single-core/low-memory
# -XX:MaxRAMPercentage=75.0: Dynamically allocate memory based on container limit (512MB)
# -Xss512k: Reduce thread stack size to save memory
# -XX:TieredStopAtLevel=1: Faster startup by limiting JIT optimization
ENTRYPOINT ["java", "-XX:+UseSerialGC", "-Xss512k", "-XX:MaxRAMPercentage=75.0", "-XX:TieredStopAtLevel=1", "-Djava.security.egd=file:/dev/./urandom", "-Dserver.port=${PORT}", "-jar", "app.jar"]
