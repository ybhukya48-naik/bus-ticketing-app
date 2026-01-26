# Build stage
FROM eclipse-temurin:17-jdk AS build
WORKDIR /app

# Set Gradle memory limits for Render free tier
ENV GRADLE_OPTS="-Dorg.gradle.daemon=false -Dorg.gradle.jvmargs='-Xmx512m -XX:MaxMetaspaceSize=192m'"

# Copy gradle files for caching
COPY gradlew .
COPY gradle gradle
COPY build.gradle .
COPY settings.gradle .

# Fix line endings in case they were changed on Windows and set permissions
RUN apt-get update && apt-get install -y dos2unix && \
    dos2unix gradlew && \
    chmod +x gradlew

# Download dependencies
RUN ./gradlew dependencies --no-daemon

# Copy source code and data
COPY src src
COPY *.csv . 

# Build the application - skip tests
RUN ./gradlew clean bootJar -x test --no-daemon

# Final stage
FROM eclipse-temurin:17-jre
WORKDIR /app

# Copy the jar from build stage
COPY --from=build /app/build/libs/app.jar .
# Copy CSV files to the final image so the app can find them at runtime
COPY --from=build /app/*.csv ./

EXPOSE 10000

# Use shell form to ensure environment variable substitution for $PORT
ENTRYPOINT java -XX:+UseSerialGC -Xss512k -XX:MaxRAMPercentage=75.0 -XX:TieredStopAtLevel=1 -Djava.security.egd=file:/dev/./urandom -Dserver.port=${PORT:-10000} -jar app.jar
