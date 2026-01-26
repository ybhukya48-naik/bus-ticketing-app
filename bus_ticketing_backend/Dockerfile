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

EXPOSE 10000

# Use shell form to ensure environment variable substitution for $PORT
ENTRYPOINT java -XX:+UseSerialGC -Xss512k -XX:MaxRAMPercentage=75.0 -XX:TieredStopAtLevel=1 -Djava.security.egd=file:/dev/./urandom -Dserver.port=${PORT:-10000} -jar app.jar
